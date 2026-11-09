# Task Report — Billing and Notifications

**Member:** Sadewma T. M. (`IT26100090`)  
**Branch:** `feature/5-billing-and-notifications`  
**Module:** Invoicing, Charge Calculation, Payment Processing & Notifications

---

## 1. What I was responsible for
Responsible for patient billing, calculation of doctor consultation fee + hospital charge + medical treatment charge, payment status updates (Cash/Card/Bank transfer), invoice printing, and patient notifications.

## 2. Features Implemented
| # | Feature | Where |
|---|---|---|
| 1 | Invoice Generation & Breakdown | `servlet/BillServlet.java`, `service/BillingService.java` |
| 2 | Invoice Listing & Filtering | `webapp/bill-list.jsp`, `dao/BillDAO.java` |
| 3 | Payment Settlement & Update | `servlet/BillServlet.java`, `webapp/bill-list.jsp` |
| 4 | Printable PDF Invoice & Notifications | `views/print-invoice.jsp`, `dao/NotificationDAO.java` |

## 3. Files I own
- `src/main/java/com/medicare/model/Bill.java`
- `src/main/java/com/medicare/model/Notification.java`
- `src/main/java/com/medicare/dao/BillDAO.java`
- `src/main/java/com/medicare/dao/NotificationDAO.java`
- `src/main/java/com/medicare/dao/impl/BillDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/BillDAODBImpl.java`
- `src/main/java/com/medicare/service/BillingService.java`
- `src/main/java/com/medicare/servlet/BillServlet.java`
- `src/main/webapp/bill-list.jsp`
- `src/main/webapp/create-bill.jsp`
- `src/main/webapp/notifications.jsp`

## 4. How it works
`BillingService.create()` captures a snapshot of the doctor's consultation fee and entered hospital/treatment charges. `BigDecimal` arithmetic prevents floating-point rounding errors. `BillServlet` safely handles actor sessions and persists invoices. Notifications are queued for patients upon booking or cancellation.

```java
// Safe BigDecimal computation in BillingService
BigDecimal consultation = money(String.valueOf(d.getConsultationFee()));
BigDecimal total = consultation.add(hospitalCharge).add(treatmentCharge);
Bill b = new Bill(appointmentId, patientId, total.doubleValue(), "Cash", "Unpaid");
```

## 5. Storage (File & Database)
- **File:** `bills.txt`, `notifications.txt`
- **DB Table:** `bills`, `patient_notifications`

## 6. Testing
| Test | Steps | Expected | Result |
|---|---|---|---|
| Create Invoice | Add Rs. 1500 hospital + Rs. 500 treatment | Total = Consult Fee + 2000 | Pass |
| Settle Payment | Pay with Card | Status updated to "Paid" | Pass |
| Patient Notification | Book appointment in portal | Notification saved and displayed | Pass |
