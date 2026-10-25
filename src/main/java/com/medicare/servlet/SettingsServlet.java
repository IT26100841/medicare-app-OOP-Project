package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import com.medicare.model.User;
import com.medicare.util.AuditLogger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/settings")
public class SettingsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        String storageMode = request.getParameter("storageMode");
        if (storageMode != null && !storageMode.trim().isEmpty()) {
            DAOFactory.setStorageMode(storageMode.trim());
        }

        String hospitalName = request.getParameter("hospitalName");
        String contactNumber = request.getParameter("contactNumber");
        String address = request.getParameter("address");

        session.setAttribute("hospitalName", hospitalName);
        session.setAttribute("contactNumber", contactNumber);
        session.setAttribute("hospitalAddress", address);

        // Real-Time Audit Log
        if (currentUser != null) {
            AuditLogger.log(
                    currentUser.getUsername(),
                    currentUser.getRole(),
                    "Changed Storage Mode to " + storageMode + " & Updated Hospital Details",
                    request.getRemoteAddr()
            );
        }

        response.sendRedirect("settings.jsp?status=success");
    }
}