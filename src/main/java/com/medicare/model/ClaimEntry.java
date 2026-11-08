package com.medicare.model;

public class ClaimEntry {
  private int claimId;

  public int getClaimId() {
    return claimId;
  }

  public void setClaimId(int value) {
    claimId = value;
  }

  private String patientId;

  public String getPatientId() {
    return patientId;
  }

  public void setPatientId(String value) {
    patientId = value;
  }

  private String providerName;

  public String getProviderName() {
    return providerName;
  }

  public void setProviderName(String value) {
    providerName = value;
  }

  private String policyNumber;

  public String getPolicyNumber() {
    return policyNumber;
  }

  public void setPolicyNumber(String value) {
    policyNumber = value;
  }

  private double claimAmount;

  public double getClaimAmount() {
    return claimAmount;
  }

  public void setClaimAmount(double value) {
    claimAmount = value;
  }

  private String status;

  public String getStatus() {
    return status;
  }

  public void setStatus(String value) {
    status = value;
  }

  private String createdAt;

  public String getCreatedAt() {
    return createdAt;
  }

  public void setCreatedAt(String value) {
    createdAt = value;
  }
}
