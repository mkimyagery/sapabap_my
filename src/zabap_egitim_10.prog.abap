*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_10
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_10.

TABLES : sscrfields.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 NO INTERVALS.

  PARAMETERS : p_id     TYPE zcm_de_id,
               p_ad     TYPE zcm_de_info_ad,
               p_soyad  TYPE zcm_de_info_sad,
               p_adres  TYPE zcm_de_adres,
               p_gsm    TYPE zcm_de_gsm,
               p_e_mail TYPE zcm_de_e_mail,
               p_izinhk TYPE int1.
  SELECTION-SCREEN PUSHBUTTON 46(54) bt1 USER-COMMAND oku.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-002 NO INTERVALS.
  PARAMETERS: p_sil  RADIOBUTTON GROUP xyz,
              p_gun  RADIOBUTTON GROUP xyz,
              p_ekle RADIOBUTTON GROUP xyz.
SELECTION-SCREEN END OF BLOCK a2.


DATA : gs_eski       TYPE zcm_tablo_1,
       gs_yeni       TYPE zcm_tablo_1,
       gt_table_eski TYPE TABLE OF zzcm_tablo_1,
       gt_table_yeni TYPE TABLE OF zzcm_tablo_1,
       gt_cdpos      TYPE cdpos_tab,
       gv_process.

INITIALIZATION.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = icon_toggle_display
    IMPORTING
      result                = bt1
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.

AT SELECTION-SCREEN.

  CASE sscrfields-ucomm.
    WHEN 'OKU'.

      IF p_id IS NOT INITIAL.
        SELECT SINGLE * FROM zcm_tablo_1 INTO @DATA(gs_str) WHERE id = @p_id.
        IF gs_str IS NOT INITIAL.
          p_ad      = gs_str-ad.
          p_soyad   = gs_str-soyad.
          p_adres   = gs_str-adres.
          p_gsm     = gs_str-gsm.
          p_e_mail  = gs_str-e_mail.
          p_izinhk  = gs_str-izin_hakki.
        ELSE.
          CLEAR: p_ad, p_soyad, p_adres, p_gsm, p_e_mail, p_izinhk.
          MESSAGE 'ID bulunamadi' TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        MESSAGE 'ID giriniz' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

  ENDCASE.

START-OF-SELECTION.

  IF p_id IS INITIAL.
    MESSAGE 'Bos ID.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF p_sil = abap_true.

    SELECT SINGLE * FROM zcm_tablo_1 INTO gs_eski WHERE id = p_id.

    IF gs_eski IS NOT INITIAL.
      DELETE FROM zcm_tablo_1 WHERE id = p_id.

      IF sy-subrc IS NOT INITIAL.
        MESSAGE 'Silme basarisiz.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      gv_process = 'D'.
    ELSE.
      MESSAGE 'Silme basarisiz. ID bulunamadi.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

  ELSEIF p_gun = abap_true.
    SELECT SINGLE * FROM zcm_tablo_1 INTO gs_eski WHERE id = p_id.
    IF gs_eski IS NOT INITIAL.

      UPDATE zcm_tablo_1 SET ad         = p_ad
                             soyad      = p_soyad
                             adres      = p_adres
                             gsm        = p_gsm
                             e_mail     = p_e_mail
                             izin_hakki = p_izinhk
                         WHERE id = p_id.

      IF sy-subrc IS NOT INITIAL.
        MESSAGE 'Güncelleme basarisiz.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      gs_yeni-id         = p_id.
      gs_yeni-ad         = p_ad.
      gs_yeni-soyad      = p_soyad.
      gs_yeni-adres      = p_adres.
      gs_yeni-gsm        = p_gsm.
      gs_yeni-e_mail     = p_e_mail.
      gs_yeni-izin_hakki = p_izinhk.
      gv_process = 'U'.

    ELSE.
      MESSAGE 'Güncelleme basarisiz. ID bulunamadi.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

  ELSE.

    gs_yeni-id         = p_id.
    gs_yeni-ad         = p_ad.
    gs_yeni-soyad      = p_soyad.
    gs_yeni-adres      = p_adres.
    gs_yeni-gsm        = p_gsm.
    gs_yeni-e_mail     = p_e_mail.
    gs_yeni-izin_hakki = p_izinhk.

    INSERT zcm_tablo_1 FROM gs_yeni.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'Satir ekleme islemi basarisiz.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    gv_process = 'I'.

  ENDIF.

  IF gs_eski IS NOT INITIAL.
    gs_eski-mandt = sy-mandt.
    APPEND gs_eski TO gt_table_eski.
    CLEAR: gs_eski.
  ENDIF.

  IF gs_yeni IS NOT INITIAL.
    gs_yeni-mandt = sy-mandt.
    APPEND gs_yeni TO gt_table_yeni.
    CLEAR: gs_yeni.
  ENDIF.

  CALL FUNCTION 'ZCM_CDO_02_WRITE_DOCUMENT'
    EXPORTING
      objectid        = 'ZCM_CDO_02'
      tcode           = sy-tcode
      utime           = sy-uzeit
      udate           = sy-datum
      username        = sy-uname
      upd_zcm_tablo_1 = gv_process
    TABLES
      xzcm_tablo_1    = gt_table_yeni
      yzcm_tablo_1    = gt_table_eski.

  CALL FUNCTION 'CHANGEDOCUMENT_READ_ALL'
    EXPORTING
      i_objectclass              = 'ZCM_CDO_02'
      i_tablename                = 'ZCM_TABLO_1'
    IMPORTING
      et_cdpos                   = gt_cdpos
    EXCEPTIONS
      missing_input_objectclass  = 1
      missing_input_header       = 2
      no_position_found          = 3
      wrong_access_to_archive    = 4
      time_zone_conversion_error = 5
      read_too_many_entries      = 6
      OTHERS                     = 7.
