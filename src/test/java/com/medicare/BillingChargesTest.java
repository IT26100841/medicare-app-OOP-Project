package com.medicare;

import static org.junit.Assert.*;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import java.nio.file.*;
import org.junit.*;

public class BillingChargesTest {
  @Before
  public void setup() throws Exception {
    System.setProperty(
        "medicare.data.dir", Files.createTempDirectory("billing-charges").toString());
    DAOFactory.setStorageMode("FILE");
    DAOFactory.getPatientDAO()
        .addPatient(new Patient("P1", "Test Patient", 25, "Other", "0700000000"));
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor("D1", "Doctor", "General", "MBBS", "0700000000", "d@example.com", 2500));
    Appointment a = new Appointment("P1", "D1", "2030-01-01", "09:00", "Test", "Completed");
    DAOFactory.getAppointmentDAO().addAppointment(a);
  }

  @Test
  public void breakdownSurvivesReloadAndPayment() {
    Bill b = new BillingService().create(1, "500.25", "1000.50");
    assertEquals(4000.75, b.getAmount(), .001);
    b = DAOFactory.getBillDAO().getBillById(b.getBillId());
    assertEquals(2500, b.getConsultationCharge(), .001);
    assertEquals(500.25, b.getHospitalCharge(), .001);
    assertEquals(1000.50, b.getTreatmentCharge(), .001);
    new BillingService().pay(b.getBillId(), "Cash");
    b = DAOFactory.getBillDAO().getBillById(b.getBillId());
    assertEquals("Paid", b.getPaymentStatus());
    assertEquals(4000.75, b.getAmount(), .001);
    assertEquals(500.25, b.getHospitalCharge(), .001);
  }

  @Test
  public void invalidChargesRejected() {
    for (String value : new String[] {"-1", "NaN", "Infinity", "0.001", "10000000000"}) {
      try {
        new BillingService().create(1, value, "0");
        fail(value);
      } catch (IllegalArgumentException expected) {
      }
    }
    assertTrue(DAOFactory.getBillDAO().getAllBills().isEmpty());
  }

  @Test
  public void defaultsAndSnapshot() {
    Bill b = new BillingService().create(1);
    assertEquals(2500, b.getAmount(), .001);
    Doctor d = DAOFactory.getDoctorDAO().getDoctorById("D1");
    d.setConsultationFee(3500);
    DAOFactory.getDoctorDAO().updateDoctor(d);
    assertEquals(
        2500, DAOFactory.getBillDAO().getBillById(b.getBillId()).getConsultationCharge(), .001);
  }

  @Test
  public void legacyFileReadsAndPaymentMigrates() throws Exception {
    Path path = com.medicare.util.DataPaths.root().resolve("bills.txt");
    Files.writeString(
        path,
        "#medicare-tsv-v1\tbillId\tappointmentId\tpatientId\tamount\tpaymentMethod\tpaymentStatus\n"
            + "1\t1\tP1\t2500.0\tCash\tUnpaid\n");
    Bill b = DAOFactory.getBillDAO().getBillById(1);
    assertEquals(2500, b.getConsultationCharge(), .001);
    assertEquals(0, b.getHospitalCharge(), .001);
    new BillingService().pay(1, "Card");
    assertTrue(Files.readString(path).contains("hospitalCharge"));
    assertEquals(2500, DAOFactory.getBillDAO().getBillById(1).getAmount(), .001);
  }
}
