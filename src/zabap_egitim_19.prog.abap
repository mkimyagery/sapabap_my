*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_19
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_19.

DATA : go_alvgrid_spfli   TYPE REF TO cl_gui_alv_grid,
       go_container_spfli TYPE REF TO cl_gui_custom_container,
       gt_fieldcat_spfli  TYPE lvc_t_fcat,
       gs_fieldcat_spfli  TYPE lvc_s_fcat,
       gs_layout_spfli    TYPE lvc_s_layo.

DATA : go_alvgrid_sflight   TYPE REF TO cl_gui_alv_grid,
       go_container_sflight TYPE REF TO cl_gui_custom_container,
       gt_fieldcat_sflight  TYPE lvc_t_fcat,
       gs_fieldcat_sflight  TYPE lvc_s_fcat,
       gs_layout_sflight    TYPE lvc_s_layo.

DATA : gt_spfli   TYPE TABLE OF spfli,
       gs_spfli   TYPE spfli,
       gt_sflight TYPE TABLE OF sflight,
       gs_sflight TYPE sflight.

DATA : gv_carrid TYPE spfli-carrid. "Alternatif S_CARR_ID

START-OF-SELECTION .

  CALL SCREEN 0200.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF_STATUS_187'.
  SET TITLEBAR 'TITLE_187'.

  PERFORM select_data_spfli.
  PERFORM fcat_spfli.
  PERFORM layout_spfli.
  PERFORM show_data_spfli.

  PERFORM select_data_sflight.
  PERFORM fcat_sflight.
  PERFORM layout_sflight.
  PERFORM show_data_sflight.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'LIST'.
      IF gv_carrid IS NOT INITIAL.

        DELETE gt_spfli   WHERE carrid NE gv_carrid.
        DELETE gt_sflight WHERE carrid NE gv_carrid.

      ELSE.
        MESSAGE 'Carrid Alanı Boş Olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    WHEN 'REFRESH'.

      CLEAR: gt_spfli,gt_sflight.


  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form select_data_spfli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data_spfli .
  IF gt_spfli IS INITIAL.
    SELECT * FROM spfli INTO TABLE gt_spfli.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fcat_spfli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fcat_spfli .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'SPFLI'
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fieldcat_spfli
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_spfli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout_spfli .

  gs_layout_spfli-zebra      = abap_true.
  gs_layout_spfli-cwidth_opt = abap_true.
  gs_layout_spfli-sel_mode   = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_data_spfli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_data_spfli .

  IF go_alvgrid_spfli IS INITIAL.

    CREATE OBJECT go_container_spfli
      EXPORTING
        container_name              = 'CONT1'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    CREATE OBJECT go_alvgrid_spfli
      EXPORTING
        i_parent          = go_container_spfli
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    go_alvgrid_spfli->set_table_for_first_display(
      EXPORTING
        is_layout                     = gs_layout_spfli
      CHANGING
        it_outtab                     = gt_spfli
        it_fieldcatalog               = gt_fieldcat_spfli
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ELSE.

*    go_alvgrid->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat ).

*    go_alvgrid->set_frontend_layout( is_layout = gs_layout ).

    go_alvgrid_spfli->refresh_table_display(
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_data_sflight
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data_sflight .
  IF gt_sflight IS INITIAL.
    SELECT * FROM sflight INTO TABLE gt_sflight.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fcat_sflight
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fcat_sflight .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'SFLIGHT'
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fieldcat_sflight
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout_sflight
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout_sflight .
  gs_layout_sflight-zebra      = abap_true.
  gs_layout_sflight-cwidth_opt = abap_true.
  gs_layout_sflight-sel_mode   = 'A'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_data_sflight
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_data_sflight .

  IF go_alvgrid_sflight IS INITIAL.

    CREATE OBJECT go_container_sflight
      EXPORTING
        container_name              = 'CONT2'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    CREATE OBJECT go_alvgrid_sflight
      EXPORTING
        i_parent          = go_container_sflight
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    go_alvgrid_sflight->set_table_for_first_display(
      EXPORTING
        is_layout                     = gs_layout_sflight
      CHANGING
        it_outtab                     = gt_sflight
        it_fieldcatalog               = gt_fieldcat_sflight
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ELSE.

*    go_alvgrid->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat ).

*    go_alvgrid->set_frontend_layout( is_layout = gs_layout ).

    go_alvgrid_sflight->refresh_table_display(
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ENDIF.

ENDFORM.
