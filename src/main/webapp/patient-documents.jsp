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

    // Document Count Calculation
    int totalDocuments = 0;
    try (Connection conn = DBConnection.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rsCount = stmt.executeQuery("SELECT COUNT(*) FROM patient_documents")) {
        if (rsCount.next()) {
            totalDocuments = rsCount.getInt(1);
        }
    } catch (Exception e) {
        // Suppress if table doesn't exist yet
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Lab Reports & Documents</title>

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

        .stat-card-doc {
            border-left: 6px solid #0d6efd;
            background: linear-gradient(135deg, #ffffff 0%, #f0f5ff 100%);
        }

        .btn-3d {
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
            transition: all 0.2s ease;
        }
        .btn-3d:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.2);
        }

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

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1 text-dark">
                <i class="fa-solid fa-file-medical text-primary me-2"></i>Patient Documents & Lab Reports
            </h2>
            <p class="text-muted mb-0">Upload and access patient X-rays, lab test reports, and clinical documents.</p>
        </div>
    </div>

    <!-- Stat Summary 3D Card -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d stat-card-doc p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Documents Uploaded</span>
                        <h2 class="fw-bold text-primary mb-0"><%= totalDocuments %></h2>
                    </div>
                    <div class="rounded-circle bg-primary bg-opacity-10 p-3">
                        <i class="fa-solid fa-folder-open fs-1 text-primary"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Upload Form -->
        <div class="col-lg-5">
            <div class="card card-3d p-4">
                <h5 class="fw-bold text-primary mb-3">
                    <i class="fa-solid fa-cloud-arrow-up me-2"></i>Upload Lab Report / Scan
                </h5>
                <hr class="mt-0 mb-3">
                <form action="upload-document" method="post" enctype="multipart/form-data">
                    <div class="mb-3">
                        <label class="form-label fw-semibold text-dark">Patient ID</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fa-solid fa-id-badge text-muted"></i></span>
                            <input type="text" name="patientId" class="form-control" placeholder="e.g. 1 or P001" required>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold text-dark">Select Document (PDF / Image)</label>
                        <input type="file" name="file" class="form-control" required>
                        <small class="text-muted mt-1 d-block"><i class="fa-solid fa-circle-info me-1"></i> Supported formats: PDF, PNG, JPG, JPEG</small>
                    </div>
                    <button type="submit" class="btn btn-primary btn-3d w-100 fw-bold py-2">
                        <i class="fa-solid fa-upload me-1"></i> Upload Document
                    </button>
                </form>
            </div>
        </div>

        <!-- Uploaded Files List -->
        <div class="col-lg-7">
            <div class="card card-3d p-4">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="fw-bold text-dark mb-0">
                        <i class="fa-solid fa-folder-tree text-dark me-2"></i>Uploaded Documents Directory
                    </h5>
                </div>

                <!-- Instant Search Bar -->
                <div class="mb-3">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                        <input type="text" id="docSearchInput" class="form-control border-start-0"
                               placeholder="Search by Patient ID or File Name..." onkeyup="filterDocuments()">
                    </div>
                </div>

                <div class="table-responsive table-container-3d">
                    <table class="table table-hover align-middle mb-0" id="docTable">
                        <thead>
                            <tr>
                                <th class="py-3">Patient ID</th>
                                <th class="py-3">File Name</th>
                                <th class="py-3">Uploaded Date</th>
                                <th class="text-center py-3">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection();
                                     Statement stmt = conn.createStatement();
                                     ResultSet rs = stmt.executeQuery("SELECT * FROM patient_documents ORDER BY document_id DESC")) {
                                    boolean hasData = false;
                                    while (rs.next()) {
                                        hasData = true;
                                        String fileName = rs.getString("file_name");
                            %>
                            <tr>
                                <td>
                                    <span class="badge badge-3d bg-primary text-white">
                                        <i class="fa-solid fa-user me-1"></i><%= rs.getString("patient_id") %>
                                    </span>
                                </td>
                                <td>
                                    <div class="fw-semibold text-dark">
                                        <i class="fa-solid fa-file-lines text-secondary me-2"></i><%= fileName %>
                                    </div>
                                </td>
                                <td>
                                    <small class="text-muted fw-bold">
                                        <i class="fa-regular fa-clock me-1"></i><%= rs.getTimestamp("uploaded_at") %>
                                    </small>
                                </td>
                                <td class="text-center">
                                    <a href="view-document?file=<%= fileName %>" target="_blank"
                                       class="btn btn-sm btn-outline-primary btn-3d" title="View Document">
                                        <i class="fa-solid fa-eye me-1"></i> View
                                    </a>
                                </td>
                            </tr>
                            <%      }
                                    if (!hasData) {
                            %>
                            <tr id="noDataRow">
                                <td colspan="4" class="text-center text-muted py-4">
                                    <i class="fa-solid fa-folder-open fs-3 d-block mb-2"></i> No documents uploaded yet.
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
    function filterDocuments() {
        const input = document.getElementById('docSearchInput').value.toLowerCase();
        const table = document.getElementById('docTable');
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