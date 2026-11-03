package com.medicare.model;

public class DocumentEntry {
  private int documentId;

  public int getDocumentId() {
    return documentId;
  }

  public void setDocumentId(int value) {
    documentId = value;
  }

  private String patientId;

  public String getPatientId() {
    return patientId;
  }

  public void setPatientId(String value) {
    patientId = value;
  }

  private String fileName;

  public String getFileName() {
    return fileName;
  }

  public void setFileName(String value) {
    fileName = value;
  }

  private String filePath;

  public String getFilePath() {
    return filePath;
  }

  public void setFilePath(String value) {
    filePath = value;
  }

  private String uploadedAt;

  public String getUploadedAt() {
    return uploadedAt;
  }

  public void setUploadedAt(String value) {
    uploadedAt = value;
  }
}
