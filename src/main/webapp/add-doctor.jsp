<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Doctor - Medicare System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Add New Doctor</h4>
                </div>
                <div class="card-body">
                    <form action="doctor?action=insert" method="post">
                        <div class="mb-3">
                            <label class="form-label">Doctor ID</label>
                            <input type="text" name="id" class="form-control" placeholder="e.g. DOC001" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Full Name</label>
                            <input type="text" name="name" class="form-control" placeholder="Dr. John Smith" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Specialization</label>
                            <input type="text" name="specialization" class="form-control" placeholder="Cardiologist, Neurologist, etc." required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Qualification</label>
                            <input type="text" name="qualification" class="form-control" placeholder="MBBS, MD" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Phone</label>
                            <input type="text" name="phone" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Consultation Fee (LKR)</label>
                            <input type="number" step="0.01" name="consultationFee" class="form-control" required>
                        </div>
                        <div class="d-flex justify-content-between">
                            <a href="doctor?action=list" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-primary">Save Doctor</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>