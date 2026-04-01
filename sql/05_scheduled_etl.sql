-- ============================================================
--  GENDES FEMININE HYGIENE — STAR SCHEMA DATABASE
--  PostgreSQL | Gendes Marketplace Sales Analysis
--  Platform  : TikTok Shop + Shopee | Periode: 2023–Sekarang
-- ============================================================
--  FILE     : 05_scheduled_etl.sql
--  PERAN    : Pipeline refresh data harian. Dijalankan setiap
--             hari setelah file laporan baru dari TikTok Shop
--             dan Shopee tersedia di seller center.
--
--  MENGAPA FILE INI ADA:
--    Dashboard tiga divisi (Executive, Marketing, Brand) hanya
--    bernilai jika datanya selalu terkini. File ini memastikan
--    data di fact_orders dan semua dim tables diperbarui setiap
--    hari secara aman tanpa duplikasi, sehingga view di
--    04_views.sql selalu membaca data yang akurat saat Power BI
--    membuka dashboard pagi hari.
--
--  ALUR EKSEKUSI:
--    Step 0 → Extend dim_date otomatis hingga akhir tahun berjalan
--    Step 1 → Bersihkan staging dari batch kemarin
--    Step 2 → Load CSV baru ke staging (manual / script Python)
--    Step 3 → Upsert dimensi baru yang belum ada
--    Step 4 → Insert transaksi baru ke fact_orders
--    Step 5 → Update dim_buyer (segment & total_orders)
--    Step 6 → Validasi hasil refresh sebelum dashboard dibuka
--
--  KEAMANAN PIPELINE:
--    - dim_date auto-extend  → pipeline tidak pernah gagal karena ganti tahun
--    - TRUNCATE staging      → data lama bersih sebelum load baru
--    - ON CONFLICT DO NOTHING di semua dim → tidak ada duplikasi
--    - WHERE NOT EXISTS di fact insert → order tidak masuk dua kali
--    - UPDATE dim_buyer setelah insert → segmen selalu akurat
--    - Semua step idempoten: aman dijalankan ulang jika gagal
--
--  JALANKAN SETELAH: 04_views.sql
-- ============================================================

set search_path to gendes, public;


-- ============================================================
-- STEP 0: EXTEND dim_date HINGGA AKHIR TAHUN BERJALAN
-- ============================================================
-- dim_date di 01_schema_and_dimensions.sql hanya di-generate
-- sampai 2025-12-31. Tanpa step ini, pipeline akan gagal saat
-- ada transaksi dengan tanggal di luar rentang tersebut karena
-- date_key tidak akan ditemukan di dim_date, dan insert ke
-- fact_orders akan error FK violation.
--
-- Logika step ini:
--   1. Cek tanggal terakhir yang ada di dim_date
--   2. Jika tanggal tersebut sudah mencakup 31 Desember tahun
--      berjalan, tidak ada yang perlu dilakukan (0 baris insert)
--   3. Jika belum, generate semua tanggal yang kurang hingga
--      31 Desember tahun berjalan dan insert ke dim_date
--
-- ON CONFLICT DO NOTHING memastikan step ini aman dijalankan
-- setiap hari tanpa duplikasi meskipun dim_date sudah lengkap.
-- ============================================================

insert into dim_date (
    date_key, full_date, year, quarter, month, month_name,
    month_abbr, week_of_year, day_of_month, day_of_week,
    day_name, is_weekend, is_payday, semester,
    year_month, year_quarter
)
select
    to_char(d, 'YYYYMMDD')::integer,
    d::date,
    extract(year    from d)::smallint,
    extract(quarter from d)::smallint,
    extract(month   from d)::smallint,
    to_char(d, 'Month'),
    to_char(d, 'Mon'),
    extract(week    from d)::smallint,
    extract(day     from d)::smallint,
    extract(dow     from d)::smallint,
    to_char(d, 'Day'),
    extract(dow from d) in (0, 6),
    extract(day from d) >= 25 or extract(day from d) <= 5,
    case when extract(month from d) <= 6 then 1 else 2 end::smallint,
    to_char(d, 'YYYY-MM'),
    to_char(d, 'YYYY') || '-Q' || extract(quarter from d)::text
