-- ============================================================
--  GENDES FEMININE HYGIENE — STAR SCHEMA DATABASE
--  PostgreSQL | Gendes Marketplace Sales Analysis
-- ============================================================
--  FILE: 02_fact_table.sql
--  ISI : DDL fact_orders, insert dari TikTok & Shopee staging,
--        update dim_buyer, validasi data
-- ============================================================

set search_path to gendes, public;


-- ============================================================
-- STEP 1: DDL FACT TABLE
-- ============================================================

drop table if exists fact_orders cascade;

create table fact_orders (
    order_key               bigserial     primary key,
    -- foreign keys
    date_key                integer       not null references dim_date(date_key),
    product_key             integer       not null references dim_product(product_key),
    location_key            integer       not null references dim_location(location_key),
    marketplace_key         integer       not null references dim_marketplace(marketplace_key),
    buyer_key               integer       not null references dim_buyer(buyer_key),
    warehouse_key           integer       not null references dim_warehouse(warehouse_key),
    promo_key               integer       not null references dim_promo_type(promo_key),
    -- identitas order
    order_id                varchar(30)   not null,
    platform_name           varchar(20)   not null,
    tracking_id             varchar(30),
    package_id              varchar(30),
    payment_method          varchar(30),
    -- status
    order_status            varchar(30)   not null,
    cancel_by               varchar(20),
    cancel_reason           varchar(120),
    is_cancelled            boolean       not null default false,
    is_returned             boolean       not null default false,
    is_completed            boolean       not null default false,
    -- timestamps
    created_at              timestamp     not null,
    paid_at                 timestamp,
    shipped_at              timestamp,
    delivered_at            timestamp,
    cancelled_at            timestamp,
    completed_at            timestamp,
    -- waktu turunan (hari)
    days_to_pay             smallint,
    days_to_ship            smallint,
    days_to_deliver         smallint,
    days_to_complete        smallint,
    -- measures: volume
    quantity                smallint      not null,
    qty_returned            smallint      not null default 0,
    -- measures: harga & diskon produk
    unit_original_price     numeric(12,2) not null,
    subtotal_before_disc    numeric(14,2) not null,
    platform_disc_amount    numeric(12,2) not null default 0,
    seller_disc_amount      numeric(12,2) not null default 0,
    total_product_disc      numeric(12,2) not null default 0,
    subtotal_after_disc     numeric(14,2) not null,
    -- measures: ongkir
    original_shipping_fee   numeric(10,2) not null default 0,
    shipping_platform_disc  numeric(10,2) not null default 0,
    shipping_seller_disc    numeric(10,2) not null default 0,
    shipping_fee_paid       numeric(10,2) not null default 0,
    -- measures: biaya lain (TikTok)
    payment_platform_disc   numeric(10,2) not null default 0,
    buyer_service_fee       numeric(10,2) not null default 0,
    handling_fee            numeric(10,2) not null default 0,
    shipping_insurance      numeric(10,2) not null default 0,
    item_insurance          numeric(10,2) not null default 0,
    -- measures: shopee-specific
    voucher_seller          numeric(10,2) not null default 0,
    voucher_platform        numeric(10,2) not null default 0,
    cashback_coin           numeric(10,2) not null default 0,
    coin_deduction          numeric(10,2) not null default 0,
    credit_card_disc        numeric(10,2) not null default 0,
    bundle_disc             numeric(10,2) not null default 0,
    -- measures: total
    order_amount            numeric(14,2) not null,
    order_refund_amount     numeric(14,2) not null default 0,
    net_revenue             numeric(14,2) not null,
    -- logistik
    weight_kg               numeric(8,3),
    source_platform         varchar(20)   not null
);



-- ============================================================
-- STEP 2: INSERT DARI TIKTOK STAGING
-- ============================================================

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
    case when nullif(t."Cancelled Time", '') is not null
     then to_timestamp(nullif(t."Cancelled Time", '')::double precision)
     end,
    nullif(t."Delivered Time", '')::timestamp,
    -- days (extract epoch menghindari error cast interval ke smallint)
    case when nullif(t."Paid Time",'') is not null
         then (extract(epoch from (nullif(t."Paid Time",'')::timestamp - t."Created Time"::timestamp)) / 86400)::smallint
         else null end,
    case when nullif(t."Shipped Time",'') is not null and nullif(t."Paid Time",'') is not null
         then (extract(epoch from (t."Shipped Time"::timestamp - t."Paid Time"::timestamp)) / 86400)::smallint
         else null end,
    case when nullif(t."Delivered Time",'') is not null and nullif(t."Shipped Time",'') is not null
         then (extract(epoch from (t."Delivered Time"::timestamp - t."Shipped Time"::timestamp)) / 86400)::smallint
         else null end,
    case when nullif(t."Delivered Time",'') is not null
         then (extract(epoch from (t."Delivered Time"::timestamp - t."Created Time"::timestamp)) / 86400)::smallint
         else null end,
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
    0, 0, 0, 0, 0, 0,   -- shopee-specific = 0 untuk TikTok
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
    on l.province     = coalesce(t."Province", 'Unknown')
   and l.regency_city = coalesce(t."Regency and City", 'Unknown')
   and coalesce(l.district, '') = coalesce(nullif(t."Districts",''), '')
   and coalesce(l.village, '')  = coalesce(nullif(t."Villages",''), '')
