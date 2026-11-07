package com.medicare.model;

public class Bill {
  private int billId;
  private int appointmentId;
  private String patientId;
  private double amount;
  private double consultationCharge = -1;
  private double hospitalCharge;
  private double treatmentCharge;

  public double getConsultationCharge() {
    return consultationCharge < 0 ? amount : consultationCharge;
  }

  public void setConsultationCharge(double v) {
    consultationCharge = v;
  }

  public double getHospitalCharge() {
    return hospitalCharge;
  }

  public void setHospitalCharge(double v) {
    hospitalCharge = v;
  }

  public double getTreatmentCharge() {
    return treatmentCharge;
  }

  public void setTreatmentCharge(double v) {
    treatmentCharge = v;
  }

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
