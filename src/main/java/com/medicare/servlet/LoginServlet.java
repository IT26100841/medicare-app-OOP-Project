package com.medicare.servlet;

import com.medicare.dao.UserDAO;
import com.medicare.factory.DAOFactory;
import com.medicare.model.User;
import com.medicare.util.AuditLogger;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.sendRedirect("login.jsp");
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");

    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if (username == null
        || password == null
        || username.trim().isEmpty()
        || password.trim().isEmpty()) {
      response.sendRedirect("login.jsp?error=empty");
      return;
    }

    try {
      UserDAO userDAO = DAOFactory.getUserDAO();
      User user = userDAO.validateUser(username.trim(), password);

      if (user != null) {
        HttpSession session = request.getSession();
        request.changeSessionId();
        session.setAttribute("currentUser", user);
        session.setAttribute("storageBackend", DAOFactory.getStorageMode());

        // 1. Audit Log සටහන් කිරීම
        AuditLogger.log(
            user.getUsername(),
            user.getRole(),
            "User Logged In Successfully",
            request.getRemoteAddr());

        // 2. ADMIN සහ DOCTOR දෙදෙනාවම එකම Main Dashboard එකට Redirect කිරීම
        response.sendRedirect("dashboard.jsp");

      } else {
        response.sendRedirect("login.jsp?error=invalid");
      }
    } catch (Exception e) {
      e.printStackTrace();
      response.sendRedirect("login.jsp?error=server");
    }
  }
}
