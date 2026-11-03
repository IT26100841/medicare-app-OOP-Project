package com.medicare.dao.impl;

import com.medicare.dao.MedicalRecordDAO;
import com.medicare.model.MedicalRecord;
import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MedicalRecordDAODBImpl implements MedicalRecordDAO {

  @Override
  public boolean addMedicalRecord(MedicalRecord record) {
    String sql =
        "INSERT INTO medical_records (patient_id, doctor_id, appointment_id, diagnosis,"
            + " prescription, notes, record_date) VALUES (?, ?, ?, ?, ?, ?, ?)";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, record.getPatientId());
      stmt.setString(2, record.getDoctorId());
      if (record.getAppointmentId() <= 0) stmt.setNull(3, java.sql.Types.INTEGER);
      else stmt.setInt(3, record.getAppointmentId());
      stmt.setString(4, record.getDiagnosis());
      stmt.setString(5, record.getPrescription());
      stmt.setString(6, record.getNotes());
      stmt.setString(7, record.getRecordDate());
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public List<MedicalRecord> getAllMedicalRecords() {
    List<MedicalRecord> list = new ArrayList<>();
    String sql = "SELECT * FROM medical_records ORDER BY record_id DESC";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {
      while (rs.next()) {
        list.add(mapResultSet(rs));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public MedicalRecord getMedicalRecordById(int recordId) {
    String sql = "SELECT * FROM medical_records WHERE record_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, recordId);
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        return mapResultSet(rs);
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return null;
  }

  @Override
  public List<MedicalRecord> getMedicalRecordsByPatientId(String patientId) {
    List<MedicalRecord> list = new ArrayList<>();
    String sql = "SELECT * FROM medical_records WHERE patient_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, patientId);
      ResultSet rs = stmt.executeQuery();
      while (rs.next()) {
        list.add(mapResultSet(rs));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public boolean updateMedicalRecord(MedicalRecord record) {
    String sql =
        "UPDATE medical_records SET patient_id=?, doctor_id=?, appointment_id=?, diagnosis=?,"
            + " prescription=?, notes=?, record_date=? WHERE record_id=?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, record.getPatientId());
      stmt.setString(2, record.getDoctorId());
      if (record.getAppointmentId() <= 0) stmt.setNull(3, java.sql.Types.INTEGER);
      else stmt.setInt(3, record.getAppointmentId());
      stmt.setString(4, record.getDiagnosis());
      stmt.setString(5, record.getPrescription());
      stmt.setString(6, record.getNotes());
      stmt.setString(7, record.getRecordDate());
      stmt.setInt(8, record.getRecordId());
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public boolean deleteMedicalRecord(int recordId) {
    String sql = "DELETE FROM medical_records WHERE record_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, recordId);
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  private MedicalRecord mapResultSet(ResultSet rs) throws SQLException {
    return new MedicalRecord(
        rs.getInt("record_id"),
        rs.getString("patient_id"),
        rs.getString("doctor_id"),
        rs.getInt("appointment_id"),
        rs.getString("diagnosis"),
        rs.getString("prescription"),
        rs.getString("notes"),
        rs.getString("record_date"));
  }
}
