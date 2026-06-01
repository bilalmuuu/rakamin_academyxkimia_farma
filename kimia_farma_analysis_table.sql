CREATE OR REPLACE TABLE `exemplary-vista-497614-q5.kimia_farma.tabel_analisis_kimia_farma` AS

WITH cleaned_transaction AS (
  -- Langkah 1: Membersihkan format tanggal terlebih dahulu
  SELECT *,
    PARSE_DATE('%m/%d/%E4Y', date) as transaction_date
  FROM `exemplary-vista-497614-q5.kimia_farma.kf_final_transaction`
)

SELECT 
  -- 1. Identitas Transaksi & Waktu
  t.transaction_id,
  t.transaction_date,
  
  -- 2. Detail Cabang
  t.branch_id,
  b.branch_name,
  b.branch_category,
  b.kota,
  b.provinsi,
  b.rating AS rating_cabang,
  
  -- 3. Detail Pelanggan & Produk
  t.customer_name,
  t.product_id,
  p.product_name,
  p.product_category,
  
  -- 4. Kalkulasi Finansial (Sesuai Rumus Bisnis)
  p.price AS harga_asli_produk,
  t.discount_percentage,
  
  -- Rumus Harga Setelah Diskon (Nett Sales)
  (p.price * (1 - t.discount_percentage)) AS nett_sales,
  
  -- Klasifikasi Persentase Gross Laba (CASE WHEN)
  CASE 
    WHEN p.price <= 50000 THEN 0.10
    WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
    WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
    WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
    WHEN p.price > 500000 THEN 0.30
    ELSE 0
  END AS persentase_gross_laba,
  
  -- Rumus Laba Bersih Rupiah (Nett Profit)
  ((p.price * (1 - t.discount_percentage)) * CASE 
      WHEN p.price <= 50000 THEN 0.10
      WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
      WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
      WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
      WHEN p.price > 500000 THEN 0.30
      ELSE 0
    END
  ) AS nett_profit,
  
  -- 5. Rating Transaksi
  t.rating AS rating_transaksi

FROM cleaned_transaction AS t
LEFT JOIN `exemplary-vista-497614-q5.kimia_farma.kf_kantor_cabang` AS b
  ON t.branch_id = b.branch_id
LEFT JOIN `exemplary-vista-497614-q5.kimia_farma.kf_product` AS p
  ON t.product_id = p.product_id;
