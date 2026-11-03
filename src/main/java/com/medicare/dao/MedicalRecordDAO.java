package com.medicare.dao;

import com.medicare.model.MedicalRecord;
import java.util.List;

public interface MedicalRecordDAO {
  boolean addMedicalRecord(MedicalRecord record);

  List<MedicalRecord> getAllMedicalRecords();

  MedicalRecord getMedicalRecordById(int recordId);

  List<MedicalRecord> getMedicalRecordsByPatientId(String patientId);

  boolean updateMedicalRecord(MedicalRecord record);

  boolean deleteMedicalRecord(int recordId);
}
