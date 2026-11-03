package com.medicare.servlet;

import com.medicare.dao.PatientDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.User;
import com.medicare.util.AuditLogger;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/delete-patient")
public class DeletePatientServlet extends HttpServlet {
  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    doGet(req, res);
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    HttpSession session = request.getSession(false);
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

    // Admin Security Check
    if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
      if (currentUser != null) {
        AuditLogger.log(
            currentUser.getUsername(),
            currentUser.getRole(),
            "UNAUTHORIZED DELETE ATTEMPT: Tried to delete patient",
            request.getRemoteAddr());
      }
      response.sendRedirect("login.jsp?error=unauthorized");
      return;
    }

    String patientId = request.getParameter("id");
    if (patientId != null && !patientId.trim().isEmpty()) {
      try {
        PatientDAO patientDAO = DAOFactory.getPatientDAO();
        boolean deleted = new com.medicare.service.PatientService().deletePatient(patientId);

        if (deleted) {
          AuditLogger.log(
              currentUser.getUsername(),
              currentUser.getRole(),
              "Deleted Patient (ID: " + patientId + ")",
              request.getRemoteAddr());
          response.sendRedirect("patient-list.jsp?success=deleted");
          return;
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    response.sendRedirect("patient-list.jsp?error=delete_failed");
  }
}
