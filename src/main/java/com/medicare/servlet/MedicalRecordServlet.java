package com.medicare.servlet;

import com.medicare.model.MedicalRecord;
import com.medicare.service.MedicalRecordService;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/medical-record")
public class MedicalRecordServlet extends HttpServlet {
  private final MedicalRecordService service = new MedicalRecordService();

  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws IOException, ServletException {
    String action = req.getParameter("action");
    if ("edit".equals(action)) {
      MedicalRecord record = service.getMedicalRecordById(Integer.parseInt(req.getParameter("id")));
      if (record == null) {
        res.sendError(404);
        return;
      }
      new com.medicare.service.VisitService()
          .requireDoctor(
              (com.medicare.model.User) req.getSession().getAttribute("currentUser"),
              record.getDoctorId());
      req.setAttribute("record", record);
      req.getRequestDispatcher("edit-medical-record.jsp").forward(req, res);
    } else if ("new".equals(action))
      req.getRequestDispatcher("add-medical-record.jsp").forward(req, res);
    else res.sendRedirect("medical-record-list.jsp");
  }

  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws IOException, ServletException {
    String action = req.getParameter("action");
    com.medicare.model.User actor =
        (com.medicare.model.User) req.getSession().getAttribute("currentUser");
    if ("delete".equals(action) || "update".equals(action)) {
      String key = req.getParameter("delete".equals(action) ? "id" : "recordId");
      MedicalRecord existing = service.getMedicalRecordById(Integer.parseInt(key));
      if (existing == null) throw new IllegalArgumentException("Record not found");
      new com.medicare.service.VisitService().requireDoctor(actor, existing.getDoctorId());
      if ("update".equals(action)
          && (!existing.getPatientId().equals(req.getParameter("patientId"))
              || !existing.getDoctorId().equals(req.getParameter("doctorId"))
              || existing.getAppointmentId()
                  != Integer.parseInt(req.getParameter("appointmentId"))))
        throw new IllegalArgumentException("Clinical record identity cannot be reassigned");
    }
    if (!"delete".equals(action))
      new com.medicare.service.VisitService().requireDoctor(actor, req.getParameter("doctorId"));
    boolean success;
    if ("delete".equals(action))
      success = service.deleteMedicalRecord(Integer.parseInt(req.getParameter("id")));
    else {
      String appointment = req.getParameter("appointmentId");
      int id = appointment == null || appointment.isBlank() ? 0 : Integer.parseInt(appointment);
      MedicalRecord r =
          new MedicalRecord(
              req.getParameter("patientId"),
              req.getParameter("doctorId"),
              id,
              req.getParameter("diagnosis"),
              req.getParameter("prescription"),
              req.getParameter("notes"),
              req.getParameter("recordDate"));
      if ("update".equals(action)) {
        r.setRecordId(Integer.parseInt(req.getParameter("recordId")));
        success = service.updateMedicalRecord(r);
      } else success = service.addMedicalRecord(r);
    }
    if (!success) throw new IllegalStateException("Medical record could not be saved");
    req.getSession()
        .setAttribute(
            "flash",
            "Clinical record saved. Complete the visit when the consultation is finished.");
    res.sendRedirect("medical-record-list.jsp?status=saved");
  }
}
