# Medicare Clinic Management and Patient Portal

SE1020 Object Oriented Programming — corrected coursework release, 2 November 2026.

## Purpose
A web application linking patients, doctors, reception and administrators. A patient can self-register, browse clinicians and published sessions, book or cancel their own eligible appointments, update permitted personal details and view their own notifications. The internal workspace manages patient profiles, doctors, appointments, clinical notes, invoices and team accounts.

## Architecture and data flow
Browser → AdminAuthFilter → Servlet → Service → DAOFactory → FILE/DB DAO → storage. Servlets/JSP views return escaped HTML. Some JSP lists use DAO/service reads directly; the Patient Portal is rendered by PatientPortalServlet. This is Java Servlet/JSP, not Spring Boot. JDK 11 target and javax.servlet require a compatible Tomcat 9 deployment.

Patient registration creates a clinical Patient and separate PatientAccount credential, linked by patient ID. DB registration uses one transaction. Existing clinical records cannot be claimed just by knowing an email address. Administrative identity verification/onboarding remains a reception process.

Appointments reference one patient and one doctor. ScheduleService reads clinic_availability. New bookings and reschedules use published slots and future time validation. Persistence serializes booking checks/writes and stores the confirmation notification together. Reception checks in arrivals; the mapped doctor starts the consultation, saves a MedicalRecord and completes the visit. Completed visits retain at least one clinical record.

A completed visit can have at most one invoice. BillingService snapshots the current consultation fee and two entered non-negative additional charges. BigDecimal validation/addition computes the total; the persisted decimal amounts populate the list and printable invoice. A later doctor-fee change does not rewrite existing invoice components. Legacy invoices retain their original total as the consultation component with zero additional charges. Payment updates method/status without changing component amounts.

## OOP evidence
- Encapsulation and information hiding: private model fields and public accessors, private validation/storage helpers.
- Inheritance: Patient, Doctor and User extend abstract Person; concrete FILE DAOs extend AbstractFileDAO<T>.
- Abstraction: Person and the PatientDAO, DoctorDAO, AppointmentDAO, MedicalRecordDAO, BillDAO, NotificationDAO and UserDAO contracts.
- Polymorphism: DAOFactory returns FILE or DB implementations behind the same interfaces; getRoleLabel is overridden by Person subclasses.
- Domain behavior: AppointmentStatus owns allowed state transitions. Transitions are checked again at persistence time to avoid reactivating a cancelled visit from a stale request.

## Security and consistency fixes
Management requests re-read the stored account identity, role and password hash. Deleted users, changed roles or changed passwords invalidate older sessions on their next management request. POSTs require CSRF tokens. Mutation detection normalizes action case. Patient deletion requires an administrator and executes only in POST handlers; authorized GET links display confirmation without deleting records.

Patient identity for self-service writes comes from the session. Cancellation checks ownership and future Booked state. Only patient-owned notifications are rendered in the portal. Account creation/update validates the doctor link first; AccountService commits account and link together in DB mode. Deletion removes a doctor account mapping and account together. FILE writes have in-process snapshot rollback across the related files.

Appointment creation/cancellation notifications are committed with the appointment write. Failures roll back both in DB mode; FILE mode restores snapshots for runtime failures. This is not a crash-recovery journal, a distributed FILE store, an immutable medical record or an immutable audit trail.

## Storage and database files
- database/upgrade-reviewed.sql: additive migration for the supplied existing medicare_db; preflight detects duplicate invoices and invalid schedule/account mappings before ALTERs. Re-runnable constraints/columns. No rows are deleted or reassigned.
- database/medicare-database-updated.sql: a copy of the user's supplied export followed by the migration, imported into a separate medicare_db_updated database. Original INSERT statements are preserved, including account hashes and clinical rows.
- database/medicare-patient-portal-fresh.sql and medicare_db.sql: synthetic demo data for an empty medicare_db only. Do not overwrite a populated database with these files.
- FILE: versioned UTF-8 TSV in an external data directory; complete field persistence, escaping, synchronized operations and atomic individual-file replacements. Legacy six-column bills can be read and are upgraded on a later write.

The new schema adds bill charge components, unique bills.appointment_id, and missing foreign keys for clinic schedules and account mappings. Existing generated-slot unique indexes prevent double bookings. doctor_availability is preserved as legacy data; booking uses clinic_availability. Database DDL is not transactionally reversible in MySQL/MariaDB: keep a backup, and address a failed preflight before retrying.

## Interfaces and team mapping
See GUIDELINE_MAPPING.md and TEAM_CONTRIBUTIONS.md. Each of the six component areas includes Java/backend responsibilities; visual design alone is not a substitute for an assigned CRUD demonstration. Member names, IDs, actual commits and viva performance cannot be inferred from a ZIP and are deliberately not fabricated.

## Verification and practical limits
See TEST_RESULTS.md for execution evidence. Actual checks use JDK 17 targeting Java 11, Tomcat 9.0.98 and MariaDB 10.11.5 with MySQL Connector/J 8.0.33. The user's original export identifies MariaDB 10.4.32; that exact engine and their personal machine were not executed remotely. Deployment server versions here identify test conditions, not current production recommendations.

No payment gateway, SMS/email delivery, automated identity recovery, AI diagnosis, laboratory integration, production clinical certification or guaranteed defect-free operation is claimed. Use fake data for demonstrations. Team member attribution and repository history must be supplied by the team.


## Version control and individual contribution evidence

The [Git commit history report](git-history/Git_Commit_History.md) records the 18 main-branch commits verified on 9 November 2026, with account attribution, dates, commit and pull request links, a member evidence table, and three screenshots. The report distinguishes module assignments from commit attribution and records the outstanding account differences and unmerged admin pull request.

The evidence is also available as a [standalone HTML report](git-history/Git_Commit_History.html) and [CSV history](git-history/commit-history.csv). This is a dated evidence snapshot; subsequent repository commits are visible in the [live main history](https://github.com/IT26100841/medicare-app-OOP-Project/commits/main/).
