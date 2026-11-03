-- BACK UP FIRST. Run on the existing medicare_db. No DELETE/DROP TABLE/TRUNCATE statements.
USE medicare_db;
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
