package com.medicare.filter;

import com.medicare.model.User;
import com.medicare.util.AuditLogger;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// Edit/Delete/Add සිදුකරන සියලුම URL Routes මෙහි ඇතුළත් කර ඇත
@WebFilter(urlPatterns = {
        "/edit-patient",
        "/delete-patient",
        "/add-patient",
        "/edit-medical-record",
        "/delete-medical-record",
        "/add-bill",
        "/edit-bill",
        "/delete-bill",
        "/user-management.jsp",
        "/settings"
})
public class AdminAuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // පරිශීලකයා ADMIN නොවේ නම් (DOCTOR නම්) Access Block කිරීම
        if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {

            if (currentUser != null) {
                // Audit Log එකට සටහන් කිරීම
                AuditLogger.log(
                        currentUser.getUsername(),
                        currentUser.getRole(),
                        "UNAUTHORIZED EDIT ATTEMPT: Doctor tried to access restricted route (" + req.getRequestURI() + ")",
                        req.getRemoteAddr()
                );
            }

            // Doctor ව නැවත Doctor Dashboard එකට හරවා යැවීම
            res.sendRedirect(req.getContextPath() + "/doctor-dashboard.jsp?error=unauthorized");
            return;
        }

        // ADMIN නම් පමණක් Edit/Delete කිරීමට ඉඩ දීම
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}