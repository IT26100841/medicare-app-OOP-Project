<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.Doctor" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Doctor - Medicare System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<%
    Doctor doc = (Doctor) request.getAttribute("doctor");
%>
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="card shadow-sm">
                <div class="card-header bg-warning text-dark">
                    <h4 class="mb-0">Edit Doctor Profile</h4>
                </div>
                <div class="card-body">
                    <% if (doc != null) { %>
                    <form action="doctor?action=update" method="post">
                        <div class="mb-3">
                            <label class="form-label">Doctor ID (Cannot be changed)</label>
                            <input type="text" name="id" class="form-control" value="<%= doc.getId() %>" readonly>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" class="form-control" value="<%= doc.getName() %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Specialization</label>
                            <input type="text" name="specialization" class="form-control" value="<%= doc.getSpecialization() %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Qualification</label>
                            <input type="text" name="qualification" class="form-control" value="<%= doc.getQualification() %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Phone</label>
                            <input type="text" name="phone" class="form-control" value="<%= doc.getPhone() %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" value="<%= doc.getEmail() %>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Consultation Fee (LKR)</label>
                            <input type="number" step="0.01" name="consultationFee" class="form-control" value="<%= doc.getConsultationFee() %>" required>
                        </div>
                        <div class="d-flex justify-content-between">
                            <a href="doctor?action=list" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-warning">Update Doctor</button>
                        </div>
                    </form>
                    <% } else { %>
                        <p class="text-danger">Doctor details not found.</p>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>