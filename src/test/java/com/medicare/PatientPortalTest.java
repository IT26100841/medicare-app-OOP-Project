package com.medicare;

import static org.junit.Assert.*;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import java.nio.file.*;
import java.time.*;
import org.junit.*;

public class PatientPortalTest {
  PatientPortalService s;
  String id, other;

  @Before
  public void init() throws Exception {
    System.setProperty("medicare.data.dir", Files.createTempDirectory("portal-test").toString());
    DAOFactory.setStorageMode("FILE");
    s = new PatientPortalService();
    id = s.register(p("one@example.com"), "StrongPassword123");
    other = s.register(p("two@example.com"), "StrongPassword123");
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor(
                "D1", "Test Doctor", "General", "MBBS", "0700000000", "d@example.com", 2500));
    Availability a = new Availability();
    a.setDoctorId("D1");
    a.setDayOfWeek(LocalDate.now().plusDays(1).getDayOfWeek().getValue());
    a.setStartTime("09:00");
    a.setEndTime("10:00");
    a.setSlotMinutes(20);
    new ScheduleService().save(a);
  }

  private Patient p(String email) {
    return new Patient(
        null, "Test Patient", email, 22, "Other", "0700000001", "Address", null, null, null);
  }

  @Test
  public void accountAndSharedProfile() {
    assertNotNull(DAOFactory.getPatientDAO().getPatientById(id));
    assertEquals(id, s.login("ONE@example.com", "StrongPassword123"));
    assertNull(s.login("one@example.com", "wrong"));
    assertTrue(s.find("one@example.com").getPasswordHash().startsWith("pbkdf2$"));
  }

  @Test
  public void duplicateRegistrationRejected() {
    try {
      s.register(p("one@example.com"), "StrongPassword123");
      fail();
    } catch (IllegalArgumentException expected) {
    }
    assertEquals(2, DAOFactory.getPatientDAO().getAllPatients().size());
  }

  @Test
  public void clinicalEmailCannotBeClaimed() {
    Patient p = p("existing@example.com");
    DAOFactory.getPatientDAO().addPatient(p);
    try {
      s.register(p("existing@example.com"), "StrongPassword123");
      fail();
    } catch (IllegalArgumentException expected) {
    }
  }

  @Test
  public void appointmentsArePrivate() {
    book(id, "09:00");
    assertEquals(1, s.appointments(id).size());
    assertTrue(s.appointments(other).isEmpty());
    int a = s.appointments(id).get(0).getAppointmentId();
    try {
      s.cancel(other, a);
      fail();
    } catch (SecurityException expected) {
    }
    assertEquals("Booked", new AppointmentService().getAppointmentById(a).getStatus());
    s.cancel(id, a);
    assertEquals("Cancelled", new AppointmentService().getAppointmentById(a).getStatus());
  }

  @Test
  public void doubleBookingRejected() {
    book(id, "09:00");
    try {
      book(other, "09:00");
      fail();
    } catch (IllegalArgumentException expected) {
    }
    assertEquals(1, new AppointmentService().getAllAppointments().size());
  }

  @Test
  public void profileDoesNotChangeClinicalFields() {
    Patient p = DAOFactory.getPatientDAO().getPatientById(id);
    p.setMedicalHistory("Clinical history");
    DAOFactory.getPatientDAO().updatePatient(p);
    s.profile(id, "Updated", "0700000002", "New address");
    p = DAOFactory.getPatientDAO().getPatientById(id);
    assertEquals("Updated", p.getName());
    assertEquals("Clinical history", p.getMedicalHistory());
    assertEquals("one@example.com", p.getEmail());
  }

  private void book(String id, String time) {
    s.book(id, "D1", LocalDate.now().plusDays(1).toString(), time, "Checkup");
  }
}
