# KormoBD - Full Application Flow Chart

## 1. Authentication Flow

```mermaid
flowchart TD
    Start([User Opens App]) --> CheckAuth{Authenticated?}
    CheckAuth -->|No| LoginReg[Login/Registration Screen]
    CheckAuth -->|Yes| RoleCheck{User Role?}
    
    LoginReg --> SelectRole{Select Role}
    SelectRole -->|Employer| EmpReg[Register as Employer]
    SelectRole -->|Worker| WorkerReg[Register as Worker]
    SelectRole -->|Admin| AdminReg[Admin Access]
    
    EmpReg --> EmpProfile[Create Employer Profile]
    WorkerReg --> WorkerProfile[Create Worker Profile]
    AdminReg --> AdminDash[Admin Dashboard]
    
    EmpProfile --> EmpDash[Employer Dashboard]
    WorkerProfile --> WorkerDash[Worker Dashboard]
    
    RoleCheck -->|Employer| EmpDash
    RoleCheck -->|Worker| WorkerDash
    RoleCheck -->|Admin| AdminDash
```

## 2. Complete User Journey - Worker Flow

```mermaid
flowchart TD
    WorkerLogin([Worker Login]) --> WorkerDash[Worker Dashboard]
    
    WorkerDash --> BrowseJobs{Browse Jobs}
    WorkerDash --> ManageProfile{Manage Profile}
    WorkerDash --> ViewApplications{View Applications}
    WorkerDash --> Messaging{Messaging}
    
    BrowseJobs --> JobList[View Job Listings]
    JobList --> Filter[Filter by Type/Location]
    Filter --> ViewDetails[View Job Details]
    ViewDetails --> DecideApply{Apply to Job?}
    
    DecideApply -->|Yes| SubmitApp[Submit Application]
    SubmitApp --> AppSubmitted[Application Sent]
    AppSubmitted --> JobList
    DecideApply -->|No| JobList
    
    ManageProfile --> EditProfile[Edit Profile Info]
    EditProfile --> UpdatePhoto[Upload/Update Photo]
    UpdatePhoto --> UpdateExp[Update Experience]
    UpdateExp --> SaveProfile[Save Changes]
    SaveProfile --> WorkerDash
    
    ViewApplications --> AppList[View Application List]
    AppList --> CheckStatus{Check Status}
    CheckStatus -->|Pending| Waiting[Waiting for Response]
    CheckStatus -->|Approved| Approved[Application Approved!]
    CheckStatus -->|Rejected| Rejected[Application Rejected]
    
    Approved --> ContactEmployer[Contact Employer]
    ContactEmployer --> WorkerDash
    
    Messaging --> ChatList[View Chat List]
    ChatList --> OpenChat[Open Chat with Employer]
    OpenChat --> SendMsg[Send/Receive Messages]
    SendMsg --> Messaging
```

## 3. Complete User Journey - Employer Flow

```mermaid
flowchart TD
    EmpLogin([Employer Login]) --> EmpDash[Employer Dashboard]
    
    EmpDash --> PostJob{Post New Job}
    EmpDash --> ManageJobs{Manage Jobs}
    EmpDash --> ReviewApps{Review Applications}
    EmpDash --> Messaging{Messaging}
    
    PostJob --> JobForm[Fill Job Details]
    JobForm --> FillInfo[Title, Type, Wage, Location]
    FillInfo --> SetRequire[Set Requirements]
    SetRequire --> PublishJob[Publish Job]
    PublishJob --> JobPublished[Job Published]
    JobPublished --> JobList[Job Listings]
    
    ManageJobs --> JobList
    JobList --> SelectJob{Select Job}
    SelectJob --> ViewDetails[View Job Details]
    ViewDetails --> Options{Action?}
    Options -->|View Applicants| AppList[View Applicants]
    Options -->|Edit| EditJob[Edit Job]
    Options -->|Close| CloseJob[Close Job]
    
    EditJob --> UpdateJob[Update Details]
    UpdateJob --> SaveJob[Save Changes]
    SaveJob --> ViewDetails
    
    CloseJob --> Confirm[Confirm Closure]
    Confirm --> JobList
    
    ReviewApps --> AllApps[View All Applications]
    AllApps --> ReviewApp{Review Application}
    ReviewApp --> ViewWorker[View Worker Profile]
    ViewWorker --> AppOptions{Action?}
    AppOptions -->|Approve| ApproveApp[Approve Application]
    AppOptions -->|Reject| RejectApp[Reject Application]
    AppOptions -->|Contact Worker| MessagingFlow[Open Messaging]
    
    ApproveApp --> Approved[Application Approved]
    RejectApp --> Rejected[Application Rejected]
    Approved --> AllApps
    Rejected --> AllApps
    
    Messaging --> ChatList[View Chat with Workers]
    ChatList --> OpenChat[Open Chat]
    OpenChat --> SendMsg[Send/Receive Messages]
    SendMsg --> Messaging
```

## 4. Complete User Journey - Admin Flow

