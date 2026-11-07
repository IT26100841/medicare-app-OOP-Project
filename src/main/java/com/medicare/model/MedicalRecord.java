package com.medicare.model;

public class MedicalRecord {
  private int recordId;
  private String patientId;
  private String doctorId;
  private int appointmentId;
  private String diagnosis;
  private String prescription;
  private String notes;
  private String recordDate;

  public MedicalRecord() {}

  public MedicalRecord(
      int recordId,
      String patientId,
      String doctorId,
      int appointmentId,
      String diagnosis,
      String prescription,
      String notes,
      String recordDate) {
    this.recordId = recordId;
    this.patientId = patientId;
    this.doctorId = doctorId;
    this.appointmentId = appointmentId;
    this.diagnosis = diagnosis;
    this.prescription = prescription;
    this.notes = notes;
    this.recordDate = recordDate;
  }

  public MedicalRecord(
      String patientId,
      String doctorId,
      int appointmentId,
      String diagnosis,
      String prescription,
      String notes,
      String recordDate) {
    this.patientId = patientId;
    this.doctorId = doctorId;
    this.appointmentId = appointmentId;
    this.diagnosis = diagnosis;
    this.prescription = prescription;
    this.notes = notes;
    this.recordDate = recordDate;
  }

  public int getRecordId() {
    return recordId;
  }

  public void setRecordId(int recordId) {
    this.recordId = recordId;
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

  public int getAppointmentId() {
    return appointmentId;
  }

  public void setAppointmentId(int appointmentId) {
    this.appointmentId = appointmentId;
  }

  public String getDiagnosis() {
    return diagnosis;
  }

  public void setDiagnosis(String diagnosis) {
    this.diagnosis = diagnosis;
  }

  public String getPrescription() {
    return prescription;
  }

  public void setPrescription(String prescription) {
    this.prescription = prescription;
  }

  public String getNotes() {
    return notes;
  }

  public void setNotes(String notes) {
    this.notes = notes;
  }

  public String getRecordDate() {
    return recordDate;
  }

  public void setRecordDate(String recordDate) {
    this.recordDate = recordDate;
  }

  public String toFileString() {
    return recordId
        + ","
        + patientId
        + ","
        + doctorId
        + ","
        + appointmentId
        + ","
        + diagnosis
        + ","
        + prescription
        + ","
        + notes
        + ","
        + recordDate;
  }
}
