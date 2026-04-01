## Tentang Gendes
<img width="226" height="88" alt="image" src="https://github.com/user-attachments/assets/53c0a994-72e8-4281-8edc-c251b0bfa2e4" />

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
---

## Diskon Besar Tidak Menghasilkan GMV Terbesar (2025)

<img width="567" height="314" alt="image" src="https://github.com/user-attachments/assets/92379458-34e5-419d-90b7-d8283e9d9564" />

<table>
<tr>
<td width="50%">

### Key Insights
- Bucket `02 | 6–10%` menghasilkan **GMV tertinggi Rp73.5M** dengan discount ratio hanya **7.8%**.
- Bucket `06 | >25%` hanya menghasilkan **Rp5.3M** meski discount ratio mencapai **38.6%**.
- Pola ini konsisten — semakin besar diskon, semakin kecil kontribusi GMV-nya.
- Total discount yang diberikan selama 2025 mencapai **Rp22.3M** dari GMV Rp218.2M (~10.2%).

</td>
<td width="50%">

### Business Implication
- Deep discount **bukan strategi efisien** — biaya promosi besar tidak berbanding lurus dengan revenue.
- Konsentrasikan budget promosi di rentang **6–10%** sebagai sweet spot GMV tertinggi dengan cost terendah.
- Perlu evaluasi menyeluruh apakah flash sale >25% masih layak dipertahankan dalam kalender promosi.

</td>
</tr>
</table>

---

##  Buyer Terbanyak Justru Ada di Diskon Rendah (2025)

<img width="1222" height="363" alt="image" src="https://github.com/user-attachments/assets/3b74cc76-4d10-453c-8914-022af93acc15" />


<table>
<tr>
<td width="50%">

### Key Insights
- Bucket `02 | 6–10%` mendominasi unique buyers dengan **1.090 buyers** (New: 681, Repeat: 409).
- Repeat buyer **tidak terkonsentrasi di diskon tinggi** — mereka tetap terbesar di bucket diskon rendah.
- Bucket `06 | >25%` hanya menghasilkan **103 unique buyers** — terendah dari semua bucket.
- Repeat buyer rate secara keseluruhan berada di **36.8%** dari total 3.383 unique buyers.

</td>
<td width="50%">

### Business Implication
- Repeat buyer **tidak membutuhkan diskon besar** untuk kembali membeli — loyalitas tidak dibangun dari diskon.
- Program retensi berbasis **voucher eksklusif atau early access** lebih cost-effective dari deep discount.
- Fokus akuisisi new buyer cukup di rentang diskon **6–10%** tanpa perlu menawarkan diskon agresif.

</td>
</tr>
</table>

---

## Diskon Tinggi Menghasilkan Completion Rate Lebih Rendah (2025)

<img width="595" height="361" alt="image" src="https://github.com/user-attachments/assets/8b7f2e9e-ad9c-44e1-bb07-594775719b2d" />


<table>
<tr>
<td width="50%">

###  Key Insights
- Completion rate tertinggi ada di bucket `02 | 6–10%` sebesar **89.2%** dan `03 | 11–15%` sebesar **87.1%**.
- Bucket `06 | >25%` mencatat completion rate **terendah di 84.3%** — selisih 4.9 poin dari bucket terbaik.
- Overall completion rate marketing berada di **88.6%** dari 2.999 completed orders.
- Pola ini mengindikasikan order dari diskon besar lebih rentan dibatalkan setelah checkout.

</td>
<td width="50%">

###  Business Implication
- Diskon besar menarik **order impulsif** yang berakhir dengan pembatalan — net revenue-nya lebih kecil dari yang terlihat.
- Hitung ulang **true ROI** setiap campaign diskon tinggi dengan memasukkan cancellation loss ke dalam kalkulasi.
- Pertimbangkan batas maksimal diskon di **15–20%** sebagai kebijakan promosi standar untuk menjaga kualitas order.

</td>
</tr>
</table>

---

## Peak Order Terkonsentrasi di Malam Hari (2025)

<img width="1278" height="322" alt="image" src="https://github.com/user-attachments/assets/a47135c4-de02-435c-b1f5-c2d9655bb86a" />


<table>
<tr>
<td width="50%">

