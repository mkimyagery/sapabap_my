*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_003
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_03.


SELECT * FROM sflight  INTO TABLE  @DATA(gt_sflight).

TRY .

    DATA: o_salv TYPE REF TO cl_salv_table.


    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = o_salv
      CHANGING
        t_table      = gt_sflight.


    o_salv->get_functions( )->set_all( abap_true ).
    o_salv->get_columns( )->set_optimize( abap_true ).
    o_salv->get_display_settings( )->set_list_header( 'FLIGHT CONNECTION!' ).
    o_salv->get_display_settings( )->set_striped_pattern( abap_true ).
    o_salv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>row_column ).

    o_salv->get_functions( )->set_export_spreadsheet( abap_false ).
    o_salv->get_functions( )->set_group_export( abap_false ).

    o_salv->get_functions( )->set_print( abap_false ).
    o_salv->get_functions( )->set_print_preview( abap_false ).

    o_salv->display( ).

  CATCH cx_salv_msg.


ENDTRY.
