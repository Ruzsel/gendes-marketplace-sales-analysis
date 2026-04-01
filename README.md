## Tentang Gendes

Gendes adalah brand lokal Indonesia yang bergerak di bidang *feminine hygiene* — perawatan kebersihan area kewanitaan. Gendes hadir untuk menjawab kebutuhan perempuan Indonesia yang semakin sadar akan pentingnya menjaga kebersihan area intim, namun juga menginginkan produk yang memberikan rasa nyaman, aman, dan meningkatkan kepercayaan diri dalam aktivitas sehari-hari.

Lini produk utama Gendes mencakup **wash foam** (sabun pembersih) dan **feminine spray**, yang dirancang untuk penggunaan harian. Produk-produk ini diformulasikan dengan bahan aktif alami seperti manjakani, daun sirih, dan niacinamide — dengan manfaat antibakteri, menjaga keseimbangan pH, serta membantu mengatasi masalah umum seperti keputihan, gatal, dan bau tidak sedap. Kandungan tambahan seperti vitamin B5 turut berfungsi menjaga kelembapan dan kesehatan kulit area kewanitaan.

Repositori ini mendokumentasikan infrastruktur data analytics Gendes, mencakup pipeline PostgreSQL, lapisan view untuk Power BI, dan insight bisnis berbasis data penjualan di platform Shopee dan TikTok Shop.

---

## Daftar Isi

