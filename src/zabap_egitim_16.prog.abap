*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_16
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_16.



SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 NO INTERVALS.

  PARAMETERS: p_ag_num TYPE s_agncynum,
              p_name   TYPE s_agncynam,
              p_street TYPE s_street,
              p_pbox   TYPE s_postbox,
              p_pcode  TYPE postcode,
              p_city   TYPE city,
              p_cntry  TYPE s_country,
              p_region TYPE s_region,
              p_tel    TYPE s_phoneno,
              p_curr   TYPE s_curr_ag.

SELECTION-SCREEN END OF BLOCK a1.

DATA: go_stravelag_new_entry_alv TYPE REF TO zstravelag_new_entry_alv_3,
      gt_fcat                    TYPE slis_t_fieldcat_alv,
      gs_layout                  TYPE slis_layout_alv,
      gt_stravelag               TYPE zcm_tt_stravelag.

START-OF-SELECTION.

  CREATE OBJECT go_stravelag_new_entry_alv.

  go_stravelag_new_entry_alv->new_entry(
    EXPORTING
      iv_agencynum = p_ag_num
      iv_name      = p_name
      iv_street    = p_street
      iv_postbox   = p_pbox
      iv_postcode  = p_pcode
      iv_city      = p_city
      iv_country   = p_cntry
      iv_region    = p_region
      iv_telephone = p_tel
      iv_currency  = p_curr ).

  go_stravelag_new_entry_alv->prep_fcat(
    IMPORTING
      et_fcat = gt_fcat
    EXCEPTIONS
      no_fcat = 1
      OTHERS  = 2 ).

  IF sy-subrc = 1 .
    MESSAGE TEXT-002 TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  go_stravelag_new_entry_alv->prep_layout(
    EXPORTING
      iv_zebra             = abap_true
      iv_colwidth_optimize = abap_true
    IMPORTING
      es_layout            = gs_layout ).

  go_stravelag_new_entry_alv->prep_data(
    IMPORTING
      et_stravelag = gt_stravelag ).

  go_stravelag_new_entry_alv->show_data(
    EXPORTING
      it_fcat      = gt_fcat
      is_layout    = gs_layout
      it_stravelag = gt_stravelag ).
