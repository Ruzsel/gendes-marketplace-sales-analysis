-- ============================================================
--  GENDES FEMININE HYGIENE — STAR SCHEMA DATABASE
--  PostgreSQL | Gendes Marketplace Sales Analysis
--  Platform: TikTok Shop + Shopee |
-- ============================================================
--  FILE: 01_schema_and_dimensions.sql
--  ISI : Schema, tabel dimensi, staging table,
--        populate semua dimensi
-- ============================================================

-- ============================================================
-- STEP 1: SCHEMA 
-- ============================================================

create schema if not exists gendes;
set search_path to gendes, public;

-- ============================================================
-- STEP 2: TABEL DIMENSI
-- ============================================================

-- 2A. dim_date
drop table if exists dim_date cascade;
create table dim_date (
    date_key        integer primary key,
    full_date       date        not null,
    year            smallint    not null,
    quarter         smallint    not null,
    month           smallint    not null,
    month_name      varchar(15) not null,
    month_abbr      varchar(5)  not null,
    week_of_year    smallint    not null,
    day_of_month    smallint    not null,
    day_of_week     smallint    not null,
    day_name        varchar(15) not null,
    is_weekend      boolean     not null,
    is_payday       boolean     not null,
    semester        smallint    not null,
    year_month      varchar(7)  not null,
    year_quarter    varchar(7)  not null
);


-- 2B. dim_product
drop table if exists dim_product cascade;
create table dim_product (
    product_key      serial        primary key,
    sku_id           varchar(20)   not null unique,
    seller_sku       varchar(20),
    product_name     varchar(120)  not null,
    variation        varchar(60),
    product_type     varchar(10)   not null,
    size_ml          smallint,
    is_bundle        boolean       not null default false,
    price_tier       varchar(10)   not null,
    base_price       numeric(12,2) not null,
    weight_kg        numeric(6,3),
    product_category varchar(40)   not null default 'Feminine Hygiene',
    is_active        boolean       not null default true
);


-- 2C. dim_location
drop table if exists dim_location cascade;
create table dim_location (
    location_key    serial      primary key,
    province        varchar(60) not null,
    regency_city    varchar(60) not null,
    district        varchar(60),
    village         varchar(60),
    zipcode         varchar(10),
    island_group    varchar(20) not null,
    region_group    varchar(20) not null,
    unique (province, regency_city, district, village)
);


-- 2D. dim_marketplace
drop table if exists dim_marketplace cascade;
create table dim_marketplace (
    marketplace_key  serial      primary key,
    platform_name    varchar(20) not null,
    purchase_channel varchar(30),
    fulfillment_type varchar(30),
    delivery_option  varchar(20),
    shipping_provider varchar(40),
    unique (platform_name, purchase_channel, fulfillment_type, delivery_option, shipping_provider)
);


-- 2E. dim_buyer
drop table if exists dim_buyer cascade;
create table dim_buyer (
    buyer_key        serial      primary key,
    username         varchar(80) not null unique,
    platform_name    varchar(20) not null,
    recipient_name   varchar(120),
    phone_masked     varchar(15),
    first_order_date date,
    total_orders     integer     default 0,
    is_repeat_buyer  boolean     default false,
    buyer_segment    varchar(20) default 'New'
);


-- 2F. dim_warehouse
drop table if exists dim_warehouse cascade;
create table dim_warehouse (
    warehouse_key   serial      primary key,
    warehouse_name  varchar(80) not null unique,
    city            varchar(60),
    province        varchar(60),
    island_group    varchar(20),
    is_active       boolean     not null default true
);


-- 2G. dim_promo_type
drop table if exists dim_promo_type cascade;
create table dim_promo_type (
    promo_key         serial      primary key,
    has_platform_disc boolean     not null default false,
    has_seller_disc   boolean     not null default false,
    has_shipping_disc boolean     not null default false,
    has_voucher       boolean     not null default false,
    promo_label       varchar(60) not null,
    unique (has_platform_disc, has_seller_disc, has_shipping_disc, has_voucher)
);


-- ============================================================
-- STEP 3: TABEL STAGING
-- ============================================================

