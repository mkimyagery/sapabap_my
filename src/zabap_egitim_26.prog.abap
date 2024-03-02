*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_26
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_26.



SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 NO INTERVALS.
  PARAMETERS: p_scarr  RADIOBUTTON GROUP abc,
              p_spfli  RADIOBUTTON GROUP abc,
              p_sflght RADIOBUTTON GROUP abc.
SELECTION-SCREEN END OF BLOCK a1.

DATA: go_select_from_database TYPE REF TO zabap_cm_select_from_database,
      gt_scarr                TYPE TABLE OF scarr,
      gt_spfli                TYPE TABLE OF spfli,
      gt_sflight              TYPE TABLE OF sflight,
      gv_number               TYPE i VALUE 1.

FIELD-SYMBOLS: <fs_table> TYPE ANY TABLE,
               <fs_str>   TYPE any,
               <fs_field> TYPE any.

START-OF-SELECTION.

  CREATE OBJECT go_select_from_database.

  IF p_scarr = abap_true.
    ASSIGN gt_scarr TO <fs_table>.
  ELSEIF p_spfli = abap_true.
    ASSIGN gt_spfli TO <fs_table>.
  ELSE.
    ASSIGN gt_sflight TO <fs_table>.
  ENDIF.

  go_select_from_database->get_table(
    EXPORTING
      iv_get_scarr   = p_scarr
      iv_get_spfli   = p_spfli
      iv_get_sflight = p_sflght
    IMPORTING
      et_data = <fs_table> ).

  LOOP AT <fs_table> ASSIGNING <fs_str>.

    DO.
      ASSIGN COMPONENT gv_number OF STRUCTURE <fs_str> TO <fs_field>.
      IF <fs_field> IS ASSIGNED.
        WRITE: <fs_field>.
        UNASSIGN <fs_field>.
      ELSE.
        EXIT.
      ENDIF.

      gv_number = gv_number + 1.
    ENDDO.

    gv_number = 1.
    SKIP.

  ENDLOOP.
