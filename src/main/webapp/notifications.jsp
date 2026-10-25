<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="com.medicare.model.Notification" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="java.util.List" %>
<%
    // 1. Session Check & Security
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Fetch Notifications List
    List<Notification> list = null;
    try {
        if (DAOFactory.getNotificationDAO() != null) {
            list = DAOFactory.getNotificationDAO().getAllNotifications();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    int totalNotifications = (list != null) ? list.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - System Notifications</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Custom 3D & Depth Styling -->
    <style>
        body {
            background: #f0f3f8;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        /* 3D Glassmorphic Cards */
        .card-3d {
            border: none;
            border-radius: 18px;
            background: #ffffff;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.6);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        .card-3d:hover {
            transform: translateY(-4px);
            box-shadow: 0 18px 38px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255, 255, 255, 0.8);
        }

        /* Stat Card Accent Borders */
        .stat-card-bell {
            border-left: 6px solid #6c757d;
            background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        }

        /* Notification Feed Item 3D Style */
        .notification-item-3d {
            border: none;
            border-radius: 14px;
            background: #ffffff;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            transition: all 0.2s ease-in-out;
            border-left: 5px solid #0d6efd;
        }
        .notification-item-3d:hover {
            transform: scale(1.01) translateX(4px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        }

        /* 3D Button Shadows */
        .btn-3d {
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
            transition: all 0.2s ease;
        }
        .btn-3d:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
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
            <i class="fa-solid fa-circle-user me-1"></i><%= currentUser.getUsername() %> (<%= currentUser.getRole() %>)
        </span>
        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm btn-3d">
            <i class="fa-solid fa-house me-1"></i> Dashboard
        </a>
        <a href="logout" class="btn btn-danger btn-sm btn-3d">
            <i class="fa-solid fa-right-from-bracket"></i>
        </a>
    </div>
</nav>

<div class="container my-4 mb-5">

    <!-- Header Section -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="fa-solid fa-bell text-secondary me-2"></i>System Notifications
            </h2>
            <p class="text-muted mb-0">Track appointment status updates, clinical alerts, and system messages.</p>
        </div>
    </div>

    <!-- Stat Summary 3D Card -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d stat-card-bell p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Notifications</span>
                        <h2 class="fw-bold text-secondary mb-0"><%= totalNotifications %></h2>
                    </div>
                    <div class="rounded-circle bg-secondary bg-opacity-10 p-3">
                        <i class="fa-solid fa-bell fs-1 text-secondary"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content 3D Card -->
    <div class="card card-3d p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="fw-bold text-dark mb-0">
                <i class="fa-solid fa-clock-rotate-left me-2 text-primary"></i>Notification Stream
            </h5>
        </div>

        <!-- Real-Time Search Filter -->
        <div class="mb-4">
            <div class="input-group">
                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                <input type="text" id="notificationSearchInput" class="form-control border-start-0"
                       placeholder="Search by Patient ID or message text..." onkeyup="filterNotifications()">
            </div>
        </div>

        <!-- Notification List Feed -->
        <div id="notificationList" class="d-flex flex-column gap-3">
            <% if (list != null && !list.isEmpty()) { %>
                <% for (Notification n : list) { %>
                    <div class="p-3 notification-item-3d notification-card">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <div class="d-flex align-items-center gap-2">
                                <i class="fa-solid fa-circle-info text-primary fs-5"></i>
                                <span class="badge badge-3d bg-primary text-white">
                                    <i class="fa-solid fa-user me-1"></i>Patient ID: <%= n.getPatientId() %>
                                </span>
                            </div>
                            <small class="text-muted fw-bold">
                                <i class="fa-regular fa-clock me-1"></i><%= n.getDate() %>
                            </small>
                        </div>
                        <p class="mb-0 text-dark fw-semibold ms-4"><%= n.getMessage() %></p>
                    </div>
                <% } %>
            <% } else { %>
                <div class="text-center py-5 text-muted" id="noNotificationMsg">
                    <i class="fa-solid fa-bell-slash fs-1 d-block mb-3 text-secondary opacity-50"></i>
                    <h6 class="fw-bold">No Notifications Available</h6>
                    <p class="small mb-0">You are all caught up! New alerts will appear here automatically.</p>
                </div>
            <% } %>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Real-time Search Filter for Notification Feed
    function filterNotifications() {
        const input = document.getElementById('notificationSearchInput').value.toLowerCase();
        const cards = document.getElementsByClassName('notification-card');

        for (let i = 0; i < cards.length; i++) {
            const cardText = cards[i].innerText.toLowerCase();
            if (cardText.includes(input)) {
                cards[i].style.display = '';
            } else {
                cards[i].style.display = 'none';
            }
        }
    }
</script>
</body>
</html>