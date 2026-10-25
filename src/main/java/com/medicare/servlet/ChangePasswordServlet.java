package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import com.medicare.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/change-password")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("change-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (!currentUser.getPassword().equals(currentPassword)) {
            req.setAttribute("errorMessage", "Current password is incorrect!");
            req.getRequestDispatcher("change-password.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "New passwords do not match!");
            req.getRequestDispatcher("change-password.jsp").forward(req, resp);
            return;
        }

        currentUser.setPassword(newPassword);
        boolean updated = DAOFactory.getUserDAO().updateUser(currentUser);

        if (updated) {
            session.setAttribute("currentUser", currentUser);
            req.setAttribute("successMessage", "Password updated successfully!");
        } else {
            req.setAttribute("errorMessage", "Failed to update password. Try again.");
        }

        req.getRequestDispatcher("change-password.jsp").forward(req, resp);
    }
}