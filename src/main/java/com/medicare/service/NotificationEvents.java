package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import java.sql.*;

public final class NotificationEvents {
  private NotificationEvents() {}

  public static String message(Appointment a, String event) {
    return "Appointment #"
        + a.getAppointmentId()
        + " "
        + event
        + ". Doctor: "
        + a.getDoctorId()
        + "; visit: "
        + a.getAppointmentDate()
        + " "
        + a.getAppointmentTime()
        + " (Asia/Colombo).";
  }

  public static void file(Appointment a, String event) {
    if (!DAOFactory.getNotificationDAO()
        .addNotification(new Notification(a.getPatientId(), message(a, event))))
      throw new IllegalStateException("Notification was not saved");
  }

  public static void db(Connection c, Appointment a, String event) throws SQLException {
    try (PreparedStatement s =
        c.prepareStatement("INSERT INTO notifications(patient_id,message) VALUES(?,?)")) {
      s.setString(1, a.getPatientId());
      s.setString(2, message(a, event));
      if (s.executeUpdate() != 1) throw new SQLException("Notification was not saved");
    }
  }
}
