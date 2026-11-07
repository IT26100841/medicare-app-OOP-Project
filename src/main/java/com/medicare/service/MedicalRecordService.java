package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.MedicalRecord;
import java.util.List;

public class MedicalRecordService {

  public boolean addMedicalRecord(MedicalRecord record) {
    com.medicare.util.Validation.record(record);
    if (record.getAppointmentId() > 0) {
      com.medicare.model.Appointment a =
          DAOFactory.getAppointmentDAO().getAppointmentById(record.getAppointmentId());
      if (!java.util.Arrays.asList("In consultation", "Completed").contains(a.getStatus()))
        throw new IllegalArgumentException("Start this consultation before adding clinical notes");
    }
    return DAOFactory.getMedicalRecordDAO().addMedicalRecord(record);
  }

  public List<MedicalRecord> getAllMedicalRecords() {
    return DAOFactory.getMedicalRecordDAO().getAllMedicalRecords();
  }

  public MedicalRecord getMedicalRecordById(int recordId) {
    return DAOFactory.getMedicalRecordDAO().getMedicalRecordById(recordId);
  }

  public boolean updateMedicalRecord(MedicalRecord record) {
    com.medicare.util.Validation.record(record);
    if (record.getAppointmentId() > 0) {
      com.medicare.model.Appointment a =
          DAOFactory.getAppointmentDAO().getAppointmentById(record.getAppointmentId());
      if (!java.util.Arrays.asList("In consultation", "Completed").contains(a.getStatus()))
        throw new IllegalArgumentException("Start this consultation before adding clinical notes");
    }
    return DAOFactory.getMedicalRecordDAO().updateMedicalRecord(record);
  }

  public boolean deleteMedicalRecord(int recordId) {
    com.medicare.model.MedicalRecord r =
        DAOFactory.getMedicalRecordDAO().getMedicalRecordById(recordId);
    if (r != null && r.getAppointmentId() > 0) {
      com.medicare.model.Appointment a =
          DAOFactory.getAppointmentDAO().getAppointmentById(r.getAppointmentId());
      long notes =
          DAOFactory.getMedicalRecordDAO().getAllMedicalRecords().stream()
              .filter(x -> x.getAppointmentId() == r.getAppointmentId())
              .count();
      if (a != null && "Completed".equals(a.getStatus()) && notes <= 1)
        throw new IllegalArgumentException("A completed visit must retain its clinical record");
    }
    return DAOFactory.getMedicalRecordDAO().deleteMedicalRecord(recordId);
  }
}
