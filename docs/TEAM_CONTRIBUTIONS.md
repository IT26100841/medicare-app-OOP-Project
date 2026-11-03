# Team Responsibilities and Contribution Evidence

Repository: https://github.com/IT26100841/medicare-app-OOP-Project

## Team Members

| Member | Name | Registration ID | Assigned Module | Branch |
|---|---|---|---|---|
| 1 | Ambegoda S.P | IT26100023 | Patient Management | feature/1-patients |
| 2 | Akalanka K.K.G.K | IT26100803 | Doctor and Schedule Management | feature/2-doctors |
| 3 | Wickramasinghe V.I. | IT26100802 | Appointment and Visit Workflow | IT26100802/appointment |
| 4 | Dimath A.M.S | IT26100764 | Medical Records and Prescriptions | update/latest-medicare |
| 5 | Sadewma T. M. | IT26100090 | Billing and Notifications | feature/5-billing-and-notifications |
| 6 | Dharmarathna L. A. L. S. | IT26100841 | Admin, Dashboard and Integration | add-admin |

These assignments describe module responsibilities. They do not, by themselves, establish authorship of the existing code.

## Backend Areas to Demonstrate

| Member | Relevant Classes and Components | Functionality to Explain and Verify |
|---|---|---|
| 1 | PatientService, PatientServlet, PatientDAO and FILE/DB implementations | Patient create, read, update and delete operations; validation and access checks |
| 2 | DoctorService, ScheduleService, ClinicStore | Doctor management, schedules and published availability |
| 3 | AppointmentService, AppointmentServlet, VisitService, AppointmentStatus | Booking, conflict checks, rescheduling, cancellation and visit workflow |
| 4 | MedicalRecordService, MedicalRecordServlet, MedicalRecordDAO implementations, PrescriptionPDFServlet | Medical record management, ownership/history checks and prescription output |
| 5 | BillingService, BillServlet, NotificationEvents and DAOs | Invoice creation, invoice viewing, payment updates and saved notifications |
| 6 | AdminAuthFilter, AccountService, UserServlet, DAOFactory and shared views | Account management, role-based access, dashboard and module integration |

## Actual Contribution Evidence

Each member must complete this table using work they actually performed.
Add real commit hashes and pull request links when available.

| Member | GitHub Username | Actual Work Completed or Reviewed | Tests Performed and Results | Commit / Pull Request Evidence |
|---|---|---|---|---|
| 1 | it26100023-Sahana | Patient Management module implementation and review | Documented in PR #4 | PR #4 (feature/1-patients) |
| 2 | IT26100803 | Doctor management, specialties and availability scheduling | Documented in PR #2 | PR #2 (feature/2-doctors) |
| 3 | IT26100802 | Appointment booking, visit workflow and slot management | Documented in branch | Branch IT26100802/appointment |
| 4 | it26100764-cell | Medical records, clinical prescriptions, review fixes, test capability handling and integration | 46 tests run: 45 passed, 1 skipped (symlinks in non-elevated Windows) | Branch update/latest-medicare |
| 5 | IT26100090 | Billing, payment processing, insurance claims and notifications | Documented in PR #5 | PR #5 (feature/5-billing-and-notifications) |
| 6 | IT26100841 | Admin dashboard, user management, project scaffolding | Initial scaffolding & PR #3 | PR #3 (add-admin) |

## Shared Responsibilities

The Patient Portal involves Patient Management, Appointment Management
and Admin Integration. Record each member's actual contribution to these
shared areas.

Coordinate changes to shared files with the relevant members. Review and
test changes before merging them into main.

## GitHub Contribution Workflow

1. Each member uses their own GitHub account and assigned branch.
2. Make and test changes related to the assigned responsibility.
3. Commit actual changes with clear, accurate messages.
4. Push the branch and open a pull request targeting main.
5. Have another team member review the changes before merging.
6. Update the contribution evidence table with the relevant commits,
   pull requests and test results.

The initial project import is a baseline commit. Creating branches does
not create individual implementation evidence.

Preserve the existing Git history. Do not fabricate authorship or
backdate commits. Each member must explain the backend work they
actually contributed to or reviewed.

## Exporting Repository History

Run these commands from the project directory when preparing submission
evidence:

    git log --all --date=short --pretty=format:"%h %ad %an %s" > commit-history.txt
    git shortlog -sne --all > contributors.txt

These reports show the history available in the local repository.
A ZIP archive alone does not verify individual contributions.