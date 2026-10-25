# Task Report — Core, Authentication, Security & Audit (Admin)

**Member:** Shanaka D (`@IT26100841`)  
**Branch:** `feature/1-core-auth`  
**Module:** Core, Authentication, Security & Admin Audit  

---

## 1. What I was responsible for

I was responsible for the foundational architecture of the Medicare Hospital Management System. This includes the database connection lifecycle (`DBConnection`), user authentication (login/logout/registration), password management, role-based access control filters (`AdminAuthFilter`), audit logging for administrative events (`AuditLogger`), the `DAOFactory` pattern, and system settings.

## 2. Features I implemented

| # | Feature | Where |
|---|---|---|
| 1 | Database connection management with connection pooling safety | `util/DBConnection.java` |
| 2 | Role-based authentication & admin route protection | `filter/AdminAuthFilter.java` |
| 3 | User Login & Session handling | `servlet/LoginServlet.java` |
| 4 | User Logout & session invalidation | `servlet/LogoutServlet.java` |
| 5 | Password change with current-password verification | `servlet/ChangePasswordServlet.java` |
| 6 | System settings management | `servlet/SettingsServlet.java` |
| 7 | Security audit logging for administrative compliance | `util/AuditLogger.java` |
| 8 | User DAO with JDBC and file-fallback implementations | `dao/impl/UserDAODBImpl.java`, `UserDAOFileImpl.java` |
| 9 | Factory pattern for seamless DAO decoupling | `factory/DAOFactory.java` |

## 3. Files I own

- `src/main/java/com/medicare/util/DBConnection.java`
- `src/main/java/com/medicare/util/AuditLogger.java`
- `src/main/java/com/medicare/filter/AdminAuthFilter.java`
- `src/main/java/com/medicare/model/User.java`
- `src/main/java/com/medicare/dao/UserDAO.java`
- `src/main/java/com/medicare/dao/impl/UserDAODBImpl.java`
- `src/main/java/com/medicare/dao/impl/UserDAOFileImpl.java`
- `src/main/java/com/medicare/service/UserService.java`
- `src/main/java/com/medicare/factory/DAOFactory.java`
- `src/main/java/com/medicare/servlet/LoginServlet.java`
- `src/main/java/com/medicare/servlet/LogoutServlet.java`
- `src/main/java/com/medicare/servlet/ChangePasswordServlet.java`
- `src/main/java/com/medicare/servlet/SettingsServlet.java`
- `src/main/webapp/login.jsp`
- `src/main/webapp/register.jsp`
- `src/main/webapp/dashboard.jsp`
- `src/main/webapp/change-password.jsp`
- `src/main/webapp/settings.jsp`
- `src/main/webapp/audit-logs.jsp`

## 4. How it works

When an administrator or user accesses any secured URL, `AdminAuthFilter` intercepts the HTTP request to verify if a valid session exists and checks if the user's role is `ADMIN`. If unauthenticated, it redirects to `login.jsp`. Upon valid login via `LoginServlet`, user credentials are authenticated via `UserService` and `UserDAO`. Every security-sensitive administrative operation (such as user creation or password updates) automatically triggers `AuditLogger.log()`, persisting the timestamp, user ID, IP address, and action to the `audit_logs` database table.

```java
// Excerpt from AdminAuthFilter.java: Ensuring strict role-based access control
HttpSession session = httpRequest.getSession(false);
User user = (session != null) ? (User) session.getAttribute("currentUser") : null;

if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
    httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp?error=unauthorized");
    return;
}
chain.doFilter(request, response);
```

## 5. Database tables used

| Table | Operation |
|---|---|
| `users` | SELECT, INSERT, UPDATE |
| `audit_logs` | SELECT, INSERT |
| `settings` | SELECT, UPDATE |

## 6. Testing

| Test | Steps | Expected | Result |
|---|---|---|---|
| Admin Login | Navigate to `/login.jsp`, enter `admin` / `admin123` | Redirected to admin dashboard with active session | Pass |
| Unauthorized Access | Open `/audit-logs.jsp` without logging in | Blocked by `AdminAuthFilter`, redirected to login | Pass |
| Role Check | Log in as Doctor and attempt to access `/settings` | Access denied with unauthorized error message | Pass |
| Password Change | Submit valid current password and new password | Database updated, success notification shown | Pass |
| Audit Logging | Perform administrative changes and inspect audit logs | New row added to `audit_logs` with correct user and action | Pass |

## 7. Difficulties and how I solved them

- **Connection Leaks:** Initially, raw JDBC connections remained open when unexpected exceptions occurred. I resolved this by standardizing `try-with-resources` blocks across all `UserDAODBImpl` methods.
- **Role Permissions:** Non-admin users could potentially tamper with administrative routes. Implemented the central `AdminAuthFilter` in `web.xml` to intercept all `/admin/*` and sensitive servlet mappings before requests reach controllers.

## 8. What I would improve

- Integrate BCrypt password hashing instead of plaintext/basic encoding for production-grade security.
- Implement rate limiting on `/login` to protect against brute-force attacks.
