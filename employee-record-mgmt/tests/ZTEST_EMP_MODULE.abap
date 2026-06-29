*&---------------------------------------------------------------------*
*& Program     : ZTEST_EMP_MODULE
*& Description : Test program to verify all CRUD operations
*&               Run this in SE38 to test the function modules
*&---------------------------------------------------------------------*

REPORT ztest_emp_module.

DATA: ls_employee TYPE ty_employee,
      lt_employees TYPE TABLE OF ty_employee,
      lv_success TYPE abap_bool,
      lv_msg     TYPE string,
      lv_found   TYPE abap_bool.

START-OF-SELECTION.

  WRITE: / '=== EMPLOYEE CRUD TEST SUITE ==='.
  WRITE: / ''.

  " ---- TEST 1: CREATE ----
  WRITE: / '--- TEST 1: Create Employee ---'.
  CLEAR ls_employee.
  ls_employee-emp_id          = '000001'.
  ls_employee-emp_name        = 'Rahul Sharma'.
  ls_employee-emp_department  = 'Information Technology'.
  ls_employee-emp_designation = 'ABAP Developer'.
  ls_employee-emp_salary      = 75000.
  ls_employee-emp_age         = 28.
  ls_employee-emp_email       = 'rahul.sharma@company.com'.
  ls_employee-emp_phone       = '9876543210'.
  ls_employee-emp_join_date   = '20230101'.
  ls_employee-emp_status      = 'A'.

  CALL FUNCTION 'ZEMP_CREATE'
    EXPORTING
      is_employee = ls_employee
    IMPORTING
      ev_success  = lv_success
      ev_message  = lv_msg.

  IF lv_success = abap_true.
    WRITE: / 'PASS:', lv_msg.
  ELSE.
    WRITE: / 'FAIL:', lv_msg.
  ENDIF.

  " ---- TEST 2: READ ----
  WRITE: / ''.
  WRITE: / '--- TEST 2: Read Employee ---'.
  CLEAR ls_employee.

  CALL FUNCTION 'ZEMP_READ'
    EXPORTING
      iv_emp_id   = '000001'
    IMPORTING
      es_employee = ls_employee
      ev_found    = lv_found.

  IF lv_found = abap_true.
    WRITE: / 'PASS: Record found -', ls_employee-emp_name.
  ELSE.
    WRITE: / 'FAIL: Record not found'.
  ENDIF.

  " ---- TEST 3: UPDATE ----
  WRITE: / ''.
  WRITE: / '--- TEST 3: Update Employee ---'.
  ls_employee-emp_salary = 85000.   " Give a raise
  ls_employee-emp_designation = 'Senior ABAP Developer'.

  CALL FUNCTION 'ZEMP_UPDATE'
    EXPORTING
      is_employee = ls_employee
    IMPORTING
      ev_success  = lv_success
      ev_message  = lv_msg.

  IF lv_success = abap_true.
    WRITE: / 'PASS:', lv_msg.
  ELSE.
    WRITE: / 'FAIL:', lv_msg.
  ENDIF.

  " ---- TEST 4: READ ALL ----
  WRITE: / ''.
  WRITE: / '--- TEST 4: List All Employees ---'.
  REFRESH lt_employees.

  CALL FUNCTION 'ZEMP_READ_ALL'
    IMPORTING
      et_employees = lt_employees.

  WRITE: / 'Total Records Found:', lines( lt_employees ).

  " ---- TEST 5: DELETE ----
  WRITE: / ''.
  WRITE: / '--- TEST 5: Delete Employee ---'.

  CALL FUNCTION 'ZEMP_DELETE'
    EXPORTING
      iv_emp_id  = '000001'
    IMPORTING
      ev_success = lv_success
      ev_message = lv_msg.

  IF lv_success = abap_true.
    WRITE: / 'PASS:', lv_msg.
  ELSE.
    WRITE: / 'FAIL:', lv_msg.
  ENDIF.

  WRITE: / ''.
  WRITE: / '=== TEST SUITE COMPLETE ==='.
