# Medicare Clinic Management System

Medicare is a Java web application for managing clinic activities,
including patients, doctors, appointments, visits, medical records,
prescriptions, billing and notifications.

The application provides separate interfaces for patients and the
management team. It supports both MySQL database storage and file storage.

## Technologies

- Java 11 or later
- JSP and Java Servlets (`javax.servlet`)
- JDBC and MySQL
- HTML, CSS and JavaScript
- Maven
- Apache Tomcat 9

Use Tomcat 9. This project is not directly compatible with Tomcat 10 or 11.

## Main Modules

- Patient management and patient registration
- Doctor profiles, schedules and availability
- Appointment booking, rescheduling and cancellation
- Check-in and consultation visit workflow
- Medical records and prescriptions
- Billing, payments and invoice printing
- Patient notifications
- User accounts, role-based access and dashboard integration

Invoices include the doctor fee, hospital charge and medical treatment charge.

## Team Responsibilities

| Member | Name | Registration ID | Assigned Module |
|---|---|---|---|
| 1 | Ambegoda S.P | IT26100023 | Patient Management |
| 2 | Akalanka K.K.G.K | IT26100803 | Doctor and Schedule Management |
| 3 | Wickramasinghe V.I. | IT26100802 | Appointment and Visit Workflow |
| 4 | Dimath A.M.S | IT26100764 | Medical Records and Prescriptions |
| 5 | Sadewma T. M. | IT26100090 | Billing and Notifications |
| 6 | Dharmarathna L. A. L. S. | IT26100841 | Admin, Dashboard and Integration |

Assignments describe responsibilities. Actual contributions and supporting
evidence are recorded in [Team Contributions](docs/TEAM_CONTRIBUTIONS.md).

## Project Structure

| Path | Purpose |
|---|---|
| `src/main/java/` | Java models, services, DAOs, servlets and supporting code |
| `src/main/webapp/` | JSP pages, web assets and web configuration |
| `database/` | Demo database setup and upgrade scripts |
| `docs/` | Technical documentation, diagrams and test reports |
| `samples/` | Sample resources |
| `scripts/` | Project helper scripts |
| `dist/` | Packaged WAR supplied with the project |
| `pom.xml` | Maven dependencies and build configuration |

## Getting Started

### 1. Clone the Repository

Repository access is required while the repository is private.

```bash
git clone https://github.com/IT26100841/medicare-app-OOP-Project.git
cd medicare-app-OOP-Project
```

Open `pom.xml` in IntelliJ IDEA and load the project as a Maven project.
Configure a JDK version of 11 or later.

### 2. Choose a Storage Mode

FILE and DB modes use separate datasets. Switching modes does not
automatically transfer data between them.

#### Option A: FILE Mode

To run without MySQL, add this option to the Tomcat run configuration:

```text
-Dmedicare.storage=FILE
```

Back up any existing external `medicare-data` directory before replacing
or upgrading an existing installation.

#### Option B: MySQL Mode

For a new local demo database, use:

```text
database/medicare-patient-portal-fresh.sql
```

Review the script before running it and use a separate local demo
environment. Do not use a fresh setup script to upgrade an existing
database containing records.

For an existing compatible `medicare_db` installation:

1. Export a database backup.
2. Stop Tomcat.
3. Read [Database Migration](docs/DB_MIGRATION.md).
4. Execute `database/upgrade-reviewed.sql`.
5. If the database name differs, adjust the script's `USE` statement.
6. Deploy the updated application and restart Tomcat.

The upgrade script requires the relevant ALTER and CREATE ROUTINE
permissions.

Configure these VM options in the Tomcat run configuration:

```text
-Dmedicare.storage=DB
-Dmedicare.db.url=jdbc:mysql://localhost:3306/medicare_db
-Dmedicare.db.user=YOUR_MYSQL_USER
-Dmedicare.db.password=YOUR_MYSQL_PASSWORD
```

Replace the placeholders with local credentials. Adjust the database
name and port if necessary.

Set these options on Tomcat, not only on the Maven runner. Keep actual
credentials and private database exports out of Git.

Private database snapshots mentioned in older release notes are not
required repository files and are excluded from version control.

### 3. Build the Application

From PowerShell in the project directory:

```powershell
.\mvnw.cmd clean package
```

The generated WAR is:

```text
target/medicare-app.war
```

A packaged WAR is also supplied at `dist/medicare-app.war`.
After changing source code, build and deploy the newly generated WAR.

### 4. Deploy to Tomcat 9

Deploy the WAR to Tomcat 9 and use this application context:

```text
/medicare-app
```

For IntelliJ installations with Tomcat integration, configure a local
Tomcat server and add the WAR under Deployment. Otherwise, deploy the
WAR using an external Tomcat 9 installation.

Start Tomcat and open:

| Interface | Local URL |
|---|---|
| Patient Portal | http://localhost:8080/medicare-app/portal |
| Management Login | http://localhost:8080/medicare-app/login.jsp |

Adjust the URLs if Tomcat uses a different port or application context.

## Login

Existing database installations retain their existing accounts and
password hashes. Upgrading does not assign new passwords to those accounts.

The supplied startup guide lists these credentials for FILE demo or
empty-demo SQL setups only:

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `admin123` |
| Staff | `staff` | `staff123` |
| Doctor | `doctor` | `doc123` |

Patients can register through **Patient Portal → Create account**.

Change demo credentials before any public deployment.

## Example Workflow

1. A patient registers and signs in.
2. The patient selects an available doctor, date and time.
3. The patient books an appointment and receives a saved notification.
4. Reception checks in the patient on the appointment date.
5. The mapped doctor starts the visit.
6. The doctor saves clinical notes and completes the visit.
7. Staff create an invoice with the relevant charges.
8. Staff record payment and print the invoice.

Doctor availability is managed through the clinic doctor schedules UI.
The active availability table is `clinic_availability`.

## Verification

See [Test Results](docs/TEST_RESULTS.md) for the recorded test report.

After configuring your own environment, verify the complete workflow above.
Also check that patients can access only their own information and that
management actions respect the assigned user roles.

Recorded test results apply to the version and environment documented
in the report.

## Team Git Workflow

| Member | Branch |
|---|---|
| 1 | `feature/1-patients` |
| 2 | `feature/2-doctors` |
| 3 | `IT26100802/appointment` |
| 4 | `update/latest-medicare` |
| 5 | `feature/5-billing-and-notifications` |
| 6 | `add-admin` |

Each member should:

1. Use their own GitHub account and Git commit identity.
2. Work on their assigned branch.
3. Make and test changes.
4. Commit with a clear description of the actual work.
5. Push the branch and open a pull request to `main`.
6. Request a teammate review before merging.
7. Record contribution and test evidence in the team document.

Branch creation alone does not establish individual implementation
contributions.

## Documentation

- [Team Contributions](docs/TEAM_CONTRIBUTIONS.md)
- [GitHub Contributions](docs/GITHUB_CONTRIBUTIONS.md)
- [Guideline Mapping](docs/GUIDELINE_MAPPING.md)
- [Technical Report](docs/TECHNICAL_REPORT.md)
- [Class Diagrams](docs/CLASS_DIAGRAM.md)
- [Database Migration](docs/DB_MIGRATION.md)
- [Demo Walkthrough](docs/DEMO_WALKTHROUGH.md)
- [Test Results](docs/TEST_RESULTS.md)
- [Sinhala Startup Guide](START_HERE_SINHALA.txt)
- [Patient Portal Guide](PATIENT_PORTAL_START_HERE.md)
- [Third-Party Notices](THIRD_PARTY_NOTICES.txt)