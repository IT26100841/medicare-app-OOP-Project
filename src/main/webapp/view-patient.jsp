<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.Patient" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Patient Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <% Patient p = (Patient) request.getAttribute("patient"); if (p != null) { %>
    <div class="card shadow">
        <div class="card-header bg-info text-white">
            <h4>Patient Details (ID: <%= p.getId() %>)</h4>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-6"><strong>Full Name:</strong> <%= p.getName() %></div>
                <div class="col-md-6"><strong>Email:</strong> <%= p.getEmail() %></div>
            </div>
            <div class="row mb-3">
                <div class="col-md-4"><strong>Age:</strong> <%= p.getAge() %></div>
                <div class="col-md-4"><strong>Gender:</strong> <%= p.getGender() %></div>
                <div class="col-md-4"><strong>Phone:</strong> <%= p.getPhone() %></div>
            </div>
            <div class="row mb-3">
                <div class="col-md-8"><strong>Address:</strong> <%= p.getAddress() %></div>
                <div class="col-md-4"><strong>Blood Group:</strong> <%= p.getBloodGroup() %></div>
            </div>
            <div class="mb-3">
                <strong>Allergies:</strong> <%= p.getAllergies() %>
            </div>
            <div class="mb-3">
                <strong>Medical History:</strong> <%= p.getMedicalHistory() %>
            </div>
            <a href="patient?action=list" class="btn btn-secondary">Back to List</a>
            <a href="patient?action=edit&id=<%= p.getId() %>" class="btn btn-warning">Edit Details</a>
        </div>
    </div>
    <% } else { %>
        <p class="text-danger">Patient not found.</p>
    <% } %>
</div>
</body>
</html>