package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.User;
import com.medicare.util.*;
import java.sql.*;
import java.util.*;

/** Account and linked doctor identity are saved as one unit. */
public class AccountService {
  private String link(User u, String doctor) {
    if (!Arrays.asList("ADMIN", "DOCTOR", "STAFF").contains(u.getRole()))
      throw new IllegalArgumentException("Invalid role");
    if (!"DOCTOR".equals(u.getRole())) return null;
    if (doctor == null || doctor.isBlank()) return null;
    if (DAOFactory.getDoctorDAO().getDoctorById(doctor) == null)
      throw new IllegalArgumentException("Selected doctor does not exist");
    return doctor;
  }

  public void save(User u, boolean update, String doctor) {
    String selected = link(u, doctor);
    Validation.email(u.getEmail());
    Validation.required(u.getUsername(), "Username");
    if (u.getUsername().length() > 50 || (u.getEmail() != null && u.getEmail().length() > 100))
      throw new IllegalArgumentException("Username or email too long");
    if (!Passwords.encoded(u.getPassword())) {
      if (u.getPassword() == null || u.getPassword().length() < 8 || u.getPassword().length() > 128)
        throw new IllegalArgumentException("Use an 8–128 character password");
      u.setPassword(Passwords.hash(u.getPassword()));
    }
    if ("FILE".equals(DAOFactory.getStorageMode())) {
      FileTransactions.run(
          () -> {
            boolean saved =
                update ? DAOFactory.getUserDAO().updateUser(u) : DAOFactory.getUserDAO().addUser(u);
            if (!saved)
              throw new IllegalArgumentException("User was not saved; check duplicate username");
            User persisted = DAOFactory.getUserDAO().getUserByUsername(u.getUsername());
            u.setId(persisted.getId());
            ClinicStore.bind(u.getId(), selected);
            return true;
          },
          "users.txt",
          "doctor_accounts.txt");
      return;
    }
    try (Connection c = DBConnection.getConnection()) {
      c.setAutoCommit(false);
      try {
        String sql =
            update
                ? "UPDATE users SET password=?,role=?,email=? WHERE user_id=? AND username=?"
                : "INSERT INTO users(password,role,email,username) VALUES(?,?,?,?)";
        try (PreparedStatement s = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
          s.setString(1, u.getPassword());
          s.setString(2, u.getRole());
          s.setString(3, u.getEmail() == null ? "" : u.getEmail());
          if (update) {
            s.setInt(4, u.getId());
            s.setString(5, u.getUsername());
          } else s.setString(4, u.getUsername());
          if (s.executeUpdate() != 1)
            throw new IllegalArgumentException("User not found or not saved");
          if (!update)
            try (ResultSet k = s.getGeneratedKeys()) {
              if (!k.next()) throw new SQLException("No account ID");
              u.setId(k.getInt(1));
            }
        }
        try (PreparedStatement s =
            c.prepareStatement("DELETE FROM clinic_doctor_accounts WHERE user_id=?")) {
          s.setInt(1, u.getId());
          s.executeUpdate();
        }
        if (selected != null)
          try (PreparedStatement s =
              c.prepareStatement(
                  "INSERT INTO clinic_doctor_accounts(user_id,doctor_id) VALUES(?,?)")) {
            s.setInt(1, u.getId());
            s.setString(2, selected);
            s.executeUpdate();
          }
        c.commit();
      } catch (SQLException | RuntimeException e) {
        c.rollback();
        throw e;
      }
    } catch (SQLIntegrityConstraintViolationException e) {
      throw new IllegalArgumentException(
          "Account or doctor link conflicts with an existing record", e);
    } catch (SQLException e) {
      throw new IllegalStateException("Account and doctor link were not saved", e);
    }
  }

  public void delete(int id) {
    if ("FILE".equals(DAOFactory.getStorageMode())) {
      FileTransactions.run(
          () -> {
            ClinicStore.bind(id, null);
            if (!DAOFactory.getUserDAO().deleteUser(id))
              throw new IllegalArgumentException("User not found");
            return true;
          },
          "users.txt",
          "doctor_accounts.txt");
      return;
    }
    try (Connection c = DBConnection.getConnection()) {
      c.setAutoCommit(false);
      try {
        try (PreparedStatement s =
            c.prepareStatement("DELETE FROM clinic_doctor_accounts WHERE user_id=?")) {
          s.setInt(1, id);
          s.executeUpdate();
        }
        try (PreparedStatement s = c.prepareStatement("DELETE FROM users WHERE user_id=?")) {
          s.setInt(1, id);
          if (s.executeUpdate() != 1) throw new IllegalArgumentException("User not found");
        }
        c.commit();
      } catch (SQLException | RuntimeException e) {
        c.rollback();
        throw e;
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Account was not deleted", e);
    }
  }
}
