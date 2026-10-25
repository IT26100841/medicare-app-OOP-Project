<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%
    // 1. Security Check: නොලොග් වූ අය Login එකට Redirect කිරීම
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Patient Portal</title>

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

        /* 3D Glassmorphic Cards */
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

        /* Hero Banner 3D Gradient */
        .hero-banner-3d {
            background: linear-gradient(135deg, #0dcaf0 0%, #0d6efd 100%);
            border-radius: 20px;
            color: #ffffff;
            box-shadow: 0 12px 30px rgba(13, 202, 240, 0.25);
        }

        /* Card Top Borders for 3D Accent */
        .border-3d-info      { border-top: 6px solid #0dcaf0 !important; }
        .border-3d-primary   { border-top: 6px solid #0d6efd !important; }
        .border-3d-warning   { border-top: 6px solid #ffc107 !important; }
        .border-3d-success   { border-top: 6px solid #198754 !important; }
        .border-3d-secondary { border-top: 6px solid #6c757d !important; }

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
<nav class="navbar navbar-expand-lg navbar-dark bg-info px-4 shadow">
    <a class="navbar-brand fw-bold text-white" href="patient-portal.jsp">
        <i class="fa-solid fa-hospital-user me-2"></i>Patient Portal
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#patientNavbar">
        <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="patientNavbar">
        <div class="ms-auto d-flex align-items-center flex-wrap gap-2 mt-2 mt-lg-0">
            <span class="text-white me-3">
                <i class="fa-solid fa-circle-user me-1"></i>
                Welcome, <strong><%= currentUser.getUsername() %></strong>
            </span>

            <!-- Dark Mode Toggle Button -->
            <button onclick="toggleDarkMode()" class="btn btn-outline-light btn-sm btn-3d">
                <i class="fa-solid fa-moon me-1"></i> Dark Mode
            </button>

            <!-- Change Password Button -->
            <a href="change-password" class="btn btn-outline-light btn-sm btn-3d">
                <i class="fa-solid fa-key me-1"></i> Password
            </a>

            <!-- Logout -->
            <a href="logout" class="btn btn-danger btn-sm btn-3d">
                <i class="fa-solid fa-right-from-bracket me-1"></i> Logout
            </a>
        </div>
    </div>
</nav>

<!-- Main Container -->
<div class="container my-4 mb-5">

    <!-- Patient Welcome Hero 3D Card -->
    <div class="hero-banner-3d p-4 mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="fw-bold mb-1">
                <i class="fa-solid fa-hand-holding-medical me-2"></i>Hello, <%= currentUser.getUsername() %>!
            </h2>
            <p class="mb-0 opacity-90">Welcome to your personal Medicare healthcare portal. Manage your appointments, prescriptions, and lab reports securely.</p>
        </div>
        <div>
            <a href="appointment?action=new" class="btn btn-light text-primary btn-3d fw-bold px-3 py-2">
                <i class="fa-solid fa-calendar-plus me-1"></i> Book Appointment
            </a>
        </div>
    </div>

    <!-- Navigation Cards Grid (3D Depth Cards) -->
    <div class="row g-4">

        <!-- 1. Medical Records & Prescriptions -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-info h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-info mb-0">
                            <i class="fa-solid fa-notes-medical me-2"></i>Medical Records
                        </h5>
                        <i class="fa-solid fa-file-prescription fs-3 text-info opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">View clinical diagnoses, doctor instructions, and download PDF prescriptions.</p>
                    <div class="mt-auto d-grid">
                        <a href="medical-record-list.jsp" class="btn btn-info text-white btn-3d">My Medical Records</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Billing & Payments -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-warning h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-warning mb-0">
                            <i class="fa-solid fa-receipt me-2"></i>Billing & Invoices
                        </h5>
                        <i class="fa-solid fa-file-invoice-dollar fs-3 text-warning opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Check your consultation bills, track payment history, and download receipts.</p>
                    <div class="mt-auto d-grid">
                        <a href="bill-list.jsp" class="btn btn-warning text-dark btn-3d">My Bills & Receipts</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 3. My Appointments Schedule -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-primary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-primary mb-0">
                            <i class="fa-solid fa-calendar-check me-2"></i>My Appointments
                        </h5>
                        <i class="fa-solid fa-calendar-days fs-3 text-primary opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">View upcoming doctor visits, schedule new appointments, or request cancellations.</p>
                    <div class="mt-auto d-grid gap-2">
                        <a href="appointment?action=list" class="btn btn-outline-primary btn-3d">View Consultations</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 4. Lab Reports & Scans -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-primary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-primary mb-0">
                            <i class="fa-solid fa-folder-open me-2"></i>Lab Reports & Scans
                        </h5>
                        <i class="fa-solid fa-file-medical fs-3 text-primary opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Access blood test reports, radiology scans, and uploaded lab documents.</p>
                    <div class="mt-auto d-grid">
                        <a href="patient-documents.jsp" class="btn btn-outline-primary btn-3d">View Lab Documents</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 5. Insurance Claims -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-success h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-success mb-0">
                            <i class="fa-solid fa-shield-halved me-2"></i>Insurance Claims
                        </h5>
                        <i class="fa-solid fa-file-signature fs-3 text-success opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Submit policy claim requests and track real-time approval status.</p>
                    <div class="mt-auto d-grid">
                        <a href="insurance-claims.jsp" class="btn btn-outline-success btn-3d">My Policy Claims</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 6. Notifications & Alerts -->
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d border-3d-secondary h-100 p-3">
                <div class="card-body d-flex flex-column p-0">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-bold text-secondary mb-0">
                            <i class="fa-solid fa-bell me-2"></i>Notifications
                        </h5>
                        <i class="fa-solid fa-circle-info fs-3 text-secondary opacity-25"></i>
                    </div>
                    <p class="text-muted small mb-3">Check system alerts, visit status changes, and healthcare updates.</p>
                    <div class="mt-auto d-grid">
                        <a href="notifications.jsp" class="btn btn-secondary btn-3d">View Notifications</a>
                    </div>
                </div>
            </div>
        </div>

    </div>

</div>

<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>