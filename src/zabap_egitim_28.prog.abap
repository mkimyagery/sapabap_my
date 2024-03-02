*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_28
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_28.


PARAMETERS: p_scarr  RADIOBUTTON GROUP abc,
            p_spfli  RADIOBUTTON GROUP abc,
            p_sflght RADIOBUTTON GROUP abc.

DATA: go_select_from_database TYPE REF TO zabap_cm_select_new,
      gt_scarr                TYPE TABLE OF scarr,
      gt_spfli                TYPE TABLE OF spfli,
      gt_sflight              TYPE TABLE OF sflight.

FIELD-SYMBOLS: <fs_table> TYPE ANY TABLE.

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
      iv_tabname = COND #( WHEN p_scarr  = abap_true THEN 'SCARR'
                           WHEN p_spfli  = abap_true THEN 'SPFLI'
                           WHEN p_sflght = abap_true THEN 'SFLIGHT' )
    IMPORTING
      et_data    = <fs_table> ).

  BREAK-POINT.
