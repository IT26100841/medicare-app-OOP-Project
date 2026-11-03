package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import com.medicare.model.Appointment;
import com.medicare.model.Doctor;
import com.medicare.model.Patient;
import com.medicare.model.User;
import com.medicare.service.AppointmentService;
import com.medicare.util.AuditLogger;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet({"/appointment", "/appointments"})
public class AppointmentServlet extends HttpServlet {

  private AppointmentService appointmentService;

  @Override
  public void init() {
    appointmentService = new AppointmentService();
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    processRequest(request, response);
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    processRequest(request, response);
  }

  private void processRequest(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    request.setCharacterEncoding("UTF-8");

    // Session check
    HttpSession session = request.getSession(false);
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    if (currentUser == null) {
      response.sendRedirect("login.jsp");
      return;
    }

    String action = request.getParameter("action");
    if (action == null || action.trim().isEmpty()) {
      action = "list";
    }

    switch (action) {
      case "new":
      case "book":
        showBookForm(request, response);
        break;
      case "insert":
        insertAppointment(request, response, currentUser);
        break;
      case "edit":
        showEditForm(request, response);
        break;
      case "update":
        updateAppointment(request, response, currentUser);
        break;
      case "cancel":
        cancelAppointment(request, response, currentUser);
        break;
      case "confirm-cancel":
        showCancelConfirmation(request, response);
        break;
      case "delete":
        deleteAppointment(request, response, currentUser);
        break;
      case "list":
      default:
        listAppointments(request, response);
        break;
    }
  }

