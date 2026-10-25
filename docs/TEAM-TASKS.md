# Team & Task Allocation

**Project:** Medicare — Hospital Management System
**Module:** WD 51 group project
**Members:** 6

This file is the single source of truth for **who owns what**. If two members
edit the same file, you will get merge conflicts — check here first.

> Replace every `Member N` and `@username` with the real name and GitHub
> username before you submit.

---

## 1. Core, Authentication, Security & Audit

| | |
| --- | --- |
| **Member** | Member 1 — `@username` |
| **Branch** | `feature/1-core-auth` |
| **Task report** | `docs/tasks/1-core-auth.md` |

**Responsibility:** project setup and build, database connection, user accounts,
login/logout, session handling, role-based access control, password change,
settings, audit logging, shared dashboard.

| Area | Files |
| --- | --- |
| Build & config | `pom.xml`, `.gitignore`, `.gitattributes`, `mvnw`, `mvnw.cmd`, `.mvn/` |
| Database | `medicare_db.sql`, `src/main/java/com/medicare/util/DBConnection.java` |
| Security | `util/AuditLogger.java`, `filter/AdminAuthFilter.java` |
| User model | `model/User.java` |
| User persistence | `dao/UserDAO.java`, `dao/impl/UserDAODBImpl.java`, `dao/impl/UserDAOFileImpl.java` |
| User logic | `service/UserService.java`, `factory/DAOFactory.java` |
| Servlets | `servlet/LoginServlet.java`, `servlet/LogoutServlet.java`, `servlet/ChangePasswordServlet.java`, `servlet/SettingsServlet.java` |
| Views | `webapp/index.jsp`, `login.jsp`, `register.jsp`, `dashboard.jsp`, `change-password.jsp`, `settings.jsp`, `audit-logs.jsp`, `WEB-INF/web.xml` |

**Key deliverables**

- Maven `war` build that deploys cleanly on Tomcat 9
- Importable `medicare_db.sql` schema with seed users
- Login, logout, registration, password change
- `AdminAuthFilter` blocking non-admin routes
- Audit log written on security-relevant actions

---

## 2. Patient Management

| | |
| --- | --- |
| **Member** | Member 2 — `@username` |
| **Branch** | `feature/2-patients` |
| **Task report** | `docs/tasks/2-patients.md` |

**Responsibility:** patient directory, create/read/update/delete, medical
history, blood group, allergies, patient portal view.

| Area | Files |
| --- | --- |
| Model | `model/Patient.java` |
| Persistence | `dao/PatientDAO.java`, `dao/impl/PatientDAODBImpl.java`, `dao/impl/PatientDAOFileImpl.java` |
| Service | `service/PatientService.java` |
| Servlets | `servlet/PatientServlet.java`, `servlet/AddPatientServlet.java`, `servlet/EditPatientServlet.java`, `servlet/DeletePatientServlet.java` |
| Views | `webapp/patient-list.jsp`, `add-patient.jsp`, `edit-patient.jsp`, `view-patient.jsp`, `patient-dashboard.jsp` |

**Key deliverables**

- Searchable patient list
- Add / edit / delete with server-side validation
- Patient profile page: blood group, allergies, medical history
- Delete guarded by a confirmation step

---

## 3. Doctor Management

| | |
| --- | --- |
| **Member** | Member 3 — `@username` |
| **Branch** | `feature/3-doctors` |
| **Task report** | `docs/tasks/3-doctors.md` |

**Responsibility:** doctor directory, specialisations, consultation fees,
weekly availability, doctor portal dashboard.

| Area | Files |
| --- | --- |
| Model | `model/Doctor.java` |
| Persistence | `dao/DoctorDAO.java`, `dao/impl/DoctorDAODBImpl.java`, `dao/impl/DoctorDAOFileImpl.java` |
| Service | `service/DoctorService.java` |
| Servlets | `servlet/DoctorServlet.java` |
| Views | `webapp/list-doctors.jsp`, `add-doctor.jsp`, `edit-doctor.jsp`, `view-doctor.jsp`, `doctor-dashboard.jsp` |

**Key deliverables**

- Doctor directory with specialisation and fee columns
- Add / edit doctor
- Availability data consumed by the appointment module
- Doctor dashboard showing that doctor's own appointments

---

## 4. Appointment Scheduling & Conflict Detection