from generate_series(
    -- mulai dari hari setelah tanggal terakhir di dim_date
    (select max(full_date) + 1 from dim_date),
    -- hingga 31 Desember tahun berjalan
    date_trunc('year', current_date)::date + interval '1 year - 1 day',
    '1 day'::interval
) as g(d)
on conflict (date_key) do nothing;


-- Verifikasi: tampilkan rentang dim_date setelah extend
-- (tanggal akhir harus selalu = 31 Desember tahun berjalan)
select
    min(full_date) as date_start,
    max(full_date) as date_end,
    count(*)       as total_days
from dim_date;


-- ============================================================
-- STEP 1: BERSIHKAN STAGING TABLE
-- ============================================================
-- Staging hanya menyimpan data batch hari ini, bukan akumulasi.
-- Truncate dilakukan sebelum load agar tidak ada data ganda
-- dari laporan yang didownload ulang.
-- ============================================================

truncate table stg_tiktok;
truncate table stg_shopee;


-- ============================================================
-- STEP 2: LOAD CSV KE STAGING
-- ============================================================
-- Jalankan \copy dari terminal psql setelah truncate di atas,
-- atau gunakan fitur Import di pgAdmin / DBeaver.
--
-- Contoh perintah dari terminal psql:
--
--   \copy gendes.stg_tiktok FROM '/path/to/tiktok_hari_ini.csv'
--   WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
--
--   \copy gendes.stg_shopee FROM '/path/to/shopee_hari_ini.csv'
--   WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
--
-- File laporan didownload dari:
--   TikTok Shop Seller Center > Export
--   Shopee Seller Center      > Export
-- ============================================================


-- ============================================================
-- STEP 3: UPSERT DIMENSI BARU
-- ============================================================
-- Insert hanya data dimensi yang belum ada.
-- ON CONFLICT DO NOTHING memastikan data lama tidak tertimpa.
-- ============================================================

-- 3A. Produk baru
insert into dim_product (
    sku_id, seller_sku, product_name, variation,
    product_type, size_ml, is_bundle, price_tier,
    base_price, weight_kg, product_category
)
select distinct on (s.sku_id)
    s.sku_id, s.seller_sku, s.product_name, s.variation,
    case
        when lower(s.variation) like 'spray%'  then 'Spray'
        when lower(s.variation) like 'foam%'   then 'Foam'
        when lower(s.variation) like 'bundle%' then 'Bundle'
        else 'Other'
    end,
    case
        when s.variation like '%20ml%' then 20
        when s.variation like '%60ml%' then 60
        else null
    end,
    lower(s.variation) like '%bundle%',
    case
        when s.unit_price < 35000  then 'Budget'
        when s.unit_price <= 50000 then 'Standard'
        else 'Premium'
    end,
    s.unit_price,
    s.weight_kg::numeric,
    'Feminine Hygiene'
from (
    select "Seller SKU" as sku_id, "SKU ID" as seller_sku,
           "Product Name" as product_name, "Variation" as variation,
           "SKU Unit Original Price"::numeric as unit_price,
           "Weight(kg)" as weight_kg
    from stg_tiktok where "Seller SKU" is not null
    union all
    select "SKU Induk", "Nomor Referensi SKU",
           "Nama Produk", "Nama Variasi",
           "Harga Awal"::numeric, "Berat Produk"
    from stg_shopee where "SKU Induk" is not null
) s
order by s.sku_id, s.unit_price desc
on conflict (sku_id) do nothing;


