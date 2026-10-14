USE db_apotek_sehat;

-- ============================================================================
-- 1. FUNCTION: Perhitungan Total Faktur (Action 5)
-- ============================================================================
DROP FUNCTION IF EXISTS fn_hitung_total_faktur;
DELIMITER //
CREATE FUNCTION fn_hitung_total_faktur(p_id_penjualan INT) 
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(12,2) DEFAULT 0.00;
    SELECT SUM(subtotal) INTO v_total 
    FROM detail_penjualan 
    WHERE id_penjualan = p_id_penjualan;
    RETURN IFNULL(v_total, 0.00);
END //
DELIMITER ;

-- ============================================================================
-- 2. TRIGGER: Log Perubahan Stok Otomatis (Action 5)
-- ============================================================================
CREATE TABLE IF NOT EXISTS log_stok (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_stok INT,
    stok_lama INT,
    stok_baru INT,
    waktu_perubahan TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_after_update_stok;
DELIMITER //
CREATE TRIGGER trg_after_update_stok
AFTER UPDATE ON stok_cabang
FOR EACH ROW
BEGIN
    IF OLD.jumlah_stok <> NEW.jumlah_stok THEN
        INSERT INTO log_stok (id_stok, stok_lama, stok_baru)
        VALUES (NEW.id_stok, OLD.jumlah_stok, NEW.jumlah_stok);
    END IF;
END //
DELIMITER ;

-- ============================================================================
-- 3. OPTIMASI KUERI LAPORAN (Action 9)
-- ============================================================================
-- Indeks Komposit untuk Mempercepat Query Laporan
CREATE INDEX idx_penjualan_tgl_cabang ON penjualan(tanggal_jam, id_cabang);

-- ============================================================================
-- 4. SKRIP MIGRASI FEFO & BATCH (Action 11 & 13)
-- ============================================================================
CREATE TABLE IF NOT EXISTS stok_batch (
    id_batch INT AUTO_INCREMENT PRIMARY KEY,
    id_cabang INT NOT NULL,
    id_obat INT NOT NULL,
    no_batch VARCHAR(50) NOT NULL,
    tgl_kadaluwarsa DATE NOT NULL,
    jumlah_stok INT DEFAULT 0,
    FOREIGN KEY (id_cabang) REFERENCES cabang(id_cabang),
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat)
);

CREATE INDEX idx_fefo_kadaluwarsa ON stok_batch(id_cabang, id_obat, tgl_kadaluwarsa ASC);