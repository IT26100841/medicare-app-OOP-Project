========================================================================
MEDICARE HOSPITAL MANAGEMENT SYSTEM - WD 51 GROUP PROJECT
========================================================================
Read START_HERE_SINHALA.txt first. Updated release: 02 November 2026.

1. OVERVIEW
------------------------------------------------------------------------
Medicare is a full-featured Java Servlet & JSP web application designed
for hospital management, doctor scheduling, patient clinical records, 
appointment bookings with automated conflict detection, and billing.
Includes source, rebuilt WAR, additive migration, data-preserving SQL copy,
class diagrams and test results.

2. DATABASE SETUP
------------------------------------------------------------------------
- Fresh demo schema: database/medicare-patient-portal-fresh.sql
- Migration script for existing database: database/upgrade-reviewed.sql
- Database Name: medicare_db
- How to import fresh schema:
  * Using phpMyAdmin / XAMPP:
    1. Create a database named 'medicare_db'.
    2. Click 'Import' and select 'database/medicare-patient-portal-fresh.sql'.
    3. Click 'Go'.
  * Using MySQL CLI:
    mysql -u root -p < database/medicare-patient-portal-fresh.sql

- Database configuration file in source code:
  src/main/java/com/medicare/util/DBConnection.java
  (Default: jdbc:mysql://localhost:3306/medicare_db, User: root, Password: "")
  Or pass VM options to Tomcat:
  -Dmedicare.storage=DB -Dmedicare.db.url=jdbc:mysql://localhost:3306/medicare_db -Dmedicare.db.user=root -Dmedicare.db.password=

3. DEFAULT LOGIN CREDENTIALS
------------------------------------------------------------------------
- Admin:  Username: admin   | Password: admin123  (Full access)
- Doctor: Username: doctor  | Password: doc123    (Doctor Portal & Clinical)
- Staff:  Username: staff   | Password: staff123  (Staff Reception)

4. CORE MODULES & FEATURES
------------------------------------------------------------------------
- Appointment Management:
  * Book Appointment: Doctor & Patient selectors, date/time pickers.
  * Conflict Detection: Automatically prevents double-booking a doctor
    at the same date and time slot.
  * Appointment List: Live keyword search & status filters (Booked, Completed, Cancelled).
  * Edit Appointment: Rescheduling and details modification.
  * Cancel Appointment: Confirmation screen that releases doctor slots.
- Patient Directory (Add, edit, medical history, blood group, allergies)
- Doctor Directory (Specializations, consultation fees, availability)
- Medical Records & Clinical Diagnoses (Prescription generation)
- Billing & Invoicing (Consultation fee tracking & PDF receipts)
- Insurance Claims Management
- Patient Lab Reports & Scans
- Real-time Audit Logs (Security & user activity tracking)

5. HOW TO RUN
------------------------------------------------------------------------
- Option A: IntelliJ IDEA / Eclipse
  1. Open the 'medicare-app' project folder.
  2. Configure a local Tomcat 9 server.
  3. Deploy the 'MedicalAppointmentSystem:war exploded' or 'dist/medicare-app.war' artifact.
  4. Context path: /medicare-app
  5. Open: http://localhost:8080/medicare-app/

- Option B: Terminal / Maven
  1. cd medicare-app
  2. .\mvnw.cmd clean package
  3. Deploy 'dist/medicare-app.war' or 'target/medicare-app.war' to Tomcat webapps.
  4. Open: http://localhost:8080/medicare-app/
========================================================================
