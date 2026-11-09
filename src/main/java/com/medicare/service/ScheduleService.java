package com.medicare.service;

import com.medicare.dao.impl.AbstractFileDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.util.Validation;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class ScheduleService {
  public List<Availability> list() {
    return ClinicStore.availability();
  }

  public boolean save(Availability a) {
    synchronized (AbstractFileDAO.LOCK) {
      if (DAOFactory.getDoctorDAO().getDoctorById(a.getDoctorId()) == null)
        throw new IllegalArgumentException("Doctor not found");
      LocalTime start = LocalTime.parse(Validation.required(a.getStartTime(), "Start time"));
      LocalTime end = LocalTime.parse(Validation.required(a.getEndTime(), "End time"));
      if (a.getDayOfWeek() < 1
          || a.getDayOfWeek() > 7
          || !end.isAfter(start)
          || a.getSlotMinutes() < 5
          || a.getSlotMinutes() > 120
          || java.time.Duration.between(start, end).toMinutes() < a.getSlotMinutes())
        throw new IllegalArgumentException(
            "Choose a valid day, time range and slot duration (5-120 minutes)");
      for (Availability other : list())
        if (other.getId() != a.getId()
            && other.getDoctorId().equals(a.getDoctorId())
            && other.getDayOfWeek() == a.getDayOfWeek()
            && start.isBefore(LocalTime.parse(other.getEndTime()))
            && end.isAfter(LocalTime.parse(other.getStartTime())))
          throw new IllegalArgumentException("This schedule overlaps an existing session");
      if (a.getId() > 0)
        for (Availability old : list()) if (old.getId() == a.getId()) guardChanges(old);
      a.setStartTime(start.toString());
      a.setEndTime(end.toString());
      return ClinicStore.save(a);
    }
  }

  public boolean delete(int id) {
    for (Availability old : list()) if (old.getId() == id) guardChanges(old);
    return ClinicStore.delete(id);
  }

  private void guardChanges(Availability old) {
    for (Appointment a : DAOFactory.getAppointmentDAO().getAllAppointments())
      if (a.getDoctorId().equals(old.getDoctorId())
          && !LocalDate.parse(a.getAppointmentDate()).isBefore(LocalDate.now())
          && LocalDate.parse(a.getAppointmentDate()).getDayOfWeek().getValue() == old.getDayOfWeek()
          && java.util.Arrays.asList("Booked", "Checked-in", "In consultation")
              .contains(a.getStatus())
          && !LocalTime.parse(a.getAppointmentTime()).isBefore(LocalTime.parse(old.getStartTime()))
          && LocalTime.parse(a.getAppointmentTime()).isBefore(LocalTime.parse(old.getEndTime())))
        throw new IllegalArgumentException(
            "This session has active bookings. Reschedule or cancel them before changing the"
                + " session");
  }

  public List<String> slots(String doctor, String date, int exclude) {
    LocalDate day = LocalDate.parse(date);
    SortedSet<String> result = new TreeSet<>();
    for (Availability a : list())
      if (a.getDoctorId().equals(doctor) && a.getDayOfWeek() == day.getDayOfWeek().getValue()) {
        LocalDateTime end = LocalDateTime.of(day, LocalTime.parse(a.getEndTime()));
        for (LocalDateTime slot = LocalDateTime.of(day, LocalTime.parse(a.getStartTime()));
            !slot.plusMinutes(a.getSlotMinutes()).isAfter(end); ) {
          LocalTime t = slot.toLocalTime();
          if (slot.isAfter(LocalDateTime.now())
              && !DAOFactory.getAppointmentDAO()
                  .checkDoctorConflict(doctor, date, t.toString(), exclude))
            result.add(t.format(DateTimeFormatter.ofPattern("HH:mm")));
          LocalDateTime next = slot.plusMinutes(a.getSlotMinutes());
          if (!next.isAfter(slot)) break;
          slot = next;
        }
      }
    return new ArrayList<>(result);
  }

  public boolean scheduled(String doctor, String date, String time) {
    LocalDate d = LocalDate.parse(date);
    LocalTime t = LocalTime.parse(time);
    for (Availability a : list())
      if (a.getDoctorId().equals(doctor) && a.getDayOfWeek() == d.getDayOfWeek().getValue()) {
        LocalTime start = LocalTime.parse(a.getStartTime()), end = LocalTime.parse(a.getEndTime());
        long offset = Duration.between(start, t).toMinutes();
        if (!t.isBefore(start)
            && Duration.between(t, end).toMinutes() >= a.getSlotMinutes()
            && offset % a.getSlotMinutes() == 0
            && t.getSecond() == 0) return true;
      }
    return false;
  }
}
