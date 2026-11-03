package com.medicare.dao.impl;

import com.medicare.dao.BillDAO;
import com.medicare.model.Bill;
import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BillDAODBImpl implements BillDAO {

  @Override
  public boolean createBill(Bill bill) {
    try (Connection c = DBConnection.getConnection()) {
      boolean locked = false;
      try {
        try (PreparedStatement lock =
                c.prepareStatement("SELECT GET_LOCK('medicare.invoice.write.v1',10)");
            ResultSet rs = lock.executeQuery()) {
          locked = rs.next() && rs.getInt(1) == 1;
        }
        if (!locked) throw new SQLException("Invoice lock timeout");
        try (PreparedStatement check =
            c.prepareStatement("SELECT COUNT(*) FROM bills WHERE appointment_id=?")) {
          check.setInt(1, bill.getAppointmentId());
          try (ResultSet rs = check.executeQuery()) {
            if (rs.next() && rs.getInt(1) > 0) return false;
          }
        }
        try (PreparedStatement stmt =
            c.prepareStatement(
                "INSERT INTO bills(appointment_id,patient_id,amount,payment_method,payment_status)"
                    + " VALUES(?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
          stmt.setInt(1, bill.getAppointmentId());
          stmt.setString(2, bill.getPatientId());
          stmt.setDouble(3, bill.getAmount());
          stmt.setString(4, bill.getPaymentMethod());
          stmt.setString(5, bill.getPaymentStatus());
          if (stmt.executeUpdate() == 0) return false;
          try (ResultSet keys = stmt.getGeneratedKeys()) {
            if (keys.next()) bill.setBillId(keys.getInt(1));
          }
          return true;
        }
      } finally {
        if (locked)
          try (Statement s = c.createStatement()) {
            s.execute("SELECT RELEASE_LOCK('medicare.invoice.write.v1')");
          }
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Invoice write failed", e);
    }
  }

  @Override
  public List<Bill> getAllBills() {
    List<Bill> list = new ArrayList<>();
    String sql = "SELECT * FROM bills ORDER BY bill_id DESC";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {
      while (rs.next()) {
        list.add(
            new Bill(
                rs.getInt("bill_id"),
                rs.getInt("appointment_id"),
                rs.getString("patient_id"),
                rs.getDouble("amount"),
                rs.getString("payment_method"),
                rs.getString("payment_status")));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }

  @Override
  public Bill getBillById(int billId) {
    String sql = "SELECT * FROM bills WHERE bill_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, billId);
      ResultSet rs = stmt.executeQuery();
      if (rs.next()) {
        return new Bill(
            rs.getInt("bill_id"),
            rs.getInt("appointment_id"),
            rs.getString("patient_id"),
            rs.getDouble("amount"),
            rs.getString("payment_method"),
            rs.getString("payment_status"));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return null;
  }

  @Override
  public boolean updatePaymentStatus(int billId, String paymentMethod, String status) {
    String sql = "UPDATE bills SET payment_method = ?, payment_status = ? WHERE bill_id = ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, paymentMethod);
      stmt.setString(2, status);
      stmt.setInt(3, billId);
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }
}
