package com.medicare.service;

import com.medicare.dao.impl.*;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.util.*;
import java.sql.*;
import java.time.*;
import java.util.*;

public class PatientPortalService {
  private EntryFileDAO<PatientAccount> files() {
    return new EntryFileDAO<>(
        "patient_accounts.txt", PatientAccount.class, "email", "patientId", "passwordHash");
  }

  private boolean file() {
    return "FILE".equals(DAOFactory.getStorageMode());
  }

  public static String email(String v) {
    v = Validation.required(v, "Email").toLowerCase(Locale.ROOT);
    Validation.email(v);
    if (v.length() > 100) throw new IllegalArgumentException("Email is too long");
    return v;
  }

  public PatientAccount find(String email) {
    if (file())
      return files().list().stream()
          .filter(a -> a.getEmail().equals(email))
          .findFirst()
          .orElse(null);
    try (Connection c = DBConnection.getConnection();
        PreparedStatement s =
            c.prepareStatement(
                "SELECT email,patient_id,password_hash FROM patient_portal_accounts WHERE"
                    + " email=?")) {
      s.setString(1, email);
      try (ResultSet rs = s.executeQuery()) {
        if (!rs.next()) return null;
        PatientAccount a = new PatientAccount();
        a.setEmail(rs.getString(1));
        a.setPatientId(rs.getString(2));
        a.setPasswordHash(rs.getString(3));
        return a;
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Patient account storage unavailable", e);
    }
  }

  public String login(String email, String password) {
    PatientAccount a = find(email(email));
    return a != null
            && Passwords.verify(password, a.getPasswordHash())
            && DAOFactory.getPatientDAO().getPatientById(a.getPatientId()) != null
        ? a.getPatientId()
        : null;
  }

  public String register(Patient p, String password) {
    Validation.patient(p);
    details(p.getName(), p.getPhone(), p.getAddress());
    p.setEmail(email(p.getEmail()));
    if (password == null || password.length() < 12 || password.length() > 128)
      throw new IllegalArgumentException("Use a password between 12 and 128 characters");
    String hash = Passwords.hash(password);
    synchronized (AbstractFileDAO.LOCK) {
      if (find(p.getEmail()) != null)
        throw new IllegalArgumentException(
            "An account already exists. Please sign in or contact reception.");
      // Never claim an existing clinical record merely by knowing its email.
      if (DAOFactory.getPatientDAO().getAllPatients().stream()
          .anyMatch(x -> p.getEmail().equalsIgnoreCase(x.getEmail())))
        throw new IllegalArgumentException(
            "This email is already on a clinical profile. Contact reception to verify your"
                + " identity.");
      if (file()) {
        if (!DAOFactory.getPatientDAO().addPatient(p))
          throw new IllegalStateException("Cannot create profile");
        PatientAccount a = new PatientAccount();
        a.setEmail(p.getEmail());
        a.setPatientId(p.getId());
        a.setPasswordHash(hash);
        try {
          if (!files().save(a)) throw new IllegalStateException("Cannot create account");
        } catch (RuntimeException e) {
          DAOFactory.getPatientDAO().deletePatient(p.getId());
          throw e;
        }
        return p.getId();
      }
      try (Connection c = DBConnection.getConnection()) {
        c.setAutoCommit(false);
        try {
          try (PreparedStatement s =
              c.prepareStatement(
                  "INSERT INTO patients(name,email,age,gender,phone,address) VALUES(?,?,?,?,?,?)",
                  Statement.RETURN_GENERATED_KEYS)) {
            s.setString(1, p.getName());
            s.setString(2, p.getEmail());
            s.setInt(3, p.getAge());
            s.setString(4, p.getGender());
            s.setString(5, p.getPhone());
            s.setString(6, p.getAddress());
            s.executeUpdate();
            try (ResultSet k = s.getGeneratedKeys()) {
              if (!k.next()) throw new SQLException("No patient ID");
              p.setId(k.getString(1));
            }
          }
          try (PreparedStatement s =
              c.prepareStatement(
                  "INSERT INTO patient_portal_accounts(email,patient_id,password_hash)"
                      + " VALUES(?,?,?)")) {
            s.setString(1, p.getEmail());
            s.setString(2, p.getId());
            s.setString(3, hash);
            s.executeUpdate();
          }
          c.commit();
          return p.getId();
        } catch (SQLException e) {
          c.rollback();
          throw e;
        }
      } catch (SQLException e) {
        throw new IllegalStateException(
            "Registration could not be saved. If already registered, sign in.", e);
      }
    }
  }

  public List<Appointment> appointments(String patient) {
    List<Appointment> result = new ArrayList<>();
    for (Appointment a : DAOFactory.getAppointmentDAO().getAllAppointments())
      if (patient.equals(a.getPatientId())) result.add(a);
    return result;
  }

  public void book(String patient, String doctor, String date, String time, String reason) {
    if (reason == null || reason.isBlank() || reason.length() > 255)
      throw new IllegalArgumentException("Enter a reason, up to 255 characters");
    if (LocalDate.parse(date).isAfter(LocalDate.now().plusDays(90)))
      throw new IllegalArgumentException("Book within the next 90 days");
    synchronized (AbstractFileDAO.LOCK) {
      if (!new ScheduleService().slots(doctor, date, 0).contains(time))
        throw new IllegalArgumentException(
            "That slot is no longer available. Choose another time.");
      Appointment a = new Appointment(patient, doctor, date, time, reason, "Booked");
      if (!new AppointmentService().addAppointment(a))
        throw new IllegalArgumentException(
            "This doctor or patient already has a booking at that time.");
    }
  }

  public void cancel(String patient, int id) {
    synchronized (AbstractFileDAO.LOCK) {
      Appointment a = new AppointmentService().getAppointmentById(id);
      if (a == null || !patient.equals(a.getPatientId()))
        throw new SecurityException("Appointment is not available to this account");
      if (!"Booked".equals(a.getStatus())
          || !LocalDateTime.of(
                  LocalDate.parse(a.getAppointmentDate()), LocalTime.parse(a.getAppointmentTime()))
              .isAfter(LocalDateTime.now()))
        throw new IllegalArgumentException(
            "Only future booked appointments can be cancelled. Contact reception.");
      if (file()) {
        if (!new AppointmentService().cancelAppointment(id))
          throw new IllegalStateException("Cancellation was not saved");
      } else if (!new com.medicare.dao.impl.AppointmentDAODBImpl().cancelForPatient(id, patient))
        throw new IllegalStateException("Cancellation was not saved");
    }
  }

  public void removeFileAccount(String patient) {
    if (!file()) throw new IllegalStateException("DB accounts use foreign-key deletion");
    files().delete(a -> patient.equals(a.getPatientId()));
  }

  private void details(String name, String phone, String address) {
    if (name == null
        || name.length() > 100
        || phone == null
        || !phone.matches("[+0-9() -]{7,20}")
        || (address != null && address.length() > 500))
      throw new IllegalArgumentException(
          "Use a name up to 100 characters, a valid phone (7–20 characters), and an address up to"
              + " 500 characters");
  }

  public void profile(String id, String name, String phone, String address) {
    details(name, phone, address);
    Patient p = DAOFactory.getPatientDAO().getPatientById(id);
    if (p == null) throw new SecurityException("Profile unavailable");
    p.setName(Validation.required(name, "Name"));
    p.setPhone(Validation.required(phone, "Phone"));
    p.setAddress(address);
    Validation.patient(p);
    if (file()) {
      if (!DAOFactory.getPatientDAO().updatePatient(p))
        throw new IllegalStateException("Profile was not saved");
    } else
      try (Connection c = DBConnection.getConnection();
          PreparedStatement q =
              c.prepareStatement("UPDATE patients SET name=?,phone=?,address=? WHERE id=?")) {
        q.setString(1, p.getName());
        q.setString(2, p.getPhone());
        q.setString(3, p.getAddress());
        q.setString(4, id);
        if (q.executeUpdate() != 1) throw new IllegalStateException("Profile was not saved");
      } catch (SQLException e) {
        throw new IllegalStateException("Profile was not saved", e);
      }
  }
}
