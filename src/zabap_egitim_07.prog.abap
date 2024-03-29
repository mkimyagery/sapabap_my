*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_07
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_EGITIM_07.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(20) gv_rqt FOR FIELD p_req MODIF ID rq.
PARAMETERS : p_req LIKE e071-trkorr MODIF ID rq.

SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(20) gv_fld FOR FIELD p_folder
MODIF ID fl.

PARAMETERS :
  p_folder(50) DEFAULT 'C:\SAP_TRANSPORT_FILES\' MODIF ID fl.

SELECTION-SCREEN END OF LINE.

DATA : gv_dir_trans_path LIKE cst_rswatch01_alv-dirname,
       gv_slash ,gv_dotname_cofile(20), gv_dotname_data(20),
       gv_path_cofile LIKE sapb-sappfad,
       gv_path_data LIKE sapb-sappfad.

DATA gv_front_path_cofile LIKE sapb-sappfad.
DATA gv_front_path_data LIKE sapb-sappfad.
DATA gv_err.

INITIALIZATION.

  gv_rqt = 'Transport Request :'.
  gv_fld = 'Local Folder:'.

START-OF-SELECTION.

*--1-- Path of DIR_TRANS folder :

  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD 'DIR_TRANS'
                     ID 'VALUE' FIELD gv_dir_trans_path.

* --2-- Slash type :

  FIND '\' IN gv_dir_trans_path.
  IF sy-subrc EQ 0.
    gv_slash = '\'.
  ELSE.
    gv_slash = '/'.
  ENDIF.

* --3-- Cofiles / Data File Paths :

  CONCATENATE :
    'K' p_req+4 '.' p_req(3) INTO gv_dotname_cofile,

    gv_dir_trans_path gv_slash 'cofiles'
    gv_slash gv_dotname_cofile
    INTO gv_path_cofile,

    'R' p_req+4 '.' p_req(3) INTO gv_dotname_data,

    gv_dir_trans_path gv_slash
    'data' gv_slash gv_dotname_data INTO gv_path_data.

* --4-- Upload

  CONCATENATE p_folder gv_dotname_cofile
  INTO gv_front_path_cofile.

  CONCATENATE p_folder gv_dotname_data
  INTO gv_front_path_data.

  " Upload Cofile :

  PERFORM upload_file
  USING gv_path_cofile
        gv_front_path_cofile
        gv_err.

  CHECK gv_err IS INITIAL.

  " Upload Data :

  PERFORM upload_file
  USING gv_path_data
        gv_front_path_data
        gv_err.


FORM upload_file
USING ip_server_path
      ip_front_path
      ep_err.

  DATA lv_server_path LIKE sapb-sappfad.
  DATA lv_front_path  LIKE sapb-sappfad.

  CLEAR ep_err.

  lv_server_path = ip_server_path.
  lv_front_path  = ip_front_path.

  CALL FUNCTION 'ARCHIVFILE_CLIENT_TO_SERVER'
    EXPORTING
      path             = lv_front_path
      targetpath       = lv_server_path
    EXCEPTIONS
      error_file       = 1
      no_authorization = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    WRITE  'Error uploading file'.
    ep_err = 'X'.
  ENDIF.

ENDFORM.
