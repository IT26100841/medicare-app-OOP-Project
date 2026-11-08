package com.medicare.servlet;

import com.medicare.service.ScheduleService;
import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/slots")
public class SlotsServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
    String exclude = req.getParameter("exclude");
    List<String> slots =
        new ScheduleService()
            .slots(
                req.getParameter("doctorId"),
                req.getParameter("date"),
                exclude == null || exclude.isBlank() ? 0 : Integer.parseInt(exclude));
    res.setContentType("application/json;charset=UTF-8");
    res.getWriter()
        .print(
            "["
                + slots.stream()
                    .map(s -> "\"" + s + "\"")
                    .collect(java.util.stream.Collectors.joining(","))
                + "]");
  }
}
