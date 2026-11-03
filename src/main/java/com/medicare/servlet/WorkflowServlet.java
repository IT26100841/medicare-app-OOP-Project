package com.medicare.servlet;

import com.medicare.model.*;
import com.medicare.service.*;
import com.medicare.util.*;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/visit")
public class WorkflowServlet extends HttpServlet {
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    User actor = (User) req.getSession().getAttribute("currentUser");
    int id = Integer.parseInt(req.getParameter("id"));
    AppointmentStatus next = AppointmentStatus.parse(req.getParameter("status"));
    new VisitService().transition(id, next, actor);
    AuditLogger.log(
        actor.getUsername(),
        actor.getRole(),
        "Visit #" + id + " moved to " + next.label(),
        req.getRemoteAddr());
    req.getSession().setAttribute("flash", "Visit updated: " + next.label());
    res.sendRedirect("appointment?action=list");
  }
}
