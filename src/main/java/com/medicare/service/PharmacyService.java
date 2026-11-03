package com.medicare.service;

import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PharmacyService {

  // Prescriptions ලියන විට Stock එකෙන් Auto Deduct වන Logic එක
  public static boolean deductStock(int medicineId, int quantityUsed) {
    if (quantityUsed <= 0) throw new IllegalArgumentException("Quantity must be positive");
    if ("FILE".equalsIgnoreCase(com.medicare.factory.DAOFactory.getStorageMode()))
      throw new UnsupportedOperationException("Pharmacy inventory requires DB mode");
    String sql =
        "UPDATE medicines SET stock_quantity = stock_quantity - ? WHERE medicine_id = ? AND"
            + " stock_quantity >= ?";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setInt(1, quantityUsed);
      stmt.setInt(2, medicineId);
      stmt.setInt(3, quantityUsed);
      return stmt.executeUpdate() > 0;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }

  // දින 30ක් ඇතුළත Expiry වන ඖෂධ සෙවීම
  public static List<String> getExpiringMedicinesAlerts() {
    List<String> alerts = new ArrayList<>();
    if ("FILE".equalsIgnoreCase(com.medicare.factory.DAOFactory.getStorageMode())) return alerts;
    String sql =
        "SELECT name, expiry_date FROM medicines WHERE expiry_date BETWEEN CURRENT_DATE AND"
            + " DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {
      while (rs.next()) {
        alerts.add(
            "Warning: Medicine '"
                + rs.getString("name")
                + "' expires on "
                + rs.getDate("expiry_date"));
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
    return alerts;
  }
}
