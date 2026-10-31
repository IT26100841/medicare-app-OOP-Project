package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import com.medicare.util.*;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    String mode = Validation.required(req.getParameter("storageMode"), "Storage mode");
    if ("DB".equals(mode)) {
      try (java.sql.Connection c = DBConnection.getConnection();
          java.sql.Statement s = c.createStatement()) {
        s.executeQuery("SELECT 1 FROM clinic_availability LIMIT 1").close();
      } catch (java.sql.SQLException e) {
        throw new IllegalArgumentException(
            "Cannot use MySQL. Start the server, check connection settings and import"
                + " database/upgrade-workflow.sql.");
      }
    }
    ClinicSettings.save(
        req.getParameter("hospitalName"),
        req.getParameter("contactNumber"),
        req.getParameter("address"));
    boolean changed = !mode.equals(DAOFactory.getStorageMode());
    DAOFactory.setStorageMode(mode);
    if (changed) {
      req.getSession().invalidate();
      res.sendRedirect("login.jsp?switched=1");
    } else {
      req.getSession().setAttribute("flash", "Workspace settings saved");
      res.sendRedirect("settings.jsp");
    }
  }
}
