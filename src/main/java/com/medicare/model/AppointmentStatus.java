package com.medicare.model;

/** A visit moves forward through a small, explicit clinical workflow. */
public enum AppointmentStatus {
  BOOKED("Booked"),
  CHECKED_IN("Checked-in"),
  IN_CONSULTATION("In consultation"),
  COMPLETED("Completed"),
  CANCELLED("Cancelled"),
  NO_SHOW("No-show");
  private final String label;

  AppointmentStatus(String label) {
    this.label = label;
  }

  public String label() {
    return label;
  }

  public boolean reservesSlot() {
    return this != CANCELLED && this != NO_SHOW;
  }

  public static AppointmentStatus parse(String text) {
    for (AppointmentStatus s : values()) if (s.label.equalsIgnoreCase(text)) return s;
    throw new IllegalArgumentException("Unknown appointment status");
  }

  public boolean canMoveTo(AppointmentStatus next) {
    if (this == next) return false;
    if (this == BOOKED) return next == CHECKED_IN || next == CANCELLED || next == NO_SHOW;
    if (this == CHECKED_IN) return next == IN_CONSULTATION || next == CANCELLED;
    return this == IN_CONSULTATION && next == COMPLETED;
  }
}
