package com.medicare.service;

import com.medicare.dao.impl.*;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.util.*;
import java.sql.*;
import java.util.*;

/** Additional workflow data is stored without changing existing patient/doctor tables. */
public final class ClinicStore {
  private ClinicStore() {}

  private static EntryFileDAO<Availability> files() {
    return new EntryFileDAO<>(
        "availability.txt",
        Availability.class,
        "id",
        "doctorId",
        "dayOfWeek",
        "startTime",
        "endTime",
        "slotMinutes");
  }

  private static EntryFileDAO<DoctorAccount> accounts() {
    return new EntryFileDAO<>("doctor_accounts.txt", DoctorAccount.class, "userId", "doctorId");
  }

  private static boolean file() {
    return "FILE".equalsIgnoreCase(DAOFactory.getStorageMode());
  }

  public static List<Availability> availability() {
    if (file()) return files().list();
    List<Availability> result = new ArrayList<>();
    try (Connection c = DBConnection.getConnection();
        Statement s = c.createStatement();
        ResultSet rs =
            s.executeQuery("SELECT * FROM clinic_availability ORDER BY day_of_week,start_time")) {
      while (rs.next()) {
        Availability a = new Availability();
        a.setId(rs.getInt("id"));
        a.setDoctorId(rs.getString("doctor_id"));
        a.setDayOfWeek(rs.getInt("day_of_week"));
        a.setStartTime(rs.getString("start_time"));
        a.setEndTime(rs.getString("end_time"));
        a.setSlotMinutes(rs.getInt("slot_minutes"));
        result.add(a);
      }
      return result;
    } catch (SQLException e) {
      throw new IllegalStateException(
          "Workflow tables missing. Import database/upgrade-workflow.sql", e);
    }
  }

  public static boolean save(Availability a) {
    synchronized (AbstractFileDAO.LOCK) {
      if (file()) {
        if (a.getId() == 0) {
          a.setId(files().list().stream().mapToInt(Availability::getId).max().orElse(0) + 1);
          return files().save(a);
        }
        return files().update(a, x -> x.getId() == a.getId());
      }
      String sql =
          a.getId() == 0
              ? "INSERT INTO"
                    + " clinic_availability(doctor_id,day_of_week,start_time,end_time,slot_minutes)"
                    + " VALUES(?,?,?,?,?)"
              : "UPDATE clinic_availability SET"
                    + " doctor_id=?,day_of_week=?,start_time=?,end_time=?,slot_minutes=? WHERE"
                    + " id=?";
      try (Connection c = DBConnection.getConnection();
          PreparedStatement s = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        s.setString(1, a.getDoctorId());
        s.setInt(2, a.getDayOfWeek());
        s.setString(3, a.getStartTime());
        s.setString(4, a.getEndTime());
        s.setInt(5, a.getSlotMinutes());
        if (a.getId() > 0) s.setInt(6, a.getId());
        if (s.executeUpdate() == 0) return false;
        if (a.getId() == 0)
          try (ResultSet keys = s.getGeneratedKeys()) {
            if (keys.next()) a.setId(keys.getInt(1));
          }
        return true;
      } catch (SQLException e) {
        throw new IllegalStateException("Schedule write failed", e);
      }
    }
  }

  public static boolean delete(int id) {
    if (file()) return files().delete(x -> x.getId() == id);
    try (Connection c = DBConnection.getConnection();
        PreparedStatement s = c.prepareStatement("DELETE FROM clinic_availability WHERE id=?")) {
      s.setInt(1, id);
      return s.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException(e);
    }
  }

  public static String doctorFor(int userId) {
    if (file()) {
      for (DoctorAccount a : accounts().list()) if (a.getUserId() == userId) return a.getDoctorId();
      return null;
    }
    try (Connection c = DBConnection.getConnection();
        PreparedStatement s =
            c.prepareStatement("SELECT doctor_id FROM clinic_doctor_accounts WHERE user_id=?")) {
      s.setInt(1, userId);
      try (ResultSet rs = s.executeQuery()) {
        return rs.next() ? rs.getString(1) : null;
      }
    } catch (SQLException e) {
      throw new IllegalStateException(
          "Doctor account mapping is unavailable. Import upgrade-workflow.sql", e);
    }
  }

  public static void bind(int userId, String doctorId) {
    synchronized (AbstractFileDAO.LOCK) {
      if (doctorId != null
          && !doctorId.isBlank()
          && DAOFactory.getDoctorDAO().getDoctorById(doctorId) == null)
        throw new IllegalArgumentException("Selected doctor does not exist");
      if (file()) {
        accounts().delete(x -> x.getUserId() == userId);
        if (doctorId != null && !doctorId.isBlank()) {
          DoctorAccount a = new DoctorAccount();
          a.setUserId(userId);
          a.setDoctorId(doctorId);
          accounts().save(a);
        }
        return;
      }
      try (Connection c = DBConnection.getConnection()) {
        c.setAutoCommit(false);
        try {
          try (PreparedStatement s =
              c.prepareStatement("DELETE FROM clinic_doctor_accounts WHERE user_id=?")) {
            s.setInt(1, userId);
            s.executeUpdate();
          }
          if (doctorId != null && !doctorId.isBlank())
            try (PreparedStatement s =
                c.prepareStatement(
                    "INSERT INTO clinic_doctor_accounts(user_id,doctor_id) VALUES(?,?)")) {
              s.setInt(1, userId);
              s.setString(2, doctorId);
              s.executeUpdate();
            }
          c.commit();
        } catch (SQLException e) {
          c.rollback();
          throw e;
        }
      } catch (SQLException e) {
        throw new IllegalStateException("Cannot link doctor account", e);
      }
    }
  }
}
