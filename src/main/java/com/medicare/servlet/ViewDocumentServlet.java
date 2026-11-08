package com.medicare.servlet;

import com.medicare.model.DocumentEntry;
import com.medicare.service.PortalData;
import com.medicare.util.DocumentStorage;
import java.io.*;
import java.nio.file.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/view-document")
public class ViewDocumentServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    DocumentEntry doc;
    try {
      doc = PortalData.getDocument(Integer.parseInt(req.getParameter("id")));
    } catch (java.sql.SQLException e) {
      throw new ServletException(e);
    }
    if (doc == null) {
      res.sendError(404, "Document not found");
      return;
    }
    // Older SQL imports stored a relative uploads/ prefix. Strip only that known prefix.
    String name = doc.getFilePath();
    if (name.startsWith("uploads/")) name = name.substring(8);
    Path path = DocumentStorage.resolve(name);
    if (!Files.isRegularFile(path)) {
      res.sendError(404, "Document file is missing. Re-upload legacy documents.");
      return;
    }
    String type = getServletContext().getMimeType(path.getFileName().toString());
    res.setContentType(type == null ? "application/octet-stream" : type);
    res.setHeader("Content-Disposition", "attachment; filename=document-" + doc.getDocumentId());
    res.setContentLengthLong(Files.size(path));
    Files.copy(path, res.getOutputStream());
  }
}
