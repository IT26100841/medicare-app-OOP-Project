package com.medicare.service;

import com.medicare.dao.impl.AbstractFileDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import java.time.*;
import java.util.*;

public class VisitService {
  public void requireDoctor(User actor, String doctorId) {
    if ("DOCTOR".equals(actor.getRole())
        && !Objects.equals(ClinicStore.doctorFor(actor.getId()), doctorId))
      throw new SecurityException(
          "This visit belongs to another doctor. Ask an administrator to link your doctor"
              + " account.");
  }

  public Appointment transition(int id, AppointmentStatus next, User actor) {
    synchronized (AbstractFileDAO.LOCK) {
      Appointment a = DAOFactory.getAppointmentDAO().getAppointmentById(id);
      if (a == null) throw new IllegalArgumentException("Appointment not found");
      AppointmentStatus current = AppointmentStatus.parse(a.getStatus());
      if (!current.canMoveTo(next))
        throw new IllegalArgumentException(
            "Cannot move a " + current.label() + " visit to " + next.label());
      boolean clinical =
          next == AppointmentStatus.IN_CONSULTATION || next == AppointmentStatus.COMPLETED;
      if (clinical) {
        if (!Arrays.asList("ADMIN", "DOCTOR").contains(actor.getRole()))
          throw new SecurityException("Only a clinician can start or complete a consultation");
        requireDoctor(actor, a.getDoctorId());
      } else if (!Arrays.asList("ADMIN", "STAFF").contains(actor.getRole()))
        throw new SecurityException("Reception or admin access is required");
      if (next == AppointmentStatus.CHECKED_IN
          && !LocalDate.parse(a.getAppointmentDate()).equals(LocalDate.now()))
        throw new IllegalArgumentException("Patients can only check in on their appointment date");
      if (next == AppointmentStatus.COMPLETED) {
        boolean record =
            DAOFactory.getMedicalRecordDAO().getAllMedicalRecords().stream()
                .anyMatch(r -> r.getAppointmentId() == id);
        if (!record)
          throw new IllegalArgumentException("Save a clinical record before completing this visit");
      }
      a.setStatus(next.label());
      if (!DAOFactory.getAppointmentDAO().updateAppointment(a))
        throw new IllegalStateException("Visit state could not be saved");
      return a;
    }
  }
}
