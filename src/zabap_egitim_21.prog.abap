*&---------------------------------------------------------------------*
*& Report ZCM_TEST_171
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_21.

DATA: go_cont_spfli TYPE REF TO cl_gui_custom_container,
      go_grid_spfli TYPE REF TO cl_gui_alv_grid,
      gt_fcat_spfli TYPE lvc_t_fcat,
      gt_spfli      TYPE TABLE OF spfli,
      gs_spfli      TYPE spfli.

DATA: go_cont_zcm TYPE REF TO cl_gui_custom_container,
      go_grid_zcm TYPE REF TO cl_gui_alv_grid,
      gt_fcat_zcm TYPE lvc_t_fcat,
      gt_zcm      TYPE TABLE OF zcm_spfli,
      gs_zcm      TYPE zcm_spfli.

DATA: gs_layout TYPE lvc_s_layo.

START-OF-SELECTION.

  CALL SCREEN 0400.

MODULE status_0400 OUTPUT.
  SET PF-STATUS 'STATUS_171'.
  SET TITLEBAR 'xxx'.

  PERFORM select_data_spfli.
  PERFORM fcat_spfli.
  PERFORM layout.
  PERFORM show_alv_spfli.

  PERFORM select_data_zcm.
  PERFORM fcat_zcm.
  PERFORM show_alv_zcm.
ENDMODULE.

MODULE user_command_0400 INPUT.
  DATA: lt_selected_rows TYPE lvc_t_roid,
        ls_selected_rows TYPE lvc_s_roid,
        lt_spfli         TYPE TABLE OF spfli.

  CASE sy-ucomm.
    WHEN 'GERI'.
      LEAVE PROGRAM.
    WHEN 'SAG'.
      go_grid_spfli->get_selected_rows(
        IMPORTING
          et_row_no = lt_selected_rows ).

      IF lt_selected_rows IS NOT INITIAL.
*        LOOP AT lt_selected_rows INTO ls_selected_rows.
*          READ TABLE gt_spfli INTO gs_spfli INDEX ls_selected_rows-row_id.
*          IF sy-subrc IS INITIAL.
*            DELETE gt_spfli INDEX ls_selected_rows-row_id.
*            APPEND gs_spfli TO gt_zcm.
*            INSERT zcm_spfli FROM gs_spfli.
*          ENDIF.
*        ENDLOOP.
        LOOP AT lt_selected_rows INTO ls_selected_rows.
          READ TABLE gt_spfli INTO gs_spfli INDEX ls_selected_rows-row_id.
          IF sy-subrc IS INITIAL.
            APPEND gs_spfli TO lt_spfli.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_spfli INTO gs_spfli.
          DELETE gt_spfli WHERE carrid = gs_spfli-carrid AND connid = gs_spfli-connid.
          APPEND gs_spfli TO gt_zcm.
          INSERT zcm_spfli FROM gs_spfli.
        ENDLOOP.

        CLEAR: lt_spfli.
        PERFORM show_alv_zcm.
      ENDIF.

    WHEN 'SOL'.

      go_grid_zcm->get_selected_rows(
        IMPORTING
          et_row_no = lt_selected_rows ).
      IF lt_selected_rows IS NOT INITIAL.
        LOOP AT lt_selected_rows INTO ls_selected_rows.
          READ TABLE gt_zcm INTO gs_zcm INDEX ls_selected_rows-row_id.
          IF sy-subrc IS INITIAL.
            APPEND gs_zcm TO lt_spfli.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_spfli INTO gs_spfli.
          DELETE gt_zcm WHERE carrid = gs_spfli-carrid AND connid = gs_spfli-connid.
          DELETE FROM zcm_spfli WHERE carrid = gs_spfli-carrid AND connid = gs_spfli-connid.
          APPEND gs_spfli TO gt_spfli.
        ENDLOOP.

        PERFORM show_alv_spfli.
        PERFORM show_alv_zcm.
      ENDIF.

  ENDCASE.
ENDMODULE.

FORM select_data_spfli.
  IF gt_spfli IS INITIAL.
    SELECT * FROM spfli INTO CORRESPONDING FIELDS OF TABLE gt_spfli.
  ENDIF.
ENDFORM.

FORM fcat_spfli.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'SPFLI'
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fcat_spfli
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.

FORM layout.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = 'A'.
ENDFORM.

FORM show_alv_spfli.

  IF go_grid_spfli IS INITIAL.

    CREATE OBJECT go_cont_spfli
      EXPORTING
        container_name              = 'CC_ALV_SPFLI'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.

    CREATE OBJECT go_grid_spfli
      EXPORTING
        i_parent          = go_cont_spfli
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.

    go_grid_spfli->set_table_for_first_display(
      EXPORTING
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_spfli
        it_fieldcatalog               = gt_fcat_spfli
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.

  ELSE.

    go_grid_spfli->refresh_table_display(
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
ENDFORM.

FORM select_data_zcm.
  IF gt_zcm IS INITIAL.
    SELECT * FROM zcm_spfli INTO CORRESPONDING FIELDS OF TABLE gt_zcm.
  ENDIF.
ENDFORM.

FORM fcat_zcm.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZCM_SPFLI'
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fcat_zcm
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.
ENDFORM.

FORM show_alv_zcm.

  IF go_grid_zcm IS INITIAL.

    CREATE OBJECT go_cont_zcm
      EXPORTING
        container_name              = 'CC_ALV_ZCM'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.

    CREATE OBJECT go_grid_zcm
      EXPORTING
        i_parent          = go_cont_zcm
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.

    go_grid_zcm->set_table_for_first_display(
      EXPORTING
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_zcm
        it_fieldcatalog               = gt_fcat_zcm
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.

  ELSE.

    go_grid_zcm->refresh_table_display(
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).

    IF sy-subrc IS NOT INITIAL.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
ENDFORM.
