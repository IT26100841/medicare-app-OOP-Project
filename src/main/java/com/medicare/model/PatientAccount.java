package com.medicare.model;

public class PatientAccount {
  private String email, patientId, passwordHash;

  public PatientAccount() {}

  public String getEmail() {
    return email;
  }

  public void setEmail(String v) {
    email = v;
  }

  public String getPatientId() {
    return patientId;
  }

  public void setPatientId(String v) {
    patientId = v;
  }

  public String getPasswordHash() {
    return passwordHash;
  }

  public void setPasswordHash(String v) {
    passwordHash = v;
  }
}
