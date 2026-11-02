package com.medicare.util;

import javax.servlet.*;
import javax.servlet.annotation.WebListener;

@WebListener
public class AppBootstrap implements ServletContextListener {
  public void contextInitialized(ServletContextEvent event) {
    java.util.TimeZone.setDefault(
        java.util.TimeZone.getTimeZone(System.getProperty("medicare.timezone", "Asia/Colombo")));
    boolean fresh = !java.nio.file.Files.exists(DataPaths.root().resolve("users.txt"));
    DemoData.seed();
    if (fresh && "FILE".equals(com.medicare.factory.DAOFactory.getStorageMode())) {
      com.medicare.model.User doctor =
          com.medicare.factory.DAOFactory.getUserDAO().getUserByUsername("doctor");
      if (doctor != null) com.medicare.service.ClinicStore.bind(doctor.getId(), "D001");
      for (int day = 1; day <= 7; day++) {
        com.medicare.model.Availability a = new com.medicare.model.Availability();
        a.setDoctorId("D001");
        a.setDayOfWeek(day);
        a.setStartTime("09:00");
        a.setEndTime("17:00");
        a.setSlotMinutes(20);
        new com.medicare.service.ScheduleService().save(a);
      }
      if (Boolean.getBoolean("medicare.demo")) DemoWorkspace.populate();
    }
  }
}
