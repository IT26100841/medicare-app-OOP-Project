========================================================================
MEDICARE HOSPITAL MANAGEMENT SYSTEM - WD 51 GROUP PROJECT
========================================================================

1. OVERVIEW
------------------------------------------------------------------------
Medicare is a full-featured Java Servlet & JSP web application designed
for hospital management, doctor scheduling, patient clinical records, 
appointment bookings with automated conflict detection, and billing.

2. DATABASE SETUP
------------------------------------------------------------------------
- SQL File: medicare_db.sql (Included in this package)
- Database Name: medicare_db
- How to import:
  * Using phpMyAdmin / XAMPP:
    1. Create a database named 'medicare_db'.
    2. Click 'Import' and select 'medicare_db.sql'.
    3. Click 'Go'.
  * Using MySQL CLI:
    mysql -u root -p < medicare_db.sql

- Database configuration file in source code:
  src/main/java/com/medicare/util/DBConnection.java
  (Default: jdbc:mysql://localhost:3306/medicare_db, User: root, Password: "")

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
  3. Deploy the 'MedicalAppointmentSystem:war exploded' artifact.
  4. Context path: /medicare-app
  5. Open: http://localhost:8080/medicare-app/

- Option B: Terminal / Maven
  1. cd medicare-app
  2. ./mvnw clean package
  3. Deploy 'target/MedicalAppointmentSystem-1.0-SNAPSHOT.war' to Tomcat webapps.
  4. Open: http://localhost:8080/medicare-app/
========================================================================
