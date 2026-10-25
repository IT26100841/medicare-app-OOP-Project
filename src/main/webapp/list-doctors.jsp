<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Doctor" %>
<%@ page import="com.medicare.dao.DoctorDAO" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>

<%
    // 1. Session Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isAdmin = "ADMIN".equalsIgnoreCase(currentUser.getRole());

    // 2. Doctor List Load
    DoctorDAO doctorDAO = DAOFactory.getDoctorDAO();
    List<Doctor> doctorList = doctorDAO.getAllDoctors();

    int totalDoctors = (doctorList != null) ? doctorList.size() : 0;

    Set<String> specializations = new HashSet<>();
    if (doctorList != null) {
        for (Doctor d : doctorList) {
            if (d.getSpecialization() != null && !d.getSpecialization().trim().isEmpty()) {
                specializations.add(d.getSpecialization().trim());
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Doctor Directory</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        body { background-color: #f4f6f9; }
        .card-stat { border-radius: 12px; border: none; border-left: 5px solid; }
        .stat-doctor { border-left-color: #198754; }
        .stat-spec { border-left-color: #0dcaf0; }
        .table-card { border-radius: 16px; border: none; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
    </style>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary px-4 shadow-sm">
    <a class="navbar-brand fw-bold" href="dashboard.jsp">
        <i class="fa-solid fa-hospital-user me-2"></i>Medicare System
    </a>
    <div class="ms-auto d-flex align-items-center gap-2">
        <span class="text-white me-2">
            <i class="fa-solid fa-circle-user me-1"></i><%= currentUser.getUsername() %> (<%= currentUser.getRole() %>)
        </span>
        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm"><i class="fa-solid fa-house me-1"></i> Dashboard</a>
        <a href="logout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket"></i></a>
    </div>
</nav>

<div class="container my-4">

    <!-- Header Section -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1"><i class="fa-solid fa-user-doctor text-success me-2"></i>Doctor Directory</h2>
            <p class="text-muted mb-0">Manage doctor details, medical specialties, and availability status.</p>
        </div>
        <div>
            <% if (isAdmin) { %>
                <a href="add-doctor.jsp" class="btn btn-success fw-bold px-3">
                    <i class="fa-solid fa-plus me-1"></i> Add New Doctor
                </a>
            <% } %>
        </div>
    </div>

    <!-- Stat Summary Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-lg-3">
            <div class="card card-stat stat-doctor p-3 bg-white shadow-sm">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Doctors</span>
                        <h2 class="fw-bold text-success mb-0"><%= totalDoctors %></h2>
                    </div>
                    <i class="fa-solid fa-user-doctor fs-1 text-success opacity-25"></i>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-3">
            <div class="card card-stat stat-spec p-3 bg-white shadow-sm">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Specialties</span>
                        <h2 class="fw-bold text-info mb-0"><%= specializations.size() %></h2>
                    </div>
                    <i class="fa-solid fa-stethoscope fs-1 text-info opacity-25"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Real-time Search Bar -->
    <div class="card p-3 mb-4 border-0 shadow-sm rounded-3">
        <div class="row g-2">
            <div class="col-12">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                    <input type="text" id="doctorSearchInput" class="form-control border-start-0"
                           placeholder="Search by Doctor Name, Specialization, or Phone..." onkeyup="filterDoctors()">
                </div>
            </div>
        </div>
    </div>

    <!-- Data Table Card -->
    <div class="card table-card bg-white p-3">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="doctorTable">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Doctor Name</th>
                        <th>Specialization</th>
                        <th>Phone</th>
                        <th>Consultation Fee</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (doctorList != null && !doctorList.isEmpty()) {
                        for (Doctor doc : doctorList) { %>
                        <tr>
                            <td class="fw-bold">#<%= doc.getId() %></td>
                            <td>
                                <div class="fw-bold text-dark">
                                    <i class="fa-solid fa-user-md text-success me-2"></i><%= doc.getName() %>
                                </div>
                            </td>
                            <td>
                                <span class="badge bg-light text-primary border border-primary-subtle px-2 py-1 fs-6">
                                    <i class="fa-solid fa-stethoscope me-1"></i><%= doc.getSpecialization() %>
                                </span>
                            </td>
                            <td><i class="fa-solid fa-phone text-muted me-1"></i><%= doc.getPhone() %></td>
                            <td>
                                <span class="fw-bold text-dark">LKR <%= String.format("%.2f", (double) doc.getConsultationFee()) %></span>
                            </td>
                            <td class="text-end">
                                <a href="view-doctor.jsp?id=<%= doc.getId() %>" class="btn btn-sm btn-outline-info me-1" title="View Details">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <% if (isAdmin) { %>
                                    <a href="edit-doctor?id=<%= doc.getId() %>" class="btn btn-sm btn-outline-primary me-1" title="Edit">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <a href="delete-doctor?id=<%= doc.getId() %>" class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Are you sure you want to delete this doctor?');" title="Delete">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                <% } %>
                            </td>
                        </tr>
                    <%  }
                       } else { %>
                        <tr id="noDataRow">
                            <td colspan="6" class="text-center py-4 text-muted">
                                <i class="fa-solid fa-folder-open fs-3 d-block mb-2"></i> No doctors found.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Real-time table filter script
    function filterDoctors() {
        const input = document.getElementById('doctorSearchInput').value.toLowerCase();
        const table = document.getElementById('doctorTable');
        const trs = table.getElementsByTagName('tr');

        for (let i = 1; i < trs.length; i++) {
            if (trs[i].id === 'noDataRow') continue;
            const tdText = trs[i].innerText.toLowerCase();
            if (tdText.includes(input)) {
                trs[i].style.display = '';
            } else {
                trs[i].style.display = 'none';
            }
        }
    }
</script>
</body>
</html>