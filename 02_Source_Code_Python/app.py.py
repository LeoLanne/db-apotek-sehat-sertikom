import os
import mysql.connector
from mysql.connector import Error

def load_env():
    config = {}
    if os.path.exists('.env'):
        with open('.env', 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    key, val = line.split('=', 1)
                    config[key.strip()] = val.strip()
    return config

config = load_env()

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=config.get('DB_HOST', 'localhost'),
            user=config.get('DB_USER', 'root'),
            password=config.get('DB_PASSWORD', ''),
            database=config.get('DB_NAME', 'db_apotek_sehat'),
            port=int(config.get('DB_PORT', 3306))
        )
        return connection
    except Error as e:
        print(f"[-] Gagal terhubung ke database: {e}")
        return None

def simpan_transaksi_aman(faktur, id_cabang, id_pengguna, id_obat, jumlah):
    conn = get_db_connection()
    if not conn:
        return

    cursor = conn.cursor()
    try:
        # Panggil Stored Procedure dengan parameter terikat (Mencegah SQL Injection)
        result_args = cursor.callproc('sp_simpan_transaksi_penjualan', [
            faktur, id_cabang, id_pengguna, id_obat, jumlah, ''
        ])
        
        status = result_args[5] # Ambil hasil OUT parameter p_status
        
        print("\n===========================================")
        print(" HASIL EKSEKUSI APLIKASI PYTHON")
        print("===========================================")
        print(f"No Faktur : {faktur}")
        print(f"Status    : {status}")
        print("===========================================\n")

    except Error as e:
        print(f"[-] Terjadi kesalahan aplikasi: {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    print("=== SISTEM INFORMASI APOTEK SEHAT (PYTHON BRIDGE) ===")
    print("[+] Mencoba transaksi via Stored Procedure...")
    
    # Pengujian transaksi dari Python dengan Faktur 'FK-201'
    simpan_transaksi_aman(
        faktur='FK-201',
        id_cabang=1,
        id_pengguna=2, # Apoteker Jakarta
        id_obat=1,     # Paracetamol
        jumlah=5
    )

""" jika ingin uji coba system input user
def main():
    print("==================================================")
    print("  SISTEM INFORMASI APOTEK SEHAT (INTERACTIVE INPUT)")
    print("==================================================")
    
    try:
        # Menerima input langsung dari pengetikan pengguna
        faktur = input("Masukkan No Faktur   : ").strip()
        id_cabang = int(input("Masukkan ID Cabang   : "))
        id_pengguna = int(input("Masukkan ID Pengguna : "))
        id_obat = int(input("Masukkan ID Obat     : "))
        jumlah = int(input("Masukkan Jumlah Beli : "))
        
        print("\n[+] Memproses transaksi via Stored Procedure...")
        # Memanggil fungsi transaksi dengan data yang diinput pengguna
        simpan_transaksi_aman(faktur, id_cabang, id_pengguna, id_obat, jumlah)
        
    except ValueError:
        print("\n[-] ERROR: Input ID dan Jumlah harus berupa angka!")

if __name__ == "__main__":
    main()
    """

"""jika ingin langsung jalankan keduanya
if __name__ == "__main__":
    print("=== SISTEM INFORMASI APOTEK SEHAT (PYTHON BRIDGE) ===")
    print("1. Jalankan Pengujian Otomatis (Faktur FK-201)")
    print("2. Input Transaksi Manual (Interaktif)")
    
    pilihan = input("Pilih mode (1/2): ").strip()
    
    if pilihan == "2":
        faktur = input("Masukkan No Faktur   : ").strip()
        id_cabang = int(input("Masukkan ID Cabang   : "))
        id_pengguna = int(input("Masukkan ID Pengguna : "))
        id_obat = int(input("Masukkan ID Obat     : "))
        jumlah = int(input("Masukkan Jumlah Beli : "))
        simpan_transaksi_aman(faktur, id_cabang, id_pengguna, id_obat, jumlah)
    else:
        print("\n[+] Jalankan pengujian otomatis...")
        simpan_transaksi_aman(
            faktur='FK-201',
            id_cabang=1,
            id_pengguna=2, # Apoteker Jakarta
            id_obat=1,     # Paracetamol
            jumlah=5
        )
        """