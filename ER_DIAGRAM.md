# KormoBD - Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ WORKER_PROFILE : "has"
    USER ||--o{ JOB : "creates"
    WORKER_PROFILE ||--o{ APPLICATION : "submits"
    JOB ||--o{ APPLICATION : "receives"
    JOB ||--o{ APPLICANT : "contains"
    ADMIN ||--|| USER : "manages"

    USER {
        string id PK
        string name
        string role "employer/worker/admin"
        string contact
        string status "pending/approved/rejected/active"
    }

    WORKER_PROFILE {
        string id PK
        string name
        int experienceYears
        string jobType
        string contact
        string address
        string photoUrl "optional"
        double latitude "optional"
        double longitude "optional"
        string status "pending/approved/rejected/active"
        boolean verified
    }

    JOB {
        string id PK
        string title
        string employerName
        string employerId FK
        string jobType
        int numWorkers
        string neededBy
        string location
        int wage
        string contact
        string status "pending/active/completed/closed"
        timestamp createdAt
    }

    APPLICATION {
        string jobId FK
        string workerId FK
        string status "pending/approved/rejected"
    }

    APPLICANT {
        string name
        string contact
        string status "pending/approved/rejected"
        object profile "worker snapshot"
    }

    ADMIN {
        string id PK
        string name
        string email
        string role "admin"
    }
```

## Entity Details

### User
- **Primary Key**: id
- **Attributes**: name, role, contact, status
- **Roles**: employer, worker, admin
- **Relationships**: has WorkerProfile, creates Job

### WorkerProfile
- **Primary Key**: id
- **Foreign Key**: Links to User
- **Attributes**: experienceYears, jobType, address, location (lat/lng), photoUrl, verified status
- **Relationships**: submits Application

### Job
- **Primary Key**: id
- **Foreign Key**: employerId (references User)
- **Attributes**: title, jobType, wage, numWorkers, neededBy, location, status
- **Relationships**: receives Applications, contains Applicants

### Application
- **Composite Key**: jobId + workerId
- **Foreign Keys**: jobId (Job), workerId (WorkerProfile)
- **Attributes**: status (pending/approved/rejected)
- **Purpose**: Junction table linking workers to jobs

### Applicant
- **Embedded in**: Job document
- **Attributes**: name, contact, status, worker profile snapshot
- **Purpose**: Denormalized snapshot of worker info for quick access

### Admin
- **Primary Key**: id
- **Attributes**: name, email, role
- **Purpose**: System administrator for approval workflows
