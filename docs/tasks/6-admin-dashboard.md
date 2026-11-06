# Task Report - Admin Dashboard and User Management

**Member:** Dharmarathna L. A. L. S. (`@IT26100841`)  
**Branch:** `feature/6-admin-dashboard`  
**Module:** Admin Dashboard, User Management, and Role-Based Access Control (Member 6)

---

## 1. What I was responsible for

I was responsible for designing and implementing the hospital administrative module, role-based user management, authentication security, and cross-cutting integration. My module ensures secure access across the application by authenticating hospital staff, managing accounts with granular roles (Admin, Doctor, Staff), providing a centralized administrative dashboard, and keeping an audit trail of administrative actions.

---

## 2. Features I implemented

| # | Feature | Where |
|---|---|---|
| 1 | Role-based User Authentication & Session Security | `servlet/LoginServlet.java`, `servlet/LogoutServlet.java` |
| 2 | Complete User CRUD Operations (Create, Read, Update, Delete) | `servlet/UserServlet.java`, `webapp/user-management.jsp`, `webapp/user-form.jsp` |
| 3 | Access Control & Route Protection Filter | `filter/AdminAuthFilter.java` |
| 4 | Dual-Persistence Storage (Database & File Handling via DAO Pattern) | `dao/impl/UserDAODBImpl.java`, `dao/impl/UserDAOFileImpl.java`, `dao/impl/AbstractFileDAO.java` |
| 5 | Factory Pattern for Decoupled DAO Instantiation | `factory/DAOFactory.java` |
| 6 | Hospital Admin Dashboard & Metrics Overview | `webapp/dashboard.jsp`, `service/ClinicStore.java` |
| 7 | User Audit Logging & System Event Tracking | `util/AuditLogger.java`, `model/AuditEntry.java`, `webapp/audit-logs.jsp` |
| 8 | User Data Export (CSV Reporting via File I/O) | `servlet/UserServlet.java` (`users?action=export`) |
| 9 | Password Hashing & Security Utilities | `util/Passwords.java`, `util/Validation.java` |

---

## 3. Files I own

- `src/main/java/com/medicare/model/Person.java` (Abstract superclass)
- `src/main/java/com/medicare/model/User.java` (Domain entity)
- `src/main/java/com/medicare/model/AuditEntry.java` (Audit model)
- `src/main/java/com/medicare/dao/UserDAO.java` (DAO Interface)
- `src/main/java/com/medicare/dao/impl/UserDAODBImpl.java` (JDBC Database implementation)
- `src/main/java/com/medicare/dao/impl/UserDAOFileImpl.java` (File handling implementation)
- `src/main/java/com/medicare/dao/impl/AbstractFileDAO.java` (Reusable file I/O abstraction)
- `src/main/java/com/medicare/factory/DAOFactory.java` (Factory pattern)
- `src/main/java/com/medicare/service/UserService.java` (Business service layer)
- `src/main/java/com/medicare/servlet/UserServlet.java` (User controller & CSV export)
- `src/main/java/com/medicare/servlet/LoginServlet.java` & `LogoutServlet.java` (Auth controllers)
- `src/main/java/com/medicare/filter/AdminAuthFilter.java` (Security filter)
- `src/main/java/com/medicare/util/Passwords.java`, `Validation.java`, `AuditLogger.java`
- `src/main/webapp/dashboard.jsp`, `user-management.jsp`, `user-form.jsp`, `audit-logs.jsp`
- `src/test/java/com/medicare/UserTest.java` (JUnit test suite)
- `database/member_6_admin_dashboard_integration.sql` (Database schema)

---

## 4. Application of OOP Concepts

### A. Inheritance
`User` extends the abstract superclass `Person`:
```java
public abstract class Person {
  public abstract String getName();
  public abstract String getEmail();
  public abstract String getRoleLabel();

  public String getDisplayName() {
    return getRoleLabel() + ": " + getName();
  }
}

public class User extends Person {
  @Override
  public String getRoleLabel() {
    return "User";
  }
  // User inherits getDisplayName() and common personal attributes
}
```

### B. Polymorphism
- **Dynamic Polymorphism (Method Overriding):** `User` overrides `getRoleLabel()`. Both `UserDAODBImpl` and `UserDAOFileImpl` override all methods declared in the `UserDAO` interface.
- **Static Polymorphism (Constructor Overloading):** `User` provides 4 overloaded constructors matching different initialization requirements (default, credentials only, credentials + ID, full profile).

### C. Abstraction
- The `UserDAO` interface separates data access contracts from implementation specifics.
- `AbstractFileDAO<T>` provides generic file serialization, parsing, and thread-safe locking.

### D. Encapsulation & Information Hiding
- All fields in `User` (`id`, `username`, `password`, `role`, `name`, `email`) are `private`.
- Password hashes are stored securely and never exposed in plain text.
- Critical actions prevent destructive self-deletion (`if (id == current.getId()) throw new IllegalArgumentException(...)`).

---

## 5. How it works

When an administrator manages users:
1. The admin accesses `/users` which routes to `UserServlet.doGet()`.
2. `UserServlet` calls `UserService.getAllUsers()`, which queries `DAOFactory.getUserDAO()`.
3. Depending on configuration, `UserDAODBImpl` queries MySQL, or `UserDAOFileImpl` reads from `users.txt`.
4. `UserServlet` attaches the users list to the request and forwards to `user-management.jsp`.
5. When exporting data, `action=export` streams a formatted CSV directly to the browser.

---

## 6. Database tables used

| Table | Operation |
|---|---|
| `users` | SELECT, INSERT, UPDATE, DELETE |
| `audit_logs` | SELECT, INSERT |

---

## 7. Testing

Automated test cases were written in `src/test/java/com/medicare/UserTest.java` using JUnit:

| Test Case | Description | Expected Result | Status |
|---|---|---|---|
| `testUserInheritanceAndPolymorphism` | Verifies `User extends Person` and method overriding | Correct role label and display name | Pass |
| `testUserEncapsulationAndConstructors` | Verifies getters/setters and overloaded constructors | Accurate state initialization | Pass |
| `testPasswordHashingAndVerification` | Verifies password hashing and verification | Secure hash match, reject invalid pass | Pass |
| `testValidationUtilities` | Verifies mandatory inputs and email format check | Validates format, rejects malformed | Pass |
