<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="com.medicare.model.MedicalRecord" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="java.util.List" %>
<%
    // 1. Session Check & Security
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isAdmin = "ADMIN".equalsIgnoreCase(currentUser.getRole());

    // 2. Fetch Medical Records
    List<MedicalRecord> list = null;
    try {
        if (DAOFactory.getMedicalRecordDAO() != null) {
            list = DAOFactory.getMedicalRecordDAO().getAllMedicalRecords();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    int totalRecords = (list != null) ? list.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Medical Records History</title>

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
        .stat-card-info {
            border-left: 6px solid #0dcaf0;
            background: linear-gradient(135deg, #ffffff 0%, #eefcff 100%);
        }
        .stat-card-records {
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
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
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
                <i class="fa-solid fa-notes-medical text-info me-2"></i>Medical Records History
            </h2>
            <p class="text-muted mb-0">Record clinical diagnoses, view doctor prescriptions, and export records.</p>
        </div>
        <div>
            <a href="add-medical-record.jsp" class="btn btn-success btn-3d fw-bold px-3">
                <i class="fa-solid fa-plus me-1"></i> Add New Record
            </a>
        </div>
    </div>

    <!-- Stat Summary 3D Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d stat-card-info p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Total Medical Records</span>
                        <h2 class="fw-bold text-info mb-0"><%= totalRecords %></h2>
                    </div>
                    <div class="rounded-circle bg-info bg-opacity-10 p-3">
                        <i class="fa-solid fa-file-medical fs-1 text-info"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-4">
            <div class="card card-3d stat-card-records p-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted small fw-bold">Prescription Documents</span>
                        <h2 class="fw-bold text-primary mb-0"><%= totalRecords %></h2>
                    </div>
                    <div class="rounded-circle bg-primary bg-opacity-10 p-3">
                        <i class="fa-solid fa-file-pdf fs-1 text-primary"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Data Table 3D Container -->
    <div class="card card-3d p-4">
        <div class="table-responsive table-container-3d">
            <table id="medicalRecordTable" class="table table-hover align-middle w-100 mb-0">
                <thead>
                    <tr>
                        <th class="py-3">Record ID</th>
                        <th class="py-3">Patient ID</th>
                        <th class="py-3">Doctor ID</th>
                        <th class="py-3">Diagnosis</th>
                        <th class="py-3">Prescription</th>
                        <th class="py-3">Record Date</th>
                        <th class="text-center py-3">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (list != null && !list.isEmpty()) { %>
                        <% for (MedicalRecord r : list) { %>
                        <tr>
                            <td class="fw-bold text-dark">#<%= r.getRecordId() %></td>
                            <td>
                                <span class="badge badge-3d bg-primary text-white">
                                    <i class="fa-solid fa-user me-1"></i>ID: <%= r.getPatientId() %>
                                </span>
                            </td>
                            <td>
                                <span class="badge badge-3d bg-success text-white">
                                    <i class="fa-solid fa-user-md me-1"></i>ID: <%= r.getDoctorId() %>
                                </span>
                            </td>
                            <td class="fw-semibold text-dark"><%= r.getDiagnosis() %></td>
                            <td class="text-secondary"><%= r.getPrescription() %></td>
                            <td>
                                <small class="text-muted fw-bold">
                                    <i class="fa-regular fa-calendar-days me-1"></i><%= r.getRecordDate() %>
                                </small>
                            </td>
                            <td class="text-center">
                                <a href="download-prescription?id=<%= r.getRecordId() %>" target="_blank"
                                   class="btn btn-sm btn-outline-primary btn-3d me-1" title="Download PDF">
                                    <i class="fa-solid fa-print me-1"></i> PDF
                                </a>
                                <a href="medical-record?action=delete&id=<%= r.getRecordId() %>"
                                   class="btn btn-sm btn-outline-danger btn-3d"
                                   onclick="return confirm('Are you sure you want to delete this record?')" title="Delete Record">
                                    <i class="fa-solid fa-trash me-1"></i> Delete
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- jQuery & DataTables JS -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>

<script>
    $(document).ready(function() {
        $('#medicalRecordTable').DataTable({
            dom: '<"d-flex justify-content-between align-items-center mb-3"Bf>rt<"d-flex justify-content-between align-items-center mt-3"ip>',
            buttons: [
                {
                    extend: 'excelHtml5',
                    className: 'btn btn-sm btn-success btn-3d text-white',
                    text: '<i class="fa-solid fa-file-excel me-1"></i> Export to Excel'
                },
                {
                    extend: 'csvHtml5',
                    className: 'btn btn-sm btn-info btn-3d text-white',
                    text: '<i class="fa-solid fa-file-csv me-1"></i> Export to CSV'
                }
            ],
            pageLength: 10,
            responsive: true,
            language: {
                search: "_INPUT_",
                searchPlaceholder: "Search records..."
            }
        });
    });
</script>

</body>
</html>