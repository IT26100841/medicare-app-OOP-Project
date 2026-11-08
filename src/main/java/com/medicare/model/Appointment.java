package com.medicare.model;

public class Appointment {
  private int appointmentId;
  private String patientId;
  private String doctorId;
  private String appointmentDate;
  private String appointmentTime;
  private String reason;
  private String status; // "Booked", "Completed", "Cancelled"

  // Display helpers (populated from JOIN queries)
  private String patientName;
  private String doctorName;
  private String doctorSpecialization;

  public Appointment() {
    this.status = "Booked";
  }

  public Appointment(
      int appointmentId,
      String patientId,
      String doctorId,
      String appointmentDate,
      String appointmentTime,
      String reason,
      String status) {
    this.appointmentId = appointmentId;
    this.patientId = patientId;
    this.doctorId = doctorId;
    this.appointmentDate = appointmentDate;
    this.appointmentTime = appointmentTime;
    this.reason = reason;
    this.status = (status != null && !status.isEmpty()) ? status : "Booked";
  }

  public Appointment(
      String patientId,
      String doctorId,
      String appointmentDate,
      String appointmentTime,
      String reason,
      String status) {
    this.patientId = patientId;
    this.doctorId = doctorId;
    this.appointmentDate = appointmentDate;
    this.appointmentTime = appointmentTime;
    this.reason = reason;
    this.status = (status != null && !status.isEmpty()) ? status : "Booked";
  }

  // Getters and Setters
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

  public String getDoctorId() {
    return doctorId;
  }

  public void setDoctorId(String doctorId) {
    this.doctorId = doctorId;
  }

  public String getAppointmentDate() {
    return appointmentDate;
  }

  public void setAppointmentDate(String appointmentDate) {
    this.appointmentDate = appointmentDate;
  }

  public String getAppointmentTime() {
    return appointmentTime;
  }

  public void setAppointmentTime(String appointmentTime) {
    this.appointmentTime = appointmentTime;
  }

  public String getReason() {
    return reason;
  }

  public void setReason(String reason) {
    this.reason = reason;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }

  public String getPatientName() {
    return patientName != null ? patientName : "Patient #" + patientId;
  }

  public void setPatientName(String patientName) {
    this.patientName = patientName;
  }

  public String getDoctorName() {
    return doctorName != null ? doctorName : "Doctor #" + doctorId;
  }

  public void setDoctorName(String doctorName) {
    this.doctorName = doctorName;
  }

  public String getDoctorSpecialization() {
    return doctorSpecialization != null ? doctorSpecialization : "";
  }

  public void setDoctorSpecialization(String doctorSpecialization) {
    this.doctorSpecialization = doctorSpecialization;
  }

  public String toFileString() {
    // appointmentId,patientId,doctorId,appointmentDate,appointmentTime,reason,status
    String sanitizedReason = (reason != null) ? reason.replace(",", ";") : "";
    return appointmentId
        + ","
        + patientId
        + ","
        + doctorId
        + ","
        + appointmentDate
        + ","
        + appointmentTime
        + ","
        + sanitizedReason
        + ","
        + status;
  }
}
