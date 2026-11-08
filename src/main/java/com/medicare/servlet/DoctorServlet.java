package com.medicare.servlet;

import com.medicare.model.Doctor;
import com.medicare.service.DoctorService;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/doctor")
public class DoctorServlet extends HttpServlet {

  private DoctorService doctorService;

  @Override
  public void init() {
    doctorService = new DoctorService();
  }

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    String action = request.getParameter("action");
    if (action == null) {
      action = "list";
    }

    switch (action) {
      case "new":
        showNewForm(request, response);
        break;
      case "insert":
        insertDoctor(request, response);
        break;
      case "delete":
        deleteDoctor(request, response);
        break;
      case "edit":
        showEditForm(request, response);
        break;
      case "update":
        updateDoctor(request, response);
        break;
      case "view":
        viewDoctor(request, response);
        break;
      case "search":
        searchDoctors(request, response);
        break;
      default:
        listDoctors(request, response);
        break;
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    doGet(request, response);
  }

  private void listDoctors(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    List<Doctor> listDoctor = doctorService.getAllDoctors();
    request.setAttribute("listDoctor", listDoctor);
    request.getRequestDispatcher("list-doctors.jsp").forward(request, response);
  }

  private void showNewForm(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    request.getRequestDispatcher("add-doctor.jsp").forward(request, response);
  }

  private void showEditForm(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String id = request.getParameter("id");
    Doctor existingDoctor = doctorService.getDoctorById(id);
    if (existingDoctor == null) {
      response.sendError(404, "Doctor not found");
      return;
    }
    request.setAttribute("doctor", existingDoctor);
    request.getRequestDispatcher("edit-doctor.jsp").forward(request, response);
  }

  private void viewDoctor(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String id = request.getParameter("id");
    Doctor doctor = doctorService.getDoctorById(id);
    if (doctor == null) {
      response.sendError(404, "Doctor not found");
      return;
    }
    request.setAttribute("doctor", doctor);
    request.getRequestDispatcher("view-doctor.jsp").forward(request, response);
  }

  private void searchDoctors(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    String query = request.getParameter("query");
    List<Doctor> listDoctor = doctorService.searchDoctors(query);
    request.setAttribute("listDoctor", listDoctor);
    request.getRequestDispatcher("list-doctors.jsp").forward(request, response);
  }

  private void insertDoctor(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String specialization = request.getParameter("specialization");
    String qualification = request.getParameter("qualification");
    String phone = request.getParameter("phone");
    String email = request.getParameter("email");
    double consultationFee = Double.parseDouble(request.getParameter("consultationFee"));

    Doctor newDoctor =
        new Doctor(id, name, specialization, qualification, phone, email, consultationFee);
    if (!doctorService.addDoctor(newDoctor))
      throw new IllegalStateException("Doctor operation failed; check ID and related records");
    response.sendRedirect("doctor?action=list");
  }

  private void updateDoctor(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String specialization = request.getParameter("specialization");
    String qualification = request.getParameter("qualification");
    String phone = request.getParameter("phone");
    String email = request.getParameter("email");
    double consultationFee = Double.parseDouble(request.getParameter("consultationFee"));

    Doctor doctor =
        new Doctor(id, name, specialization, qualification, phone, email, consultationFee);
    if (!doctorService.updateDoctor(doctor))
      throw new IllegalStateException("Doctor operation failed; check ID and related records");
    response.sendRedirect("doctor?action=list");
  }

  private void deleteDoctor(HttpServletRequest request, HttpServletResponse response)
      throws IOException {
    String id = request.getParameter("id");
    if (!doctorService.deleteDoctor(id))
      throw new IllegalStateException("Doctor operation failed; check ID and related records");
    response.sendRedirect("doctor?action=list");
  }
}
