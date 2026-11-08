package com.medicare;

import static org.junit.Assert.*;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import java.nio.file.*;
import java.time.*;
import org.junit.*;

public class ReviewFixTest {
  private Path dir;

  @Before
  public void setup() throws Exception {
    dir = Files.createTempDirectory("review-fixes-");
    System.setProperty("medicare.data.dir", dir.toString());
    DAOFactory.setStorageMode("FILE");
    DAOFactory.getPatientDAO().addPatient(new Patient("P1", "Patient", 22, "Other", "0700000000"));
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor("D1", "Doctor", "General", "MBBS", "0700000000", "d@example.com", 2500));
    for (int day = 1; day <= 7; day++) {
      Availability a = new Availability();
      a.setDoctorId("D1");
      a.setDayOfWeek(day);
      a.setStartTime("09:00");
      a.setEndTime("10:00");
      a.setSlotMinutes(20);
      new ScheduleService().save(a);
    }
  }

  private Appointment booked() {
    Appointment a =
        new Appointment(
            "P1", "D1", LocalDate.now().plusDays(1).toString(), "09:00", "Checkup", "Booked");
    assertTrue(new AppointmentService().addAppointment(a));
    return a;
  }

  @Test
  public void cancelledVisitCannotBeResurrected() {
    Appointment a = booked();
    new AppointmentService().cancelAppointment(a.getAppointmentId());
    a.setStatus("Checked-in");
    try {
      DAOFactory.getAppointmentDAO().updateAppointment(a);
      fail();
    } catch (IllegalArgumentException expected) {
    }
    assertEquals(
        "Cancelled",
        DAOFactory.getAppointmentDAO().getAppointmentById(a.getAppointmentId()).getStatus());
  }

  @Test
  public void pastRescheduleRejected() {
    Appointment a = booked();
    a.setAppointmentDate(LocalDate.now().minusDays(1).toString());
    try {
      new AppointmentService().updateAppointment(a);
      fail();
    } catch (IllegalArgumentException expected) {
    }
    assertEquals(
        LocalDate.now().plusDays(1).toString(),
        new AppointmentService().getAppointmentById(a.getAppointmentId()).getAppointmentDate());
  }

  @Test
  public void notificationsExactlyOnce() {
    Appointment a = booked();
    assertEquals(1, DAOFactory.getNotificationDAO().getAllNotifications().size());
    assertTrue(new AppointmentService().cancelAppointment(a.getAppointmentId()));
    assertEquals(2, DAOFactory.getNotificationDAO().getAllNotifications().size());
    assertTrue(new AppointmentService().cancelAppointment(a.getAppointmentId()));
    assertEquals(2, DAOFactory.getNotificationDAO().getAllNotifications().size());
  }

  @Test
  public void failedNotificationRollsBackBooking() throws Exception {
    Files.createDirectory(dir.resolve("notifications.txt"));
    try {
      booked();
      fail();
    } catch (IllegalStateException expected) {
    }
    assertTrue(DAOFactory.getAppointmentDAO().getAllAppointments().isEmpty());
  }

  @Test
  public void invalidDoctorDoesNotCreateAccount() {
    User u = new User(0, "newdoctor", "Password123", "DOCTOR");
    try {
      new AccountService().save(u, false, "missing");
      fail();
    } catch (IllegalArgumentException expected) {
    }
    assertNull(DAOFactory.getUserDAO().getUserByUsername("newdoctor"));
  }

  @Test
  public void accountAndLinkLifecycle() {
    User u = new User(0, "linked", "Password123", "DOCTOR");
    AccountService s = new AccountService();
    s.save(u, false, "D1");
    assertEquals("D1", ClinicStore.doctorFor(u.getId()));
    u.setRole("STAFF");
    s.save(u, true, "D1");
    assertNull(ClinicStore.doctorFor(u.getId()));
    s.delete(u.getId());
    assertNull(DAOFactory.getUserDAO().getUserById(u.getId()));
  }

  @Test
  public void fileAccountSaveRollsBackOnLinkFailure() throws Exception {
    Files.createDirectory(dir.resolve("doctor_accounts.txt"));
    User u = new User(0, "rollback", "Password123", "DOCTOR");
    try {
      new AccountService().save(u, false, "D1");
      fail();
    } catch (IllegalStateException expected) {
    }
    assertNull(DAOFactory.getUserDAO().getUserByUsername("rollback"));
  }

  @Test
  public void deletionRemovesUnusedPortalAccount() {
    Patient p =
        new Patient(
            null,
            "Self Patient",
            "self@example.com",
            20,
            "Other",
            "0700000000",
            "Addr",
            null,
            null,
            null);
    PatientPortalService portal = new PatientPortalService();
    String id = portal.register(p, "StrongPassword123");
    assertTrue(new PatientService().deletePatient(id));
    assertNull(portal.find("self@example.com"));
  }
}
