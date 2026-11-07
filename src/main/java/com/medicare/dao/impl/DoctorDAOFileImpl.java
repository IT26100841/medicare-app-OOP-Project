package com.medicare.dao.impl;

import com.medicare.dao.DoctorDAO;
import com.medicare.model.Doctor;
import java.util.*;

public class DoctorDAOFileImpl extends AbstractFileDAO<Doctor> implements DoctorDAO {
  public DoctorDAOFileImpl() {
    super(
        "doctors.txt",
        Doctor.class,
        "id",
        "name",
        "specialization",
        "qualification",
        "phone",
        "email",
        "consultationFee");
  }

  public List<Doctor> getAllDoctors() {
    return readAll();
  }

  public Doctor getDoctorById(String id) {
    return find(d -> d.getId().equalsIgnoreCase(id));
  }

  public boolean addDoctor(Doctor d) {
    synchronized (LOCK) {
      d.setId(d.getId().trim());
      return getDoctorById(d.getId()) == null && insert(d);
    }
  }

  public boolean updateDoctor(Doctor d) {
    return replace(d, x -> x.getId().equalsIgnoreCase(d.getId()));
  }

  public boolean deleteDoctor(String id) {
    return remove(d -> d.getId().equalsIgnoreCase(id));
  }

  public List<Doctor> searchDoctors(String q) {
    return search(q, d -> d.getId() + " " + d.getName() + " " + d.getSpecialization());
  }
}