1. [Business Insights & Rekomendasi — Executive](#1-business-insights--rekomendasi--executive)
2. [Business Insights & Rekomendasi — Marketing](#2-business-insights--rekomendasi--marketing)
3. [Business Insights & Rekomendasi — Brand Manager](#3-business-insights--rekomendasi--brand-manager)
4. [Arsitektur Database](#4-arsitektur-database)
5. [Struktur File Proyek](#5-struktur-file-proyek)
6. [Setup & Instalasi](#6-setup--instalasi)
7. [Power BI Dashboard](#7-power-bi-dashboard)
8. [Data Dictionary](#8-data-dictionary)

---

## 1. Business Insights & Rekomendasi — Executive

> **Audience:** CEO, Owner, Direktur  
> **Sumber data:** `vw_exec_growth_health`

### Ringkasan Kinerja Bisnis (2023–2025)

| Metrik | Shopee | TikTok Shop | Total |
|---|---|---|---|
| Total GMV (completed orders) | Rp 191.5 jt | Rp 440.9 jt | **Rp 632.4 jt** |
| Total Orders | 3.010 | 6.990 | **10.000** |
| Completion Rate | 87.6% | 88.4% | ~88% |
| Cancellation Rate | 8.3% | 8.0% | ~8.1% |
| Avg Order Value | Rp 72.6 rb | Rp 71.3 rb | ~Rp 71.9 rb |
| Avg Discount Rate | 10.1% | 9.9% | ~10% |

### Insight Kunci

**1. TikTok Shop adalah mesin pertumbuhan utama — volume 2.3x lebih besar dari Shopee.**
Dari total 10.000 order, 6.990 (70%) berasal dari TikTok Shop dengan GMV Rp 440.9 juta vs Shopee Rp 191.5 juta. TikTok bukan lagi channel sekunder — ini sudah menjadi primary channel.

**2. GMV Shopee menunjukkan tren penurunan, TikTok stabil dengan recovery di 2025.**
Shopee mengalami kontraksi dari Rp 65.2 jt (2023) ke Rp 62.0 jt (2025), turun 4.9% dalam 2 tahun. TikTok sempat dip di 2024 (Rp 143.0 jt) namun rebound ke Rp 151.2 jt di 2025, mengindikasikan momentum yang positif.

**3. AOV stagnan di kedua platform — pertumbuhan hanya berbasis volume, bukan nilai transaksi.**
AOV Shopee: Rp 72.6k (2023) → Rp 71.7k (2025). AOV TikTok: Rp 72.0k (2023) → Rp 70.9k (2025). Tidak ada kenaikan signifikan selama 3 tahun, yang berarti bisnis tumbuh secara horizontal (lebih banyak pembeli) bukan secara vertikal (pembeli belanja lebih banyak).

**4. Cancellation rate 8% adalah sinyal operasional yang perlu dimonitor.**
Dari 10.000 order, sekitar 808 order dibatalkan. Pada skala GMV yang ada, ini merepresentasikan potensi revenue yang hilang setiap bulannya.

**5. Konsentrasi geografis sangat tinggi — Jawa mendominasi >70% GMV.**
DKI Jakarta dan Jawa Barat saja berkontribusi lebih dari 40% total GMV di kedua platform. Sumatera Utara menjadi provinsi non-Jawa terbesar.

### Rekomendasi

| Prioritas | Aksi | Dampak Estimasi |
|---|---|---|
| **Tinggi** | Alihkan budget promosi ke TikTok Shop — jadikan sebagai primary growth driver | Volume +15-20% |
| **Tinggi** | Investigasi penyebab declining GMV Shopee — evaluasi relevansi channel di mix strategi | Revenue preservation |
| **Sedang** | Rancang program upsell/cross-sell untuk mendorong AOV naik minimal 10-15% | Revenue +8-12% |
| **Sedang** | Analisis akar penyebab cancellation 8% — apakah stok, ekspektasi produk, atau harga | Revenue recovery |
| **Rendah** | Ekspansi ke Sumatera, Kalimantan, Sulawesi secara bertahap — market belum saturasi | Volume baru |

---

## 2. Business Insights & Rekomendasi — Marketing

> **Audience:** Marketing Manager, Tim Promo, Growth  
> **Sumber data:** `vw_mkt_promo_buyer`

### Ringkasan Performa Promo & Channel

**TikTok Shop — Breakdown per Purchase Channel (Completed Orders):**

| Channel | GMV | Orders | % GMV |
|---|---|---|---|
| TikTok Shop (organic/feed) | Rp 291.3 jt | 4.223 | **66%** |
| Affiliate | Rp 79.7 jt | 1.125 | **18%** |
| TikTok Live | Rp 69.9 jt | 833 | **16%** |

**Rata-rata Discount Rate:** ~10% di kedua platform (Shopee 10.1%, TikTok 9.9%)

### Insight Kunci

**1. TikTok Shop feed (organic/paid ads) mendominasi 66% dari seluruh GMV TikTok — bukan Live.**
Contrary to popular belief bahwa Live Commerce mendominasi TikTok Shop, data Gendes menunjukkan channel organik/feed masih menjadi generator volume terbesar. TikTok Live hanya 16% dari GMV dengan 833 order.

**2. Affiliate adalah channel dengan potensi besar yang relatif underdeveloped.**
Affiliate menghasilkan Rp 79.7 jt (18% GMV) dari hanya 1.125 order — artinya AOV affiliate lebih tinggi dari rata-rata. Ini menunjukkan kualitas traffic affiliate lebih baik dalam hal nilai transaksi.

**3. Discount rate ~10% cukup konsisten di semua channel — tidak ada diferensiasi strategi diskon.**
Uniform discount rate mengindikasikan belum ada optimasi diskon berbasis channel atau buyer segment. Idealnya, buyer baru mendapat diskon akuisisi lebih dalam, sedangkan repeat buyer didorong dengan loyalty reward, bukan diskon besar.

**4. Payday cycle dan weekend pattern tersedia di data tapi belum tereksplore secara visual.**
Kolom `is_payday` dan `day_of_week` tersedia di `vw_mkt_promo_buyer` — ada peluang untuk mengidentifikasi peak order timing dan menjalankan flash sale yang lebih presisi.

**5. Buyer segment (New vs Repeat) membutuhkan strategi promo berbeda.**
Data menunjukkan split New/Repeat buyer bisa di-slice per channel — sebuah insight yang krusial untuk menentukan apakah campaign berjalan lebih efektif dalam akuisisi atau retensi.

### Rekomendasi

| Prioritas | Aksi | Target |
|---|---|---|
| **Tinggi** | Scale up program Affiliate — rekrut lebih banyak kreator mikro, prioritaskan yang menghasilkan AOV tinggi | Affiliate GMV +30% |
| **Tinggi** | Diferensiasi strategi diskon: deep discount (>15%) untuk new buyer, voucher loyalty untuk repeat buyer | CR New buyer +10% |
| **Sedang** | Rancang kalender Live Commerce yang lebih terstruktur — fokus pada H-1 payday dan weekend sore | Live GMV +25% |
| **Sedang** | Implementasi A/B test di Shopee: test diskon 5%, 10%, 15% untuk cari sweet spot conversion vs margin | Data-driven pricing |
| **Rendah** | Buat dashboard heatmap jam order untuk optimasi jadwal posting konten dan start Live | Conversion optimization |

---

## 3. Business Insights & Rekomendasi — Brand Manager

> **Audience:** Brand Manager, Product Team  
> **Sumber data:** `vw_brand_sku_flavor`

### Ringkasan Performa Produk

**GMV per Flavor — Gabungan Kedua Platform (Completed Orders):**

| Flavor | Shopee GMV | TikTok GMV | Total | % Share |
|---|---|---|---|---|
| Vanilla | Rp 85.7 jt | Rp 196.6 jt | **Rp 282.3 jt** | 44.7% |
| Bubblegum | Rp 67.3 jt | Rp 152.4 jt | **Rp 219.7 jt** | 34.7% |
| Hazelnut | Rp 10.9 jt | Rp 27.1 jt | **Rp 38.0 jt** | 6.0% |
| Mango | Rp 10.6 jt | Rp 23.8 jt | **Rp 34.4 jt** | 5.4% |
| Bundle | Rp 10.0 jt | Rp 23.9 jt | **Rp 33.9 jt** | 5.4% |

**Split Size 20ml vs 60ml:**

| Size | Shopee GMV | Shopee Orders | TikTok GMV | TikTok Orders |
|---|---|---|---|---|
| 60ml | Rp 161.6 jt | 1.966 (74.6%) | Rp 372.1 jt | 4.614 (74.6%) |
| 20ml | Rp 29.9 jt | 671 (25.4%) | Rp 68.8 jt | 1.567 (25.4%) |

**Bundle Performance:**

| Metric | Shopee | TikTok |
|---|---|---|
| Bundle GMV | Rp 10.0 jt | Rp 23.9 jt |
| Bundle Orders | 91 (3.5%) | 216 (3.5%) |
| Bundle % of Total GMV | 5.2% | 5.4% |

### Insight Kunci

**1. Vanilla dan Bubblegum adalah duopoli — bersama-sama mengontrol 79.4% total GMV.**
Kedua flagship flavor ini mendominasi secara konsisten di kedua platform. SKU top performer adalah `GDS-FOA-VAN-60` (Foam Vanilla 60ml) dan `GDS-SPR-VAN-60` (Spray Vanilla 60ml).

**2. Hazelnut dan Mango under-indexed secara signifikan — hanya 11% dari GMV gabungan.**
Dengan hanya 5-6% share masing-masing, Hazelnut dan Mango jauh tertinggal. Ini bisa mengindikasikan masalah awareness, kurangnya push marketing, atau preferensi pasar yang memang lebih terbatas untuk kedua flavor ini.

**3. Bundle hanya berkontribusi 3.5% dari total order — jauh di bawah potensinya.**
Dengan penetrasi bundle yang sangat rendah (3.5% order), bundle belum berhasil menjadi strategi upsell yang efektif. Padahal bundle idealnya bisa mendorong AOV naik 30-50% per transaksi.

**4. Ukuran 60ml mendominasi 74.6% order di kedua platform secara konsisten.**
Pattern ini sangat konsisten (74.6% di Shopee dan TikTok). Ukuran 20ml kemungkinan berfungsi sebagai trial size atau hadiah — strategi harga dan promosi untuk 20ml perlu direview apakah ia menjadi gateway untuk konversi ke 60ml.

**5. Konsentrasi geografis Jawa untuk semua flavor — Luar Jawa belum tereksplor.**
DKI Jakarta dan Jawa Barat mendominasi semua flavor. Sumatera Utara dan Sulawesi Selatan muncul sebagai pasar luar Jawa terbesar — ada peluang untuk melakukan regional campaign yang lebih targeted.

### Rekomendasi

| Prioritas | Aksi | Target |
|---|---|---|
| **Tinggi** | Fokuskan inventory dan content marketing pada Vanilla 60ml dan Bubblegum 60ml sebagai hero SKU | Maintain dominasi, optimalkan margin |
| **Tinggi** | Rancang bundle awareness campaign: tampilkan bundle sebagai "best value" di halaman produk dan konten TikTok Live | Bundle penetration dari 3.5% ke 8-10% |
| **Sedang** | Lakukan limited time push untuk Hazelnut dan Mango — test apakah demand ada tapi tersembunyi atau memang low preference | Validasi market fit |
| **Sedang** | Buat program "try size 20ml → upgrade 60ml" — jadikan 20ml sebagai funnel akuisisi pembeli baru | Repeat purchase rate |
| **Rendah** | Eksplorasi kampanye regional untuk Sumatera Utara dan Sulawesi Selatan dengan kreator lokal | Geographic diversification |

---

## 4. Arsitektur Database

Proyek ini menggunakan star schema PostgreSQL dengan skema `gendes`.
```
                          ┌─────────────┐
                          │  dim_date   │
                          └──────┬──────┘
                                 │
┌──────────────┐   ┌─────────────▼──────────────┐   ┌──────────────────┐
│  dim_product │   │                            │   │   dim_location   │
└──────┬───────┘   │        fact_orders         │   └────────┬─────────┘
       │           │                            │            │
       └───────────►   PK: order_id (serial)    ◄────────────┘
                   │   FK: date_key             │
┌──────────────┐   │   FK: product_key          │   ┌──────────────────┐
│  dim_buyer   │   │   FK: location_key         │   │ dim_marketplace  │
└──────┬───────┘   │   FK: marketplace_key      │   └────────┬─────────┘
       │           │   FK: buyer_key            │            │
       └───────────►   FK: warehouse_key        ◄────────────┘
                   │   FK: promo_key            │
┌──────────────┐   │                            │   ┌──────────────────┐
│ dim_warehouse │  │   Measures:                │   │  dim_promo_type  │
└──────┬───────┘   │   - order_amount           │   └────────┬─────────┘
       │           │   - net_revenue            │            │
       └───────────►   - quantity               ◄────────────┘
                   │   - total_product_disc     │
                   │   - days_to_deliver        │
                   └────────────────────────────┘
```

### Views sebagai Data Layer Power BI

| View | Divisi | Deskripsi |
|---|---|---|
| `vw_exec_growth_health` | Executive | KPI growth, completion rate, GMV per platform & lokasi |
| `vw_mkt_promo_buyer` | Marketing | Efektivitas promo, buyer type, purchase channel, disc bucket |
| `vw_brand_sku_flavor` | Brand | Performa SKU, flavor, size, bundle per region |

> **Penting:** Nama kolom pada ketiga view ini tidak boleh diubah. Perubahan nama kolom akan memutus koneksi Power BI yang sudah live.

---

## 5. Struktur File Proyek
```
gendes-analytics/
│
├── sql/
│   ├── 01_schema_and_dimensions.sql   # DDL schema, semua dim tables
│   ├── 02_fact_table.sql              # DDL fact_orders + ETL insert logic
│   ├── 03_index.sql                   # Index analitik pada fact_orders
│   ├── 04_views.sql                   # 3 views untuk Power BI (jangan ubah kolom)
│   └── 05_scheduled_etl.sql           # ETL terjadwal (pg_cron / manual trigger)
│
├── data/
│   ├── shopee_gendes_2023_2025.csv    # Raw export Shopee (3.010 rows)
│   └── tiktok_gendes_2023_2025.csv    # Raw export TikTok Shop (6.990 rows)
│
├── powerbi/
│   └── Visualization.pbix             # Dashboard Power BI (3 halaman)
│
└── README.md                          # Dokumentasi ini
```

---

## 6. Setup & Instalasi

### Prasyarat

- PostgreSQL 14+
- Power BI Desktop (untuk membuka `.pbix`)
- Python 3.9+ dengan pandas (opsional, untuk validasi data)

### Urutan Eksekusi SQL

Jalankan file SQL secara berurutan:
```bash
sql/01_schema_and_dimensions.sql
sql/02_fact_table.sql
sql/03_index.sql
sql/04_views.sql
sql/05_scheduled_etl.sql
```

### Koneksi Power BI

1. Buka `Visualization.pbix` di Power BI Desktop
2. Pilih **Transform Data > Data Source Settings**
3. Update connection string ke PostgreSQL instance:
   - Server: `localhost` (atau IP server)
   - Database: `gendes_db`
   - Schema: `gendes`
4. Klik **Refresh** untuk memuat data terbaru

### Catatan Teknis ETL

- Field `"Cancelled Time"` pada TikTok menggunakan Unix epoch float — parse menggunakan `to_timestamp(nullif(..., 0)::bigint)`
- TikTok join key menggunakan kolom `"Seller SKU"` (bukan `"SKU ID"`) untuk mencocokkan format SKU Gendes (contoh: `GDS-FOA-VAN-60`)
- Search path default: `set search_path to gendes, public;`

---

## 7. Power BI Dashboard

Dashboard terdiri dari 3 halaman yang masing-masing melayani satu divisi:

### Halaman 1 — Executive Dashboard
**Data source:** `vw_exec_growth_health`

Visualisasi utama:
- GMV trend line (Shopee vs TikTok, per bulan/kuartal)
- KPI cards: total GMV, completion rate, cancellation rate, unique buyers
- Choropleth map performa per provinsi
- Waterfall chart revenue vs discount vs refund

### Halaman 2 — Marketing Dashboard
**Data source:** `vw_mkt_promo_buyer`

Layout tiga baris:
- **Baris 1:** Volume order per hari (heatmap) + distribusi jam order
- **Baris 2:** GMV per discount bucket + completion rate per disc bucket
- **Baris 3:** New vs Repeat buyer breakdown per channel + AOV comparison

### Halaman 3 — Brand Dashboard
**Data source:** `vw_brand_sku_flavor`

Visualisasi utama:
- SKU prioritization matrix (GMV vs growth rate)
- Flavor performance bar chart per island group
- Size split treemap (20ml vs 60ml per region)
- Bundle effectiveness scatter plot (AOV vs order volume)

---

## 8. Data Dictionary

### fact_orders — Kolom Utama

| Kolom | Tipe | Deskripsi |
|---|---|---|
| `order_amount` | numeric | Nilai total yang dibayarkan pembeli (termasuk ongkir) |
| `net_revenue` | numeric | Revenue bersih setelah diskon platform dan voucher |
| `subtotal_before_disc` | numeric | Harga produk sebelum diskon |
| `total_product_disc` | numeric | Total diskon produk (seller + platform) |
| `order_refund_amount` | numeric | Nilai refund untuk order yang dikembalikan |
| `is_completed` | boolean | True jika order berstatus selesai |
| `is_cancelled` | boolean | True jika order dibatalkan |
| `is_returned` | boolean | True jika order dikembalikan |
| `days_to_deliver` | integer | Selisih hari antara created_at dan delivered_at |
| `source_platform` | varchar | `'Shopee'` atau `'TikTok Shop'` |

### dim_product — Kolom Utama

| Kolom | Tipe | Deskripsi |
|---|---|---|
| `sku_id` | varchar | Kode SKU format `GDS-{TYPE}-{FLAVOR}-{SIZE}` |
| `product_type` | varchar | `'Spray'`, `'Foam'`, atau `'Bundle'` |
| `size_ml` | integer | Ukuran produk: `20` atau `60` |
| `price_tier` | varchar | Tier harga berdasarkan rentang HPP |
| `is_bundle` | boolean | True jika produk adalah bundle |

### Konvensi Penamaan SKU
```
GDS - {TYPE} - {FLAVOR} - {SIZE}
 │      │         │          │
 │      │         │          └── 20 (20ml) atau 60 (60ml)
 │      │         └──────────── VAN=Vanilla, BUB=Bubblegum,
 │      │                       HAZ=Hazelnut, MAN=Mango, GRP=Grape
 │      └────────────────────── FOA=Foam, SPR=Spray, BDL=Bundle
 └───────────────────────────── Gendes (brand prefix)

Contoh: GDS-FOA-VAN-60 = Gendes Foam Vanilla 60ml
```
