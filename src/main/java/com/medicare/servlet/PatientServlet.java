package com.medicare.servlet;

import com.medicare.model.Patient;
import com.medicare.model.User;
import com.medicare.service.PatientService;
import com.medicare.util.AuditLogger;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/patient")
public class PatientServlet extends HttpServlet {

  private PatientService patientService = new PatientService();

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    HttpSession session = request.getSession();
    User currentUser = (User) session.getAttribute("currentUser");

    String action = request.getParameter("action");
    String patientId = request.getParameter("id");
    if ("view".equalsIgnoreCase(action)) {
      com.medicare.model.Patient p = patientService.getPatientById(patientId);
      if (p == null) {
        response.sendError(404, "Patient not found");
        return;
      }
      request.setAttribute("patient", p);
      request.getRequestDispatcher("view-patient.jsp").forward(request, response);
      return;
    }
    if ("edit".equalsIgnoreCase(action)) {
      response.sendRedirect("edit-patient?id=" + java.net.URLEncoder.encode(patientId, "UTF-8"));
      return;
    }

    if ("delete".equalsIgnoreCase(action)) {
      response.sendError(405, "Deletion requires POST");
      return;
    }
    response.sendRedirect("patient-list.jsp");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    HttpSession session = request.getSession();
    User currentUser = (User) session.getAttribute("currentUser");

    String action = request.getParameter("action");
    String id = request.getParameter("id");
    if ("delete".equalsIgnoreCase(action)) {
      if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendError(403);
        return;
      }
      if (!patientService.deletePatient(id))
        throw new IllegalArgumentException("Patient not found");
      AuditLogger.log(
          currentUser.getUsername(),
          currentUser.getRole(),
          "Deleted patient " + id,
          request.getRemoteAddr());
      response.sendRedirect("patient-list.jsp?status=deleted");
      return;
    }

    String name = request.getParameter("name");
    String email = request.getParameter("email");

    int age = 0;
    try {
      age = Integer.parseInt(request.getParameter("age"));
    } catch (NumberFormatException e) {
      throw new IllegalArgumentException("Enter a valid age");
    }

    String gender = request.getParameter("gender");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String bloodGroup = request.getParameter("bloodGroup");
    String allergies = request.getParameter("allergies");
    String medicalHistory = request.getParameter("medicalHistory");

    Patient patient =
        new Patient(
            id, name, email, age, gender, phone, address, bloodGroup, allergies, medicalHistory);

    String username = (currentUser != null) ? currentUser.getUsername() : "System";
    String role = (currentUser != null) ? currentUser.getRole() : "ADMIN";

    if ("update".equalsIgnoreCase(action)) {
      if (!patientService.updatePatient(patient))
        throw new IllegalStateException("Patient update failed");

      // Real-Time Audit Log (Update Action)
      AuditLogger.log(
          username,
          role,
          "Updated details for Patient: " + patient.getPatientId(),
          request.getRemoteAddr());

      response.sendRedirect("patient-list.jsp?status=updated");
    } else {
      if (!patientService.addPatient(patient))
        throw new IllegalStateException("Patient creation failed");

      // Real-Time Audit Log (Add Action)
      AuditLogger.log(
          username,
          role,
          "Registered new Patient: " + patient.getPatientId(),
          request.getRemoteAddr());

      response.sendRedirect("patient-list.jsp?status=added");
    }
  }
}
