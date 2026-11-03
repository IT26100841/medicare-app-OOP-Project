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
