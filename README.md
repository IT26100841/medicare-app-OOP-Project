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

## Documentation hub

Browse [all project documents](docs/) or open a guide below.

| Document | What you will find |
| --- | --- |
| [Project manual](docs/PROJECT_MANUAL.md) | Installation, configuration, and user guide |
| [Complete UML diagrams](docs/UML_DIAGRAMS.md) | Use cases, class design, sequence diagrams, and appointment states |
| [Class diagram and OOP design](docs/CLASS_DIAGRAM.md) | Classes, relationships, and OOP architecture |
| [Technical report](docs/TECHNICAL_REPORT.md) | Implementation and technical details |
| [Database migration](docs/DB_MIGRATION.md) | Database setup and migration instructions |
| [Demo walkthrough](docs/DEMO_WALKTHROUGH.md) | Demonstration steps |
| [Guideline mapping](docs/GUIDELINE_MAPPING.md) | Coursework requirement mapping |
| [Team tasks](docs/TEAM-TASKS.md) | Workload and task distribution |
| [Team contributions](docs/TEAM_CONTRIBUTIONS.md) | Team contribution documentation |
| [GitHub contributions](docs/GITHUB_CONTRIBUTIONS.md) | Contribution tracking guidance |
| [Git workflow](docs/GIT-WORKFLOW.md) | Branch and collaboration workflow |
| [Test results](docs/TEST_RESULTS.md) | Supplied test report |
| [Patient portal tests](docs/PATIENT_PORTAL_TESTS.md) | Supplied patient portal test notes |
| [ZIP update notes](docs/ZIP_UPDATE_NOTES.md) | Changes included in the project distribution |

## UML diagrams

The diagrams below are taken from [the complete UML document](docs/UML_DIAGRAMS.md). Expand a diagram to view it here.

<details>
<summary>Use Case Diagram</summary>

```mermaid
flowchart LR
    subgraph Actors
        P["👤 Patient"]
        D["👨‍⚕️ Doctor"]
        R["🧑‍💼 Receptionist / Staff"]
        A["🛡️ Administrator"]
    end

    subgraph SystemBoundary ["Medicare Hospital Management System"]
        UC_Reg["Register Account"]
        UC_Login["Login / Authenticate"]
        UC_ViewSlots["View Available Doctors & Sessions"]
        UC_BookApp["Book Appointment"]
        UC_CancelApp["Cancel Own Appointment"]
        UC_ViewNotif["View Notifications"]
        UC_ManagePatient["Manage Patients (CRUD)"]
        UC_CheckIn["Check-in Patient Arrival"]
        UC_StartConsult["Start Consultation"]
        UC_AddRecord["Add Clinical Record & Prescription"]
        UC_CompleteVisit["Complete Visit"]
        UC_CreateBill["Generate Invoice & Additional Charges"]
        UC_RecordPay["Record Payment & Print Invoice"]
        UC_ManageDoc["Manage Doctors & Published Schedules"]
        UC_ManageUsers["Manage Staff & Link Doctor Accounts"]
        UC_ViewAudit["View Audit Logs & System Settings"]
    end

    %% Patient associations
    P --> UC_Reg
    P --> UC_Login
    P --> UC_ViewSlots
    P --> UC_BookApp
    P --> UC_CancelApp
    P --> UC_ViewNotif

    %% Receptionist associations
    R --> UC_Login
    R --> UC_ManagePatient
    R --> UC_CheckIn
    R --> UC_ViewSlots
    R --> UC_BookApp
    R --> UC_CreateBill
    R --> UC_RecordPay

    %% Doctor associations
    D --> UC_Login
    D --> UC_StartConsult
    D --> UC_AddRecord
    D --> UC_CompleteVisit

    %% Administrator associations
    A --> UC_Login
    A --> UC_ManageDoc
    A --> UC_ManageUsers
    A --> UC_ViewAudit
    A --> UC_ManagePatient

    %% Dependencies
    UC_BookApp -.->|<<include>>| UC_ViewSlots
    UC_CompleteVisit -.->|<<include>>| UC_AddRecord
    UC_CreateBill -.->|<<extend>>| UC_RecordPay
```

</details>

<details>
<summary>Complete System Class Diagram (OOP Design)</summary>

