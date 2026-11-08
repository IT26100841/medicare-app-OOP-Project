package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.*;
import com.medicare.util.*;
import java.io.*;
import java.time.*;
import java.util.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/portal")
public class PatientPortalServlet extends HttpServlet {
  private final PatientPortalService service = new PatientPortalService();
  private static final Map<String, long[]> attempts = new LinkedHashMap<>();

  private static synchronized boolean limited(String ip) {
    long now = System.currentTimeMillis();
    attempts.entrySet().removeIf(e -> now - e.getValue()[0] > 900000);
    long[] a = attempts.get(ip);
    if (a == null) {
      if (attempts.size() >= 10000) return true;
      a = new long[] {now, 0};
      attempts.put(ip, a);
    }
    return ++a[1] > 15;
  }

  private String e(Object v) {
    return Html.escape(v == null ? "" : String.valueOf(v));
  }

  private String param(HttpServletRequest r, String n) {
    String v = r.getParameter(n);
    if (v != null && v.length() > 1000) throw new IllegalArgumentException("Input is too long");
    return v;
  }

  private String patient(HttpServletRequest r) {
    HttpSession s = r.getSession();
    if (!Objects.equals(s.getAttribute("portalBackend"), DAOFactory.getStorageMode())) {
      s.removeAttribute("portalPatientId");
      return null;
    }
    return (String) s.getAttribute("portalPatientId");
  }

  protected void doPost(HttpServletRequest r, HttpServletResponse res) throws IOException {
    String action = param(r, "action");
    String id = patient(r);
    try {
      if ("logout".equals(action)) {
        r.getSession().invalidate();
        res.sendRedirect("portal");
        return;
      }
      if ("login".equals(action) || "register".equals(action)) {
        if (limited(r.getRemoteAddr())) {
          res.setStatus(429);
          render(r, res, "Too many attempts. Please wait 15 minutes.");
          return;
        }
        if ("login".equals(action)) {
          id = service.login(param(r, "email"), param(r, "password"));
          if (id == null) throw new IllegalArgumentException("Email or password is incorrect.");
        } else {
          Patient p = new Patient();
          p.setName(param(r, "name"));
          p.setEmail(param(r, "email"));
          p.setAge(Integer.parseInt(param(r, "age")));
          p.setGender(param(r, "gender"));
          p.setPhone(param(r, "phone"));
          p.setAddress(param(r, "address"));
          id = service.register(p, param(r, "password"));
        }
        r.getSession().invalidate();
        HttpSession s = r.getSession(true);
        s.setMaxInactiveInterval(1800);
        s.setAttribute("portalPatientId", id);
        s.setAttribute("portalBackend", DAOFactory.getStorageMode());
        s.setAttribute("csrfToken", UUID.randomUUID().toString());
      } else {
        if (id == null) {
          res.sendRedirect("portal?view=login");
          return;
        }
        if ("book".equals(action))
          service.book(
              id, param(r, "doctor"), param(r, "date"), param(r, "time"), param(r, "reason"));
        else if ("cancel".equals(action))
          service.cancel(id, Integer.parseInt(param(r, "appointment")));
        else if ("profile".equals(action))
          service.profile(id, param(r, "name"), param(r, "phone"), param(r, "address"));
        else throw new IllegalArgumentException("Unknown action");
      }
      r.getSession().setAttribute("portalNotice", "Your change was saved successfully.");
      res.sendRedirect("portal");
    } catch (SecurityException ex) {
      res.setStatus(403);
      render(r, res, ex.getMessage());
    } catch (IllegalArgumentException | java.time.DateTimeException ex) {
      res.setStatus(400);
      render(r, res, "Please check your details. " + ex.getMessage());
    } catch (IllegalStateException ex) {
      getServletContext().log("Patient portal operation failed", ex);
      res.setStatus(503);
      render(r, res, "We could not save this change. Please try again or contact reception.");
    }
  }

  protected void doGet(HttpServletRequest r, HttpServletResponse res) throws IOException {
    try {
      render(r, res, null);
    } catch (IllegalArgumentException | java.time.DateTimeException ex) {
      res.setStatus(400);
      res.setContentType("text/plain;charset=UTF-8");
      res.getWriter().print("Please select a valid doctor and date.");
    } catch (IllegalStateException ex) {
      getServletContext().log("Portal unavailable", ex);
      res.setStatus(503);
      res.getWriter().print("Patient portal temporarily unavailable. Please contact reception.");
    }
  }

