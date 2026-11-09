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

@WebServlet("/add-patient")
public class AddPatientServlet extends HttpServlet {

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
      // 1. අනිවාර්ය (Required) Fields ලබා ගැනීම
      String name = request.getParameter("name");
      String ageStr = request.getParameter("age");
      int age = 0;
      if (ageStr != null && !ageStr.trim().isEmpty()) {
        try {
          age = Integer.parseInt(ageStr.trim());
        } catch (NumberFormatException nfe) {
          response.sendRedirect("add-patient.jsp?error=invalid_age");
          return;
        }
      }
      String gender = request.getParameter("gender");

      // Phone / Contact ලබා ගැනීම
      String phone = request.getParameter("phone");
      if (phone == null || phone.trim().isEmpty()) {
        phone = request.getParameter("contact");
      }

      // 2. අනිවාර්ය නොවන (Optional) Fields ලබා ගැනීම (Email ඇතුළුව)
      String email = request.getParameter("email");
      if (email == null) email = "";

      String bloodGroup = request.getParameter("blood_group");
      if (bloodGroup == null) bloodGroup = "";

      String address = request.getParameter("address");
      if (address == null) address = "";

      String allergies = request.getParameter("allergies");
      if (allergies == null) allergies = "";

      String medicalHistory = request.getParameter("medical_history");
      if (medicalHistory == null) medicalHistory = "";

      // 3. Patient Object එක සාදා දත්ත Set කිරීම
      Patient patient = new Patient();
      patient.setName(name);
      patient.setEmail(email);
      patient.setAge(age);
      patient.setGender(gender);

      // Model එකේ setPhone හෝ setContact අනුව Set කිරීම
      try {
        patient.setPhone(phone);
      } catch (Exception e) {
        // setPhone නොමැති නම් setContact භාවිතා කරයි
      }
      try {
        patient.setContact(phone);
      } catch (Exception e) {
        // Ignored
      }

      patient.setBloodGroup(bloodGroup);
      patient.setAddress(address);
      patient.setAllergies(allergies);
      patient.setMedicalHistory(medicalHistory);

      // 4. Database එකට Save කිරීම
      PatientDAO patientDAO = DAOFactory.getPatientDAO();
      com.medicare.util.Validation.patient(patient);
      boolean added = patientDAO.addPatient(patient);

      if (added) {
        AuditLogger.log(
            currentUser.getUsername(),
            currentUser.getRole(),
            "Added New Patient: " + name,
            request.getRemoteAddr());
        response.sendRedirect("patient-list.jsp?success=added");
      } else {
        response.sendRedirect("add-patient.jsp?error=failed");
      }
    } catch (IllegalArgumentException e) {
      throw e;
    } catch (Exception e) {
      throw new ServletException("Patient could not be saved", e);
    }
  }
}
