*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_12
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_12.

DATA : go_alvgrid   TYPE REF TO cl_gui_alv_grid,
       go_container TYPE REF TO cl_gui_custom_container,
       gt_fieldcat  TYPE lvc_t_fcat,
       gs_fieldcat  TYPE lvc_s_fcat,
       gs_layout    TYPE lvc_s_layo.

TYPES : BEGIN OF gty_list.
          INCLUDE STRUCTURE sflight.
TYPES:    row_color TYPE c LENGTH 4.
TYPES:    cell_color TYPE lvc_t_scol.
*TYPES:    trafik_isigi TYPE c LENGTH 1.
TYPES:    trafik_isigi TYPE icon-id.
TYPES : END OF gty_list.

DATA : gt_list TYPE TABLE OF gty_list.


START-OF-SELECTION.

  CALL SCREEN 0100.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_STATUS_150'.
  SET TITLEBAR 'TITLE_018'.

  PERFORM select_data.
  PERFORM trafik_isigi.
  PERFORM fcat.
  PERFORM layout.
  PERFORM show_alv.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA: lt_row_no         TYPE lvc_t_roid,
        ls_row_no         TYPE lvc_s_roid,
        ls_list           TYPE gty_list,
        lt_list           TYPE TABLE OF gty_list,
        lt_sel_cols       TYPE lvc_t_col,
        ls_sel_cols       TYPE lvc_s_col,
        lv_color          TYPE lvc_emphsz,
        lv_answer         TYPE c LENGTH 1,
        lt_selected_cells TYPE lvc_t_cell,
        ls_selected_cells TYPE lvc_s_cell,
        ls_sell_color     TYPE lvc_s_scol,
        lv_color_number   TYPE c LENGTH 1,
        lv_intensified    TYPE c LENGTH 1,
        lv_inverse        TYPE c LENGTH 1,
        lt_filter         TYPE lvc_t_filt,
        ls_filter         TYPE lvc_s_filt,
        lt_sort           TYPE lvc_t_sort,
        ls_sort           TYPE lvc_s_sort.


  CASE sy-ucomm.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.

    WHEN 'SIL'.
      go_alvgrid->get_selected_rows(
        IMPORTING
          et_row_no     =  lt_row_no ).

      lt_list = gt_list.

      LOOP AT lt_row_no INTO ls_row_no.

        READ TABLE lt_list INTO ls_list INDEX ls_row_no-row_id.
        IF sy-subrc = 0.
          DELETE gt_list WHERE carrid = ls_list-carrid
                           AND connid = ls_list-connid
                           AND fldate = ls_list-fldate.
        ENDIF.
      ENDLOOP.

    WHEN 'RESET'.
      CLEAR gt_list.
    WHEN 'K_RENK'.

      go_alvgrid->get_selected_columns(
        IMPORTING
          et_index_columns = lt_sel_cols ).
      IF lt_sel_cols IS NOT INITIAL.
        LOOP AT lt_sel_cols INTO ls_sel_cols.
          READ TABLE gt_fieldcat INTO gs_fieldcat
             WITH KEY fieldname = ls_sel_cols-fieldname.
          IF sy-subrc IS INITIAL.
            gs_fieldcat-emphasize = 'C611'.
            MODIFY gt_fieldcat FROM gs_fieldcat
               TRANSPORTING emphasize
               WHERE fieldname = gs_fieldcat-fieldname.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE 'EN AZ BİR KOLON SECMELİSİNİZ.' TYPE 'I'.
      ENDIF.

    WHEN 'S_RENK'.
      go_alvgrid->get_selected_rows(
        IMPORTING
          et_row_no     = lt_row_no ).

      IF lt_row_no IS NOT INITIAL.
        LOOP AT lt_row_no INTO ls_row_no.
          READ TABLE gt_list INTO ls_list
             INDEX ls_row_no-row_id.
          IF sy-subrc IS INITIAL.
            ls_list-row_color = 'C511'.
            MODIFY gt_list FROM ls_list
               TRANSPORTING row_color
               WHERE carrid = ls_list-carrid AND
                     connid = ls_list-connid AND
                     fldate = ls_list-fldate.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE 'EN AZ BİR SATIR SECMELİSİNİZ.' TYPE 'I'.
      ENDIF.

    WHEN 'H_RENK'.

      go_alvgrid->get_selected_cells(
        IMPORTING
          et_cell = lt_selected_cells ).

      IF lt_selected_cells IS NOT INITIAL.

        CALL FUNCTION 'ZZO_COLOR_SELECTION_CELL'
          IMPORTING
            ev_color_number = lv_color_number
            ev_intensified  = lv_intensified
            ev_inverse      = lv_inverse
            ev_answer       = lv_answer.


        LOOP AT lt_selected_cells INTO ls_selected_cells.

          ls_sell_color-fname     = ls_selected_cells-col_id.
          ls_sell_color-color-col = lv_color_number.
          ls_sell_color-color-int = lv_intensified.
          ls_sell_color-color-inv = lv_inverse.

          READ TABLE gt_list INTO ls_list INDEX ls_selected_cells-row_id.
          IF sy-subrc IS INITIAL.
            APPEND ls_sell_color TO ls_list-cell_color.
            MODIFY gt_list FROM ls_list TRANSPORTING cell_color WHERE carrid = ls_list-carrid AND
                                                                      connid = ls_list-connid AND
                                                                      fldate = ls_list-fldate.
          ENDIF.
        ENDLOOP.
      ELSE.
        MESSAGE 'En az bir adet hücre seciniz' TYPE 'I'.


      ENDIF.

    WHEN 'F_UCAK'.

      DATA: lv_number TYPE i.

      go_alvgrid->get_selected_cells(
        IMPORTING
          et_cell = lt_selected_cells ).
      DESCRIBE TABLE lt_selected_cells LINES lv_number.

      IF lv_number = 1.
        READ TABLE lt_selected_cells INTO ls_selected_cells INDEX 1.
        IF  sy-subrc IS INITIAL .
          IF ls_selected_cells-col_id = 'PLANETYPE'.
            READ TABLE gt_list INTO ls_list INDEX ls_selected_cells-row_id.
            IF sy-subrc IS INITIAL .
              ls_filter-fieldname = ls_selected_cells-col_id.
              ls_filter-sign = 'I'.
              ls_filter-option = 'EQ'.
              ls_filter-low = ls_list-planetype.
              APPEND  ls_filter TO lt_filter.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE 'Filtreleme butonu sadece bir hücre secerek kullanilabilir'
           TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN 'A-Z'.

      go_alvgrid->get_selected_cells(
        IMPORTING
          et_cell = lt_selected_cells ).

      IF lines( lt_selected_cells ) = 1.
        CLEAR: lt_sort.

        READ TABLE lt_selected_cells INTO ls_selected_cells INDEX 1.

        IF sy-subrc IS INITIAL.
          ls_sort-spos      = sy-tabix.
          ls_sort-fieldname = ls_selected_cells-col_id.
          ls_sort-up        = abap_true.
          ls_sort-down      = ' '.
          APPEND ls_sort TO lt_sort.
          CLEAR ls_sort.
        ENDIF.

      ELSE.
        MESSAGE 'Siralama butonunu sadece 1 hücre seçiniz!' TYPE 'I'.

      ENDIF.

    WHEN 'Z-A'.

      CALL METHOD go_alvgrid->get_selected_cells
        IMPORTING
          et_cell = lt_selected_cells.

      IF lines( lt_selected_cells ) = 1.

        CLEAR: lt_sort.
        READ TABLE lt_selected_cells INTO ls_selected_cells INDEX 1.
        IF sy-subrc EQ 0.
          ls_sort-spos      = sy-tabix.
          ls_sort-fieldname = ls_selected_cells-col_id.
          ls_sort-up        = space. " ' '
          ls_sort-down      = abap_true.
          APPEND ls_sort TO lt_sort.
          CLEAR ls_sort.
        ENDIF.

      ELSE.
        MESSAGE 'Siralama butonunu sadece 1 hücre seçiniz!' TYPE 'I'.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .
  IF gt_list IS INITIAL.
    SELECT * FROM sflight INTO CORRESPONDING FIELDS OF TABLE gt_list.

  ENDIF.

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
  IF gt_fieldcat IS INITIAL.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'SFLIGHT'
        i_bypassing_buffer     = abap_true
      CHANGING
        ct_fieldcat            = gt_fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

   gs_fieldcat-fieldname = 'TRAFIK_ISIGI'.
  gs_fieldcat-scrtext_m = 'Dolu Koltuk Oranı'.
  gs_fieldcat-col_pos   = 7.

  APPEND gs_fieldcat TO gt_fieldcat.
  CLEAR: gs_fieldcat.
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

  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = 'A'.
  gs_layout-info_fname = 'ROW_COLOR'.
  gs_layout-ctab_fname = 'CELL_COLOR'.
