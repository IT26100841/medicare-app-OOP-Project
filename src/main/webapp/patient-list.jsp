<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Patient" %>
<%@ page import="com.medicare.dao.PatientDAO" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="java.util.List" %>

<%
    // 1. Session Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Role Check (ADMIN ද නැද්ද යන්න)
    boolean isAdmin = "ADMIN".equalsIgnoreCase(currentUser.getRole());

    // 3. Patient List එක Load කිරීම
    PatientDAO patientDAO = DAOFactory.getPatientDAO();
    List<Patient> patientList = patientDAO.getAllPatients();

    int totalPatients = (patientList != null) ? patientList.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Patient Management</title>
    <!-- Bootstrap 5 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Custom 3D Floating Depth Styling -->
    <style>
        body {
            background: #f0f3f8;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        /* 3D Glassmorphic Cards */
        .card-3d {
            border: none;
            border-radius: 20px;
            background: #ffffff;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.8);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        .card-3d:hover {
            transform: translateY(-5px);
            box-shadow: 0 18px 38px rgba(0, 0, 0, 0.12), inset 0 1px 0 rgba(255, 255, 255, 0.9);
        }

        /* Stat Card Accent */
        .stat-card-patient {
            border-left: 6px solid #0d6efd;
            background: linear-gradient(135deg, #ffffff 0%, #f0f5ff 100%);
        }

        /* 3D Interactive Buttons */
        .btn-3d {
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
            transition: all 0.2s ease-in-out;
            font-weight: 600;
        }
        .btn-3d:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.18);
        }
        .btn-3d:active {
            transform: translateY(1px);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15);
        }

        /* 3D Table Customization */
        .table-container-3d {
            border-radius: 16px;
            overflow: hidden;
            background: #ffffff;
            box-shadow: 0 8px 25px rgba(0,0,0,0.06);
        }
        .table thead {
            background: linear-gradient(180deg, #2b3035 0%, #1a1e21 100%);
            color: #ffffff;
        }

        .badge-3d {
            border-radius: 8px;
            padding: 6px 12px;
            font-weight: 600;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>

<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary px-4 shadow">
    <a class="navbar-brand fw-bold" href="dashboard.jsp">
        <i class="fa-solid fa-hospital-user me-2"></i>Medicare System
    </a>
    <div class="ms-auto d-flex align-items-center gap-2">
        <span class="text-white me-2">
            <i class="fa-solid fa-circle-user me-1"></i>Logged in as: <strong><%= currentUser.getUsername() %></strong>
            <span class="badge bg-light text-primary ms-1"><%= currentUser.getRole() %></span>
        </span>

        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm btn-3d">
            <i class="fa-solid fa-house me-1"></i> Dashboard
        </a>
        <a href="appointment?action=list" class="btn btn-light text-primary btn-sm btn-3d fw-bold">
            <i class="fa-solid fa-calendar-check me-1"></i> Appointments
        </a>
        <a href="logout" class="btn btn-danger btn-sm btn-3d">
            <i class="fa-solid fa-right-from-bracket"></i>
        </a>
    </div>
</nav>

<div class="container-fluid px-4 my-4 mb-5">

    <!-- Header Section -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="fa-solid fa-users me-2 text-primary"></i>Patient Management
            </h2>
            <p class="text-muted mb-0">Manage clinical profiles, view medical histories, and update patient registration details.</p>
        </div>
        <div>
            <% if (isAdmin) { %>
                <a href="add-patient.jsp" class="btn btn-success btn-3d fw-bold px-3 py-2">
                    <i class="fa-solid fa-user-plus me-1"></i> Add New Patient
                </a>
            <% } %>
        </div>
    </div>

    <!-- Stat Summary 3D Card -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-lg-3">
            <div class="card card-3d stat-card-patient p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Registered Patients</span>
                        <h2 class="fw-bold text-primary mb-0"><%= totalPatients %></h2>
                    </div>
                    <div class="rounded-circle bg-primary bg-opacity-10 p-3">
                        <i class="fa-solid fa-user-injured fs-1 text-primary"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Instant Real-Time Search Filter Bar -->
    <div class="card card-3d p-3 mb-4">
        <div class="input-group">
            <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
            <input type="text" id="patientSearchInput" class="form-control border-start-0"
                   placeholder="Search by Patient Name, ID, Phone, Blood Group, or Medical History..." onkeyup="filterPatients()">
        </div>
    </div>

    <!-- Patient Data Table 3D Card Container -->
    <div class="card card-3d p-4">
        <div class="table-responsive table-container-3d">
            <table class="table table-hover align-middle mb-0" id="patientTable">
                <thead>
                    <tr>
                        <th class="py-3">ID</th>
                        <th class="py-3">Name</th>
                        <th class="py-3">Email</th>
                        <th class="py-3">Age</th>
                        <th class="py-3">Gender</th>
                        <th class="py-3">Phone</th>
                        <th class="py-3">Address</th>
                        <th class="py-3">Blood Group</th>
                        <th class="py-3">Allergies</th>
                        <th class="py-3">Medical History</th>
                        <th class="text-center py-3">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (patientList != null && !patientList.isEmpty()) {
                        for (Patient patient : patientList) { %>
                            <tr>
                                <td class="fw-bold text-dark">#<%= patient.getId() %></td>
                                <td>
                                    <div class="fw-bold text-dark">
                                        <i class="fa-solid fa-user text-primary me-2"></i><%= patient.getName() %>
                                    </div>
                                </td>
                                <td>
                                    <% if (patient.getEmail() != null && !patient.getEmail().trim().isEmpty()) { %>
                                        <span class="text-dark small"><i class="fa-regular fa-envelope me-1 text-muted"></i><%= patient.getEmail() %></span>
                                    <% } else { %>
                                        <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge badge-3d bg-light text-dark border"><%= patient.getAge() %> Yrs</span>
                                </td>
                                <td>
                                    <span class="badge badge-3d bg-info text-dark"><%= patient.getGender() %></span>
                                </td>
                                <td>
                                    <% if (patient.getPhone() != null && !patient.getPhone().trim().isEmpty()) { %>
                                        <small class="fw-bold text-dark"><i class="fa-solid fa-phone me-1 text-muted"></i><%= patient.getPhone() %></small>
                                    <% } else { %>
                                        <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (patient.getAddress() != null && !patient.getAddress().trim().isEmpty()) { %>
                                        <small class="text-secondary"><%= patient.getAddress() %></small>
                                    <% } else { %>
                                        <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (patient.getBloodGroup() != null && !patient.getBloodGroup().trim().isEmpty()) { %>
                                        <span class="badge badge-3d bg-danger text-white">
                                            <i class="fa-solid fa-droplet me-1"></i><%= patient.getBloodGroup() %>
                                        </span>
                                    <% } else { %>
                                        <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <small class="text-dark"><%= (patient.getAllergies() != null && !patient.getAllergies().trim().isEmpty()) ? patient.getAllergies() : "-" %></small>
                                </td>
                                <td>
                                    <small class="text-muted"><%= (patient.getMedicalHistory() != null && !patient.getMedicalHistory().trim().isEmpty()) ? patient.getMedicalHistory() : "-" %></small>
                                </td>
                                <td class="text-center">
                                    <div class="d-inline-flex gap-1">
                                        <!-- View Details: Doctor සහ Admin දෙදෙනාටම පෙනේ -->
                                        <a href="view-patient.jsp?id=<%= patient.getId() %>" class="btn btn-sm btn-info text-white btn-3d" title="View Details">
                                            <i class="fa-solid fa-eye me-1"></i> View
                                        </a>

                                        <!-- Edit & Delete Buttons: ADMIN ට පමණක් පෙනේ -->
                                        <% if (isAdmin) { %>
                                            <a href="edit-patient?id=<%= patient.getId() %>" class="btn btn-sm btn-warning btn-3d" title="Edit Patient">
                                                <i class="fa-solid fa-pen-to-square me-1"></i> Edit
                                            </a>
                                            <a href="delete-patient?id=<%= patient.getId() %>" class="btn btn-sm btn-danger btn-3d"
                                               onclick="return confirm('Are you sure you want to delete this patient?');" title="Delete Patient">
                                                <i class="fa-solid fa-trash me-1"></i> Delete
                                            </a>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                    <%  }
                       } else { %>
                            <tr id="noDataRow">
                                <td colspan="11" class="text-center text-muted py-4">
                                    <i class="fa-solid fa-folder-open fs-3 d-block mb-2"></i> No patients found.
                                </td>
                            </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Real-Time Table Filter Function
    function filterPatients() {
        const input = document.getElementById('patientSearchInput').value.toLowerCase();
        const table = document.getElementById('patientTable');
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