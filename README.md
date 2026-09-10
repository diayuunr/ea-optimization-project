# Project 1 Mata Kuliah Sains Manajemen — Pengembangan 10 Expert Advisor (EA) dengan AI
Diayu Nur Aini (24

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

| EA | Strategi | Referensi | Status |
|---|---|---|---|
| EA01 | Moving Average Crossover | [Antovis Analytics](https://www.youtube.com/watch?v=h8lZCEpiFOI) | Done |
| EA02 | Range Breakout | [René Balke](https://www.youtube.com/watch?v=zYTdc0Q1BCs) | Done |
| EA03 | RSI Mean Reversion | [The Market Structure Trader](https://www.youtube.com/watch?v=4Y89S50fLds) | Done |
| EA04 | Bollinger Bands Reversal | [René Balke](https://www.youtube.com/watch?v=Z0rQqBUyusk) | Done |
| EA05 | MACD Momentum | [René Balke](https://www.youtube.com/watch?v=ab3JWfkUr-A) | Done |
| EA06 | Donchian Channel Scalping | [René Balke](https://www.youtube.com/watch?v=WodHEy7zuCk) | Done |
| EA07 | Trend Channel / Dual MA Trend Following | [René Balke](https://www.youtube.com/watch?v=vrFhMBEdUeE) | Done |
| EA08 | Stock Mean Reversion | [René Balke](https://www.youtube.com/watch?v=1wjvOC6RBB0) | Done |
| EA09 | Market Structure Trend Following | [René Balke](https://www.youtube.com/watch?v=mGG0nu8A9FU) | Done |
| EA10 | AI Gold Strategy (XAUUSD) | [René Balke](https://www.youtube.com/watch?v=clNEYz_yUQY) | Done |

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

## 6. Referensi

1. Antovis Analytics — *Moving Average Crossover EA mql5 Programming*  
   https://www.youtube.com/watch?v=h8lZCEpiFOI

2. René Balke — *+$800,000 Profit: How I Achieve Impossible Trading Results! (10y Test + Live Results Verification)*  
   https://www.youtube.com/watch?v=zYTdc0Q1BCs