drop table if exists stg_tiktok cascade;
create table stg_tiktok (
    "Order ID"                          varchar(30),
    "Order Status"                      varchar(30),
    "Order Substatus"                   varchar(50),
    "Cancelation/Return Type"           varchar(30),
    "Normal or Pre-order"               varchar(20),
    "SKU ID"                            varchar(20),
    "Seller SKU"                        varchar(20),
    "Product Name"                      varchar(120),
    "Variation"                         varchar(60),
    "Quantity"                          varchar(10),
    "Sku Quantity of return"            varchar(10),
    "SKU Unit Original Price"           varchar(20),
    "SKU Subtotal Before Discount"      varchar(20),
    "SKU Platform Discount"             varchar(20),
    "SKU Seller Discount"               varchar(20),
    "SKU Subtotal After Discount"       varchar(20),
    "Shipping Fee After Discount"       varchar(20),
    "Original Shipping Fee"             varchar(20),
    "Shipping Fee Seller Discount"      varchar(20),
    "Shipping Fee Platform Discount"    varchar(20),
    "Payment platform discount"         varchar(20),
    "Buyer Service Fee"                 varchar(20),
    "Handling Fee"                      varchar(20),
    "Shipping Insurance"                varchar(20),
    "Item Insurance"                    varchar(20),
    "Order Amount"                      varchar(20),
    "Order Refund Amount"               varchar(20),
    "Created Time"                      varchar(30),
    "Paid Time"                         varchar(30),
    "RTS Time"                          varchar(30),
    "Shipped Time"                      varchar(30),
    "Delivered Time"                    varchar(30),
    "Cancelled Time"                    varchar(30),
    "Cancel By"                         varchar(20),
    "Cancel Reason"                     varchar(120),
    "Fulfillment Type"                  varchar(40),
    "Warehouse Name"                    varchar(80),
    "Tracking ID"                       varchar(30),
    "Delivery Option"                   varchar(20),
    "Shipping Provider Name"            varchar(40),
    "Buyer Message"                     varchar(200),
    "Buyer Username"                    varchar(80),
    "Recipient"                         varchar(120),
    "Phone #"                           varchar(20),
    "Zipcode"                           varchar(10),
    "Country"                           varchar(20),
    "Province"                          varchar(60),
    "Regency and City"                  varchar(60),
    "Districts"                         varchar(60),
    "Villages"                          varchar(60),
    "Detail Address"                    varchar(200),
    "Additional address information"    varchar(200),
    "Payment Method"                    varchar(30),
    "Weight(kg)"                        varchar(30),
    "Product Category"                  varchar(40),
    "Package ID"                        varchar(30),
    "Purchase Channel"                  varchar(30),
    "Seller Note"                       varchar(100),
    "Checked Status"                    varchar(20),
    "Checked Marked by"                 varchar(40)
);

drop table if exists stg_shopee cascade;
create table stg_shopee (
    "No. Pesanan"                                                   varchar(30),
    "Status Pesanan"                                                varchar(30),
    "Alasan Pembatalan"                                             varchar(120),
    "Status Pembatalan/ Pengembalian"                               varchar(30),
    "No. Resi"                                                      varchar(30),
    "Opsi Pengiriman"                                               varchar(20),
    "Antar ke counter/ pick-up"                                     varchar(30),
    "Pesanan Harus Dikirimkan Sebelum (Menghindari keterlambatan)"  varchar(30),
    "Waktu Pengiriman Diatur"                                       varchar(30),
    "Waktu Pesanan Dibuat"                                          varchar(30),
    "Waktu Pembayaran Dilakukan"                                    varchar(30),
    "Metode Pembayaran"                                             varchar(30),
    "SKU Induk"                                                     varchar(20),
    "Nama Produk"                                                   varchar(120),
    "Nomor Referensi SKU"                                           varchar(20),
    "Nama Variasi"                                                  varchar(60),
    "Harga Awal"                                                    varchar(20),
    "Harga Setelah Diskon"                                          varchar(20),
    "Jumlah"                                                        varchar(10),
    "Returned quantity"                                             varchar(10),
    "Total Harga Produk"                                            varchar(20),
    "Total Diskon"                                                  varchar(20),
    "Diskon Dari Penjual"                                           varchar(20),
    "Diskon Dari Shopee"                                            varchar(20),
    "Berat Produk"                                                  varchar(10),
    "Jumlah Produk di Pesan"                                        varchar(10),
    "Total Berat"                                                   varchar(10),
    "Nama Gudang"                                                   varchar(80),
    "Voucher Ditanggung Penjual"                                    varchar(20),
    "Cashback Koin"                                                 varchar(20),
    "Voucher Ditanggung Shopee"                                     varchar(20),
    "Paket Diskon"                                                  varchar(20),
    "Paket Diskon (Diskon dari Shopee)"                             varchar(20),
    "Paket Diskon (Diskon dari Penjual)"                            varchar(20),
    "Potongan Koin Shopee"                                          varchar(20),
    "Diskon Kartu Kredit"                                           varchar(20),
    "Ongkos Kirim Dibayar oleh Pembeli"                             varchar(20),
    "Estimasi Potongan Biaya Pengiriman"                            varchar(20),
    "Ongkos Kirim Pengembalian Barang"                              varchar(20),
    "Total Pembayaran"                                              varchar(20),
    "Perkiraan Ongkos Kirim"                                        varchar(20),
    "Catatan dari Pembeli"                                          varchar(200),
    "Catatan"                                                       varchar(100),
    "Username (Pembeli)"                                            varchar(80),
    "Nama Penerima"                                                 varchar(120),
    "No. Telepon"                                                   varchar(20),
    "Alamat Pengiriman"                                             varchar(200),
    "Kota/Kabupaten"                                                varchar(60),
    "Provinsi"                                                      varchar(60),
    "Waktu Pesanan Selesai"                                         varchar(30)
);


-- ============================================================
-- STEP 4: LOAD CSV KE STAGING
-- ============================================================

copy gendes.stg_tiktok
from 'D:\\Data Project\\gendes_hygiene\\tiktok_gendes_2023_2025.csv'
delimiter ',' csv header encoding 'UTF-8';

