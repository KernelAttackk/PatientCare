# Architecture Notes

## Overview

PatientCare Desktop is intentionally structured as a small layered VCL application.

The main goal is to keep UI code, database access and database initialization separated enough that the application can be extended without turning the forms into large monolithic units.

```text
┌───────────────────────────────┐
│           VCL Forms           │
│                               │
│ MainForm                      │
│ PatientEditForm               │
│ AppointmentsForm              │
│ AppointmentEditForm           │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│          Repositories         │
│                               │
│ PatientRepository             │
│ AppointmentRepository         │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│       DatabaseManager         │
│                               │
│ Connection lifecycle          │
│ Schema initialization         │
│ Demo data generation          │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│           FireDAC             │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│            SQLite             │
└───────────────────────────────┘
```

---

## DatabaseManager

`TDatabaseManager` owns the FireDAC SQLite connection.

Its responsibilities include:

* Connection configuration
* Opening the database
* Schema creation
* Index creation
* Demo data initialization

The forms and repositories receive the same connection rather than creating independent connections.

This keeps connection lifecycle management centralized.

---

## Repository Layer

Database operations are separated into repositories.

### PatientRepository

Responsible for:

* Patient search
* Patient lookup
* Patient creation
* Patient updates
* Patient deletion
* Patient-related queries

### AppointmentRepository

Responsible for:

* Loading appointments for a patient
* Creating appointments
* Updating appointments
* Deleting appointments

The repository approach keeps SQL out of the majority of UI code and gives each entity a clear database access boundary.

---

## Forms

The application uses several focused VCL forms.

### MainForm

Provides:

* Patient search
* Patient list
* Patient creation
* Patient editing
* Patient deletion

### PatientEditForm

Provides:

* Patient editing
* Patient validation
* Access to patient appointments

### AppointmentsForm

Provides:

* Appointment list
* Appointment creation
* Appointment editing
* Appointment deletion

### AppointmentEditForm

Provides:

* Appointment editing
* Date/time selection
* Doctor information
* Notes

The separation makes individual forms easier to understand and maintain.

---

## Transactions

Database mutations use explicit transactions.

```text
StartTransaction
       │
       ▼
   Execute SQL
       │
       ├──────────────┐
       │              │
    Success          Error
       │              │
       ▼              ▼
    Commit         Rollback
```

This is especially important when extending CRUD operations into multi-step operations.

---

## SQL

Queries use parameters rather than concatenating user input into SQL.

Example:

```pascal
Q.SQL.Text :=
  'SELECT ... ' +
  'FROM Patients ' +
  'WHERE LastName LIKE :Search';

Q.ParamByName('Search').AsString := '%' + ASearch + '%';
```

This avoids SQL injection issues and also allows FireDAC/database engines to handle parameters correctly.

---

## SQLite Configuration

SQLite is configured with WAL journal mode and normal synchronous operation.

The configuration is intended for a local desktop demonstration where:

* The database is local
* There is a single application instance
* Data is stored on the workstation
* A lightweight embedded database is sufficient

A production system with multiple users would require different database and deployment considerations.

---

## Demo Dataset

The application generates 100,000 patient records when the database is empty.

This serves two purposes:

1. Demonstrates database initialization.
2. Provides a meaningful dataset for testing search and grid performance.

The application does not load all patients into memory before filtering. Filtering and limiting are performed by SQL.

---

## Maintainability

The project deliberately favors straightforward Delphi/VCL patterns over unnecessary abstraction.

There is no large dependency-injection framework, ORM or complex infrastructure layer.

The intended structure is easy for an experienced Delphi developer to understand:

```text
Form
 ↓
Repository
 ↓
FireDAC
 ↓
SQLite
```

This is particularly useful when working with established Windows desktop codebases where maintainability and incremental modernization are often more important than introducing a completely new architecture.

---

## Possible Production Extensions

The current project intentionally stops short of production healthcare functionality.

Possible future extensions could include:

* Authentication and authorization
* User/role management
* Audit logging
* Structured application logging
* Configuration management
* Database migrations
* Automated tests
* Repository interfaces
* Service layer for complex business workflows
* Background operations for long-running tasks
* Windows API integration
* Reporting
* Printing
* Export/import
* Enterprise database support such as SQL Server or Oracle

These are intentionally outside the scope of this demonstration.
