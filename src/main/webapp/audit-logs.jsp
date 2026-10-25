<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.util.DBConnection" %>
<%@ page import="java.sql.*" %>
<%
    // Security Check: නොලොග් වූ අය Login එකට Redirect කිරීම
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Dynamic Audit Statistics Calculation
    int totalLogs = 0;
    int adminLogs = 0;
    int userLogs = 0;

    try (Connection conn = DBConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rsStats = stmt.executeQuery("SELECT user_role FROM audit_logs")) {
        while (rsStats.next()) {
            totalLogs++;
            String role = rsStats.getString("user_role");
            if ("ADMIN".equalsIgnoreCase(role)) {
                adminLogs++;
            } else {
                userLogs++;
            }
        }
    } catch (Exception e) {
        // Suppress if table empty or not created yet
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - System Security Audit Logs</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- DataTables & Buttons CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css">

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
        .stat-card-dark {
            border-left: 6px solid #212529;
            background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        }
        .stat-card-danger {
            border-left: 6px solid #dc3545;
            background: linear-gradient(135deg, #ffffff 0%, #fff5f5 100%);
        }
        .stat-card-primary {
            border-left: 6px solid #0d6efd;
            background: linear-gradient(135deg, #ffffff 0%, #f0f5ff 100%);
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

        /* Custom DataTables Styling */
        .dataTables_wrapper .dt-buttons .btn {
            border-radius: 8px !important;
            margin-right: 8px;
            font-weight: 600;
            box-shadow: 0 3px 8px rgba(0,0,0,0.12);
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
                <i class="fa-solid fa-clock-rotate-left text-dark me-2"></i>System Security & Audit Logs
            </h2>
            <p class="text-muted mb-0">Review full system security logs, user actions, IP addresses, and timestamps.</p>
        </div>
    </div>

    <!-- Stat Summary 3D Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card card-3d stat-card-dark p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Recorded Audit Events</span>
                        <h2 class="fw-bold text-dark mb-0"><%= totalLogs %></h2>
                    </div>
                    <div class="rounded-circle bg-dark bg-opacity-10 p-3">
                        <i class="fa-solid fa-shield-cat fs-1 text-dark"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card card-3d stat-card-danger p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Admin Level Actions</span>
                        <h2 class="fw-bold text-danger mb-0"><%= adminLogs %></h2>
                    </div>
                    <div class="rounded-circle bg-danger bg-opacity-10 p-3">
                        <i class="fa-solid fa-user-gear fs-1 text-danger"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card card-3d stat-card-primary p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">User System Activities</span>
                        <h2 class="fw-bold text-primary mb-0"><%= userLogs %></h2>
                    </div>
                    <div class="rounded-circle bg-primary bg-opacity-10 p-3">
                        <i class="fa-solid fa-users-gear fs-1 text-primary"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Data Table 3D Container -->
    <div class="card card-3d p-4">
        <div class="table-responsive table-container-3d">
            <table id="auditTable" class="table table-hover align-middle w-100 mb-0">
                <thead>
                    <tr>
                        <th class="py-3">Log ID</th>
                        <th class="py-3">User</th>
                        <th class="py-3">Role</th>
                        <th class="py-3">Action Performed</th>
                        <th class="py-3">IP Address</th>
                        <th class="py-3">Timestamp</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conn = DBConnection.getConnection();
                             Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery("SELECT * FROM audit_logs ORDER BY log_id DESC")) {

                            while (rs.next()) {
                                String role = rs.getString("user_role");
                                String action = rs.getString("action");
                    %>
                    <tr>
                        <td class="fw-bold text-dark">#LOG-<%= rs.getInt("log_id") %></td>
                        <td class="fw-bold text-dark">
                            <i class="fa-solid fa-user me-2 text-secondary"></i><%= rs.getString("username") %>
                        </td>
                        <td>
                            <span class="badge badge-3d <%= "ADMIN".equalsIgnoreCase(role) ? "bg-danger text-white" : "bg-primary text-white" %>">
                                <i class="fa-solid <%= "ADMIN".equalsIgnoreCase(role) ? "fa-shield-halved" : "fa-circle-user" %> me-1"></i><%= role %>
                            </span>
                        </td>
                        <td class="fw-semibold text-secondary"><%= action %></td>
                        <td>
                            <code class="bg-light text-dark px-2 py-1 rounded border">
                                <i class="fa-solid fa-network-wired me-1 text-muted"></i><%= rs.getString("ip_address") %>
                            </code>
                        </td>
                        <td>
                            <small class="text-muted fw-bold">
                                <i class="fa-regular fa-calendar-check me-1"></i><%= rs.getTimestamp("timestamp") %>
                            </small>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>

<script>
    $(document).ready(function() {
        $('#auditTable').DataTable({
            dom: '<"d-flex justify-content-between align-items-center mb-3"Bf>rt<"d-flex justify-content-between align-items-center mt-3"ip>',
            buttons: [
                {
                    extend: 'excelHtml5',
                    className: 'btn btn-sm btn-success btn-3d text-white',
                    text: '<i class="fa-solid fa-file-excel me-1"></i> Export Logs Excel'
                },
                {
                    extend: 'csvHtml5',
                    className: 'btn btn-sm btn-info btn-3d text-white',
                    text: '<i class="fa-solid fa-file-csv me-1"></i> Export CSV'
                }
            ],
            pageLength: 15,
            order: [[0, 'desc']],
            responsive: true,
            language: {
                emptyTable: "No security audit logs recorded yet.",
                search: "_INPUT_",
                searchPlaceholder: "Search logs..."
            }
        });
    });
</script>

</body>
</html>