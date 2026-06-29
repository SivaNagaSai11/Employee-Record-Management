# Technical Design Document
## Employee Record Management — SAP ABAP

---

## 1. Overview

This document describes the technical design of the Employee Record Management application built using SAP ABAP core concepts.

---

## 2. System Architecture

```
┌──────────────────────────────────────────────────────┐
│                   SAP ABAP System                    │
│                                                      │
│  ┌────────────────┐      ┌──────────────────────┐   │
│  │  ZEMPLOYEE     │      │   ZEMP_REPORT_ALV    │   │
│  │  _MAIN         │      │  (ALV Grid Report)   │   │
│  │  (Main Program)│      │                      │   │
│  └───────┬────────┘      └──────────┬───────────┘   │
│          │                          │                │
│          ▼                          ▼                │
│  ┌────────────────────────────────────────────────┐  │
│  │           ZEMP_CRUD_FG (Function Group)        │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐   │  │
│  │  │ZEMP_     │ │ZEMP_READ │ │ZEMP_UPDATE   │   │  │
│  │  │CREATE    │ │ZEMP_READ │ │ZEMP_DELETE   │   │  │
│  │  │          │ │_ALL      │ │              │   │  │
│  │  └──────────┘ └──────────┘ └──────────────┘   │  │
│  └────────────────────┬───────────────────────────┘  │
│                       │                              │
│                       ▼                              │
│  ┌────────────────────────────────────────────────┐  │
│  │         ZTABLE_EMP_MASTER (Database)           │  │
│  │  MANDT | EMP_ID | EMP_NAME | DEPT | ...        │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## 3. Data Dictionary Objects

### 3.1 Domain
| Object | Type | Length | Fixed Values |
|---|---|---|---|
| ZDOMAIN_EMP_STATUS | CHAR | 1 | A=Active, I=Inactive, T=Terminated |

### 3.2 Data Elements
| Data Element | Domain / Type | Description |
|---|---|---|
| ZDE_EMP_ID | NUMC(6) | Employee ID |
| ZDE_EMP_NAME | CHAR(40) | Employee Full Name |
| ZDE_EMP_DEPT | CHAR(30) | Department |
| ZDE_EMP_DESIG | CHAR(30) | Designation |
| ZDE_EMP_SALARY | CURR(13,2) | Monthly Salary |
| ZDE_EMP_AGE | NUMC(3) | Employee Age |
| ZDE_EMP_EMAIL | CHAR(50) | Email Address |
| ZDE_EMP_PHONE | CHAR(15) | Phone Number |
| ZDE_EMP_JOIN_DATE | DATS(8) | Date of Joining |
| ZDE_EMP_STATUS | ZDOMAIN_EMP_STATUS | Employment Status |

### 3.3 Transparent Table: ZTABLE_EMP_MASTER

| Field | Key | Data Element | Type | Length | Description |
|---|---|---|---|---|---|
| MANDT | ✓ | MANDT | CLNT | 3 | Client |
| EMP_ID | ✓ | ZDE_EMP_ID | NUMC | 6 | Employee ID |
| EMP_NAME | | ZDE_EMP_NAME | CHAR | 40 | Full Name |
| EMP_DEPARTMENT | | ZDE_EMP_DEPT | CHAR | 30 | Department |
| EMP_DESIGNATION | | ZDE_EMP_DESIG | CHAR | 30 | Designation |
| EMP_SALARY | | ZDE_EMP_SALARY | CURR | 13,2 | Salary |
| EMP_AGE | | ZDE_EMP_AGE | NUMC | 3 | Age |
| EMP_EMAIL | | ZDE_EMP_EMAIL | CHAR | 50 | Email |
| EMP_PHONE | | ZDE_EMP_PHONE | CHAR | 15 | Phone |
| EMP_JOIN_DATE | | ZDE_EMP_JOIN_DATE | DATS | 8 | Join Date |
| EMP_STATUS | | ZDE_EMP_STATUS | CHAR | 1 | Status |
| CREATED_BY | | ERNAM | CHAR | 12 | Created By |
| CREATED_ON | | ERDAT | DATS | 8 | Created On |

---

## 4. Program Design

### 4.1 ZEMPLOYEE_MAIN — Selection Screen Actions

| Parameter | Values | Description |
|---|---|---|
| P_ACTION | C / R / U / D / L | Operation to perform |
| P_EMPID | 000001–999999 | Employee ID |
| P_NAME | Text | Employee Name |
| P_DEPT | Text | Department |
| P_STATUS | A / I / T | Employment Status |

### 4.2 ZEMP_REPORT_ALV — Selection Options

| Parameter | Description |
|---|---|
| S_DEPT | Filter by Department (range) |
| S_STATUS | Filter by Status (default: Active) |
| P_MAX | Max rows to display (default: 100) |

---

## 5. Validation Rules

| Rule | Field | Condition |
|---|---|---|
| Mandatory | EMP_ID, EMP_NAME, EMP_DEPARTMENT | Must not be empty |
| Age Range | EMP_AGE | Must be 18–65 |
| Salary | EMP_SALARY | Must be ≥ 0 |
| Email | EMP_EMAIL | Must contain '@' |
| Status | EMP_STATUS | Must be A, I, or T |
| Join Date | EMP_JOIN_DATE | Cannot be future date |
| Duplicate | EMP_ID | Must not exist (on Create) |

---

## 6. CRUD Flow Diagrams

### Create Flow
```
User Input → AT SELECTION-SCREEN (validate action)
          → FORM validate_inputs (field validation)
          → SELECT COUNT(*) (duplicate check)
          → INSERT ztable_emp_master
          → sy-subrc = 0? → COMMIT WORK → Success Message
                          → ELSE        → ROLLBACK WORK → Error Message
```

### Read Flow
```
User Input (EMP_ID) → SELECT SINGLE ... INTO wa_employee
                    → sy-subrc = 0? → WRITE employee details
                                    → ELSE → Warning: not found
```

### Update Flow
```
User Input → validate_inputs → SELECT SINGLE (existence check)
           → not found? → Error
           → Update wa_employee fields
           → UPDATE ztable_emp_master FROM wa_employee
           → sy-subrc = 0? → COMMIT WORK → Success
                           → ROLLBACK WORK → Error
```

### Delete Flow
```
User Input (EMP_ID) → SELECT COUNT(*) (existence check)
                    → not found? → Warning, return
                    → DELETE FROM ztable_emp_master WHERE emp_id = ...
                    → sy-subrc = 0? → COMMIT WORK → Success
                                    → Error message
```

---

## 7. Testing

Run `ZTEST_EMP_MODULE` in SE38 to execute a full test cycle:
1. Creates a test employee (ID: 000001)
2. Reads and verifies the record
3. Updates salary and designation
4. Lists all employees
5. Deletes the test record
