*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_25_SPFLI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_25_SPFLI.



DATA: gv_carrid TYPE s_carr_id.

SELECT-OPTIONS: so_car_2 FOR gv_carrid.

DATA: gt_table  TYPE TABLE OF spfli,
      gt_fcat   TYPE lvc_t_fcat,
      gs_layout TYPE lvc_s_layo.

START-OF-SELECTION.

  SELECT * FROM spfli INTO TABLE gt_table WHERE carrid IN so_car_2.

  CHECK gt_table IS NOT INITIAL.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'SPFLI'
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.

  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program = sy-repid
      is_layout_lvc      = gs_layout
      it_fieldcat_lvc    = gt_fcat
    TABLES
      t_outtab           = gt_table
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.
