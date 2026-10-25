<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Appointment" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%
    // Session Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Appointment app = (Appointment) request.getAttribute("appointment");
    if (app == null) {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idStr.trim());
                app = DAOFactory.getAppointmentDAO().getAppointmentById(id);
            } catch (Exception ignored) {}
        }
    }

    if (app == null) {
        response.sendRedirect("appointment?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cancel Appointment #<%= app.getAppointmentId() %> - Medicare</title>
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
        .cancel-card {
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(220, 53, 69, 0.12);
            border: 1px solid #f5c2c7;
            overflow: hidden;
        }
        .cancel-header {
            background: linear-gradient(135deg, #dc3545 0%, #b02a37 100%);
            color: white;
            padding: 24px 30px;
        }
        body.dark-mode {
            background-color: #121212 !important;
            color: #e0e0e0 !important;
        }
        body.dark-mode .card {
            background-color: #1e1e1e !important;
            color: #ffffff !important;
            border-color: #552222 !important;
        }
        body.dark-mode .list-group-item {
            background-color: #2b2b2b !important;
            color: #ffffff !important;
            border-color: #444444 !important;
        }
    </style>
    <script>
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
        <a href="appointment?action=list" class="btn btn-outline-light btn-sm">
            <i class="fa-solid fa-arrow-left me-1"></i> Back to List
        </a>
    </div>
</nav>

<div class="container py-5" style="max-width: 650px;">
    <div class="card cancel-card bg-white">
        <div class="cancel-header text-center py-4">
            <i class="fa-solid fa-triangle-exclamation fa-3x mb-2 text-white"></i>
            <h4 class="fw-bold mb-1">Confirm Appointment Cancellation</h4>
            <p class="text-white-50 mb-0 small">Are you sure you want to cancel this booking?</p>
        </div>

        <div class="card-body p-4 p-md-5">

            <div class="alert alert-warning border-0 shadow-sm d-flex align-items-center mb-4">
                <i class="fa-solid fa-circle-info fs-4 me-3 text-warning"></i>
                <small>Cancelling this appointment will release the doctor's time slot for other patients and update the record status to <strong>Cancelled</strong>.</small>
            </div>

            <!-- Appointment Summary -->
            <ul class="list-group list-group-flush mb-4 rounded-3 border">
                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                    <span class="text-muted"><i class="fa-solid fa-hashtag me-2 text-primary"></i>Appointment ID</span>
                    <span class="fw-bold">#<%= app.getAppointmentId() %></span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                    <span class="text-muted"><i class="fa-solid fa-user me-2 text-primary"></i>Patient</span>
                    <span class="fw-bold"><%= app.getPatientName() %> (ID: <%= app.getPatientId() %>)</span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                    <span class="text-muted"><i class="fa-solid fa-user-doctor me-2 text-success"></i>Doctor</span>
                    <span class="fw-bold"><%= app.getDoctorName() %></span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                    <span class="text-muted"><i class="fa-regular fa-calendar me-2 text-secondary"></i>Date & Time</span>
                    <span class="fw-bold"><%= app.getAppointmentDate() %> at <%= app.getAppointmentTime() %></span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                    <span class="text-muted"><i class="fa-solid fa-notes-medical me-2 text-danger"></i>Reason</span>
                    <span class="fw-medium text-end"><%= app.getReason() %></span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center py-3">
                    <span class="text-muted"><i class="fa-solid fa-signal me-2 text-info"></i>Current Status</span>
                    <span class="badge bg-primary px-3 py-2"><%= app.getStatus() %></span>
                </li>
            </ul>

            <!-- Confirmation Form -->
            <form action="appointment" method="POST">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="id" value="<%= app.getAppointmentId() %>">

                <div class="d-flex justify-content-end gap-2">
                    <a href="appointment?action=list" class="btn btn-outline-secondary px-4">
                        Keep Appointment
                    </a>
                    <button type="submit" class="btn btn-danger px-4 fw-semibold">
                        <i class="fa-solid fa-ban me-1"></i> Yes, Cancel Appointment
                    </button>
                </div>
            </form>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
