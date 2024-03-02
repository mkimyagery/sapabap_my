*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_02.

**select * UP TO 10 rows from spfli into table @data(gt_tab).
**  BREAK-POINT.


CLASS lcl_yillik_izin DEFINITION.
  PUBLIC SECTION.
    METHODS: id_kontrol IMPORTING iv_id             TYPE zcm_de_id
                        EXPORTING ev_calisan_mevcut TYPE xfeld,

      izin_kontrol IMPORTING  iv_id              TYPE zcm_de_id
                              iv_izin_baslangic  TYPE sy-datum
                              iv_izin_bitis      TYPE sy-datum
                   EXPORTING  ev_yil_2           TYPE char4
                              ev_talep_izin_2    TYPE int1
                              ev_izin_alabilir_2 TYPE char1
                              ev_yil_1           TYPE char4
                              ev_talep_izin_1    TYPE int1
                              ev_izin_alabilir_1 TYPE xfeld
                   EXCEPTIONS sifir_is_gunu
                              yetersiz_izin_hakki
                              mevcut_kayit,

      izin_ekle IMPORTING iv_id             TYPE zcm_de_id
                          iv_yil            TYPE char4
                          iv_izin_baslangic TYPE sy-datum
                          iv_izin_bitis     TYPE sy-datum
                          iv_kul_izin       TYPE int1.
ENDCLASS.

