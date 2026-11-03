# Task Report — Billing & Notifications Module

**Member:** IT26100066 (`@IT26100066`)  
**Branch:** `feature/5-billing-and-notifications`  
**Module:** Member 5 — Billing, Payments, Insurance Claims & Notifications  

---

## 1. What I was responsible for

I was responsible for developing the complete Billing & Notifications module for the Medicare Hospital Management System. This module provides consultation invoice generation from completed visits, payment recording (Cash, Card, Bank transfer) with audit logging, printable invoice/receipt generation, insurance claims management and status tracking, patient appointment notifications, and dual persistence support (MySQL database and fallback file storage).

---

## 2. Features I implemented

| # | Feature | Where |
|---|---|---|
| 1 | Consultation Invoice Generation (from completed visits) | `BillingService.java`, `BillServlet.java`, `create-bill.jsp` |
| 2 | Invoice Directory with Search, Status Filtering, and Financial Summaries | `bill-list.jsp`, `BillServlet.java` |
| 3 | Payment Processing (Cash, Card, Bank Transfer) with Audit Logging | `BillingService.java`, `BillServlet.java` |
| 4 | Printable Invoice / Receipt View | `BillPDFServlet.java`, `WEB-INF/views/print-invoice.jsp` |
| 5 | Insurance Claim Submission & Status Tracking | `InsuranceClaimServlet.java`, `insurance-claims.jsp` |
| 6 | Patient Notifications Management | `NotificationDAO.java`, `notifications.jsp` |
| 7 | Dual Persistence Architecture (MySQL DB & File fallback) | `dao/impl/BillDAODBImpl.java`, `dao/impl/BillDAOFileImpl.java`, `dao/impl/NotificationDAODBImpl.java`, `dao/impl/NotificationDAOFileImpl.java` |
| 8 | Database Table DDL and Seed Scripts | `database/member_5_billing_and_notifications.sql` |

---

## 3. Files I own

- `src/main/java/com/medicare/model/Bill.java`
- `src/main/java/com/medicare/model/ClaimEntry.java`
- `src/main/java/com/medicare/model/Notification.java`
- `src/main/java/com/medicare/dao/BillDAO.java`
- `src/main/java/com/medicare/dao/NotificationDAO.java`
- `src/main/java/com/medicare/dao/impl/BillDAODBImpl.java`
- `src/main/java/com/medicare/dao/impl/BillDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/NotificationDAODBImpl.java`
- `src/main/java/com/medicare/dao/impl/NotificationDAOFileImpl.java`
- `src/main/java/com/medicare/service/BillingService.java`
- `src/main/java/com/medicare/servlet/BillServlet.java`
- `src/main/java/com/medicare/servlet/BillPDFServlet.java`
- `src/main/java/com/medicare/servlet/InsuranceClaimServlet.java`
- `src/main/webapp/bill-list.jsp`
- `src/main/webapp/create-bill.jsp`
- `src/main/webapp/insurance-claims.jsp`
- `src/main/webapp/notifications.jsp`
- `src/main/webapp/WEB-INF/views/print-invoice.jsp`
- `database/member_5_billing_and_notifications.sql`

---

## 4. How it works

1. **Invoice Creation Flow**: A staff member or receptionist creates an invoice for a completed doctor appointment via `create-bill.jsp`. Upon form submission, `BillServlet` receives the `appointmentId` and calls `BillingService.create(appointmentId)`. The service validates that the appointment exists, is in `Completed` status, and has not yet been invoiced. It queries the doctor's consultation fee through `DoctorDAO` and persists the new `Bill` record with status `Unpaid`.
2. **Payment Processing**: Staff members record payments from `bill-list.jsp`. `BillServlet` receives `action=pay`, bill ID, and payment method (`Cash`, `Card`, or `Bank transfer`). `BillingService.pay(...)` updates the payment status to `Paid` and records an audit log entry via `AuditLogger`.
3. **Printable Invoice**: Clicking "Print invoice" sends a GET request to `BillPDFServlet?id=<id>`, which fetches the bill data from `BillDAO` and forwards to `WEB-INF/views/print-invoice.jsp` formatted for print/PDF export.
4. **Insurance Claims**: Patients and staff submit insurance claims via `insurance-claims.jsp`. `InsuranceClaimServlet` manages claim creation, status updates (`Pending`, `Approved`, `Rejected`), and policy tracking.
5. **Notifications**: System alerts and reminders for patient appointments are displayed on `notifications.jsp`, retrieved through `NotificationDAO`.

### Key Code Highlight: Synchronized Invoice Generation & Validation

```java
public Bill create(int appointmentId) {
    synchronized (AbstractFileDAO.LOCK) {
        Appointment a = DAOFactory.getAppointmentDAO().getAppointmentById(appointmentId);
        if (a == null || !"Completed".equals(a.getStatus())) {
            throw new IllegalArgumentException("Invoices can only be created for completed consultations");
        }
        for (Bill b : DAOFactory.getBillDAO().getAllBills()) {
            if (b.getAppointmentId() == appointmentId) {
                throw new IllegalArgumentException("An invoice already exists for this visit");
            }
        }
        Doctor d = DAOFactory.getDoctorDAO().getDoctorById(a.getDoctorId());
        if (d == null) throw new IllegalArgumentException("Doctor not found");
        Bill b = new Bill(appointmentId, a.getPatientId(), d.getConsultationFee(), "Cash", "Unpaid");
        if (!DAOFactory.getBillDAO().createBill(b)) {
            throw new IllegalStateException("Invoice was not saved");
        }
        return b;
    }
}
```

---

## 5. Database tables used

| Table | Operation | Purpose |
|---|---|---|
| `bills` | SELECT, INSERT, UPDATE | Invoices with appointment ID, patient ID, fee amount, payment method, payment status |
| `notifications` | SELECT, INSERT, DELETE | Patient and system notifications with timestamps |
| `insurance_claims` | SELECT, INSERT, UPDATE | Insurance claim entries, provider name, policy number, claim amount, claim status |

---

## 6. Testing

| Test | Steps | Expected | Result |
|---|---|---|---|
| Create Invoice | Submit completed appointment ID in create bill form | Invoice created with fee matching doctor consultation fee and status `Unpaid` | Pass |
| Duplicate Invoice Guard | Attempt to create another invoice for same appointment ID | Action rejected with error message | Pass |
| Record Payment | Select payment method (Card/Cash) and mark paid | Bill status updated to `Paid`, audit log recorded | Pass |
| Print Invoice View | Click print invoice for existing bill | Clean printable layout rendered with bill & patient details | Pass |
| Submit Insurance Claim | Enter policy number, provider, amount, and submit | Claim appears with `Pending` status | Pass |
| Dual Storage Fallback | Switch system to FILE storage mode and create bill | Invoice saved into file storage seamlessly | Pass |

---

## 7. Difficulties and how I solved them

- **Consultation Fee Consistency**: Dynamically linked invoice generation to `DoctorDAO` rather than hardcoding amounts, ensuring the billing record accurately reflects doctor charges.
- **Dual Persistence Architecture**: Implemented both `BillDAODBImpl` and `BillDAOFileImpl` (as well as for `NotificationDAO`) so the entire module functions consistently regardless of whether MySQL or local file persistence is active.

---

## 8. What I would improve

- Integrate an online payment gateway (e.g. Stripe / PayHere) for patient self-checkout.
- Automated email / SMS dispatch for overdue invoice reminders.
