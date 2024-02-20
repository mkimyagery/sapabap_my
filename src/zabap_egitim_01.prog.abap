*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_01.
TABLES scarr.

* ALV

TYPES: BEGIN OF gty_table,
         box TYPE char1.
         INCLUDE STRUCTURE scarr.
TYPES: END OF gty_table.

DATA: gt_scarr    TYPE TABLE OF gty_table,
      gs_scarr    TYPE gty_table,
      gs_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv.



SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.


CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
    i_structure_name       = 'SCARR'
  CHANGING
    ct_fieldcat            = gt_fieldcat
  EXCEPTIONS
    inconsistent_interface = 1
    program_error          = 2
    OTHERS                 = 3.
IF sy-subrc <> 0.
  LEAVE PROGRAM.
ENDIF.

gs_layout-zebra = 'X'.
gs_layout-colwidth_optimize = 'X'.
gs_layout-box_fieldname = 'BOX'.


CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid
    is_layout          = gs_layout
    it_fieldcat        = gt_fieldcat
  TABLES
    t_outtab           = gt_scarr
  EXCEPTIONS
    program_error      = 1
    OTHERS             = 2.
IF sy-subrc <> 0.
  LEAVE PROGRAM.
ENDIF.
