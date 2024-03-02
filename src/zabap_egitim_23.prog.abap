*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_23
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_23.

TABLES: sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 NO INTERVALS.
  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN COMMENT 1(5) TEXT-002. "Saat:
    SELECTION-SCREEN POSITION 6.
    PARAMETERS: p_hour TYPE int2 AS LISTBOX VISIBLE LENGTH 6.

    SELECTION-SCREEN COMMENT 15(7) TEXT-003. "Dakika:
    SELECTION-SCREEN POSITION 22.
    PARAMETERS: p_mins TYPE int2 AS LISTBOX VISIBLE LENGTH 6.

    SELECTION-SCREEN COMMENT 31(7) TEXT-004. "Saniye:
    SELECTION-SCREEN POSITION 38.
    PARAMETERS: p_scnd TYPE int2 AS LISTBOX VISIBLE LENGTH 6.

    SELECTION-SCREEN PUSHBUTTON 46(54) bt1 USER-COMMAND hsp.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-005 NO INTERVALS.
  PARAMETERS: p_rslt TYPE i.
SELECTION-SCREEN END OF BLOCK a2.

INITIALIZATION. "Selection screen gösterilmeden
                "önce yapilacak tüm islemler.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_calculation
      text   = TEXT-006
      info   = TEXT-007
    IMPORTING
      result = bt1
    EXCEPTIONS
      OTHERS = 0.

  PERFORM dropdown.

AT SELECTION-SCREEN OUTPUT. "Selection screen gösterilmeden
                            "önce ekran elementleri üzerinde
  LOOP AT SCREEN.           "yapilacak islemler.
    IF p_rslt IS INITIAL.
      IF screen-name = 'P_RSLT' OR screen-name = '%_P_RSLT_%_APP_%-TEXT'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF screen-name = 'P_RSLT'.
        screen-input = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN. "Selection screen icerisinde
                     "kalarak yapilacak islemler.
  CLEAR: p_rslt.

  CASE sscrfields-ucomm.
    WHEN 'HSP'.
      IF p_hour > 0.
        p_rslt = p_hour * 3600.
      ENDIF.

      IF p_mins > 0.
        p_rslt = p_rslt + ( p_mins * 60 ).
      ENDIF.

      IF p_scnd > 0.
        p_rslt = p_rslt + p_scnd.
      ENDIF.
  ENDCASE.

FORM dropdown.

  DATA: lv_fname  TYPE vrm_id,
        lt_values TYPE vrm_values,
        ls_value  TYPE vrm_value,
        lv_number TYPE i.

  lv_fname = 'P_HOUR'.
  CLEAR: lv_number, lt_values.

  DO 24 TIMES.
    lv_number     = lv_number + 1.
    ls_value-key  = lv_number.
    ls_value-text = lv_number.

    APPEND ls_value TO lt_values.
    CLEAR: ls_value.
  ENDDO.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_fname
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.

  lv_fname = 'P_MINS'.
  CLEAR: lv_number, lt_values.

  DO 60 TIMES.
    lv_number     = lv_number + 1.
    ls_value-key  = lv_number.
    ls_value-text = lv_number.

    APPEND ls_value TO lt_values.
    CLEAR: ls_value.
  ENDDO.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_fname
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.

  lv_fname = 'P_SCND'.
  CLEAR: lv_number, lt_values.

  DO 60 TIMES.
    lv_number     = lv_number + 1.
    ls_value-key  = lv_number.
    ls_value-text = lv_number.

    APPEND ls_value TO lt_values.
    CLEAR: ls_value.
  ENDDO.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = lv_fname
      values          = lt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.
