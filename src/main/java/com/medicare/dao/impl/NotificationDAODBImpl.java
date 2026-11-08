package com.medicare.dao.impl;

import com.medicare.dao.NotificationDAO;
import com.medicare.model.Notification;
import com.medicare.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAODBImpl implements NotificationDAO {

  @Override
  public boolean addNotification(Notification notification) {
    String sql = "INSERT INTO notifications (patient_id, message) VALUES (?, ?)";
    try (Connection conn = DBConnection.getConnection();
        PreparedStatement stmt = conn.prepareStatement(sql)) {
      stmt.setString(1, notification.getPatientId());
      stmt.setString(2, notification.getMessage());
      return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
  }

  @Override
  public List<Notification> getAllNotifications() {
    List<Notification> list = new ArrayList<>();
    String sql = "SELECT * FROM notifications ORDER BY notification_id DESC";
    try (Connection conn = DBConnection.getConnection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql)) {
      while (rs.next()) {
        list.add(
            new Notification(
                rs.getInt("notification_id"),
                rs.getString("patient_id"),
                rs.getString("message"),
                rs.getString("date")));
      }
    } catch (SQLException e) {
      throw new IllegalStateException("Database operation failed", e);
    }
    return list;
  }
}
