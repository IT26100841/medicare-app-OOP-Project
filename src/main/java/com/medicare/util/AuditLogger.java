package com.medicare.util;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class AuditLogger {

    public static void log(String username, String role, String action, String ipAddress) {
        String sql = "INSERT INTO audit_logs (username, user_role, action, ip_address) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username != null ? username : "System");
            stmt.setString(2, role != null ? role : "GUEST");
            stmt.setString(3, action);
            stmt.setString(4, (ipAddress != null && !ipAddress.isEmpty()) ? ipAddress : "127.0.0.1");
            stmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}