-- 3B. Lokasi baru
insert into dim_location (
    province, regency_city, district, village, zipcode,
    island_group, region_group
)
select distinct
    coalesce(province, 'Unknown'),
    coalesce(regency_city, 'Unknown'),
    nullif(district, ''),
    nullif(village, ''),
    nullif(zipcode, ''),
    case
        when province in ('DKI Jakarta','Jawa Barat','Jawa Tengah',
                          'Jawa Timur','Banten','Yogyakarta')
            then 'Jawa'
        when province in ('Sumatera Utara','Sumatera Barat','Sumatera Selatan',
                          'Riau','Kepulauan Riau','Jambi','Bengkulu',
                          'Lampung','Bangka Belitung','Aceh')
            then 'Sumatera'
        when province in ('Kalimantan Timur','Kalimantan Selatan',
                          'Kalimantan Tengah','Kalimantan Barat','Kalimantan Utara')
            then 'Kalimantan'
        when province in ('Sulawesi Selatan','Sulawesi Tengah','Sulawesi Utara',
                          'Sulawesi Tenggara','Sulawesi Barat','Gorontalo')
            then 'Sulawesi'
        when province in ('Bali','Nusa Tenggara Barat','Nusa Tenggara Timur')
            then 'Bali & Nusa Tenggara'
        else 'Indonesia Timur'
    end,
    case
        when province = 'DKI Jakarta' then 'Jabodetabek'
        when province = 'Banten'      then 'Jabodetabek'
        when province = 'Jawa Barat'
         and regency_city in ('Bekasi','Depok','Bogor') then 'Jabodetabek'
        else province
    end
from (
    select "Province" as province, "Regency and City" as regency_city,
           "Districts" as district, "Villages" as village, "Zipcode" as zipcode
    from stg_tiktok
    union all
    select "Provinsi", "Kota/Kabupaten", null, null, null
    from stg_shopee
) loc
on conflict (province, regency_city, district, village) do nothing;


-- 3C. Marketplace / channel baru
insert into dim_marketplace (
    platform_name, purchase_channel, fulfillment_type,
    delivery_option, shipping_provider
)
select distinct
    'TikTok',
    nullif("Purchase Channel", ''),
    nullif("Fulfillment Type", ''),
    nullif("Delivery Option", ''),
    nullif("Shipping Provider Name", '')
from stg_tiktok
union
select distinct
    'Shopee', null, null,
    nullif("Opsi Pengiriman", ''),
    null
from stg_shopee
on conflict (platform_name, purchase_channel, fulfillment_type,
             delivery_option, shipping_provider) do nothing;


-- 3D. Warehouse baru
insert into dim_warehouse (warehouse_name, city, province, island_group)
select distinct
    warehouse_name,
    trim(replace(lower(warehouse_name), 'gudang', '')),
    case
        when lower(warehouse_name) like '%jakarta%'  then 'DKI Jakarta'
        when lower(warehouse_name) like '%bandung%'  then 'Jawa Barat'
        when lower(warehouse_name) like '%surabaya%' then 'Jawa Timur'
        when lower(warehouse_name) like '%medan%'    then 'Sumatera Utara'
        else 'Unknown'
    end,
    case
        when lower(warehouse_name) like '%jakarta%'  then 'Jawa'
        when lower(warehouse_name) like '%bandung%'  then 'Jawa'
        when lower(warehouse_name) like '%surabaya%' then 'Jawa'
        when lower(warehouse_name) like '%medan%'    then 'Sumatera'
        else 'Unknown'
    end
from (
    select "Warehouse Name" as warehouse_name from stg_tiktok
    union
    select "Nama Gudang" from stg_shopee
) w
where warehouse_name is not null and warehouse_name != ''
on conflict (warehouse_name) do nothing;


-- 3E. Buyer baru
insert into dim_buyer (username, platform_name, recipient_name, phone_masked)
select distinct on (username)
    username, platform_name, recipient_name,
    left(phone, 4) || 'xxxx' || right(phone, 3)
from (
    select "Buyer Username" as username, 'TikTok' as platform_name,
           "Recipient" as recipient_name, "Phone #" as phone
    from stg_tiktok where "Buyer Username" is not null
    union all
    select "Username (Pembeli)", 'Shopee',
           "Nama Penerima", "No. Telepon"
    from stg_shopee where "Username (Pembeli)" is not null
) b
order by username
on conflict (username) do nothing;


-- ============================================================
-- STEP 4: INSERT TRANSAKSI BARU KE fact_orders
-- ============================================================
-- WHERE NOT EXISTS memastikan order_id yang sudah ada tidak
-- dimasukkan dua kali, sehingga pipeline aman dijalankan ulang.
-- ============================================================

