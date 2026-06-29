# Interview Guide — Employee Record Management (SAP ABAP)

This guide covers the most likely interview questions based on this project.

---

## 🔹 SECTION 1: Project Introduction (Say This First)

> "I developed an Employee Record Management System using SAP ABAP. The system allows users to perform full CRUD operations — Create, Read, Update, and Delete — on employee records stored in a custom transparent table called `ZTABLE_EMP_MASTER`. I used modular programming with subroutines and function modules, implemented input validation on the selection screen, and built an ALV Grid report for displaying employee data with filtering options."

---

## 🔹 SECTION 2: Data Dictionary Questions

**Q: What is a Transparent Table in SAP?**
> A transparent table in SAP is a database table that has a 1:1 relationship with its physical table in the database. Each row in the ABAP table corresponds exactly to one row in the database. I used `ZTABLE_EMP_MASTER` as my transparent table to store employee records.

**Q: What is a Domain and Data Element?**
> A **Domain** defines the technical properties of a field — its data type and length. For example, `ZDOMAIN_EMP_STATUS` is a CHAR(1) domain with fixed values A, I, T.  
> A **Data Element** links a domain to business semantics — it provides the field label and documentation. For example, `ZDE_EMP_STATUS` uses the domain and adds column headers like "Status" for the UI.  
> The hierarchy is: **Domain → Data Element → Table Field**

**Q: What is MANDT field and why is it always the first key field?**
> MANDT is the Client field. SAP is a multi-client system, meaning multiple companies/clients can share the same database. The MANDT field ensures data is isolated per client. It's always the primary key field in custom tables.

---

## 🔹 SECTION 3: Internal Tables Questions

**Q: What is an internal table? How is it different from a database table?**
> An internal table is a temporary table that exists only in the program's memory (RAM) during runtime. It is lost when the program ends. A database table is permanently stored in the database.  
> I used an internal table `it_employees` to hold employee data fetched from `ZTABLE_EMP_MASTER` and process it before displaying.

**Q: What is a Work Area?**
> A work area (`wa_employee`) is a single-row structure that acts as a buffer between the program and the internal table. When you `LOOP AT it_employees INTO wa_employee`, each row is loaded one at a time into the work area for processing.

**Q: Difference between TYPE TABLE OF and TYPE STANDARD TABLE OF?**
> They are the same. `TYPE TABLE OF` defaults to a STANDARD TABLE. There are 3 internal table types:
> - **STANDARD TABLE**: Access by index. Default.
> - **SORTED TABLE**: Always sorted by key. Binary search by default.
> - **HASHED TABLE**: Access only by unique key using hash algorithm. Fastest for large data.

---

## 🔹 SECTION 4: CRUD Operations Questions

**Q: How did you insert a record into the database?**
```abap
INSERT ztable_emp_master FROM wa_employee.
IF sy-subrc = 0.
  COMMIT WORK.
ELSE.
  ROLLBACK WORK.
ENDIF.
```
> After every database change, I check `sy-subrc`. If it's 0, the operation succeeded and I do `COMMIT WORK` to permanently save it. Otherwise, `ROLLBACK WORK` undoes the change.

**Q: What is sy-subrc?**
> `sy-subrc` is a system variable that holds the return code of the last operation. Value `0` means success. Any non-zero value means something went wrong.

**Q: How did you handle duplicate Employee IDs during Create?**
```abap
SELECT COUNT(*) FROM ztable_emp_master WHERE emp_id = p_empid.
IF sy-dbcnt > 0.
  MESSAGE 'Employee ID already exists' TYPE 'E'.
ENDIF.
```
> Before inserting, I run a `SELECT COUNT(*)` to check if the ID already exists. `sy-dbcnt` holds the row count. If it's greater than 0, I throw an error message.

