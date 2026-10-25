-- MySQL dump 10.13  Distrib 26.7.0, for macos15 (arm64)
--
-- Host: localhost    Database: medicare_db
-- ------------------------------------------------------
-- Server version	26.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `medicare_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `medicare_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `medicare_db`;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `appointment_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `doctor_id` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` time NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `status` varchar(15) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'BOOKED',
  PRIMARY KEY (`appointment_id`),
  KEY `idx_doctor_slot` (`doctor_id`,`appointment_date`,`appointment_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,'3','shiron','2026-10-16','11:30:00','Rescheduled Cardiovascular Checkup','Cancelled'),(2,'4','shiron','2026-10-16','11:30:00','Freed Slot Booking','Booked'),(3,'5','dfg','2026-10-11','09:00:00','fever','Booked');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `user_role` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `ip_address` varchar(50) COLLATE utf8mb4_general_ci DEFAULT '127.0.0.1',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,'admin','ADMIN','Registered new Patient: 1120','0:0:0:0:0:0:0:1','2026-10-10 07:58:03'),(2,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:23:22'),(3,'dr_perera','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:25:01'),(4,'dr_perera','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:39:45'),(5,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:44:01'),(6,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:44:47'),(7,'dr_perera','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:44:59'),(8,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:45:37'),(9,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:45:37'),(10,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:47:15'),(11,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:51:39'),(12,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:58:46'),(13,'dr_perera','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:59:26'),(14,'dr_perera','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 08:59:47'),(15,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-10 09:00:20'),(16,'admin','ADMIN','Added New Patient: Dimath A.M.S','0:0:0:0:0:0:0:1','2026-10-10 09:00:42'),(17,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:35:59'),(18,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:38:41'),(19,'dr_perera','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:39:03'),(20,'dr_shiron','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:43:39'),(21,'dr_shiron','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:46:14'),(22,'dr_shiron','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:47:31'),(23,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:47:52'),(24,'dr_shiron','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:53:14'),(25,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:54:01'),(26,'dr_shiron','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:54:53'),(27,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 03:55:34'),(28,'dr_shiron','DOCTOR','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 04:02:21'),(29,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 14:19:33'),(30,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 14:20:47'),(31,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 15:16:59'),(32,'admin','ADMIN','Booked Appointment #1 (Patient: 3, Doctor: shiron)','0:0:0:0:0:0:0:1','2026-10-11 15:18:08'),(33,'admin','ADMIN','Updated Appointment #1 (Status: Booked)','0:0:0:0:0:0:0:1','2026-10-11 15:20:06'),(34,'admin','ADMIN','Cancelled Appointment #1','0:0:0:0:0:0:0:1','2026-10-11 15:20:45'),(35,'admin','ADMIN','Booked Appointment #2 (Patient: 4, Doctor: shiron)','0:0:0:0:0:0:0:1','2026-10-11 15:21:05'),(36,'admin','ADMIN','User Logged In Successfully','0:0:0:0:0:0:0:1','2026-10-11 15:22:38'),(37,'admin','ADMIN','Booked Appointment #3 (Patient: 5, Doctor: dfg)','0:0:0:0:0:0:0:1','2026-10-11 15:24:30');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bills` (
  `bill_id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `patient_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `amount` double NOT NULL,
  `payment_method` varchar(50) COLLATE utf8mb4_general_ci DEFAULT 'Cash',
  `payment_status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'Unpaid',
  PRIMARY KEY (`bill_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (1,1120,'1120',1130,'Cash','Paid');
/*!40000 ALTER TABLE `bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_availability`
--

DROP TABLE IF EXISTS `doctor_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_availability` (
  `availability_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `doctor_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `day` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`availability_id`),
  KEY `fk_availability_doctor` (`doctor_id`),
  CONSTRAINT `fk_availability_doctor` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_availability`
--

LOCK TABLES `doctor_availability` WRITE;
/*!40000 ALTER TABLE `doctor_availability` DISABLE KEYS */;
/*!40000 ALTER TABLE `doctor_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `id` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `specialization` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `qualification` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `consultation_fee` double NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES ('dfg','Dimath A.M.S','full ss','mbbs','94756970048','shirondimathprivate@gmail.com',14000),('shiron ','Dimath A.M.S','full ss','mbbs','94756970048','shirondimathprivate@gmail.com',14000);
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurance_claims`
--

DROP TABLE IF EXISTS `insurance_claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurance_claims` (
  `claim_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `provider_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `policy_number` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `claim_amount` double NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`claim_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurance_claims`
--

LOCK TABLES `insurance_claims` WRITE;
/*!40000 ALTER TABLE `insurance_claims` DISABLE KEYS */;
INSERT INTO `insurance_claims` VALUES (1,'1120','ceylinco','546',500,'Approved','2026-10-10 04:36:20');
/*!40000 ALTER TABLE `insurance_claims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_records`
--

DROP TABLE IF EXISTS `medical_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_records` (
  `record_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `doctor_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `appointment_id` int DEFAULT NULL,
  `diagnosis` text COLLATE utf8mb4_general_ci NOT NULL,
  `prescription` text COLLATE utf8mb4_general_ci NOT NULL,
  `notes` text COLLATE utf8mb4_general_ci,
  `record_date` date NOT NULL,
  PRIMARY KEY (`record_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_records`
--

LOCK TABLES `medical_records` WRITE;
/*!40000 ALTER TABLE `medical_records` DISABLE KEYS */;
INSERT INTO `medical_records` VALUES (1,'shiron','avVsdv',140,'ccfASC','afvAvfAvf','vV','2026-10-02');
/*!40000 ALTER TABLE `medical_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medicines`
--

DROP TABLE IF EXISTS `medicines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicines` (
  `medicine_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `stock_quantity` int NOT NULL,
  `unit_price` double NOT NULL,
  `expiry_date` date NOT NULL,
  PRIMARY KEY (`medicine_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicines`
--

LOCK TABLES `medicines` WRITE;
/*!40000 ALTER TABLE `medicines` DISABLE KEYS */;
/*!40000 ALTER TABLE `medicines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `message` text COLLATE utf8mb4_general_ci NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_documents`
--

DROP TABLE IF EXISTS `patient_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_documents` (
  `document_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`document_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_documents`
--

LOCK TABLES `patient_documents` WRITE;
/*!40000 ALTER TABLE `patient_documents` DISABLE KEYS */;
INSERT INTO `patient_documents` VALUES (1,'shiron','Screenshot 2026-04-17 130709.png','uploads/Screenshot 2026-04-17 130709.png','2026-10-10 04:34:24'),(2,'1120','Screenshot 2026-04-25 200120.png','uploads/Screenshot 2026-04-25 200120.png','2026-10-10 07:44:26');
/*!40000 ALTER TABLE `patient_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `age` int NOT NULL,
  `gender` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_general_ci,
  `blood_group` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `allergies` text COLLATE utf8mb4_general_ci,
  `medical_history` text COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (3,'yen dimath','yendimath@gmail.com',14,'Male','0756970048','40 thibbotugoda ganemulla','A+','shiron',''),(4,'yen dimath','yendimath@gmail.com',14,'Male','0756970048','40 thibbotugoda ganemulla','A+','shiron',''),(5,'yen dimath','yendimath@gmail.com',14,'Male','0756970048','40 thibbotugoda ganemulla','A+','shiron',''),(6,'Dimath A.M.S','yendimath@gmail.com',100,'Male','0756970048','40 thibbotugoda ganemulla','A+','',''),(7,'Dimath A.M.S',NULL,12200,'Male','0756970048',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@medicare.com','admin123','ADMIN'),(2,'doctor','doctor@medicare.com','doc123','DOCTOR'),(3,'staff','staff@medicare.com','staff123','STAFF'),(5,'dr_perera','','doc123','DOCTOR'),(6,'dr_shiron','','doc123','DOCTOR');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-11 21:05:28
