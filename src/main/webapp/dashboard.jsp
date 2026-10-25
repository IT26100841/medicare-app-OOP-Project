<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Bill" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="com.medicare.service.PharmacyService" %>
<%@ page import="java.util.List" %>
<%
    // 1. Security Check: නොලොග් වූ අය Login එකට Redirect කිරීම
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Role එක Check කර ගැනීම (ADMIN ද නැද්ද යන්න)
    boolean isAdmin = "ADMIN".equalsIgnoreCase(currentUser.getRole());

    String currentStorageMode = DAOFactory.getStorageMode();

    // 2. Database එකෙන් සජීවී දත්ත (Real-time Counts) ලබා ගැනීම
    int patientCount = 0;
    int doctorCount = 0;
    int recordCount = 0;
    int billCount = 0;
    int appointmentCount = 0;
    int bookedAppointmentCount = 0;
    double totalRevenue = 0.0;

    try {
        if (DAOFactory.getPatientDAO() != null && DAOFactory.getPatientDAO().getAllPatients() != null) {
            patientCount = DAOFactory.getPatientDAO().getAllPatients().size();
        }
        if (DAOFactory.getDoctorDAO() != null && DAOFactory.getDoctorDAO().getAllDoctors() != null) {
            doctorCount = DAOFactory.getDoctorDAO().getAllDoctors().size();
        }
        if (DAOFactory.getAppointmentDAO() != null && DAOFactory.getAppointmentDAO().getAllAppointments() != null) {
            List<com.medicare.model.Appointment> apps = DAOFactory.getAppointmentDAO().getAllAppointments();
            appointmentCount = apps.size();
            for (com.medicare.model.Appointment a : apps) {
                if ("Booked".equalsIgnoreCase(a.getStatus())) {
                    bookedAppointmentCount++;
                }
            }
        }
        if (DAOFactory.getMedicalRecordDAO() != null && DAOFactory.getMedicalRecordDAO().getAllMedicalRecords() != null) {
            recordCount = DAOFactory.getMedicalRecordDAO().getAllMedicalRecords().size();
        }
        if (DAOFactory.getBillDAO() != null && DAOFactory.getBillDAO().getAllBills() != null) {
            List<Bill> bills = DAOFactory.getBillDAO().getAllBills();
            billCount = bills.size();
            for (Bill b : bills) {
                if (b != null && "Paid".equalsIgnoreCase(b.getPaymentStatus())) {
                    totalRevenue += b.getAmount();
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Main Dashboard</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Custom 3D Floating Depth Styling -->
    <style>
        body {
            background: #f0f3f8;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            transition: background-color 0.3s ease, color 0.3s ease;
        }

        /* 3D Glassmorphic Cards with Soft Shadow Elevation */
        .card-3d {
            border: none;
            border-radius: 20px;
            background: #ffffff;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.8);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            position: relative;
            overflow: hidden;
        }
        .card-3d:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.14), inset 0 1px 0 rgba(255, 255, 255, 0.9);
        }

        /* 3D Accent Borders */
        .border-3d-primary   { border-top: 6px solid #0d6efd !important; }
        .border-3d-success   { border-top: 6px solid #198754 !important; }
        .border-3d-info      { border-top: 6px solid #0dcaf0 !important; }
        .border-3d-warning   { border-top: 6px solid #ffc107 !important; }
        .border-3d-secondary { border-top: 6px solid #6c757d !important; }
        .border-3d-danger    { border-top: 6px solid #dc3545 !important; }
        .border-3d-dark      { border-top: 6px solid #212529 !important; }

        /* 3D Interactive Buttons */
        .btn-3d {
            border-radius: 12px;
            box-shadow: 0 5px 12px rgba(0, 0, 0, 0.12);
            transition: all 0.2s ease-in-out;
            font-weight: 600;
        }
        .btn-3d:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.18);
        }
        .btn-3d:active {
            transform: translateY(2px);
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
        }

        /* Glossy Badges */
        .badge-3d {
            border-radius: 10px;
            padding: 8px 14px;
            font-weight: 600;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.12);
        }

        /* Dark Mode Extensions */
        body.dark-mode {
            background-color: #121212 !important;
            color: #e0e0e0 !important;
        }
        body.dark-mode .card-3d {
            background-color: #1e1e1e !important;
            color: #ffffff !important;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.05);
        }
        body.dark-mode .text-muted {
            color: #b0b0b0 !important;
        }
        body.dark-mode .card-header {
            background-color: #2a2a2a !important;
            color: #ffffff !important;
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

<!-- Top 3D Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary px-4 shadow-sm">
    <a class="navbar-brand fw-bold" href="dashboard.jsp">
        <i class="fa-solid fa-hospital-user me-2"></i>Medicare System
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#dashboardNavbar">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="dashboardNavbar">
        <div class="ms-auto d-flex align-items-center flex-wrap gap-2 mt-2 mt-lg-0">
            <span class="text-white me-3">
                <i class="fa-solid fa-circle-user me-1"></i>
                <strong><%= currentUser.getUsername() %></strong>
                <span class="badge bg-light text-primary ms-1"><%= currentUser.getRole() %></span>
            </span>

            <!-- Appointments Navigation Link -->
            <a href="appointment?action=list" class="btn btn-light text-primary btn-sm btn-3d fw-bold">
                <i class="fa-solid fa-calendar-check me-1"></i> Appointments
                <% if (bookedAppointmentCount > 0) { %>
                    <span class="badge bg-primary text-white ms-1"><%= bookedAppointmentCount %></span>
                <% } else { %>
                    (<%= bookedAppointmentCount %>)
                <% } %>
            </a>

            <!-- Dark Mode Toggle Button -->
            <button onclick="toggleDarkMode()" class="btn btn-outline-light btn-sm btn-3d">
                <i class="fa-solid fa-moon me-1"></i> Dark Mode
            </button>

            <!-- Change Password Button -->
            <a href="change-password" class="btn btn-outline-light btn-sm btn-3d">
                <i class="fa-solid fa-key me-1"></i> Password
            </a>

            <!-- System Settings (ADMIN Only) -->
            <% if (isAdmin) { %>
                <a href="settings.jsp" class="btn btn-dark btn-sm btn-3d">
                    <i class="fa-solid fa-gear me-1"></i> Settings
                </a>
            <% } %>

            <!-- Logout -->
            <a href="logout" class="btn btn-danger btn-sm btn-3d">
                <i class="fa-solid fa-right-from-bracket me-1"></i> Logout
            </a>
        </div>
    </div>
</nav>

<!-- Main Container -->
<div class="container my-4 mb-5">

    <%-- Pharmacy Expiry Alerts Banner --%>
    <%
        try {
            List<String> expiryAlerts = PharmacyService.getExpiringMedicinesAlerts();
            if (expiryAlerts != null && !expiryAlerts.isEmpty()) {
                for (String alertMsg : expiryAlerts) {
    %>
        <div class="alert alert-warning alert-dismissible fade show card-3d p-3 border-start border-warning border-5 mb-4" role="alert">
            <div class="d-flex align-items-center">
                <i class="fa-solid fa-triangle-exclamation text-warning me-3 fs-3"></i>
                <div>
                    <strong>Pharmacy Inventory Alert:</strong> <%= alertMsg %>
                </div>
            </div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
                }
            }
        } catch (Exception e) {
            // Suppress if table empty or not created yet
        }
    %>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1 text-dark">System Control Panel</h2>
            <p class="text-muted mb-0">Overview of clinical modules, patient directories, and real-time system metrics.</p>
        </div>
        <span class="badge badge-3d bg-success text-white fs-6">
            <i class="fa-solid fa-database me-1"></i> Mode: <%= currentStorageMode %>
        </span>
    </div>

    <!-- Navigation Cards Grid (3D Depth Cards) -->
    <div class="row g-4">

        <!-- 0. Appointments Management -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-primary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-primary mb-0"><i class="fa-solid fa-calendar-check me-2"></i>Appointments</h5>
                        <% if (bookedAppointmentCount > 0) { %>
                            <span class="badge bg-primary text-white rounded-pill px-3 py-1"><%= bookedAppointmentCount %> Active</span>
                        <% } else { %>
                            <i class="fa-solid fa-calendar-days fs-3 text-primary opacity-25"></i>
                        <% } %>
                    </div>
                    <p class="text-muted small mb-3">Book consultations, detect doctor slot conflicts, view, edit and cancel visits.</p>
                    <div class="mt-auto d-grid gap-2">
                        <a href="appointment?action=list" class="btn btn-outline-primary btn-3d btn-sm">Manage Appointments (<%= appointmentCount %>)</a>
                        <a href="appointment?action=new" class="btn btn-sm btn-primary btn-3d">Book New Appointment</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 1. Patient Directory -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-primary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-primary mb-0"><i class="fa-solid fa-users me-2"></i>Patient Directory</h5>
                        <i class="fa-solid fa-user-injured fs-3 text-primary opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Register, view, search, edit or remove patient medical profiles.</p>
                    <div class="mt-auto d-grid">
                        <a href="patient-list.jsp" class="btn btn-outline-primary btn-3d btn-sm">View Patients (<%= patientCount %>)</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Doctor Directory -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-success h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-success mb-0"><i class="fa-solid fa-user-doctor me-2"></i>Doctor Directory</h5>
                        <i class="fa-solid fa-stethoscope fs-3 text-success opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Manage doctor details, medical specialties, and availability status.</p>
                    <div class="mt-auto d-grid">
                        <a href="list-doctors.jsp" class="btn btn-outline-success btn-3d btn-sm">View Doctors (<%= doctorCount %>)</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. Medical Records -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-info h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-info mb-0"><i class="fa-solid fa-notes-medical me-2"></i>Medical Records</h5>
                        <i class="fa-solid fa-file-prescription fs-3 text-info opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Record clinical diagnoses, write prescriptions, and print PDF reports.</p>
                    <div class="mt-auto d-grid gap-2">
                        <a href="medical-record-list.jsp" class="btn btn-outline-info btn-3d btn-sm">View Records (<%= recordCount %>)</a>
                        <a href="add-medical-record.jsp" class="btn btn-sm btn-info text-white btn-3d">Add Record</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. Billing & Payments -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-warning h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-warning mb-0"><i class="fa-solid fa-receipt me-2"></i>Billing & Payments</h5>
                        <i class="fa-solid fa-file-invoice-dollar fs-3 text-warning opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Create consultation bills, track payment status, and download receipts.</p>
                    <div class="mt-auto d-grid gap-2">
                        <a href="bill-list.jsp" class="btn btn-outline-warning text-dark btn-3d btn-sm">Manage Bills (<%= billCount %>)</a>
                        <% if (isAdmin) { %>
                            <a href="create-bill.jsp" class="btn btn-sm btn-warning text-dark btn-3d">Create Bill</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- 5. Lab Reports & Scans -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-primary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-primary mb-0"><i class="fa-solid fa-file-medical me-2"></i>Lab Reports & Scans</h5>
                        <i class="fa-solid fa-folder-open fs-3 text-primary opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Upload and manage patient X-rays, blood reports, and clinical documents.</p>
                    <div class="mt-auto d-grid">
                        <a href="patient-documents.jsp" class="btn btn-outline-primary btn-3d btn-sm">Manage Documents</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 6. Insurance Claims -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-success h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-success mb-0"><i class="fa-solid fa-shield-halved me-2"></i>Insurance Claims</h5>
                        <i class="fa-solid fa-file-signature fs-3 text-success opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Submit patient policy details and track approval or rejection status.</p>
                    <div class="mt-auto d-grid">
                        <a href="insurance-claims.jsp" class="btn btn-outline-success btn-3d btn-sm">Manage Claims</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 7. Notifications -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-secondary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-secondary mb-0"><i class="fa-solid fa-bell me-2"></i>Notifications</h5>
                        <i class="fa-solid fa-circle-info fs-3 text-secondary opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Check appointment updates, system alerts, and message history.</p>
                    <div class="mt-auto d-grid">
                        <a href="notifications.jsp" class="btn btn-outline-secondary btn-3d btn-sm">View Notifications</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 8. System Audit Logs (ADMIN Only) -->
        <% if (isAdmin) { %>
            <div class="col-md-6 col-lg-4">
                <div class="card card-3d border-3d-dark h-100 p-3">
                    <div class="card-body d-flex flex-column p-0">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5 class="fw-bold text-dark mb-0"><i class="fa-solid fa-clock-rotate-left me-2"></i>System Audit Logs</h5>
                            <i class="fa-solid fa-shield-cat fs-3 text-dark opacity-25"></i>
                        </div>
                        <p class="text-muted small mb-3">Review full system security logs, user actions, and timestamps.</p>
                        <div class="mt-auto d-grid">
                            <a href="audit-logs.jsp" class="btn btn-outline-dark btn-3d btn-sm">View System History</a>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>

    </div>

    <!-- Analytics & Real-Time Graphical Charts Section -->
    <div class="row mt-5 g-4">
        <div class="col-md-6">
            <div class="card card-3d p-3">
                <div class="card-header bg-white fw-bold border-0 fs-6">
                    <i class="fa-solid fa-chart-pie me-2 text-primary"></i>Real-time Data Distribution
                </div>
                <div class="card-body">
                    <canvas id="systemDataChart" style="max-height: 260px;"></canvas>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card card-3d p-3">
                <div class="card-header bg-white fw-bold border-0 fs-6">
                    <i class="fa-solid fa-chart-column me-2 text-success"></i>Revenue Overview ($)
                </div>
                <div class="card-body">
                    <canvas id="revenueChart" style="max-height: 260px;"></canvas>
                </div>
            </div>
        </div>
    </div>

</div>

<!-- Bootstrap & Chart.js JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    // 1. Dynamic System Data Distribution Doughnut Chart
    const ctx1 = document.getElementById('systemDataChart').getContext('2d');
    new Chart(ctx1, {
        type: 'doughnut',
        data: {
            labels: ['Appointments', 'Patients', 'Doctors', 'Medical Records', 'Bills'],
            datasets: [{
                data: [<%= appointmentCount %>, <%= patientCount %>, <%= doctorCount %>, <%= recordCount %>, <%= billCount %>],
                backgroundColor: ['#0d6efd', '#198754', '#0dcaf0', '#ffc107', '#6c757d']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });

    // 2. Dynamic Revenue Summary Bar Chart
    const ctx2 = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctx2, {
        type: 'bar',
        data: {
            labels: ['Total Revenue ($)'],
            datasets: [{
                label: 'Paid Revenue ($)',
                data: [<%= totalRevenue %>],
                backgroundColor: '#198754',
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
</script>

</body>
</html>