| | |
| --- | --- |
| **Member** | Member 4 — `@username` |
| **Branch** | `feature/4-appointments` |
| **Task report** | `docs/tasks/4-appointments.md` |

**Responsibility:** booking, listing, searching and filtering, rescheduling,
cancellation, and the double-booking conflict rule.

| Area | Files |
| --- | --- |
| Model | `model/Appointment.java` |
| Persistence | `dao/AppointmentDAO.java`, `dao/impl/AppointmentDAODBImpl.java`, `dao/impl/AppointmentDAOFileImpl.java` |
| Service | `service/AppointmentService.java` |
| Servlets | `servlet/AppointmentServlet.java` |
| Views | `webapp/book-appointment.jsp`, `appointment-list.jsp`, `edit-appointment.jsp`, `cancel-appointment.jsp` |

**Key deliverables**

- Booking form with doctor, patient, date and time selectors
- Conflict detection: same doctor cannot hold two appointments in one slot
- Live keyword search and status filter (Booked / Completed / Cancelled)
- Reschedule and cancel; cancellation releases the slot
- Clear, user-facing error when a slot is taken (not a stack trace)

---

## 5. Medical Records, Prescriptions & Documents

| | |
| --- | --- |
| **Member** | Member 5 — `@username` |
| **Branch** | `feature/5-records` |
| **Task report** | `docs/tasks/5-records.md` |

**Responsibility:** clinical records, diagnoses, prescriptions and PDF export,
lab report/scan upload and viewing, in-app notifications.

| Area | Files |
| --- | --- |
| Models | `model/MedicalRecord.java`, `model/Notification.java` |
| Persistence | `dao/MedicalRecordDAO.java`, `dao/impl/MedicalRecordDAODBImpl.java`, `dao/impl/MedicalRecordDAOFileImpl.java`, `dao/NotificationDAO.java`, `dao/impl/NotificationDAODBImpl.java` |
| Service | `service/MedicalRecordService.java` |
| Servlets | `servlet/MedicalRecordServlet.java`, `servlet/PrescriptionPDFServlet.java`, `servlet/UploadDocumentServlet.java`, `servlet/ViewDocumentServlet.java` |
| Views | `webapp/medical-record-list.jsp`, `add-medical-record.jsp`, `patient-documents.jsp`, `notifications.jsp` |

**Key deliverables**

- Diagnosis and prescription entry per patient
- Prescription PDF download
- Document upload with type/size validation, secure view by id
- Notifications list for the logged-in user

---

## 6. Billing, Insurance & Pharmacy

| | |
| --- | --- |
| **Member** | Member 6 — `@username` |
| **Branch** | `feature/6-billing` |
| **Task report** | `docs/tasks/6-billing.md` |

**Responsibility:** invoices, consultation fee tracking, PDF receipts, insurance
claims, pharmacy/medicine service.

| Area | Files |
| --- | --- |
| Model | `model/Bill.java` |
| Persistence | `dao/BillDAO.java`, `dao/impl/BillDAODBImpl.java` |
| Service | `service/PharmacyService.java` |
| Servlets | `servlet/BillServlet.java`, `servlet/BillPDFServlet.java`, `servlet/InsuranceClaimServlet.java` |
| Views | `webapp/bill-list.jsp`, `create-bill.jsp`, `insurance-claims.jsp` |

**Key deliverables**

- Create invoice from a patient appointment
- Bill list with paid/unpaid status
- PDF receipt download
- Insurance claim submission and status tracking

---

## Shared files (touch with care)

These are read by more than one module. Announce the change in the group chat
before editing, and keep the edit minimal.

| File | Used by |
| --- | --- |
| `pom.xml` | everyone |
| `medicare_db.sql` | everyone — schema changes need agreement |
| `util/DBConnection.java` | every DAO |
| `factory/DAOFactory.java` | every service |
| `WEB-INF/web.xml` | deployment config |

**Unused file:** `src/main/java/com/medicare/medicareapp/HelloServlet.java` is a
leftover project template that is not mapped to any route. Member 1 may delete it.

---

## Contribution checklist per member

- [ ] Real name and GitHub username filled in above and in `README.md`
- [ ] Branch created from `main` with the name listed above
- [ ] Task report written at `docs/tasks/<branch>.md`
- [ ] Only files from your own module touched (or shared-file change announced)
- [ ] Commit author name/email match your GitHub account
- [ ] Pull request opened against `main` and merged
- [ ] `git log --author="<your name>"` shows your commits
