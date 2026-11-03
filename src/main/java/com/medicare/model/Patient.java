package com.medicare.model;

public class Patient extends Person {
  @Override
  public String getRoleLabel() {
    return "Patient";
  }

  private String id;
  private String name;
  private String email;
  private int age;
  private String gender;
  private String phone;
  private String contact;
  private String address;
  private String bloodGroup;
  private String allergies;
  private String medicalHistory;

  // 1. Default Constructor
  public Patient() {}

  // 2. 6-String Constructor (PatientDAOFileImpl සඳහා - Line 27 Error එක විසඳීමට)
  public Patient(
      String id, String name, String ageStr, String gender, String contact, String address) {
    this.id = id;
    this.name = name;
    try {
      this.age = Integer.parseInt(ageStr.trim());
    } catch (Exception e) {
      this.age = 0;
    }
    this.gender = gender;
    this.contact = contact;
    this.phone = contact;
    this.address = address;
  }

  // 3. 4-Parameter Constructor (AddPatientServlet සඳහා)
  public Patient(String name, int age, String gender, String contact) {
    this.name = name;
    this.age = age;
    this.gender = gender;
    this.contact = contact;
    this.phone = contact;
  }

  // 4. 5-Parameter Constructor with String ID (EditPatientServlet සඳහා)
  public Patient(String id, String name, int age, String gender, String contact) {
    this.id = id;
    this.name = name;
    this.age = age;
    this.gender = gender;
    this.contact = contact;
    this.phone = contact;
  }

  // 5. 5-Parameter Constructor with int ID
  public Patient(int id, String name, int age, String gender, String contact) {
    this.id = String.valueOf(id);
    this.name = name;
    this.age = age;
    this.gender = gender;
    this.contact = contact;
    this.phone = contact;
  }

  // 6. Full Constructor (Database Implementation සඳහා)
  public Patient(
      String id,
      String name,
      String email,
      int age,
      String gender,
      String phone,
      String address,
      String bloodGroup,
      String allergies,
      String medicalHistory) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.age = age;
    this.gender = gender;
    this.phone = phone;
    this.contact = phone;
    this.address = address;
    this.bloodGroup = bloodGroup;
    this.allergies = allergies;
    this.medicalHistory = medicalHistory;
  }

  // --- Getters & Setters ---

  public String getPatientId() {
    return id;
  }

  public void setPatientId(String patientId) {
    this.id = patientId;
  }

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

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public int getAge() {
    return age;
  }

  public void setAge(int age) {
    this.age = age;
  }

  public String getGender() {
    return gender;
  }

  public void setGender(String gender) {
    this.gender = gender;
  }

  public String getPhone() {
    return phone != null ? phone : contact;
  }

  public void setPhone(String phone) {
    this.phone = phone;
    this.contact = phone;
  }

  public String getContact() {
    return contact != null ? contact : phone;
  }

  public void setContact(String contact) {
    this.contact = contact;
    this.phone = contact;
  }

  public String getAddress() {
    return address;
  }

  public void setAddress(String address) {
    this.address = address;
  }

  public String getBloodGroup() {
    return bloodGroup;
  }

  public void setBloodGroup(String bloodGroup) {
    this.bloodGroup = bloodGroup;
  }

  public String getAllergies() {
    return allergies;
  }

  public void setAllergies(String allergies) {
    this.allergies = allergies;
  }

  public String getMedicalHistory() {
    return medicalHistory;
  }

  public void setMedicalHistory(String medicalHistory) {
    this.medicalHistory = medicalHistory;
  }
}
