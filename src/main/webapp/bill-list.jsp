<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.medicare.factory.DAOFactory, com.medicare.model.Bill, java.util.List" %>
<%
    List<Bill> list = DAOFactory.getBillDAO().getAllBills();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicare - Bills & Payments</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- DataTables & Buttons CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.1/css/buttons.bootstrap5.min.css">
</head>
<body class="bg-light">

<div class="container mt-4 mb-5">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2><i class="fa-solid fa-receipt text-warning me-2"></i>Bills & Payment Records</h2>
        <div>
            <a href="create-bill.jsp" class="btn btn-success me-2">
                <i class="fa-solid fa-plus me-1"></i> Create Bill
            </a>
            <a href="dashboard.jsp" class="btn btn-secondary">
                <i class="fa-solid fa-arrow-left me-1"></i> Dashboard
            </a>
        </div>
    </div>
    <hr>

    <div class="card shadow-sm border-0 p-3">
        <div class="table-responsive">
            <table id="billTable" class="table table-hover table-striped align-middle w-100">
                <thead class="table-dark">
                    <tr>
                        <th>Bill ID</th>
                        <th>Appt ID</th>
                        <th>Patient ID</th>
                        <th>Amount</th>
                        <th>Payment Method</th>
                        <th>Payment Status</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (list != null && !list.isEmpty()) { %>
                        <% for (Bill b : list) { %>
                        <tr>
                            <td><strong>#<%= b.getBillId() %></strong></td>
                            <td>#<%= b.getAppointmentId() %></td>
                            <td><span class="badge bg-primary"><%= b.getPatientId() %></span></td>
                            <td class="fw-bold text-success">$<%= String.format("%.2f", b.getAmount()) %></td>
                            <td><i class="fa-solid fa-wallet me-1 text-secondary"></i><%= b.getPaymentMethod() %></td>
                            <td>
                                <span class="badge <%= "Paid".equalsIgnoreCase(b.getPaymentStatus()) ? "bg-success" : "bg-warning text-dark" %>">
                                    <%= b.getPaymentStatus() %>
                                </span>
                            </td>
                            <td class="text-center">
                                <% if (!"Paid".equalsIgnoreCase(b.getPaymentStatus())) { %>
                                <form action="bill" method="post" style="display:inline;" class="me-1">
                                    <input type="hidden" name="action" value="pay">
                                    <input type="hidden" name="billId" value="<%= b.getBillId() %>">
                                    <input type="hidden" name="paymentMethod" value="Cash">
                                    <button type="submit" class="btn btn-sm btn-success">
                                        <i class="fa-solid fa-check me-1"></i> Mark Paid
                                    </button>
                                </form>
                                <% } %>
                                <a href="download-bill?id=<%= b.getBillId() %>" target="_blank" class="btn btn-sm btn-outline-warning text-dark">
                                    <i class="fa-solid fa-file-pdf me-1"></i> Receipt
                                </a>
                            </td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- jQuery & DataTables JS -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>

<script>
    $(document).ready(function() {
        $('#billTable').DataTable({
            dom: 'Bfrtip',
            buttons: [
                { extend: 'excelHtml5', className: 'btn btn-sm btn-success mb-3 me-2', text: '<i class="fa-solid fa-file-excel me-1"></i> Export to Excel' },
                { extend: 'csvHtml5', className: 'btn btn-sm btn-info mb-3 text-white', text: '<i class="fa-solid fa-file-csv me-1"></i> Export to CSV' }
            ],
            pageLength: 10,
            responsive: true
        });
    });
</script>

</body>
</html>