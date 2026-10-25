<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Appointment" %>
<%@ page import="com.medicare.model.Doctor" %>
<%@ page import="com.medicare.model.Patient" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="java.util.List" %>
<%
    // Session Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Appointment app = (Appointment) request.getAttribute("appointment");
    if (app == null) {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idStr.trim());
                app = DAOFactory.getAppointmentDAO().getAppointmentById(id);
            } catch (Exception ignored) {}
        }
    }

    if (app == null) {
        response.sendRedirect("appointment?action=list&error=notfound");
        return;
    }

    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    if (patients == null) {
        patients = DAOFactory.getPatientDAO().getAllPatients();
    }

    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    if (doctors == null) {
        doctors = DAOFactory.getDoctorDAO().getAllDoctors();
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Appointment #<%= app.getAppointmentId() %> - Medicare</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f4f7f6;
        }
        .form-card {
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: none;
            overflow: hidden;
        }
        .form-header {
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
            color: white;
            padding: 24px 30px;
        }
        .input-group-text {
            background-color: #f8f9fa;
        }
        body.dark-mode {
            background-color: #121212 !important;
            color: #e0e0e0 !important;
        }
        body.dark-mode .card {
            background-color: #1e1e1e !important;
            color: #ffffff !important;
            border-color: #333333 !important;
        }
        body.dark-mode .input-group-text,
        body.dark-mode .form-control,
        body.dark-mode .form-select {
            background-color: #2b2b2b !important;
            color: #ffffff !important;
            border-color: #444444 !important;
        }
    </style>
    <script>
        window.onload = function() {
            if (localStorage.getItem('medicareDarkMode') === 'enabled') {
                document.body.classList.add('dark-mode');
            }
        }
    </script>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary px-4 shadow-sm">
    <a class="navbar-brand fw-bold" href="dashboard.jsp">
        <i class="fa-solid fa-hospital-user me-2"></i>Medicare System
    </a>
    <div class="ms-auto d-flex align-items-center gap-2">
        <a href="appointment?action=list" class="btn btn-outline-light btn-sm">
            <i class="fa-solid fa-arrow-left me-1"></i> Back to List
        </a>
        <a href="dashboard.jsp" class="btn btn-outline-light btn-sm">
            <i class="fa-solid fa-house me-1"></i> Dashboard
        </a>
    </div>
</nav>

<div class="container py-5" style="max-width: 760px;">
    <div class="card form-card">
        <div class="form-header d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-1 fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i>Edit Appointment #<%= app.getAppointmentId() %></h4>
                <p class="mb-0 text-white-50 small">Modify booking details, reschedule slot, or change status</p>
            </div>
            <span class="badge bg-light text-primary px-3 py-2 fw-semibold">
                Status: <%= app.getStatus() %>
            </span>
        </div>

        <div class="card-body p-4 p-md-5">

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger d-flex align-items-center border-0 shadow-sm rounded-3 mb-4" role="alert">
                    <i class="fa-solid fa-triangle-exclamation fs-4 me-3 text-danger"></i>
                    <div>
                        <strong>Unable to Update Appointment:</strong><br>
                        <%= errorMessage %>
                    </div>
                </div>
            <% } %>

            <form action="appointment" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="appointmentId" value="<%= app.getAppointmentId() %>">

                <!-- 1. Patient Selection -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-user me-1 text-primary"></i> Patient <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-hospital-user text-muted"></i></span>
                        <select name="patientId" class="form-select" required>
                            <% if (patients != null && !patients.isEmpty()) {
                                for (Patient p : patients) {
                                    String pidStr = String.valueOf(p.getId());
                                    boolean sel = pidStr.equals(app.getPatientId());
                            %>
                                <option value="<%= p.getId() %>" <%= sel ? "selected" : "" %>>
                                    #<%= p.getId() %> - <%= p.getName() %> (Age: <%= p.getAge() %>, Blood: <%= p.getBloodGroup() != null ? p.getBloodGroup() : "N/A" %>)
                                </option>
                            <%  }
                            } else { %>
                                <option value="<%= app.getPatientId() %>" selected>Patient #<%= app.getPatientId() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- 2. Doctor Selection -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-user-doctor me-1 text-primary"></i> Doctor <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-stethoscope text-muted"></i></span>
                        <select name="doctorId" class="form-select" required>
                            <% if (doctors != null && !doctors.isEmpty()) {
                                for (Doctor doc : doctors) {
                                    boolean sel = doc.getId().equalsIgnoreCase(app.getDoctorId());
                            %>
                                <option value="<%= doc.getId() %>" <%= sel ? "selected" : "" %>>
                                    <%= doc.getName() %> - <%= doc.getSpecialization() %> (Fee: LKR <%= doc.getConsultationFee() %>)
                                </option>
                            <%  }
                            } else { %>
                                <option value="<%= app.getDoctorId() %>" selected>Doctor #<%= app.getDoctorId() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- 3. Date & Time Row -->
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-secondary">
                            <i class="fa-solid fa-calendar-day me-1 text-primary"></i> Appointment Date <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-regular fa-calendar text-muted"></i></span>
                            <input type="date" name="appointmentDate" class="form-control"
                                   value="<%= app.getAppointmentDate() %>" required>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-secondary">
                            <i class="fa-solid fa-clock me-1 text-primary"></i> Appointment Time <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-regular fa-clock text-muted"></i></span>
                            <input type="time" name="appointmentTime" class="form-control"
                                   value="<%= app.getAppointmentTime() != null && app.getAppointmentTime().length() >= 5 ? app.getAppointmentTime().substring(0, 5) : "09:00" %>" required>
                        </div>
                    </div>
                </div>

                <!-- 4. Reason for Visit -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-notes-medical me-1 text-primary"></i> Reason / Symptoms <span class="text-danger">*</span>
                    </label>
                    <textarea name="reason" class="form-control" rows="3" required><%= app.getReason() != null ? app.getReason() : "" %></textarea>
                </div>

                <!-- 5. Appointment Status -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-signal me-1 text-primary"></i> Appointment Status <span class="text-danger">*</span>
                    </label>
                    <select name="status" class="form-select" required>
                        <option value="Booked" <%= "Booked".equalsIgnoreCase(app.getStatus()) ? "selected" : "" %>>Booked</option>
                        <option value="Completed" <%= "Completed".equalsIgnoreCase(app.getStatus()) ? "selected" : "" %>>Completed</option>
                        <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(app.getStatus()) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>

                <!-- Conflict Check Info -->
                <div class="p-3 bg-light rounded-3 mb-4 border d-flex align-items-center">
                    <i class="fa-solid fa-clock-rotate-left text-primary fs-4 me-3"></i>
                    <small class="text-muted">
                        Rescheduling this appointment will automatically verify the doctor's calendar for time slot collisions.
                    </small>
                </div>

                <!-- Action Buttons -->
                <div class="d-flex justify-content-between align-items-center pt-2">
                    <% if (!"Cancelled".equalsIgnoreCase(app.getStatus())) { %>
                        <a href="appointment?action=confirm-cancel&id=<%= app.getAppointmentId() %>" class="btn btn-outline-danger">
                            <i class="fa-solid fa-ban me-1"></i> Cancel Appointment
                        </a>
                    <% } else { %>
                        <div></div>
                    <% } %>

                    <div class="d-flex gap-2">
                        <a href="appointment?action=list" class="btn btn-outline-secondary px-4">Close</a>
                        <button type="submit" class="btn btn-primary px-4 fw-semibold">
                            <i class="fa-solid fa-floppy-disk me-2"></i> Save Changes
                        </button>
                    </div>
                </div>
            </form>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
