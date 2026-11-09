# ZIP Update Notes

This update applies three source-level fixes identified during review:

1. `ViewDocumentServlet` now requires a signed-in management user. Administrators and staff can access documents; doctors can access documents only when the patient has an appointment linked to that doctor's account. Other roles receive an access-denied response.
2. `ScheduleService` now calculates candidate slots as date-time values and checks the slot duration against the end of the same-day schedule. This prevents a slot near midnight from wrapping into the next day and being accepted incorrectly.
3. `PatientPortalServlet` validates the `action` parameter inside its error-handling block so oversized input is handled by the servlet's normal validation response.

The project also includes the existing manual, UML documentation, team task reports, database scripts, and tests from the supplied archive.

GitHub contribution records are external to this ZIP. Open pull requests, commit authorship, and merge history must be reviewed and completed in the repository by the team. This ZIP does not claim that those GitHub changes have been merged. The source changes have not been run in a Tomcat/MySQL environment as part of this packaging step.
