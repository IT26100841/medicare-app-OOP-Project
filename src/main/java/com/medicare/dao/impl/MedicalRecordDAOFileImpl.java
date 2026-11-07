package com.medicare.dao.impl;

import com.medicare.dao.MedicalRecordDAO;
import com.medicare.model.MedicalRecord;
import java.util.*;

public class MedicalRecordDAOFileImpl extends AbstractFileDAO<MedicalRecord>
    implements MedicalRecordDAO {
  public MedicalRecordDAOFileImpl() {
    super(
        "medical_records.txt",
        MedicalRecord.class,
        "recordId",
        "patientId",
        "doctorId",
        "appointmentId",
        "diagnosis",
        "prescription",
        "notes",
        "recordDate");
  }

  public List<MedicalRecord> getAllMedicalRecords() {
    return readAll();
  }

  public MedicalRecord getMedicalRecordById(int id) {
    return find(r -> r.getRecordId() == id);
  }

  public List<MedicalRecord> getMedicalRecordsByPatientId(String id) {
    List<MedicalRecord> result = readAll();
    result.removeIf(r -> !r.getPatientId().equalsIgnoreCase(id));
    return result;
  }

  public boolean addMedicalRecord(MedicalRecord r) {
    synchronized (LOCK) {
      r.setRecordId(readAll().stream().mapToInt(MedicalRecord::getRecordId).max().orElse(0) + 1);
      return insert(r);
    }
  }

  public boolean updateMedicalRecord(MedicalRecord r) {
    return replace(r, x -> x.getRecordId() == r.getRecordId());
  }

  public boolean deleteMedicalRecord(int id) {
    return remove(r -> r.getRecordId() == id);
  }
}
