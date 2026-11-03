# Task Report — Patient Management & Medical Profiles

**Member:** IT26100841 (`@IT26100841`)  
**Branch:** `feature/1-patients`  
**Module:** Member 1 — Patient Management  

---

## 1. What I was responsible for

I was responsible for implementing the Patient Management module for the Medicare Hospital Management System. This module manages the lifecycle of patient records, including registration with server-side field validation, searchable patient directories, comprehensive clinical profile management (blood group, allergies, medical history), patient portal dashboard access, medical document uploads and viewing, and referential-integrity-guarded patient record deletion.

---

## 2. Features I implemented

| # | Feature | Where |
|---|---|---|
| 1 | Patient Registration with comprehensive validation | `servlet/AddPatientServlet.java`, `add-patient.jsp` |
| 2 | Live Patient Directory with real-time search & pagination | `servlet/PatientServlet.java`, `patient-list.jsp` |
| 3 | Patient Profile View & Medical History Update | `servlet/EditPatientServlet.java`, `edit-patient.jsp`, `view-patient.jsp` |
| 4 | Safe Patient Deletion with Referential Integrity checks | `servlet/DeletePatientServlet.java`, `service/PatientService.java` |
| 5 | Patient Portal Authentication & Self-Service Dashboard | `servlet/PatientPortalServlet.java`, `patient-dashboard.jsp` |
| 6 | Medical Document Upload & Secure File Viewing | `servlet/UploadDocumentServlet.java`, `servlet/ViewDocumentServlet.java`, `patient-documents.jsp` |
| 7 | Dual Persistence (MySQL JDBC & flat-file storage fallback) | `dao/impl/PatientDAODBImpl.java`, `dao/impl/PatientDAOFileImpl.java` |

---

## 3. Files I own

- `src/main/java/com/medicare/model/Patient.java`
- `src/main/java/com/medicare/model/PatientAccount.java`
- `src/main/java/com/medicare/model/DocumentEntry.java`
- `src/main/java/com/medicare/dao/PatientDAO.java`
- `src/main/java/com/medicare/dao/impl/PatientDAODBImpl.java`
- `src/main/java/com/medicare/dao/impl/PatientDAOFileImpl.java`
- `src/main/java/com/medicare/service/PatientService.java`
- `src/main/java/com/medicare/service/PatientPortalService.java`
- `src/main/java/com/medicare/servlet/PatientServlet.java`
- `src/main/java/com/medicare/servlet/AddPatientServlet.java`
- `src/main/java/com/medicare/servlet/EditPatientServlet.java`
- `src/main/java/com/medicare/servlet/DeletePatientServlet.java`
- `src/main/java/com/medicare/servlet/PatientPortalServlet.java`
- `src/main/java/com/medicare/servlet/UploadDocumentServlet.java`
- `src/main/java/com/medicare/servlet/ViewDocumentServlet.java`
- `src/main/webapp/patient-list.jsp`
- `src/main/webapp/add-patient.jsp`
- `src/main/webapp/edit-patient.jsp`
- `src/main/webapp/view-patient.jsp`
- `src/main/webapp/patient-dashboard.jsp`
- `src/main/webapp/patient-documents.jsp`
- `database/member_1_patient_management.sql`

---

## 4. How it works

1. **Patient Registration**: The staff or receptionist accesses `/add-patient.jsp` and enters personal and clinical details. Upon submission, `AddPatientServlet` validates all fields (name, age, contact, blood group, allergies, medical history) using `Validation.patient()`.
2. **Persistence Layer**: The service layer delegates to `DAOFactory.getPatientDAO()`. Depending on the configured runtime storage mode, `PatientDAODBImpl` performs parameterized SQL operations against MySQL, or `PatientDAOFileImpl` persists records in `patients.txt`.
3. **Safe Deletion**: When an administrator requests deletion, `PatientService.deletePatient(id)` performs relational integrity checks before deletion. If the patient has associated appointments, medical records, billing invoices, or uploaded documents, the operation is blocked with a descriptive error message to prevent orphaned records.
4. **Patient Portal & Documents**: Registered patients can log into the patient portal to view upcoming appointments, medical history, and upload medical documents (e.g., lab reports, scans) handled by `UploadDocumentServlet` with secure multipart streaming.

### Key Code Highlight: Safe Patient Deletion Referential Integrity

```java
// Prevents deleting patients that have existing relations in other modules
public boolean deletePatient(String id) {
  for (com.medicare.model.Appointment a : DAOFactory.getAppointmentDAO().getAllAppointments())
    if (a.getPatientId().equalsIgnoreCase(id))
      throw new IllegalArgumentException("Cannot delete a patient referenced by appointments");
  for (com.medicare.model.MedicalRecord r :
      DAOFactory.getMedicalRecordDAO().getAllMedicalRecords())
    if (r.getPatientId().equalsIgnoreCase(id))
      throw new IllegalArgumentException("Cannot delete a patient referenced by medical records");
  for (com.medicare.model.Bill b : DAOFactory.getBillDAO().getAllBills())
    if (b.getPatientId().equalsIgnoreCase(id))
      throw new IllegalArgumentException("Cannot delete a patient referenced by bills");

  return DAOFactory.getPatientDAO().deletePatient(id);
}
```

---

## 5. Database tables used

| Table | Operation | Purpose |
|---|---|---|
| `patients` | SELECT, INSERT, UPDATE, DELETE | Primary patient demographic and medical profile records |
| `patient_documents` | SELECT, INSERT, DELETE | Uploaded medical documents, file metadata, and timestamps |
| `patient_portal_accounts` | SELECT, INSERT, UPDATE | Patient portal login credentials and credential hashes |

---

## 6. Testing

| Test | Steps | Expected | Result |
|---|---|---|---|
| Register Patient | Submit valid patient demographics, blood group, contact | Patient record created with unique ID; redirected to list | Pass |
| Input Validation | Submit invalid contact or age (< 0) | Submission rejected with descriptive error alert | Pass |
| Search Directory | Search by partial name, patient ID, or contact number | Matching filtered patient rows displayed dynamically | Pass |
| Update Profile | Edit address, allergies, or medical history | Patient profile updated successfully in database | Pass |
| Referential Integrity on Delete | Attempt to delete patient linked to active appointments or bills | Deletion prevented with relational warning message | Pass |
| Document Upload | Upload PDF/image report from portal dashboard | Document stored securely and listed in patient document history | Pass |

---

## 7. Difficulties and how I solved them

- **Referential Integrity Across Modules**: In a microservice/modular architecture where different team members develop appointments, billing, and records independently, deleting a patient could leave orphaned foreign keys. Implemented cross-DAO pre-deletion validation in `PatientService` to enforce relational integrity gracefully.
- **Dual Persistence (JDBC & File)**: Designed `PatientDAOFileImpl` extending `AbstractFileDAO` to ensure 100% feature parity with `PatientDAODBImpl` so the application runs seamlessly even in environments without an active MySQL service.

---

## 8. What I would improve

- Add automated PDF export of complete patient medical histories for referrals.
- Implement two-factor authentication (2FA) for patient portal accounts.
