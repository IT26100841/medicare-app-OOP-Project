package com.medicare.servlet;

import com.medicare.dao.PatientDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.Patient;
import com.medicare.model.User;
import com.medicare.util.AuditLogger;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/edit-patient")
public class EditPatientServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    HttpSession session = request.getSession(false);
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

    // Admin Security Check
    if (currentUser == null
        || !java.util.Arrays.asList("ADMIN", "STAFF").contains(currentUser.getRole())) {
      if (currentUser != null) {
        AuditLogger.log(
            currentUser.getUsername(),
            currentUser.getRole(),
            "UNAUTHORIZED EDIT ATTEMPT: Patient Edit Page Access",
            request.getRemoteAddr());
      }
      response.sendRedirect("login.jsp?error=unauthorized");
      return;
    }

    String patientId = request.getParameter("id");
    if (patientId != null && !patientId.trim().isEmpty()) {
      try {
        PatientDAO patientDAO = DAOFactory.getPatientDAO();
        Patient patient = patientDAO.getPatientById(patientId);

        request.setAttribute("patient", patient);
        request.getRequestDispatcher("edit-patient.jsp").forward(request, response);
        return;
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    response.sendRedirect("patient-list.jsp");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    HttpSession session = request.getSession(false);
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

    // Admin Security Check
    if (currentUser == null
        || !java.util.Arrays.asList("ADMIN", "STAFF").contains(currentUser.getRole())) {
      response.sendRedirect("login.jsp?error=unauthorized");
      return;
    }

    try {
      String id = request.getParameter("id");
      String name = request.getParameter("name");
      int age = Integer.parseInt(request.getParameter("age"));
      String gender = request.getParameter("gender");
      String contact = request.getParameter("contact");

      Patient patient = DAOFactory.getPatientDAO().getPatientById(id);
      if (patient == null) {
        response.sendError(404, "Patient not found");
        return;
      }
      patient.setName(name);
      if (request.getParameter("email") != null) patient.setEmail(request.getParameter("email"));
      if (request.getParameter("address") != null)
        patient.setAddress(request.getParameter("address"));
      if (request.getParameter("bloodGroup") != null)
        patient.setBloodGroup(request.getParameter("bloodGroup"));
      if (request.getParameter("allergies") != null)
        patient.setAllergies(request.getParameter("allergies"));
      if (request.getParameter("medicalHistory") != null)
        patient.setMedicalHistory(request.getParameter("medicalHistory"));
      patient.setAge(age);
      patient.setGender(gender);
      patient.setContact(contact);
      com.medicare.util.Validation.patient(patient);
      PatientDAO patientDAO = DAOFactory.getPatientDAO();
      boolean updated = patientDAO.updatePatient(patient);

      if (updated) {
        AuditLogger.log(
            currentUser.getUsername(),
            currentUser.getRole(),
            "Updated Patient Info (ID: " + id + ")",
            request.getRemoteAddr());
        response.sendRedirect("patient-list.jsp?success=updated");
      } else {
        response.sendRedirect("edit-patient.jsp?id=" + id + "&error=failed");
      }
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect("patient-list.jsp?error=server");
    }
  }
}
