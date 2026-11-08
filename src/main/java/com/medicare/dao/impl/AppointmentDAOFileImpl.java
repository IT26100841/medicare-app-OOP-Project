package com.medicare.dao.impl;

import com.medicare.dao.AppointmentDAO;
import com.medicare.model.Appointment;
import java.time.*;
import java.util.*;

public class AppointmentDAOFileImpl extends AbstractFileDAO<Appointment> implements AppointmentDAO {
  public AppointmentDAOFileImpl() {
    super(
        "appointments.txt",
        Appointment.class,
        "appointmentId",
        "patientId",
        "doctorId",
        "appointmentDate",
        "appointmentTime",
        "reason",
        "status");
  }

  public List<Appointment> getAllAppointments() {
    List<Appointment> rows = readAll();
    for (Appointment a : rows) {
      var p = com.medicare.factory.DAOFactory.getPatientDAO().getPatientById(a.getPatientId());
      var d = com.medicare.factory.DAOFactory.getDoctorDAO().getDoctorById(a.getDoctorId());
      if (p != null) a.setPatientName(p.getName());
      if (d != null) {
        a.setDoctorName(d.getName());
        a.setDoctorSpecialization(d.getSpecialization());
      }
    }
    return rows;
  }

  public Appointment getAppointmentById(int id) {
    for (Appointment a : getAllAppointments()) if (a.getAppointmentId() == id) return a;
    return null;
  }

  public boolean addAppointment(Appointment a) {
    synchronized (LOCK) {
      if (active(a))
        for (Appointment x : readAll())
          if (x.getAppointmentId() != a.getAppointmentId()
              && active(x)
              && x.getPatientId().equals(a.getPatientId())
              && x.getAppointmentDate().equals(a.getAppointmentDate())
              && java.time.LocalTime.parse(x.getAppointmentTime())
                  .equals(java.time.LocalTime.parse(a.getAppointmentTime())))
            throw new IllegalArgumentException(
                "This patient already has an appointment at that time");
      if (active(a)
          && checkDoctorConflict(
              a.getDoctorId(), a.getAppointmentDate(), a.getAppointmentTime(), 0)) return false;
      a.setAppointmentId(
          readAll().stream().mapToInt(Appointment::getAppointmentId).max().orElse(0) + 1);
      return com.medicare.util.FileTransactions.run(
          () -> {
            if (!insert(a)) return false;
            if ("Booked".equals(a.getStatus()))
              com.medicare.service.NotificationEvents.file(a, "confirmed");
            return true;
          },
          "appointments.txt",
          "notifications.txt");
    }
  }

  public boolean updateAppointment(Appointment a) {
    synchronized (LOCK) {
      if (active(a))
        for (Appointment x : readAll())
          if (x.getAppointmentId() != a.getAppointmentId()
              && active(x)
              && x.getPatientId().equals(a.getPatientId())
              && x.getAppointmentDate().equals(a.getAppointmentDate())
              && java.time.LocalTime.parse(x.getAppointmentTime())
                  .equals(java.time.LocalTime.parse(a.getAppointmentTime())))
            throw new IllegalArgumentException(
                "This patient already has an appointment at that time");
      if (active(a)
          && checkDoctorConflict(
              a.getDoctorId(),
              a.getAppointmentDate(),
              a.getAppointmentTime(),
              a.getAppointmentId())) return false;
      Appointment before = getAppointmentById(a.getAppointmentId());
      if (before != null
          && !before.getStatus().equals(a.getStatus())
          && !com.medicare.model.AppointmentStatus.parse(before.getStatus())
              .canMoveTo(com.medicare.model.AppointmentStatus.parse(a.getStatus())))
        throw new IllegalArgumentException(
            "This appointment changed. Reload it before changing its status.");
      return com.medicare.util.FileTransactions.run(
          () -> {
            if (!replace(a, x -> x.getAppointmentId() == a.getAppointmentId())) return false;
            if (before != null
                && !"Cancelled".equals(before.getStatus())
                && "Cancelled".equals(a.getStatus()))
              com.medicare.service.NotificationEvents.file(a, "cancelled");
            return true;
          },
          "appointments.txt",
          "notifications.txt");
    }
  }

  public boolean cancelAppointment(int id) {
    synchronized (LOCK) {
      Appointment a = getAppointmentById(id);
      if (a == null) return false;
      a.setStatus("Cancelled");
      return updateAppointment(a);
    }
  }

  public boolean deleteAppointment(int id) {
    return remove(a -> a.getAppointmentId() == id);
  }

  public List<Appointment> searchAppointments(String q) {
    String term = q == null ? "" : q.toLowerCase(Locale.ROOT);
    List<Appointment> rows = getAllAppointments();
    rows.removeIf(
        a ->
            !(a.getAppointmentId()
                    + " "
                    + a.getPatientId()
                    + " "
                    + a.getDoctorId()
                    + " "
                    + a.getPatientName()
                    + " "
                    + a.getDoctorName()
                    + " "
                    + a.getReason()
                    + " "
                    + a.getStatus()
                    + " "
                    + a.getAppointmentDate())
                .toLowerCase(Locale.ROOT)
                .contains(term));
    return rows;
  }

  public List<Appointment> getAppointmentsByStatus(String s) {
    List<Appointment> rows = getAllAppointments();
    rows.removeIf(a -> !a.getStatus().equalsIgnoreCase(s));
    return rows;
  }

  private boolean active(Appointment a) {
    return com.medicare.model.AppointmentStatus.parse(a.getStatus()).reservesSlot();
  }

  public boolean checkDoctorConflict(String doctor, String date, String time, int exclude) {
    for (Appointment a : readAll())
      if (a.getAppointmentId() != exclude
          && active(a)
          && a.getDoctorId().equalsIgnoreCase(doctor)
          && LocalDate.parse(a.getAppointmentDate()).equals(LocalDate.parse(date))
          && LocalTime.parse(a.getAppointmentTime()).equals(LocalTime.parse(time))) return true;
    return false;
  }
}
