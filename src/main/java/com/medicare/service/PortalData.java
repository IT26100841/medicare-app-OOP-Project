package com.medicare.service;

import com.medicare.dao.impl.*;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.util.*;
import java.sql.*;
import java.time.*;
import java.util.*;
import javax.sql.rowset.*;

/** Persistence for audit, insurance and document metadata. JSPs receive disconnected row sets. */
public final class PortalData {
  private PortalData() {}

  private static boolean file() {
    return "FILE".equalsIgnoreCase(DAOFactory.getStorageMode());
  }

  private static EntryFileDAO<DocumentEntry> documents() {
    return new EntryFileDAO<>(
        "documents.txt",
        DocumentEntry.class,
        "documentId",
        "patientId",
        "fileName",
        "filePath",
        "uploadedAt");
  }

  private static EntryFileDAO<ClaimEntry> claims() {
    return new EntryFileDAO<>(
        "claims.txt",
        ClaimEntry.class,
        "claimId",
        "patientId",
        "providerName",
        "policyNumber",
        "claimAmount",
        "status",
        "createdAt");
  }

  private static EntryFileDAO<AuditEntry> audits() {
    return new EntryFileDAO<>(
        "audit_logs.txt",
        AuditEntry.class,
        "logId",
        "username",
        "userRole",
        "action",
        "ipAddress",
        "timestamp");
  }

  private static String now() {
    return LocalDateTime.now().toString().replace('T', ' ');
  }

  public static void audit(String username, String role, String action, String ip) {
    if (file()) {
      synchronized (AbstractFileDAO.LOCK) {
        AuditEntry a = new AuditEntry();
        a.setLogId(audits().list().stream().mapToInt(AuditEntry::getLogId).max().orElse(0) + 1);
        a.setUsername(username);
        a.setUserRole(role);
        a.setAction(action);
        a.setIpAddress(ip);
        a.setTimestamp(now());
        audits().save(a);
      }
      return;
    }
    execute(
        "INSERT INTO audit_logs (username,user_role,action,ip_address) VALUES (?,?,?,?)",
        username,
        role,
        action,
        ip);
  }

  public static void addDocument(String patient, String name, String path) {
    Validation.references(patient, null);
    if (file()) {
      synchronized (AbstractFileDAO.LOCK) {
        DocumentEntry d = new DocumentEntry();
        d.setDocumentId(
            documents().list().stream().mapToInt(DocumentEntry::getDocumentId).max().orElse(0) + 1);
        d.setPatientId(patient);
        d.setFileName(name);
        d.setFilePath(path);
        d.setUploadedAt(now());
        documents().save(d);
      }
      return;
    }
    execute(
        "INSERT INTO patient_documents (patient_id,file_name,file_path) VALUES (?,?,?)",
        patient,
        name,
        path);
  }

  public static void addClaim(String patient, String provider, String policy, double amount) {
    Validation.references(patient, null);
    Validation.required(provider, "Provider");
    Validation.required(policy, "Policy");
    Validation.amount(amount);
    if (file()) {
      synchronized (AbstractFileDAO.LOCK) {
        ClaimEntry c = new ClaimEntry();
        c.setClaimId(claims().list().stream().mapToInt(ClaimEntry::getClaimId).max().orElse(0) + 1);
        c.setPatientId(patient);
        c.setProviderName(provider);
        c.setPolicyNumber(policy);
        c.setClaimAmount(amount);
        c.setStatus("Pending");
        c.setCreatedAt(now());
        claims().save(c);
      }
      return;
    }
    execute(
        "INSERT INTO insurance_claims (patient_id,provider_name,policy_number,claim_amount,status)"
            + " VALUES (?,?,?,?,'Pending')",
        patient,
        provider,
        policy,
        amount);
  }

  public static void updateClaim(int id, String status) {
    if (!Arrays.asList("Approved", "Rejected", "Pending").contains(status))
      throw new IllegalArgumentException("Invalid claim status");
    if (file()) {
      synchronized (AbstractFileDAO.LOCK) {
        for (ClaimEntry c : claims().list())
          if (c.getClaimId() == id) {
            c.setStatus(status);
            claims().update(c, x -> x.getClaimId() == id);
            return;
          }
      }
      throw new IllegalArgumentException("Claim not found");
    }
    execute("UPDATE insurance_claims SET status=? WHERE claim_id=?", status, id);
  }

