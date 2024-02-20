*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_05.
TABLES: spfli.

SELECTION-SCREEN BEGIN OF LINE.

  SELECTION-SCREEN COMMENT (15) lv_text1 FOR FIELD p_rb1.
  PARAMETERS: p_rb1 RADIOBUTTON GROUP grb1 DEFAULT 'X' USER-COMMAND rb.

SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.

  SELECTION-SCREEN COMMENT (15) lv_text2 FOR FIELD p_rb2.
  PARAMETERS: p_rb2 RADIOBUTTON GROUP grb1.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK simple.

  PARAMETERS: p_carrid type spfli-carrid.
  PARAMETERS: p_connid type spfli-connid.

SELECTION-SCREEN end OF BLOCK simple.

SELECTION-SCREEN BEGIN OF BLOCK advanced.

  PARAMETERS: p_cfrom type spfli-cityfrom.
  PARAMETERS: p_cto type spfli-cityto.

SELECTION-SCREEN end OF BLOCK advanced.

at SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN into data(wa).
if wa-name cs 'cfrom' or wa-name cs 'cto'.
  IF p_rb2 = abap_true.
    wa-active = '0'.
    ELSE.
      wa-active = 1.
  ENDIF.

  MODIFY SCREEN from wa.
  ENDIF.
  ENDLOOP.
  INITIALIZATION.
  lv_text1 = '  ADVANCED '.
  lv_text2 = '  SIMPLE '.
