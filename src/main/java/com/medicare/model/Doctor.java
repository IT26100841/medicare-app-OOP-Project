package com.medicare.model;

public class Doctor extends Person {
  @Override
  public String getRoleLabel() {
    return "Doctor";
  }

  private String id;
  private String name;
  private String specialization;
  private String qualification;
  private String phone;
  private String email;
  private double consultationFee;

  public Doctor() {}

  public Doctor(
      String id,
      String name,
      String specialization,
      String qualification,
      String phone,
      String email,
      double consultationFee) {
    this.id = id;
    this.name = name;
    this.specialization = specialization;
    this.qualification = qualification;
    this.phone = phone;
    this.email = email;
    this.consultationFee = consultationFee;
  }

  // Getters and Setters
  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getSpecialization() {
    return specialization;
  }

  public void setSpecialization(String specialization) {
    this.specialization = specialization;
  }

  public String getQualification() {
    return qualification;
  }

  public void setQualification(String qualification) {
    this.qualification = qualification;
  }

  public String getPhone() {
    return phone;
  }

  public void setPhone(String phone) {
    this.phone = phone;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public double getConsultationFee() {
    return consultationFee;
  }

  public void setConsultationFee(double consultationFee) {
    this.consultationFee = consultationFee;
  }

  // Text File Mode සඳහා Helper Method එක
  public String toFileString() {
    return id
        + ","
        + name
        + ","
        + specialization
        + ","
        + qualification
        + ","
        + phone
        + ","
        + email
        + ","
        + consultationFee;
  }
}
