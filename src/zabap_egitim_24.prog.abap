*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_24
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_24 MESSAGE-ID zmy_msg_class_1.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 NO INTERVALS.
  PARAMETERS: p_basari RADIOBUTTON GROUP abc,
              p_hata   RADIOBUTTON GROUP abc,
              p_uyari  RADIOBUTTON GROUP abc,
              p_bilgi  RADIOBUTTON GROUP abc.
SELECTION-SCREEN END OF BLOCK a1.

START-OF-SELECTION.

  IF p_basari = abap_true.

    MESSAGE s000 WITH 'First' 'SUCCESS'.

  ELSEIF p_hata = abap_true.

    MESSAGE e000 WITH 'Second' 'ERROR'.

  ELSEIF p_uyari = abap_true.

    MESSAGE w000 WITH 'Third' 'WARNING'.

  ELSEIF p_bilgi = abap_true.

    MESSAGE i000 WITH 'Fourth' 'INFORMATION'.

  ENDIF.
