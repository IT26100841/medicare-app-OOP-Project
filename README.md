# Medicare — Hospital Management System

A Java Servlet & JSP web application for hospital management: patient and doctor
directories, appointment booking with automatic double-booking detection, clinical
records and prescriptions, billing with PDF receipts, insurance claims, document
uploads, notifications and audit logging.

> **University group project — WD 51** · 6 members
> Task allocation: [`docs/TEAM-TASKS.md`](docs/TEAM-TASKS.md) · Git guide: [`docs/GIT-WORKFLOW.md`](docs/GIT-WORKFLOW.md)

---

## Table of contents

- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
- [Default logins](#default-logins)
- [Modules and features](#modules-and-features)
- [Team and task allocation](#team-and-task-allocation)
- [Documentation](#documentation)

---

## Tech stack

| Layer | Technology |
| --- | --- |
| Presentation | JSP, JSTL 1.2, HTML/CSS |
| Web layer | Java Servlet API 4.0.1 (`@WebServlet` annotations) |
| Business logic | Plain Java service classes |
| Persistence | DAO pattern — interface + JDBC and file-backed implementations |
| Database | MySQL 8 (`medicare_db`) |
| Build | Apache Maven — `war` packaging |
| Server | Apache Tomcat 9 |
| Java | 11 |

## Architecture

```
Browser
  │
  ▼
JSP  ◄──────────────┐
  │                 │
  ▼                 │
Servlet (@WebServlet)  ──►  Service  ──►  DAO interface  ──►  DAO impl  ──►  MySQL
                                       │
                                       └─►  File impl (optional, no-DB demo)
```

| Package | Responsibility |
| --- | --- |
| `com.medicare.model` | Domain entities (`Patient`, `Doctor`, `Appointment`, `Bill`, …) |
| `com.medicare.dao` | DAO interfaces — the persistence contract |
| `com.medicare.dao.impl` | JDBC (`*DAODBImpl`) and file-based (`*DAOFileImpl`) implementations |
| `com.medicare.factory` | `DAOFactory` — chooses the DAO implementation |
| `com.medicare.service` | Business rules (conflict detection, billing, validation) |
| `com.medicare.servlet` | HTTP endpoints |
| `com.medicare.filter` | `AdminAuthFilter` — role-based access control |
| `com.medicare.util` | `DBConnection`, `AuditLogger` |

## Project structure

```
medicare-app/
├── pom.xml                      Maven build (war)
├── medicare_db.sql              Full schema + seed data
├── mvnw / mvnw.cmd              Maven wrapper
├── docs/
│   ├── TEAM-TASKS.md            Who owns which module and files
│   ├── GIT-WORKFLOW.md          Step-by-step Git/GitHub guide
│   └── tasks/                   Per-member task reports
├── src/main/java/com/medicare/  Java sources
├── src/main/webapp/             JSP views + WEB-INF/web.xml
└── src/test/                    Tests
```

## Getting started

### 1. Prerequisites

- JDK 11+
- MySQL 8 (XAMPP / WAMP / standalone)
- Apache Tomcat 9
- Maven — or just use the bundled wrapper (`mvnw`)

### 2. Create the database

Using phpMyAdmin:

1. Create a database named `medicare_db`.
2. Open **Import**, choose `medicare_db.sql`, click **Go**.

Using the MySQL CLI:

```bash
mysql -u root -p < medicare_db.sql
```

Connection settings live in
`src/main/java/com/medicare/util/DBConnection.java`:

```
jdbc:mysql://localhost:3306/medicare_db?useSSL=false&allowPublicKeyRetrieval=true
user: root
password: (empty by default)
```

> These credentials are for a local development database only. Never point this
> app at a production server, and never commit a real password.

### 3. Build and run

**Option A — IntelliJ IDEA / Eclipse**

1. Open the `medicare-app` folder as a Maven project.
2. Configure a local **Tomcat 9** run configuration.
3. Deploy the `MedicalAppointmentSystem:war exploded` artifact.
4. Context path: `/medicare-app`.
5. Open <http://localhost:8080/medicare-app/>.

**Option B — Maven + Tomcat**

```bash
./mvnw clean package
# Windows: .\mvnw.cmd clean package
```

Copy `target/MedicalAppointmentSystem-1.0-SNAPSHOT.war` into Tomcat's `webapps/`,
start Tomcat, then open <http://localhost:8080/medicare-app/>.

## Default logins

| Role | Username | Password | Access |
| --- | --- | --- | --- |
| Admin | `admin` | `admin123` | Full access |
| Doctor | `doctor` | `doc123` | Doctor portal, clinical records |
| Staff | `staff` | `staff123` | Reception, appointments, billing |

## Modules and features

| Module | Highlights |
| --- | --- |
| Authentication & security | Login, registration, password change, role checks, audit log |
| Patient management | Directory, add/edit/delete, medical history, blood group, allergies |
| Doctor management | Directory, specialisations, consultation fees, availability |
| Appointments | Booking, live search, status filters, reschedule, cancellation |
| Conflict detection | Prevents double-booking a doctor for the same date and time slot |
| Medical records | Diagnoses, prescriptions, prescription PDF export |
| Billing | Invoices, consultation fee tracking, PDF receipts |
| Insurance | Claims management |
| Documents | Lab reports and scans — upload and view |
| Notifications | In-app patient/staff notifications |

## Team and task allocation

> Replace the placeholders in the table below with the real names and GitHub
> usernames. The same data is kept in [`docs/TEAM-TASKS.md`](docs/TEAM-TASKS.md).

| # | Member | GitHub | Module | Branch |
| --- | --- | --- | --- | --- |
| 1 | Member 1 | `@username` | Core, authentication, security & audit | `feature/1-core-auth` |
| 2 | Member 2 | `@username` | Patient management | `feature/2-patients` |
| 3 | Member 3 | `@username` | Doctor management | `feature/3-doctors` |
| 4 | Member 4 | `@username` | Appointment scheduling & conflict detection | `feature/4-appointments` |
| 5 | Member 5 | `@username` | Medical records, prescriptions, documents | `feature/5-records` |
| 6 | Member 6 | `@username` | Billing, insurance & pharmacy | `feature/6-billing` |

## Documentation

| Document | Purpose |
| --- | --- |
| [`docs/TEAM-TASKS.md`](docs/TEAM-TASKS.md) | Exact file ownership per member |
| [`docs/GIT-WORKFLOW.md`](docs/GIT-WORKFLOW.md) | How each member commits and opens a pull request |
| [`docs/tasks/TEMPLATE.md`](docs/tasks/TEMPLATE.md) | Template for each member's task report |
