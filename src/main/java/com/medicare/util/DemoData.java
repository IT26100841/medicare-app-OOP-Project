package com.medicare.util;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;

public final class DemoData {
  private DemoData() {}

  public static void seed() {
    if (!"FILE".equalsIgnoreCase(DAOFactory.getStorageMode())) return;
    if (java.nio.file.Files.exists(DataPaths.root().resolve("users.txt"))) return;
    DAOFactory.getUserDAO()
        .addUser(new User(0, "admin", "admin123", "ADMIN", "Demo Admin", "admin@example.com"));
    DAOFactory.getUserDAO()
        .addUser(new User(0, "doctor", "doc123", "DOCTOR", "Demo Doctor", "doctor@example.com"));
    DAOFactory.getUserDAO()
        .addUser(new User(0, "staff", "staff123", "STAFF", "Demo Staff", "staff@example.com"));
    if (DAOFactory.getDoctorDAO().getAllDoctors().isEmpty())
      DAOFactory.getDoctorDAO()
          .addDoctor(
              new Doctor(
                  "D001",
                  "Demo Doctor",
                  "General Medicine",
                  "MBBS",
                  "0700000001",
                  "doctor@example.com",
                  2500));
    if (DAOFactory.getPatientDAO().getAllPatients().isEmpty())
      DAOFactory.getPatientDAO()
          .addPatient(
              new Patient(
                  "P001",
                  "Demo Patient",
                  "patient@example.com",
                  25,
                  "Other",
                  "0700000002",
                  "12, Sample Road",
                  "O+",
                  "None",
                  "Sample data only"));
  }

  public static void main(String[] args) {
    seed();
    System.out.println("Demo data initialized at " + DataPaths.root());
  }
}
