package com.medicare;

import static org.junit.Assert.*;

import com.medicare.dao.impl.*;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import com.medicare.util.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import org.junit.*;

public class RegressionTest {
  private Path data;

  @Before
  public void setup() throws Exception {
    data = Files.createTempDirectory("medicare-regression-");
    System.setProperty("medicare.data.dir", data.toString());
    DAOFactory.setStorageMode("FILE");
  }

  @After
  public void cleanup() throws Exception {
    try (var paths = Files.walk(data)) {
      paths
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

  private Patient patient() {
    return new Patient(
        "P1",
        "Test Patient",
        "test@example.com",
        21,
        "Male",
        "0700000000",
        "12, Main Road\nUpstairs\tRoom \\N",
        "A+",
        "Penicillin, nuts",
        "History\nSecond line");
  }

  private void refs() {
    for (int day = 1; day <= 7; day++) {
      Availability a = new Availability();
      a.setDoctorId("D1");
      a.setDayOfWeek(day);
      a.setStartTime("08:00");
      a.setEndTime("17:00");
      a.setSlotMinutes(20);
      ClinicStore.save(a);
    }

    DAOFactory.getPatientDAO().addPatient(patient());
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor(
                "D1",
                "Test Doctor",
                "General, Medicine",
                "MBBS",
                "0700000001",
                "doctor@example.com",
                2000));
  }

  private Appointment appointment() {
    return new Appointment("P1", "D1", "2099-10-28", "09:00", "Fever, cough\nReview", "Booked");
  }

  @Test
  public void patientAllFieldsRoundTrip() {
    Patient p = patient();
    assertTrue(DAOFactory.getPatientDAO().addPatient(p));
    Patient r = new PatientDAOFileImpl().getPatientById("P1");
    assertEquals(p.getAddress(), r.getAddress());
    assertEquals(p.getEmail(), r.getEmail());
    assertEquals(p.getBloodGroup(), r.getBloodGroup());
    assertEquals(p.getAllergies(), r.getAllergies());
    assertEquals(p.getMedicalHistory(), r.getMedicalHistory());
  }

  @Test
  public void patientGeneratedIdsAndDuplicateProtection() {
    Patient p = patient();
    p.setId(null);
    assertTrue(DAOFactory.getPatientDAO().addPatient(p));
    assertNotNull(p.getId());
    assertFalse(DAOFactory.getPatientDAO().addPatient(p));
    assertEquals(1, DAOFactory.getPatientDAO().getAllPatients().size());
  }

  @Test
  public void patientUpdatePreservesUneditedFields() {
    Patient p = patient();
    DAOFactory.getPatientDAO().addPatient(p);
    Patient r = DAOFactory.getPatientDAO().getPatientById("P1");
    r.setName("Edited");
    assertTrue(DAOFactory.getPatientDAO().updatePatient(r));
    assertEquals(p.getAllergies(), DAOFactory.getPatientDAO().getPatientById("P1").getAllergies());
    assertTrue(DAOFactory.getPatientDAO().deletePatient("P1"));
    assertNull(DAOFactory.getPatientDAO().getPatientById("P1"));
  }

  @Test
  public void medicalRecordCommasNewlinesAndEmptyNotesSurvive() {
    MedicalRecord r =
        new MedicalRecord("P1", "D1", 0, "Fever, cough\nReview", "Rest, fluids", "", "2026-10-28");
    assertTrue(DAOFactory.getMedicalRecordDAO().addMedicalRecord(r));
    MedicalRecord got = new MedicalRecordDAOFileImpl().getMedicalRecordById(r.getRecordId());
    assertEquals(r.getDiagnosis(), got.getDiagnosis());
    assertEquals("", got.getNotes());
    got.setNotes("Updated\tNote");
    assertTrue(DAOFactory.getMedicalRecordDAO().updateMedicalRecord(got));
    assertTrue(DAOFactory.getMedicalRecordDAO().deleteMedicalRecord(r.getRecordId()));
  }

  @Test
  public void userCrudAndPasswordSurviveNewDao() {
    User u = new User("tester", "password123", "STAFF");
    assertTrue(DAOFactory.getUserDAO().addUser(u));
    assertTrue(Passwords.encoded(u.getPassword()));
    assertNotNull(new UserDAOFileImpl().validateUser("tester", "password123"));
    assertNull(new UserDAOFileImpl().validateUser("tester", "wrong"));
    u.setPassword("newpassword123");
    assertTrue(DAOFactory.getUserDAO().updateUser(u));
    assertNotNull(new UserDAOFileImpl().validateUser("tester", "newpassword123"));
    assertNull(new UserDAOFileImpl().validateUser("tester", "password123"));
    assertTrue(DAOFactory.getUserDAO().deleteUser(u.getId()));
    assertNull(DAOFactory.getUserDAO().getUserByUsername("tester"));
  }

  @Test
  public void doctorRoundTripAndCrud() {
    refs();
    Doctor d = DAOFactory.getDoctorDAO().getDoctorById("D1");
    assertEquals("General, Medicine", d.getSpecialization());
    d.setEmail("");
    assertTrue(DAOFactory.getDoctorDAO().updateDoctor(d));
    assertEquals("", new DoctorDAOFileImpl().getDoctorById("D1").getEmail());
    assertTrue(DAOFactory.getDoctorDAO().deleteDoctor("D1"));
  }

  @Test
  public void appointmentDuplicateCancelRebookAndDisplayNames() {
    refs();
    AppointmentService s = new AppointmentService();
    Appointment a = appointment();
    assertTrue(s.addAppointment(a));
    assertFalse(s.addAppointment(appointment()));
    assertEquals("Test Patient", s.getAppointmentById(a.getAppointmentId()).getPatientName());
    assertTrue(s.cancelAppointment(a.getAppointmentId()));
    assertTrue(s.addAppointment(appointment()));
    a.setStatus("Cancelled");
    assertTrue(s.updateAppointment(a));
  }

  @Test
  public void appointmentConcurrentRequestsOnlyOneBooking() throws Exception {
    refs();
    ExecutorService pool = Executors.newFixedThreadPool(8);
    try {
      List<Future<Boolean>> results = new ArrayList<>();
      for (int i = 0; i < 24; i++)
        results.add(
            pool.submit(
                () -> {
                  try {
                    return new AppointmentService().addAppointment(appointment());
                  } catch (IllegalArgumentException e) {
                    if (!"This patient already has an appointment at that time"
                        .equals(e.getMessage())) throw e;
                    return false;
                  }
                }));
      int success = 0;
      for (Future<Boolean> r : results) if (r.get()) success++;
      assertEquals(1, success);
      assertEquals(1, DAOFactory.getAppointmentDAO().getAllAppointments().size());
    } finally {
      pool.shutdownNow();
    }
  }

  @Test
  public void billAndNotificationsUseFiles() {
    refs();
    Appointment a = appointment();
    new AppointmentService().addAppointment(a);
    Bill b = new Bill(a.getAppointmentId(), "P1", 2000, "Cash", "Unpaid");
    Validation.bill(b);
    assertTrue(DAOFactory.getBillDAO().createBill(b));
    assertTrue(DAOFactory.getBillDAO().updatePaymentStatus(b.getBillId(), "Card", "Paid"));
    assertEquals("Paid", new BillDAOFileImpl().getBillById(b.getBillId()).getPaymentStatus());
    assertTrue(
        DAOFactory.getNotificationDAO()
            .addNotification(new Notification("P1", "Reminder, appointment\nTomorrow")));
    assertEquals(2, new NotificationDAOFileImpl().getAllNotifications().size());
  }

  @Test
  public void supportingModulesUseFiles() throws Exception {
    refs();
    PortalData.addClaim("P1", "Provider, Ltd", "policy-1", 500);
    try (var rs = PortalData.query("insurance_claims")) {
      assertTrue(rs.next());
      int id = rs.getInt("claim_id");
      PortalData.updateClaim(id, "Approved");
    }
    PortalData.addDocument("P1", "report, sample.pdf", "unique.pdf");
    PortalData.audit("admin", "ADMIN", "Test, action\nLine", "127.0.0.1");
    try (var rs = PortalData.query("insurance_claims")) {
      assertTrue(rs.next());
      assertEquals("Approved", rs.getString("status"));
    }
    try (var rs = PortalData.query("patient_documents")) {
      assertTrue(rs.next());
      assertEquals("unique.pdf", PortalData.getDocument(rs.getInt("document_id")).getFilePath());
    }
    try (var rs = PortalData.query("audit_logs")) {
      assertTrue(rs.next());
      assertEquals("Test, action\nLine", rs.getString("action"));
    }
  }

  @Test
  public void referencedEntitiesCannotBeDeleted() {
    refs();
    Appointment a = appointment();
    new AppointmentService().addAppointment(a);
    try {
      new PatientService().deletePatient("P1");
      fail();
    } catch (IllegalArgumentException expected) {
    }
    try {
      new DoctorService().deleteDoctor("D1");
      fail();
    } catch (IllegalArgumentException expected) {
    }
  }

  @Test
  public void invalidBackendValuesRejected() {
    Patient p = patient();
    p.setAge(12200);
    try {
      Validation.patient(p);
      fail();
    } catch (IllegalArgumentException expected) {
    }
    try {
      Validation.amount(Double.NaN);
      fail();
    } catch (IllegalArgumentException expected) {
    }
    try {
      Validation.amount(-1);
      fail();
    } catch (IllegalArgumentException expected) {
    }
    try {
      Validation.references("missing", null);
      fail();
    } catch (IllegalArgumentException expected) {
    }
  }

  @Test
  public void traversalAndSymlinksRejected() throws Exception {
    for (String name : new String[] {"../secret", "..\\secret", "/tmp/secret", ""})
      try {
        DocumentStorage.resolve(name);
        fail(name);
      } catch (IllegalArgumentException expected) {
      }
    Path outside = Files.createTempFile("outside-", ".txt");
    try {
      try {
        Files.createSymbolicLink(DocumentStorage.root().resolve("link.txt"), outside);
      } catch (java.nio.file.FileSystemException | UnsupportedOperationException e) {
        // Explicitly skipped when symlink creation is unsupported or unprivileged on Windows
        return;
      }
      try {
        DocumentStorage.resolve("link.txt");
        fail();
      } catch (IllegalArgumentException expected) {
      }
    } finally {
      Files.deleteIfExists(outside);
    }
  }

  @Test
  public void damagedFileCannotBeSilentlyOverwritten() throws Exception {
    Path file = data.resolve("patients.txt");
    String original = "bad legacy row\n";
    Files.writeString(file, original);
    try {
      DAOFactory.getPatientDAO().addPatient(patient());
      fail();
    } catch (IllegalStateException expected) {
    }
    assertEquals(original, Files.readString(file));
  }

  @Test
  public void fileWriteFailureIsNotReportedAsSuccess() throws Exception {
    Files.createDirectory(data.resolve("patients.txt"));
    try {
      DAOFactory.getPatientDAO().addPatient(patient());
      fail();
    } catch (IllegalStateException expected) {
    }
  }

  @Test
  public void oopPolymorphismAndHtmlEscaping() {
    Person[] people = {patient(), new Doctor(), new User()};
    assertEquals("Patient", people[0].getRoleLabel());
    assertEquals("Doctor", people[1].getRoleLabel());
    assertEquals("User", people[2].getRoleLabel());
    assertEquals("&lt;script&gt;&amp;&quot;&#39;", Html.escape("<script>&\"'"));
  }
}
