-- ============================================================
--  GENDES FEMININE HYGIENE — STAR SCHEMA DATABASE
--  PostgreSQL | Gendes Marketplace Sales Analysis
--  Platform  : TikTok Shop + Shopee | 
-- ============================================================
--  FILE     : 04_views.sql
--  PERAN    : Data preparation layer — setiap view dibangun
--             dari satu masalah bisnis nyata per divisi.
--             View di-connect langsung ke Power BI sebagai
--             data source sehingga dashboard selalu live.
--
--  MASALAH BISNIS & VIEW YANG MENJAWABNYA:
--
--  [EXECUTIVE]
--  Masalah : Bisnis sudah 3 tahun berjalan di dua platform.
--            Leadership belum punya satu tempat untuk melihat
--            apakah revenue benar-benar tumbuh, dari mana
--            pertumbuhannya, dan apakah kualitas order ikut
--            membaik seiring skala bisnis.
--  View    : vw_exec_growth_health
--
--  [MARKETING]
--  Masalah : Tim marketing rutin jalankan flash sale, TikTok
--            Live, dan campaign payday — tapi tidak tahu diskon
--            seberapa besar yang benar-benar menghasilkan order
--            selesai
--  View    : vw_mkt_promo_buyer
--
--  [BRAND]
--  Masalah : Brand manager belum tahu secara data SKU mana
--            yang harus dipush, flavor mana yang tumbuh,
--            size mana yang diminati per wilayah, dan apakah
--            bundle berhasil meningkatkan nilai transaksi atau
--            tidak relevan untuk sebagian besar buyer.
--  View    : vw_brand_sku_flavor
--
--  JALANKAN SETELAH: 03_index.sql
-- ============================================================

set search_path to gendes, public;


-- ============================================================
-- VIEW 1: vw_exec_growth_health
-- Divisi   : Executive
-- ============================================================
-- Power Bi  : Data source untuk Dashboard Executive.
--            Satu view ini cukup untuk semua sheet di dashboard
--            karena mencakup dimensi waktu, platform, lokasi,
--            dan semua KPI kualitas order sekaligus.
-- ============================================================

create or replace view vw_exec_growth_health as
select
    -- dimensi waktu
    d.full_date,
    d.year,
    d.quarter,
    d.month,
    d.month_name,
    d.year_month,
    d.year_quarter,
    d.is_payday,
    d.is_weekend,
    -- dimensi platform
    f.source_platform,
    -- dimensi lokasi
    l.province,
    l.island_group,
    l.region_group,
    -- measures: volume & revenue
    count(*)                                        as total_orders,
    sum(f.quantity)                                 as total_units,
    sum(f.order_amount)                             as gmv,
    sum(f.net_revenue)                              as net_revenue,
    sum(f.total_product_disc)                       as total_discount,
    sum(f.order_refund_amount)                      as total_refund,
    -- measures: kualitas order
    sum(case when f.is_completed then 1 else 0 end) as completed_orders,
    sum(case when f.is_cancelled then 1 else 0 end) as cancelled_orders,
    sum(case when f.is_returned  then 1 else 0 end) as returned_orders,
    -- measures: efisiensi
    round(avg(f.order_amount), 0)                   as avg_order_value,
    round(avg(f.days_to_deliver), 1)                as avg_days_to_deliver,
    -- measures: jangkauan buyer
    count(distinct f.buyer_key)                     as unique_buyers
from fact_orders f
join dim_date     d on d.date_key     = f.date_key
join dim_location l on l.location_key = f.location_key
group by
    d.full_date, d.year, d.quarter, d.month, d.month_name,
    d.year_month, d.year_quarter, d.is_payday, d.is_weekend,
    f.source_platform,
    l.province, l.island_group, l.region_group;


