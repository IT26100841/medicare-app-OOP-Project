package com.medicare.dao.impl;

import com.medicare.dao.AppointmentDAO;
import com.medicare.model.Appointment;
import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAODBImpl implements AppointmentDAO {

  private static final String SELECT_JOIN_BASE =
      "SELECT a.appointment_id, a.patient_id, a.doctor_id, a.appointment_date, a.appointment_time,"
          + " a.reason, a.status,        p.name AS patient_name, d.name AS doctor_name,"
          + " d.specialization AS doctor_specialization FROM appointments a LEFT JOIN patients p ON"
          + " a.patient_id = p.id LEFT JOIN doctors d ON a.doctor_id = d.id ";

  private Appointment mapResultSetToAppointment(ResultSet rs) throws SQLException {
    Appointment app =
        new Appointment(
            rs.getInt("appointment_id"),
            rs.getString("patient_id"),
            rs.getString("doctor_id"),
            String.valueOf(rs.getDate("appointment_date")),
            String.valueOf(rs.getTime("appointment_time")),
            rs.getString("reason"),
            rs.getString("status"));
    app.setPatientName(rs.getString("patient_name"));
    app.setDoctorName(rs.getString("doctor_name"));
    app.setDoctorSpecialization(rs.getString("doctor_specialization"));
    return app;
  }

  @Override
  public boolean addAppointment(Appointment appointment) {
    return saveLocked(appointment, false);
  }

  private boolean saveLocked(Appointment a, boolean update) {
    // All writers in this app take this MySQL named lock on the same connection.
    // This also serializes bookings across multiple deployed app instances.
    String lock = "medicare.appointment.write.v1";
    try (Connection conn = DBConnection.getConnection()) {
      boolean acquired = false;
      try {
        try (PreparedStatement stmt = conn.prepareStatement("SELECT GET_LOCK(?,10)")) {
          stmt.setString(1, lock);
          try (ResultSet rs = stmt.executeQuery()) {
            acquired = rs.next() && rs.getInt(1) == 1;
          }
        }
        if (!acquired) throw new SQLException("Could not acquire appointment lock");
        conn.setAutoCommit(false);
        String previousStatus = null;
        if (update)
          try (PreparedStatement old =
              conn.prepareStatement(
                  "SELECT status FROM appointments WHERE appointment_id=? FOR UPDATE")) {
            old.setInt(1, a.getAppointmentId());
            try (ResultSet rs = old.executeQuery()) {
              if (!rs.next()) return false;
              previousStatus = rs.getString(1);
            }
          }

        if (update
            && previousStatus != null
            && !previousStatus.equals(a.getStatus())
            && !com.medicare.model.AppointmentStatus.parse(previousStatus)
                .canMoveTo(com.medicare.model.AppointmentStatus.parse(a.getStatus())))
          throw new IllegalArgumentException(
              "This appointment changed. Reload it before changing its status.");
        if (com.medicare.model.AppointmentStatus.parse(a.getStatus()).reservesSlot()) {
          String check =
              "SELECT COUNT(*) FROM appointments WHERE (doctor_id=? OR patient_id=?) AND"
                  + " appointment_date=? AND appointment_time=? AND status NOT IN"
                  + " ('Cancelled','No-show') AND appointment_id<>?";
          try (PreparedStatement stmt = conn.prepareStatement(check)) {
            stmt.setString(1, a.getDoctorId());
            stmt.setString(2, a.getPatientId());
            stmt.setDate(3, Date.valueOf(a.getAppointmentDate()));
            stmt.setTime(4, Time.valueOf(formatTimeToSql(a.getAppointmentTime())));
            stmt.setInt(5, update ? a.getAppointmentId() : 0);
            try (ResultSet rs = stmt.executeQuery()) {
              if (rs.next() && rs.getInt(1) > 0) return false;
            }
          }
        }
        String sql =
            update
                ? "UPDATE appointments SET"
                      + " patient_id=?,doctor_id=?,appointment_date=?,appointment_time=?,reason=?,status=?"
                      + " WHERE appointment_id=?"
                : "INSERT INTO"
                      + " appointments(patient_id,doctor_id,appointment_date,appointment_time,reason,status)"
                      + " VALUES(?,?,?,?,?,?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
          stmt.setString(1, a.getPatientId());
          stmt.setString(2, a.getDoctorId());
          stmt.setDate(3, Date.valueOf(a.getAppointmentDate()));
          stmt.setTime(4, Time.valueOf(formatTimeToSql(a.getAppointmentTime())));
          stmt.setString(5, a.getReason());
          stmt.setString(6, a.getStatus());
          if (update) stmt.setInt(7, a.getAppointmentId());
          if (stmt.executeUpdate() == 0) return false;
          if (!update)
            try (ResultSet keys = stmt.getGeneratedKeys()) {
              if (keys.next()) a.setAppointmentId(keys.getInt(1));
            }
          if (!update && "Booked".equals(a.getStatus()))
            com.medicare.service.NotificationEvents.db(conn, a, "confirmed");
          if (update && "Cancelled".equals(a.getStatus()) && !"Cancelled".equals(previousStatus))
            com.medicare.service.NotificationEvents.db(conn, a, "cancelled");
          conn.commit();
          return true;
        }
      } finally {
        if (!conn.getAutoCommit()) conn.rollback();
        if (acquired)
          try (PreparedStatement stmt = conn.prepareStatement("SELECT RELEASE_LOCK(?)")) {
            stmt.setString(1, lock);
            stmt.execute();
          }
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Appointment write failed", e);
    }
  }

  @Override
  public List<Appointment> getAllAppointments() {
    List<Appointment> list = new ArrayList<>();
    String sql = SELECT_JOIN_BASE + "ORDER BY a.appointment_date DESC, a.appointment_time DESC";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {

      while (rs.next()) {
        list.add(mapResultSetToAppointment(rs));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public Appointment getAppointmentById(int appointmentId) {
    String sql = SELECT_JOIN_BASE + "WHERE a.appointment_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setInt(1, appointmentId);
      try (ResultSet rs = stmt.executeQuery()) {
        if (rs.next()) {
          return mapResultSetToAppointment(rs);
        }
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return null;
  }

  @Override
  public boolean updateAppointment(Appointment appointment) {
    return saveLocked(appointment, true);
  }

  @Override
  public boolean cancelAppointment(int appointmentId) {
    Appointment a = getAppointmentById(appointmentId);
    if (a == null) return false;
    a.setStatus("Cancelled");
    return updateAppointment(a);
  }

  public boolean cancelForPatient(int id, String patient) {
    try (Connection c = DBConnection.getConnection()) {
      c.setAutoCommit(false);
      try {
        Appointment a;
        try (PreparedStatement s =
            c.prepareStatement("SELECT * FROM appointments WHERE appointment_id=? FOR UPDATE")) {
          s.setInt(1, id);
          try (ResultSet rs = s.executeQuery()) {
            if (!rs.next() || !patient.equals(rs.getString("patient_id")))
              throw new SecurityException("Appointment is not available to this account");
            if (!"Booked".equals(rs.getString("status"))
                || !java.time.LocalDateTime.of(
                        rs.getDate("appointment_date").toLocalDate(),
                        rs.getTime("appointment_time").toLocalTime())
                    .isAfter(java.time.LocalDateTime.now()))
              throw new IllegalArgumentException(
                  "Only future booked appointments can be cancelled");
            a =
                new Appointment(
                    id,
                    patient,
                    rs.getString("doctor_id"),
                    rs.getDate("appointment_date").toString(),
                    rs.getTime("appointment_time").toString(),
                    rs.getString("reason"),
                    "Cancelled");
          }
        }
        try (PreparedStatement s =
            c.prepareStatement(
                "UPDATE appointments SET status='Cancelled' WHERE appointment_id=?")) {
          s.setInt(1, id);
          s.executeUpdate();
        }
        com.medicare.service.NotificationEvents.db(c, a, "cancelled");
        c.commit();
        return true;
      } catch (SQLException | RuntimeException e) {
        c.rollback();
        throw e;
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Cancellation and notification were not saved", e);
    }
  }

  @Override
  public boolean deleteAppointment(int appointmentId) {
    String sql = "DELETE FROM appointments WHERE appointment_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setInt(1, appointmentId);
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public List<Appointment> searchAppointments(String keyword) {
    List<Appointment> list = new ArrayList<>();
    String sql =
        SELECT_JOIN_BASE
            + "WHERE a.patient_id LIKE ? OR a.doctor_id LIKE ? OR a.reason LIKE ? OR a.status LIKE"
            + " ?    OR p.name LIKE ? OR d.name LIKE ? OR a.appointment_date LIKE ? ORDER BY"
            + " a.appointment_date DESC, a.appointment_time DESC";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      String term = "%" + (keyword != null ? keyword.trim() : "") + "%";
      for (int i = 1; i <= 7; i++) {
        stmt.setString(i, term);
      }

      try (ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
          list.add(mapResultSetToAppointment(rs));
        }
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public List<Appointment> getAppointmentsByStatus(String status) {
    List<Appointment> list = new ArrayList<>();
    String sql =
        SELECT_JOIN_BASE
            + "WHERE a.status = ? ORDER BY a.appointment_date DESC, a.appointment_time DESC";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setString(1, status);
      try (ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
          list.add(mapResultSetToAppointment(rs));
        }
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public boolean checkDoctorConflict(
      String doctorId, String date, String time, int excludeAppointmentId) {
    String sql =
        "SELECT COUNT(*) FROM appointments "
            + "WHERE doctor_id = ? "
            + "  AND appointment_date = ? "
            + "  AND appointment_time = ? "
            + "  AND status NOT IN ('Cancelled','No-show') "
            + "  AND (? <= 0 OR appointment_id != ?)";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setString(1, doctorId);
      stmt.setDate(2, Date.valueOf(date));
      stmt.setTime(3, Time.valueOf(formatTimeToSql(time)));
      stmt.setInt(4, excludeAppointmentId);
      stmt.setInt(5, excludeAppointmentId);

      try (ResultSet rs = stmt.executeQuery()) {
        if (rs.next()) {
          return rs.getInt(1) > 0;
        }
      }
    } catch (Exception e) {
      throw new IllegalStateException("Cannot check appointment availability", e);
    }
    return false;
  }

  private String formatTimeToSql(String time) {
    if (time == null || time.trim().isEmpty()) {
      return "09:00:00";
    }
    String clean = time.trim();
    if (clean.length() == 5) {
      return clean + ":00";
    }
    return clean;
  }
}
