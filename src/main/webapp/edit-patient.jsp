<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Patient" %>

<%
    // Admin Security Check (Admin නොවේ නම් පිටතට යැවීම)
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }

    Patient patient = (Patient) request.getAttribute("patient");
    if (patient == null) {
        response.sendRedirect("patient-list.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Patient - Medicare</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">

    <div class="container mt-5" style="max-width: 600px;">
        <div class="card shadow">
            <div class="card-header bg-warning text-dark">
                <h4 class="mb-0">Edit Patient Details</h4>
            </div>
            <div class="card-body">
                <form action="edit-patient" method="post">
                    <!-- Hidden Patient ID -->
                    <input type="hidden" name="id" value="<%= patient.getId() %>">

                    <div class="mb-3">
                        <label class="form-label">Patient Name</label>
                        <input type="text" name="name" class="form-control" value="<%= patient.getName() %>" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Age</label>
                        <input type="number" name="age" class="form-control" value="<%= patient.getAge() %>" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Gender</label>
                        <select name="gender" class="form-select" required>
                            <option value="Male" <%= "Male".equalsIgnoreCase(patient.getGender()) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= "Female".equalsIgnoreCase(patient.getGender()) ? "selected" : "" %>>Female</option>
                            <option value="Other" <%= "Other".equalsIgnoreCase(patient.getGender()) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Contact Number</label>
                        <input type="text" name="contact" class="form-control" value="<%= patient.getContact() %>" required>
                    </div>

                    <div class="d-flex justify-content-between">
                        <a href="patient-list.jsp" class="btn btn-secondary">Cancel</a>
                        <button type="submit" class="btn btn-primary">Update Patient</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</body>
</html>