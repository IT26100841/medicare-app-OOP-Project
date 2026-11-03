package com.medicare.servlet;

import com.medicare.factory.DAOFactory;
import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/download-bill")
public class BillPDFServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws IOException, ServletException {
    com.medicare.model.Bill value =
        DAOFactory.getBillDAO().getBillById(Integer.parseInt(req.getParameter("id")));
    if (value == null) {
      res.sendError(404, "Record not found");
      return;
    }
    req.setAttribute("invoice", value);
    req.getRequestDispatcher("WEB-INF/views/print-invoice.jsp").forward(req, res);
  }
}
