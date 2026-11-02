package com.medicare.model;

public class AuditEntry {
  private int logId;

  public int getLogId() {
    return logId;
  }

  public void setLogId(int value) {
    logId = value;
  }

  private String username;

  public String getUsername() {
    return username;
  }

  public void setUsername(String value) {
    username = value;
  }

  private String userRole;

  public String getUserRole() {
    return userRole;
  }

  public void setUserRole(String value) {
    userRole = value;
  }

  private String action;

  public String getAction() {
    return action;
  }

  public void setAction(String value) {
    action = value;
  }

  private String ipAddress;

  public String getIpAddress() {
    return ipAddress;
  }

  public void setIpAddress(String value) {
    ipAddress = value;
  }

  private String timestamp;

  public String getTimestamp() {
    return timestamp;
  }

  public void setTimestamp(String value) {
    timestamp = value;
  }
}
