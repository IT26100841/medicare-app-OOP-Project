<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.util.DBConnection, java.sql.*" %>
<%@ page import="com.medicare.model.User" %>
<%
    // 1. Session Check & Security
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Dynamic Claims Statistics Computation
    int totalClaims = 0;
    int pendingClaims = 0;
    double totalApprovedAmount = 0.0;

    try (Connection conn = DBConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rsStats = stmt.executeQuery("SELECT status, claim_amount FROM insurance_claims")) {
        while (rsStats.next()) {
            totalClaims++;
            String st = rsStats.getString("status");
            if ("Pending".equalsIgnoreCase(st)) {
                pendingClaims++;
            } else if ("Approved".equalsIgnoreCase(st)) {
                totalApprovedAmount += rsStats.getDouble("claim_amount");
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
    <title>Medicare - Insurance Claims Management</title>

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
        .stat-card-success {
            border-left: 6px solid #198754;
            background: linear-gradient(135deg, #ffffff 0%, #f0fff4 100%);
        }
        .stat-card-warning {
            border-left: 6px solid #ffc107;
            background: linear-gradient(135deg, #ffffff 0%, #fffdf0 100%);
        }
        .stat-card-info {
            border-left: 6px solid #0dcaf0;
            background: linear-gradient(135deg, #ffffff 0%, #eefcff 100%);
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
                <i class="fa-solid fa-shield-halved text-success me-2"></i>Insurance Claims Management
            </h2>
            <p class="text-muted mb-0">Submit patient policy claim details and track approval status.</p>
        </div>
    </div>

    <!-- Stat Summary 3D Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card card-3d stat-card-info p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Claim Requests</span>
                        <h2 class="fw-bold text-info mb-0"><%= totalClaims %></h2>
                    </div>
                    <div class="rounded-circle bg-info bg-opacity-10 p-3">
                        <i class="fa-solid fa-file-invoice-dollar fs-1 text-info"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card card-3d stat-card-warning p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Pending Reviews</span>
                        <h2 class="fw-bold text-warning mb-0"><%= pendingClaims %></h2>
                    </div>
                    <div class="rounded-circle bg-warning bg-opacity-10 p-3">
                        <i class="fa-solid fa-hourglass-half fs-1 text-warning"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card card-3d stat-card-success p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Approved Claims Value</span>
                        <h2 class="fw-bold text-success mb-0">$<%= String.format("%.2f", totalApprovedAmount) %></h2>
                    </div>
                    <div class="rounded-circle bg-success bg-opacity-10 p-3">
                        <i class="fa-solid fa-circle-check fs-1 text-success"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Submit New Claim 3D Form Card -->
        <div class="col-lg-4">
            <div class="card card-3d p-4">
                <h5 class="fw-bold text-success mb-3">
                    <i class="fa-solid fa-file-signature me-2"></i>Submit New Claim
                </h5>
                <hr class="mt-0 mb-3">
                <form action="insurance-claim" method="post">
                    <input type="hidden" name="action" value="create">

                    <div class="mb-3">
                        <label class="form-label fw-semibold text-dark">Patient ID</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fa-solid fa-user me-1 text-muted"></i></span>
                            <input type="text" name="patientId" class="form-control" placeholder="e.g. 1 or P001" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold text-dark">Provider Name</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fa-solid fa-building-columns me-1 text-muted"></i></span>
                            <input type="text" name="providerName" class="form-control" placeholder="e.g. Ceylinco Insurance" required>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold text-dark">Policy Number</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fa-solid fa-hashtag me-1 text-muted"></i></span>
                            <input type="text" name="policyNumber" class="form-control" placeholder="POL-12345" required>
                        </div>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold text-dark">Claim Amount ($)</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light fw-bold text-success">$</span>
                            <input type="number" step="0.01" name="claimAmount" class="form-control" placeholder="500.00" required>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-success btn-3d w-100 fw-bold py-2">
                        <i class="fa-solid fa-paper-plane me-1"></i> Submit Claim
                    </button>
                </form>
            </div>
        </div>

        <!-- Claim Requests Directory 3D Container -->
        <div class="col-lg-8">
            <div class="card card-3d p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0">
                        <i class="fa-solid fa-list-check text-dark me-2"></i>Claim Requests Directory
                    </h5>
                </div>

                <!-- Instant Search Filter -->
                <div class="mb-3">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                        <input type="text" id="claimSearchInput" class="form-control border-start-0"
                               placeholder="Search by Patient, Provider, Policy No, or Status..." onkeyup="filterClaims()">
                    </div>
                </div>

                <div class="table-responsive table-container-3d">
                    <table class="table table-hover align-middle mb-0" id="claimsTable">
                        <thead>
                            <tr>
                                <th class="py-3">Claim ID</th>
                                <th class="py-3">Patient ID</th>
                                <th class="py-3">Provider & Policy</th>
                                <th class="py-3">Amount</th>
                                <th class="py-3">Status</th>
                                <th class="text-center py-3">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection();
                                     Statement stmt = conn.createStatement();
                                     ResultSet rs = stmt.executeQuery("SELECT * FROM insurance_claims ORDER BY claim_id DESC")) {
                                    boolean hasData = false;
                                    while (rs.next()) {
                                        hasData = true;
                                        String status = rs.getString("status");
                            %>
                            <tr>
                                <td class="fw-bold text-dark">#<%= rs.getInt("claim_id") %></td>
                                <td>
                                    <span class="badge badge-3d bg-primary text-white">
                                        <i class="fa-solid fa-user me-1"></i><%= rs.getString("patient_id") %>
                                    </span>
                                </td>
                                <td>
                                    <div class="fw-bold text-dark"><%= rs.getString("provider_name") %></div>
                                    <small class="text-muted"><i class="fa-solid fa-file-contract me-1"></i><%= rs.getString("policy_number") %></small>
                                </td>
                                <td class="fw-bold text-success fs-6">
                                    $<%= String.format("%.2f", rs.getDouble("claim_amount")) %>
                                </td>
                                <td>
                                    <% if ("Approved".equalsIgnoreCase(status)) { %>
                                        <span class="badge badge-3d bg-success text-white">
                                            <i class="fa-solid fa-circle-check me-1"></i>Approved
                                        </span>
                                    <% } else if ("Rejected".equalsIgnoreCase(status)) { %>
                                        <span class="badge badge-3d bg-danger text-white">
                                            <i class="fa-solid fa-circle-xmark me-1"></i>Rejected
                                        </span>
                                    <% } else { %>
                                        <span class="badge badge-3d bg-warning text-dark">
                                            <i class="fa-solid fa-clock me-1"></i>Pending
                                        </span>
                                    <% } %>
                                </td>
                                <td class="text-center">
                                    <% if ("Pending".equalsIgnoreCase(status)) { %>
                                        <form action="insurance-claim" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="claimId" value="<%= rs.getInt("claim_id") %>">
                                            <input type="hidden" name="status" value="Approved">
                                            <button type="submit" class="btn btn-sm btn-outline-success btn-3d me-1" title="Approve Claim">
                                                <i class="fa-solid fa-check"></i>
                                            </button>
                                        </form>
                                        <form action="insurance-claim" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="claimId" value="<%= rs.getInt("claim_id") %>">
                                            <input type="hidden" name="status" value="Rejected">
                                            <button type="submit" class="btn btn-sm btn-outline-danger btn-3d" title="Reject Claim">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <span class="text-muted small fw-semibold">
                                            <i class="fa-solid fa-lock me-1"></i>Completed
                                        </span>
                                    <% } %>
                                </td>
                            </tr>
                            <%      }
                                    if (!hasData) {
                            %>
                            <tr id="noDataRow">
                                <td colspan="6" class="text-center text-muted py-4">
                                    <i class="fa-solid fa-folder-open fs-3 d-block mb-2"></i> No insurance claims submitted.
                                </td>
                            </tr>
                            <%      }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Real-time Search Filter for Insurance Claims Table
    function filterClaims() {
        const input = document.getElementById('claimSearchInput').value.toLowerCase();
        const table = document.getElementById('claimsTable');
        const trs = table.getElementsByTagName('tr');

        for (let i = 1; i < trs.length; i++) {
            if (trs[i].id === 'noDataRow') continue;
            const tdText = trs[i].innerText.toLowerCase();
            if (tdText.includes(input)) {
                trs[i].style.display = '';
            } else {
                trs[i].style.display = 'none';
            }
        }
    }
</script>
</body>
</html>