-- 4A. TikTok
insert into fact_orders (
    date_key, product_key, location_key, marketplace_key,
    buyer_key, warehouse_key, promo_key,
    order_id, platform_name, tracking_id, package_id, payment_method,
    order_status, cancel_by, cancel_reason,
    is_cancelled, is_returned, is_completed,
    created_at, paid_at, shipped_at, delivered_at, cancelled_at, completed_at,
    days_to_pay, days_to_ship, days_to_deliver, days_to_complete,
    quantity, qty_returned,
    unit_original_price, subtotal_before_disc,
    platform_disc_amount, seller_disc_amount, total_product_disc,
    subtotal_after_disc,
    original_shipping_fee, shipping_platform_disc, shipping_seller_disc,
    shipping_fee_paid,
    payment_platform_disc, buyer_service_fee, handling_fee,
    shipping_insurance, item_insurance,
    voucher_seller, voucher_platform, cashback_coin,
    coin_deduction, credit_card_disc, bundle_disc,
    order_amount, order_refund_amount, net_revenue,
    weight_kg, source_platform
)
select
    to_char(t."Created Time"::timestamp, 'YYYYMMDD')::integer,
    p.product_key,
    l.location_key,
    mk.marketplace_key,
    b.buyer_key,
    w.warehouse_key,
    pr.promo_key,
    t."Order ID",
    'TikTok',
    nullif(t."Tracking ID", ''),
    nullif(t."Package ID", ''),
    nullif(t."Payment Method", ''),
    t."Order Status",
    nullif(t."Cancel By", ''),
    nullif(t."Cancel Reason", ''),
    t."Order Status" = 'Cancelled',
    t."Order Status" = 'Returned',
    t."Order Status" = 'Completed',
    nullif(t."Created Time", '')::timestamp,
    nullif(t."Paid Time", '')::timestamp,
    nullif(t."Shipped Time", '')::timestamp,
    nullif(t."Delivered Time", '')::timestamp,
    nullif(t."Cancelled Time", '')::timestamp,
    nullif(t."Delivered Time", '')::timestamp,
    case when nullif(t."Paid Time",'') is not null
         then (extract(epoch from (t."Paid Time"::timestamp
               - t."Created Time"::timestamp)) / 86400)::smallint end,
    case when nullif(t."Shipped Time",'') is not null
              and nullif(t."Paid Time",'') is not null
         then (extract(epoch from (t."Shipped Time"::timestamp
               - t."Paid Time"::timestamp)) / 86400)::smallint end,
    case when nullif(t."Delivered Time",'') is not null
              and nullif(t."Shipped Time",'') is not null
         then (extract(epoch from (t."Delivered Time"::timestamp
               - t."Shipped Time"::timestamp)) / 86400)::smallint end,
    case when nullif(t."Delivered Time",'') is not null
         then (extract(epoch from (t."Delivered Time"::timestamp
               - t."Created Time"::timestamp)) / 86400)::smallint end,
    t."Quantity"::smallint,
    coalesce(nullif(t."Sku Quantity of return",'')::smallint, 0),
    t."SKU Unit Original Price"::numeric,
    t."SKU Subtotal Before Discount"::numeric,
    coalesce(nullif(t."SKU Platform Discount",'')::numeric, 0),
    coalesce(nullif(t."SKU Seller Discount",'')::numeric, 0),
    coalesce(nullif(t."SKU Platform Discount",'')::numeric, 0)
        + coalesce(nullif(t."SKU Seller Discount",'')::numeric, 0),
    t."SKU Subtotal After Discount"::numeric,
    coalesce(nullif(t."Original Shipping Fee",'')::numeric, 0),
    coalesce(nullif(t."Shipping Fee Platform Discount",'')::numeric, 0),
    coalesce(nullif(t."Shipping Fee Seller Discount",'')::numeric, 0),
    coalesce(nullif(t."Shipping Fee After Discount",'')::numeric, 0),
    coalesce(nullif(t."Payment platform discount",'')::numeric, 0),
    coalesce(nullif(t."Buyer Service Fee",'')::numeric, 0),
    coalesce(nullif(t."Handling Fee",'')::numeric, 0),
    coalesce(nullif(t."Shipping Insurance",'')::numeric, 0),
    coalesce(nullif(t."Item Insurance",'')::numeric, 0),
    0, 0, 0, 0, 0, 0,
    coalesce(nullif(t."Order Amount",'')::numeric, 0),
    coalesce(nullif(t."Order Refund Amount",'')::numeric, 0),
    coalesce(nullif(t."Order Amount",'')::numeric, 0)
        - coalesce(nullif(t."Order Refund Amount",'')::numeric, 0),
    coalesce(nullif(t."Weight(kg)",'')::numeric, 0),
    'TikTok'
