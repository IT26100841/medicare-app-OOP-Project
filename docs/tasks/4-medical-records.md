# Task Report — Medical Records and Prescriptions

**Member:** Dimath A.M.S (`IT26100764`)  
**Branch:** `update/latest-medicare`  
**Module:** Clinical Notes, Diagnosis, Patient Medical History & Prescription PDF

---

## 1. What I was responsible for
Responsible for clinical medical records, doctor diagnosis notes, prescription authoring, patient history tracking, and printable prescription document generation.

## 2. Features Implemented
| # | Feature | Where |
|---|---|---|
| 1 | Create Medical Record & Prescription | `servlet/MedicalRecordServlet.java`, `service/MedicalRecordService.java` |
| 2 | Medical Record History Search | `webapp/medical-record-list.jsp`, `dao/MedicalRecordDAO.java` |
| 3 | Doctor Authorization Guards | `service/VisitService.java` |
| 4 | Printable Clinical Prescription | `servlet/PrescriptionPDFServlet.java`, `views/print-clinical.jsp` |

## 3. Files I own
- `src/main/java/com/medicare/model/MedicalRecord.java`
- `src/main/java/com/medicare/dao/MedicalRecordDAO.java`
- `src/main/java/com/medicare/dao/impl/MedicalRecordDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/MedicalRecordDAODBImpl.java`
- `src/main/java/com/medicare/service/MedicalRecordService.java`
- `src/main/java/com/medicare/servlet/MedicalRecordServlet.java`
- `src/main/java/com/medicare/servlet/PrescriptionPDFServlet.java`
- `src/main/webapp/medical-record-list.jsp`
- `src/main/webapp/add-medical-record.jsp`
- `src/main/webapp/edit-medical-record.jsp`

## 4. How it works
During an active consultation, the assigned clinician submits clinical findings via `MedicalRecordServlet`. `VisitService.requireDoctor()` guarantees that only the assigned doctor can add or edit medical records for that visit. The diagnosis and prescription details are encapsulated within `MedicalRecord` and persisted to `medical_records.txt` or `medical_records` table.

```java
// Encapsulation of patient medical findings
public class MedicalRecord {
    private int recordId;
    private String patientId;
    private String doctorId;
    private int appointmentId;
    private String diagnosis;
    private String prescription;
    // Getters and Setters
}
```

## 5. Storage (File & Database)
- **File:** `medical_records.txt`
- **DB Table:** `medical_records`

## 6. Testing
| Test | Steps | Expected | Result |
|---|---|---|---|
| Add Clinical Record | Enter diagnosis and prescription details | Record persisted and linked to appointment | Pass |
| Doctor Check | Non-assigned clinician edits record | Blocked with security exception | Pass |
| Print Prescription | Click print on completed record | Printable JSP rendered cleanly | Pass |
