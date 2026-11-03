package com.medicare.dao.impl;

import com.medicare.dao.DoctorDAO;
import com.medicare.model.Doctor;
import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAODBImpl implements DoctorDAO {

  @Override
  public boolean addDoctor(Doctor doctor) {
    String sql =
        "INSERT INTO doctors (id, name, specialization, qualification, phone, email,"
            + " consultation_fee) VALUES (?, ?, ?, ?, ?, ?, ?)";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, doctor.getId());
      stmt.setString(2, doctor.getName());
      stmt.setString(3, doctor.getSpecialization());
      stmt.setString(4, doctor.getQualification());
      stmt.setString(5, doctor.getPhone());
      stmt.setString(6, doctor.getEmail());
      stmt.setDouble(7, doctor.getConsultationFee());
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public List<Doctor> getAllDoctors() {
    List<Doctor> doctors = new ArrayList<>();
    String sql = "SELECT * FROM doctors";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {
      while (rs.next()) {
        Doctor d =
            new Doctor(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("specialization"),
                rs.getString("qualification"),
                rs.getString("phone"),
                rs.getString("email"),
                rs.getDouble("consultation_fee"));
        doctors.add(d);
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return doctors;
  }

  @Override
  public Doctor getDoctorById(String id) {
    String sql = "SELECT * FROM doctors WHERE id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, id);
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        return new Doctor(
            rs.getString("id"),
            rs.getString("name"),
            rs.getString("specialization"),
            rs.getString("qualification"),
            rs.getString("phone"),
            rs.getString("email"),
            rs.getDouble("consultation_fee"));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return null;
  }

  @Override
  public List<Doctor> searchDoctors(String keyword) {
    List<Doctor> doctors = new ArrayList<>();
    String sql = "SELECT * FROM doctors WHERE name LIKE ? OR specialization LIKE ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, "%" + keyword + "%");
      stmt.setString(2, "%" + keyword + "%");
      ResultSet rs = stmt.executeQuery();
      while (rs.next()) {
        Doctor d =
            new Doctor(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("specialization"),
                rs.getString("qualification"),
                rs.getString("phone"),
                rs.getString("email"),
                rs.getDouble("consultation_fee"));
        doctors.add(d);
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return doctors;
  }

  @Override
  public boolean updateDoctor(Doctor doctor) {
    String sql =
        "UPDATE doctors SET name=?, specialization=?, qualification=?, phone=?, email=?,"
            + " consultation_fee=? WHERE id=?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, doctor.getName());
      stmt.setString(2, doctor.getSpecialization());
      stmt.setString(3, doctor.getQualification());
      stmt.setString(4, doctor.getPhone());
      stmt.setString(5, doctor.getEmail());
      stmt.setDouble(6, doctor.getConsultationFee());
      stmt.setString(7, doctor.getId());
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public boolean deleteDoctor(String id) {
    String sql = "DELETE FROM doctors WHERE id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, id);
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }
}
