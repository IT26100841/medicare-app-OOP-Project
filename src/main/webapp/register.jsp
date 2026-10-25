<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Patient - Medicare System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h4>Add New Patient</h4>
        </div>
        <div class="card-body">
            <form action="patient" method="post">
                <input type="hidden" name="action" value="add">

                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label">Age</label>
                        <input type="number" name="age" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Gender</label>
                        <select name="gender" class="form-select" required>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Phone Number</label>
                        <input type="text" name="phone" class="form-control" required>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-md-8">
                        <label class="form-label">Address</label>
                        <input type="text" name="address" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Blood Group</label>
                        <select name="bloodGroup" class="form-select">
                            <option value="A+">A+</option>
                            <option value="A-">A-</option>
                            <option value="B+">B+</option>
                            <option value="B-">B-</option>
                            <option value="O+">O+</option>
                            <option value="O-">O-</option>
                            <option value="AB+">AB+</option>
                            <option value="AB-">AB-</option>
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Allergies</label>
                    <input type="text" name="allergies" class="form-control" placeholder="e.g. Penicillin, Nuts (or 'None')">
                </div>

                <div class="mb-3">
                    <label class="form-label">Medical History / Notes</label>
                    <textarea name="medicalHistory" class="form-control" rows="3"></textarea>
                </div>

                <button type="submit" class="btn btn-success">Save Patient</button>
                <a href="patient?action=list" class="btn btn-secondary">Cancel</a>
            </form>
        </div>
    </div>
</div>
</body>
</html>