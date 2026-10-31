package com.medicare.util;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import java.time.*;
import java.util.*;

public final class Validation {
  private Validation() {}

  public static String required(String value, String field) {
    if (value == null || value.isBlank())
      throw new IllegalArgumentException(field + " is required");
    return value.trim();
  }

  public static void patient(Patient p) {
    p.setName(required(p.getName(), "Patient name"));
    if (p.getAge() < 0 || p.getAge() > 120)
      throw new IllegalArgumentException("Age must be between 0 and 120");
    required(p.getContact(), "Contact");
    if (!Arrays.asList("Male", "Female", "Other").contains(p.getGender()))
      throw new IllegalArgumentException("Invalid gender");
    email(p.getEmail());
  }

  public static void email(String s) {
    if (s != null && !s.isBlank() && !s.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"))
      throw new IllegalArgumentException("Invalid email address");
  }

  public static void doctor(Doctor d) {
    d.setId(required(d.getId(), "Doctor ID"));
    d.setName(required(d.getName(), "Doctor name"));
    required(d.getSpecialization(), "Specialization");
    amount(d.getConsultationFee());
    email(d.getEmail());
  }

  public static void amount(double n) {
    if (!Double.isFinite(n) || n < 0)
      throw new IllegalArgumentException("Amount must be a finite positive number or zero");
  }

  public static void references(String patient, String doctor) {
    if (DAOFactory.getPatientDAO().getPatientById(required(patient, "Patient")) == null)
      throw new IllegalArgumentException("Patient does not exist");
    if (doctor != null
        && DAOFactory.getDoctorDAO().getDoctorById(required(doctor, "Doctor")) == null)
      throw new IllegalArgumentException("Doctor does not exist");
  }

  public static void appointment(Appointment a) {
    references(a.getPatientId(), a.getDoctorId());
    LocalDate date = LocalDate.parse(required(a.getAppointmentDate(), "Date"));
    LocalTime time = LocalTime.parse(required(a.getAppointmentTime(), "Time"));
    a.setAppointmentDate(date.toString());
    a.setAppointmentTime(time.toString());
    required(a.getReason(), "Reason");
    if (!java.util.Arrays.stream(AppointmentStatus.values())
        .anyMatch(s -> s.label().equals(a.getStatus())))
      throw new IllegalArgumentException("Invalid appointment status");
    if (a.getAppointmentId() <= 0 && LocalDateTime.of(date, time).isBefore(LocalDateTime.now()))
      throw new IllegalArgumentException("New appointments must be in the future");
  }

  public static void record(MedicalRecord r) {
    references(r.getPatientId(), r.getDoctorId());
    required(r.getDiagnosis(), "Diagnosis");
    required(r.getPrescription(), "Prescription");
    LocalDate.parse(required(r.getRecordDate(), "Record date"));
    if (r.getAppointmentId() > 0) {
      Appointment a = DAOFactory.getAppointmentDAO().getAppointmentById(r.getAppointmentId());
      if (a == null
          || !a.getPatientId().equals(r.getPatientId())
          || !a.getDoctorId().equals(r.getDoctorId()))
        throw new IllegalArgumentException("Appointment does not match patient and doctor");
    }
  }

  public static void bill(Bill b) {
    amount(b.getAmount());
    references(b.getPatientId(), null);
    Appointment a = DAOFactory.getAppointmentDAO().getAppointmentById(b.getAppointmentId());
    if (a == null || !a.getPatientId().equals(b.getPatientId()))
      throw new IllegalArgumentException("Appointment does not match patient");
    if (!Arrays.asList("Paid", "Unpaid").contains(b.getPaymentStatus()))
      throw new IllegalArgumentException("Invalid payment status");
    required(b.getPaymentMethod(), "Payment method");
  }
}
