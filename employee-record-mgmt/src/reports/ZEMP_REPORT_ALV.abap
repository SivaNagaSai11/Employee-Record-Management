*&---------------------------------------------------------------------*
*& Program     : ZEMP_REPORT_ALV
*& Title       : Employee Records - ALV Grid Report
*& Description : Generates a formatted ALV Grid report of employee data
*&               with filtering by department and status
*& Author      : ABAP Developer
*&---------------------------------------------------------------------*
*& CONCEPTS COVERED:
*&   - ALV Grid Display (REUSE_ALV_GRID_DISPLAY)
*&   - Field Catalog (SLIS_T_FIELDCAT_ALV)
*&   - Layout configuration (SLIS_LAYOUT_ALV)
*&   - SELECT-OPTIONS for range filtering
*&   - WRITE vs ALV comparison
*&---------------------------------------------------------------------*

REPORT zemp_report_alv.

*---------------------------------------------------------------------*
* INCLUDES / TYPE-POOLS
*---------------------------------------------------------------------*
TYPE-POOLS: slis.   " Required for ALV types

*---------------------------------------------------------------------*
* TYPES
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_emp_display,
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
         status_text     TYPE char15,    " Derived field: Status description
       END OF ty_emp_display.

*---------------------------------------------------------------------*
* DATA
*---------------------------------------------------------------------*
DATA: it_emp_display TYPE TABLE OF ty_emp_display,
      wa_emp_display TYPE ty_emp_display,
      it_fieldcat    TYPE slis_t_fieldcat_alv,
      wa_fieldcat    TYPE slis_fieldcat_alv,
      ls_layout      TYPE slis_layout_alv,
      lv_repid       TYPE sy-repid.

*---------------------------------------------------------------------*
* SELECTION SCREEN
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_dept   FOR ztable_emp_master-emp_department,
                  s_status FOR ztable_emp_master-emp_status DEFAULT 'A'.
  PARAMETERS:     p_max    TYPE i DEFAULT 100.
SELECTION-SCREEN END OF BLOCK sel.

*---------------------------------------------------------------------*
* START OF SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM build_fieldcat.
  PERFORM set_layout.
  PERFORM display_alv.

*---------------------------------------------------------------------*
* FORM: FETCH_DATA
* Fetches employee data from DB with filter conditions
*---------------------------------------------------------------------*
FORM fetch_data.

  REFRESH it_emp_display.

  SELECT emp_id emp_name emp_department emp_designation
         emp_salary emp_age emp_email emp_phone
         emp_join_date emp_status
    FROM ztable_emp_master
    INTO CORRESPONDING FIELDS OF TABLE it_emp_display
    WHERE emp_department IN s_dept
      AND emp_status     IN s_status
    ORDER BY emp_id
    UP TO p_max ROWS.

  IF sy-subrc <> 0 OR it_emp_display IS INITIAL.
    MESSAGE 'No records found for the selected criteria' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  " Enrich status_text field
  LOOP AT it_emp_display INTO wa_emp_display.
    CASE wa_emp_display-emp_status.
      WHEN 'A'. wa_emp_display-status_text = 'Active'.
      WHEN 'I'. wa_emp_display-status_text = 'Inactive'.
      WHEN 'T'. wa_emp_display-status_text = 'Terminated'.
      WHEN OTHERS. wa_emp_display-status_text = 'Unknown'.
    ENDCASE.
    MODIFY it_emp_display FROM wa_emp_display.
  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: BUILD_FIELDCAT
* Builds the ALV Field Catalog - defines column headers and properties
*---------------------------------------------------------------------*
FORM build_fieldcat.

  REFRESH it_fieldcat.

  " Macro-style helper using inline population
  DEFINE add_field.
    CLEAR wa_fieldcat.
    wa_fieldcat-fieldname  = &1.
    wa_fieldcat-coltext    = &2.
    wa_fieldcat-seltext_m  = &2.
    wa_fieldcat-outputlen  = &3.
    APPEND wa_fieldcat TO it_fieldcat.
  END-OF-DEFINITION.

  add_field 'EMP_ID'          'Emp ID'        8.
  add_field 'EMP_NAME'        'Employee Name' 25.
  add_field 'EMP_DEPARTMENT'  'Department'    20.
  add_field 'EMP_DESIGNATION' 'Designation'   20.
  add_field 'EMP_SALARY'      'Salary'        12.
  add_field 'EMP_AGE'         'Age'           5.
  add_field 'EMP_EMAIL'       'Email'         30.
  add_field 'EMP_PHONE'       'Phone'         15.
  add_field 'EMP_JOIN_DATE'   'Join Date'     12.
  add_field 'STATUS_TEXT'     'Status'        12.

  " Mark Salary as currency field
  READ TABLE it_fieldcat INTO wa_fieldcat WITH KEY fieldname = 'EMP_SALARY'.
  IF sy-subrc = 0.
    wa_fieldcat-do_sum = 'X'.         " Show total at bottom
    MODIFY it_fieldcat FROM wa_fieldcat.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* FORM: SET_LAYOUT
* Configures the overall ALV grid layout
*---------------------------------------------------------------------*
FORM set_layout.
  ls_layout-zebra          = 'X'.    " Alternating row colors
  ls_layout-colwidth_optimize = 'X'. " Auto-fit column widths
  ls_layout-sel_mode       = 'A'.    " Allow row selection
ENDFORM.

*---------------------------------------------------------------------*
* FORM: DISPLAY_ALV
* Calls the ALV function module to render the grid
*---------------------------------------------------------------------*
FORM display_alv.

  lv_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_repid     = lv_repid
      is_layout   = ls_layout
      it_fieldcat = it_fieldcat
      i_save      = 'A'                " Allow layout save
    TABLES
      t_outtab    = it_emp_display
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error displaying ALV report' TYPE 'E'.
  ENDIF.

ENDFORM.
