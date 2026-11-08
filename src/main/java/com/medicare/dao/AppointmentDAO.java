package com.medicare.dao;

import com.medicare.model.Appointment;
import java.util.List;

public interface AppointmentDAO {
  boolean addAppointment(Appointment appointment);

  List<Appointment> getAllAppointments();

  Appointment getAppointmentById(int appointmentId);

  boolean updateAppointment(Appointment appointment);

  boolean cancelAppointment(int appointmentId);

  boolean deleteAppointment(int appointmentId);

  List<Appointment> searchAppointments(String keyword);

  List<Appointment> getAppointmentsByStatus(String status);

  boolean checkDoctorConflict(String doctorId, String date, String time, int excludeAppointmentId);
}
