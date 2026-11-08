package com.medicare.dao;

import com.medicare.model.Doctor;
import java.util.List;

public interface DoctorDAO {
  boolean addDoctor(Doctor doctor);

  List<Doctor> getAllDoctors();

  Doctor getDoctorById(String id);

  List<Doctor> searchDoctors(String keyword);

  boolean updateDoctor(Doctor doctor);

  boolean deleteDoctor(String id);
}