  private void listAppointments(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String keyword = request.getParameter("keyword");
    String status = request.getParameter("status");

    List<Appointment> list;
    if (keyword != null && !keyword.trim().isEmpty()) {
      list = appointmentService.searchAppointments(keyword.trim());
      request.setAttribute("keyword", keyword.trim());
    } else if (status != null
        && !status.trim().isEmpty()
        && !"ALL".equalsIgnoreCase(status.trim())) {
      list = appointmentService.getAppointmentsByStatus(status.trim());
      request.setAttribute("selectedStatus", status.trim());
    } else {
      list = appointmentService.getAllAppointments();
    }

    if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
      final String filter = status.trim();
      list.removeIf(a -> !a.getStatus().equalsIgnoreCase(filter));
      request.setAttribute("selectedStatus", filter);
    }
    request.setAttribute("appointments", list);
    request.getRequestDispatcher("appointment-list.jsp").forward(request, response);
  }

  private void showBookForm(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    loadDropdownData(request);
    request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
  }

  private void insertAppointment(
      HttpServletRequest request, HttpServletResponse response, User currentUser)
      throws ServletException, IOException {
    String patientId = request.getParameter("patientId");
    String doctorId = request.getParameter("doctorId");
    String appointmentDate = request.getParameter("appointmentDate");
    String appointmentTime = request.getParameter("appointmentTime");
    String reason = request.getParameter("reason");
    String status = "Booked"; // New visits always enter through the booking state.

    if (status == null || status.trim().isEmpty()) {
      status = "Booked";
    }

    // Basic validation
    if (patientId == null
        || patientId.trim().isEmpty()
        || doctorId == null
        || doctorId.trim().isEmpty()
        || appointmentDate == null
        || appointmentDate.trim().isEmpty()
        || appointmentTime == null
        || appointmentTime.trim().isEmpty()
        || reason == null
        || reason.trim().isEmpty()) {

      request.setAttribute("errorMessage", "All fields are required. Please fill in all details.");
      loadDropdownData(request);
      request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
      return;
    }

    // Conflict check
    boolean available =
        appointmentService.isDoctorSlotAvailable(doctorId, appointmentDate, appointmentTime, 0);
    if (!available) {
      Doctor doc = DAOFactory.getDoctorDAO().getDoctorById(doctorId);
      String docName = (doc != null) ? doc.getName() : "Dr. " + doctorId;
      request.setAttribute(
          "errorMessage",
          "Schedule Conflict: "
              + docName
              + " already has an active appointment on "
              + appointmentDate
              + " at "
              + appointmentTime
              + ". Please choose a different date or time slot.");
      request.setAttribute("prePatientId", patientId);
      request.setAttribute("preDoctorId", doctorId);
      request.setAttribute("preDate", appointmentDate);
      request.setAttribute("preTime", appointmentTime);
      request.setAttribute("preReason", reason);
      request.setAttribute("preStatus", status);

      loadDropdownData(request);
      request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
      return;
    }

    Appointment appointment =
        new Appointment(
            patientId.trim(),
            doctorId.trim(),
            appointmentDate.trim(),
            appointmentTime.trim(),
            reason.trim(),
            status.trim());

    boolean success = appointmentService.addAppointment(appointment);
    if (success) {
      AuditLogger.log(
          currentUser.getUsername(),
          currentUser.getRole(),
          "Booked Appointment #"
              + appointment.getAppointmentId()
              + " (Patient: "
              + patientId
              + ", Doctor: "
              + doctorId
              + ")",
          request.getRemoteAddr());
      response.sendRedirect("appointment?action=list&msg=booked");
    } else {
      request.setAttribute("errorMessage", "Failed to book appointment. Please try again.");
      loadDropdownData(request);
      request.getRequestDispatcher("book-appointment.jsp").forward(request, response);
    }
  }

  private void showEditForm(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String idStr = request.getParameter("id");
    if (idStr == null || idStr.trim().isEmpty()) {
      response.sendRedirect("appointment?action=list");
      return;
    }

    try {
      int id = Integer.parseInt(idStr.trim());
      Appointment app = appointmentService.getAppointmentById(id);
      if (app != null) {
        request.setAttribute("appointment", app);
        loadDropdownData(request);
        request.getRequestDispatcher("edit-appointment.jsp").forward(request, response);
        return;
      }
    } catch (NumberFormatException ignored) {
    }

    response.sendRedirect("appointment?action=list&error=notfound");
  }

  private void updateAppointment(
      HttpServletRequest request, HttpServletResponse response, User currentUser)
      throws ServletException, IOException {
    String idStr = request.getParameter("appointmentId");
    if (idStr != null && !idStr.isBlank()) {
      Appointment before = appointmentService.getAppointmentById(Integer.parseInt(idStr));
      if (before == null) throw new IllegalArgumentException("Appointment not found");
      if (!"Booked".equalsIgnoreCase(before.getStatus()))
        throw new IllegalArgumentException("Only booked visits can be rescheduled");
      if (request.getParameter("status") != null
          && !"Booked".equals(request.getParameter("status")))
        throw new IllegalArgumentException("Use the visit actions to update its status");
    }
    String patientId = request.getParameter("patientId");
    String doctorId = request.getParameter("doctorId");
    String appointmentDate = request.getParameter("appointmentDate");
    String appointmentTime = request.getParameter("appointmentTime");
    String reason = request.getParameter("reason");
    String status = request.getParameter("status");

    if (idStr == null || idStr.trim().isEmpty()) {
      response.sendRedirect("appointment?action=list");
      return;
    }

    int appointmentId;
    try {
      appointmentId = Integer.parseInt(idStr.trim());
    } catch (NumberFormatException e) {
      response.sendRedirect("appointment?action=list");
      return;
    }

    // If status is being set to Cancelled, slot conflict check is not violated
    if (!"Cancelled".equalsIgnoreCase(status)) {
      boolean available =
          appointmentService.isDoctorSlotAvailable(
              doctorId, appointmentDate, appointmentTime, appointmentId);
      if (!available) {
        Doctor doc = DAOFactory.getDoctorDAO().getDoctorById(doctorId);
        String docName = (doc != null) ? doc.getName() : "Dr. " + doctorId;
        request.setAttribute(
            "errorMessage",
            "Schedule Conflict: "
                + docName
                + " already has an active appointment on "
                + appointmentDate
                + " at "
                + appointmentTime
                + ". Please select a different time slot.");

        Appointment app =
            new Appointment(
                appointmentId,
                patientId,
                doctorId,
                appointmentDate,
                appointmentTime,
                reason,
                status);
        request.setAttribute("appointment", app);
        loadDropdownData(request);
        request.getRequestDispatcher("edit-appointment.jsp").forward(request, response);
        return;
      }
    }

    com.medicare.util.Validation.required(patientId, "Patient");
    com.medicare.util.Validation.required(doctorId, "Doctor");
    com.medicare.util.Validation.required(appointmentDate, "Date");
    com.medicare.util.Validation.required(appointmentTime, "Time");
    com.medicare.util.Validation.required(reason, "Reason");
    com.medicare.util.Validation.required(status, "Status");
    Appointment app =
        new Appointment(
            appointmentId,
            patientId.trim(),
            doctorId.trim(),
            appointmentDate.trim(),
            appointmentTime.trim(),
            reason.trim(),
            status.trim());

    boolean updated = appointmentService.updateAppointment(app);
    if (updated) {
      AuditLogger.log(
          currentUser.getUsername(),
          currentUser.getRole(),
          "Updated Appointment #" + appointmentId + " (Status: " + status + ")",
          request.getRemoteAddr());
      response.sendRedirect("appointment?action=list&msg=updated");
    } else {
      request.setAttribute("errorMessage", "Failed to update appointment. Please check details.");
      request.setAttribute("appointment", app);
      loadDropdownData(request);
      request.getRequestDispatcher("edit-appointment.jsp").forward(request, response);
    }
  }

  private void showCancelConfirmation(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String idStr = request.getParameter("id");
    if (idStr != null && !idStr.trim().isEmpty()) {
      try {
        int id = Integer.parseInt(idStr.trim());
        Appointment app = appointmentService.getAppointmentById(id);
        if (app != null) {
          request.setAttribute("appointment", app);
          request.getRequestDispatcher("cancel-appointment.jsp").forward(request, response);
          return;
        }
      } catch (NumberFormatException ignored) {
      }
    }
    response.sendRedirect("appointment?action=list");
  }

  private void cancelAppointment(
      HttpServletRequest request, HttpServletResponse response, User currentUser)
      throws ServletException, IOException {
    String idStr = request.getParameter("id");
    if (idStr != null && !idStr.trim().isEmpty()) {
      try {
        int id = Integer.parseInt(idStr.trim());
        new com.medicare.service.VisitService()
            .transition(id, com.medicare.model.AppointmentStatus.CANCELLED, currentUser);
        boolean cancelled = true;
        if (cancelled) {
          AuditLogger.log(
              currentUser.getUsername(),
              currentUser.getRole(),
              "Cancelled Appointment #" + id,
              request.getRemoteAddr());
          response.sendRedirect("appointment?action=list&msg=cancelled");
          return;
        }
      } catch (NumberFormatException ignored) {
      }
    }
    response.sendRedirect("appointment?action=list&error=cancel_failed");
  }

  private void deleteAppointment(
      HttpServletRequest request, HttpServletResponse response, User currentUser)
      throws ServletException, IOException {
    String idStr = request.getParameter("id");
    if (idStr != null && !idStr.trim().isEmpty()) {
      try {
        int id = Integer.parseInt(idStr.trim());
        boolean deleted = appointmentService.deleteAppointment(id);
        if (deleted) {
          AuditLogger.log(
              currentUser.getUsername(),
              currentUser.getRole(),
              "Deleted Appointment #" + id,
              request.getRemoteAddr());
          response.sendRedirect("appointment?action=list&msg=deleted");
          return;
        }
      } catch (NumberFormatException ignored) {
      }
    }
    response.sendRedirect("appointment?action=list&error=delete_failed");
  }

  private void loadDropdownData(HttpServletRequest request) {
    List<Patient> patients = DAOFactory.getPatientDAO().getAllPatients();
    List<Doctor> doctors = DAOFactory.getDoctorDAO().getAllDoctors();
    request.setAttribute("patients", patients);
    request.setAttribute("doctors", doctors);
  }
}
