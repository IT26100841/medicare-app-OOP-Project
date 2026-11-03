-- =======================================================
-- Member 3: Appointment Management Module
-- Responsibilities: Booking, rescheduling, cancellation, conflict checking
-- =======================================================

CREATE DATABASE IF NOT EXISTS medicare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_db;

-- 1. Appointments Table with Slot Safeguards & Conflict Prevention
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id VARCHAR(20) NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason VARCHAR(255) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'Booked',
    -- Generated virtual column to enforce unique slot only for active bookings
    reserved_slot TINYINT GENERATED ALWAYS AS (CASE WHEN status NOT IN ('Cancelled','No-show') THEN 1 ELSE NULL END) STORED,
    INDEX idx_doctor_slot(doctor_id, appointment_date, appointment_time),
    UNIQUE KEY uq_doctor_booking(doctor_id, appointment_date, appointment_time, reserved_slot),
    UNIQUE KEY uq_patient_booking(patient_id, appointment_date, appointment_time, reserved_slot)
);