  private static void execute(String sql, Object... values) {
    try (Connection c = DBConnection.getConnection();
        PreparedStatement s = c.prepareStatement(sql)) {
      for (int i = 0; i < values.length; i++) s.setObject(i + 1, values[i]);
      if (s.executeUpdate() == 0) throw new IllegalArgumentException("Record not found");
    } catch (SQLException e) {
      throw new IllegalStateException("Database write failed", e);
    }
  }

  public static CachedRowSet query(String table) throws SQLException {
    if (!Arrays.asList("patient_documents", "insurance_claims", "audit_logs").contains(table))
      throw new IllegalArgumentException("Unknown table");
    CachedRowSet rows = RowSetProvider.newFactory().createCachedRowSet();
    if (!file()) {
      String id =
          table.equals("patient_documents")
              ? "document_id"
              : table.equals("insurance_claims") ? "claim_id" : "log_id";
      try (Connection c = DBConnection.getConnection();
          Statement s = c.createStatement();
          ResultSet rs = s.executeQuery("SELECT * FROM " + table + " ORDER BY " + id + " DESC")) {
        rows.populate(rs);
      }
      return rows;
    }
    String[] names;
    int[] types;
    List<Object[]> values = new ArrayList<>();
    if (table.equals("patient_documents")) {
      names = new String[] {"document_id", "patient_id", "file_name", "file_path", "uploaded_at"};
      types =
          new int[] {Types.INTEGER, Types.VARCHAR, Types.VARCHAR, Types.VARCHAR, Types.TIMESTAMP};
      for (DocumentEntry d : documents().list())
        values.add(
            new Object[] {
              d.getDocumentId(),
              d.getPatientId(),
              d.getFileName(),
              d.getFilePath(),
              Timestamp.valueOf(d.getUploadedAt())
            });
    } else if (table.equals("insurance_claims")) {
      names =
          new String[] {
            "claim_id",
            "patient_id",
            "provider_name",
            "policy_number",
            "claim_amount",
            "status",
            "created_at"
          };
      types =
          new int[] {
            Types.INTEGER,
            Types.VARCHAR,
            Types.VARCHAR,
            Types.VARCHAR,
            Types.DOUBLE,
            Types.VARCHAR,
            Types.TIMESTAMP
          };
      for (ClaimEntry c : claims().list())
        values.add(
            new Object[] {
              c.getClaimId(),
              c.getPatientId(),
              c.getProviderName(),
              c.getPolicyNumber(),
              c.getClaimAmount(),
              c.getStatus(),
              Timestamp.valueOf(c.getCreatedAt())
            });
    } else {
      names = new String[] {"log_id", "username", "user_role", "action", "ip_address", "timestamp"};
      types =
          new int[] {
            Types.INTEGER,
            Types.VARCHAR,
            Types.VARCHAR,
            Types.VARCHAR,
            Types.VARCHAR,
            Types.TIMESTAMP
          };
      for (AuditEntry a : audits().list())
        values.add(
            new Object[] {
              a.getLogId(),
              a.getUsername(),
              a.getUserRole(),
              a.getAction(),
              a.getIpAddress(),
              Timestamp.valueOf(a.getTimestamp())
            });
    }
    RowSetMetaDataImpl meta = new RowSetMetaDataImpl();
    meta.setColumnCount(names.length);
    for (int i = 0; i < names.length; i++) {
      meta.setColumnName(i + 1, names[i]);
      meta.setColumnLabel(i + 1, names[i]);
      meta.setColumnType(i + 1, types[i]);
    }
    rows.setMetaData(meta);
    for (Object[] data : values) {
      rows.moveToInsertRow();
      for (int i = 0; i < data.length; i++) rows.updateObject(i + 1, data[i]);
      rows.insertRow();
      rows.moveToCurrentRow();
    }
    rows.beforeFirst();
    return rows;
  }

  public static DocumentEntry getDocument(int id) throws SQLException {
    try (ResultSet rs = query("patient_documents")) {
      while (rs.next())
        if (rs.getInt("document_id") == id) {
          DocumentEntry d = new DocumentEntry();
          d.setDocumentId(id);
          d.setPatientId(rs.getString("patient_id"));
          d.setFileName(rs.getString("file_name"));
          d.setFilePath(rs.getString("file_path"));
          return d;
        }
    }
    return null;
  }
}
