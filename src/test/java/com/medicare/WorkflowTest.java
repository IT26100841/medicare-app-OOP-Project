package com.medicare;

import static org.junit.Assert.*;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import com.medicare.util.*;
import java.nio.file.*;
import java.time.*;
import java.util.*;
import org.junit.*;

public class WorkflowTest {
  private Path data;
  private final User admin = new User(1, "admin", "password123", "ADMIN"),
      doctor = new User(2, "doctor", "password123", "DOCTOR"),
      staff = new User(3, "staff", "password123", "STAFF");

  @Before
  public void setup() throws Exception {
    data = Files.createTempDirectory("clinic-workflow-");
    System.setProperty("medicare.data.dir", data.toString());
    DAOFactory.setStorageMode("FILE");
    DAOFactory.getPatientDAO()
        .addPatient(
            new Patient(
                "P1",
                "Patient",
                "p@example.com",
                21,
                "Other",
                "0700000000",
                "Address",
                "O+",
                "None",
                ""));
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor("D1", "Doctor", "General", "MBBS", "0700000001", "d@example.com", 2500));
    ClinicStore.bind(2, "D1");
  }

  @After
  public void cleanup() throws Exception {
    try (var files = Files.walk(data)) {
      files
          .sorted(Comparator.reverseOrder())
          .forEach(
              p -> {
                try {
                  Files.delete(p);
                } catch (Exception e) {
                  throw new RuntimeException(e);
                }
              });
    }
  }

  private Availability session(int day, String start, String end, int minutes) {
    Availability a = new Availability();
    a.setDoctorId("D1");
    a.setDayOfWeek(day);
    a.setStartTime(start);
    a.setEndTime(end);
    a.setSlotMinutes(minutes);
    return a;
  }

  private Appointment visit() {
    Appointment a =
        new Appointment("P1", "D1", LocalDate.now().toString(), "09:00", "Sample visit", "Booked");
    assertTrue(DAOFactory.getAppointmentDAO().addAppointment(a));
    return a;
  }

  private void expectFailure(Runnable r) {
    try {
      r.run();
      fail("Expected failure");
    } catch (IllegalArgumentException | SecurityException expected) {
    }
  }

  @Test
  public void schedulesValidateAndRejectOverlap() {
    ScheduleService service = new ScheduleService();
    assertTrue(service.save(session(1, "09:00", "12:00", 20)));
    expectFailure(() -> service.save(session(1, "11:00", "13:00", 20)));
    expectFailure(() -> service.save(session(8, "09:00", "12:00", 20)));
    expectFailure(() -> service.save(session(2, "12:00", "09:00", 20)));
    expectFailure(() -> service.save(session(2, "09:00", "12:00", 0)));
  }

  @Test
  public void scheduleCrud() {
    ScheduleService s = new ScheduleService();
    Availability a = session(1, "09:00", "12:00", 20);
    assertTrue(s.save(a));
    a.setEndTime("13:00");
    assertTrue(s.save(a));
    assertEquals("13:00", s.list().get(0).getEndTime());
    assertTrue(s.delete(a.getId()));
    assertTrue(s.list().isEmpty());
  }

  @Test
  public void slotsFollowDurationAndExcludeBookings() {
    LocalDate day = LocalDate.now().plusDays(1);
    ScheduleService service = new ScheduleService();
    service.save(session(day.getDayOfWeek().getValue(), "09:00", "10:00", 20));
    assertEquals(Arrays.asList("09:00", "09:20", "09:40"), service.slots("D1", day.toString(), 0));
    Appointment a = new Appointment("P1", "D1", day.toString(), "09:20", "Test", "Booked");
    new AppointmentService().addAppointment(a);
    assertEquals(Arrays.asList("09:00", "09:40"), service.slots("D1", day.toString(), 0));
    assertEquals(3, service.slots("D1", day.toString(), a.getAppointmentId()).size());
    assertFalse(service.scheduled("D1", day.toString(), "09:10"));
  }

  @Test
  public void bookOutsidePublishedScheduleIsRejected() {
    Appointment a =
        new Appointment(
            "P1", "D1", LocalDate.now().plusDays(1).toString(), "09:00", "Test", "Booked");
    expectFailure(() -> new AppointmentService().addAppointment(a));
  }

  @Test
  public void stateMachineDoesNotSkipCare() {
    Appointment a = visit();
    VisitService service = new VisitService();
    expectFailure(
        () -> service.transition(a.getAppointmentId(), AppointmentStatus.COMPLETED, admin));
    expectFailure(
        () -> service.transition(a.getAppointmentId(), AppointmentStatus.CHECKED_IN, doctor));
    service.transition(a.getAppointmentId(), AppointmentStatus.CHECKED_IN, staff);
    expectFailure(
        () -> service.transition(a.getAppointmentId(), AppointmentStatus.IN_CONSULTATION, staff));
    service.transition(a.getAppointmentId(), AppointmentStatus.IN_CONSULTATION, doctor);
    expectFailure(
        () -> service.transition(a.getAppointmentId(), AppointmentStatus.COMPLETED, doctor));
  }

  @Test
  public void doctorOwnershipEnforced() {
    ClinicStore.bind(2, null);
    Appointment a = visit();
    VisitService s = new VisitService();
    s.transition(a.getAppointmentId(), AppointmentStatus.CHECKED_IN, staff);
    expectFailure(
        () -> s.transition(a.getAppointmentId(), AppointmentStatus.IN_CONSULTATION, doctor));
    assertEquals(
        "Checked-in",
        DAOFactory.getAppointmentDAO().getAppointmentById(a.getAppointmentId()).getStatus());
  }

  @Test
  public void futureVisitCannotCheckIn() {
    Appointment a =
        new Appointment(
            "P1", "D1", LocalDate.now().plusDays(1).toString(), "09:00", "Test", "Booked");
    DAOFactory.getAppointmentDAO().addAppointment(a);
    expectFailure(
        () ->
            new VisitService()
                .transition(a.getAppointmentId(), AppointmentStatus.CHECKED_IN, staff));
  }

  @Test
  public void consultationToPaymentWorkflow() {
    Appointment a = visit();
    VisitService s = new VisitService();
    s.transition(a.getAppointmentId(), AppointmentStatus.CHECKED_IN, staff);
    s.transition(a.getAppointmentId(), AppointmentStatus.IN_CONSULTATION, doctor);
    MedicalRecord r =
        new MedicalRecord(
            "P1",
            "D1",
            a.getAppointmentId(),
            "Assessment, sample",
            "Sample note",
            "",
            LocalDate.now().toString());
    assertTrue(new MedicalRecordService().addMedicalRecord(r));
    s.transition(a.getAppointmentId(), AppointmentStatus.COMPLETED, doctor);
    BillingService billing = new BillingService();
    Bill b = billing.create(a.getAppointmentId());
    assertEquals(2500, b.getAmount(), .001);
    assertEquals("Unpaid", b.getPaymentStatus());
    expectFailure(() -> billing.create(a.getAppointmentId()));
    billing.pay(b.getBillId(), "Card");
    assertEquals("Paid", DAOFactory.getBillDAO().getBillById(b.getBillId()).getPaymentStatus());
    expectFailure(() -> billing.pay(b.getBillId(), "Card"));
    expectFailure(() -> new MedicalRecordService().deleteMedicalRecord(r.getRecordId()));
  }

  @Test
  public void noInvoiceBeforeCompletion() {
    Appointment a = visit();
    expectFailure(() -> new BillingService().create(a.getAppointmentId()));
  }

  @Test
  public void scheduleChangesDoNotInvalidateBookedSessions() {
    Appointment a = visit();
    ScheduleService s = new ScheduleService();
    Availability schedule =
        session(LocalDate.now().getDayOfWeek().getValue(), "09:00", "12:00", 20);
    s.save(schedule);
    expectFailure(() -> s.delete(schedule.getId()));
    schedule.setEndTime("10:00");
    expectFailure(() -> s.save(schedule));
  }

  @Test
  public void duplicatePatientSlotsAcrossDoctorsRejected() {
    Appointment a = visit();
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor("D2", "Other", "General", "", "0700000003", "other@example.com", 3000));
    Appointment duplicate =
        new Appointment(
            "P1", "D2", a.getAppointmentDate(), a.getAppointmentTime(), "Test", "Booked");
    expectFailure(() -> DAOFactory.getAppointmentDAO().addAppointment(duplicate));
  }
}
