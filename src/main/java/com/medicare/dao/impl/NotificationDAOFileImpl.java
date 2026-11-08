package com.medicare.dao.impl;

import com.medicare.dao.NotificationDAO;
import com.medicare.model.Notification;
import java.util.*;

public class NotificationDAOFileImpl extends AbstractFileDAO<Notification>
    implements NotificationDAO {
  public NotificationDAOFileImpl() {
    super(
        "notifications.txt", Notification.class, "notificationId", "patientId", "message", "date");
  }

  public List<Notification> getAllNotifications() {
    return readAll();
  }

  public boolean addNotification(Notification n) {
    synchronized (LOCK) {
      n.setNotificationId(
          readAll().stream().mapToInt(Notification::getNotificationId).max().orElse(0) + 1);
      n.setDate(java.time.LocalDateTime.now().toString());
      return insert(n);
    }
  }
}
