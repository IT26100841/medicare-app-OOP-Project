# Corrected Patient Portal

Start with START_HERE_SINHALA.txt. This release keeps the uploaded patient UI and its separate login, adds patient-scoped persisted notifications, fixes authorization/validation/account consistency and includes hospital/treatment invoice charges in the team workspace. MySQL requires database/upgrade-reviewed.sql before the corrected WAR is deployed. Existing patient and team credentials are preserved by the updated SQL export.

Patient entry: /medicare-app/portal. Team entry: /medicare-app/login.jsp. Patient registration creates your own profile only. Existing clinical profiles require reception identity verification. No automatic email/SMS recovery, family accounts or online payment is added.