from stg_tiktok t
join dim_product p
    on p.sku_id = t."Seller SKU"
join dim_location l
    on l.province     = coalesce(nullif(t."Province",''), 'Unknown')
   and l.regency_city = coalesce(nullif(t."Regency and City",''), 'Unknown')
   and l.district     = coalesce(nullif(t."Districts",''), '')
   and l.village      = coalesce(nullif(t."Villages",''), '')
join dim_marketplace mk
    on mk.platform_name    = 'TikTok'
   and coalesce(mk.purchase_channel,  '') = coalesce(nullif(t."Purchase Channel",''),  '')
   and coalesce(mk.fulfillment_type,  '') = coalesce(nullif(t."Fulfillment Type",''),  '')
   and coalesce(mk.delivery_option,   '') = coalesce(nullif(t."Delivery Option",''),   '')
   and coalesce(mk.shipping_provider, '') = coalesce(nullif(t."Shipping Provider Name",''), '')
join dim_buyer b
    on b.username = t."Buyer Username"
join dim_warehouse w
    on w.warehouse_name = t."Warehouse Name"
join dim_promo_type pr
    on pr.has_platform_disc = (coalesce(nullif(t."SKU Platform Discount",'')::numeric, 0) > 0)
   and pr.has_seller_disc   = (coalesce(nullif(t."SKU Seller Discount",'')::numeric, 0) > 0)
   and pr.has_shipping_disc = (coalesce(nullif(t."Shipping Fee Platform Discount",'')::numeric, 0) > 0)
   and pr.has_voucher       = false
where not exists (
    select 1 from fact_orders fo
    where fo.order_id        = t."Order ID"
      and fo.source_platform = 'TikTok'
);


