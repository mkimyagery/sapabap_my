*&---------------------------------------------------------------------*
*& Report ZABAP_EGITIM_004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_egitim_04.


SELECT sflight~carrid,
       sflight~connid,
       scarr~carrname
  FROM sflight INNER JOIN scarr
  ON sflight~carrid = scarr~carrid  INTO TABLE @DATA(it_output).

cl_demo_output=>display( it_output ).

**********************************************************************

SELECT sflight~carrid,
       sflight~connid,
       scarr~carrname
  FROM sflight LEFT OUTER JOIN scarr
  ON sflight~carrid = scarr~carrid  INTO TABLE @DATA(it_output2).


cl_demo_output=>display( it_output2 ).

**********************************************************************

SELECT sflight~carrid,
       sflight~connid,
       scarr~carrname,
  spfli~cityfrom,
  spfli~cityto
  FROM sflight LEFT OUTER JOIN scarr
  ON sflight~carrid = scarr~carrid
  INNER JOIN spfli ON  sflight~carrid = spfli~carrid
    INTO TABLE @DATA(it_output3).


cl_demo_output=>display( it_output3 ).

clear:it_output, it_output2, it_output3.


BREAK-POINT.
