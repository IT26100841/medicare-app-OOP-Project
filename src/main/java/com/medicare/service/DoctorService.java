package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.Doctor;
import java.util.List;

public class DoctorService {

  public boolean addDoctor(Doctor doctor) {
    com.medicare.util.Validation.doctor(doctor);
    return DAOFactory.getDoctorDAO().addDoctor(doctor);
  }

  public List<Doctor> getAllDoctors() {
    return DAOFactory.getDoctorDAO().getAllDoctors();
  }

  public Doctor getDoctorById(String id) {
    return DAOFactory.getDoctorDAO().getDoctorById(id);
  }

  public List<Doctor> searchDoctors(String keyword) {
    return DAOFactory.getDoctorDAO().searchDoctors(keyword);
  }

  public boolean updateDoctor(Doctor doctor) {
    com.medicare.util.Validation.doctor(doctor);
    return DAOFactory.getDoctorDAO().updateDoctor(doctor);
  }

  public boolean deleteDoctor(String id) {
    for (com.medicare.model.Availability a : ClinicStore.availability())
      if (a.getDoctorId().equals(id))
        throw new IllegalArgumentException(
            "Remove this doctor's sessions before deleting the profile");
    for (com.medicare.model.User u : DAOFactory.getUserDAO().getAllUsers())
      if (id.equals(ClinicStore.doctorFor(u.getId())))
        throw new IllegalArgumentException(
            "Unlink this doctor's login account before deleting the profile");
    for (com.medicare.model.Appointment a : DAOFactory.getAppointmentDAO().getAllAppointments())
      if (a.getDoctorId().equalsIgnoreCase(id))
        throw new IllegalArgumentException("Cannot delete a doctor referenced by appointments");
    for (com.medicare.model.MedicalRecord r :
        DAOFactory.getMedicalRecordDAO().getAllMedicalRecords())
      if (r.getDoctorId().equalsIgnoreCase(id))
        throw new IllegalArgumentException("Cannot delete a doctor referenced by medical records");

    return DAOFactory.getDoctorDAO().deleteDoctor(id);
  }
}
