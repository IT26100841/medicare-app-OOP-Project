package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/download-prescription")
public class PrescriptionPDFServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws IOException, ServletException {
    com.medicare.model.MedicalRecord value =
        DAOFactory.getMedicalRecordDAO()
            .getMedicalRecordById(Integer.parseInt(req.getParameter("id")));
    if (value == null) {
      res.sendError(404, "Record not found");
      return;
    }
    if (value != null)
      new com.medicare.service.VisitService()
          .requireDoctor(
              (com.medicare.model.User) req.getSession().getAttribute("currentUser"),
              value.getDoctorId());
    req.setAttribute("clinical", value);
    req.getRequestDispatcher("WEB-INF/views/print-clinical.jsp").forward(req, res);
  }
}