-- ============================================================
-- VIEW 2: vw_mkt_promo_buyer
-- Divisi   : Marketing
-- ============================================================
-- Power Bi  : Data source untuk Dashboard Marketing.
--            Semua dimensi promo, channel, waktu, dan buyer
--            digabung agar analyst bisa slice-and-dice tanpa
--            harus join manual di Power BI.
-- ============================================================

create or replace view vw_mkt_promo_buyer as
with first_orders as (
    select
        buyer_key,
        min(date_key) as first_date_key
    from fact_orders f
    group by buyer_key
)
select
    -- dimensi waktu
    d.full_date,
    d.year,
    d.month,
    d.year_month,
    d.day_name,
    d.day_of_week,
    d.is_payday,
    extract(hour from f.created_at)::smallint       as order_hour,
    -- dimensi platform & channel
    f.source_platform,
    mk.purchase_channel,
    -- dimensi buyer
    b.buyer_segment,
    case
        when fo.first_date_key = f.date_key then 'New'
        else                                     'Repeat'
    end                                             as buyer_type,
    -- dimensi promo: bucket diskon
    case
        when f.subtotal_before_disc = 0
          or round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) = 0   then 'No Disc'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 5  then '01 | 1-5%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 10 then '02 | 6-10%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 15 then '03 | 11-15%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 20 then '04 | 16-20%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 25 then '05 | 21-25%'
        else                                                 '06 | >25%'
    end                                             as disc_bucket,
    pr.has_platform_disc,
    pr.has_seller_disc,
    pr.has_voucher,
    -- measures: volume & revenue
    count(*)                                        as total_orders,
    sum(f.quantity)                                 as total_units,
    sum(f.order_amount)                             as gmv,
    sum(f.net_revenue)                              as net_revenue,
    sum(f.total_product_disc)                       as total_discount,
    -- measures: kualitas order
    sum(case when f.is_completed then 1 else 0 end) as completed_orders,
    sum(case when f.is_cancelled then 1 else 0 end) as cancelled_orders,
    -- measures: nilai per transaksi
    round(avg(f.order_amount), 0)                   as avg_order_value,
    round(avg(f.quantity), 2)                       as avg_qty_per_order,
    -- measures: jangkauan buyer
    count(distinct f.buyer_key)                     as unique_buyers
from fact_orders f
join dim_date        d  on d.date_key        = f.date_key
join dim_marketplace mk on mk.marketplace_key = f.marketplace_key
join dim_buyer       b  on b.buyer_key       = f.buyer_key
join dim_promo_type  pr on pr.promo_key      = f.promo_key
join first_orders    fo on fo.buyer_key      = f.buyer_key
group by
    d.full_date, d.year, d.month, d.year_month,
    d.day_name, d.day_of_week, d.is_payday,
    extract(hour from f.created_at)::smallint,
    f.source_platform,
    mk.purchase_channel,
    b.buyer_segment,
    case
        when fo.first_date_key = f.date_key then 'New'
        else                                     'Repeat'
    end,
    case
        when f.subtotal_before_disc = 0
          or round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) = 0   then 'No Disc'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 5  then '01 | 1-5%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 10 then '02 | 6-10%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 15 then '03 | 11-15%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 20 then '04 | 16-20%'
        when round(f.total_product_disc * 100.0
             / nullif(f.subtotal_before_disc, 0)) <= 25 then '05 | 21-25%'
        else                                                 '06 | >25%'
    end,
    pr.has_platform_disc, pr.has_seller_disc, pr.has_voucher;


-- ============================================================
-- VIEW 3: vw_brand_sku_flavor
-- Divisi   : Brand
-- ============================================================
-- Power Bi  : Data source untuk Dashboard Brand.
--            Semua dimensi produk, lokasi, dan waktu digabung
--            agar brand manager bisa eksplorasi performa SKU
--            dari berbagai sudut tanpa query tambahan.
-- ============================================================

