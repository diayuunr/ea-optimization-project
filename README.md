# Project 1 Mata Kuliah Sains Manajemen — Pengembangan 10 Expert Advisor (EA) dengan AI

## 1. Deskripsi

Project ini merupakan pengembangan **10 Expert Advisor (EA) pada MetaTrader 5 (MT5)** dengan bantuan AI. Setiap EA dibuat berdasarkan strategi trading yang diperoleh dari berbagai referensi, seperti video YouTube atau sumber pembelajaran lainnya.

EA yang dibuat kemudian diuji menggunakan **Strategy Tester MT5** untuk melihat performa strategi berdasarkan data historis. Setelah mendapatkan hasil baseline, beberapa EA akan dilanjutkan ke tahap **optimization** untuk mencari kombinasi parameter yang lebih baik dan kemudian diuji kembali melalui **validation**.

Alur utama project:

**Referensi strategi → Pembuatan EA → Baseline → Optimization → Validation → Evaluasi**

> Hasil backtest bersifat historis dan tidak menjamin performa EA di kondisi pasar yang akan datang.

---

## 2. Tujuan

Project ini bertujuan untuk:

- Membuat dan memahami 10 EA dengan strategi yang berbeda.
- Menerapkan strategi trading ke dalam kode MQL5.
- Menguji performa EA menggunakan Strategy Tester MT5.
- Melakukan optimization terhadap parameter EA.
- Melakukan validation untuk melihat apakah hasil optimization tetap bekerja pada data yang berbeda.
- Membandingkan performa dan robustness dari EA yang telah dibuat.
- Menentukan beberapa EA yang memiliki performa paling menjanjikan untuk pengembangan lebih lanjut.

---

## 3. Daftar Expert Advisor

| No. | Expert Advisor | Strategi | Sumber / Channel | Link Referensi | Status |
|---:|---|---|---|---|---|
| **EA01** | **Moving Average Crossover EA** | Moving Average Crossover | Antovis Analytics | [YouTube](https://www.youtube.com/watch?v=h8lZCEpiFOI) | Dalam pengembangan |
| **EA02** | **Range Breakout EA** | Range Breakout | René Balke | [YouTube](https://www.youtube.com/watch?v=zYTdc0Q1BCs) | Optimization |
| EA03 | Belum ditentukan | - | - | - | Belum dibuat |
| EA04 | Belum ditentukan | - | - | - | Belum dibuat |
| EA05 | Belum ditentukan | - | - | - | Belum dibuat |
| EA06 | Belum ditentukan | - | - | - | Belum dibuat |
| EA07 | Belum ditentukan | - | - | - | Belum dibuat |
| EA08 | Belum ditentukan | - | - | - | Belum dibuat |
| EA09 | Belum ditentukan | - | - | - | Belum dibuat |
| EA10 | Belum ditentukan | - | - | - | Belum dibuat |

---

## 4. Metode Pengujian

Setiap EA akan diuji secara bertahap.

### Baseline

Baseline digunakan untuk mengetahui performa awal EA menggunakan parameter awal sebelum dilakukan optimization.

Beberapa metrik yang diperhatikan antara lain:

- Net Profit
- Profit Factor
- Maximum Drawdown
- Expected Payoff
- Total Trades
- Sharpe Ratio

### Optimization

Optimization dilakukan dengan menguji beberapa kombinasi parameter yang terdapat pada EA. Parameter yang dioptimasi disesuaikan dengan karakteristik masing-masing strategi.

Optimization tidak hanya bertujuan mencari **profit terbesar**, tetapi juga mempertimbangkan drawdown, jumlah transaksi, dan konsistensi hasil.

### Validation

Parameter yang dipilih dari hasil optimization kemudian diuji pada periode data yang berbeda dan tidak digunakan saat optimization.

Secara umum pembagian data dapat dilakukan sebagai:

```text
Data Historis
├── In-Sample     → Optimization
└── Out-of-Sample → Validation
```

Tujuannya adalah melihat apakah performa EA tetap cukup baik ketika digunakan pada data yang belum digunakan dalam proses pencarian parameter.

---

## 5. Evaluasi

EA akan dibandingkan berdasarkan beberapa indikator, bukan hanya berdasarkan profit.

Hal-hal yang diperhatikan meliputi:

- Profitability
- Profit Factor
- Drawdown
- Jumlah transaksi
- Konsistensi hasil
- Performa pada validation
- Robustness terhadap perubahan parameter

EA dengan profit tinggi tetapi hanya menghasilkan sedikit transaksi atau mengalami penurunan performa yang besar pada validation tidak otomatis dianggap sebagai EA terbaik.

---

## 6. Hasil Sementara

### EA01 — Moving Average Crossover

EA01 menggunakan strategi **Moving Average Crossover** dengan referensi dari Antovis Analytics.

Detail hasil baseline dan optimization akan ditambahkan setelah pengujian selesai.

### EA02 — Range Breakout

EA02 menggunakan strategi **Range Breakout** dengan referensi René Balke.

Baseline awal dilakukan pada:

- Symbol: EURUSD
- Timeframe: H1
- Model: Every tick based on real ticks
- Initial Deposit: USD 10,000
- Periode: 2021–2025

Hasil baseline awal:

| Metrik | Hasil |
|---|---:|
| Net Profit | -$44.71 |
| Profit Factor | 0.94 |
| Max Equity Drawdown | 3.79% |
| Total Trades | 21 |
| Sharpe Ratio | -0.27 |

Hasil tersebut menunjukkan bahwa konfigurasi awal EA02 belum profitable sehingga dilanjutkan ke tahap optimization.

---

## 7. Pengembangan Selanjutnya

Setelah 10 EA selesai dibuat, hasil setiap EA akan dibandingkan dan beberapa EA dengan performa yang paling menjanjikan akan dipilih untuk pengujian lebih lanjut.

Pengembangan berikutnya dapat mencakup:

- optimization parameter yang lebih luas atau lebih terarah,
- pengujian pada periode dan kondisi pasar yang berbeda,
- robustness testing,
- perbandingan antar-strategi,
- serta evaluasi kembali terhadap risiko overfitting.

Project ini akan terus diperbarui selama semester sesuai dengan perkembangan pengujian dan hasil yang diperoleh.

---

## 8. Referensi

1. Antovis Analytics — *Moving Average Crossover EA mql5 Programming*  
   https://www.youtube.com/watch?v=h8lZCEpiFOI

2. René Balke — *+$800,000 Profit: How I Achieve Impossible Trading Results! (10y Test + Live Results Verification)*  
   https://www.youtube.com/watch?v=zYTdc0Q1BCs
