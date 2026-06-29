*&---------------------------------------------------------------------*
*& Program     : ZEMPLOYEE_MAIN
*& Title       : Employee Record Management System - Main Program
*& Description : Entry point for Employee CRUD operations
*& Author      : ABAP Developer
*& Created On  : 2024
*&---------------------------------------------------------------------*
*& CONCEPTS COVERED:
*&   - Selection Screen (PARAMETERS, SELECT-OPTIONS)
*&   - Internal Tables and Work Areas
*&   - Modular Programming (PERFORM/FORM)
*&   - CRUD on Transparent Table (ZTABLE_EMP_MASTER)
*&   - Message handling (MESSAGE)
*&   - Conditional logic, loops
*&---------------------------------------------------------------------*

REPORT zemployee_main.

*---------------------------------------------------------------------*
* TYPE DECLARATIONS
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_employee,
         emp_id          TYPE ztable_emp_master-emp_id,
         emp_name        TYPE ztable_emp_master-emp_name,
         emp_department  TYPE ztable_emp_master-emp_department,
         emp_designation TYPE ztable_emp_master-emp_designation,
         emp_salary      TYPE ztable_emp_master-emp_salary,
         emp_age         TYPE ztable_emp_master-emp_age,
         emp_email       TYPE ztable_emp_master-emp_email,
         emp_phone       TYPE ztable_emp_master-emp_phone,
         emp_join_date   TYPE ztable_emp_master-emp_join_date,
         emp_status      TYPE ztable_emp_master-emp_status,
       END OF ty_employee.

*---------------------------------------------------------------------*
* DATA DECLARATIONS
*---------------------------------------------------------------------*
DATA: it_employees TYPE TABLE OF ty_employee,   " Internal table
      wa_employee  TYPE ty_employee,             " Work area (single row)
      lv_emp_id    TYPE ztable_emp_master-emp_id,
      lv_count     TYPE i,
      lv_msg       TYPE string.

*---------------------------------------------------------------------*
* CONSTANTS
*---------------------------------------------------------------------*
CONSTANTS: c_active     TYPE char1 VALUE 'A',
           c_inactive   TYPE char1 VALUE 'I',
           c_terminated TYPE char1 VALUE 'T',
           c_min_age    TYPE numc3 VALUE '18',
           c_max_age    TYPE numc3 VALUE '65'.

*---------------------------------------------------------------------*
* SELECTION SCREEN
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    p_action  TYPE char1 OBLIGATORY DEFAULT 'D',  " C=Create R=Read U=Update D=Delete L=List
    p_empid   TYPE ztable_emp_master-emp_id,
    p_name    TYPE ztable_emp_master-emp_name,
    p_dept    TYPE ztable_emp_master-emp_department,
    p_desig   TYPE ztable_emp_master-emp_designation,
    p_salary  TYPE ztable_emp_master-emp_salary,
    p_age     TYPE ztable_emp_master-emp_age,
    p_email   TYPE ztable_emp_master-emp_email,
    p_phone   TYPE ztable_emp_master-emp_phone,
    p_joindt  TYPE ztable_emp_master-emp_join_date,
    p_status  TYPE ztable_emp_master-emp_status DEFAULT 'A'.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN COMMENT /1(60) TEXT-002.

*---------------------------------------------------------------------*
* AT SELECTION SCREEN - Input validation before execution
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM validate_action USING p_action.

*---------------------------------------------------------------------*
* START OF SELECTION - Main execution logic
*---------------------------------------------------------------------*
START-OF-SELECTION.

  CASE p_action.
    WHEN 'C'.                           " CREATE
      PERFORM validate_inputs.
      PERFORM create_employee.
    WHEN 'R'.                           " READ
      PERFORM read_employee USING p_empid.
    WHEN 'U'.                           " UPDATE
      PERFORM validate_inputs.
      PERFORM update_employee.
    WHEN 'D'.                           " DELETE
      PERFORM delete_employee USING p_empid.
    WHEN 'L'.                           " LIST ALL
      PERFORM list_all_employees.
    WHEN OTHERS.
      MESSAGE 'Invalid action. Use C/R/U/D/L' TYPE 'E'.
  ENDCASE.

