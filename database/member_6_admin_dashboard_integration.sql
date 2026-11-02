-- =======================================================
-- Member 6: Admin, Security, Dashboard & Integration Module
-- Responsibilities: Users, roles, reports, dashboard, system integration
-- =======================================================

CREATE DATABASE IF NOT EXISTS medicare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_db;

-- 1. Users Table (Admin, Doctor, Staff roles)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL DEFAULT '',
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL
);

-- 2. Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    user_role VARCHAR(50) NOT NULL,
    action VARCHAR(255) NOT NULL,
    ip_address VARCHAR(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System Logins with Salted PBKDF2 Hashes
INSERT INTO users(username, email, password, role) VALUES
('admin', 'admin@example.com', 'pbkdf2$120000$WYq7tZwdgBzgvPmxn1CE8w==$qkZOgNM1ysrsjbgfBSHmGcohCnTqj8NYi4g0o89ydE4=', 'ADMIN'),
('doctor', 'doctor@example.com', 'pbkdf2$120000$W0VnhnjEboXgKvAXLaY+Sg==$6mP9kt0frUbmot/WNrxfRxd46Tkc9ipjzApU7CWuTKw=', 'DOCTOR'),
('staff', 'staff@example.com', 'pbkdf2$120000$eiZB67xZ4sWgrTFk7ekikg==$3gRuT2I/B68zFG+qAKCTxoxgzTbpCa63PrqntOZrl/Y=', 'STAFF')
ON DUPLICATE KEY UPDATE role=VALUES(role);
