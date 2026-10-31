package com.medicare.filter;

import com.medicare.model.User;
import com.medicare.util.AuditLogger;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

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

        if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {

            if (currentUser != null) {
     
                AuditLogger.log(
                        currentUser.getUsername(),
                        currentUser.getRole(),
                        "UNAUTHORIZED EDIT ATTEMPT: Doctor tried to access restricted route (" + req.getRequestURI() + ")",
                        req.getRemoteAddr()
                );
            }

            res.sendRedirect(req.getContextPath() + "/doctor-dashboard.jsp?error=unauthorized");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