*  gs_layout-excp_fname = 'TRAFIK_ISIGI'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_alv .

  IF go_alvgrid IS INITIAL.

    CREATE OBJECT go_container
      EXPORTING
        container_name              = 'CON'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    CREATE OBJECT go_alvgrid
      EXPORTING
        i_parent          = go_container
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    go_alvgrid->set_table_for_first_display(
      EXPORTING
        is_layout                     = gs_layout
      CHANGING
        it_outtab                     = gt_list
        it_fieldcatalog               = gt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4  ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ELSE.

    go_alvgrid->set_frontend_fieldcatalog( it_fieldcatalog = gt_fieldcat ).
    go_alvgrid->set_frontend_layout( is_layout = gs_layout  ).

    go_alvgrid->set_filter_criteria(
      EXPORTING
        it_filter                 =   lt_filter
      EXCEPTIONS
        no_fieldcatalog_available = 1
        OTHERS                    = 2 ).
    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    go_alvgrid->set_sort_criteria(
      EXPORTING
        it_sort                   = lt_sort
     EXCEPTIONS
       no_fieldcatalog_available = 1
       OTHERS                    = 2 ).
    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

    go_alvgrid->refresh_table_display(
      EXCEPTIONS
        finished       = 1
        OTHERS         = 2 ).

    IF sy-subrc <> 0.
      LEAVE PROGRAM.
    ENDIF.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form trafik_isigi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM trafik_isigi .
  DATA: ls_list TYPE gty_list,
        lt_table TYPE TABLE OF gty_list,
        lv_oran TYPE p DECIMALS 2.

  LOOP AT gt_list INTO ls_list.
    lv_oran = ls_list-seatsocc / ls_list-seatsmax.

    IF lv_oran >= ( 75 / 100 ).
*      ls_list-trafik_isigi = 1.
      ls_list-trafik_isigi = '@0A@'.
    ELSEIF lv_oran < ( 75 / 100 ) AND lv_oran >= ( 40 / 100 ).
*      ls_list-trafik_isigi = 2.
      ls_list-trafik_isigi = '@09@'.
    ELSEIF lv_oran < ( 40 / 100 ).
*      ls_list-trafik_isigi = 3.
      ls_list-trafik_isigi = '@08@'.
    ENDIF.

*    APPEND ls_list TO lt_table.
*    CLEAR: ls_list.

    MODIFY gt_list FROM ls_list
       TRANSPORTING trafik_isigi
       WHERE carrid = ls_list-carrid
         AND connid = ls_list-connid
         AND fldate = ls_list-fldate.
  ENDLOOP.

*  MODIFY TABLE gt_list FROM lt_table.

ENDFORM.
