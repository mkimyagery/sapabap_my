*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_31
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_31.

*from Local to SAP

TABLES : scarr .
DATA : gt_scarr    TYPE TABLE OF scarr,
       gv_filename TYPE string,
       gv_path     TYPE string,
       gv_fullpath TYPE string.
SELECT-OPTIONS : s_carrid FOR scarr-carrid .

START-OF-SELECTION .
  SELECT * FROM scarr INTO TABLE gt_scarr
  WHERE carrid IN s_carrid .
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title              = 'Dosya yolunu seçiniz'
      default_extension         = 'XLS'
      file_filter               = 'Excel files (*.XLS)|*.XLS'
    CHANGING
      filename                  = gv_filename
      path                      = gv_path
      fullpath                  = gv_fullpath
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = gv_filename
      write_field_separator   = 'X'
    TABLES
      data_tab                = gt_scarr
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  BREAK-POINT .
