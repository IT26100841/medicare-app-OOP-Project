<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Doctor" %>
<%@ page import="com.medicare.dao.DoctorDAO" %>
<%@ page import="com.medicare.factory.DAOFactory" %>

<%
    // 1. Session Check (Login වී නැත්නම් Login පිටුවට)
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isAdmin = "ADMIN".equalsIgnoreCase(currentUser.getRole());

    // 2. Doctor Data Load කරගැනීම (Servlet එකෙන් හෝ URL Parameter එකෙන්)
    Doctor doc = (Doctor) request.getAttribute("doctor");
    if (doc == null) {
        String doctorId = request.getParameter("id");
        if (doctorId != null && !doctorId.trim().isEmpty()) {
            DoctorDAO doctorDAO = DAOFactory.getDoctorDAO();
            doc = doctorDAO.getDoctorById(doctorId);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Doctor Profile - Medicare System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header bg-info text-white">
                    <h4 class="mb-0">Doctor Profile</h4>
                </div>
                <div class="card-body">
                    <% if (doc != null) { %>
                        <ul class="list-group list-group-flush mb-3">
                            <li class="list-group-item"><strong>ID:</strong> <%= doc.getId() %></li>
                            <li class="list-group-item"><strong>Name:</strong> <%= doc.getName() %></li>
                            <li class="list-group-item"><strong>Specialization:</strong> <%= doc.getSpecialization() %></li>
                            <li class="list-group-item"><strong>Phone:</strong> <%= doc.getPhone() %></li>
                            <li class="list-group-item">
                                <strong>Consultation Fee:</strong> LKR <%= String.format("%.2f", doc.getConsultationFee()) %>
                            </li>
                        </ul>
                    <% } else { %>
                        <p class="text-danger fw-bold">Doctor details not found.</p>
                    <% } %>

                    <div class="d-flex justify-content-between mt-3">
                        <a href="list-doctors.jsp" class="btn btn-secondary">Back to List</a>

                        <!-- Edit Profile Button එක පෙනෙන්නේ ADMIN ට පමණි -->
                        <% if (doc != null && isAdmin) { %>
                            <a href="edit-doctor?id=<%= doc.getId() %>" class="btn btn-warning">Edit Profile</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>