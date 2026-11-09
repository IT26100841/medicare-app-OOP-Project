-- UPDATED COPY OF THE USER-SUPPLIED EXPORT. Contains the original records and account hashes.
-- Import into an EMPTY medicare_db_updated database. Existing tables are never dropped.
CREATE DATABASE IF NOT EXISTS medicare_db_updated CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_db_updated;
-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 02, 2026 at 09:09 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `medicare_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `doctor_id` varchar(20) NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` time NOT NULL,
  `reason` varchar(255) NOT NULL,
  `status` varchar(15) NOT NULL DEFAULT 'Booked',
  `reserved_slot` tinyint(4) GENERATED ALWAYS AS (case when `status` not in ('Cancelled','No-show') then 1 else NULL end) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`appointment_id`, `patient_id`, `doctor_id`, `appointment_date`, `appointment_time`, `reason`, `status`) VALUES
(1, 2, 'D001', '2026-10-29', '09:00:00', 'none', 'Cancelled'),
(2, 2, 'D001', '2026-10-30', '12:40:00', 'none', 'Completed'),
(3, 2, 'D001', '2026-10-30', '13:40:00', 'none', 'In consultation');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `log_id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `user_role` varchar(50) NOT NULL,
  `action` varchar(255) NOT NULL,
  `ip_address` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`log_id`, `username`, `user_role`, `action`, `ip_address`, `timestamp`) VALUES
(1, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-28 17:06:25'),
(2, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-28 17:08:25'),
(3, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-28 17:15:20'),
(4, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-29 03:24:33'),
(5, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-29 03:53:47'),
(6, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-29 04:05:52'),
(7, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-30 06:45:03'),
(8, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-30 06:45:57'),
(9, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-30 06:51:24'),
(10, 'admin', 'ADMIN', 'Updated Appointment #2 (Status: Booked)', '0:0:0:0:0:0:0:1', '2026-10-30 06:52:42'),
(11, 'admin', 'ADMIN', 'Visit #2 moved to Checked-in', '0:0:0:0:0:0:0:1', '2026-10-30 06:52:44'),
(12, 'admin', 'ADMIN', 'Visit #2 moved to In consultation', '0:0:0:0:0:0:0:1', '2026-10-30 06:52:48'),
(13, 'admin', 'ADMIN', 'Visit #2 moved to Completed', '0:0:0:0:0:0:0:1', '2026-10-30 06:56:00'),
(14, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-30 07:24:19'),
(15, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-10-30 07:28:10'),
(16, 'admin', 'ADMIN', 'Updated Appointment #3 (Status: Booked)', '0:0:0:0:0:0:0:1', '2026-10-30 07:28:46'),
(17, 'admin', 'ADMIN', 'Visit #3 moved to Checked-in', '0:0:0:0:0:0:0:1', '2026-10-30 07:28:49'),
(18, 'admin', 'ADMIN', 'Visit #3 moved to In consultation', '0:0:0:0:0:0:0:1', '2026-10-30 07:28:50'),
(19, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-11-02 05:14:14'),
(20, 'admin', 'ADMIN', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-11-02 05:28:24'),
(21, 'staff', 'STAFF', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-11-02 05:29:39'),
(22, 'staff', 'STAFF', 'User Logged In Successfully', '0:0:0:0:0:0:0:1', '2026-11-02 06:01:45');

-- --------------------------------------------------------

--
-- Table structure for table `bills`
--

CREATE TABLE `bills` (
  `bill_id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT 'Cash',
  `payment_status` varchar(20) DEFAULT 'Unpaid'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `clinic_availability`
--

