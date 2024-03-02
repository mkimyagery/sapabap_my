*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_13
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_13.

"Örnek Tablom zcm_table_001.

DATA : gv_id      TYPE zcm_de_id,
       gv_name    TYPE zcm_de_name,
       gv_surname TYPE zcm_de_surname,
       gv_job     TYPE zcm_de_job,
       gv_salary  TYPE zcm_de_salary,
       gv_curr    TYPE zcm_de_curr,
       gv_gsm     TYPE zcm_de_gsm,
       gv_e_mail  TYPE zcm_de_e_mail.

CONSTANTS: gc_structure_name TYPE dd02l-tabname VALUE 'ZCM_TABLE_001'.

DATA : gs_table     TYPE zcm_table_001,
       gt_table     TYPE TABLE OF zcm_table_001,
       gs_layout    TYPE lvc_s_layo,
       gt_fieldcat  TYPE lvc_t_fcat,
       go_container TYPE REF TO cl_gui_custom_container,
       go_alvgrid   TYPE REF TO cl_gui_alv_grid.

START-OF-SELECTION.

  CALL SCREEN 0100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_STATUS_019'.
  SET TITLEBAR 'TITLE_019'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'READ'.
      PERFORM read.
    WHEN 'DELETE'.
      PERFORM delete.
    WHEN 'UPDATE'.
      PERFORM update.
    WHEN 'CREATE'.
      PERFORM create.
    WHEN 'ALV'.
      PERFORM alv.

  ENDCASE.
ENDMODULE.

FORM select_data.
  IF gv_id IS NOT INITIAL.
    SELECT * FROM zcm_table_001 INTO TABLE gt_table WHERE id = gv_id.
  ELSE.
    SELECT * FROM zcm_table_001 INTO TABLE gt_table.
  ENDIF.

ENDFORM.

FORM fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_structure_name
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    LEAVE PROGRAM.
  ENDIF.


ENDFORM.

FORM layout.
  gs_layout-zebra = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode = 'A'.

ENDFORM.

FORM show_alv.
  IF go_alvgrid IS INITIAL.

    CREATE OBJECT go_container
      EXPORTING
        container_name              = 'CON'
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

    CREATE OBJECT go_alvgrid
      EXPORTING
        i_parent          = go_container
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    go_alvgrid->set_table_for_first_display(
      EXPORTING
      is_layout          =   gs_layout
      CHANGING
        it_outtab         =   gt_table
        it_fieldcatalog   =  gt_fieldcat

      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ELSE.
    go_alvgrid->check_changed_data( ).

    go_alvgrid->refresh_table_display(

      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).
    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read .

  CLEAR : gs_table.
  SELECT SINGLE * FROM zcm_table_001
                  INTO gs_table
                 WHERE id = gv_id.

  IF gs_table IS NOT INITIAL.

    gv_name    = gs_table-name    .
    gv_surname = gs_table-surname .
    gv_job     = gs_table-job     .
    gv_salary  = gs_table-salary  .
    gv_curr    = gs_table-curr    .
    gv_gsm     = gs_table-gsm     .
    gv_e_mail  = gs_table-e_mail  .

  ELSE.
    CLEAR: gv_name,gv_surname,gv_job,
           gv_salary,gv_curr,gv_gsm,gv_e_mail.

    MESSAGE 'Girilen IDye ait satır bulunamadı!' TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete .

  IF gv_id IS NOT INITIAL.
    DELETE FROM zcm_table_001 WHERE id = gv_id.
    IF sy-subrc EQ 0.
      MESSAGE 'İşlem başarılı' TYPE 'S'.
    ELSE.
      MESSAGE 'Girilen ID ile ilgili kayıt bulunamadı' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'ID alanı boş olamaz..!' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form update
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update .
  IF gv_id IS NOT INITIAL.

    UPDATE zcm_table_001 SET name    = gv_name
                             surname = gv_surname
                             job     = gv_job
                             salary  = gv_salary
                             curr    = gv_curr
                             gsm     = gv_gsm
                             e_mail  = gv_e_mail
                       WHERE id      = gv_id.
    IF sy-subrc EQ 0.
      MESSAGE 'Satır Güncelleme BAŞARILI TEBRİKLER' TYPE 'S' .
    ELSE.
      MESSAGE 'Girilen ID ile ilgili kayıt bulunamadı' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

  ELSE.
    MESSAGE 'ID alanı boş olamaz..!' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create .


  CLEAR: gs_table.

  gs_table-id      = gv_id      .
  gs_table-name    = gv_name    .
  gs_table-surname = gv_surname .
  gs_table-job     = gv_job     .
  gs_table-salary  = gv_salary  .
  gs_table-curr    = gv_curr    .
  gs_table-gsm     = gv_gsm     .
  gs_table-e_mail  = gv_e_mail  .

  INSERT zcm_table_001 FROM gs_table.

  IF sy-subrc EQ 0.
    MESSAGE  'Kayıt Başarılı!' TYPE 'S'.
  ELSE.
    MESSAGE 'Kayıt ekleme sırasında HATA!' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv .
  PERFORM select_data.
  PERFORM fcat.
  PERFORM layout.
  PERFORM show_alv.

ENDFORM.