```mermaid
classDiagram
    %% Inheritance hierarchy
    Person <|-- Patient
    Person <|-- Doctor
    Person <|-- User

    %% DAO Inheritance and Realization
    AbstractFileDAO <|-- PatientDAOFileImpl
    AbstractFileDAO <|-- DoctorDAOFileImpl
    AbstractFileDAO <|-- AppointmentDAOFileImpl
    AbstractFileDAO <|-- MedicalRecordDAOFileImpl
    AbstractFileDAO <|-- BillDAOFileImpl
    AbstractFileDAO <|-- NotificationDAOFileImpl
    AbstractFileDAO <|-- UserDAOFileImpl

    PatientDAO <|.. PatientDAOFileImpl
    PatientDAO <|.. PatientDAODBImpl
    DoctorDAO <|.. DoctorDAOFileImpl
    DoctorDAO <|.. DoctorDAODBImpl
    AppointmentDAO <|.. AppointmentDAOFileImpl
    AppointmentDAO <|.. AppointmentDAODBImpl
    MedicalRecordDAO <|.. MedicalRecordDAOFileImpl
    MedicalRecordDAO <|.. MedicalRecordDAODBImpl
    BillDAO <|.. BillDAOFileImpl
    BillDAO <|.. BillDAODBImpl
    NotificationDAO <|.. NotificationDAOFileImpl
    NotificationDAO <|.. NotificationDAODBImpl
    UserDAO <|.. UserDAOFileImpl
    UserDAO <|.. UserDAODBImpl

    %% Factory and Services
    DAOFactory ..> PatientDAO : creates
    DAOFactory ..> DoctorDAO : creates
    DAOFactory ..> AppointmentDAO : creates
    DAOFactory ..> MedicalRecordDAO : creates
    DAOFactory ..> BillDAO : creates
    DAOFactory ..> NotificationDAO : creates
    DAOFactory ..> UserDAO : creates

    PatientService --> PatientDAO
    DoctorService --> DoctorDAO
    AppointmentService --> AppointmentDAO
    AppointmentService --> ScheduleService
    ScheduleService --> ClinicStore
    MedicalRecordService --> MedicalRecordDAO
    BillingService --> BillDAO
    VisitService --> AppointmentService
    VisitService --> MedicalRecordService
    PatientPortalService --> AppointmentService
    PatientPortalService --> PatientService
    AccountService --> UserDAO
    AccountService --> DoctorDAO

    %% Model relationships
    Appointment --> AppointmentStatus : has status
    Appointment --> Patient : patientId
    Appointment --> Doctor : doctorId
    MedicalRecord --> Appointment : appointmentId
    Bill --> Appointment : appointmentId

    class Person {
        <<abstract>>
        +getName()* String
        +getEmail()* String
        +getRoleLabel()* String
        +getDisplayName() String
    }

    class Patient {
        -String id
        -String name
        -String email
        -int age
        -String gender
        -String contact
        -String address
        -String medicalHistory
        +getRoleLabel() String
        +getId() String
        +getMedicalHistory() String
    }

    class Doctor {
        -String id
        -String name
        -String specialization
        -String qualification
        -String phone
        -String email
        -double consultationFee
        +getRoleLabel() String
        +getId() String
        +getSpecialization() String
        +getConsultationFee() double
    }

    class User {
        -int id
        -String username
        -String password
        -String role
        -String name
        -String email
        +getRoleLabel() String
        +getId() int
        +getUsername() String
        +getRole() String
    }

    class Appointment {
        -int appointmentId
        -String patientId
        -String doctorId
        -String appointmentDate
        -String appointmentTime
        -String reason
        -String status
        +getAppointmentId() int
        +getStatus() String
        +setStatus(String) void
    }

    class AppointmentStatus {
        <<enumeration>>
        BOOKED
        CHECKED_IN
        IN_CONSULTATION
        COMPLETED
        CANCELLED
        NO_SHOW
        +canMoveTo(AppointmentStatus) boolean
        +reservesSlot() boolean
        +label() String
    }

    class MedicalRecord {
        -int recordId
        -String patientId
        -String doctorId
        -int appointmentId
        -String diagnosis
        -String prescription
        -String notes
        -String recordDate
        +getRecordId() int
        +getPrescription() String
        +getDiagnosis() String
    }

    class Bill {
        -int billId
        -int appointmentId
        -String patientId
        -double amount
        -double consultationCharge
        -double hospitalCharge
        -double treatmentCharge
        -String paymentMethod
        -String paymentStatus
        +getAmount() double
        +getHospitalCharge() double
        +getTreatmentCharge() double
        +getPaymentStatus() String
    }

    class Notification {
        -int notificationId
        -String patientId
        -String message
        -String date
        +getMessage() String
    }

    class AbstractFileDAO {
        <<abstract>>
        #readAll() List
        #writeAll(List) boolean
        #insert(Object) boolean
        #replace(Object, Predicate) boolean
        #remove(Predicate) boolean
    }

    class DAOFactory {
        +getPatientDAO() PatientDAO$
        +getDoctorDAO() DoctorDAO$
        +getAppointmentDAO() AppointmentDAO$
        +getMedicalRecordDAO() MedicalRecordDAO$
        +getBillDAO() BillDAO$
        +getUserDAO() UserDAO$
        +getNotificationDAO() NotificationDAO$
    }
```

</details>

<details>
<summary>Sequence Diagram 1: Patient Self-Service Appointment Booking</summary>

