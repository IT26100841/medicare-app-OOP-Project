package com.medicare.util;

public final class AuditLogger {
  private AuditLogger() {}

  public static void log(String username, String role, String action, String ip) {
    try {
      com.medicare.service.PortalData.audit(
          username == null ? "System" : username,
          role == null ? "GUEST" : role,
          action,
          ip == null ? "" : ip);
    } catch (RuntimeException e) {
      java.util.logging.Logger.getLogger(AuditLogger.class.getName())
          .log(java.util.logging.Level.WARNING, "Audit log could not be persisted", e);
    }
  }
}
