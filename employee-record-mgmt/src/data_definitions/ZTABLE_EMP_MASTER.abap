*&---------------------------------------------------------------------*
*& SAP ABAP Data Dictionary - Transparent Table
*& Object Name : ZTABLE_EMP_MASTER
*& Description : Employee Master Table - stores all employee records
*&---------------------------------------------------------------------*
*
* STEPS TO CREATE IN SAP (SE11):
* 1. Go to SE11 → Select "Database Table" → Enter: ZTABLE_EMP_MASTER → Create
* 2. Short Description: Employee Master Data Table
* 3. Delivery Class : A (Application Table - Master/Transaction data)
* 4. Data Browser/Table View Maintenance: Display/Maintenance Allowed
* 5. Add fields as below
* 6. Go to "Technical Settings":
*    - Data Class: APPL0
*    - Size Category: 0
* 7. Save → Activate → the physical table is created in DB
*
*---------------------------------------------------------------------*
* TABLE FIELDS DEFINITION:
*
* Field Name     | Key | Data Element         | Type  | Length | Description
* ---------------|-----|----------------------|-------|--------|------------------
* MANDT          | X   | MANDT                | CLNT  | 3      | Client (auto)
* EMP_ID         | X   | ZDE_EMP_ID           | NUMC  | 6      | Employee ID
* EMP_NAME       |     | ZDE_EMP_NAME         | CHAR  | 40     | Employee Full Name
* EMP_DEPARTMENT |     | ZDE_EMP_DEPT         | CHAR  | 30     | Department
* EMP_DESIGNATION|     | ZDE_EMP_DESIG        | CHAR  | 30     | Designation/Role
* EMP_SALARY     |     | ZDE_EMP_SALARY       | CURR  | 13,2   | Monthly Salary
* EMP_AGE        |     | ZDE_EMP_AGE          | NUMC  | 3      | Age
* EMP_EMAIL      |     | ZDE_EMP_EMAIL        | CHAR  | 50     | Email Address
* EMP_PHONE      |     | ZDE_EMP_PHONE        | CHAR  | 15     | Phone Number
* EMP_JOIN_DATE  |     | ZDE_EMP_JOIN_DATE    | DATS  | 8      | Date of Joining
* EMP_STATUS     |     | ZDE_EMP_STATUS       | CHAR  | 1      | Status (A/I/T)
* CREATED_BY     |     | ERNAM                | CHAR  | 12     | Created By (user)
* CREATED_ON     |     | ERDAT                | DATS  | 8      | Created On (date)
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
* ABAP DICTIONARY OBJECT - Table can also be referenced in ABAP as:
*---------------------------------------------------------------------*

* Referencing the table type in ABAP programs:
*
*   DATA: it_employees TYPE TABLE OF ztable_emp_master,
*         wa_employee  TYPE ztable_emp_master.
*
* This automatically gives you all fields defined in the table.
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
* FOREIGN KEY RELATIONSHIPS:
*   EMP_STATUS → ZDOMAIN_EMP_STATUS (values: A, I, T)
*---------------------------------------------------------------------*
