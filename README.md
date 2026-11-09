# Medicare - Medical Appointment System

SE1020 Object Oriented Programming coursework: a Java web application for medical appointments and clinic management.

## Features

- Patient portal and appointment booking
- Doctor availability and scheduling
- Patient and medical record management
- Billing, insurance claims, and notifications
- Staff accounts and audit logs
- File storage and MySQL storage implementations

## Technology

Java 11, Maven, JSP, Java Servlet 4, JDBC, MySQL, HTML, CSS, and JavaScript. Deploy to Apache Tomcat 9.

## Build and test

Install a JDK (11 or later) and run from this directory on Windows:

```powershell
.\mvnw.cmd clean verify
```

The build produces `target/medicare-app.war`. Deploy it to Tomcat 9's `webapps` directory. The supplied `dist/medicare-app.war` is the original prebuilt distribution.

- Patient portal: `http://localhost:8080/medicare-app/portal`
- Staff portal: `http://localhost:8080/medicare-app/login.jsp`

The source defaults to file storage. For configuration, database imports, and deployment details, read [the project manual](docs/PROJECT_MANUAL.md) and [database migration guide](docs/DB_MIGRATION.md).

## Project structure

| Path | Contents |
| --- | --- |
| `src/main/java` | Models, DAO implementations, services, and servlets |
| `src/main/webapp` | JSP pages and static assets |
| `src/test` | Java regression tests and HTTP integration scripts |
| `database` | SQL exports and migration scripts |
| `docs` | Manuals, diagrams, and existing test reports |
| `scripts` | Offline build and smoke-test helpers |
| `dist` | Original prebuilt WAR |
| `tools/test-libs` | Bundled offline test dependencies |

## Data handling

The supplied SQL exports contain demonstration records and demo account credentials, confirmed by the project owner for this coursework upload. Use these accounts only for local demonstrations. Local runtime data and environment files are ignored by Git.

## Documentation

Start with `START_HERE_SINHALA.txt`. Additional documentation is under `docs/`. Existing test reports were included in the supplied project; they do not represent a fresh test run of this upload.
