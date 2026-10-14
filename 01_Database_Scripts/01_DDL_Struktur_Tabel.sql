-- 1. Buat dan gunakan database baru
CREATE DATABASE IF NOT EXISTS db_apotek_sehat;
USE db_apotek_sehat;

-- 2. Tabel Cabang
CREATE TABLE cabang (
    id_cabang INT AUTO_INCREMENT PRIMARY KEY,
    kode_cabang VARCHAR(10) UNIQUE NOT NULL,
    nama_cabang VARCHAR(100) NOT NULL,
    alamat TEXT,
    telepon VARCHAR(20)
);

-- 3. Tabel Kategori
CREATE TABLE kategori (
    id_kategori INT AUTO_INCREMENT PRIMARY KEY,
    kode_kategori VARCHAR(10) UNIQUE NOT NULL,
    nama_kategori VARCHAR(50) NOT NULL
);

-- 4. Tabel Obat
CREATE TABLE obat (
    id_obat INT AUTO_INCREMENT PRIMARY KEY,
    kode_obat VARCHAR(20) UNIQUE NOT NULL,
    id_kategori INT NOT NULL,
    nama_obat VARCHAR(150) NOT NULL,
    satuan VARCHAR(20) NOT NULL,
    harga_jual DECIMAL(12,2) NOT NULL,
    stok_minimum INT DEFAULT 5,
    FOREIGN KEY (id_kategori) REFERENCES kategori(id_kategori)
);

-- 5. Tabel Stok per Cabang
CREATE TABLE stok_cabang (
    id_stok INT AUTO_INCREMENT PRIMARY KEY,
    id_cabang INT NOT NULL,
    id_obat INT NOT NULL,
    jumlah_stok INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_cabang_obat UNIQUE (id_cabang, id_obat),
    FOREIGN KEY (id_cabang) REFERENCES cabang(id_cabang),
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat)
);

-- 6. Tabel Pengguna
CREATE TABLE pengguna (
    id_pengguna INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    peran ENUM('Admin Pusat', 'Apoteker', 'Kasir') NOT NULL,
    id_cabang INT,
    FOREIGN KEY (id_cabang) REFERENCES cabang(id_cabang)
);

-- 7. Tabel Penjualan
CREATE TABLE penjualan (
    id_penjualan INT AUTO_INCREMENT PRIMARY KEY,
    no_faktur VARCHAR(30) UNIQUE NOT NULL,
    tanggal_jam DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_cabang INT NOT NULL,
    id_pengguna INT NOT NULL,
    total DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (id_cabang) REFERENCES cabang(id_cabang),
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna)
);

-- 8. Tabel Detail Penjualan
CREATE TABLE detail_penjualan (
    id_detail INT AUTO_INCREMENT PRIMARY KEY,
    id_penjualan INT NOT NULL,
    id_obat INT NOT NULL,
    jumlah INT NOT NULL,
    harga_satuan DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_penjualan) REFERENCES penjualan(id_penjualan),
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat)
);

-- 9. Indeks untuk optimasi query
CREATE INDEX idx_penjualan_tgl_cabang ON penjualan(tanggal_jam, id_cabang);
CREATE INDEX idx_detail_penjualan_id ON detail_penjualan(id_penjualan, id_obat);