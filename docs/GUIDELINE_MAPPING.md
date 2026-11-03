# SE1020 guideline mapping

| Criterion | Code/evidence | Team action still required |
|---|---|---|
| Assigned CRUD (30) | Patient, doctor/schedule, appointment, medical-record and team-account CRUD; billing create/read/update through payment | Each member demonstrates at least their required three operations |
| OOP (20) | Person inheritance/overrides; private model fields; DAO abstraction and FILE/DB polymorphism; AbstractFileDAO<T>; state enum | Explain actual code, not just definitions |
| File handling (10) | Escaped UTF-8 TSV, read/write, atomic replacement, shared locking, in-process multi-file rollback; legacy invoice compatibility test | Run a FILE demo and open corresponding data files |
| UI (10) | Separate patient/team entrances, role-aware views, forms, validation, tables, notifications, live invoice preview and print | Demonstrate on desktop and mobile |
| Contribution/GitHub (10) | TEAM_CONTRIBUTIONS.md template and honest history instructions | Real names/IDs, repository URL and real member commits |
| Viva (10) | DEMO_WALKTHROUGH.md | Every member explains their backend and flow |
| Documentation (10) | Updated CLASS_DIAGRAM.md, TECHNICAL_REPORT.md, test evidence, DB migration and startup instructions | Add real team/repository evidence and export report if your submission requires PDF |

The description permits SQL/DB in its storage line, while the marking sheet explicitly lists file handling. Both modes are retained; show FILE behavior in viva. The description also names Spring Boot in one place and JSP/Servlets in another. This application is explicitly Servlet/JSP; do not describe it as Spring Boot. Confirm any course-specific technology interpretation with the lecturer.

There are at least three interface states/pages in each component: patient add/list/view/edit; doctor add/list/view/edit/availability; appointment book/list/edit/cancel; medical-record add/list/edit/print; billing create/list/print plus notifications; administration login/dashboard/list/form.
