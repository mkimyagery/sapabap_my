*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_30
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_30.

PARAMETERS: p_table TYPE tabname.

DATA: gr_data TYPE REF TO data.

START-OF-SELECTION.

DATA(go_new) = NEW zcmdynamic_table_selection( ).

go_new->get_data(
  EXPORTING
    iv_tabname = p_table
  IMPORTING
    et_data    = gr_data ).

ASSIGN gr_data->* TO FIELD-SYMBOL(<fs_table>).

BREAK-POINT.
