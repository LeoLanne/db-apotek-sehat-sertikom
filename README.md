# Multi-Branch Pharmacy Information System (Database & Application Bridge)

This repository contains the structured database development and Python application bridge for the **Multi-Branch Pharmacy Information System** (*PT Sehat Bersama Farma*), created as part of the **BNSP Certification for Database Programmer Scheme** (*Politeknik Negeri Pontianak*).

## 🚀 Key Features

- **3NF Relational Database Architecture:** Fully normalized database schema isolating inventory levels across multiple pharmacy branches via `stok_cabang`.
- **ACID Transaction Control:** Encapsulated sale transactions inside MariaDB Stored Procedures using `START TRANSACTION`, `COMMIT`, `ROLLBACK`, and `FOR UPDATE` pessimistic row locking.
- **Role-Based Access Control (RBAC):** Built-in security rules in Stored Procedures preventing unauthorized roles (e.g., Cashiers) from selling restricted prescription medicine (*Obat Keras*).
- **Automated Logging & FEFO Migration:** Triggers for automatic inventory change tracking (`log_stok`) and batch management table migrations for FEFO (*First Expired, First Out*) inventory strategy.
- **Secure Python Bridge (`app.py`):** Uses parameterized prepared statements via `mysql-connector-python` to eliminate SQL Injection risks, with isolated environment credentials (`.env`).

---

## 📁 Repository Structure

```text
├── 01_Database_Scripts/
│   ├── 01_DDL_Struktur_Tabel.sql             # Database schema, PK/FK constraints, & indexes
│   ├── 02_DML_Master_Data_dan_View.sql       # Seed data for branches, items, users, & critical stock view
│   ├── 03_Stored_Procedure_Transaksi.sql     # Transaction Stored Procedure with ACID & RBAC rules
│   ├── 03b_Function_Trigger_dan_Migrasi_FEFO.sql # Stock log trigger, billing function, & FEFO migration
│   └── 04_Pengujian_Skenario_Asesor.sql      # Test scripts for evaluation scenarios
├── 02_Source_Code_Python/
│   ├── app.py                                # Python connection module & SP caller
│   └── .env.example                          # Environment configuration template
├── .gitignore                                # Excludes sensitive environment files
└── README.md                                 # Project documentation