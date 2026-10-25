package com.medicare.factory;

import com.medicare.dao.DoctorDAO;
import com.medicare.dao.PatientDAO;
import com.medicare.dao.UserDAO;
import com.medicare.dao.MedicalRecordDAO; // Added Import
import com.medicare.dao.BillDAO;
import com.medicare.dao.NotificationDAO;

import com.medicare.dao.impl.DoctorDAODBImpl;
import com.medicare.dao.impl.DoctorDAOFileImpl;
import com.medicare.dao.impl.PatientDAODBImpl;
import com.medicare.dao.impl.PatientDAOFileImpl;
import com.medicare.dao.impl.UserDAODBImpl;
import com.medicare.dao.impl.UserDAOFileImpl;
import com.medicare.dao.impl.MedicalRecordDAODBImpl; // Added Import
import com.medicare.dao.impl.MedicalRecordDAOFileImpl; // Added Import
import com.medicare.dao.impl.BillDAODBImpl;
import com.medicare.dao.impl.NotificationDAODBImpl;

import com.medicare.dao.AppointmentDAO;
import com.medicare.dao.impl.AppointmentDAODBImpl;
import com.medicare.dao.impl.AppointmentDAOFileImpl;

public class DAOFactory {
    private static String storageMode = "DB"; // Default DB mode

    public static void setStorageMode(String mode) {
        storageMode = mode;
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
        return new BillDAODBImpl();
    }

    public static NotificationDAO getNotificationDAO() {
        return new NotificationDAODBImpl();
    }

    // Appointment DAO Method
    public static AppointmentDAO getAppointmentDAO() {
        if ("FILE".equalsIgnoreCase(storageMode)) {
            return new AppointmentDAOFileImpl();
        }
        return new AppointmentDAODBImpl();
    }
}