<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Medical Record</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h2>Add New Medical Record</h2>
    <form action="medical-record" method="post" class="mt-3" style="max-width: 600px;">
        <div class="mb-3">
            <label>Patient ID</label>
            <input type="text" name="patientId" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Doctor ID</label>
            <input type="text" name="doctorId" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Appointment ID</label>
            <input type="number" name="appointmentId" class="form-control" value="0">
        </div>
        <div class="mb-3">
            <label>Diagnosis</label>
            <textarea name="diagnosis" class="form-control" required></textarea>
        </div>
        <div class="mb-3">
            <label>Prescription</label>
            <textarea name="prescription" class="form-control" required></textarea>
        </div>
        <div class="mb-3">
            <label>Notes</label>
            <textarea name="notes" class="form-control"></textarea>
        </div>
        <div class="mb-3">
            <label>Record Date</label>
            <input type="date" name="recordDate" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary">Save Medical Record</button>
        <a href="medical-record-list.jsp" class="btn btn-secondary">Cancel</a>
    </form>
</body>
</html>