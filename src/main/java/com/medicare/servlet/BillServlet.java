package com.medicare.servlet;

import com.medicare.model.User;
import com.medicare.service.BillingService;
import com.medicare.util.AuditLogger;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/bill")
public class BillServlet extends HttpServlet {
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    BillingService service = new BillingService();
    String action = req.getParameter("action");
    String detail;
    if ("pay".equals(action)) {
      int id = Integer.parseInt(req.getParameter("billId"));
      service.pay(id, req.getParameter("paymentMethod"));
      detail = "Payment recorded for invoice #" + id;
    } else {
      com.medicare.model.Bill b =
          service.create(
              Integer.parseInt(req.getParameter("appointmentId")),
              req.getParameter("hospitalCharge"),
              req.getParameter("treatmentCharge"));
      detail = "Invoice created for visit #" + b.getAppointmentId();
    }
    User actor = (User) req.getSession().getAttribute("currentUser");
    AuditLogger.log(actor.getUsername(), actor.getRole(), detail, req.getRemoteAddr());
    req.getSession().setAttribute("flash", detail);
    res.sendRedirect("bill-list.jsp");
  }
}
