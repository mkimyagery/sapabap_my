*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_25
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_25.


DATA: gv_carrid TYPE s_carr_id.

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_table TYPE tabname.

  SELECT-OPTIONS: so_carr FOR gv_carrid.
SELECTION-SCREEN END OF BLOCK a1.

START-OF-SELECTION.

  CASE p_table.
    WHEN 'SCARR'.
      SUBMIT ZABAP_EGITIM_25_scarr WITH so_car_1 IN so_carr AND RETURN.
      MESSAGE 'SCARR tablosunun ALV''si gösterildi.' TYPE 'S'.
    WHEN 'SPFLI'.
      SUBMIT ZABAP_EGITIM_25_spfli WITH so_car_2 IN so_carr AND RETURN.
      MESSAGE 'SPFLI tablosunun ALV''si gösterildi.' TYPE 'S'.
    WHEN 'SFLIGHT'.
      SUBMIT ZABAP_EGITIM_25_sflight WITH so_car_3 IN so_carr AND RETURN.
      MESSAGE 'SFLIGHT tablosunun ALV''si gösterildi.' TYPE 'S'.
  ENDCASE.
