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
---

## KPI SUMMARY (2023–2025)

> **2023**
<img width="1253" height="184" alt="image" src="https://github.com/user-attachments/assets/ea94993e-6bd0-4cf9-8e9d-8d039bf2f053" />

> **2024**
<img width="1250" height="185" alt="image" src="https://github.com/user-attachments/assets/a177f3f6-1e24-4fba-b80b-e55055c14a56" />

> **2025**
<img width="1253" height="185" alt="image" src="https://github.com/user-attachments/assets/c4f2ca80-b899-4e4b-8481-c6f20e4109e4" />

<table>
<tr>
<td width="50%" valign="top">

### 1. Revenue Performance
- 2024 mengalami penurunan:
  - GMV: -2.83%
  - Net Revenue: -2.31%
- 2025 recovery:
  - GMV: +2.06%
  - Net Revenue: +2.79%
- Net Revenue tumbuh lebih cepat dari GMV → monetization membaik

---

### 2. AOV Trend
- 2023: Rp65.9K  
- 2024: Rp65.2K (-1.02%)  
- 2025: Rp64.5K (-1.11%)

- Penurunan konsisten → growth didorong volume, bukan value per order

---

### 3. Completion Rate
- 87.93% → 88.65% (↑)
- Indikasi peningkatan eksekusi operasional

</td>

<td width="50%" valign="top">

### 4. Cancellation & Return

**Cancellation Rate**
- 2024 naik, 2025 membaik (8.36% → 8.01%)
- Masih di atas baseline 2023 (7.88%)

**Return Rate**
- Turun konsisten (4.19% → 3.34%)
- Indikasi kualitas produk & expectation alignment meningkat

---

### 5. Key Risks
- Ketergantungan pada volume (AOV turun)
- Potensi over-discounting
- Cancel rate belum optimal

---

### 6. Executive Takeaway
- 2025 menunjukkan recovery dengan efisiensi lebih baik  
- Namun masih terdapat tekanan pada AOV dan kualitas growth

</td>
</tr>
</table>

## GMV Trend Monthly — Executive Insight (2025 vs 2024)

<img width="888" height="471" alt="image" src="https://github.com/user-attachments/assets/e4285c76-4a4f-490a-8a39-a9759bd0c714" />

<table>
<tr>
<td width="50%">

### Key Insights
- GMV 2025 berada pada range **Rp13.0M – Rp21.9M**, menunjukkan volatilitas bulanan yang tinggi.
- Peak terjadi di **May (~Rp21.88M)** sebagai performa terbaik sepanjang tahun.
- Penurunan signifikan terlihat di **February dan September**, indikasi seasonality atau lemahnya campaign.
- Performa **lebih tinggi dari tahun sebelumnya (YoY)** pada: Jan, Mar, May, Jul, Oct, Dec.
- Performa **lebih rendah dari tahun sebelumnya** pada: Feb, Jun, Aug, Sep, Nov.
- **AOV relatif stabil** (Rp62K–Rp67K) → pertumbuhan GMV lebih dipengaruhi volume/order.

</td>
<td width="50%">

### Business Implication
- Pertumbuhan masih **campaign-driven**, belum menunjukkan baseline demand yang kuat.
- Risiko terdapat pada bulan low performance (Feb, Sep) → potensi revenue leakage.
- Bulan peak (May, Oct) menunjukkan **strategi yang bisa direplikasi**.
- Tidak ada peningkatan signifikan pada AOV → peluang di pricing dan bundling.
- Ketidakkonsistenan YoY menunjukkan eksekusi marketing belum stabil.

</td>
</tr>
</table>

## GMV Contribution by Region — Executive Insight (2025)

<img width="1480" height="303" alt="image" src="https://github.com/user-attachments/assets/18321425-8d23-47d2-b988-24a7056773a4" />


<table>
<tr>
<td width="50%">

### Key Insights
- **Jabodetabek mendominasi GMV** dengan kontribusi ~Rp90.7M (±40–45% total), menunjukkan ketergantungan tinggi pada satu region.
- Tier 2 terbesar: **Jawa Timur (~Rp26.1M)** dan **Jawa Barat (~Rp21.4M)** → menjadi secondary growth driver.
- **Jawa Tengah (~Rp17.2M)** dan **Sumatera Utara (~Rp13.4M)** berada di mid-tier, namun gap dengan top region masih signifikan.
- Long tail region (Sulsel, Sumbar, Yogya, Kalimantan, Bali, Lampung, Riau, Aceh) kontribusi relatif kecil (<Rp10M).
- **AOV relatif seragam** (±Rp62K–Rp66K), kecuali **Sumatera Barat (~Rp70K)** yang lebih tinggi → indikasi daya beli/pattern berbeda.
- Distribusi revenue menunjukkan **high concentration risk** di Jabodetabek.

</td>
<td width="50%">

### Business Implication
- Bisnis sangat bergantung pada **urban core market (Jabodetabek)**.
- Growth di luar Jawa masih **underpenetrated** meskipun ada potensi volume.
- Secondary cities (Jatim, Jabar) sudah menunjukkan traction → bisa di-scale.
- Long tail region belum optimal → kemungkinan constraint di distribusi, awareness, atau channel.
- AOV stagnan antar region → belum ada diferensiasi pricing strategy.

</td>
</tr>
</table>

## GMV Behavior — Executive Insight (2025)

<img width="252" height="533" alt="image" src="https://github.com/user-attachments/assets/1ef86ab1-5f8b-44c7-9d35-00fc70857d16" />


<table>
<tr>
<td width="50%">

### Key Insights
- **Payday mendominasi GMV (55.6%)** vs non-payday (44.4%) → demand masih kuat dipengaruhi momen gajian.
- **Weekday menjadi kontributor utama (69.5%)** dibanding weekend → transaksi lebih banyak terjadi di hari kerja.
- **TikTok mendominasi platform (71.2%)** dibanding Shopee (28.8%) → channel utama revenue saat ini.
- Shopee masih underutilized meskipun memiliki potensi sebagai marketplace besar.
- Terdapat pola **event-driven (payday)** dan **routine-driven (weekday)** secara bersamaan.

</td>
<td width="50%">

### Business Implication
- Payday tetap menjadi **core revenue driver** → penting untuk campaign utama.
- Weekday dominance menunjukkan **behavior pembelian lebih rutin**, bukan hanya impuls di weekend.
- Ketergantungan tinggi pada TikTok → risiko pada perubahan algoritma/platform.
- Shopee belum optimal → peluang untuk diversifikasi revenue channel.

</td>
</tr>
</table>

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

[LINK DASHBOARD](https://app.powerbi.com/view?r=eyJrIjoiZWE5ZGQ3YjgtZDhjYi00MWJkLWIxNGQtZWQ1MmI5NjgzNTZiIiwidCI6IjUwODkxNmEwLTdiODktNDNhMS1hZjRlLTcyZmUxNWFiYTViOSIsImMiOjEwfQ%3D%3D&pageName=49b2dc96a744df1b1fe4)

<img width="1744" height="838" alt="image" src="https://github.com/user-attachments/assets/9eceb813-91c4-4659-a1c8-8693709fa629" />
<img width="1443" height="811" alt="image" src="https://github.com/user-attachments/assets/04b35c1e-0edc-45b6-8716-04681b083bfa" />
<img width="1444" height="816" alt="image" src="https://github.com/user-attachments/assets/8e96eb6a-a6c7-4a4c-94bf-b64904713741" />



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