*---------------------------------------------------------------------*
* FORM: VALIDATE_ACTION
* Validates that the action code entered is valid
*---------------------------------------------------------------------*
FORM validate_action USING pv_action TYPE char1.
  IF pv_action NA 'CRUDL'.
    MESSAGE 'Action must be C(reate), R(ead), U(pdate), D(elete), L(ist)' TYPE 'E'.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
* FORM: VALIDATE_INPUTS
* Validates all mandatory fields before Create/Update operations
*---------------------------------------------------------------------*
FORM validate_inputs.

  " 1. Employee ID mandatory
  IF p_empid IS INITIAL.
    MESSAGE 'Employee ID is mandatory' TYPE 'E'.
  ENDIF.

  " 2. Employee Name mandatory
  IF p_name IS INITIAL.
    MESSAGE 'Employee Name is mandatory' TYPE 'E'.
  ENDIF.

  " 3. Department mandatory
  IF p_dept IS INITIAL.
    MESSAGE 'Department is mandatory' TYPE 'E'.
  ENDIF.

  " 4. Salary cannot be negative
  IF p_salary < 0.
    MESSAGE 'Salary cannot be negative' TYPE 'E'.
  ENDIF.

  " 5. Age validation
  IF p_age < c_min_age OR p_age > c_max_age.
    MESSAGE 'Employee age must be between 18 and 65' TYPE 'E'.
  ENDIF.

  " 6. Status validation
  IF p_status NA 'AIT'.
    MESSAGE 'Status must be A(ctive), I(nactive), or T(erminated)' TYPE 'E'.
  ENDIF.

  " 7. Email basic check - must contain @
  IF p_email NS '@'.
    MESSAGE 'Please enter a valid email address (must contain @)' TYPE 'W'.
  ENDIF.

  " 8. Joining date cannot be future date
  IF p_joindt > sy-datum.
    MESSAGE 'Joining date cannot be a future date' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: CREATE_EMPLOYEE
* Inserts a new employee record into ZTABLE_EMP_MASTER
*---------------------------------------------------------------------*
FORM create_employee.

  " Check for duplicate Employee ID
  SELECT COUNT(*) FROM ztable_emp_master
    WHERE emp_id = p_empid.

  IF sy-dbcnt > 0.
    MESSAGE 'Employee ID already exists. Use Update instead.' TYPE 'E'.
    RETURN.
  ENDIF.

  " Populate Work Area
  CLEAR wa_employee.
  wa_employee-emp_id          = p_empid.
  wa_employee-emp_name        = p_name.
  wa_employee-emp_department  = p_dept.
  wa_employee-emp_designation = p_desig.
  wa_employee-emp_salary      = p_salary.
  wa_employee-emp_age         = p_age.
  wa_employee-emp_email       = p_email.
  wa_employee-emp_phone       = p_phone.
  wa_employee-emp_join_date   = p_joindt.
  wa_employee-emp_status      = p_status.

  " Insert into DB table
  INSERT ztable_emp_master FROM wa_employee.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE 'Employee record created successfully!' TYPE 'S'.
    WRITE: / 'Employee Created:', p_name, '| ID:', p_empid.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Error creating employee record' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: READ_EMPLOYEE
* Reads and displays a single employee record
*---------------------------------------------------------------------*
FORM read_employee USING pv_emp_id TYPE ztable_emp_master-emp_id.

  IF pv_emp_id IS INITIAL.
    MESSAGE 'Employee ID is required for Read operation' TYPE 'E'.
    RETURN.
  ENDIF.

  CLEAR wa_employee.

  SELECT SINGLE emp_id emp_name emp_department emp_designation
                emp_salary emp_age emp_email emp_phone
                emp_join_date emp_status
    FROM ztable_emp_master
    INTO CORRESPONDING FIELDS OF wa_employee
    WHERE emp_id = pv_emp_id.

  IF sy-subrc = 0.
    " Display the record
    WRITE: / '================================================'.
    WRITE: / 'EMPLOYEE DETAILS'.
    WRITE: / '================================================'.
    WRITE: / 'Employee ID   :', wa_employee-emp_id.
    WRITE: / 'Name          :', wa_employee-emp_name.
    WRITE: / 'Department    :', wa_employee-emp_department.
    WRITE: / 'Designation   :', wa_employee-emp_designation.
    WRITE: / 'Salary        :', wa_employee-emp_salary.
    WRITE: / 'Age           :', wa_employee-emp_age.
    WRITE: / 'Email         :', wa_employee-emp_email.
    WRITE: / 'Phone         :', wa_employee-emp_phone.
    WRITE: / 'Joining Date  :', wa_employee-emp_join_date.
    WRITE: / 'Status        :', wa_employee-emp_status.
    WRITE: / '================================================'.
  ELSE.
    MESSAGE 'Employee not found for given ID' TYPE 'W'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: UPDATE_EMPLOYEE
