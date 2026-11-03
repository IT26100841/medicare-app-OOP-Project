-- =======================================================
-- Member 1: Patient Management Module
-- Responsibilities: Patient registration, profiles, medical information
-- =======================================================

CREATE DATABASE IF NOT EXISTS medicare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_db;

-- 1. Patients Table
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    age INT NOT NULL,
    gender VARCHAR(10),
    phone VARCHAR(20),
    address TEXT,
    blood_group VARCHAR(10),
    allergies TEXT,
    medical_history TEXT
);

-- 2. Patient Documents Table
CREATE TABLE IF NOT EXISTS patient_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- 3. Patient Portal Accounts Table
CREATE TABLE IF NOT EXISTS patient_portal_accounts (
    email VARCHAR(100) NOT NULL PRIMARY KEY,
    patient_id INT NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_portal_patient FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sample Seed Data for Patient Management
INSERT INTO patients(id, name, email, age, gender, phone, address, blood_group, allergies, medical_history) 
VALUES(1, 'Demo Patient', 'patient@example.com', 25, 'Other', '0700000002', '12, Sample Road', 'O+', 'None', 'Sample data only')
ON DUPLICATE KEY UPDATE name=VALUES(name);