join dim_marketplace mk
    on mk.platform_name      = 'TikTok'
   and coalesce(mk.purchase_channel, '')  = coalesce(nullif(t."Purchase Channel",''), '')
   and coalesce(mk.fulfillment_type, '')  = coalesce(nullif(t."Fulfillment Type",''), '')
   and coalesce(mk.delivery_option, '')   = coalesce(nullif(t."Delivery Option",''), '')
   and coalesce(mk.shipping_provider, '') = coalesce(nullif(t."Shipping Provider Name",''), '')
join dim_buyer b
    on b.username = t."Buyer Username"
join dim_warehouse w
    on w.warehouse_name = t."Warehouse Name"
join dim_promo_type pr
    on pr.has_platform_disc = (coalesce(nullif(t."SKU Platform Discount",'')::numeric, 0) > 0)
   and pr.has_seller_disc   = (coalesce(nullif(t."SKU Seller Discount",'')::numeric, 0) > 0)
   and pr.has_shipping_disc = (coalesce(nullif(t."Shipping Fee Platform Discount",'')::numeric, 0) > 0)
   and pr.has_voucher       = false;


-- ============================================================
-- STEP 3: INSERT DARI SHOPEE STAGING
-- ============================================================

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
         then (extract(epoch from (s."Waktu Pembayaran Dilakukan"::timestamp - s."Waktu Pesanan Dibuat"::timestamp)) / 86400)::smallint
         else null end,
    case when nullif(s."Waktu Pengiriman Diatur",'') is not null
              and nullif(s."Waktu Pembayaran Dilakukan",'') is not null
         then (extract(epoch from (s."Waktu Pengiriman Diatur"::timestamp - s."Waktu Pembayaran Dilakukan"::timestamp)) / 86400)::smallint
         else null end,
    null::smallint,
    case when nullif(s."Waktu Pesanan Selesai",'') is not null
         then (extract(epoch from (s."Waktu Pesanan Selesai"::timestamp - s."Waktu Pesanan Dibuat"::timestamp)) / 86400)::smallint
         else null end,
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
   );


-- ============================================================
-- STEP 4: UPDATE dim_buyer
-- ============================================================

update dim_buyer b
set
    first_order_date = sub.first_date,
    total_orders     = sub.cnt,
    is_repeat_buyer  = sub.cnt > 1,
    buyer_segment    = case
                           when sub.cnt = 1              then 'New'
                           when sub.cnt between 2 and 4  then 'Returning'
                           else 'Loyal'
                       end
from (
    select buyer_key,
           min(created_at::date) as first_date,
           count(*)              as cnt
    from fact_orders
    group by buyer_key
) sub
where b.buyer_key = sub.buyer_key;


-- ============================================================
-- STEP 5: VALIDASI DATA
-- ============================================================

-- 5A. Jumlah baris per platform
select source_platform, count(*) as total_orders
from fact_orders
group by source_platform;


-- 5B. Distribusi status per platform
select source_platform, order_status, count(*) as cnt,
       round(count(*) * 100.0 / sum(count(*)) over (partition by source_platform), 1) as pct
from fact_orders
group by source_platform, order_status
order by source_platform, cnt desc;

-- 5C. FK integrity — semua harus 0
select
    sum(case when date_key        is null then 1 else 0 end) as null_date,
    sum(case when product_key     is null then 1 else 0 end) as null_product,
    sum(case when location_key    is null then 1 else 0 end) as null_location,
    sum(case when marketplace_key is null then 1 else 0 end) as null_marketplace,
    sum(case when buyer_key       is null then 1 else 0 end) as null_buyer,
    sum(case when warehouse_key   is null then 1 else 0 end) as null_warehouse
from fact_orders;

-- 5D. Rentang tanggal
select
    min(created_at)::date as earliest_order,
    max(created_at)::date as latest_order,
    count(distinct to_char(created_at, 'YYYY-MM')) as months_covered
from fact_orders;

-- 5E. Total GMV per platform
select
    source_platform,
    to_char(sum(order_amount), 'FM999,999,999,999') as total_gmv,
    to_char(sum(net_revenue),  'FM999,999,999,999') as total_net_revenue,
    round(avg(order_amount), 0)                      as avg_order_value
from fact_orders
where is_cancelled = false
group by source_platform;

select sum(order_amount)
from fact_orders;