* Updates an existing employee record
*---------------------------------------------------------------------*
FORM update_employee.

  " Check if employee exists
  SELECT SINGLE * FROM ztable_emp_master
    INTO CORRESPONDING FIELDS OF wa_employee
    WHERE emp_id = p_empid.

  IF sy-subrc <> 0.
    MESSAGE 'Employee not found. Cannot update.' TYPE 'E'.
    RETURN.
  ENDIF.

  " Update the fields
  wa_employee-emp_name        = p_name.
  wa_employee-emp_department  = p_dept.
  wa_employee-emp_designation = p_desig.
  wa_employee-emp_salary      = p_salary.
  wa_employee-emp_age         = p_age.
  wa_employee-emp_email       = p_email.
  wa_employee-emp_phone       = p_phone.
  wa_employee-emp_join_date   = p_joindt.
  wa_employee-emp_status      = p_status.

  UPDATE ztable_emp_master FROM wa_employee.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE 'Employee record updated successfully!' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Error updating employee record' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: DELETE_EMPLOYEE
* Deletes an employee record by Employee ID
*---------------------------------------------------------------------*
FORM delete_employee USING pv_emp_id TYPE ztable_emp_master-emp_id.

  IF pv_emp_id IS INITIAL.
    MESSAGE 'Employee ID is required for Delete operation' TYPE 'E'.
    RETURN.
  ENDIF.

  " Verify exists before delete
  SELECT COUNT(*) FROM ztable_emp_master WHERE emp_id = pv_emp_id.
  IF sy-dbcnt = 0.
    MESSAGE 'Employee ID not found. Nothing to delete.' TYPE 'W'.
    RETURN.
  ENDIF.

  " Perform Delete
  DELETE FROM ztable_emp_master WHERE emp_id = pv_emp_id.

  IF sy-subrc = 0.
    COMMIT WORK.
    lv_msg = |Employee { pv_emp_id } deleted successfully|.
    MESSAGE lv_msg TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Error deleting employee record' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: LIST_ALL_EMPLOYEES
* Fetches all employees and displays using WRITE statement
* (For ALV Report, refer to ZEMP_REPORT_ALV program)
*---------------------------------------------------------------------*
FORM list_all_employees.

  REFRESH it_employees.

  SELECT emp_id emp_name emp_department emp_designation
         emp_salary emp_age emp_status
    FROM ztable_emp_master
    INTO CORRESPONDING FIELDS OF TABLE it_employees
    ORDER BY emp_id.

  lv_count = lines( it_employees ).

  IF lv_count = 0.
    MESSAGE 'No employee records found in the system' TYPE 'I'.
    RETURN.
  ENDIF.

  " Display header
  WRITE: / '================================================================'.
  WRITE: / 'EMP ID', 10 'NAME', 35 'DEPT', 60 'DESIGNATION', 80 'SALARY', 95 'STATUS'.
  WRITE: / '================================================================'.

  " Loop through internal table and display
  LOOP AT it_employees INTO wa_employee.
    WRITE: / wa_employee-emp_id,
             10 wa_employee-emp_name,
             35 wa_employee-emp_department,
             60 wa_employee-emp_designation,
             80 wa_employee-emp_salary,
             95 wa_employee-emp_status.
  ENDLOOP.

  WRITE: / '================================================================'.
  WRITE: / 'Total Records:', lv_count.

ENDFORM.
