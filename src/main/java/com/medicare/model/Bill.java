package com.medicare.model;

public class Bill {
  private int billId;
  private int appointmentId;
  private String patientId;
  private double amount;
  private String paymentMethod;
  private String paymentStatus; // Paid, Unpaid

  public Bill() {}

  public Bill(
      int billId,
      int appointmentId,
      String patientId,
      double amount,
      String paymentMethod,
      String paymentStatus) {
    this.billId = billId;
    this.appointmentId = appointmentId;
    this.patientId = patientId;
    this.amount = amount;
    this.paymentMethod = paymentMethod;
    this.paymentStatus = paymentStatus;
  }

  public Bill(
      int appointmentId,
      String patientId,
      double amount,
      String paymentMethod,
      String paymentStatus) {
    this.appointmentId = appointmentId;
    this.patientId = patientId;
    this.amount = amount;
    this.paymentMethod = paymentMethod;
    this.paymentStatus = paymentStatus;
  }

  public int getBillId() {
    return billId;
  }

  public void setBillId(int billId) {
    this.billId = billId;
  }

  public int getAppointmentId() {
    return appointmentId;
  }

  public void setAppointmentId(int appointmentId) {
    this.appointmentId = appointmentId;
  }

  public String getPatientId() {
    return patientId;
  }

  public void setPatientId(String patientId) {
    this.patientId = patientId;
  }

  public double getAmount() {
    return amount;
  }

  public void setAmount(double amount) {
    this.amount = amount;
  }

  public String getPaymentMethod() {
    return paymentMethod;
  }

  public void setPaymentMethod(String paymentMethod) {
    this.paymentMethod = paymentMethod;
  }

  public String getPaymentStatus() {
    return paymentStatus;
  }

  public void setPaymentStatus(String paymentStatus) {
    this.paymentStatus = paymentStatus;
  }
}
