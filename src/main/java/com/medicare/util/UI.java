package com.medicare.util;

import com.medicare.factory.DAOFactory;
import com.medicare.model.*;
import com.medicare.service.ClinicStore;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

public final class UI {
  private UI() {}

  public static String e(Object v) {
    return Html.escape(v);
  }

  public static String money(double value) {
    return "LKR " + String.format(java.util.Locale.US, "%,.2f", value);
  }

  public static String initials(String name) {
    if (name == null || name.isBlank()) return "MC";
    String[] parts = name.trim().split("\\s+");
    return (parts[0].substring(0, 1)
            + (parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : ""))
        .toUpperCase(Locale.ROOT);
  }

  public static String date(String value) {
    try {
      return LocalDate.parse(value).format(DateTimeFormatter.ofPattern("dd MMM yyyy"));
    } catch (Exception e) {
      return value == null ? "—" : value;
    }
  }

  public static String time(String value) {
    try {
      return LocalTime.parse(value).format(DateTimeFormatter.ofPattern("hh:mm a"));
    } catch (Exception e) {
      return value == null ? "—" : value;
    }
  }

  public static String patient(String id) {
    Patient p = DAOFactory.getPatientDAO().getPatientById(id);
    return p == null ? "Patient " + id : p.getName();
  }

  public static String doctor(String id) {
    Doctor d = DAOFactory.getDoctorDAO().getDoctorById(id);
    return d == null ? "Doctor " + id : d.getName();
  }

  public static String badge(String status) {
    String cls = status == null ? "" : status.toLowerCase(Locale.ROOT).replace(" ", "-");
    return "<span class='badge badge-" + e(cls) + "'><span></span>" + e(status) + "</span>";
  }

  public static boolean admin(User u) {
    return u != null && "ADMIN".equals(u.getRole());
  }

  public static boolean reception(User u) {
    return u != null && Arrays.asList("ADMIN", "STAFF").contains(u.getRole());
  }

  public static boolean clinical(User u) {
    return u != null && Arrays.asList("ADMIN", "DOCTOR").contains(u.getRole());
  }

  public static List<Appointment> visibleAppointments(User u) {
    List<Appointment> rows = DAOFactory.getAppointmentDAO().getAllAppointments();
    if ("DOCTOR".equals(u.getRole())) {
      String linked = ClinicStore.doctorFor(u.getId());
      rows.removeIf(a -> !Objects.equals(a.getDoctorId(), linked));
    }
    rows.sort(
        Comparator.comparing(Appointment::getAppointmentDate)
            .thenComparing(Appointment::getAppointmentTime));
    return rows;
  }

  public static String icon(String name) {
    String path;
    switch (name) {
      case "dashboard":
        path = "M3 3h7v7H3z M14 3h7v7h-7z M3 14h7v7H3z M14 14h7v7h-7z";
        break;
      case "calendar":
        path = "M8 2v4m8-4v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14H3V6a2 2 0 0 1 2-2z";
        break;
      case "users":
        path =
            "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2m20 0v-2a4 4 0 0 0-3-3.87M15 3.13a4 4 0 0 1 0"
                + " 7.75 M13 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0z";
        break;
      case "doctor":
        path =
            "M6 3v5a6 6 0 0 0 12 0V3M6 3H4m14 0h2M12 14v2a5 5 0 0 0 10 0v-3m0-3a2 2 0 1 1-4 0 2 2 0"
                + " 0 1 4 0";
        break;
      case "file":
        path = "M14 2H4v20h16V8z M14 2v6h6 M8 13h8m-8 4h6";
        break;
      case "wallet":
        path = "M3 5h17v16H3z M3 5V3h14v2 M15 11h7v5h-7z";
        break;
      case "settings":
        path =
            "M12 8a4 4 0 1 1 0 8 4 4 0 0 1 0-8M12 2v3m0 14v3M2 12h3m14 0h3M5 5l2 2m10 10 2 2M5"
                + " 19l2-2M17 7l2-2";
        break;
      case "search":
        path = "M21 21l-5-5M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0z";
        break;
      case "plus":
        path = "M12 5v14M5 12h14";
        break;
      case "arrow":
        path = "M5 12h14m-5-5 5 5-5 5";
        break;
      case "clock":
        path = "M12 8v5l3 2 M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0z";
        break;
      case "logout":
        path = "M9 3H3v18h6m5-5 4-4-4-4m-6 4h13";
        break;
      default:
        path = "M5 12l4 4L19 6";
    }
    return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.7'"
               + " stroke-linecap='round' stroke-linejoin='round' aria-hidden='true'><path d='"
        + path
        + "'/></svg>";
  }
}
