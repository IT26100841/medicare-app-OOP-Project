-- Fresh demo schema for Medicare. Use a new database; original_snapshot.sql preserves the uploaded snapshot.
CREATE DATABASE IF NOT EXISTS medicare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE medicare_db;
CREATE TABLE users (user_id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL UNIQUE, email VARCHAR(100) NOT NULL DEFAULT '', password VARCHAR(255) NOT NULL, role VARCHAR(20) NOT NULL);
CREATE TABLE patients (id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(100) NOT NULL,email VARCHAR(100),age INT NOT NULL,gender VARCHAR(10),phone VARCHAR(20),address TEXT,blood_group VARCHAR(10),allergies TEXT,medical_history TEXT);
CREATE TABLE doctors (id VARCHAR(20) PRIMARY KEY,name VARCHAR(100) NOT NULL,specialization VARCHAR(100) NOT NULL,qualification VARCHAR(100),phone VARCHAR(20),email VARCHAR(100),consultation_fee DECIMAL(12,2) NOT NULL);
CREATE TABLE appointments (appointment_id INT AUTO_INCREMENT PRIMARY KEY,patient_id INT NOT NULL,doctor_id VARCHAR(20) NOT NULL,appointment_date DATE NOT NULL,appointment_time TIME NOT NULL,reason VARCHAR(255) NOT NULL,status VARCHAR(15) NOT NULL DEFAULT 'Booked',INDEX idx_doctor_slot(doctor_id,appointment_date,appointment_time),FOREIGN KEY(patient_id) REFERENCES patients(id),FOREIGN KEY(doctor_id) REFERENCES doctors(id));
CREATE TABLE medical_records(record_id INT AUTO_INCREMENT PRIMARY KEY,patient_id INT NOT NULL,doctor_id VARCHAR(20) NOT NULL,appointment_id INT NULL,diagnosis TEXT NOT NULL,prescription TEXT NOT NULL,notes TEXT,record_date DATE NOT NULL,FOREIGN KEY(patient_id) REFERENCES patients(id),FOREIGN KEY(doctor_id) REFERENCES doctors(id),FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id));
CREATE TABLE bills(bill_id INT AUTO_INCREMENT PRIMARY KEY,appointment_id INT NOT NULL,patient_id INT NOT NULL,amount DECIMAL(12,2) NOT NULL,payment_method VARCHAR(50) DEFAULT 'Cash',payment_status VARCHAR(20) DEFAULT 'Unpaid',consultation_charge DECIMAL(12,2) NULL DEFAULT NULL,hospital_charge DECIMAL(12,2) NOT NULL DEFAULT 0,treatment_charge DECIMAL(12,2) NOT NULL DEFAULT 0,FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id),FOREIGN KEY(patient_id) REFERENCES patients(id));
CREATE TABLE notifications(notification_id INT AUTO_INCREMENT PRIMARY KEY,patient_id INT NOT NULL,message TEXT NOT NULL,date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(patient_id) REFERENCES patients(id));
CREATE TABLE patient_documents(document_id INT AUTO_INCREMENT PRIMARY KEY,patient_id INT NOT NULL,file_name VARCHAR(255) NOT NULL,file_path VARCHAR(255) NOT NULL,uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(patient_id) REFERENCES patients(id));
CREATE TABLE insurance_claims(claim_id INT AUTO_INCREMENT PRIMARY KEY,patient_id INT NOT NULL,provider_name VARCHAR(100) NOT NULL,policy_number VARCHAR(100) NOT NULL,claim_amount DECIMAL(12,2) NOT NULL,status VARCHAR(20) DEFAULT 'Pending',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(patient_id) REFERENCES patients(id));
CREATE TABLE audit_logs(log_id INT AUTO_INCREMENT PRIMARY KEY,username VARCHAR(100) NOT NULL,user_role VARCHAR(50) NOT NULL,action VARCHAR(255) NOT NULL,ip_address VARCHAR(50),timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE doctor_availability(availability_id VARCHAR(50) PRIMARY KEY,doctor_id VARCHAR(20) NOT NULL,day VARCHAR(20) NOT NULL,start_time TIME NOT NULL,end_time TIME NOT NULL,FOREIGN KEY(doctor_id) REFERENCES doctors(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE medicines(medicine_id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(100) NOT NULL,stock_quantity INT NOT NULL,unit_price DECIMAL(12,2) NOT NULL,expiry_date DATE NOT NULL);
-- Demo logins only; passwords are already PBKDF2 hashed. Change before deployment.
INSERT INTO users(username,email,password,role) VALUES('admin','admin@example.com','pbkdf2$120000$WYq7tZwdgBzgvPmxn1CE8w==$qkZOgNM1ysrsjbgfBSHmGcohCnTqj8NYi4g0o89ydE4=','ADMIN'),('doctor','doctor@example.com','pbkdf2$120000$W0VnhnjEboXgKvAXLaY+Sg==$6mP9kt0frUbmot/WNrxfRxd46Tkc9ipjzApU7CWuTKw=','DOCTOR'),('staff','staff@example.com','pbkdf2$120000$eiZB67xZ4sWgrTFk7ekikg==$3gRuT2I/B68zFG+qAKCTxoxgzTbpCa63PrqntOZrl/Y=','STAFF');
INSERT INTO patients(name,email,age,gender,phone,address,blood_group,allergies,medical_history) VALUES('Demo Patient','patient@example.com',25,'Other','0700000002','12, Sample Road','O+','None','Sample data only');
INSERT INTO doctors VALUES('D001','Demo Doctor','General Medicine','MBBS','0700000001','doctor@example.com',2500);

-- Medicare clinic workflow upgrade. Run once on your existing medicare_db.
-- Additive and safe to rerun: does not remove patients, users, visits or invoices.
USE medicare_db;
CREATE TABLE IF NOT EXISTS clinic_availability (
 id INT AUTO_INCREMENT PRIMARY KEY,
 doctor_id VARCHAR(20) NOT NULL,
 day_of_week INT NOT NULL,
 start_time TIME NOT NULL,
 end_time TIME NOT NULL,
 slot_minutes INT NOT NULL DEFAULT 20,
 INDEX clinic_schedule_lookup(doctor_id,day_of_week)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS clinic_doctor_accounts (
 user_id INT PRIMARY KEY,
 doctor_id VARCHAR(20) NOT NULL
) ENGINE=InnoDB;
-- Only link the known demo login/profile if both exist. Configure real accounts in Team & access.
INSERT IGNORE INTO clinic_doctor_accounts(user_id,doctor_id)
 SELECT u.user_id,d.id FROM users u JOIN doctors d ON d.id='D001' WHERE u.username='doctor' AND u.role='DOCTOR';
-- Known demo sessions only. Real clinicians' sessions must be configured by the administrator.
INSERT INTO clinic_availability(doctor_id,day_of_week,start_time,end_time,slot_minutes)
 SELECT d.id,n.day_of_week,'09:00:00','17:00:00',20 FROM doctors d
 JOIN (SELECT 1 day_of_week UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) n
 WHERE d.id='D001' AND NOT EXISTS(SELECT 1 FROM clinic_availability a WHERE a.doctor_id=d.id AND a.day_of_week=n.day_of_week);

-- Additive portal upgrade for the supplied original schema. Back up first.
USE medicare_db;
CREATE TABLE IF NOT EXISTS patient_portal_accounts (
 email VARCHAR(100) NOT NULL PRIMARY KEY,
 patient_id INT NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_portal_patient FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Database-level safeguards against double booking, including external SQL writers.
-- Fresh schema only. Do not append these blindly to a populated legacy database.
ALTER TABLE appointments
 ADD COLUMN reserved_slot TINYINT GENERATED ALWAYS AS (CASE WHEN status NOT IN ('Cancelled','No-show') THEN 1 ELSE NULL END) STORED,
 ADD UNIQUE KEY uq_doctor_booking(doctor_id,appointment_date,appointment_time,reserved_slot),
 ADD UNIQUE KEY uq_patient_booking(patient_id,appointment_date,appointment_time,reserved_slot);

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
