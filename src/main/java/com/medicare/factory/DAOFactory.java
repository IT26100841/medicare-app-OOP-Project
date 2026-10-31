package com.medicare.factory;

import com.medicare.dao.AppointmentDAO;
import com.medicare.dao.BillDAO;
import com.medicare.dao.DoctorDAO;
import com.medicare.dao.MedicalRecordDAO; // Added Import
import com.medicare.dao.NotificationDAO;
import com.medicare.dao.PatientDAO;
import com.medicare.dao.UserDAO;
import com.medicare.dao.impl.AppointmentDAODBImpl;
import com.medicare.dao.impl.AppointmentDAOFileImpl;
import com.medicare.dao.impl.BillDAODBImpl;
import com.medicare.dao.impl.DoctorDAODBImpl;
import com.medicare.dao.impl.DoctorDAOFileImpl;
import com.medicare.dao.impl.MedicalRecordDAODBImpl; // Added Import
import com.medicare.dao.impl.MedicalRecordDAOFileImpl; // Added Import
import com.medicare.dao.impl.NotificationDAODBImpl;
import com.medicare.dao.impl.PatientDAODBImpl;
import com.medicare.dao.impl.PatientDAOFileImpl;
import com.medicare.dao.impl.UserDAODBImpl;
import com.medicare.dao.impl.UserDAOFileImpl;

public class DAOFactory {
  private static volatile String storageMode = initialMode(); // Default DB mode

  private static String initialMode() {
    String override = System.getProperty("medicare.storage");
    if (override != null) return "DB".equalsIgnoreCase(override) ? "DB" : "FILE";
    try {
      java.nio.file.Path config = com.medicare.util.DataPaths.root().resolve("storage-mode.txt");
      if (java.nio.file.Files.exists(config))
        return "DB".equalsIgnoreCase(java.nio.file.Files.readString(config).trim()) ? "DB" : "FILE";
    } catch (java.io.IOException e) {
      throw new IllegalStateException(e);
    }
    return "FILE";
  }

  public static synchronized void setStorageMode(String mode) {
    if (!"DB".equalsIgnoreCase(mode) && !"FILE".equalsIgnoreCase(mode))
      throw new IllegalArgumentException("Storage mode must be FILE or DB");
    String selected = mode.toUpperCase(java.util.Locale.ROOT);
    try {
      java.nio.file.Path config = com.medicare.util.DataPaths.root().resolve("storage-mode.txt");
      java.nio.file.Path temp =
          java.nio.file.Files.createTempFile(config.getParent(), "mode", ".tmp");
      java.nio.file.Files.writeString(temp, selected);
      try {
        java.nio.file.Files.move(
            temp,
            config,
            java.nio.file.StandardCopyOption.REPLACE_EXISTING,
            java.nio.file.StandardCopyOption.ATOMIC_MOVE);
      } catch (java.nio.file.AtomicMoveNotSupportedException e) {
        java.nio.file.Files.move(temp, config, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
      }
    } catch (java.io.IOException e) {
      throw new IllegalStateException("Cannot save storage mode", e);
    }
    storageMode = selected;
  }

  public static String getStorageMode() {
    return storageMode;
  }

  public static PatientDAO getPatientDAO() {
    if ("FILE".equalsIgnoreCase(storageMode)) {
      return new PatientDAOFileImpl();
    }
    return new PatientDAODBImpl();
  }

  public static DoctorDAO getDoctorDAO() {
    if ("FILE".equalsIgnoreCase(storageMode)) {
      return new DoctorDAOFileImpl();
    }
    return new DoctorDAODBImpl();
  }

  public static UserDAO getUserDAO() {
    if ("FILE".equalsIgnoreCase(storageMode)) {
      return new UserDAOFileImpl();
    }
    return new UserDAODBImpl();
  }

  // Medical Record DAO Method
  public static MedicalRecordDAO getMedicalRecordDAO() {
    if ("FILE".equalsIgnoreCase(storageMode)) {
      return new MedicalRecordDAOFileImpl();
    }
    return new MedicalRecordDAODBImpl();
  }

  // Billing & Notification DAO Methods
  public static BillDAO getBillDAO() {
    return "FILE".equalsIgnoreCase(storageMode)
        ? new com.medicare.dao.impl.BillDAOFileImpl()
        : new BillDAODBImpl();
  }

  public static NotificationDAO getNotificationDAO() {
    return "FILE".equalsIgnoreCase(storageMode)
        ? new com.medicare.dao.impl.NotificationDAOFileImpl()
        : new NotificationDAODBImpl();
  }

  // Appointment DAO Method
  public static AppointmentDAO getAppointmentDAO() {
    if ("FILE".equalsIgnoreCase(storageMode)) {
      return new AppointmentDAOFileImpl();
    }
    return new AppointmentDAODBImpl();
  }
}
