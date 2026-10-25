<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%
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
    <title>Medicare - Change Password</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">
<div class="container mt-5" style="max-width: 500px;">
    <div class="card shadow border-0">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="fa-solid fa-key me-2"></i>Change Password</h5>
            <a href="dashboard.jsp" class="btn btn-sm btn-outline-light">Dashboard</a>
        </div>
        <div class="card-body p-4">
            <% String error = (String) request.getAttribute("errorMessage"); %>
            <% String success = (String) request.getAttribute("successMessage"); %>

            <% if (error != null) { %>
                <div class="alert alert-danger py-2"><%= error %></div>
            <% } %>
            <% if (success != null) { %>
                <div class="alert alert-success py-2"><%= success %></div>
            <% } %>

            <form action="change-password" method="post">
                <div class="mb-3">
                    <label class="form-label">Current Password</label>
                    <input type="password" name="currentPassword" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">New Password</label>
                    <input type="password" name="newPassword" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Confirm New Password</label>
                    <input type="password" name="confirmPassword" class="form-control" required>
                </div>
                <button type="submit" class="btn btn-primary w-100 fw-bold">Update Password</button>
            </form>
        </div>
    </div>
</div>
</body>
</html>