<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Create Bill</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
    <h2>Create New Bill</h2>
    <form action="bill" method="post" class="mt-3" style="max-width: 500px;">
        <div class="mb-3">
            <label>Appointment ID</label>
            <input type="number" name="appointmentId" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Patient ID</label>
            <input type="text" name="patientId" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Amount ($)</label>
            <input type="number" step="0.01" name="amount" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Payment Method</label>
            <select name="paymentMethod" class="form-select">
                <option value="Cash">Cash</option>
                <option value="Card">Card</option>
            </select>
        </div>
        <div class="mb-3">
            <label>Payment Status</label>
            <select name="paymentStatus" class="form-select">
                <option value="Unpaid">Unpaid</option>
                <option value="Paid">Paid</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Generate Bill</button>
        <a href="bill-list.jsp" class="btn btn-secondary">Cancel</a>
    </form>
</body>
</html>