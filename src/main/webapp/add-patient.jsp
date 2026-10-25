<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.medicare.model.User" %>

<%
    // 1. Session & Role Check (ADMIN ට පමණක් Patient ඇතුළත් කළ හැක)
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Patient - Medicare</title>
    <!-- Bootstrap 5 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-light">

    <div class="container mt-5 mb-5" style="max-width: 700px;">
        <div class="card shadow-sm border-0">
            <div class="card-header bg-success text-white py-3">
                <h4 class="mb-0"><i class="fa-solid fa-user-plus me-2"></i>Add New Patient</h4>
            </div>
            <div class="card-body p-4">
                <form action="add-patient" method="post">

                    <div class="row g-3">
                        <!-- Patient Name -->
                        <div class="col-md-12">
                            <label class="form-label fw-bold">Patient Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" placeholder="Enter full name" required>
                        </div>

                        <!-- Email (Optional - required Attribute එක ඉවත් කර ඇත) -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Email <span class="text-muted fw-normal">(Optional)</span></label>
                            <input type="email" name="email" class="form-control" placeholder="example@gmail.com">
                        </div>

                        <!-- Age -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Age <span class="text-danger">*</span></label>
                            <input type="number" name="age" class="form-control" min="0" max="120" placeholder="Age" required>
                        </div>

                        <!-- Gender -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Gender <span class="text-danger">*</span></label>
                            <select name="gender" class="form-select" required>
                                <option value="" selected disabled>Select</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>

                        <!-- Contact / Phone Number -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Contact / Phone <span class="text-danger">*</span></label>
                            <input type="text" name="phone" class="form-control" placeholder="07XXXXXXXX" required>
                        </div>

                        <!-- Blood Group -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Blood Group <span class="text-muted fw-normal">(Optional)</span></label>
                            <select name="blood_group" class="form-select">
                                <option value="">Select Blood Group</option>
                                <option value="A+">A+</option>
                                <option value="A-">A-</option>
                                <option value="B+">B+</option>
                                <option value="B-">B-</option>
                                <option value="AB+">AB+</option>
                                <option value="AB-">AB-</option>
                                <option value="O+">O+</option>
                                <option value="O-">O-</option>
                            </select>
                        </div>

                        <!-- Address -->
                        <div class="col-md-12">
                            <label class="form-label fw-bold">Address <span class="text-muted fw-normal">(Optional)</span></label>
                            <input type="text" name="address" class="form-control" placeholder="Enter residential address">
                        </div>

                        <!-- Allergies -->
                        <div class="col-md-12">
                            <label class="form-label fw-bold">Allergies <span class="text-muted fw-normal">(Optional)</span></label>
                            <input type="text" name="allergies" class="form-control" placeholder="e.g., Penicillin, Dust, Nuts">
                        </div>

                        <!-- Medical History -->
                        <div class="col-md-12">
                            <label class="form-label fw-bold">Medical History <span class="text-muted fw-normal">(Optional)</span></label>
                            <textarea name="medical_history" class="form-control" rows="3" placeholder="Enter any previous conditions or surgical history"></textarea>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="d-flex justify-content-between align-items-center mt-4 pt-2 border-top">
                        <a href="patient-list.jsp" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-arrow-left me-1"></i> Cancel
                        </a>
                        <button type="submit" class="btn btn-success px-4">
                            <i class="fa-solid fa-floppy-disk me-1"></i> Save Patient
                        </button>
                    </div>

                </form>
            </div>
        </div>
    </div>

</body>
</html>