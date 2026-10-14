USE db_apotek_sehat;

-- 1. Jalankan Transaksi dengan Nomor Faktur Baru
CALL sp_simpan_transaksi_penjualan('FK-105', 1, 2, 1, 5, @status1);

-- 2. Tampilkan Hasil Status
SELECT @status1 AS Status_Skenario_1;

-- 3. Cek Stok Cabang
SELECT * FROM stok_cabang WHERE id_cabang = 1 AND id_obat = 1;

-- ==========================================================================
-- SKENARIO 2: Transaksi Ditolak & Rollback (Beli Melebihi Stok)
-- ==========================================================================
CALL sp_simpan_transaksi_penjualan('FK-106', 1, 2, 1, 9999, @status2);
SELECT @status2 AS Status_Skenario_2;

-- ==========================================================================
-- SKENARIO 3: Transaksi Ditolak Hak Akses (Kasir Mencoba Jual Obat Keras)
-- ==========================================================================
CALL sp_simpan_transaksi_penjualan('FK-103', 1, 3, 3, 1, @status3);
SELECT @status3 AS Status_Skenario_3;