  private void form(PrintWriter o, HttpServletRequest r, String action) {
    o.print(
        "<form method='post' action='portal'><input type='hidden' name='csrfToken' value='"
            + e(r.getSession().getAttribute("csrfToken"))
            + "'><input type='hidden' name='action' value='"
            + e(action)
            + "'>");
    if ("login".equals(action) || "register".equals(action))
      o.print("<input type='hidden' name='view' value='" + action + "'>");
  }

  private void input(
      PrintWriter o, String label, String name, String type, Object value, boolean required) {
    o.print(
        "<label>"
            + e(label)
            + "<input name='"
            + name
            + "' type='"
            + type
            + "' value='"
            + e(value)
            + "' maxlength='"
            + ("password".equals(type) ? 128 : 100)
            + "' "
            + (required ? "required" : "")
            + "></label>");
  }

  private void render(HttpServletRequest r, HttpServletResponse res, String error)
      throws IOException {
    res.setContentType("text/html;charset=UTF-8");
    res.setHeader(
        "Content-Security-Policy",
        "default-src 'self'; style-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri"
            + " 'self'");
    PrintWriter o = res.getWriter();
    String id = patient(r);
    Patient p = id == null ? null : DAOFactory.getPatientDAO().getPatientById(id);
    if (id != null && p == null) {
      r.getSession().invalidate();
      res.sendRedirect("portal");
      return;
    }
    o.print(
        "<!doctype html><html lang='en'><head><meta charset='UTF-8'><meta name='viewport'"
            + " content='width=device-width,initial-scale=1'><title>Medicare · Patient"
            + " care</title><link rel='stylesheet' href='assets/portal.css'></head><body><header><a"
            + " class='brand' href='portal'><span class='cross'>+</span> Medicare<span"
            + " class='subbrand'>PATIENT CARE</span></a><nav><a href='portal#find'>Find a"
            + " doctor</a>");
    if (p == null)
      o.print(
          "<a href='login.jsp'>Clinic team</a><a href='portal?view=login'>Sign in</a><a"
              + " class='button' href='portal?view=register'>Create account</a>");
    else {
      o.print(
          "<a href='portal#appointments'>My appointments</a><a"
              + " href='portal#notifications'>Notifications</a><a href='portal#profile'>My"
              + " profile</a>");
      form(o, r, "logout");
      o.print("<button class='quiet'>Sign out</button></form>");
    }
    o.print("</nav></header><main>");
    if (error != null) o.print("<div class='notice error' role='alert'>" + e(error) + "</div>");
    Object notice = r.getSession().getAttribute("portalNotice");
    if (notice != null) {
      o.print("<div class='notice' role='status'>" + e(notice) + "</div>");
      r.getSession().removeAttribute("portalNotice");
    }
    String view = param(r, "view");
    if (p == null && ("login".equals(view) || "register".equals(view))) {
      boolean reg = "register".equals(view);
      o.print(
          "<section class='auth'><div><p class='eyebrow'>YOUR CARE, CONNECTED</p><h1>"
              + (reg ? "Start your care journey." : "Welcome back.")
              + "</h1><p>Book a visit, manage your appointments, and keep your personal details up"
              + " to date.</p><p class='muted'>Patient access is separate from the clinic"
              + " management workspace.</p></div><article class='card'><h2>"
              + (reg ? "Create your patient account" : "Patient sign in")
              + "</h2>");
      form(o, r, reg ? "register" : "login");
      if (reg) {
        input(o, "Full name", "name", "text", "", true);
        input(o, "Age (0–120)", "age", "number", "", true);
        o.print(
            "<label>Gender<select"
                + " name='gender'><option>Male</option><option>Female</option><option>Other</option></select></label>");
        input(o, "Phone", "phone", "tel", "", true);
        input(o, "Address", "address", "text", "", false);
      }
      input(o, "Email", "email", "email", "", true);
      input(o, reg ? "Password (12–128 characters)" : "Password", "password", "password", "", true);
      o.print(
          "<button>"
              + (reg ? "Create account" : "Sign in")
              + "</button></form><p><a href='portal?view="
              + (reg ? "login" : "register")
              + "'>"
              + (reg ? "Already registered? Sign in" : "New here? Create an account")
              + "</a></p><small>For account recovery or an existing clinical profile, contact"
              + " reception for identity verification.</small></article></section>");
    } else {
      o.print(
          "<section class='hero'><div><p class='eyebrow'>MEDICARE PATIENT PORTAL</p><h1>"
              + (p == null
                  ? "Good care starts<br>with the right doctor."
                  : "Welcome, " + e(p.getName()) + ".")
              + "</h1><p>Find a specialist and choose a time that works for you.<br>Your next step"
              + " towards better health, made simpler.</p><a class='button' href='#find'>Find your"
              + " doctor →</a></div><aside><span class='care-symbol'>+</span><h2>Your care, in one"
              + " place.</h2><p>Published doctor sessions<br>Secure personal access<br>Appointment"
              + " updates</p><small>For a medical emergency, contact local emergency"
              + " services.</small></aside></section>");
      if (p != null) {
        List<Appointment> list = service.appointments(id);
        o.print(
            "<section id='appointments'><p class='eyebrow'>MY CARE</p><h2>My appointments <span"
                + " class='count'>"
                + list.size()
                + "</span></h2><div class='appointments'>");
        if (list.isEmpty())
          o.print(
              "<article class='card'><h3>No appointments yet</h3><p>Choose a doctor below to book"
                  + " your first visit.</p></article>");
        for (Appointment a : list) {
          Doctor d = DAOFactory.getDoctorDAO().getDoctorById(a.getDoctorId());
          o.print(
              "<article class='card'><span class='badge'>"
                  + e(a.getStatus())
                  + "</span><h3>"
                  + e(d == null ? a.getDoctorId() : d.getName())
                  + "</h3><p>"
                  + e(a.getAppointmentDate())
                  + " · "
                  + e(a.getAppointmentTime())
                  + "</p><p>"
                  + e(a.getReason())
                  + "</p><small>Booking #"
                  + a.getAppointmentId()
                  + "</small>");
          if ("Booked".equals(a.getStatus())
              && LocalDateTime.of(
                      LocalDate.parse(a.getAppointmentDate()),
                      LocalTime.parse(a.getAppointmentTime()))
                  .isAfter(LocalDateTime.now())) {
            form(o, r, "cancel");
            o.print(
                "<input type='hidden' name='appointment' value='"
                    + a.getAppointmentId()
                    + "'><button class='cancel'>Cancel appointment</button></form>");
          }
          o.print("</article>");
        }
        o.print("</div></section>");
      }
      o.print(
          "<section id='find'><p class='eyebrow'>FIND THE RIGHT CARE</p><h2>Meet our doctors</h2><p"
              + " class='muted'>Availability follows clinic-published sessions. All times are"
              + " Asia/Colombo.</p><form class='search' method='get' action='portal'><label>Search"
              + " name or specialty<input name='q' value='"
              + e(param(r, "q"))
              + "' placeholder='e.g. General Medicine'></label><button>Search</button></form><div"
              + " class='doctors'>");
      String query = Optional.ofNullable(param(r, "q")).orElse("").toLowerCase(Locale.ROOT);
      int found = 0;
      for (Doctor d : DAOFactory.getDoctorDAO().getAllDoctors()) {
        if (!(d.getName() + " " + d.getSpecialization()).toLowerCase(Locale.ROOT).contains(query))
          continue;
        found++;
        o.print(
            "<article class='card doctor'><div class='avatar'>"
                + e(d.getName().substring(0, 1))
                + "</div><span class='badge'>"
                + e(d.getSpecialization())
                + "</span><h3>"
                + e(d.getName())
                + "</h3><p>"
                + e(d.getQualification())
                + "</p><p class='fee'>LKR "
                + String.format(Locale.ROOT, "%,.2f", d.getConsultationFee())
                + " <small>/ consultation</small></p><details><summary>Weekly clinic"
                + " sessions</summary>");
        boolean scheduled = false;
        for (Availability a : new ScheduleService().list())
          if (d.getId().equals(a.getDoctorId())) {
            scheduled = true;
            o.print(
                "<p>"
                    + e(DayOfWeek.of(a.getDayOfWeek()))
                    + " · "
                    + e(a.getStartTime())
                    + "–"
                    + e(a.getEndTime())
                    + "</p>");
          }
        if (!scheduled) o.print("<p>No sessions published. Contact reception.</p>");
        o.print(
            "</details><a class='button secondary' href='portal?doctor="
                + e(d.getId())
                + "#booking'>View available times →</a></article>");
      }
      if (found == 0) o.print("<p>No matching doctors found.</p>");
      o.print("</div></section>");
      String doctor = param(r, "doctor");
      if (doctor != null) {
        Doctor d = DAOFactory.getDoctorDAO().getDoctorById(doctor);
        if (d == null) throw new IllegalArgumentException("Doctor unavailable");
        String date =
            Optional.ofNullable(param(r, "date")).orElse(LocalDate.now().plusDays(1).toString());
        LocalDate day = LocalDate.parse(date);
        if (day.isBefore(LocalDate.now()) || day.isAfter(LocalDate.now().plusDays(90)))
          throw new IllegalArgumentException("Choose a date within 90 days");
        o.print(
            "<section id='booking' class='card'><p class='eyebrow'>BOOK A VISIT</p><h2>"
                + e(d.getName())
                + "</h2><form method='get' action='portal#booking'><input type='hidden'"
                + " name='doctor' value='"
                + e(doctor)
                + "'><label>Appointment date<input name='date' type='date' min='"
                + LocalDate.now()
                + "' max='"
                + LocalDate.now().plusDays(90)
                + "' value='"
                + e(date)
                + "' required></label><button>Check availability</button></form>");
        List<String> slots = new ScheduleService().slots(doctor, date, 0);
        if (slots.isEmpty())
          o.print("<p>No available times on this date. Please choose another date.</p>");
        else if (p == null)
          o.print(
              "<p>"
                  + slots.size()
                  + " times available. <a href='portal?view=login'>Sign in</a> or <a"
                  + " href='portal?view=register'>create your account</a> to book.</p>");
        else {
          form(o, r, "book");
          o.print(
              "<input type='hidden' name='doctor' value='"
                  + e(doctor)
                  + "'><input type='hidden' name='date' value='"
                  + e(date)
                  + "'><label>Available time<select name='time'>");
          for (String t : slots) o.print("<option>" + e(t) + "</option>");
          o.print(
              "</select></label><label>Reason for visit<textarea name='reason' maxlength='255'"
                  + " required></textarea></label><p>Consultation fee: LKR "
                  + e(d.getConsultationFee())
                  + ". Pay at the clinic. Your booking will appear in the clinic"
                  + " workspace.</p><button>Confirm appointment</button></form>");
        }
        o.print("</section>");
      }
      if (p != null) {
        o.print(
            "<section id='notifications' class='card'><p class='eyebrow'>MY"
                + " UPDATES</p><h2>Notifications</h2>");
        boolean any = false;
        for (Notification n : DAOFactory.getNotificationDAO().getAllNotifications())
          if (id.equals(n.getPatientId())) {
            any = true;
            o.print(
                "<article><p>"
                    + e(n.getMessage())
                    + "</p><small>"
                    + e(n.getDate())
                    + "</small></article>");
          }
        if (!any) o.print("<p class='muted'>No appointment updates yet.</p>");
        o.print("</section>");
      }
      if (p != null) {
        o.print(
            "<section id='profile' class='card profile'><p class='eyebrow'>PERSONAL"
                + " DETAILS</p><h2>My profile</h2><p>Patient ID: "
                + e(p.getId())
                + " · "
                + e(p.getEmail())
                + "</p>");
        form(o, r, "profile");
        input(o, "Full name", "name", "text", p.getName(), true);
        input(o, "Phone", "phone", "tel", p.getPhone(), true);
        input(o, "Address", "address", "text", p.getAddress(), false);
        o.print(
            "<button>Save my details</button></form><small>Contact reception to correct your age,"
                + " email or clinical information.</small></section>");
      }
    }
    o.print(
        "</main><footer><strong>Medicare</strong><p>Patient care portal · Appointments and personal"
            + " details</p><small>Need help? Contact your clinic"
            + " reception.</small></footer></body></html>");
  }
}