-- 4B. Shopee
insert into fact_orders (
    date_key, product_key, location_key, marketplace_key,
    buyer_key, warehouse_key, promo_key,
    order_id, platform_name, tracking_id, package_id, payment_method,
    order_status, cancel_by, cancel_reason,
    is_cancelled, is_returned, is_completed,
    created_at, paid_at, shipped_at, delivered_at, cancelled_at, completed_at,
    days_to_pay, days_to_ship, days_to_deliver, days_to_complete,
    quantity, qty_returned,
    unit_original_price, subtotal_before_disc,
    platform_disc_amount, seller_disc_amount, total_product_disc,
    subtotal_after_disc,
    original_shipping_fee, shipping_platform_disc, shipping_seller_disc,
    shipping_fee_paid,
    payment_platform_disc, buyer_service_fee, handling_fee,
    shipping_insurance, item_insurance,
    voucher_seller, voucher_platform, cashback_coin,
    coin_deduction, credit_card_disc, bundle_disc,
    order_amount, order_refund_amount, net_revenue,
    weight_kg, source_platform
)
select
    to_char(s."Waktu Pesanan Dibuat"::timestamp, 'YYYYMMDD')::integer,
    p.product_key,
    l.location_key,
    mk.marketplace_key,
    b.buyer_key,
    w.warehouse_key,
    pr.promo_key,
    s."No. Pesanan",
    'Shopee',
    nullif(s."No. Resi", ''),
    null,
    nullif(s."Metode Pembayaran", ''),
    case s."Status Pesanan"
        when 'Selesai'                  then 'Completed'
        when 'Dibatalkan'               then 'Cancelled'
        when 'Pengembalian Dana/Barang' then 'Returned'
        else s."Status Pesanan"
    end,
    null,
    nullif(s."Alasan Pembatalan", ''),
    s."Status Pesanan" = 'Dibatalkan',
    s."Status Pesanan" = 'Pengembalian Dana/Barang',
    s."Status Pesanan" = 'Selesai',
    nullif(s."Waktu Pesanan Dibuat", '')::timestamp,
    nullif(s."Waktu Pembayaran Dilakukan", '')::timestamp,
    nullif(s."Waktu Pengiriman Diatur", '')::timestamp,
    nullif(s."Waktu Pesanan Selesai", '')::timestamp,
    null,
    nullif(s."Waktu Pesanan Selesai", '')::timestamp,
    case when nullif(s."Waktu Pembayaran Dilakukan",'') is not null
         then (extract(epoch from (s."Waktu Pembayaran Dilakukan"::timestamp
               - s."Waktu Pesanan Dibuat"::timestamp)) / 86400)::smallint end,
    case when nullif(s."Waktu Pengiriman Diatur",'') is not null
              and nullif(s."Waktu Pembayaran Dilakukan",'') is not null
         then (extract(epoch from (s."Waktu Pengiriman Diatur"::timestamp
               - s."Waktu Pembayaran Dilakukan"::timestamp)) / 86400)::smallint end,
    null::smallint,
    case when nullif(s."Waktu Pesanan Selesai",'') is not null
         then (extract(epoch from (s."Waktu Pesanan Selesai"::timestamp
               - s."Waktu Pesanan Dibuat"::timestamp)) / 86400)::smallint end,
    s."Jumlah"::smallint,
    coalesce(nullif(s."Returned quantity",'')::smallint, 0),
    s."Harga Awal"::numeric,
    s."Harga Awal"::numeric * s."Jumlah"::numeric,
    coalesce(nullif(s."Diskon Dari Shopee",'')::numeric, 0),
    coalesce(nullif(s."Diskon Dari Penjual",'')::numeric, 0),
    coalesce(nullif(s."Total Diskon",'')::numeric, 0),
    coalesce(nullif(s."Total Harga Produk",'')::numeric, 0),
    coalesce(nullif(s."Ongkos Kirim Dibayar oleh Pembeli",'')::numeric, 0),
    coalesce(nullif(s."Estimasi Potongan Biaya Pengiriman",'')::numeric, 0),
    0,
    coalesce(nullif(s."Ongkos Kirim Dibayar oleh Pembeli",'')::numeric, 0)
        - coalesce(nullif(s."Estimasi Potongan Biaya Pengiriman",'')::numeric, 0),
    0, 0, 0, 0, 0,
    coalesce(nullif(s."Voucher Ditanggung Penjual",'')::numeric, 0),
    coalesce(nullif(s."Voucher Ditanggung Shopee",'')::numeric, 0),
    coalesce(nullif(s."Cashback Koin",'')::numeric, 0),
    coalesce(nullif(s."Potongan Koin Shopee",'')::numeric, 0),
    coalesce(nullif(s."Diskon Kartu Kredit",'')::numeric, 0),
    coalesce(nullif(s."Paket Diskon",'')::numeric, 0),
    coalesce(nullif(s."Total Pembayaran",'')::numeric, 0),
    coalesce(nullif(s."Ongkos Kirim Pengembalian Barang",'')::numeric, 0),
    coalesce(nullif(s."Total Pembayaran",'')::numeric, 0)
        - coalesce(nullif(s."Ongkos Kirim Pengembalian Barang",'')::numeric, 0),
    coalesce(nullif(s."Total Berat",'')::numeric, 0),
    'Shopee'
from stg_shopee s
join dim_product p
    on p.sku_id = s."SKU Induk"
join dim_location l
    on l.province     = coalesce(s."Provinsi", 'Unknown')
   and l.regency_city = coalesce(s."Kota/Kabupaten", 'Unknown')
   and coalesce(l.district, '') = ''
   and coalesce(l.village, '')  = ''
join dim_marketplace mk
    on mk.platform_name = 'Shopee'
   and coalesce(mk.delivery_option, '') = coalesce(nullif(s."Opsi Pengiriman",''), '')
join dim_buyer b
    on b.username = s."Username (Pembeli)"
join dim_warehouse w
    on w.warehouse_name = s."Nama Gudang"
join dim_promo_type pr
    on pr.has_platform_disc = (coalesce(nullif(s."Diskon Dari Shopee",'')::numeric, 0) > 0)
   and pr.has_seller_disc   = (coalesce(nullif(s."Diskon Dari Penjual",'')::numeric, 0) > 0)
   and pr.has_shipping_disc = (coalesce(nullif(s."Estimasi Potongan Biaya Pengiriman",'')::numeric, 0) > 0)
   and pr.has_voucher = (
       coalesce(nullif(s."Voucher Ditanggung Penjual",'')::numeric, 0)
       + coalesce(nullif(s."Voucher Ditanggung Shopee",'')::numeric, 0) > 0
   )
