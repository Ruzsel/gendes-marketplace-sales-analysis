-- ============================================================
--  GENDES FEMININE HYGIENE — STAR SCHEMA DATABASE
--  PostgreSQL | Gendes Marketplace Sales Analysis
-- ============================================================
--  FILE: 03_index.sql
--  ISI : Semua index pada fact_orders
-- ============================================================

set search_path to gendes, public;


-- ============================================================
-- INDEX PADA fact_orders
-- Fungsi: mempercepat query analitik PostgreSQL
-- ============================================================

-- Index kolom FK individual
create index if not exists idx_fact_date_key
    on fact_orders(date_key);

create index if not exists idx_fact_product_key
    on fact_orders(product_key);

create index if not exists idx_fact_location_key
    on fact_orders(location_key);

create index if not exists idx_fact_marketplace_key
    on fact_orders(marketplace_key);

create index if not exists idx_fact_buyer_key
    on fact_orders(buyer_key);

create index if not exists idx_fact_warehouse_key
    on fact_orders(warehouse_key);

create index if not exists idx_fact_promo_key
    on fact_orders(promo_key);

-- Index filter umum
create index if not exists idx_fact_platform
    on fact_orders(source_platform);

create index if not exists idx_fact_status
    on fact_orders(order_status);

create index if not exists idx_fact_created_at
    on fact_orders(created_at);

-- Composite index untuk kombinasi filter paling sering dipakai
create index if not exists idx_fact_platform_date
    on fact_orders(source_platform, date_key);

create index if not exists idx_fact_product_status
    on fact_orders(product_key, order_status);

create index if not exists idx_fact_platform_status
    on fact_orders(source_platform, is_cancelled, is_completed);


-- ============================================================
-- VERIFIKASI INDEX
-- ============================================================

select
    indexname,
    indexdef
from pg_indexes
where tablename = 'fact_orders'
  and schemaname = 'gendes'
order by indexname;
