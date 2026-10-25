<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Modern Healthcare Management System</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }

        /* Gradient Navigation */
        .navbar-custom {
            background: linear-gradient(135deg, #0d6efd 0%, #004085 100%);
            padding: 15px 0;
        }

        /* Hero Section */
        .hero-section {
            background: linear-gradient(135deg, rgba(13, 110, 253, 0.9) 0%, rgba(0, 64, 133, 0.95) 100%),
                        url('https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=1350&q=80') center/cover no-repeat;
            color: white;
            padding: 100px 0 120px 0;
            border-bottom-left-radius: 50px;
            border-bottom-right-radius: 50px;
        }

        .hero-title {
            font-size: 3rem;
            font-weight: 700;
        }

        /* Feature Cards */
        .feature-card {
            border: none;
            border-radius: 20px;
            transition: all 0.3s ease;
            background: white;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
        }

        .icon-box {
            width: 70px;
            height: 70px;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin-bottom: 20px;
        }

        /* Quick Stats Banner */
        .stats-section {
            margin-top: -60px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.08);
        }

        /* Footer */
        footer {
            background-color: #0b2239;
            color: #a0aec0;
            padding: 40px 0 20px 0;
        }
    </style>
</head>
<body>

    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-custom sticky-top shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold fs-3" href="index.jsp">
                <i class="fa-solid fa-hospital-user me-2"></i>Medicare
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto align-items-center gap-2">
                    <li class="nav-item"><a class="nav-link active fw-semibold" href="index.jsp">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="#services">Services</a></li>
                    <li class="nav-item"><a class="nav-link" href="#about">About System</a></li>

                    <% if (currentUser != null) { %>
                        <li class="nav-item ms-lg-3">
                            <a href="dashboard.jsp" class="btn btn-warning px-4 rounded-pill fw-semibold shadow-sm">
                                <i class="fa-solid fa-gauge me-2"></i>Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a href="logout" class="btn btn-outline-light px-3 rounded-pill">Logout</a>
                        </li>
                    <% } else { %>
                        <li class="nav-item ms-lg-3">
                            <a href="login.jsp" class="btn btn-light text-primary px-4 rounded-pill fw-semibold shadow-sm">
                                <i class="fa-solid fa-right-to-bracket me-2"></i>Login
                            </a>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section text-center text-lg-start">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-7">
                    <span class="badge bg-light text-primary px-3 py-2 rounded-pill fs-6 mb-3 fw-bold">
                        <i class="fa-solid fa-shield-halved me-2"></i>Smart Healthcare Platform
                    </span>
                    <h1 class="hero-title mb-3">Modern & Efficient Medical Management</h1>
                    <p class="lead mb-4 opacity-90">Seamlessly manage patient consultations, doctor schedules, medical history, e-billing, and notifications in one secure platform.</p>

                    <div class="d-flex flex-wrap gap-3 justify-content-center justify-content-lg-start">
                        <% if (currentUser != null) { %>
                            <a href="dashboard.jsp" class="btn btn-light btn-lg px-4 rounded-pill text-primary fw-bold shadow">
                                Go to Dashboard <i class="fa-solid fa-arrow-right ms-2"></i>
                            </a>
                        <% } else { %>
                            <a href="login.jsp" class="btn btn-light btn-lg px-4 rounded-pill text-primary fw-bold shadow">
                                Access System <i class="fa-solid fa-arrow-right ms-2"></i>
                            </a>
                        <% } %>
                        <a href="#services" class="btn btn-outline-light btn-lg px-4 rounded-pill">Explore Modules</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Quick Stats Section -->
    <div class="container stats-section">
        <div class="row g-4 text-center">
            <div class="col-md-3 col-6">
                <div class="stat-card">
                    <h2 class="fw-bold text-primary mb-1"><i class="fa-solid fa-users me-2"></i>100%</h2>
                    <p class="text-muted mb-0 fw-medium">Digital Records</p>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-card">
                    <h2 class="fw-bold text-success mb-1"><i class="fa-solid fa-user-doctor me-2"></i>24/7</h2>
                    <p class="text-muted mb-0 fw-medium">Doctor Availability</p>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-card">
                    <h2 class="fw-bold text-info mb-1"><i class="fa-solid fa-file-invoice-dollar me-2"></i>Instant</h2>
                    <p class="text-muted mb-0 fw-medium">E-Billing</p>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-card">
                    <h2 class="fw-bold text-warning mb-1"><i class="fa-solid fa-database me-2"></i>Dual Mode</h2>
                    <p class="text-muted mb-0 fw-medium">DB / File Storage</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Features / Services Section -->
    <section id="services" class="py-5 mt-4">
        <div class="container py-4">
            <div class="text-center mb-5">
                <h2 class="fw-bold text-dark">System Modules & Features</h2>
                <p class="text-muted">Everything you need for full-scope hospital and clinical administration</p>
            </div>

            <div class="row g-4">
                <!-- Patient Management -->
                <div class="col-lg-4 col-md-6">
                    <div class="card feature-card p-4 h-100 shadow-sm">
                        <div class="icon-box bg-primary bg-opacity-10 text-primary">
                            <i class="fa-solid fa-hospital-user"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Patient Records</h4>
                        <p class="text-muted">Register, edit, view, and search comprehensive patient medical profiles and history easily.</p>
                        <a href="<%= (currentUser != null) ? "patient-list.jsp" : "login.jsp" %>" class="mt-auto fw-bold text-decoration-none text-primary">
                            Manage Patients <i class="fa-solid fa-angle-right ms-1"></i>
                        </a>
                    </div>
                </div>

                <!-- Doctor Management -->
                <div class="col-lg-4 col-md-6">
                    <div class="card feature-card p-4 h-100 shadow-sm">
                        <div class="icon-box bg-success bg-opacity-10 text-success">
                            <i class="fa-solid fa-user-doctor"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Doctor Profiles</h4>
                        <p class="text-muted">Track doctor specialties, contact details, consultation fees, and available time slots.</p>
                        <a href="<%= (currentUser != null) ? "list-doctors.jsp" : "login.jsp" %>" class="mt-auto fw-bold text-decoration-none text-success">
                            View Doctors <i class="fa-solid fa-angle-right ms-1"></i>
                        </a>
                    </div>
                </div>

                <!-- Medical Records -->
                <div class="col-lg-4 col-md-6">
                    <div class="card feature-card p-4 h-100 shadow-sm">
                        <div class="icon-box bg-info bg-opacity-10 text-info">
                            <i class="fa-solid fa-file-prescription"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Medical History</h4>
                        <p class="text-muted">Record diagnosis, prescriptions, and notes directly linked to patient consultations.</p>
                        <a href="<%= (currentUser != null) ? "medical-record-list.jsp" : "login.jsp" %>" class="mt-auto fw-bold text-decoration-none text-info">
                            Access Records <i class="fa-solid fa-angle-right ms-1"></i>
                        </a>
                    </div>
                </div>

                <!-- Billing & Payments -->
                <div class="col-lg-4 col-md-6">
                    <div class="card feature-card p-4 h-100 shadow-sm">
                        <div class="icon-box bg-warning bg-opacity-10 text-warning">
                            <i class="fa-solid fa-receipt"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Billing System</h4>
                        <p class="text-muted">Generate instant consultation bills, track paid/unpaid statuses, and payment methods.</p>
                        <a href="<%= (currentUser != null) ? "bill-list.jsp" : "login.jsp" %>" class="mt-auto fw-bold text-decoration-none text-warning">
                            Manage Bills <i class="fa-solid fa-angle-right ms-1"></i>
                        </a>
                    </div>
                </div>

                <!-- System Notifications -->
                <div class="col-lg-4 col-md-6">
                    <div class="card feature-card p-4 h-100 shadow-sm">
                        <div class="icon-box bg-danger bg-opacity-10 text-danger">
                            <i class="fa-solid fa-bell"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Notifications</h4>
                        <p class="text-muted">In-system appointment status updates and important patient communication logs.</p>
                        <a href="<%= (currentUser != null) ? "notifications.jsp" : "login.jsp" %>" class="mt-auto fw-bold text-decoration-none text-danger">
                            Check Alerts <i class="fa-solid fa-angle-right ms-1"></i>
                        </a>
                    </div>
                </div>

                <!-- DAO Architecture -->
                <div class="col-lg-4 col-md-6">
                    <div class="card feature-card p-4 h-100 shadow-sm">
                        <div class="icon-box bg-secondary bg-opacity-10 text-secondary">
                            <i class="fa-solid fa-server"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Dual Storage Engine</h4>
                        <p class="text-muted">Powered by Object-Oriented DAO Factory switching seamlessly between MySQL DB and local files.</p>
                        <a href="<%= (currentUser != null) ? "dashboard.jsp" : "login.jsp" %>" class="mt-auto fw-bold text-decoration-none text-secondary">
                            View Architecture <i class="fa-solid fa-angle-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer id="about" class="mt-5">
        <div class="container text-center">
            <h4 class="fw-bold text-white mb-3"><i class="fa-solid fa-hospital-user me-2"></i>Medicare System</h4>
            <p class="mb-4 text-white-50" style="max-width: 600px; margin: 0 auto;">An integrated healthcare system for managing patients, medical staff, consultations, records, and billing efficiently.</p>
            <hr class="border-secondary my-4">
            <p class="small mb-0">&copy; Medicare Management System. All Rights Reserved.</p>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>