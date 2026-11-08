package com.medicare.dao;

import com.medicare.model.Patient;
import java.util.List;

public interface PatientDAO {
  boolean addPatient(Patient patient);

  List<Patient> getAllPatients();

  Patient getPatientById(String id);

  List<Patient> searchPatients(String keyword);

  boolean updatePatient(Patient patient);

  boolean deletePatient(String id);
}
