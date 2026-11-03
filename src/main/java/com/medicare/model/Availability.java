package com.medicare.model;

public class Availability {
  private int id;

  public int getId() {
    return id;
  }

  public void setId(int value) {
    id = value;
  }

  private String doctorId;

  public String getDoctorId() {
    return doctorId;
  }

  public void setDoctorId(String value) {
    doctorId = value;
  }

  private int dayOfWeek;

  public int getDayOfWeek() {
    return dayOfWeek;
  }

  public void setDayOfWeek(int value) {
    dayOfWeek = value;
  }

  private String startTime;

  public String getStartTime() {
    return startTime;
  }

  public void setStartTime(String value) {
    startTime = value;
  }

  private String endTime;

  public String getEndTime() {
    return endTime;
  }

  public void setEndTime(String value) {
    endTime = value;
  }

  private int slotMinutes;

  public int getSlotMinutes() {
    return slotMinutes;
  }

  public void setSlotMinutes(int value) {
    slotMinutes = value;
  }
}
