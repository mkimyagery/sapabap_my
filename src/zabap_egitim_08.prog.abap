*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_08
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_08.



PARAMETERS: p_id TYPE zcm_de_id AS LISTBOX VISIBLE LENGTH 15.

DATA: gv_field  TYPE vrm_id,
      gt_values TYPE vrm_values,
      gs_value  TYPE vrm_value,
      gt_tablo_1 TYPE TABLE OF zcm_tablo_1,
      gs_tablo_1 TYPE zcm_tablo_1,
      gt_tablo_2 TYPE TABLE OF zcm_tablo_2,
      gs_tablo_2 TYPE zcm_tablo_2.

INITIALIZATION.

  gv_field = 'P_ID'.

  SELECT * FROM zcm_tablo_1 INTO TABLE gt_tablo_1.

  LOOP AT gt_tablo_1 INTO gs_tablo_1.
    gs_value-key  = gs_tablo_1-id.
    gs_value-text = gs_tablo_1-ad && | | && gs_tablo_1-soyad.
    append gs_value to gt_values.
    CLEAR: gs_value.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = gv_field
      values          = gt_values
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

  IF sy-subrc IS NOT INITIAL.
    LEAVE PROGRAM.
  ENDIF.

START-OF-SELECTION.

SELECT * FROM zcm_tablo_2
  INTO TABLE gt_tablo_2
  WHERE id = p_id.
Write: /'Id         YEAR     START   FINISH    DAYS'.
LOOP AT gt_tablo_2 INTO gs_tablo_2.
  WRITE: / gs_tablo_2-id, gs_tablo_2-yil, gs_tablo_2-izin_baslangic,
         gs_tablo_2-izin_bitis, gs_tablo_2-kul_izin.

  SKIP.
ENDLOOP.