CLASS lcl_yillik_izin IMPLEMENTATION.

  METHOD id_kontrol.
    DATA: ls_tablo_1 TYPE zcm_tablo_1.

    SELECT SINGLE * FROM zcm_tablo_1
      INTO ls_tablo_1
      WHERE id = iv_id.

    IF ls_tablo_1 IS NOT INITIAL.
      ev_calisan_mevcut = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD izin_kontrol.
    DATA: lv_is_gunu       TYPE i,
          ls_tablo_1       TYPE zcm_tablo_1,
          lt_tablo_2       TYPE TABLE OF zcm_tablo_2,
          ls_tablo_2       TYPE zcm_tablo_2,
          lv_kul_izin      TYPE i,
          lv_izin_bas      TYPE sy-datum,
          lv_izin_bitis    TYPE sy-datum,
          lv_yetersiz_izin TYPE c LENGTH 1.

    CALL FUNCTION 'HR_RO_WORKDAYS_IN_INTERVAL'
      EXPORTING
        begda   = iv_izin_baslangic
        endda   = iv_izin_bitis
        mofid   = '08'
      CHANGING
        wrkdays = lv_is_gunu.

    IF lv_is_gunu = 0.
      RAISE sifir_is_gunu.
    ENDIF.

    IF iv_izin_baslangic(4) = iv_izin_bitis(4).   "YYYYMMDD

      SELECT SINGLE * FROM zcm_tablo_1
        INTO ls_tablo_1
        WHERE id = iv_id.

      SELECT * FROM zcm_tablo_2
        INTO TABLE lt_tablo_2
        WHERE id = iv_id AND
              yil = iv_izin_baslangic(4).

      LOOP AT lt_tablo_2 INTO ls_tablo_2.
        lv_kul_izin = lv_kul_izin + ls_tablo_2-kul_izin.

        IF iv_izin_baslangic BETWEEN ls_tablo_2-izin_baslangic AND ls_tablo_2-izin_bitis OR
           iv_izin_bitis     BETWEEN ls_tablo_2-izin_baslangic AND ls_tablo_2-izin_bitis.
          RAISE mevcut_kayit.
        ENDIF.
      ENDLOOP.

      IF lv_is_gunu > ls_tablo_1-izin_hakki - lv_kul_izin.
        RAISE yetersiz_izin_hakki.
      ENDIF.

      ev_izin_alabilir_1 = abap_true.
      ev_yil_1 = iv_izin_baslangic(4).
      ev_talep_izin_1 = lv_is_gunu.

    ELSE.

      lv_izin_bitis = iv_izin_baslangic(4) && '1231'.

      CALL FUNCTION 'HR_RO_WORKDAYS_IN_INTERVAL'
        EXPORTING
          begda   = iv_izin_baslangic
          endda   = lv_izin_bitis
          mofid   = '08'
        CHANGING
          wrkdays = lv_is_gunu.

      IF lv_is_gunu IS NOT INITIAL.

        SELECT SINGLE * FROM zcm_tablo_1
          INTO ls_tablo_1
          WHERE id = iv_id.

        SELECT * FROM zcm_tablo_2
          INTO TABLE lt_tablo_2
          WHERE id = iv_id AND
                yil = iv_izin_baslangic(4).

        LOOP AT lt_tablo_2 INTO ls_tablo_2.
          lv_kul_izin = lv_kul_izin + ls_tablo_2-kul_izin.

          IF iv_izin_baslangic BETWEEN ls_tablo_2-izin_baslangic AND ls_tablo_2-izin_bitis OR
             lv_izin_bitis BETWEEN ls_tablo_2-izin_baslangic AND ls_tablo_2-izin_bitis.
          ENDIF.
        ENDLOOP.

        IF lv_is_gunu <= ls_tablo_1-izin_hakki - lv_kul_izin.
          ev_izin_alabilir_1 = abap_true.
          ev_yil_1 = iv_izin_baslangic(4).
          ev_talep_izin_1 = lv_is_gunu.
        ELSE.
          lv_yetersiz_izin = abap_true.
        ENDIF.
      ENDIF.

      lv_izin_bas = iv_izin_bitis(4) && '0101'.

      CALL FUNCTION 'HR_RO_WORKDAYS_IN_INTERVAL'
        EXPORTING
          begda   = lv_izin_bas
          endda   = iv_izin_bitis
          mofid   = '08'
        CHANGING
          wrkdays = lv_is_gunu.

      IF lv_is_gunu IS NOT INITIAL.
        SELECT SINGLE * FROM zcm_tablo_1
          INTO ls_tablo_1
          WHERE id = iv_id.

        SELECT * FROM zcm_tablo_2
          INTO TABLE lt_tablo_2
          WHERE id = iv_id AND
                yil = iv_izin_bitis(4).

        CLEAR: lv_kul_izin.

        LOOP AT lt_tablo_2 INTO ls_tablo_2.
          lv_kul_izin = lv_kul_izin + ls_tablo_2-kul_izin.

          IF lv_izin_bas BETWEEN ls_tablo_2-izin_baslangic AND ls_tablo_2-izin_bitis OR
             iv_izin_bitis BETWEEN ls_tablo_2-izin_baslangic AND ls_tablo_2-izin_bitis.
            RAISE mevcut_kayit.
          ENDIF.
        ENDLOOP.

        IF lv_is_gunu <= ls_tablo_1-izin_hakki - lv_kul_izin.
          ev_yil_2 = iv_izin_bitis(4).
          ev_talep_izin_2 = lv_is_gunu.
          ev_izin_alabilir_2 = abap_true.
        ELSE.
          IF lv_yetersiz_izin IS NOT INITIAL.
            RAISE yetersiz_izin_hakki.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD izin_ekle.
    DATA: ls_tablo_2 TYPE zcm_tablo_2.

    ls_tablo_2-id = iv_id.
    ls_tablo_2-yil = iv_yil.
    ls_tablo_2-izin_baslangic = iv_izin_baslangic.
    ls_tablo_2-izin_bitis = iv_izin_bitis.
    ls_tablo_2-kul_izin = iv_kul_izin.

    INSERT zcm_tablo_2 FROM ls_tablo_2.

    IF sy-subrc IS INITIAL.
      MESSAGE 'Kayit basariyla eklendi' TYPE 'I'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.


PARAMETERS: p_i_bas TYPE sy-datum OBLIGATORY,
            p_i_bit TYPE sy-datum OBLIGATORY,
            p_id    TYPE zcm_de_id OBLIGATORY.

DATA: go_yillik_izin     TYPE REF TO lcl_yillik_izin,
      gv_calisan_mevcut  TYPE c LENGTH 1,
      gv_yil_1           TYPE char4,
      gv_yil_2           TYPE char4,
      gv_talep_izin_1    TYPE int1,
      gv_talep_izin_2    TYPE int1,
      gv_izin_alabilir_1 TYPE c LENGTH 1,
      gv_izin_alabilir_2 TYPE c LENGTH 1,
      gv_answer          TYPE c LENGTH 1.