**Q: What is the difference between DELETE FROM and DELETE table FROM wa?**
> - `DELETE FROM ztable_emp_master WHERE emp_id = '001'` — deletes directly from DB by condition
> - `DELETE ztable_emp_master FROM wa_employee` — deletes the specific row matching the work area's key fields

---

## 🔹 SECTION 5: Modular Programming

**Q: What is the difference between a Subroutine (FORM) and a Function Module?**

| Feature | Subroutine (FORM) | Function Module |
|---|---|---|
| Scope | Local to program | Global — reusable across programs |
| Created in | SE38 (within program) | SE37 (Function Builder) |
| Container | None | Function Group |
| Exception handling | No | Yes (EXCEPTIONS) |
| Reusability | Low | High |

**Q: Why did you use both FORM and Function Modules?**
> I used `FORM/ENDFORM` for validations that are specific to the main program (like `validate_inputs`). I used Function Modules for the actual CRUD operations because they are reusable — another program can also call `ZEMP_CREATE` without duplicating code.

---

## 🔹 SECTION 6: ALV Report Questions

**Q: What is ALV and why use it over WRITE?**
> ALV (ABAP List Viewer) is a standard SAP framework for displaying tabular data. Compared to `WRITE`:
> - ALV supports **sorting, filtering, totals** out of the box
> - Users can **save layouts**
> - It has a **modern UI** with column resize, Excel export
> - No manual formatting needed

**Q: What is a Field Catalog in ALV?**
> The field catalog (`it_fieldcat`) is an internal table that tells ALV which fields to display and how. Each row defines one column — its field name, header text, output length, whether to sum it, etc.

**Q: What function module did you use for ALV?**
> `REUSE_ALV_GRID_DISPLAY` — the standard SAP function module for ALV grid display.

---

## 🔹 SECTION 7: Validation Questions

**Q: What validations did you implement?**
> 1. **Mandatory fields** — Employee ID, Name, Department must not be empty
> 2. **Age range** — Employee age must be between 18 and 65
> 3. **Salary** — Cannot be negative
> 4. **Email format** — Must contain '@' symbol
> 5. **Status values** — Must be A, I, or T (via domain fixed values)
> 6. **Joining date** — Cannot be a future date
> 7. **Duplicate ID check** — On Create, verify ID doesn't already exist

**Q: Where did you implement validations?**
> In the `AT SELECTION-SCREEN` event for action validation, and in the `FORM validate_inputs` subroutine for field-level validations before any DB operation.

---

## 🔹 SECTION 8: General ABAP Questions

**Q: What is COMMIT WORK and ROLLBACK WORK?**
> SAP uses a Logical Unit of Work (LUW). Changes made with INSERT/UPDATE/DELETE are not immediately permanent — they are in a database buffer. `COMMIT WORK` permanently saves all changes. `ROLLBACK WORK` undoes all uncommitted changes.

**Q: What are MESSAGE types in ABAP?**
> - `E` — Error: Stops processing, highlights field
> - `W` — Warning: Allows user to continue
> - `I` — Information: Popup, informational
> - `S` — Success: Green bar message at bottom
> - `A` — Abort: Terminates the program

**Q: What is SELECT SINGLE vs SELECT ... INTO TABLE?**
> - `SELECT SINGLE` — fetches exactly one row matching the WHERE clause (uses key fields)
> - `SELECT ... INTO TABLE` — fetches multiple rows into an internal table

---

## ✅ Quick Project Summary for Interview

| Item | Details |
|---|---|
| **Table** | ZTABLE_EMP_MASTER (13 fields, transparent) |
| **Programs** | ZEMPLOYEE_MAIN, ZEMP_REPORT_ALV |
| **Function Group** | ZEMP_CRUD_FG (5 Function Modules) |
| **Operations** | Create, Read, Update, Delete, List |
| **Report Type** | ALV Grid using REUSE_ALV_GRID_DISPLAY |
| **Validations** | 7 types — mandatory, range, format, duplicate |
| **Key Concepts** | Internal tables, work areas, modular programming, DDIC |
