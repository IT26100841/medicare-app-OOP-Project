package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import com.medicare.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.getRequestDispatcher("change-password.jsp").forward(req, resp);
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    HttpSession session = req.getSession();
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null) {
      resp.sendRedirect("login.jsp");
      return;
    }

    String currentPassword = req.getParameter("currentPassword");
    String newPassword = req.getParameter("newPassword");
    String confirmPassword = req.getParameter("confirmPassword");

    if (!com.medicare.util.Passwords.verify(currentPassword, currentUser.getPassword())) {
      req.setAttribute("errorMessage", "Current password is incorrect!");
      req.getRequestDispatcher("change-password.jsp").forward(req, resp);
      return;
    }

    if (newPassword == null || newPassword.length() < 8 || !newPassword.equals(confirmPassword)) {
      req.setAttribute("errorMessage", "Use at least 8 characters and matching new passwords.");
      req.getRequestDispatcher("change-password.jsp").forward(req, resp);
      return;
    }

    User replacement =
        new User(
            currentUser.getId(),
            currentUser.getUsername(),
            newPassword,
            currentUser.getRole(),
            currentUser.getName(),
            currentUser.getEmail());
    boolean updated = DAOFactory.getUserDAO().updateUser(replacement);

    if (updated) {
      session.setAttribute("currentUser", replacement);
      req.setAttribute("successMessage", "Password updated successfully!");
    } else {
      req.setAttribute("errorMessage", "Failed to update password. Try again.");
    }

    req.getRequestDispatcher("change-password.jsp").forward(req, resp);
  }
}
