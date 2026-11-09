# Task Report — Doctor and Schedule Management

**Member:** Akalanka K.K.G.K (`IT26100803`)  
**Branch:** `feature/2-doctors`  
**Module:** Doctor Profiles and Published Availability Scheduling

---

## 1. What I was responsible for
Responsible for managing doctor profiles, medical specializations, consultation fees, and weekly clinic session availability. Enables administrators to add/update doctor details and configure recurring appointment time slots.

## 2. Features Implemented
| # | Feature | Where |
|---|---|---|
| 1 | Doctor Registration & Validation | `servlet/DoctorServlet.java`, `service/DoctorService.java` |
| 2 | Doctor Directory & Search | `webapp/list-doctors.jsp`, `dao/DoctorDAO.java` |
| 3 | Doctor Profile Update & Deletion | `servlet/DoctorServlet.java`, `webapp/edit-doctor.jsp` |
| 4 | Weekly Availability & Slot Generation | `servlet/AvailabilityServlet.java`, `service/ScheduleService.java` |

## 3. Files I own
- `src/main/java/com/medicare/model/Doctor.java`
- `src/main/java/com/medicare/model/Availability.java`
- `src/main/java/com/medicare/dao/DoctorDAO.java`
- `src/main/java/com/medicare/dao/impl/DoctorDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/DoctorDAODBImpl.java`
- `src/main/java/com/medicare/service/DoctorService.java`
- `src/main/java/com/medicare/service/ScheduleService.java`
- `src/main/java/com/medicare/servlet/DoctorServlet.java`
- `src/main/java/com/medicare/servlet/AvailabilityServlet.java`
- `src/main/webapp/list-doctors.jsp`
- `src/main/webapp/add-doctor.jsp`
- `src/main/webapp/edit-doctor.jsp`
- `src/main/webapp/availability.jsp`

## 4. How it works
`DoctorServlet` handles CRUD operations for doctors. When creating or updating a clinician, the consultation fee is validated with safe decimal parsing. `ScheduleService` calculates bookable time slots based on doctor availability start/end times and slot minutes interval.

```java
// Doctor inherits Person and encapsulates consultationFee
public class Doctor extends Person {
    @Override
    public String getRoleLabel() { return "Doctor"; }
    private double consultationFee;
    public double getConsultationFee() { return consultationFee; }
}
```

## 5. Storage (File & Database)
- **File:** `doctors.txt`, `availability.txt`
- **DB Table:** `doctors`, `clinic_availability`

## 6. Testing
| Test | Steps | Expected | Result |
|---|---|---|---|
| Add Doctor | Submit doctor form with specialty and fee | Doctor created with generated ID | Pass |
| Invalid Fee | Input non-numeric consultation fee | Gracefully redirected with error | Pass |
| Publish Slots | Set Mon-Fri 09:00-12:00 20 min slots | 9 slots per day generated | Pass |
