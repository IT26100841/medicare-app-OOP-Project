package com.medicare.servlet;

import com.medicare.model.*;
import com.medicare.service.*;
import com.medicare.util.*;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/availability")
public class AvailabilityServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws IOException, ServletException {
    req.getRequestDispatcher("availability.jsp").forward(req, res);
  }

  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    ScheduleService service = new ScheduleService();
    boolean success;
    if ("delete".equals(req.getParameter("action")))
      success = service.delete(Integer.parseInt(req.getParameter("id")));
    else {
      Availability a = new Availability();
      String id = req.getParameter("id");
      a.setId(id == null || id.isBlank() ? 0 : Integer.parseInt(id));
      a.setDoctorId(req.getParameter("doctorId"));
      a.setDayOfWeek(Integer.parseInt(req.getParameter("dayOfWeek")));
      a.setStartTime(req.getParameter("startTime"));
      a.setEndTime(req.getParameter("endTime"));
      a.setSlotMinutes(Integer.parseInt(req.getParameter("slotMinutes")));
      success = service.save(a);
    }
    if (!success) throw new IllegalArgumentException("Schedule was not found");
    req.getSession().setAttribute("flash", "Doctor schedule updated");
    res.sendRedirect("availability");
  }
}
