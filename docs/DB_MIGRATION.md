# Database migration

Read START_HERE_SINHALA.txt before deployment. Stop Tomcat and back up first.

**Existing database:** import database/upgrade-reviewed.sql into medicare_db, then deploy the new WAR with existing VM options. The procedure checks duplicate invoices and orphan schedule/account mappings before adding three bill columns, invoice uniqueness, schedule/account foreign keys and amount/total checks. Re-running is supported; data is not deleted or reassigned. Permissions to create/drop a routine and alter tables are required.

**Separate copy:** import database/medicare-database-updated.sql (standalone delivery: medicare_database_updated.sql). It creates/selects medicare_db_updated and preserves the uploaded INSERT statements. Point Tomcat at jdbc:mysql://localhost:3306/medicare_db_updated. It intentionally does not drop existing tables, so use an empty target database.

**Demo only:** medicare_db.sql and database/medicare-patient-portal-fresh.sql create synthetic demonstration data in an empty medicare_db. Older upgrade-patient-portal.sql / upgrade-workflow.sql are historical additive steps, not substitutes for upgrade-reviewed.sql in this release.

clinic_availability is the active schedule source. doctor_availability is preserved legacy data; do not expect edits in that old table to publish current booking slots. The upgraded bills.appointment_id is unique. Existing invoices with consultation_charge NULL display their old amount as consultation and zero additional charges.

For rollback, stop the app and restore your database/data-folder backup and previous WAR together. MySQL/MariaDB DDL does not provide atomic rollback across all ALTERs.
