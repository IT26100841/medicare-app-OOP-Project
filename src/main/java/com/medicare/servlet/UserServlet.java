package com.medicare.servlet;

import com.medicare.model.User;
import com.medicare.service.UserService;
import com.medicare.util.Validation;
import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/users")
public class UserServlet extends HttpServlet {
  private final UserService service = new UserService();

  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    String action = req.getParameter("action");
    if ("new".equals(action) || "edit".equals(action)) {
      if ("edit".equals(action)) {
        User user = service.getUserById(Integer.parseInt(req.getParameter("id")));
        if (user == null) {
          res.sendError(404);
          return;
        }
        req.setAttribute("user", user);
      }
      req.getRequestDispatcher("user-form.jsp").forward(req, res);
    } else {
      req.setAttribute("users", service.getAllUsers());
      req.getRequestDispatcher("user-management.jsp").forward(req, res);
    }
  }

  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    String action = req.getParameter("action");
    boolean success;
    if ("delete".equals(action)) {
      int id = Integer.parseInt(req.getParameter("id"));
      User current = (User) req.getSession().getAttribute("currentUser");
      if (id == current.getId())
        throw new IllegalArgumentException("You cannot delete your signed-in account");
      success = service.deleteUser(id);
      if (success) com.medicare.service.ClinicStore.bind(id, null);
    } else {
      User u;
      if ("update".equals(action)) {
        u = service.getUserById(Integer.parseInt(req.getParameter("id")));
        if (u == null) throw new IllegalArgumentException("User not found");
      } else {
        u = new User();
        u.setUsername(Validation.required(req.getParameter("username"), "Username"));
      }
      String password = req.getParameter("password");
      if (password != null && !password.isBlank()) {
        if (password.length() < 8)
          throw new IllegalArgumentException("Use at least 8 characters for the password");
        u.setPassword(password);
      } else if (!"update".equals(action))
        throw new IllegalArgumentException("Password is required");
      String role = req.getParameter("role");
      if (!Arrays.asList("ADMIN", "DOCTOR", "STAFF").contains(role))
        throw new IllegalArgumentException("Invalid role");
      User current = (User) req.getSession().getAttribute("currentUser");
      if (u.getId() == current.getId() && !role.equals(current.getRole()))
        throw new IllegalArgumentException("You cannot change your signed-in account role");
      u.setRole(role);
      u.setEmail(req.getParameter("email"));
      Validation.email(u.getEmail());
      u.setName(u.getUsername());
      success = "update".equals(action) ? service.updateUser(u) : service.addUser(u);
      if (success) {
        User saved =
            com.medicare.factory.DAOFactory.getUserDAO().getUserByUsername(u.getUsername());
        if (req.getParameter("doctorId") != null)
          com.medicare.service.ClinicStore.bind(
              saved.getId(), "DOCTOR".equals(u.getRole()) ? req.getParameter("doctorId") : null);
      }
      if (success && u.getId() == current.getId()) req.getSession().setAttribute("currentUser", u);
    }
    if (!success)
      throw new IllegalArgumentException("User operation failed; check duplicate username or ID");
    res.sendRedirect("users");
  }
}