START-OF-SELECTION.

  IF p_i_bas > p_i_bit.
    MESSAGE 'Izin baslangic tarihi izin bitis tarihinden büyük olamaz.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF p_i_bas < sy-datum.
    MESSAGE 'Izin baslangic tarihi bugünün tarihinden kücük olamaz' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  CREATE OBJECT go_yillik_izin.

  go_yillik_izin->id_kontrol(
    EXPORTING
      iv_id             = p_id
    IMPORTING
      ev_calisan_mevcut = gv_calisan_mevcut ).

  IF gv_calisan_mevcut = abap_false.
    MESSAGE 'Girilen Id ile ilgili calisan bulunamadi.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  go_yillik_izin->izin_kontrol(
    EXPORTING
      iv_id               = p_id
      iv_izin_baslangic   = p_i_bas
      iv_izin_bitis       = p_i_bit
    IMPORTING
      ev_yil_1            = gv_yil_1
      ev_talep_izin_1     = gv_talep_izin_1
      ev_izin_alabilir_1  = gv_izin_alabilir_1
      ev_yil_2            = gv_yil_2
      ev_talep_izin_2     = gv_talep_izin_2
      ev_izin_alabilir_2  = gv_izin_alabilir_2
    EXCEPTIONS
      sifir_is_gunu       = 1
      yetersiz_izin_hakki = 2
      mevcut_kayit        = 3
      OTHERS              = 4  ).

  IF sy-subrc = 1.
    MESSAGE 'Girilen tarih araliginda is günü bulunmamaktadir.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF sy-subrc = 2.
    MESSAGE 'Yeterli izin hakki bulunmamaktadir.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF sy-subrc = 3.
    MESSAGE 'Mevcut kayit ile ortak gün problemi bulunmaktadir.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "Girilen 2 tarih arasinda is günü var mi?
  "Calisanin izin hakki var mi?
  "Girilen tarihler var olan tarihlerle kesisiyor mu?

  IF p_i_bas(4) NE p_i_bit(4).

    "Girilen tarihler farkli yillara ait.
    IF ( gv_izin_alabilir_1 IS INITIAL AND gv_izin_alabilir_2 IS NOT INITIAL ) OR
       ( gv_izin_alabilir_1 IS NOT INITIAL AND gv_izin_alabilir_2 IS INITIAL ).

      "Ya baslangic yili ya da bitis yili izin almaya müsait.
      "Kullaniciya soralim, kismi veri girisi yapilmasini onayliyor mu.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question  = 'Kismi veri girisi yapilmasini onayliyormusunuz?'
          text_button_1  = 'Evet'
          text_button_2  = 'Hayir'
        IMPORTING
          answer         = gv_answer
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.

      IF sy-subrc IS NOT INITIAL.
        EXIT.
      ENDIF.

      "Kullanici kismi veri girisini onayladi.
      "Baslangic veya bitis yilindaki izni tabloya ekleyelim.
      IF gv_answer = 1.
        IF gv_izin_alabilir_1 IS NOT INITIAL.
          go_yillik_izin->izin_ekle(
            EXPORTING
              iv_id             = p_id
              iv_yil            = gv_yil_1
              iv_izin_baslangic = p_i_bas
              iv_izin_bitis     = p_i_bas(4) && '1231'  "20241215  -----> 20241231
              iv_kul_izin       = gv_talep_izin_1 ).
        ENDIF.

        IF gv_izin_alabilir_2 IS NOT INITIAL.
          go_yillik_izin->izin_ekle(
            EXPORTING
              iv_id             = p_id
              iv_yil            = gv_yil_2
              iv_izin_baslangic = p_i_bit(4) && '0101'
              iv_izin_bitis     = p_i_bit
              iv_kul_izin       = gv_talep_izin_2 ).
        ENDIF.
      ENDIF.
    ELSEIF gv_izin_alabilir_1 IS NOT INITIAL AND gv_izin_alabilir_2 IS NOT INITIAL.
      go_yillik_izin->izin_ekle(
        EXPORTING
          iv_id             = p_id
          iv_yil            = gv_yil_1
          iv_izin_baslangic = p_i_bas
          iv_izin_bitis     = p_i_bas(4) && '1231'
          iv_kul_izin       = gv_talep_izin_1 ).

      go_yillik_izin->izin_ekle(
        EXPORTING
          iv_id             = p_id
          iv_yil            = gv_yil_2
          iv_izin_baslangic = p_i_bit(4) && '0101'
          iv_izin_bitis     = p_i_bit
          iv_kul_izin       = gv_talep_izin_2 ).

    ENDIF.
  ELSE.
    "Girilen her iki tarih de ayni yila ait.
    IF gv_izin_alabilir_1 IS NOT INITIAL.
      go_yillik_izin->izin_ekle(
        EXPORTING
          iv_id             = p_id
          iv_yil            = gv_yil_1
          iv_izin_baslangic = p_i_bas
          iv_izin_bitis     = p_i_bit
          iv_kul_izin       = gv_talep_izin_1 ).
    ENDIF.
  ENDIF.
