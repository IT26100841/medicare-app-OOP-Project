<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Appointment" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="java.util.List" %>
<%
    // Session Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isAdmin = "ADMIN".equalsIgnoreCase(currentUser.getRole());
    boolean isDoctor = "DOCTOR".equalsIgnoreCase(currentUser.getRole());

    // Fallback load if accessed directly
    List<Appointment> appointments = (List<Appointment>) request.getAttribute("appointments");
    if (appointments == null) {
        appointments = DAOFactory.getAppointmentDAO().getAllAppointments();
    }

    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    if (selectedStatus == null) selectedStatus = "ALL";

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");

    // Compute stats
    int totalCount = 0;
    int bookedCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;

    List<Appointment> allList = DAOFactory.getAppointmentDAO().getAllAppointments();
    if (allList != null) {
        totalCount = allList.size();
        for (Appointment a : allList) {
            if ("Booked".equalsIgnoreCase(a.getStatus())) bookedCount++;
            else if ("Completed".equalsIgnoreCase(a.getStatus())) completedCount++;
            else if ("Cancelled".equalsIgnoreCase(a.getStatus())) cancelledCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Management - Medicare</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f4f7f6;
        }
        .stat-card {
            border-radius: 12px;
            border: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }
        .table-card {
            border-radius: 16px;
            border: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        .table > :not(caption) > * > * {
            padding: 14px 16px;
            vertical-align: middle;
        }
        .badge-booked {
            background-color: #e7f1ff;
            color: #0d6efd;
            border: 1px solid #b6d4fe;
        }
        .badge-completed {
            background-color: #e8f5e9;
            color: #198754;
            border: 1px solid #c3e6cb;
        }
        .badge-cancelled {
            background-color: #fde8e8;
            color: #dc3545;
            border: 1px solid #f5c2c7;
        }
        body.dark-mode {
            background-color: #121212 !important;
            color: #e0e0e0 !important;
        }
        body.dark-mode .card,
        body.dark-mode .table-card {
            background-color: #1e1e1e !important;
            color: #ffffff !important;
            border-color: #333333 !important;
        }
        body.dark-mode .table {
            color: #ffffff !important;
        }
        body.dark-mode .form-control {
            background-color: #2b2b2b !important;
            color: #ffffff !important;
            border-color: #444444 !important;
        }
    </style>
    <script>
        function toggleDarkMode() {
            document.body.classList.toggle('dark-mode');
            const isDark = document.body.classList.contains('dark-mode');
            localStorage.setItem('medicareDarkMode', isDark ? 'enabled' : 'disabled');
        }
        window.onload = function() {
            if (localStorage.getItem('medicareDarkMode') === 'enabled') {
                document.body.classList.add('dark-mode');
            }
        }
    </script>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary px-4 shadow-sm">
    <a class="navbar-brand fw-bold" href="dashboard.jsp">
        <i class="fa-solid fa-hospital-user me-2"></i>Medicare System
    </a>
    <div class="ms-auto d-flex align-items-center gap-2">
        <span class="text-white me-2 small">
            <i class="fa-solid fa-circle-user me-1"></i><%= currentUser.getUsername() %> (<%= currentUser.getRole() %>)
        </span>
        <button onclick="toggleDarkMode()" class="btn btn-outline-light btn-sm">
            <i class="fa-solid fa-moon"></i>
        </button>
        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm">
            <i class="fa-solid fa-house me-1"></i> Dashboard
        </a>
        <a href="logout" class="btn btn-danger btn-sm">
            <i class="fa-solid fa-right-from-bracket"></i>
        </a>
    </div>
</nav>

<div class="container py-4">

    <!-- Header Section -->
    <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
        <div>
            <h2 class="fw-bold mb-1"><i class="fa-solid fa-calendar-check text-primary me-2"></i>Appointment Directory</h2>
            <p class="text-muted mb-0">Track, schedule, edit and cancel clinical appointments</p>
        </div>
        <div>
            <a href="appointment?action=new" class="btn btn-primary shadow-sm px-4 py-2 fw-semibold">
                <i class="fa-solid fa-plus me-1"></i> Book Appointment
            </a>
        </div>
    </div>

    <!-- Alert Messages -->
    <% if ("booked".equals(msg)) { %>
        <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><strong>Success!</strong> Appointment booked successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } else if ("updated".equals(msg)) { %>
        <div class="alert alert-info alert-dismissible fade show border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><strong>Updated!</strong> Appointment details were saved.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } else if ("cancelled".equals(msg)) { %>
        <div class="alert alert-warning alert-dismissible fade show border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-ban me-2"></i><strong>Notice:</strong> Appointment has been cancelled.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } else if ("deleted".equals(msg)) { %>
        <div class="alert alert-secondary alert-dismissible fade show border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-trash me-2"></i>Appointment deleted.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } else if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Error:</strong> Action could not be processed.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- Quick Stats Cards Row -->
    <div class="row g-3 mb-4">
        <div class="col-md-3 col-6">
            <div class="card stat-card shadow-sm p-3 bg-white border-start border-primary border-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <div class="text-muted small">Total Bookings</div>
                        <h3 class="fw-bold mb-0 text-primary"><%= totalCount %></h3>
                    </div>
                    <i class="fa-solid fa-calendar-days text-primary fs-2 opacity-50"></i>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-6">
            <div class="card stat-card shadow-sm p-3 bg-white border-start border-info border-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <div class="text-muted small">Upcoming / Booked</div>
                        <h3 class="fw-bold mb-0 text-info"><%= bookedCount %></h3>
                    </div>
                    <i class="fa-solid fa-clock text-info fs-2 opacity-50"></i>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-6">
            <div class="card stat-card shadow-sm p-3 bg-white border-start border-success border-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <div class="text-muted small">Completed</div>
                        <h3 class="fw-bold mb-0 text-success"><%= completedCount %></h3>
                    </div>
                    <i class="fa-solid fa-circle-check text-success fs-2 opacity-50"></i>
                </div>
            </div>
        </div>

        <div class="col-md-3 col-6">
            <div class="card stat-card shadow-sm p-3 bg-white border-start border-danger border-4">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <div class="text-muted small">Cancelled</div>
                        <h3 class="fw-bold mb-0 text-danger"><%= cancelledCount %></h3>
                    </div>
                    <i class="fa-solid fa-ban text-danger fs-2 opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Search & Filter Bar -->
    <div class="card shadow-sm mb-4 border-0 p-3 bg-white rounded-3">
        <div class="row g-3 align-items-center">
            <!-- Search Form -->
            <div class="col-md-7">
                <form action="appointment" method="GET" class="d-flex gap-2">
                    <input type="hidden" name="action" value="list">
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                        <input type="text" name="keyword" class="form-control"
                               placeholder="Search by patient name, doctor, date (YYYY-MM-DD), or reason..."
                               value="<%= keyword != null ? keyword : "" %>">
                    </div>
                    <button type="submit" class="btn btn-outline-primary px-3">Search</button>
                    <% if (keyword != null && !keyword.isEmpty()) { %>
                        <a href="appointment?action=list" class="btn btn-outline-secondary" title="Clear search">Clear</a>
                    <% } %>
                </form>
            </div>

            <!-- Status Filter Buttons -->
            <div class="col-md-5 text-md-end">
                <div class="btn-group" role="group">
                    <a href="appointment?action=list&status=ALL"
                       class="btn btn-sm <%= "ALL".equalsIgnoreCase(selectedStatus) ? "btn-primary" : "btn-outline-secondary" %>">All</a>
                    <a href="appointment?action=list&status=Booked"
                       class="btn btn-sm <%= "Booked".equalsIgnoreCase(selectedStatus) ? "btn-info text-white" : "btn-outline-secondary" %>">Booked</a>
                    <a href="appointment?action=list&status=Completed"
                       class="btn btn-sm <%= "Completed".equalsIgnoreCase(selectedStatus) ? "btn-success" : "btn-outline-secondary" %>">Completed</a>
                    <a href="appointment?action=list&status=Cancelled"
                       class="btn btn-sm <%= "Cancelled".equalsIgnoreCase(selectedStatus) ? "btn-danger" : "btn-outline-secondary" %>">Cancelled</a>
                </div>
            </div>
        </div>
    </div>

    <!-- Appointments Table Card -->
    <div class="card table-card">
        <div class="table-responsive">
            <table class="table table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 70px;">ID</th>
                        <th>Patient</th>
                        <th>Doctor</th>
                        <th>Date & Time</th>
                        <th>Reason</th>
                        <th>Status</th>
                        <th class="text-end" style="width: 170px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (appointments != null && !appointments.isEmpty()) {
                        for (Appointment app : appointments) {
                            String badgeClass = "badge-booked";
                            String iconClass = "fa-regular fa-clock";
                            if ("Completed".equalsIgnoreCase(app.getStatus())) {
                                badgeClass = "badge-completed";
                                iconClass = "fa-solid fa-circle-check";
                            } else if ("Cancelled".equalsIgnoreCase(app.getStatus())) {
                                badgeClass = "badge-cancelled";
                                iconClass = "fa-solid fa-ban";
                            }
                    %>
                        <tr>
                            <td>
                                <span class="fw-bold text-muted">#<%= app.getAppointmentId() %></span>
                            </td>
                            <td>
                                <div class="fw-semibold"><i class="fa-solid fa-user me-1 text-primary"></i> <%= app.getPatientName() %></div>
                                <small class="text-muted">ID: <%= app.getPatientId() %></small>
                            </td>
                            <td>
                                <div class="fw-semibold"><i class="fa-solid fa-user-doctor me-1 text-success"></i> <%= app.getDoctorName() %></div>
                                <small class="text-muted"><%= app.getDoctorSpecialization() %></small>
                            </td>
                            <td>
                                <div><i class="fa-regular fa-calendar me-1 text-secondary"></i> <%= app.getAppointmentDate() %></div>
                                <small class="text-muted"><i class="fa-regular fa-clock me-1"></i> <%= app.getAppointmentTime() %></small>
                            </td>
                            <td>
                                <span class="text-truncate d-inline-block" style="max-width: 200px;" title="<%= app.getReason() %>">
                                    <%= app.getReason() %>
                                </span>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %> px-2 py-1 rounded-pill">
                                    <i class="<%= iconClass %> me-1"></i> <%= app.getStatus() %>
                                </span>
                            </td>
                            <td class="text-end">
                                <div class="btn-group btn-group-sm">
                                    <a href="appointment?action=edit&id=<%= app.getAppointmentId() %>"
                                       class="btn btn-outline-primary" title="Edit Appointment">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>

                                    <% if (!"Cancelled".equalsIgnoreCase(app.getStatus())) { %>
                                        <a href="appointment?action=confirm-cancel&id=<%= app.getAppointmentId() %>"
                                           class="btn btn-outline-danger" title="Cancel Appointment">
                                            <i class="fa-solid fa-ban"></i>
                                        </a>
                                    <% } %>

                                    <% if (isAdmin) { %>
                                        <a href="appointment?action=delete&id=<%= app.getAppointmentId() %>"
                                           class="btn btn-outline-secondary"
                                           onclick="return confirm('Permanently delete Appointment #<%= app.getAppointmentId() %>?');"
                                           title="Delete">
                                            <i class="fa-solid fa-trash"></i>
                                        </a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr>
                            <td colspan="7" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fa-regular fa-calendar-xmark fa-3x mb-3 text-secondary opacity-50"></i>
                                    <h5>No Appointments Found</h5>
                                    <p class="small">There are no appointments matching your filter or search criteria.</p>
                                    <a href="appointment?action=new" class="btn btn-sm btn-primary">
                                        <i class="fa-solid fa-plus me-1"></i> Book First Appointment
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
