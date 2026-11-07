-- Additive portal upgrade for the supplied original schema. Back up first.
USE medicare_db;
CREATE TABLE IF NOT EXISTS patient_portal_accounts (
 email VARCHAR(100) NOT NULL PRIMARY KEY,
 patient_id INT NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_portal_patient FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE
) ENGINE=InnoDB;
