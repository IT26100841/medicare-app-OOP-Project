package com.medicare.servlet;

import com.medicare.service.PortalData;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/insurance-claim")
public class InsuranceClaimServlet extends HttpServlet {
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws IOException, ServletException {
    if ("create".equalsIgnoreCase(req.getParameter("action")))
      PortalData.addClaim(
          req.getParameter("patientId"),
          req.getParameter("providerName"),
          req.getParameter("policyNumber"),
          Double.parseDouble(req.getParameter("claimAmount")));
    else if ("updateStatus".equalsIgnoreCase(req.getParameter("action")))
      PortalData.updateClaim(
          Integer.parseInt(req.getParameter("claimId")), req.getParameter("status"));
    else throw new IllegalArgumentException("Unknown claim action");
    resp.sendRedirect("insurance-claims.jsp?status=saved");
  }
}
