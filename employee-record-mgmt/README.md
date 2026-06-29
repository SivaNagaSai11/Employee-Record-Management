# Employee Record Management using SAP ABAP

## Project Overview

Developed a basic SAP ABAP application to manage employee records using internal tables and modular programming. Implemented data validation, CRUD operations, and report generation using core ABAP concepts.

---

## 📋 Project Description

This project demonstrates a complete **Employee Record Management System** built using SAP ABAP. It covers all fundamental ABAP concepts required in enterprise SAP development, including:

- Custom Data Dictionary objects (Table, Data Elements, Domains)
- Internal Tables with Header Lines and Work Areas
- Modular Programming using Subroutines (FORM/ENDFORM) and Function Modules
- CRUD Operations (Create, Read, Update, Delete) on employee data
- Input Validation and Error Handling
- ALV Grid Report Generation
- Selection Screen Design

---

## 🗂️ Project Structure

```
employee-record-mgmt/
│
├── src/
│   ├── data_definitions/
│   │   ├── ZDOMAIN_EMP_STATUS.abap        → Domain for Employee Status
│   │   ├── ZDE_EMP_ID.abap                → Data Element: Employee ID
│   │   ├── ZDE_EMP_NAME.abap              → Data Element: Employee Name
│   │   └── ZTABLE_EMP_MASTER.abap         → Transparent Table: Employee Master
│   │
│   ├── programs/
│   │   ├── ZEMPLOYEE_MAIN.abap            → Main Program (Entry Point)
│   │   └── ZEMPLOYEE_VALIDATIONS.abap     → Validation Subroutines
│   │
│   ├── function_groups/
│   │   └── ZEMP_CRUD_FG.abap              → Function Group with CRUD modules
│   │
│   └── reports/
│       └── ZEMP_REPORT_ALV.abap           → ALV Report for Employee List
│
├── docs/
│   ├── TECHNICAL_DESIGN.md               → Technical design document
│   └── INTERVIEW_GUIDE.md                → Interview Q&A guide
│
├── tests/
│   └── ZTEST_EMP_MODULE.abap             → Test program
│
└── README.md
```

---

## 🛠️ Technologies & Concepts Used

| Concept | Usage in Project |
|---|---|
| **Data Dictionary (DDIC)** | Custom domain, data elements, transparent table |
| **Internal Tables** | Store and manipulate employee records in memory |
| **Work Areas** | Single row processing using `INTO wa_employee` |
| **Modular Programming** | FORM/ENDFORM subroutines, Function Modules |
| **CRUD Operations** | INSERT, SELECT, UPDATE, DELETE on `ZTABLE_EMP_MASTER` |
| **Data Validation** | Age range, mandatory fields, duplicate ID checks |
| **ALV Grid** | `REUSE_ALV_GRID_DISPLAY` for formatted report output |
| **Selection Screen** | `PARAMETERS` and `SELECT-OPTIONS` |
| **Message Classes** | E, W, S, I type messages for user feedback |

---

## 🔄 CRUD Operations Summary

```
CREATE  → Add new employee record after validation
READ    → Fetch single or all employee records
UPDATE  → Modify existing employee details
DELETE  → Remove employee record by ID
REPORT  → Display all records in ALV Grid format
```

---

## 🚀 How to Run in SAP System

1. **Create DDIC Objects first** (in order):
   - Create Domain: `ZDOMAIN_EMP_STATUS`
   - Create Data Elements: `ZDE_EMP_ID`, `ZDE_EMP_NAME`, etc.
   - Create Transparent Table: `ZTABLE_EMP_MASTER` → Activate → Generate Table

2. **Create Function Group**: `ZEMP_CRUD_FG` with all function modules

3. **Create Programs**:
   - `ZEMPLOYEE_MAIN` — Main executable program
   - `ZEMP_REPORT_ALV` — Report program

4. **Run** via SE38 → Enter program name → Execute (F8)

---

## 📌 Key ABAP Statements Used

```abap
" Internal Table Declaration
DATA: it_employees TYPE TABLE OF ztable_emp_master,
      wa_employee  TYPE ztable_emp_master.

" Insert Record
INSERT ztable_emp_master FROM wa_employee.

" Read Record
SELECT SINGLE * FROM ztable_emp_master
  INTO wa_employee
  WHERE emp_id = lv_emp_id.

" Update Record
UPDATE ztable_emp_master FROM wa_employee.

" Delete Record
DELETE FROM ztable_emp_master WHERE emp_id = lv_emp_id.

" ALV Display
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    it_fieldcat = it_fieldcat
  TABLES
    t_outtab    = it_employees.
```

---

## 👤 Author

**Project:** Employee Record Management using SAP ABAP  
**Purpose:** SAP ABAP Learning Project / Interview Portfolio  
**Level:** Entry to Mid-level ABAP Developer

---

## 📄 License

This project is created for educational and portfolio purposes.