create or replace view vw_brand_sku_flavor as
select
    -- dimensi waktu
	d.full_date,
    d.year,
    d.year_month,
    d.year_quarter,
    -- dimensi platform
    f.source_platform,
    -- dimensi produk
    p.sku_id,
    p.product_name,
    p.product_type,
    p.size_ml,
    p.price_tier,
    p.is_bundle,
    case
        when p.sku_id = 'GDS-BDL-SS-60' then 'Spray + Spray'
        when p.sku_id = 'GDS-BDL-FF-60' then 'Foam + Foam'
        when p.sku_id = 'GDS-BDL-FS-60' then 'Foam + Spray'
        when p.product_type = 'Spray'   then 'Spray Satuan'
        when p.product_type = 'Foam'    then 'Foam Satuan'
        else                                 'Other'
    end                                             as product_subtype,
    case
        when p.product_name like '%Vanilla%'   then 'Vanilla'
        when p.product_name like '%Bubblegum%' then 'Bubblegum'
        when p.product_name like '%Hazelnut%'  then 'Hazelnut'
        when p.product_name like '%Mango%'     then 'Mango'
        when p.product_name like '%Grape%'     then 'Grape'
        else                                        'Mixed (Bundle)'
    end                                             as flavor,
    -- dimensi lokasi
    l.island_group,
    l.province,
    -- measures: volume & revenue
    count(*)                                        as total_orders,
    sum(f.quantity)                                 as units_sold,
    sum(f.order_amount)                             as gmv,
    sum(f.net_revenue)                              as net_revenue,
    sum(f.order_refund_amount)                      as total_refund,
    -- measures: harga & diskon
    round(avg(f.order_amount), 0)                   as aov,
    round(avg(
        f.total_product_disc * 100.0
        / nullif(f.subtotal_before_disc, 0)
    ), 1)                                           as avg_disc_pct,
    -- measures: kualitas produk
    sum(case when f.is_completed then 1 else 0 end) as completed_orders,
    sum(case when f.is_returned  then 1 else 0 end) as returned_orders
from fact_orders f
join dim_product  p on p.product_key  = f.product_key
join dim_date     d on d.date_key     = f.date_key
join dim_location l on l.location_key = f.location_key
where f.is_cancelled = false
group by
    d.full_date,d.year, d.year_month, d.year_quarter,
    f.source_platform,
    p.sku_id, p.product_name, p.product_type,
    p.size_ml, p.price_tier, p.is_bundle,
    case
        when p.sku_id = 'GDS-BDL-SS-60' then 'Spray + Spray'
        when p.sku_id = 'GDS-BDL-FF-60' then 'Foam + Foam'
        when p.sku_id = 'GDS-BDL-FS-60' then 'Foam + Spray'
        when p.product_type = 'Spray'   then 'Spray Satuan'
        when p.product_type = 'Foam'    then 'Foam Satuan'
        else                                 'Other'
    end,
    case
        when p.product_name like '%Vanilla%'   then 'Vanilla'
        when p.product_name like '%Bubblegum%' then 'Bubblegum'
        when p.product_name like '%Hazelnut%'  then 'Hazelnut'
        when p.product_name like '%Mango%'     then 'Mango'
        when p.product_name like '%Grape%'     then 'Grape'
        else                                        'Mixed (Bundle)'
    end,
    l.island_group, l.province;


-- ============================================================
-- VERIFIKASI VIEWS
-- ============================================================

select 'vw_exec_growth_health' as view_name, count(*) as rows from vw_exec_growth_health
union all
select 'vw_mkt_promo_buyer'    as view_name, count(*) as rows from vw_mkt_promo_buyer
union all
select 'vw_brand_sku_flavor'   as view_name, count(*) as rows from vw_brand_sku_flavor;

select 'gmv_exe' as view_name, sum(gmv)
from vw_exec_growth_health
union all
select 'gmv_brand' as view_name, sum(gmv)
from vw_brand_sku_flavor as gmv_brand
union all
select 'gmv_marketing' as view_name, sum(gmv) as gmv_marketing
from vw_mkt_promo_buyer vmpb;


