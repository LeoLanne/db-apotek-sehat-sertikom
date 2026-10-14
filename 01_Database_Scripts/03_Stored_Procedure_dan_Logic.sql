USE db_apotek_sehat;

DROP PROCEDURE IF EXISTS sp_simpan_transaksi_penjualan;

DELIMITER //

CREATE PROCEDURE sp_simpan_transaksi_penjualan(
    IN p_faktur VARCHAR(30),
    IN p_id_cabang INT,
    IN p_id_pengguna INT,
    IN p_id_obat INT,
    IN p_jumlah INT,
    OUT p_status VARCHAR(150)
)
BEGIN
    DECLARE v_stok_saat_ini INT DEFAULT 0;
    DECLARE v_harga DECIMAL(12,2);
    DECLARE v_peran VARCHAR(20);
    DECLARE v_id_kategori INT;
    DECLARE v_id_penjualan INT;
    DECLARE v_faktur_ada INT DEFAULT 0;
    
    -- Handler Error SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SET p_status = 'ERROR: Terjadi kesalahan database (Duplicate FK / Constraint Failed).';
    END;

    START TRANSACTION;

    -- Validasi 1: Cek apakah No Faktur sudah pernah dipakai
    SELECT COUNT(*) INTO v_faktur_ada FROM penjualan WHERE no_faktur = p_faktur;
    
    IF v_faktur_ada > 0 THEN
        ROLLBACK;
        SET p_status = CONCAT('GAGAL: No Faktur [', p_faktur, '] sudah terdaftar!');
    ELSE
        -- Validasi 2: Cek Peran Pengguna & Kategori Obat
        SELECT peran INTO v_peran FROM pengguna WHERE id_pengguna = p_id_pengguna;
        SELECT id_kategori, harga_jual INTO v_id_kategori, v_harga FROM obat WHERE id_obat = p_id_obat;

        IF v_id_kategori = 3 AND v_peran = 'Kasir' THEN
            ROLLBACK;
            SET p_status = 'GAGAL: Kasir tidak diizinkan menjual Obat Keras!';
        ELSE
            -- Validasi 3: Lock & Cek Stok Cabang
            SELECT jumlah_stok INTO v_stok_saat_ini 
            FROM stok_cabang 
            WHERE id_cabang = p_id_cabang AND id_obat = p_id_obat 
            FOR UPDATE;

            IF v_stok_saat_ini IS NULL OR v_stok_saat_ini < p_jumlah THEN
                ROLLBACK;
                SET p_status = CONCAT('GAGAL: Stok cabang tidak mencukupi! Sisa stok: ', IFNULL(v_stok_saat_ini, 0));
            ELSE
                -- Simpan Penjualan & Detail
                INSERT INTO penjualan (no_faktur, id_cabang, id_pengguna, total)
                VALUES (p_faktur, p_id_cabang, p_id_pengguna, (v_harga * p_jumlah));
                
                SET v_id_penjualan = LAST_INSERT_ID();

                INSERT INTO detail_penjualan (id_penjualan, id_obat, jumlah, harga_satuan, subtotal)
                VALUES (v_id_penjualan, p_id_obat, p_jumlah, v_harga, (v_harga * p_jumlah));

                -- Potong Stok
                UPDATE stok_cabang 
                SET jumlah_stok = jumlah_stok - p_jumlah 
                WHERE id_cabang = p_id_cabang AND id_obat = p_id_obat;

                COMMIT;
                SET p_status = 'SUKSES: Transaksi berhasil disimpan.';
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;