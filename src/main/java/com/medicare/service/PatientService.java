package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.Patient;
import java.util.List;

public class PatientService {

  public boolean addPatient(Patient patient) {
    com.medicare.util.Validation.patient(patient);
    return DAOFactory.getPatientDAO().addPatient(patient);
  }

  public List<Patient> getAllPatients() {
    return DAOFactory.getPatientDAO().getAllPatients();
  }

  public Patient getPatientById(String id) {
    return DAOFactory.getPatientDAO().getPatientById(id);
  }

  public List<Patient> searchPatients(String keyword) {
    return DAOFactory.getPatientDAO().searchPatients(keyword);
  }

  public boolean updatePatient(Patient patient) {
    com.medicare.util.Validation.patient(patient);
    return DAOFactory.getPatientDAO().updatePatient(patient);
  }

  public boolean deletePatient(String id) {
    for (com.medicare.model.Appointment a : DAOFactory.getAppointmentDAO().getAllAppointments())
      if (a.getPatientId().equalsIgnoreCase(id))
        throw new IllegalArgumentException("Cannot delete a patient referenced by appointments");
    for (com.medicare.model.MedicalRecord r :
        DAOFactory.getMedicalRecordDAO().getAllMedicalRecords())
      if (r.getPatientId().equalsIgnoreCase(id))
        throw new IllegalArgumentException("Cannot delete a patient referenced by medical records");
    for (com.medicare.model.Bill b : DAOFactory.getBillDAO().getAllBills())
      if (b.getPatientId().equalsIgnoreCase(id))
        throw new IllegalArgumentException("Cannot delete a patient referenced by bills");

    try {
      for (String table : new String[] {"patient_documents", "insurance_claims"})
        try (java.sql.ResultSet rs = PortalData.query(table)) {
          while (rs.next())
            if (id.equalsIgnoreCase(rs.getString("patient_id")))
              throw new IllegalArgumentException(
                  "Patient is referenced by documents or insurance claims");
        }
    } catch (java.sql.SQLException e) {
      throw new IllegalStateException("Cannot check patient references", e);
    }
    for (com.medicare.model.Notification n : DAOFactory.getNotificationDAO().getAllNotifications())
      if (id.equalsIgnoreCase(n.getPatientId()))
        throw new IllegalArgumentException("Patient is referenced by a notification");
    return DAOFactory.getPatientDAO().deletePatient(id);
  }
}
