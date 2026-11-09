# Task Report — Patient Management

**Member:** Ambegoda S.P (`IT26100023`)  
**Branch:** `feature/1-patients`  
**Module:** Patient Management (Registration, Search, Update, Delete)

---

## 1. What I was responsible for
Responsible for complete patient profile lifecycle management. This allows the hospital front desk and online portal to register new patients, validate demographic and clinical history data, search records, update contact details, and securely delete patient profiles with administrative role checks.

## 2. Features Implemented
| # | Feature | Where |
|---|---|---|
| 1 | Patient Registration & Validation | `servlet/AddPatientServlet.java`, `util/Validation.java` |
| 2 | Patient Listing & Search | `webapp/patient-list.jsp`, `dao/PatientDAO.java` |
| 3 | Edit Patient Profile | `servlet/EditPatientServlet.java`, `webapp/edit-patient.jsp` |
| 4 | Secure Deletion (POST + Admin Role) | `servlet/DeletePatientServlet.java` |

## 3. Files I own
- `src/main/java/com/medicare/model/Patient.java`
- `src/main/java/com/medicare/dao/PatientDAO.java`
- `src/main/java/com/medicare/dao/impl/PatientDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/PatientDAODBImpl.java`
- `src/main/java/com/medicare/servlet/AddPatientServlet.java`
- `src/main/java/com/medicare/servlet/EditPatientServlet.java`
- `src/main/java/com/medicare/servlet/DeletePatientServlet.java`
- `src/main/webapp/patient-list.jsp`
- `src/main/webapp/add-patient.jsp`
- `src/main/webapp/edit-patient.jsp`

## 4. How it works
HTTP requests from `add-patient.jsp` are handled by `AddPatientServlet`. It parses input parameters with safe number format validation, builds a `Patient` model object extending `Person`, and invokes `DAOFactory.getPatientDAO().addPatient(patient)`. The concrete implementation (`PatientDAOFileImpl` in FILE mode or `PatientDAODBImpl` in DB mode) persists the record into `patients.txt` or the `patients` table.

```java
// Inheritance and Encapsulation in Patient
public class Patient extends Person {
    @Override
    public String getRoleLabel() { return "Patient"; }
    private String id;
    private String name;
    // ... private fields with public getters/setters
}
```

## 5. Storage (File & Database)
- **File:** `patients.txt` (UTF-8 TSV format)
- **DB Table:** `patients` (SELECT, INSERT, UPDATE, DELETE)

## 6. Testing
| Test | Steps | Expected | Result |
|---|---|---|---|
| Add Patient | Fill form in `add-patient.jsp` and submit | Saved to file/DB and redirected | Pass |
| Input Validation | Enter invalid age format | Clean error redirect, no crash | Pass |
| Unauthorized Delete | Delete without ADMIN role | Blocked with 403 / redirect | Pass |