### Key Insights
- Peak aktivitas order secara konsisten terjadi di **jam 20:00–21:00 malam** di semua hari tanpa terkecuali.
- Nilai tertinggi tercatat di **Monday jam 21:00 (Rp3.7M)**, diikuti **Friday jam 21:00 (Rp3.7M)** dan **Sunday jam 20:00 (Rp3.3M)**.
- Aktivitas mulai naik bertahap sejak jam 17:00–18:00 dan mencapai puncak di jam 20:00–21:00, lalu turun tajam setelah jam 22:00.
- **Jam 8–13 pagi hingga siang adalah periode paling sepi** — Tuesday jam 15:00 mencatat nilai terendah di Rp0.6M.

</td>
<td width="50%">

### Business Implication
- Jadwalkan **TikTok Live, flash sale, dan push notifikasi** di rentang **jam 20:00–21:00** untuk memaksimalkan konversi saat traffic di puncaknya.
- **Monday dan Friday malam** adalah slot prioritas tertinggi untuk Live Commerce — keduanya konsisten mencatat peak value tertinggi dalam seminggu.
- Hindari menjadwalkan campaign utama di jam pagi — traffic masih rendah dan potensi konversi terbatas.
- Manfaatkan **jam 18:00–19:00 sebagai warm-up** — posting konten teaser atau buka keranjang lebih awal sebelum peak jam 20:00.

</td>
</tr>
</table>

---

## 3. Business Insights & Rekomendasi — Brand Manager

> **Audience:** Brand Manager, Product Team  
> **Sumber data:** `vw_brand_sku_flavor`
---

## Vanilla & Bubblegum Mendominasi — Flavor Lain Jauh Tertinggal (2025)

<img width="1247" height="263" alt="image" src="https://github.com/user-attachments/assets/4b3130f5-a3f7-4e00-bc34-37af3f6a56d8" />


<table>
<tr>
<td width="50%">

### Key Insights
- **Vanilla (Rp97M)** dan **Bubblegum (Rp74M)** bersama mengontrol **78.4% total GMV flavor** di 2025.
- Flavor ke-3 adalah **Mixed Bundle (Rp13M)** dan **Hazelnut (Rp13M)** — masing-masing hanya ~6% share.
- **Mango (Rp11M)** dan **Grape (Rp10M)** berada di posisi terbawah dengan gap hampir 9x dari Vanilla.
- Tren harian "GMV by Day and Flavor" menunjukkan Vanilla dan Bubblegum konsisten di atas sepanjang bulan, flavor lain flat mendekati nol.

</td>
<td width="50%">

### Business Implication
- Vanilla dan Bubblegum adalah **hero SKU** yang harus dijaga ketersediaan stoknya — stockout pada dua flavor ini langsung berdampak besar ke GMV keseluruhan.
- Flavor minor (Hazelnut, Mango, Grape) perlu **keputusan strategis**: apakah layak di-push dengan campaign khusus atau diposisikan sebagai pilihan niche tanpa investasi promosi besar.
- Pertimbangkan untuk **mengembangkan varian baru** di bawah payung Vanilla atau Bubblegum daripada mendorong flavor yang sudah terbukti kurang diminati pasar.

</td>
</tr>
</table>

---

## Foam Mendominasi, Bundle Masih Sangat Kecil (2025)

<img width="1123" height="225" alt="image" src="https://github.com/user-attachments/assets/7fb0ffc5-8b9c-40b6-b0b9-64b95a3eab3b" />


<table>
<tr>
<td width="50%">

### Key Insights
- **Foam (Rp110M, 50.55%)** sedikit unggul dari **Spray (Rp95M, 43.38%)** di GMV product type 2025.
- **Bundle hanya Rp13M (6.07%)** dari total GMV — penetrasi sangat rendah meski SKU bundle `GDS-BDL-SS-60` masuk top 10 SKU di posisi ke-5 dengan Rp7M.
- Di scatter plot "Net Revenue vs Unit Sold", Foam Satuan dan Spray Satuan mendominasi volume, sedangkan cluster bundle sangat kecil.
- SKU top 2 adalah **GDS-FOA-VAN-60 (Rp43M)** dan **GDS-SPR-VAN-60 (Rp39M)** — keduanya varian Vanilla.

</td>
<td width="50%">

### Business Implication
- Bundle belum berhasil sebagai **strategi upsell** — perlu dievaluasi apakah kendala di visibility, harga, atau value proposition yang belum terkomunikasi dengan baik.
- Jadikan bundle sebagai **highlight di TikTok Live** dengan framing "hemat lebih banyak" untuk menaikkan penetrasi dari 6% ke target 12%+.
- Keseimbangan Foam vs Spray yang relatif setara (50% vs 43%) menunjukkan **kedua format diterima pasar** — pertahankan keduanya dalam portofolio tanpa mengorbankan salah satu.

