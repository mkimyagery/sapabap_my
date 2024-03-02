*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_29
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_29.

DATA: gv_id TYPE zcm_de_id.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_id FOR gv_id.
  PARAMETERS: p_yil TYPE c LENGTH 4.
SELECTION-SCREEN END OF BLOCK a1.

DATA: gv_name_sname TYPE string,
      gv_text       TYPE string,
      gv_izin       TYPE n LENGTH 4.

START-OF-SELECTION.

  SELECT * FROM zcm_tablo_1 INTO TABLE @DATA(gt_tablo_1).
  SELECT * FROM zcm_tablo_2 INTO TABLE @DATA(gt_tablo_2).

  LOOP AT gt_tablo_2 INTO DATA(gs_tablo_2) WHERE id IN so_id AND yil = p_yil
                                           GROUP BY ( id = gs_tablo_2-id )
                                           INTO DATA(gt_group).

    LOOP AT GROUP gt_group INTO DATA(gs_group).
      IF gv_name_sname IS INITIAL.
        READ TABLE gt_tablo_1 INTO DATA(gs_tablo_1) WITH KEY id = gs_group-id.
        IF  sy-subrc IS INITIAL.
          gv_name_sname = |{ gs_tablo_1-ad }| & | | & |{ gs_tablo_1-soyad }| & | | & |{ TEXT-002 }|.
        ENDIF.
      ENDIF.
      gv_izin = gv_izin + gs_group-kul_izin.
    ENDLOOP.

    gv_text = |{ gv_name_sname }| & | | & |{ gv_izin }|.
    WRITE: / gv_text.
    CLEAR: gv_name_sname, gv_izin.

  ENDLOOP.
