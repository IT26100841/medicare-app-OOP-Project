package com.medicare.dao;

import com.medicare.model.Notification;
import java.util.List;

public interface NotificationDAO {
  boolean addNotification(Notification notification);

  List<Notification> getAllNotifications();
}
