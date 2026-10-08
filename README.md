# PatientCare Desktop

A small Windows desktop application built with **Delphi / Object Pascal and VCL**, designed as a technical demonstration of desktop application development practices.

The project simulates a simplified healthcare-oriented patient management system with patients and appointments.

> **Important:** This is a demonstration project created to showcase architecture, database integration, VCL development, SQL, transactions and maintainable Windows desktop code. It is **not a production medical system** and must not be used to store real patient or healthcare data.

---

## Features

### Patient Management

* Create patients
* Edit patients
* Delete patients
* Search patients
* Display patient information in a VCL `TDBGrid`
* Appointment count per patient
* Validation of required fields
* Validation of date of birth

### Appointment Management

* View appointments for a selected patient
* Create appointments
* Edit appointments
* Delete appointments
* Double-click to edit
* Doctor name and notes
* Date/time validation

### Database

* SQLite database
* FireDAC database access
* Parameterized SQL queries
* Explicit database transactions
* Foreign key relationship between patients and appointments
* Database indexes
* WAL journal mode
* Automatic database/schema creation
* Automatic generation of demo data

The application can generate **100,000 demo patients** on first launch to demonstrate searching and working with a relatively large dataset.

---

## Technology Stack

* **Delphi / Object Pascal**
* **VCL**
* **FireDAC**
* **SQLite**
* SQL
* Windows desktop application architecture

---

## Architecture

The project intentionally avoids putting all application logic inside the forms.

The simplified architecture is:

```text
                    VCL Forms
                        │
                        ▼
              Application / UI Logic
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
      PatientRepository    AppointmentRepository
             │                     │
             └──────────┬──────────┘
                        ▼
                 TDatabaseManager
                        │
                        ▼
                     FireDAC
                        │
                        ▼
                     SQLite
```

### DatabaseManager

`TDatabaseManager` is responsible for:

* Creating the FireDAC connection
* Configuring SQLite
* Opening the database
* Creating the database schema
* Creating indexes
* Generating initial demo data
* Providing the shared database connection

### Repositories

Database access is separated into repository classes:

```text
TPatientRepository
TAppointmentRepository
```

The repositories contain SQL and database operations instead of placing database code throughout the UI.

### Forms

The VCL forms are responsible primarily for:

* User interaction
* Input validation
* Displaying data
* Opening child forms
* Calling repository operations

This keeps database access and UI responsibilities separated.

---

## Database Schema

### Patients

```sql
Patients
--------
Id
FirstName
LastName
DateOfBirth
Phone
Email
CreatedAt
```

### Appointments

```sql
Appointments
------------
Id
PatientId
AppointmentDate
DoctorName
Notes
```

Relationship:

```text
Patients
   │
   │ 1
   │
   │ N
   ▼
Appointments
```

`Appointments.PatientId` references `Patients.Id`.

Indexes are used for commonly queried fields such as patient name, date of birth, patient ID and appointment date.

---

## Transactions

Create, update and delete operations use explicit database transactions.

Example:

```text
StartTransaction
      │
      ▼
 Execute SQL
      │
      ├── Success ──► Commit
      │
      └── Error ────► Rollback
```

This demonstrates basic transactional integrity and provides a foundation for extending the application with more complex multi-step operations.

---

## Performance Considerations

The application intentionally creates a relatively large demo dataset.

The first startup can generate:

```text
100,000 patients
```

The patient search uses:

* Parameterized queries
* Database indexes
* Result limiting
* SQL-side filtering
* A shared FireDAC connection

The UI also reports basic query timing and result information.

The goal is not to build a benchmark application, but to demonstrate that the application architecture is designed with larger datasets in mind rather than only a handful of records.

---

## Error Handling

Database operations use exception handling and transaction rollback.

For example:

```pascal
try
  FConnection.StartTransaction;

  // Database operation

  FConnection.Commit;
except
  FConnection.Rollback;
  raise;
end;
```

UI-level errors are presented to the user through VCL dialogs while lower-level exceptions can propagate to the appropriate layer.

---

## Demo Database

The database file is created automatically next to the executable:

```text
patientcare.db
```

It is intentionally **not included in the repository**.

On first startup the application:

1. Creates the SQLite database
2. Creates the schema
3. Creates indexes
4. Generates demo patients
5. Starts the application

This keeps the repository small and makes the demo reproducible.

---

## Running the Project

### Requirements

* Windows
* Delphi with VCL and FireDAC support
* SQLite support provided by FireDAC

### Steps

1. Clone the repository.
2. Open `PatientCare.dpr` in Delphi.
3. Build the project.
4. Run the application.

The SQLite database will be created automatically.

---

## Project Structure

```text
PatientCare
│
├── PatientCare.dpr
│
├── MainFormUnit.pas
├── MainFormUnit.dfm
│
├── DatabaseManager.pas
│
├── PatientRepository.pas
│
├── AppointmentRepository.pas
│
├── PatientForm.pas
├── PatientForm.dfm
│
├── AppointmentForm.pas
├── AppointmentForm.dfm
│
├── AppointmentsForm.pas
└── AppointmentsForm.dfm
```

---

## What This Project Demonstrates

This project was created primarily as a technical demonstration and focuses on the following areas:

* Delphi / Object Pascal
* VCL desktop application development
* FireDAC
* SQLite
* SQL
* Repository pattern
* Database transactions
* Parameterized SQL
* CRUD operations
* Form lifecycle management
* Separation of UI and data access
* Working with larger datasets
* Input validation
* Exception handling
* Maintainable legacy-friendly Windows desktop architecture

The project is intentionally small enough to understand quickly while still demonstrating patterns applicable to larger production applications.

---

## Disclaimer

This project is a technical demonstration only.

It does not implement:

* Real healthcare workflows
* Medical records compliance
* Authentication
* Authorization
* Audit logging
* Encryption
* HIPAA/GDPR healthcare-specific controls
* Production backup/recovery
* Multi-user concurrency requirements

**Do not use the application with real patient data.**

---

## License

This project is provided for demonstration and educational purposes.
