package com.medicare.servlet;

import com.medicare.model.DocumentEntry;
import com.medicare.model.User;
import com.medicare.model.Appointment;
import com.medicare.factory.DAOFactory;
import com.medicare.service.PortalData;
import com.medicare.util.DocumentStorage;
import java.io.*;
import java.nio.file.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/view-document")
public class ViewDocumentServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    DocumentEntry doc;
    try {
      doc = PortalData.getDocument(Integer.parseInt(req.getParameter("id")));
    } catch (java.sql.SQLException e) {
      throw new ServletException(e);
    }
    if (doc == null) {
      res.sendError(404, "Document not found");
      return;
    }
    User actor = (User) req.getSession().getAttribute("currentUser");
    if (actor == null) {
      res.sendError(401);
      return;
    }
    boolean authorized = "ADMIN".equals(actor.getRole()) || "STAFF".equals(actor.getRole());
    if ("DOCTOR".equals(actor.getRole())) {
      com.medicare.service.VisitService visits = new com.medicare.service.VisitService();
      for (Appointment appointment : DAOFactory.getAppointmentDAO().getAllAppointments()) {
        if (doc.getPatientId().equals(appointment.getPatientId())) {
          try {
            visits.requireDoctor(actor, appointment.getDoctorId());
            authorized = true;
            break;
          } catch (SecurityException ignored) {
            // A doctor can access documents only for a patient linked to their care.
          }
        }
      }
    }
    if (!authorized) {
      res.sendError(403, "You are not allowed to access this patient document");
      return;
    }
    // Older SQL imports stored a relative uploads/ prefix. Strip only that known prefix.
    String name = doc.getFilePath();
    if (name.startsWith("uploads/")) name = name.substring(8);
    Path path = DocumentStorage.resolve(name);
    if (!Files.isRegularFile(path)) {
      res.sendError(404, "Document file is missing. Re-upload legacy documents.");
      return;
    }
    String type = getServletContext().getMimeType(path.getFileName().toString());
    res.setContentType(type == null ? "application/octet-stream" : type);
    res.setHeader("Content-Disposition", "attachment; filename=document-" + doc.getDocumentId());
    res.setContentLengthLong(Files.size(path));
    Files.copy(path, res.getOutputStream());
  }
}
