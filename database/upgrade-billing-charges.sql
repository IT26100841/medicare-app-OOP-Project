-- Back up medicare_db before this additive migration. No records are deleted.
USE medicare_db;
DELIMITER $$
DROP PROCEDURE IF EXISTS medicare_upgrade_invoice_charges$$
CREATE PROCEDURE medicare_upgrade_invoice_charges()
BEGIN
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='bills' AND column_name='consultation_charge') THEN
  ALTER TABLE bills ADD COLUMN consultation_charge DECIMAL(12,2) NULL DEFAULT NULL;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='bills' AND column_name='hospital_charge') THEN
  ALTER TABLE bills ADD COLUMN hospital_charge DECIMAL(12,2) NOT NULL DEFAULT 0;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='bills' AND column_name='treatment_charge') THEN
  ALTER TABLE bills ADD COLUMN treatment_charge DECIMAL(12,2) NOT NULL DEFAULT 0;
 END IF;
END$$
CALL medicare_upgrade_invoice_charges()$$
DROP PROCEDURE medicare_upgrade_invoice_charges$$
DELIMITER ;
