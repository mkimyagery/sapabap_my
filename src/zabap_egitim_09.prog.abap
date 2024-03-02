*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_09
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_09.


TYPES: BEGIN OF gty_table,
       kutu TYPE c LENGTH 1.
       INCLUDE STRUCTURE zmc_table_001.
TYPES: END OF gty_table.

DATA : gt_table    TYPE TABLE OF gty_table,
       gt_fieldcat TYPE	slis_t_fieldcat_alv,
       gs_fieldcat TYPE slis_fieldcat_alv,
       gs_layout   TYPE	slis_layout_alv.


SELECT * FROM zmc_table_001 INTO CORRESPONDING FIELDS OF TABLE gt_table.

CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
    i_structure_name       = 'ZMC_TABLE_001'
    i_bypassing_buffer     = abap_true
  CHANGING
    ct_fieldcat            = gt_fieldcat
  EXCEPTIONS
    inconsistent_interface = 1
    program_error          = 2
    OTHERS                 = 3.

IF sy-subrc <> 0.
  EXIT.
ENDIF.

LOOP AT gt_fieldcat INTO gs_fieldcat.

  CASE gs_fieldcat-fieldname.
    WHEN 'NAME'.
*      gs_fieldcat-key  = abap_true.
*      gs_fieldcat-edit = abap_true.
*      gs_fieldcat-no_out = abap_true.
    WHEN 'ID'.
*      gs_fieldcat-seltext_s = gs_fieldcat-seltext_m = gs_fieldcat-seltext_l = 'Alpaslan'.
*      gs_fieldcat-no_out = abap_true.
  ENDCASE.

  MODIFY gt_fieldcat FROM gs_fieldcat.
  CLEAR: gs_fieldcat.
ENDLOOP.


gs_layout-zebra             = abap_true.
gs_layout-colwidth_optimize = abap_true.
gs_layout-box_fieldname     = 'KUTU'.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid  "alternatif olarak 'ZABAP_CM_009'
    is_layout          = gs_layout
    it_fieldcat        = gt_fieldcat
  TABLES
    t_outtab           = gt_table
  EXCEPTIONS
    program_error      = 1
    OTHERS             = 2.

IF sy-subrc <> 0.
  EXIT.
ENDIF.
