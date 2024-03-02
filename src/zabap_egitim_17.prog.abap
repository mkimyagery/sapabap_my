*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_17
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_17.
"Global type
TYPES : BEGIN OF gty_table,
          box.
          INCLUDE STRUCTURE zsg_spfli.
TYPES : END OF gty_table.

"Global Table
DATA : gt_table    TYPE TABLE OF gty_table,
       gs_table    TYPE gty_table,
       gt_fieldcat TYPE slis_t_fieldcat_alv,
       gs_fieldcat LIKE LINE OF gt_fieldcat,
       gs_layout   TYPE slis_layout_alv.

START-OF-SELECTION.

  PERFORM select_data.
  PERFORM fcat.
  PERFORM layout.
  PERFORM alv_display.

FORM pf_status_20 USING lt_extab TYPE slis_t_extab.
  SET PF-STATUS 'PF_STATUS_20'.
ENDFORM.

FORM uc_button USING lv_ucomm TYPE sy-ucomm
                     ls_selfield TYPE slis_selfield.

  CASE lv_ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
     LEAVE PROGRAM.
      EXIT.
    WHEN 'EDIT'.

      PERFORM edit.
      PERFORM fcat.
      PERFORM alv_display.

    WHEN 'SAVE_CHANG'.

      READ TABLE gt_table INTO gs_table INDEX ls_selfield-tabindex.
      IF sy-subrc EQ 0.
        IF ls_selfield-fieldname EQ 'CITYFROM'.

          UPDATE zsg_spfli SET cityfrom = ls_selfield-value
                         WHERE carrid   = gs_table-carrid
                           AND connid   = gs_table-connid.

        ELSEIF ls_selfield-fieldname EQ 'CITYTO'.

          UPDATE zsg_spfli SET cityto = ls_selfield-value
                         WHERE carrid = gs_table-carrid
                           AND connid = gs_table-connid.

        ENDIF.
      ENDIF.

      PERFORM select_data.
      PERFORM alv_display.

  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .
  SELECT * FROM zsg_spfli INTO CORRESPONDING FIELDS OF TABLE gt_table.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fcat .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZSG_SPFLI'
      i_bypassing_buffer     = abap_true
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM layout .

  gs_layout-colwidth_optimize = abap_true.
  gs_layout-zebra             = abap_true.
  gs_layout-box_fieldname     = 'BOX'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form alv_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alv_display .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS_20'
      i_callback_user_command  = 'UC_BUTTON'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_table
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit .

  LOOP AT gt_fieldcat INTO gs_fieldcat.

    CASE gs_fieldcat-fieldname.
      WHEN 'CITYTO'.
        gs_fieldcat-edit = abap_true.
      WHEN 'CITYFROM'.
        gs_fieldcat-edit = abap_true.
    ENDCASE.

    MODIFY gt_fieldcat FROM gs_fieldcat.

  ENDLOOP.


ENDFORM.
