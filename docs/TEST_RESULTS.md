# Verification — corrected release, 2 November 2026

- Java/JUnit: **46 tests executed: 45 passed, 1 skipped** (original suites, billing, review-fix regressions; symlink creation explicitly skipped when unsupported/unprivileged on Windows).
- FILE Tomcat HTTP workflow: **28 checks passed**.
- DB Tomcat HTTP workflow: **28 checks passed**.
- Live DB/schema/JDBC checks: **46 passed**.
- Chromium: live invoice total, desktop/mobile billing, patient registration/booking and patient-scoped notification rendering checked; 1440px desktop and 390px mobile, no horizontal overflow in checked mobile screens.

Test runtime: JDK 17 compiling for Java 11; Apache Tomcat 9.0.98; MariaDB 10.11.5; MySQL Connector/J 8.0.33; Chromium headless 131. Runtime versions identify execution conditions and are not current production-server recommendations.

## HTTP checks run in both modes
- admin login
- staff login
- doctor login
- uppercase unauthorized patient delete blocked
- unauthorized lowercase delete blocked
- patient survives blocked deletes
- CSRF-less delete blocked
- authorized POST delete works
- invalid account not partially saved
- patient registration
- patient cannot access management
- patient visible in management
- available slots loaded
- patient booking creates notification
- other patient cannot see first patient details
- other patient cancellation blocked
- own cancellation and notification
- past reschedule blocked
- staff check-in
- doctor starts consultation
- doctor clinical record
- doctor completes consultation
- additional charge form
- invoice grand total and breakdown
- print invoice
- payment preserves total
- role change saved
- old doctor session revoked

## DB assertions
The supplied SQL imported successfully on the isolated database server. Additive migration was run twice. Row counts for all 15 original tables were unchanged. The separate updated export reproduced the original row counts. Original INSERT statements were also compared byte-for-byte with the delivery SQL copy. Booking and cancellation each persisted one notification. A forced notification INSERT failure rolled back the booking. A forced doctor-mapping INSERT failure rolled back the account. Billing components round-tripped and payments retained the total. Direct duplicate invoices and orphan schedules were rejected by constraints.

## Re-run Java tests
`mvn test`

Offline alternative with a Tomcat 9 directory:
`python scripts/build_offline.py --tomcat /path/to/tomcat9 --test`

The bundled dist/medicare-app.war is rebuilt from this release. Integration checks used isolated synthetic fixtures added to test database copies; those added test accounts/visits are not included in the user's delivered SQL export.

## Limits
The user's original dump identifies MariaDB 10.4.32. That exact engine, MySQL 8 itself, the user's computer/network, real Git history and actual member viva performance were not remotely verified. FILE rollback covers runtime failures within one process, not power-loss journaling or multiple servers. Automated tests and browser checks do not guarantee absence of every defect or certify live clinical production use. Keep backups and use synthetic data for coursework demonstrations.
