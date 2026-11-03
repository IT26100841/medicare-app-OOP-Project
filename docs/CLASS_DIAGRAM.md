# Current class and relationship diagrams

These are scoped diagrams; ID links below are logical associations, not Java collection fields.

```mermaid
classDiagram
    Person <|-- Patient
    Person <|-- Doctor
    Person <|-- User
    class Person {
        <<abstract>>
        +getName() String
        +getEmail() String
        +getRoleLabel() String
        +getDisplayName() String
    }
    class Patient {
        -String id
        -String name
        -String email
        -String medicalHistory
    }
    class Doctor {
        -String id
        -String specialization
        -double consultationFee
    }
    class User {
        -int id
        -String username
        -String password
        -String role
    }
```

```mermaid
classDiagram
    PatientDAO <|.. PatientDAOFileImpl
    PatientDAO <|.. PatientDAODBImpl
    AbstractFileDAO <|-- PatientDAOFileImpl
    class PatientDAO {
        <<interface>>
        +addPatient(Patient) boolean
        +getAllPatients() List
        +getPatientById(String) Patient
        +updatePatient(Patient) boolean
        +deletePatient(String) boolean
    }
    class AbstractFileDAO {
        <<abstract>>
        #readAll() List
        #writeAll(List) boolean
        #insert(Object) boolean
        #replace(Object, Predicate) boolean
        #remove(Predicate) boolean
    }
```

The same DAO interface/implementation pattern covers doctors, appointments, medical records, billing, users and notifications. DAOFactory chooses the concrete implementation. Servlets call services; AccountService additionally owns transactions spanning account and doctor mapping writes. FileTransactions owns runtime rollback of related FILE changes.

```mermaid
classDiagram
    PatientPortalServlet --> PatientPortalService
    PatientPortalService --> PatientAccount
    PatientPortalService --> Patient
    PatientAccount --> Patient : patientId
    class PatientAccount {
        -String email
        -String patientId
        -String passwordHash
    }
```

PatientAccount is a separate patient login identity; User remains the internal team identity. Public registration creates a new patient profile and login together. PatientPortalService delegates bookings to AppointmentService. Patient-owned notifications are rendered by PatientPortalServlet.

```mermaid
erDiagram
    PATIENT ||--o{ APPOINTMENT : books
    DOCTOR ||--o{ APPOINTMENT : receives
    APPOINTMENT o|--o{ MEDICAL_RECORD : links
    APPOINTMENT ||--o| BILL : invoices
    PATIENT ||--o{ MEDICAL_RECORD : owns
    DOCTOR ||--o{ MEDICAL_RECORD : writes
```

A MedicalRecord has a required patient and doctor and an optional appointment. A visit has zero or more clinical notes, and at most one bill; completion requires a clinical record. Bill also stores its patient ID, checked against the appointment in the application.

```mermaid
classDiagram
    AppointmentService --> ScheduleService
    ScheduleService --> ClinicStore
    VisitService --> AppointmentStatus
    AppointmentService --> AppointmentDAO
    class AppointmentStatus {
        <<enumeration>>
        BOOKED
        CHECKED_IN
        IN_CONSULTATION
        COMPLETED
        CANCELLED
        NO_SHOW
        +canMoveTo(AppointmentStatus) boolean
    }
```

Appointment DAOs save notification events in the same DB transaction or related FILE unit. Booking confirms once; cancellation notifies once when the status changes. Availability and DoctorAccount are linked by doctorId; DoctorAccount additionally links a team userId.

```mermaid
classDiagram
    BillingService --> BillDAO
    BillDAO <|.. BillDAOFileImpl
    BillDAO <|.. BillDAODBImpl
    BillingService --> Bill
    class Bill {
        -int billId
        -int appointmentId
        -String patientId
        -double amount
        -double consultationCharge
        -double hospitalCharge
        -double treatmentCharge
        -String paymentStatus
    }
```

BigDecimal performs validation/addition in BillingService; persisted DECIMAL columns and snapshot fields retain the breakdown. Legacy consultation component defaults to the original stored amount. Payment updates status/method only.
