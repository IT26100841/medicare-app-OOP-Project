package com.medicare.dao.impl;

import com.medicare.dao.PatientDAO;
import com.medicare.model.Patient;
import java.util.*;

public class PatientDAOFileImpl extends AbstractFileDAO<Patient> implements PatientDAO {
  public PatientDAOFileImpl() {
    super(
        "patients.txt",
        Patient.class,
        "id",
        "name",
        "email",
        "age",
        "gender",
        "phone",
        "address",
        "bloodGroup",
        "allergies",
        "medicalHistory");
  }

  public List<Patient> getAllPatients() {
    return readAll();
  }

  public Patient getPatientById(String id) {
    return find(p -> p.getId().equalsIgnoreCase(id));
  }

  public boolean addPatient(Patient p) {
    synchronized (LOCK) {
      if (p.getId() == null || p.getId().isBlank())
        p.setId(
            "P-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase(java.util.Locale.ROOT));
      p.setId(p.getId().trim());
      return getPatientById(p.getId()) == null && insert(p);
    }
  }

  public boolean updatePatient(Patient p) {
    return replace(p, x -> x.getId().equalsIgnoreCase(p.getId()));
  }

  public boolean deletePatient(String id) {
    return remove(p -> p.getId().equalsIgnoreCase(id));
  }

  public List<Patient> searchPatients(String q) {
    return search(
        q, p -> p.getId() + " " + p.getName() + " " + p.getContact() + " " + p.getAddress());
  }
}
