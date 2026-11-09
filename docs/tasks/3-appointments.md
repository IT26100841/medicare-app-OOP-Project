# Task Report — Appointment and Visit Workflow

**Member:** Wickramasinghe V.I. (`IT26100802`)  
**Branch:** `IT26100802/appointment`  
**Module:** Appointment Booking, Rescheduling, and Clinical Visit Workflow

---

## 1. What I was responsible for
Responsible for appointment scheduling, conflict detection, rescheduling, cancellations, and the clinical state transition workflow (Booked → Checked-in → In consultation → Completed).

## 2. Features Implemented
| # | Feature | Where |
|---|---|---|
| 1 | Book Appointment & Conflict Prevention | `servlet/AppointmentServlet.java`, `service/AppointmentService.java` |
| 2 | Appointment Listing & Filtering | `webapp/appointment-list.jsp`, `dao/AppointmentDAO.java` |
| 3 | Rescheduling & Cancellation | `servlet/AppointmentServlet.java`, `model/AppointmentStatus.java` |
| 4 | Visit State Machine Transitions | `servlet/WorkflowServlet.java`, `service/VisitService.java` |

## 3. Files I own
- `src/main/java/com/medicare/model/Appointment.java`
- `src/main/java/com/medicare/model/AppointmentStatus.java`
- `src/main/java/com/medicare/dao/AppointmentDAO.java`
- `src/main/java/com/medicare/dao/impl/AppointmentDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/AppointmentDAODBImpl.java`
- `src/main/java/com/medicare/service/AppointmentService.java`
- `src/main/java/com/medicare/service/VisitService.java`
- `src/main/java/com/medicare/servlet/AppointmentServlet.java`
- `src/main/java/com/medicare/servlet/WorkflowServlet.java`
- `src/main/webapp/appointment-list.jsp`
- `src/main/webapp/book-appointment.jsp`
- `src/main/webapp/edit-appointment.jsp`

## 4. How it works
When booking an appointment, `AppointmentService.isDoctorSlotAvailable()` verifies that the clinician does not already have an active appointment for the requested time. The state transitions are strictly governed by `AppointmentStatus.canMoveTo()`, ensuring an appointment cannot jump invalid states (e.g. Booked cannot jump directly to Completed without Check-in).

```java
// State transition control
public boolean canMoveTo(AppointmentStatus next) {
    if (this == next) return false;
    if (this == BOOKED) return next == CHECKED_IN || next == CANCELLED || next == NO_SHOW;
    if (this == CHECKED_IN) return next == IN_CONSULTATION || next == CANCELLED;
    return this == IN_CONSULTATION && next == COMPLETED;
}
```

## 5. Storage (File & Database)
- **File:** `appointments.txt`
- **DB Table:** `appointments`

## 6. Testing
| Test | Steps | Expected | Result |
|---|---|---|---|
| Slot Conflict | Book 2 appointments for same doc at 10:00 | Second booking rejected with alert | Pass |
| State Flow | Check-in -> Start Consult -> Complete | Status updates correctly | Pass |
| Invalid Jump | Attempt to complete Booked visit directly | Blocked by state check | Pass |