copy gendes.stg_shopee
from 'D:\\Data Project\\gendes_hygiene\\shopee_gendes_2023_2025.csv'
delimiter ',' csv header encoding 'UTF-8';

-- Verifikasi
select count(*) from stg_tiktok;
select count(*) from stg_shopee;

-- ============================================================
-- STEP 5: POPULATE dim_date
-- ============================================================

insert into dim_date (
    date_key, full_date, year, quarter, month, month_name, month_abbr,
    week_of_year, day_of_month, day_of_week, day_name,
    is_weekend, is_payday, semester, year_month, year_quarter
)
select
    to_char(d, 'YYYYMMDD')::integer,
    d,
    extract(year   from d)::smallint,
    extract(quarter from d)::smallint,
    extract(month  from d)::smallint,
    to_char(d, 'Month'),
    to_char(d, 'Mon'),
    extract(week   from d)::smallint,
    extract(day    from d)::smallint,
    extract(dow    from d)::smallint,
    to_char(d, 'Day'),
    extract(dow from d) in (0, 6),
    extract(day from d) >= 25 or extract(day from d) <= 5,
    case when extract(month from d) <= 6 then 1 else 2 end::smallint,
    to_char(d, 'YYYY-MM'),
    to_char(d, 'YYYY') || '-Q' || extract(quarter from d)::text
from generate_series('2023-01-01'::date, '2025-12-31'::date, '1 day'::interval) as g(d)
on conflict (date_key) do nothing;


-- ============================================================
-- STEP 6: POPULATE DIMENSI DARI STAGING
-- ============================================================

-- 6A. dim_product
insert into dim_product (
    sku_id, seller_sku, product_name, variation,
    product_type, size_ml, is_bundle, price_tier, base_price,
    weight_kg, product_category
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
        when s.variation like '%20ml%'  then 20
        when s.variation like '%60ml%'  then 60
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
    select "SKU ID" as sku_id, "Seller SKU" as seller_sku,
           "Product Name" as product_name, "Variation" as variation,
           "SKU Unit Original Price"::numeric as unit_price,
           "Weight(kg)" as weight_kg
    from stg_tiktok
    where "SKU ID" is not null
    union all
    select "SKU Induk", "Nomor Referensi SKU",
           "Nama Produk", "Nama Variasi",
           "Harga Awal"::numeric, "Berat Produk"
    from stg_shopee
    where "SKU Induk" is not null
) s
order by s.sku_id, s.unit_price desc
on conflict (sku_id) do nothing;


-- 6B. dim_location
insert into dim_location (
    province, regency_city, district, village, zipcode, island_group, region_group
)
select distinct
    coalesce(province, 'Unknown'),
    coalesce(regency_city, 'Unknown'),
    nullif(district, ''),
    nullif(village, ''),
    nullif(zipcode, ''),
    case
        when province in ('DKI Jakarta','Jawa Barat','Jawa Tengah','Jawa Timur','Banten','Yogyakarta')
            then 'Jawa'
        when province in ('Sumatera Utara','Sumatera Barat','Sumatera Selatan','Riau',
                          'Kepulauan Riau','Jambi','Bengkulu','Lampung','Bangka Belitung','Aceh')
            then 'Sumatera'
        when province in ('Kalimantan Timur','Kalimantan Selatan','Kalimantan Tengah',
                          'Kalimantan Barat','Kalimantan Utara')
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
        when province = 'Jawa Barat' and regency_city in ('Bekasi','Depok','Bogor')
            then 'Jabodetabek'
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


-- 6C. dim_marketplace
insert into dim_marketplace (
    platform_name, purchase_channel, fulfillment_type, delivery_option, shipping_provider
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
on conflict (platform_name, purchase_channel, fulfillment_type, delivery_option, shipping_provider)
do nothing;


-- 6D. dim_warehouse
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


-- 6E. dim_buyer
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


-- 6F. dim_promo_type — generate semua 16 kombinasi
insert into dim_promo_type (
    has_platform_disc, has_seller_disc, has_shipping_disc, has_voucher, promo_label
)
select
    p.v, s.v, sh.v, vou.v,
    coalesce(
        nullif(trim(
            case when p.v   then 'Platform '  else '' end ||
            case when s.v   then 'Seller '    else '' end ||
            case when sh.v  then 'Shipping '  else '' end ||
            case when vou.v then 'Voucher'     else '' end
        ), ''),
        'No Promo'
    )
from (values (true),(false)) as p(v),
     (values (true),(false)) as s(v),
     (values (true),(false)) as sh(v),
     (values (true),(false)) as vou(v)
on conflict (has_platform_disc, has_seller_disc, has_shipping_disc, has_voucher) do nothing;


-- ============================================================
-- VALIDASI DIMENSI
-- ============================================================
select count(*) as dim_date_rows      from dim_date;        
select count(*) as dim_product_rows   from dim_product;     
select count(*) as dim_location_rows  from dim_location;
select count(*) as dim_promo_rows     from dim_promo_type;  
select count(*) as dim_buyer_rows     from dim_buyer;
