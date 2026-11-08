package com.medicare.service;

import com.medicare.factory.DAOFactory;
import com.medicare.model.Appointment;
import java.util.List;

public class AppointmentService {

  public boolean isDoctorSlotAvailable(
      String doctorId, String date, String time, int excludeAppointmentId) {
    if (doctorId == null || date == null || time == null) {
      return false;
    }
    boolean conflict =
        DAOFactory.getAppointmentDAO()
            .checkDoctorConflict(doctorId.trim(), date.trim(), time.trim(), excludeAppointmentId);
    return !conflict;
  }

  public boolean addAppointment(Appointment appointment) {
    if (appointment == null) return false;
    com.medicare.util.Validation.appointment(appointment);
    if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
        && !"No-show".equalsIgnoreCase(appointment.getStatus())
        && !new ScheduleService()
            .scheduled(
                appointment.getDoctorId(),
                appointment.getAppointmentDate(),
                appointment.getAppointmentTime()))
      throw new IllegalArgumentException("Choose a time from the doctor's published schedule");
    // Check for doctor time slot conflict before adding
    if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
        && !isDoctorSlotAvailable(
            appointment.getDoctorId(),
            appointment.getAppointmentDate(),
            appointment.getAppointmentTime(),
            0)) {
      return false; // Slot is already booked
    }
    return DAOFactory.getAppointmentDAO().addAppointment(appointment);
  }

  public List<Appointment> getAllAppointments() {
    return DAOFactory.getAppointmentDAO().getAllAppointments();
  }

  public Appointment getAppointmentById(int appointmentId) {
    return DAOFactory.getAppointmentDAO().getAppointmentById(appointmentId);
  }

  public boolean updateAppointment(Appointment appointment) {
    if (appointment != null
        && "Booked".equals(appointment.getStatus())
        && !java.time.LocalDateTime.of(
                java.time.LocalDate.parse(appointment.getAppointmentDate()),
                java.time.LocalTime.parse(appointment.getAppointmentTime()))
            .isAfter(java.time.LocalDateTime.now()))
      throw new IllegalArgumentException("Rescheduled appointments must be in the future");
    if (appointment == null) return false;
    com.medicare.util.Validation.appointment(appointment);
    if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
        && !"No-show".equalsIgnoreCase(appointment.getStatus())
        && !new ScheduleService()
            .scheduled(
                appointment.getDoctorId(),
                appointment.getAppointmentDate(),
                appointment.getAppointmentTime()))
      throw new IllegalArgumentException("Choose a time from the doctor's published schedule");
    // Check conflict excluding current appointment
    if (!"Cancelled".equalsIgnoreCase(appointment.getStatus())
        && !isDoctorSlotAvailable(
            appointment.getDoctorId(),
            appointment.getAppointmentDate(),
            appointment.getAppointmentTime(),
            appointment.getAppointmentId())) {
      return false; // Slot already booked by another appointment
    }
    return DAOFactory.getAppointmentDAO().updateAppointment(appointment);
  }

  public boolean cancelAppointment(int appointmentId) {
    return DAOFactory.getAppointmentDAO().cancelAppointment(appointmentId);
  }

  public boolean deleteAppointment(int appointmentId) {
    for (com.medicare.model.Bill b : DAOFactory.getBillDAO().getAllBills())
      if (b.getAppointmentId() == appointmentId)
        throw new IllegalArgumentException("Appointment is referenced by a bill; cancel instead");
    for (com.medicare.model.MedicalRecord r :
        DAOFactory.getMedicalRecordDAO().getAllMedicalRecords())
      if (r.getAppointmentId() == appointmentId)
        throw new IllegalArgumentException(
            "Appointment is referenced by a medical record; cancel instead");
    return DAOFactory.getAppointmentDAO().deleteAppointment(appointmentId);
  }

  public List<Appointment> searchAppointments(String keyword) {
    return DAOFactory.getAppointmentDAO().searchAppointments(keyword);
  }

  public List<Appointment> getAppointmentsByStatus(String status) {
    return DAOFactory.getAppointmentDAO().getAppointmentsByStatus(status);
  }
}