where not exists (
    select 1 from fact_orders fo
    where fo.order_id        = s."No. Pesanan"
      and fo.source_platform = 'Shopee'
);


-- ============================================================
-- STEP 5: UPDATE dim_buyer
-- ============================================================
-- Hitung ulang total_orders dan buyer_segment berdasarkan
-- seluruh data di fact_orders setelah insert baru.
-- Ini penting agar vw_mkt_promo_buyer selalu menampilkan
-- segmen buyer yang akurat di Dashboard Marketing.
-- ============================================================

update dim_buyer b
set
    first_order_date = sub.first_date,
    total_orders     = sub.cnt,
    is_repeat_buyer  = sub.cnt > 1,
    buyer_segment    = case
                           when sub.cnt = 1             then 'New'
                           when sub.cnt between 2 and 4 then 'Returning'
                           else                              'Loyal'
                       end
from (
    select
        buyer_key,
        min(created_at::date) as first_date,
        count(*)              as cnt
    from fact_orders
    where is_cancelled = false
    group by buyer_key
) sub
where b.buyer_key = sub.buyer_key;


-- ============================================================
-- STEP 6: VALIDASI HASIL REFRESH
-- ============================================================
-- Jalankan setelah semua step selesai untuk memastikan data
-- sudah masuk dengan benar sebelum dashboard dibuka tim.
-- Jika ada anomali, investigasi sebelum memberi akses ke Tableau.
-- ============================================================

-- 6A. Order baru yang masuk hari ini per platform
--     (jika 0 baris, berarti tidak ada data baru atau ETL gagal)
select
    source_platform,
    count(*)              as orders_today,
    sum(order_amount)     as gmv_today,
    max(created_at::date) as latest_date
from fact_orders
where created_at::date = current_date
group by source_platform;


-- 6B. Akumulasi total fact_orders — untuk memantau pertumbuhan data
select
    source_platform,
    count(*)              as total_orders_all,
    sum(order_amount)     as total_gmv_all,
    min(created_at::date) as data_start,
    max(created_at::date) as data_end
from fact_orders
group by source_platform;


-- 6C. Cek duplikasi order_id — harus kosong (0 baris)
--     Jika ada hasil, berarti WHERE NOT EXISTS tidak bekerja
--     dan perlu investigasi sebelum dashboard diakses
select
    source_platform,
    order_id,
    count(*) as jumlah
from fact_orders
group by source_platform, order_id
having count(*) > 1
order by jumlah desc
limit 20;


-- 6D. Cek null pada foreign key — semua harus 0
--     Null di sini berarti ada data staging yang tidak match
--     dengan dimensi yang sudah ada
select
    sum(case when date_key        is null then 1 else 0 end) as null_date,
    sum(case when product_key     is null then 1 else 0 end) as null_product,
    sum(case when location_key    is null then 1 else 0 end) as null_location,
    sum(case when marketplace_key is null then 1 else 0 end) as null_marketplace,
    sum(case when buyer_key       is null then 1 else 0 end) as null_buyer,
    sum(case when warehouse_key   is null then 1 else 0 end) as null_warehouse
from fact_orders;


-- 6E. Spot check buyer segment — distribusi harus masuk akal
--     Jika Loyal tiba-tiba 0, berarti update dim_buyer di step 5 gagal
select
    buyer_segment,
    count(*) as buyer_count
from dim_buyer
group by buyer_segment
order by buyer_count desc;


-- ============================================================
-- SELESAI — pipeline harian Gendes Marketplace Analytics
-- Urutan eksekusi lengkap proyek:
--   01_schema_and_dimensions.sql  → setup awal (sekali)
--   02_fact_table.sql             → load data historis (sekali)
--   03_index.sql                  → optimasi performa (sekali)
--   04_views.sql                  → data source Tableau (sekali, update jika ada perubahan metrik)
--   05_scheduled_etl.sql          → refresh harian (dijalankan rutin setiap hari)
-- ============================================================
