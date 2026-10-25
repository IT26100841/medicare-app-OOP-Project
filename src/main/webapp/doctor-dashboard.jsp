<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");

    // Security Check: Doctor කෙනෙක් නෙවෙයි නම් Login එකට යැවීම
    if (currentUser == null || !"DOCTOR".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Medicare - Doctor Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold" href="#"><i class="fa-solid fa-user-doctor me-2"></i>Doctor Portal</a>
        <div class="d-flex align-items-center text-white">
            <span class="me-3"><i class="fa-solid fa-circle-user me-1"></i> Welcome, <%= currentUser.getName() %></span>
            <a href="logout" class="btn btn-outline-light btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </div>
</nav>

<div class="container mt-4">
    <div class="row g-4">
        <!-- My Appointments -->
        <div class="col-md-4">
            <div class="card shadow-sm border-0 text-center p-3 h-100">
                <i class="fa-solid fa-calendar-check fa-3x text-info mb-2"></i>
                <h5 class="fw-bold">My Appointments</h5>
                <p class="text-muted small">View schedule, check booked slots, and update consultations.</p>
                <div class="mt-auto d-grid gap-2">
                    <a href="appointment?action=list" class="btn btn-info text-white">View Appointments</a>
                    <a href="appointment?action=new" class="btn btn-outline-info btn-sm">Book Appointment</a>
                </div>
            </div>
        </div>

        <!-- Patient Records -->
        <div class="col-md-4">
            <div class="card shadow-sm border-0 text-center p-3 h-100">
                <i class="fa-solid fa-hospital-user fa-3x text-primary mb-2"></i>
                <h5 class="fw-bold">My Patients</h5>
                <p class="text-muted small">View patient details and medical history.</p>
                <div class="mt-auto">
                    <a href="patient-list.jsp" class="btn btn-primary w-100">View Patients</a>
                </div>
            </div>
        </div>

        <!-- Add Medical Records -->
        <div class="col-md-4">
            <div class="card shadow-sm border-0 text-center p-3">
                <i class="fa-solid fa-file-medical fa-3x text-success mb-2"></i>
                <h5 class="fw-bold">Prescriptions & Records</h5>
                <p class="text-muted small">Add prescriptions and medical notes.</p>
                <a href="patient-documents.jsp" class="btn btn-success">Manage Records</a>
            </div>
        </div>

        <!-- System Logs -->
        <div class="col-md-4">
            <div class="card shadow-sm border-0 text-center p-3">
                <i class="fa-solid fa-clock-rotate-left fa-3x text-secondary mb-2"></i>
                <h5 class="fw-bold">My Activity Logs</h5>
                <p class="text-muted small">Check your recent system activities.</p>
                <a href="audit-logs.jsp" class="btn btn-secondary">View History</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>