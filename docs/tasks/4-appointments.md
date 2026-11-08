# Task Report — Appointment Scheduling & Conflict Detection

**Member:** IT26100802 (`@IT26100802`)  
**Branch:** `feature/3-appointments` (or `IT26100802/appointment`)  
**Module:** Member 3 — Appointment Management  

---

## 1. What I was responsible for

I was responsible for implementing the complete Appointment Management module for the Medicare Hospital Management System. This module handles patient appointment booking, doctor schedule conflict detection (preventing overlapping appointments for the same doctor in the same timeslot), appointment rescheduling, cancellations with automatic slot release, and patient visit tracking.

---

## 2. Features I implemented

| # | Feature | Where |
|---|---|---|
| 1 | Appointment Booking with dynamic slot selection | `servlet/AppointmentServlet.java`, `book-appointment.jsp` |
| 2 | Conflict Detection (Double-booking prevention per doctor & slot) | `service/AppointmentService.java` |
| 3 | Live appointment directory, search, and status filtering | `appointment-list.jsp`, `servlet/AppointmentServlet.java` |
| 4 | Appointment Rescheduling / Modification | `servlet/AppointmentServlet.java`, `edit-appointment.jsp` |
| 5 | Cancellation with confirmation and slot release | `servlet/AppointmentServlet.java`, `cancel-appointment.jsp` |
| 6 | Patient Visit History tracking | `service/VisitService.java`, `WEB-INF/views/visit-rows.jspf` |
| 7 | Dual persistence (MySQL database & fallback file storage) | `dao/impl/AppointmentDAODBImpl.java`, `dao/impl/AppointmentDAOFileImpl.java` |

---

## 3. Files I own

- `src/main/java/com/medicare/model/Appointment.java`
- `src/main/java/com/medicare/model/AppointmentStatus.java`
- `src/main/java/com/medicare/dao/AppointmentDAO.java`
- `src/main/java/com/medicare/dao/impl/AppointmentDAODBImpl.java`
- `src/main/java/com/medicare/dao/impl/AppointmentDAOFileImpl.java`
- `src/main/java/com/medicare/service/AppointmentService.java`
- `src/main/java/com/medicare/service/VisitService.java`
- `src/main/java/com/medicare/servlet/AppointmentServlet.java`
- `src/main/java/com/medicare/servlet/WorkflowServlet.java`
- `src/main/webapp/appointment-list.jsp`
- `src/main/webapp/book-appointment.jsp`
- `src/main/webapp/edit-appointment.jsp`
- `src/main/webapp/cancel-appointment.jsp`
- `src/main/webapp/WEB-INF/views/visit-rows.jspf`
- `database/member_3_appointment_management.sql`

---

## 4. How it works

1. **Booking Flow**: A patient or receptionist navigates to `/book-appointment.jsp` or sends a `POST` request to `AppointmentServlet` with action `book`. The servlet validates required parameters (patient ID, doctor ID, date, time slot, notes).
2. **Conflict Checking**: Before persisting the appointment, `AppointmentService.checkConflict(doctorId, date, timeSlot)` verifies that the doctor does not already have an active appointment scheduled for the exact same date and timeslot.
3. **Persistence**: Depending on the configured persistence layer, `AppointmentDAODBImpl` saves the record into the `appointments` MySQL table, or `AppointmentDAOFileImpl` writes to the file-based store.
4. **Reschedule & Cancel**: Actions `edit` and `cancel` allow updating appointment timing or setting status to `CANCELLED`, freeing up the schedule for other patients.

### Key Code Highlight: Conflict Detection

```java
// Validates that doctor has no conflicting active appointment
public boolean hasConflict(int doctorId, LocalDate appointmentDate, String timeSlot, Integer excludeAppointmentId) {
    List<Appointment> doctorAppointments = appointmentDAO.findByDoctorIdAndDate(doctorId, appointmentDate);
    return doctorAppointments.stream()
            .filter(a -> a.getStatus() != AppointmentStatus.CANCELLED)
            .filter(a -> excludeAppointmentId == null || a.getAppointmentId() != excludeAppointmentId)
            .anyMatch(a -> a.getTimeSlot().equalsIgnoreCase(timeSlot));
}
```

---

## 5. Database tables used

| Table | Operation | Purpose |
|---|---|---|
| `appointments` | SELECT, INSERT, UPDATE, DELETE | Primary appointment records including status, doctorId, patientId, date, timeSlot |

---

## 6. Testing

| Test | Steps | Expected | Result |
|---|---|---|---|
| Book Appointment | Submit valid patient, doctor, future date, and time slot | Appointment created with status `BOOKED` | Pass |
| Conflict Detection | Attempt to book same doctor on same date & time slot | Booking rejected with clear collision error message | Pass |
| Reschedule | Edit existing appointment to an available slot | Time slot updated successfully | Pass |
| Cancel Appointment | Cancel booked appointment | Status changed to `CANCELLED`, slot becomes free | Pass |
| Search & Filter | Filter appointment list by status and doctor | Matching appointment rows displayed | Pass |

---

## 7. Difficulties and how I solved them

- **Preventing Double Booking**: Ensured edge cases such as rescheduling to the same slot don't falsely trigger conflict detection by passing the current appointment ID as an exclusion parameter.
- **Dual Persistence Consistency**: Synchronized DAO interfaces between JDBC MySQL implementation and file-based implementation so that the application seamlessly switches based on environment configuration.

---

## 8. What I would improve

- Integrate real-time SMS / Email notifications when an appointment is confirmed or rescheduled.
- Add recurring appointment booking for ongoing therapies or treatments.