```mermaid
sequenceDiagram
    autonumber
    actor Patient as 👤 Patient
    participant PortalServlet as PatientPortalServlet
    participant PortalService as PatientPortalService
    participant AppService as AppointmentService
    participant ScheduleService as ScheduleService
    participant AppDAO as AppointmentDAO
    participant NotifDAO as NotificationDAO
    participant Storage as Database / File Store

    Patient->>PortalServlet: POST /portal?action=book (doctorId, date, slot, reason)
    PortalServlet->>PortalService: bookAppointment(patientId, doctorId, date, slot, reason)
    PortalService->>ScheduleService: isSlotAvailable(doctorId, date, slot)
    ScheduleService->>Storage: check availability & existing bookings
    Storage-->>ScheduleService: slot is available
    ScheduleService-->>PortalService: true

    PortalService->>AppService: createAppointment(appointment)
    AppService->>AppDAO: saveAppointment(appointment)
    AppDAO->>Storage: INSERT into appointments (Status: 'Booked')
    Storage-->>AppDAO: appointment saved (ID generated)

    AppService->>NotifDAO: saveNotification(new Notification(patientId, "Booked with Dr..."))
    NotifDAO->>Storage: INSERT notification
    Storage-->>NotifDAO: notification saved
    AppService-->>PortalService: Booking Successful
    PortalService-->>PortalServlet: Result Success
    PortalServlet-->>Patient: Redirect /portal?msg=Booked+Successfully (renders updated appointments & notification)
```

</details>

<details>
<summary>Sequence Diagram 2: Clinical Consultation & Billing Workflow</summary>

```mermaid
sequenceDiagram
    autonumber
    actor Reception as 🧑‍💼 Receptionist
    actor Doctor as 👨‍⚕️ Doctor
    participant WorkflowServlet as WorkflowServlet / BillServlet
    participant VisitService as VisitService
    participant MedService as MedicalRecordService
    participant BillService as BillingService
    participant AppDAO as AppointmentDAO
    participant MedDAO as MedicalRecordDAO
    participant BillDAO as BillDAO
    participant Storage as Database / File Store

    %% Check-in
    Reception->>WorkflowServlet: POST /workflow (action=checkin, apptId)
    WorkflowServlet->>VisitService: checkIn(apptId)
    VisitService->>AppDAO: updateStatus(apptId, CHECKED_IN)
    AppDAO->>Storage: UPDATE status = 'Checked-in'
    Storage-->>AppDAO: updated

    %% Consultation & Notes
    Doctor->>WorkflowServlet: POST /workflow (action=start, apptId)
    WorkflowServlet->>VisitService: startConsultation(apptId)
    VisitService->>AppDAO: updateStatus(apptId, IN_CONSULTATION)
    AppDAO->>Storage: UPDATE status = 'In consultation'

    Doctor->>WorkflowServlet: POST /workflow (action=complete, diagnosis, rx, notes)
    WorkflowServlet->>MedService: saveRecord(MedicalRecord)
    MedService->>MedDAO: insert(record)
    MedDAO->>Storage: INSERT into medical_records
    Storage-->>MedDAO: success
    WorkflowServlet->>VisitService: completeVisit(apptId)
    VisitService->>AppDAO: updateStatus(apptId, COMPLETED)
    AppDAO->>Storage: UPDATE status = 'Completed'

    %% Billing
    Reception->>WorkflowServlet: POST /bill (apptId, hospitalCharge, treatmentCharge)
    WorkflowServlet->>BillService: generateBill(apptId, hospitalCharge, treatmentCharge)
    BillService->>Storage: fetch doctor consultation fee
    Storage-->>BillService: fee = Rs. 2000.00
    Note over BillService: total = consultFee + hospitalCharge + treatmentCharge
    BillService->>BillDAO: saveBill(Bill)
    BillDAO->>Storage: INSERT into bills
    Storage-->>BillDAO: bill created
    BillService-->>WorkflowServlet: Bill Generated
    WorkflowServlet-->>Reception: Show Printable Invoice
```

</details>

<details>
<summary>State Machine Diagram: Appointment Lifecycle</summary>

```mermaid
stateDiagram-v2
    [*] --> BOOKED : Patient books / Reception books

    BOOKED --> CHECKED_IN : Receptionist checks-in patient upon arrival
    BOOKED --> CANCELLED : Patient cancels / Reception cancels
    BOOKED --> NO_SHOW : Patient failed to attend

    CHECKED_IN --> IN_CONSULTATION : Mapped Doctor starts consultation
    CHECKED_IN --> CANCELLED : Cancelled before consultation

    IN_CONSULTATION --> COMPLETED : Doctor records diagnosis/Rx and completes visit

    COMPLETED --> [*] : Bill Invoiced and Paid
    CANCELLED --> [*] : Slot released
    NO_SHOW --> [*] : Slot released
```

</details>

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
