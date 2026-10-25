<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.model.User" %>
<%@ page import="com.medicare.model.Doctor" %>
<%@ page import="com.medicare.model.Patient" %>
<%@ page import="com.medicare.factory.DAOFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%
    // Session Security Check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fallback load if accessed directly
    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    if (patients == null) {
        patients = DAOFactory.getPatientDAO().getAllPatients();
    }

    List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");
    if (doctors == null) {
        doctors = DAOFactory.getDoctorDAO().getAllDoctors();
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String prePatientId = (String) request.getAttribute("prePatientId");
    String preDoctorId = (String) request.getAttribute("preDoctorId");
    String preDate = (String) request.getAttribute("preDate");
    String preTime = (String) request.getAttribute("preTime");
    String preReason = (String) request.getAttribute("preReason");
    String preStatus = (String) request.getAttribute("preStatus");

    String todayStr = LocalDate.now().toString();
    if (preDate == null || preDate.isEmpty()) {
        preDate = todayStr;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Appointment - Medicare</title>
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
            background: linear-gradient(135deg, #0d6efd 0%, #0b5ed7 100%);
            color: white;
            padding: 24px 30px;
        }
        .input-group-text {
            background-color: #f8f9fa;
            border-right: none;
        }
        .form-control:focus, .form-select:focus {
            box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.15);
            border-color: #86b7fe;
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
            <i class="fa-solid fa-calendar-check me-1"></i> Appointment List
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
                <h4 class="mb-1 fw-bold"><i class="fa-solid fa-calendar-plus me-2"></i>Book New Appointment</h4>
                <p class="mb-0 text-white-50 small">Schedule a consultation with an active doctor</p>
            </div>
            <a href="appointment?action=list" class="btn btn-sm btn-light text-primary fw-semibold">
                <i class="fa-solid fa-arrow-left me-1"></i> Back to List
            </a>
        </div>

        <div class="card-body p-4 p-md-5">

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger d-flex align-items-center border-0 shadow-sm rounded-3 mb-4" role="alert">
                    <i class="fa-solid fa-triangle-exclamation fs-4 me-3 text-danger"></i>
                    <div>
                        <strong>Unable to Book Appointment:</strong><br>
                        <%= errorMessage %>
                    </div>
                </div>
            <% } %>

            <form action="appointment" method="POST" id="appointmentForm">
                <input type="hidden" name="action" value="insert">

                <!-- 1. Patient Selection -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-user me-1 text-primary"></i> Patient <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-hospital-user text-muted"></i></span>
                        <select name="patientId" class="form-select" required>
                            <option value="">-- Choose Patient --</option>
                            <% if (patients != null && !patients.isEmpty()) {
                                for (Patient p : patients) {
                                    String pidStr = String.valueOf(p.getId());
                                    boolean sel = pidStr.equals(prePatientId);
                            %>
                                <option value="<%= p.getId() %>" <%= sel ? "selected" : "" %>>
                                    #<%= p.getId() %> - <%= p.getName() %> (Age: <%= p.getAge() %>, Blood: <%= p.getBloodGroup() != null ? p.getBloodGroup() : "N/A" %>)
                                </option>
                            <%  }
                            } %>
                        </select>
                    </div>
                    <div class="form-text">If the patient is new, please <a href="add-patient.jsp" target="_blank">register them first</a>.</div>
                </div>

                <!-- 2. Doctor Selection -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-user-doctor me-1 text-primary"></i> Doctor <span class="text-danger">*</span>
                    </label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fa-solid fa-stethoscope text-muted"></i></span>
                        <select name="doctorId" class="form-select" required id="doctorSelect">
                            <option value="">-- Choose Doctor --</option>
                            <% if (doctors != null && !doctors.isEmpty()) {
                                for (Doctor doc : doctors) {
                                    boolean sel = doc.getId().equalsIgnoreCase(preDoctorId);
                            %>
                                <option value="<%= doc.getId() %>" <%= sel ? "selected" : "" %>>
                                    <%= doc.getName() %> - <%= doc.getSpecialization() %> (Fee: LKR <%= doc.getConsultationFee() %>)
                                </option>
                            <%  }
                            } %>
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
                                   min="<%= todayStr %>"
                                   value="<%= preDate %>" required>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-secondary">
                            <i class="fa-solid fa-clock me-1 text-primary"></i> Appointment Time <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fa-regular fa-clock text-muted"></i></span>
                            <input type="time" name="appointmentTime" class="form-control"
                                   value="<%= (preTime != null && !preTime.isEmpty()) ? preTime : "09:00" %>" required>
                        </div>
                        <div class="form-text">Operating hours: 08:00 AM - 08:00 PM</div>
                    </div>
                </div>

                <!-- 4. Reason for Visit -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-notes-medical me-1 text-primary"></i> Consultation Reason / Symptoms <span class="text-danger">*</span>
                    </label>
                    <textarea name="reason" class="form-control" rows="3"
                              placeholder="e.g. Regular monthly checkup, severe migraine, cardiac consultation..." required><%= preReason != null ? preReason : "" %></textarea>
                </div>

                <!-- 5. Appointment Status -->
                <div class="mb-4">
                    <label class="form-label fw-semibold text-secondary">
                        <i class="fa-solid fa-signal me-1 text-primary"></i> Initial Status
                    </label>
                    <select name="status" class="form-select">
                        <option value="Booked" <%= ("Booked".equalsIgnoreCase(preStatus) || preStatus == null) ? "selected" : "" %>>Booked</option>
                        <option value="Completed" <%= "Completed".equalsIgnoreCase(preStatus) ? "selected" : "" %>>Completed</option>
                        <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(preStatus) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>

                <!-- Conflict Check Notice -->
                <div class="p-3 bg-light rounded-3 mb-4 border d-flex align-items-center">
                    <i class="fa-solid fa-shield-halved text-primary fs-4 me-3"></i>
                    <small class="text-muted">
                        <strong>Automated Conflict Guard:</strong> The system automatically verifies that the chosen doctor does not already hold another active booking at the selected date and time.
                    </small>
                </div>

                <!-- Action Buttons -->
                <div class="d-flex justify-content-end gap-2 pt-2">
                    <a href="appointment?action=list" class="btn btn-outline-secondary px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4 fw-semibold">
                        <i class="fa-solid fa-check me-2"></i> Confirm & Book Appointment
                    </button>
                </div>
            </form>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
