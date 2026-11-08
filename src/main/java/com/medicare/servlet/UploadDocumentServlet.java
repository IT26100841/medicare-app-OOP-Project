package com.medicare.servlet;

import com.medicare.model.User;
import com.medicare.service.PortalData;
import com.medicare.util.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@WebServlet("/upload-document")
@MultipartConfig(maxFileSize = 20971520, maxRequestSize = 23068672)
public class UploadDocumentServlet extends HttpServlet {
  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    String patient = Validation.required(req.getParameter("patientId"), "Patient");
    Validation.references(patient, null);
    Part part = req.getPart("file");
    if (part == null || part.getSize() == 0)
      throw new IllegalArgumentException("Select a document");
    String original = part.getSubmittedFileName();
    if (original == null) throw new IllegalArgumentException("Missing file name");
    original = original.replace('\\', '/');
    original = original.substring(original.lastIndexOf('/') + 1);
    if (original.length() > 180) throw new IllegalArgumentException("File name is too long");
    int dot = original.lastIndexOf('.');
    String ext = dot < 0 ? "" : original.substring(dot).toLowerCase(Locale.ROOT);
    if (!Arrays.asList(".pdf", ".png", ".jpg", ".jpeg").contains(ext))
      throw new IllegalArgumentException("Only PDF, PNG and JPEG documents are accepted");
    String stored = UUID.randomUUID() + ext;
    Path target = DocumentStorage.resolve(stored);
    try (InputStream in = part.getInputStream()) {
      Files.copy(in, target);
    }
    try {
      PortalData.addDocument(patient, original, stored);
    } catch (RuntimeException e) {
      Files.deleteIfExists(target);
      throw e;
    }
    User user = (User) req.getSession().getAttribute("currentUser");
    AuditLogger.log(
        user.getUsername(),
        user.getRole(),
        "Uploaded document for patient " + patient,
        req.getRemoteAddr());
    res.sendRedirect("patient-documents.jsp?status=success");
  }
}
