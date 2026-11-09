# Task Report — Admin, Dashboard and Integration

**Member:** Dharmarathna L. A. L. S. (`IT26100841`)  
**Branch:** `add-admin`  
**Module:** User Management, Role-Based Access Control, Dashboard & Audit Logging

---

## 1. What I was responsible for
Responsible for administrative user account management, password updates, system audit logging, global security filtering (`AdminAuthFilter`), CSRF protection, and shared dashboard integration.

## 2. Features Implemented
| # | Feature | Where |
|---|---|---|
| 1 | Staff / User CRUD & Doctor Account Link | `servlet/UserServlet.java`, `service/AccountService.java` |
| 2 | Role-Based Access Control & CSRF Protection | `filter/AdminAuthFilter.java` |
| 3 | System Audit Logging | `util/AuditLogger.java`, `webapp/audit-logs.jsp` |
| 4 | Admin Dashboard & Integration Scaffolding | `webapp/dashboard.jsp`, `factory/DAOFactory.java` |

## 3. Files I own
- `src/main/java/com/medicare/model/User.java`
- `src/main/java/com/medicare/model/DoctorAccount.java`
- `src/main/java/com/medicare/dao/UserDAO.java`
- `src/main/java/com/medicare/dao/impl/UserDAOFileImpl.java`
- `src/main/java/com/medicare/dao/impl/UserDAODBImpl.java`
- `src/main/java/com/medicare/filter/AdminAuthFilter.java`
- `src/main/java/com/medicare/factory/DAOFactory.java`
- `src/main/java/com/medicare/servlet/UserServlet.java`
- `src/main/java/com/medicare/servlet/ChangePasswordServlet.java`
- `src/main/webapp/dashboard.jsp`
- `src/main/webapp/user-management.jsp`
- `src/main/webapp/user-form.jsp`
- `src/main/webapp/audit-logs.jsp`

## 4. How it works
`AdminAuthFilter` intercepts incoming requests, validates session tokens, checks CSRF tokens on state-changing requests, and verifies user role permissions against a strict access matrix. `DAOFactory` dynamically instantiates the correct DAO implementation based on the configured storage mode (`FILE` or `DB`).

```java
// User inherits abstract Person
public class User extends Person {
    @Override
    public String getRoleLabel() { return getRole(); }
    private int id;
    private String username;
    private String password;
    private String role;
}
```

## 5. Storage (File & Database)
- **File:** `users.txt`, `doctor_accounts.txt`, `audit_logs.txt`
- **DB Table:** `users`, `doctor_accounts`, `audit_logs`

## 6. Testing
| Test | Steps | Expected | Result |
|---|---|---|---|
| RBAC Guard | Staff attempts to open `/user-management.jsp` | Blocked with 403 Forbidden | Pass |
| CSRF Verification | Submit form without CSRF token | Blocked with 403 | Pass |
| Password Change | Change password for user | Session updated and audit logged | Pass |
