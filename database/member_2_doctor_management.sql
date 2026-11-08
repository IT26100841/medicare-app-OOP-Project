-- =======================================================
-- Member 2: Doctor Management Module
-- Responsibilities: Doctors, specialties, availability
-- =======================================================

CREATE DATABASE IF NOT EXISTS medicare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_db;

-- 1. Doctors Table
CREATE TABLE IF NOT EXISTS doctors (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    qualification VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    consultation_fee DECIMAL(12,2) NOT NULL
);

-- 2. Doctor Availability Table
CREATE TABLE IF NOT EXISTS doctor_availability (
    availability_id VARCHAR(50) PRIMARY KEY,
    doctor_id VARCHAR(20) NOT NULL,
    day VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. Clinic Availability Table (Weekly schedule slots)
CREATE TABLE IF NOT EXISTS clinic_availability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id VARCHAR(20) NOT NULL,
    day_of_week INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_minutes INT NOT NULL DEFAULT 20,
    INDEX clinic_schedule_lookup(doctor_id, day_of_week),
    FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Clinic Doctor Accounts Mapping
CREATE TABLE IF NOT EXISTS clinic_doctor_accounts (
    user_id INT PRIMARY KEY,
    doctor_id VARCHAR(20) NOT NULL,
    FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sample Seed Data for Doctor Management
INSERT INTO doctors (id, name, specialization, qualification, phone, email, consultation_fee)
VALUES ('D001', 'Demo Doctor', 'General Medicine', 'MBBS', '0700000001', 'doctor@example.com', 2500.00)
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT IGNORE INTO clinic_availability(doctor_id, day_of_week, start_time, end_time, slot_minutes)
SELECT 'D001', n.day_of_week, '09:00:00', '17:00:00', 20 
FROM (SELECT 1 day_of_week UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) n
WHERE NOT EXISTS(SELECT 1 FROM clinic_availability a WHERE a.doctor_id='D001' AND a.day_of_week=n.day_of_week);
