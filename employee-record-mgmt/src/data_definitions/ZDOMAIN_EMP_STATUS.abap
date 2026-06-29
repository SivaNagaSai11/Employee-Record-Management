*&---------------------------------------------------------------------*
*& SAP ABAP Data Dictionary - Domain Definition
*& Object Name : ZDOMAIN_EMP_STATUS
*& Description : Domain for Employee Employment Status
*&---------------------------------------------------------------------*
*
* STEPS TO CREATE IN SAP (SE11):
* 1. Go to SE11 → Select "Domain" → Enter name: ZDOMAIN_EMP_STATUS → Create
* 2. Short Description: Employee Employment Status
* 3. Data Type    : CHAR
* 4. No. Characters: 1
* 5. Go to "Value Range" tab → Add Fixed Values:
*    A = Active
*    I = Inactive
*    T = Terminated
* 6. Save → Activate
*
*---------------------------------------------------------------------*
* Domain Properties:
*   Name         : ZDOMAIN_EMP_STATUS
*   Data Type    : CHAR
*   Length       : 1
*   Output Length: 1
*   Lowercase    : No
*
* Fixed Values:
*   'A' = Active
*   'I' = Inactive
*   'T' = Terminated
*---------------------------------------------------------------------*
