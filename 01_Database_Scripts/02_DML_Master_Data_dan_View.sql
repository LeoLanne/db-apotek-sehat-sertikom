USE db_apotek_sehat;

-- 1. Isi Data Cabang
INSERT INTO cabang (kode_cabang, nama_cabang, alamat, telepon) VALUES
('CB01', 'Apotek Sehat - Jkt Pusat', 'Jl. Sudirman No. 1', '021-11111'),
('CB02', 'Apotek Sehat - Jkt Selatan', 'Jl. Blok M No. 5', '021-22222'),
('CB03', 'Apotek Sehat - Tangerang', 'Jl. BSD No. 10', '021-33333');

-- 2. Isi Data Kategori
INSERT INTO kategori (kode_kategori, nama_kategori) VALUES
('KAT01', 'Obat Bebas'),
('KAT02', 'Obat Bebas Terbatas'),
('KAT03', 'Obat Keras'),
('KAT04', 'Alat Kesehatan');

-- 3. Isi Data Obat
INSERT INTO obat (kode_obat, id_kategori, nama_obat, satuan, harga_jual, stok_minimum) VALUES
('OBT01', 1, 'Paracetamol 500mg', 'Strip', 5000.00, 10),
('OBT02', 2, 'CTM 4mg', 'Strip', 3000.00, 10),
('OBT03', 3, 'Amoxicillin 500mg', 'Strip', 12000.00, 15),
('OBT04', 4, 'Termometer Digital', 'Pcs', 45000.00, 3),
('OBT05', 1, 'Vitamin C 1000mg', 'Botol', 35000.00, 5);

-- 4. Isi Data Pengguna (Pengguna dengan Peran Berbeda)
INSERT INTO pengguna (username, password_hash, nama_lengkap, peran, id_cabang) VALUES
('admin_pusat', '$2b$12$eImiTXuWVxfM37uY4JANjO...', 'Budi Admin', 'Admin Pusat', NULL),
('apoteker_jkt', '$2b$12$eImiTXuWVxfM37uY4JANjO...', 'Siti Apt', 'Apoteker', 1),
('kasir_jkt', '$2b$12$eImiTXuWVxfM37uY4JANjO...', 'Andi Kasir', 'Kasir', 1);

-- 5. Isi Data Stok per Cabang
INSERT INTO stok_cabang (id_cabang, id_obat, jumlah_stok) VALUES
(1, 1, 100), (1, 2, 50), (1, 3, 20), (1, 4, 10), (1, 5, 2),
(2, 1, 80), (2, 3, 0);

-- 6. Buat View Stok Kritis (< Stok Minimum)
CREATE VIEW vw_stok_kritis AS
SELECT 
    c.nama_cabang,
    o.kode_obat,
    o.nama_obat,
    sc.jumlah_stok,
    o.stok_minimum,
    (o.stok_minimum - sc.jumlah_stok) AS defisit
FROM stok_cabang sc
JOIN obat o ON sc.id_obat = o.id_obat
JOIN cabang c ON sc.id_cabang = c.id_cabang
WHERE sc.jumlah_stok <= o.stok_minimum;