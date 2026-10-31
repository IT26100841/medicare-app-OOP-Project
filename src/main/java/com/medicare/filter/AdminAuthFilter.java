package com.medicare.filter;

import com.medicare.model.User;
import com.medicare.util.Html;
import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter(
    urlPatterns = "/*",
    dispatcherTypes = {DispatcherType.REQUEST})
public class AdminAuthFilter implements Filter {
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse res = (HttpServletResponse) response;
    req.setCharacterEncoding("UTF-8");
    res.setHeader("X-Content-Type-Options", "nosniff");
    res.setHeader("Referrer-Policy", "same-origin");
    res.setHeader("X-Frame-Options", "SAMEORIGIN");
    res.setHeader("Cache-Control", "no-store");
    String path = req.getServletPath();
    HttpSession session = req.getSession();
    if (session.getAttribute("csrfToken") == null)
      session.setAttribute("csrfToken", UUID.randomUUID().toString());
    String token = (String) session.getAttribute("csrfToken");
    boolean publicPath =
        path.equals("/login")
            || path.equals("/login.jsp")
            || path.equals("/index.jsp")
            || path.equals("/")
            || path.startsWith("/assets/")
            || path.endsWith(".css")
            || path.endsWith(".js")
            || path.equals("/favicon.ico");
    if (path.equals("/portal")) {
      if ("POST".equals(req.getMethod()) && !Objects.equals(token, req.getParameter("csrfToken"))) {
        res.sendError(403, "Invalid form token");
        return;
      }
      chain.doFilter(request, response);
      return;
    }
    if (session.getAttribute("portalPatientId") != null && !path.startsWith("/assets/")) {
      res.sendError(403, "Patient accounts cannot access the management workspace");
      return;
    }
    User user = (User) session.getAttribute("currentUser");
    Object backend = session.getAttribute("storageBackend");
    if (user != null
        && backend != null
        && !backend.equals(com.medicare.factory.DAOFactory.getStorageMode())) {
      session.invalidate();
      res.sendRedirect(req.getContextPath() + "/login.jsp?switched=1");
      return;
    }
    if (!publicPath && user == null) {
      res.sendRedirect(req.getContextPath() + "/login.jsp");
      return;
    }
    String action = req.getParameter("action");
    boolean post = "POST".equals(req.getMethod());
    boolean mutation =
        post
            || Arrays.asList("delete", "cancel", "insert", "update", "add", "pay", "updateStatus")
                .contains(action)
            || path.equals("/delete-patient");
    if (user != null && !allowed(user.getRole(), path, action, mutation)) {
      res.sendError(403, "Your role cannot perform this action");
      return;
    }
    if (post && !Objects.equals(token, req.getParameter("csrfToken"))) {
      res.sendError(403, "Invalid or expired form token. Reload the form and try again.");
      return;
    }
    if (!post && mutation) {
      res.setContentType("text/html;charset=UTF-8");
      PrintWriter out = res.getWriter();
      out.print(
          "<!doctype html><html><head><meta name='viewport'"
              + " content='width=device-width'><title>Confirm"
              + " action</title></head><body><h2>Confirm this change</h2><p>This action changes"
              + " stored data.</p><form method='post' action='"
              + Html.escape(req.getRequestURI())
              + "'>");
      for (Map.Entry<String, String[]> entry : req.getParameterMap().entrySet())
        if (!"csrfToken".equals(entry.getKey()))
          for (String value : entry.getValue())
            out.print(
                "<input type='hidden' name='"
                    + Html.escape(entry.getKey())
                    + "' value='"
                    + Html.escape(value)
                    + "'>");
      out.print(
          "<input type='hidden' name='csrfToken' value='"
              + Html.escape(token)
              + "'><button type='submit'>Confirm</button></form><p><a href='"
              + req.getContextPath()
              + "/dashboard.jsp'>Back to dashboard</a></p></body></html>");
      return;
    }
    try {
      chain.doFilter(request, response);
    } catch (SecurityException e) {
      error(res, 403, e.getMessage());
    } catch (java.time.DateTimeException e) {
      error(res, 400, "Enter a valid date and time");
    } catch (IllegalArgumentException e) {
      error(res, 400, e.getMessage());
    } catch (IllegalStateException e) {
      req.getServletContext().log("Storage operation failed", e);
      error(
          res,
          500,
          "The operation could not be saved. Check the server configuration and try again.");
    }
  }

  private void error(HttpServletResponse res, int status, String message) throws IOException {
    if (!res.isCommitted()) {
      res.resetBuffer();
      res.setStatus(status);
      res.setContentType("text/html;charset=UTF-8");
      res.getWriter()
          .print(
              "<!doctype html><html lang='en'><head><meta name='viewport'"
                  + " content='width=device-width,initial-scale=1'><link rel='stylesheet'"
                  + " href='assets/app.css'><title>Check this action · Medicare</title></head><body"
                  + " class='error-page'><main class='error-card'><div class='eyebrow'>MEDICARE"
                  + " WORKSPACE</div><h1>Let’s check those details.</h1><p>"
                  + Html.escape(message)
                  + "</p><button class='button primary' onclick='history.back()'>Go back and"
                  + " review</button></main></body></html>");
    }
  }

  private boolean allowed(String role, String path, String action, boolean mutation) {
    if ("ADMIN".equals(role)) return true;
    if (!Arrays.asList("STAFF", "DOCTOR").contains(role)) return false;
    if (path.contains("settings")
        || path.contains("audit-logs")
        || path.contains("user-management")
        || path.equals("/users")
        || path.equals("/user-form.jsp")
        || path.equals("/delete-patient")
        || path.equals("/add-doctor.jsp")
        || path.equals("/edit-doctor.jsp")) return false;
    if (path.equals("/availability") || path.equals("/availability.jsp")) return !mutation;
    if (path.equals("/visit")) return true; // VisitService checks state, role and assigned doctor.
    if (path.equals("/add-patient")
        || path.equals("/edit-patient")
        || path.equals("/add-patient.jsp")
        || path.equals("/edit-patient.jsp")) return "STAFF".equals(role);
    if (path.contains("medical-record")
        && (mutation
            || path.contains("add-")
            || path.contains("edit-")
            || "new".equals(action)
            || "edit".equals(action))) return "DOCTOR".equals(role);
    if (path.equals("/appointment") || path.equals("/appointments")) {
      if ("DOCTOR".equals(role))
        return !mutation
            && !Arrays.asList("new", "book", "edit", "confirm-cancel").contains(action);
      return !"delete".equals(action);
    }
    if (!mutation) return true;
    if (path.equals("/change-password")
        || path.equals("/logout")
        || path.equals("/upload-document")) return true;
    if (path.equals("/patient")) return "STAFF".equals(role) && !"delete".equals(action);
    if (path.equals("/bill")) return "STAFF".equals(role);
    if (path.equals("/insurance-claim")) return "STAFF".equals(role) && "create".equals(action);
    return false;
  }
}