CREATE TABLE `clinic_availability` (
  `id` int(11) NOT NULL,
  `doctor_id` varchar(20) NOT NULL,
  `day_of_week` int(11) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `slot_minutes` int(11) NOT NULL DEFAULT 20
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `clinic_availability`
--

INSERT INTO `clinic_availability` (`id`, `doctor_id`, `day_of_week`, `start_time`, `end_time`, `slot_minutes`) VALUES
(1, 'D001', 1, '09:00:00', '17:00:00', 20),
(2, 'D001', 2, '09:00:00', '17:00:00', 20),
(3, 'D001', 3, '09:00:00', '17:00:00', 20),
(4, 'D001', 4, '09:00:00', '17:00:00', 20),
(5, 'D001', 5, '09:00:00', '17:00:00', 20),
(6, 'D001', 6, '09:00:00', '17:00:00', 20),
(7, 'D001', 7, '09:00:00', '17:00:00', 20),
(8, 'd0021', 1, '09:00:00', '17:00:00', 10),
(9, 'd0021', 2, '09:00:00', '17:00:00', 10),
(10, 'd0021', 3, '09:00:00', '17:00:00', 10);

-- --------------------------------------------------------

--
-- Table structure for table `clinic_doctor_accounts`
--

CREATE TABLE `clinic_doctor_accounts` (
  `user_id` int(11) NOT NULL,
  `doctor_id` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `clinic_doctor_accounts`
--

INSERT INTO `clinic_doctor_accounts` (`user_id`, `doctor_id`) VALUES
(2, 'D001');

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `specialization` varchar(100) NOT NULL,
  `qualification` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `consultation_fee` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`id`, `name`, `specialization`, `qualification`, `phone`, `email`, `consultation_fee`) VALUES
('D001', 'Demo Doctor', 'General Medicine', 'MBBS', '0700000001', 'doctor@example.com', 2500.00),
('d0021', 'Shiron dimath', 'General Medicine', 'MBBS', '0700000001', 'doctor@example.com', 1400.00),
('d0022', 'Shiron dimath', 'General Medicine', 'MBBS', '0700000001', 'doctor@example.com', 3600.00);

-- --------------------------------------------------------

--
-- Table structure for table `doctor_availability`
--

CREATE TABLE `doctor_availability` (
  `availability_id` varchar(50) NOT NULL,
  `doctor_id` varchar(20) NOT NULL,
  `day` varchar(20) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_claims`
--

CREATE TABLE `insurance_claims` (
  `claim_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `provider_name` varchar(100) NOT NULL,
  `policy_number` varchar(100) NOT NULL,
  `claim_amount` decimal(12,2) NOT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medical_records`
--

CREATE TABLE `medical_records` (
  `record_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `doctor_id` varchar(20) NOT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `diagnosis` text NOT NULL,
  `prescription` text NOT NULL,
  `notes` text DEFAULT NULL,
  `record_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `medical_records`
--

INSERT INTO `medical_records` (`record_id`, `patient_id`, `doctor_id`, `appointment_id`, `diagnosis`, `prescription`, `notes`, `record_date`) VALUES
(1, 2, 'D001', 2, 'panadola', 'none', 'none2', '2026-10-30'),
(2, 2, 'D001', 3, 'nonnnenee', 'noen', 'none', '2026-10-30');

-- --------------------------------------------------------

--
-- Table structure for table `medicines`
--

CREATE TABLE `medicines` (
  `medicine_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `stock_quantity` int(11) NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `expiry_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `age` int(11) NOT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `blood_group` varchar(10) DEFAULT NULL,
  `allergies` text DEFAULT NULL,
  `medical_history` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id`, `name`, `email`, `age`, `gender`, `phone`, `address`, `blood_group`, `allergies`, `medical_history`) VALUES
(1, 'Demo Patient', 'patient@example.com', 25, 'Other', '0700000002', '12, Sample Road', 'O+', 'None', 'Sample data only'),
(2, 'yen dimath', 'shiondimathprivate@gmail.com', 14, 'Male', '0756970048', '40 thibbotugoda ganemulla', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `patient_documents`
--

CREATE TABLE `patient_documents` (
  `document_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patient_portal_accounts`
--

CREATE TABLE `patient_portal_accounts` (
  `email` varchar(100) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `patient_portal_accounts`
--

INSERT INTO `patient_portal_accounts` (`email`, `patient_id`, `password_hash`, `created_at`) VALUES
('shiondimathprivate@gmail.com', 2, 'pbkdf2$120000$mZdhofxyza7p1VB5dGrq7g==$QgTnMZjYO0PfwTk0E6+kLwwIPB7It1X/ILgyrkCQ1Jo=', '2026-10-28 17:07:40');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `role`) VALUES
(1, 'admin', 'admin@example.com', 'pbkdf2$120000$WYq7tZwdgBzgvPmxn1CE8w==$qkZOgNM1ysrsjbgfBSHmGcohCnTqj8NYi4g0o89ydE4=', 'ADMIN'),
(2, 'doctor', 'doctor@example.com', 'pbkdf2$120000$W0VnhnjEboXgKvAXLaY+Sg==$6mP9kt0frUbmot/WNrxfRxd46Tkc9ipjzApU7CWuTKw=', 'DOCTOR'),
(3, 'staff', 'staff@example.com', 'pbkdf2$120000$eiZB67xZ4sWgrTFk7ekikg==$3gRuT2I/B68zFG+qAKCTxoxgzTbpCa63PrqntOZrl/Y=', 'STAFF');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`appointment_id`),
  ADD UNIQUE KEY `uq_doctor_booking` (`doctor_id`,`appointment_date`,`appointment_time`,`reserved_slot`),
  ADD UNIQUE KEY `uq_patient_booking` (`patient_id`,`appointment_date`,`appointment_time`,`reserved_slot`),
  ADD KEY `idx_doctor_slot` (`doctor_id`,`appointment_date`,`appointment_time`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `bills`
--
ALTER TABLE `bills`
  ADD PRIMARY KEY (`bill_id`),
  ADD KEY `appointment_id` (`appointment_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `clinic_availability`
--
ALTER TABLE `clinic_availability`
  ADD PRIMARY KEY (`id`),
  ADD KEY `clinic_schedule_lookup` (`doctor_id`,`day_of_week`);

--
-- Indexes for table `clinic_doctor_accounts`
--
ALTER TABLE `clinic_doctor_accounts`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD PRIMARY KEY (`availability_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `insurance_claims`
--
ALTER TABLE `insurance_claims`
  ADD PRIMARY KEY (`claim_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `medical_records`
--
ALTER TABLE `medical_records`
  ADD PRIMARY KEY (`record_id`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `doctor_id` (`doctor_id`),
  ADD KEY `appointment_id` (`appointment_id`);

--
-- Indexes for table `medicines`
--
ALTER TABLE `medicines`
  ADD PRIMARY KEY (`medicine_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `patient_documents`
--
ALTER TABLE `patient_documents`
  ADD PRIMARY KEY (`document_id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `patient_portal_accounts`
--
ALTER TABLE `patient_portal_accounts`
  ADD PRIMARY KEY (`email`),
  ADD UNIQUE KEY `patient_id` (`patient_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `appointment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `bills`
--
ALTER TABLE `bills`
  MODIFY `bill_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `clinic_availability`
--
ALTER TABLE `clinic_availability`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `insurance_claims`
--
ALTER TABLE `insurance_claims`
  MODIFY `claim_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medical_records`
--
ALTER TABLE `medical_records`
  MODIFY `record_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `medicines`
--
ALTER TABLE `medicines`
  MODIFY `medicine_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `patient_documents`
--
ALTER TABLE `patient_documents`
  MODIFY `document_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  ADD CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`);

--
-- Constraints for table `bills`
--
ALTER TABLE `bills`
  ADD CONSTRAINT `bills_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`),
  ADD CONSTRAINT `bills_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`);

--
-- Constraints for table `doctor_availability`
--
ALTER TABLE `doctor_availability`
  ADD CONSTRAINT `doctor_availability_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `insurance_claims`
--
ALTER TABLE `insurance_claims`
  ADD CONSTRAINT `insurance_claims_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`);

--
-- Constraints for table `medical_records`
--
ALTER TABLE `medical_records`
  ADD CONSTRAINT `medical_records_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`),
  ADD CONSTRAINT `medical_records_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`),
  ADD CONSTRAINT `medical_records_ibfk_3` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`);

--
-- Constraints for table `patient_documents`
--
ALTER TABLE `patient_documents`
  ADD CONSTRAINT `patient_documents_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`);

--
-- Constraints for table `patient_portal_accounts`
--
ALTER TABLE `patient_portal_accounts`
  ADD CONSTRAINT `fk_portal_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

DELIMITER $$
DROP PROCEDURE IF EXISTS medicare_review_upgrade$$
CREATE PROCEDURE medicare_review_upgrade()
BEGIN
 IF EXISTS(SELECT 1 FROM bills GROUP BY appointment_id HAVING COUNT(*)>1) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Duplicate invoices exist. Review them before upgrading; no records have been removed.';
 END IF;
 IF EXISTS(SELECT 1 FROM clinic_availability a LEFT JOIN doctors d ON d.id=a.doctor_id WHERE d.id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unlinked schedule exists. Correct its doctor ID before upgrading.';
 END IF;
 IF EXISTS(SELECT 1 FROM clinic_doctor_accounts a LEFT JOIN doctors d ON d.id=a.doctor_id LEFT JOIN users u ON u.user_id=a.user_id WHERE d.id IS NULL OR u.user_id IS NULL) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid doctor account mapping exists. Correct it before upgrading.';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='bills' AND column_name='consultation_charge') THEN
  ALTER TABLE bills ADD COLUMN consultation_charge DECIMAL(12,2) NULL DEFAULT NULL;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='bills' AND column_name='hospital_charge') THEN
  ALTER TABLE bills ADD COLUMN hospital_charge DECIMAL(12,2) NOT NULL DEFAULT 0;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='bills' AND column_name='treatment_charge') THEN
  ALTER TABLE bills ADD COLUMN treatment_charge DECIMAL(12,2) NOT NULL DEFAULT 0;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='bills' AND constraint_name='uq_bill_appointment') THEN
  ALTER TABLE bills ADD UNIQUE KEY uq_bill_appointment(appointment_id);
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='clinic_availability' AND constraint_name='fk_clinic_schedule_doctor') THEN
  ALTER TABLE clinic_availability ADD CONSTRAINT fk_clinic_schedule_doctor FOREIGN KEY(doctor_id) REFERENCES doctors(id);
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='clinic_doctor_accounts' AND constraint_name='fk_clinic_account_user') THEN
  ALTER TABLE clinic_doctor_accounts ADD CONSTRAINT fk_clinic_account_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='clinic_doctor_accounts' AND constraint_name='fk_clinic_account_doctor') THEN
  ALTER TABLE clinic_doctor_accounts ADD CONSTRAINT fk_clinic_account_doctor FOREIGN KEY(doctor_id) REFERENCES doctors(id);
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='bills' AND constraint_name='chk_invoice_amounts') THEN
  ALTER TABLE bills ADD CONSTRAINT chk_invoice_amounts CHECK(amount>=0 AND (consultation_charge IS NULL OR consultation_charge>=0) AND hospital_charge>=0 AND treatment_charge>=0);
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='bills' AND constraint_name='chk_invoice_total') THEN
  ALTER TABLE bills ADD CONSTRAINT chk_invoice_total CHECK(consultation_charge IS NULL OR amount=consultation_charge+hospital_charge+treatment_charge);
 END IF;
END$$
CALL medicare_review_upgrade()$$
DROP PROCEDURE medicare_review_upgrade$$
DELIMITER ;
