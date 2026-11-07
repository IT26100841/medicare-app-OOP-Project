package com.medicare.dao.impl;

import com.medicare.dao.PatientDAO;
import com.medicare.model.Patient;
import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientDAODBImpl implements PatientDAO {

  @Override
  public boolean addPatient(Patient patient) {
    String sql =
        "INSERT INTO patients (name, email, age, gender, phone, address, blood_group, allergies,"
            + " medical_history) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

      stmt.setString(1, patient.getName());
      stmt.setString(2, patient.getEmail());
      stmt.setInt(3, patient.getAge());
      stmt.setString(4, patient.getGender());
      stmt.setString(5, patient.getPhone());
      stmt.setString(6, patient.getAddress());
      stmt.setString(7, patient.getBloodGroup());
      stmt.setString(8, patient.getAllergies());
      stmt.setString(9, patient.getMedicalHistory());

      boolean added = stmt.executeUpdate() > 0;
      if (added)
        try (ResultSet keys = stmt.getGeneratedKeys()) {
          if (keys.next()) patient.setId(String.valueOf(keys.getInt(1)));
        }
      return added;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public List<Patient> getAllPatients() {
    List<Patient> list = new ArrayList<>();
    String sql = "SELECT * FROM patients ORDER BY id DESC";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {

      while (rs.next()) {
        list.add(mapResultSetToPatient(rs));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public Patient getPatientById(String id) {
    if (id == null || !id.matches("[0-9]+")) return null;
    String sql = "SELECT * FROM patients WHERE id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setInt(1, Integer.parseInt(id));
      ResultSet rs = stmt.executeQuery();

      if (rs.next()) {
        return mapResultSetToPatient(rs);
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return null;
  }

  @Override
  public List<Patient> searchPatients(String keyword) {
    List<Patient> list = new ArrayList<>();
    String sql = "SELECT * FROM patients WHERE name LIKE ? OR id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setString(1, "%" + keyword + "%");
      int idVal = -1;
      try {
        idVal = Integer.parseInt(keyword);
      } catch (NumberFormatException ignored) {
      }
      stmt.setInt(2, idVal);

      ResultSet rs = stmt.executeQuery();
      while (rs.next()) {
        list.add(mapResultSetToPatient(rs));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public boolean updatePatient(Patient patient) {
    String sql =
        "UPDATE patients SET name = ?, email = ?, age = ?, gender = ?, phone = ?, address = ?,"
            + " blood_group = ?, allergies = ?, medical_history = ? WHERE id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setString(1, patient.getName());
      stmt.setString(2, patient.getEmail());
      stmt.setInt(3, patient.getAge());
      stmt.setString(4, patient.getGender());
      stmt.setString(5, patient.getPhone());
      stmt.setString(6, patient.getAddress());
      stmt.setString(7, patient.getBloodGroup());
      stmt.setString(8, patient.getAllergies());
      stmt.setString(9, patient.getMedicalHistory());
      stmt.setInt(10, Integer.parseInt(patient.getId()));

      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public boolean deletePatient(String id) {
    String sql = "DELETE FROM patients WHERE id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {

      stmt.setInt(1, Integer.parseInt(id));
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  private Patient mapResultSetToPatient(ResultSet rs) throws SQLException {
    Patient p = new Patient();
    p.setId(String.valueOf(rs.getInt("id")));
    p.setName(rs.getString("name"));
    p.setEmail(rs.getString("email"));
    p.setAge(rs.getInt("age"));
    p.setGender(rs.getString("gender"));
    p.setPhone(rs.getString("phone"));
    p.setAddress(rs.getString("address"));
    p.setBloodGroup(rs.getString("blood_group"));
    p.setAllergies(rs.getString("allergies"));
    p.setMedicalHistory(rs.getString("medical_history"));
    return p;
  }
}
