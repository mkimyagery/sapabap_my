*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_27
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_27.



TYPES: BEGIN OF gty_table,
         id      TYPE n LENGTH 6,
         name    TYPE c LENGTH 20,
         surname TYPE c LENGTH 20,
         address TYPE c LENGTH 50,
       END OF gty_table.

TYPES: gtt_table TYPE TABLE OF gty_table WITH NON-UNIQUE KEY id.

START-OF-SELECTION.

  DATA(gs_str) = VALUE gty_table( id      = '000001'
                                  name    = 'Mehmet'
                                  surname = 'Arabaci'
                                  address = 'Ali Pasa Mh. 1024 Sokak 45/4').

  DATA(gt_table) = VALUE gtt_table( ( id      = '000001'
                                      name    = 'Mehmet'
                                      surname = 'Arabaci'
                                      address = 'Ali Pasa Mh. 1024 Sokak 45/4')
                                    ( id      = '000002'
                                      name    = 'Aysenur'
                                      surname = 'Akar'
                                      address = 'Cankiri Mh. 1060 Sokak 23/2')
                                    ( id      = '000003'
                                      name    = 'Murat'
                                      surname = 'Erman'
                                      address = 'Uzunyol Mh. 1234 Sokak 56/11') ).

BREAK-POINT.
