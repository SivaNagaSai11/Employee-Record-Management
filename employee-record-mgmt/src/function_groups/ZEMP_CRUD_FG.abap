*&---------------------------------------------------------------------*
*& Function Group : ZEMP_CRUD_FG
*& Description    : Function Group containing Employee CRUD Function Modules
*&---------------------------------------------------------------------*
*& HOW TO CREATE IN SAP:
*& 1. SE37 → Menu → Goto → Function Groups → Create Group
*& 2. Name: ZEMP_CRUD_FG
*& 3. Then create each Function Module below within this group
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& FUNCTION MODULE 1: ZEMP_CREATE
*& Purpose: Create a new employee record
*&---------------------------------------------------------------------*
FUNCTION zemp_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_EMPLOYEE) TYPE  TY_EMPLOYEE
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE  ABAP_BOOL
*"     VALUE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: ls_employee TYPE ztable_emp_master.

  " Check for duplicates
  SELECT COUNT(*) FROM ztable_emp_master
    WHERE emp_id = is_employee-emp_id.

  IF sy-dbcnt > 0.
    ev_success = abap_false.
    ev_message = |Employee ID { is_employee-emp_id } already exists|.
    RETURN.
  ENDIF.

  " Map to DB structure
  MOVE-CORRESPONDING is_employee TO ls_employee.
  ls_employee-created_by = sy-uname.
  ls_employee-created_on = sy-datum.

  INSERT ztable_emp_master FROM ls_employee.

  IF sy-subrc = 0.
    COMMIT WORK.
    ev_success = abap_true.
    ev_message = |Employee { is_employee-emp_name } created successfully|.
  ELSE.
    ROLLBACK WORK.
    ev_success = abap_false.
    ev_message = 'Database insert failed'.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& FUNCTION MODULE 2: ZEMP_READ
*& Purpose: Read a single employee record by ID
*&---------------------------------------------------------------------*
FUNCTION zemp_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_EMP_ID) TYPE  ZTABLE_EMP_MASTER-EMP_ID
*"  EXPORTING
*"     VALUE(ES_EMPLOYEE) TYPE  TY_EMPLOYEE
*"     VALUE(EV_FOUND) TYPE  ABAP_BOOL
*"----------------------------------------------------------------------

  SELECT SINGLE emp_id emp_name emp_department emp_designation
                emp_salary emp_age emp_email emp_phone
                emp_join_date emp_status
    FROM ztable_emp_master
    INTO CORRESPONDING FIELDS OF es_employee
    WHERE emp_id = iv_emp_id.

  IF sy-subrc = 0.
    ev_found = abap_true.
  ELSE.
    ev_found = abap_false.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& FUNCTION MODULE 3: ZEMP_READ_ALL
*& Purpose: Read all employee records into an internal table
*&---------------------------------------------------------------------*
FUNCTION zemp_read_all.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ET_EMPLOYEES) TYPE  TABLE
*"----------------------------------------------------------------------

  SELECT emp_id emp_name emp_department emp_designation
         emp_salary emp_age emp_email emp_phone
         emp_join_date emp_status
    FROM ztable_emp_master
    INTO CORRESPONDING FIELDS OF TABLE et_employees
    ORDER BY emp_id.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& FUNCTION MODULE 4: ZEMP_UPDATE
*& Purpose: Update an existing employee record
*&---------------------------------------------------------------------*
FUNCTION zemp_update.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_EMPLOYEE) TYPE  TY_EMPLOYEE
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE  ABAP_BOOL
*"     VALUE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: ls_employee TYPE ztable_emp_master.

  " Verify record exists
  SELECT SINGLE * FROM ztable_emp_master
    INTO ls_employee
    WHERE emp_id = is_employee-emp_id.

  IF sy-subrc <> 0.
    ev_success = abap_false.
    ev_message = |Employee { is_employee-emp_id } not found|.
    RETURN.
  ENDIF.

  " Overwrite with new values
  MOVE-CORRESPONDING is_employee TO ls_employee.

  UPDATE ztable_emp_master FROM ls_employee.

  IF sy-subrc = 0.
    COMMIT WORK.
    ev_success = abap_true.
    ev_message = 'Employee record updated successfully'.
  ELSE.
    ROLLBACK WORK.
    ev_success = abap_false.
    ev_message = 'Update failed'.
  ENDIF.

ENDFUNCTION.

*&---------------------------------------------------------------------*
*& FUNCTION MODULE 5: ZEMP_DELETE
*& Purpose: Delete an employee record by ID
*&---------------------------------------------------------------------*
FUNCTION zemp_delete.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_EMP_ID) TYPE  ZTABLE_EMP_MASTER-EMP_ID
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE  ABAP_BOOL
*"     VALUE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------

  DELETE FROM ztable_emp_master WHERE emp_id = iv_emp_id.

  IF sy-subrc = 0.
    COMMIT WORK.
    ev_success = abap_true.
    ev_message = |Employee { iv_emp_id } deleted successfully|.
  ELSE.
    ev_success = abap_false.
    ev_message = |Employee { iv_emp_id } not found or delete failed|.
  ENDIF.

ENDFUNCTION.