</td>
</tr>
</table>

---

## DKI Jakarta & Jawa Barat Mendominasi, Luar Jawa Masih Sangat Kecil (2025)

<img width="687" height="258" alt="image" src="https://github.com/user-attachments/assets/899bee8e-0189-4335-9fbb-73eece7adfe1" />


<table>
<tr>
<td width="50%">

### Key Insights
- **DKI Jakarta (Rp52.4M)** dan **Jawa Barat (Rp49.6M)** bersama menyumbang **46.3% total GMV Brand** 2025.
- DKI Jakarta memimpin dengan **746 orders**, completion rate **95.71%**, dan **923 units sold**.
- Provinsi luar Jawa terbesar adalah **Sumatera Utara (Rp13.4M)** — sudah ada demand organik tapi masih jauh di bawah provinsi Jawa.
- **Yogyakarta** mencatat completion rate **100%** dari 96 orders — sinyal kualitas buyer yang sangat baik di kota ini.

</td>
<td width="50%">

### Business Implication
- DKI Jakarta dan Jawa Barat adalah **core market** yang tidak boleh ada gangguan stok — prioritas fulfillment dan SLA pengiriman harus dijaga ketat di dua provinsi ini.
- **Sumatera Utara** adalah kandidat ekspansi prioritas pertama di luar Jawa — demand organik sudah terbukti, akselerasi dengan kreator lokal dan regional campaign.
- **Yogyakarta** dengan completion rate 100% layak dijadikan **pilot market** untuk program loyalitas atau bundle campaign sebelum di-scale ke kota lain.

</td>
</tr>
</table>

---

## TikTok Mendominasi Volume, Shopee Tetap Relevan (2025)

<img width="531" height="227" alt="image" src="https://github.com/user-attachments/assets/4199fcb1-3724-404b-89ec-016efdbdde73" />
<img width="943" height="255" alt="image" src="https://github.com/user-attachments/assets/59d3fea4-8d62-4c72-9a37-4229aa78d37c" />


<table>
<tr>
<td width="50%">

### Key Insights
- **TikTok Shop: 3K units (70.65%)** vs **Shopee: 1K units (29.35%)** dari total unit sold by platform 2025.
- Di treemap GMV by Province, TikTok mendominasi semua provinsi besar — DKI Jakarta TikTok **Rp38M** vs Shopee **Rp14M**.
- **Bottle Size 60ml mendominasi** di semua provinsi — DKI Jakarta: 717 unit (60ml) vs 206 unit (20ml), Jawa Barat: 654 vs 241.
- Completion rate keseluruhan sangat tinggi **96.37%** dengan return rate hanya **3.63%**.

</td>
<td width="50%">

### Business Implication
- TikTok adalah **primary growth engine** — investasi konten, affiliate, dan Live Commerce harus terus ditingkatkan secara konsisten.
- Shopee dengan ~30% share **tidak bisa diabaikan** — platform ini melayani segmen buyer berbeda dan perlu strategi tersendiri, bukan sekadar mirror konten TikTok.
- Dominasi 60ml mengonfirmasi bahwa **ukuran ini adalah main SKU** — pastikan stok 60ml selalu tersedia. Ukuran 20ml dapat diposisikan sebagai **trial entry point** untuk akuisisi buyer baru.
- Completion rate 96.37% adalah **aset kepercayaan brand** — tonjolkan angka ini sebagai social proof dalam konten marketing.

</td>
</tr>
</table>

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

[LINK DASHBOARD](https://app.powerbi.com/view?r=eyJrIjoiYjA2YmIzNzItYzYxMy00YzkxLWI5ZWYtYzdkZmY3NWJkY2IzIiwidCI6IjUwODkxNmEwLTdiODktNDNhMS1hZjRlLTcyZmUxNWFiYTViOSIsImMiOjEwfQ%3D%3D)

<img width="1607" height="736" alt="image" src="https://github.com/user-attachments/assets/e88133cf-f424-4bb2-a74c-8437928f5583" />
<img width="1369" height="765" alt="image" src="https://github.com/user-attachments/assets/5380c33e-096f-4509-8025-6ff77990304f" />
<img width="1366" height="763" alt="image" src="https://github.com/user-attachments/assets/c1aca7ec-cbe3-41b9-ada7-46a152ce1ee9" />


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
