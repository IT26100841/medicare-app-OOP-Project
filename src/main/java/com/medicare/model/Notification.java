package com.medicare.model;

public class Notification {
  private int notificationId;
  private String patientId;
  private String message;
  private String date;

  public Notification() {}

  public Notification(int notificationId, String patientId, String message, String date) {
    this.notificationId = notificationId;
    this.patientId = patientId;
    this.message = message;
    this.date = date;
  }

  public Notification(String patientId, String message) {
    this.patientId = patientId;
    this.message = message;
  }

  public int getNotificationId() {
    return notificationId;
  }

  public void setNotificationId(int notificationId) {
    this.notificationId = notificationId;
  }

  public String getPatientId() {
    return patientId;
  }

  public void setPatientId(String patientId) {
    this.patientId = patientId;
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }

  public String getDate() {
    return date;
  }

  public void setDate(String date) {
    this.date = date;
  }
}
