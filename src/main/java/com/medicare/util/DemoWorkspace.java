package com.medicare.util;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import java.time.*;

/**
 * Optional sample workspace. Invoked only on a brand-new FILE directory with -Dmedicare.demo=true.
 */
public final class DemoWorkspace {
  private DemoWorkspace() {}

  public static void populate() {
    String[] names = {
      "Nimal Fernando",
      "Amaya Silva",
      "Ravindu Perera",
      "Nethmi Jayasuriya",
      "Kasun Wijesinghe",
      "Dilini Senanayake",
      "Tharindu De Silva"
    };
    for (int i = 0; i < names.length; i++)
      DAOFactory.getPatientDAO()
          .addPatient(
              new Patient(
                  "P" + String.format("%03d", i + 2),
                  names[i],
                  "patient" + (i + 2) + "@example.com",
                  22 + i * 4,
                  i % 2 == 0 ? "Male" : "Female",
                  "07000000" + String.format("%02d", i + 3),
                  "Sample address, Colombo",
                  "O+",
                  "Not recorded",
                  "Demonstration profile only"));
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor(
                "D002",
                "Dr. Anjali Perera",
                "Family Medicine",
                "MBBS",
                "0700000102",
                "anjali@example.com",
                3000));
    DAOFactory.getDoctorDAO()
        .addDoctor(
            new Doctor(
                "D003",
                "Dr. Dilan Fernando",
                "Internal Medicine",
                "MBBS, MD",
                "0700000103",
                "dilan@example.com",
                3500));
    for (String id : new String[] {"D002", "D003"})
      for (int day = 1; day <= 7; day++) {
        Availability a = new Availability();
        a.setDoctorId(id);
        a.setDayOfWeek(day);
        a.setStartTime("09:00");
        a.setEndTime("17:00");
        a.setSlotMinutes(20);
        new ScheduleService().save(a);
      }
    String[] states = {
      "Booked", "Checked-in", "In consultation", "Completed", "Booked", "Completed", "Cancelled"
    };
    for (int i = 0; i < states.length; i++) {
      String patient = "P" + String.format("%03d", i + 2),
          doctor = i % 3 == 0 ? "D001" : i % 3 == 1 ? "D002" : "D003";
      Appointment a =
          new Appointment(
              patient,
              doctor,
              LocalDate.now().toString(),
              String.format("%02d:%02d", 9 + i / 3, (i % 3) * 20),
              "Follow-up consultation (demo)",
              states[i]);
      DAOFactory.getAppointmentDAO().addAppointment(a);
      if (states[i].equals("Completed")) {
        DAOFactory.getMedicalRecordDAO()
            .addMedicalRecord(
                new MedicalRecord(
                    patient,
                    doctor,
                    a.getAppointmentId(),
                    "Demonstration assessment",
                    "Sample clinical note. No treatment instruction.",
                    "Illustrative data only",
                    LocalDate.now().toString()));
        Doctor d = DAOFactory.getDoctorDAO().getDoctorById(doctor);
        DAOFactory.getBillDAO()
            .createBill(
                new Bill(
                    a.getAppointmentId(),
                    patient,
                    d.getConsultationFee(),
                    "Cash",
                    i == 3 ? "Unpaid" : "Paid"));
      }
    }
    PortalData.audit("admin", "ADMIN", "Illustrative demo workspace initialized", "127.0.0.1");
  }
}