```mermaid
flowchart TD
    AdminLogin([Admin Login]) --> AdminDash[Admin Dashboard]
    
    AdminDash --> ManageUsers{Manage Users}
    AdminDash --> ApproveContent{Approve Content}
    AdminDash --> ViewReports{View Reports}
    AdminDash --> SystemSettings{System Settings}
    
    ManageUsers --> UserList[View All Users]
    UserList --> FilterUsers[Filter by Type/Status]
    FilterUsers --> SelectUser{Select User}
    SelectUser --> UserDetails[View User Details]
    UserDetails --> UserActions{Action?}
    UserActions -->|Approve| ApproveUser[Approve User]
    UserActions -->|Reject| RejectUser[Reject User]
    UserActions -->|Suspend| SuspendUser[Suspend User]
    UserActions -->|Verify| VerifyUser[Verify User]
    
    ApproveUser --> Updated[User Updated]
    RejectUser --> Updated
    SuspendUser --> Updated
    VerifyUser --> Updated
    Updated --> UserList
    
    ApproveContent --> PendingJobs[Review Pending Jobs]
    PendingJobs --> ReviewJob[Review Job Posting]
    ReviewJob --> JobCheck{Appropriate?}
    JobCheck -->|Yes| ApproveJob[Approve Job]
    JobCheck -->|No| RejectJob[Reject Job]
    
    ApproveJob --> JobUpdated[Job Status Updated]
    RejectJob --> JobUpdated
    JobUpdated --> PendingJobs
    
    ViewReports --> Analytics[View Statistics]
    Analytics --> UserCount[Total Users]
    UserCount --> StatsView[View Job Postings]
    StatsView --> AppCount[View Applications]
    AppCount --> RevenueReport[View Other Metrics]
    
    SystemSettings --> Settings[Configuration]
    Settings --> SettingsOptions{Settings}
    SettingsOptions -->|Job Types| EditTypes[Edit Job Types]
    SettingsOptions -->|Pricing| EditPricing[Edit Pricing]
    SettingsOptions -->|Notifications| NotifSettings[Notification Settings]
    
    EditTypes --> AdminDash
    EditPricing --> AdminDash
    NotifSettings --> AdminDash
```

## 5. Application Status Lifecycle

```mermaid
flowchart LR
    Start([Worker Applies]) --> PendingA[PENDING]
    
    PendingA -->|Employer Reviews| DecisionPoint{Employer Decision}
    
    DecisionPoint -->|Approved| ApprovedA[APPROVED]
    DecisionPoint -->|Rejected| RejectedA[REJECTED]
    DecisionPoint -->|Needs Info| PendingA
    
    ApprovedA -->|Worker Accepts| Accepted[ACCEPTED]
    ApprovedA -->|Worker Rejects| RejectedA
    
    Accepted -->|Work Complete| Completed[COMPLETED]
    
    Completed --> End([End])
    RejectedA --> End
    
    style PendingA fill:#FFF9C4
    style ApprovedA fill:#C8E6C9
    style RejectedA fill:#FFCDD2
    style Accepted fill:#B2DFDB
    style Completed fill:#A5D6A7
```

## 6. Job Status Lifecycle

```mermaid
flowchart LR
    Create([Employer Creates]) --> DraftA[DRAFT]
    
    DraftA -->|Submit for Review| PendingReview[PENDING REVIEW]
    
    PendingReview -->|Admin Approves| PublishedA[PUBLISHED]
    PendingReview -->|Admin Rejects| DraftA
    
    PublishedA -->|Workers Apply| ActiveA[ACTIVE]
    
    ActiveA -->|All Positions Filled| FilledA[FILLED]
    ActiveA -->|Employer Closes| ClosedA[CLOSED]
    
    FilledA -->|Work Complete| CompletedA[COMPLETED]
    ClosedA --> EndA([End])
    CompletedA --> EndA
    
    style DraftA fill:#FFF9C4
    style PendingReview fill:#FFE082
    style PublishedA fill:#FFB74D
    style ActiveA fill:#C8E6C9
    style FilledA fill:#B2DFDB
    style CompletedA fill:#A5D6A7
```

## 7. Data Flow Architecture

```mermaid
flowchart TB
    subgraph Client["Mobile Client (Flutter/Dart)"]
        UI["UI Screens"]
        Controllers["Controllers & State Management"]
        Models["Local Models"]
    end
    
    subgraph Services["Business Logic Layer"]
        Auth["Auth Service"]
        JobService["Job Service"]
        WorkerService["Worker Service"]
        ChatService["Chat Service"]
        AdminService["Admin Service"]
    end
    
    subgraph Database["Firebase Backend"]
        Firestore["Firestore Database"]
        Storage["Cloud Storage"]
        Auth_FB["Firebase Auth"]
    end
    
    subgraph External["External Services"]
        Maps["Google Maps API"]
        Notifications["Push Notifications"]
    end
    
    UI --> Controllers
    Controllers --> Models
    Models --> Services
    
    Auth --> Auth_FB
    JobService --> Firestore
    WorkerService --> Firestore
    ChatService --> Firestore
    AdminService --> Firestore
    
    JobService --> Storage
    WorkerService --> Storage
    
    Services --> Maps
    Services --> Notifications
    
    style Client fill:#E3F2FD
    style Services fill:#F3E5F5
    style Database fill:#FFF3E0
    style External fill:#F1F8E9
```

## 8. Key Features Summary

| Feature | Worker | Employer | Admin |
|---------|--------|----------|-------|
| Browse & Filter Jobs | ✓ | - | - |
| Apply to Jobs | ✓ | - | - |
| Track Applications | ✓ | - | - |
| Manage Profile | ✓ | - | - |
| Post New Jobs | - | ✓ | - |
| Manage Job Postings | - | ✓ | - |
| Review Applications | - | ✓ | - |
| Accept/Reject Applicants | - | ✓ | - |
| Real-time Chat | ✓ | ✓ | - |
| View All Users | - | - | ✓ |
| Approve/Reject Users | - | - | ✓ |
| Approve Job Postings | - | - | ✓ |
| View Analytics | - | - | ✓ |
| System Settings | - | - | ✓ |
