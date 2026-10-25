<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%
    // Security Check: නොලොග් වූ අය Login එකට Redirect කිරීම
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String currentMode = DAOFactory.getStorageMode();
    String statusParam = request.getParameter("status");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - System Settings</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">

<div class="container mt-4 mb-5" style="max-width: 900px;">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2><i class="fa-solid fa-gear text-dark me-2"></i>System Settings & Configuration</h2>
        <a href="dashboard.jsp" class="btn btn-secondary">
            <i class="fa-solid fa-arrow-left me-1"></i> Dashboard
        </a>
    </div>
    <hr>

    <% if ("success".equalsIgnoreCase(statusParam)) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i>System settings updated successfully!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <form action="settings" method="post">
        <!-- 1. Storage Architecture Settings -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-primary text-white fw-bold">
                <i class="fa-solid fa-database me-2"></i>Data Storage Mode Configuration
            </div>
            <div class="card-body">
                <p class="text-muted small">
                    Medicare System එකේ Dual-Storage DAO Pattern එක මගින් MySQL Database එක හෝ Local File Storage එක අතර පහසුවෙන් Switch කළ හැක.
                </p>

                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="form-check card p-3 border <%= "MYSQL".equalsIgnoreCase(currentMode) ? "border-primary bg-light" : "" %>">
                            <input class="form-check-input" type="radio" name="storageMode" id="modeMysql" value="MYSQL" <%= "MYSQL".equalsIgnoreCase(currentMode) ? "checked" : "" %>>
                            <label class="form-check-label fw-bold ms-2" for="modeMysql">
                                <i class="fa-solid fa-server text-primary me-1"></i> MySQL Database Mode
                            </label>
                            <small class="text-muted d-block ms-4 mt-1">High performance relational database connection (Recommended for Production).</small>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-check card p-3 border <%= "FILE".equalsIgnoreCase(currentMode) ? "border-primary bg-light" : "" %>">
                            <input class="form-check-input" type="radio" name="storageMode" id="modeFile" value="FILE" <%= "FILE".equalsIgnoreCase(currentMode) ? "checked" : "" %>>
                            <label class="form-check-label fw-bold ms-2" for="modeFile">
                                <i class="fa-solid fa-file-code text-warning me-1"></i> File Storage Mode (.txt / .dat)
                            </label>
                            <small class="text-muted d-block ms-4 mt-1">Local file system storage (Offline / Failover mode).</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Hospital General Details -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-dark text-white fw-bold">
                <i class="fa-solid fa-hospital me-2"></i>Hospital / Clinic Information
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Hospital Name</label>
                        <input type="text" name="hospitalName" class="form-control" value="Medicare Health Center" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Contact Hotline</label>
                        <input type="text" name="contactNumber" class="form-control" value="+94 11 234 5678" required>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label fw-semibold">Hospital Address</label>
                        <input type="text" name="address" class="form-control" value="123, Healthcare Avenue, Colombo 03" required>
                    </div>
                </div>
            </div>
        </div>

        <div class="text-end">
            <button type="submit" class="btn btn-success btn-lg px-4 fw-bold">
                <i class="fa-solid fa-floppy-disk me-2"></i>Save Configurations
            </button>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>