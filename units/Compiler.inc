// Compiler Select

{
  Available Compilers:
  --------------------

  COMPILERFPC  - FPC (since version 2.6.0)
  COMPILER6    - Delphi 6
  COMPILER7    - Delphi 7
  COMPILER2005 - Delphi 2005
  COMPILER2006 - Delphi 2006 / BDS 2006
  COMPILER2007 - Delphi / RAD Studio 2007
  COMPILER2009 - Delphi 2009
  COMPILER2010 - Delphi 2010
  COMPILERXE1  - Delphi XE
  COMPILERXE2  - Delphi XE2
  COMPILERXE5  - Delphi XE5
  COMPILERXE7  - Delphi XE7
}

Const
{$IFDEF VER280}
{$DEFINE COMPILERXE7}
  BDS_VER = 15;
{$IFNDEF BCB}
{$DEFINE DELPHIXE1}
{$DEFINE DELPHIXE2}
{$DEFINE DELPHIXE3}
{$DEFINE DELPHIXE4}
{$DEFINE DELPHIXE5}
{$DEFINE DELPHIXE6}
{$DEFINE DELPHIXE7}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER260}
{$DEFINE COMPILERXE7}
  BDS_VER = 14;
{$IFNDEF BCB}
{$DEFINE DELPHIXE1}
{$DEFINE DELPHIXE2}
{$DEFINE DELPHIXE3}
{$DEFINE DELPHIXE4}
{$DEFINE DELPHIXE5}
{$DEFINE DELPHIXE6}
{$DEFINE DELPHIXE7}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER230}
{$DEFINE COMPILERXE2}
  BDS_VER = 12;
{$IFNDEF BCB}
{$DEFINE DELPHIXE1}
{$DEFINE DELPHIXE2}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER220}
{$DEFINE COMPILERXE1}
  BDS_VER = 11;
{$IFNDEF BCB}
{$DEFINE DELPHIXE1}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER210}
{$DEFINE COMPILER2010}
  BDS_VER = 10;
{$IFNDEF BCB}
{$DEFINE DELPHI2010}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER200}
{$DEFINE COMPILER2009}
  BDS_VER = 9;
{$IFNDEF BCB}
{$DEFINE DELPHI2009}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER185}
{$DEFINE COMPILER2007}
  BDS_VER = 7;
{$IFNDEF BCB}
{$DEFINE DELPHI2007}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER180}
{$DEFINE COMPILER2006}
  BDS_VER = 6;
{$IFNDEF BCB}
{$DEFINE DELPHI2006}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER170}
{$DEFINE COMPILER2005}
  BDS_VER = 5;
{$IFNDEF BCB}
{$DEFINE DELPHI2005}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER150}
{$DEFINE COMPILER7}
  BDS_VER = 4;
{$IFNDEF BCB}
{$DEFINE DELPHI7}
{$ELSE}
{$DEFINE BCB7}
{$ENDIF}
{$ENDIF}
{$IFDEF VER140}
{$DEFINE COMPILER6}
  BDS_VER = 3;
{$IFNDEF BCB}
{$DEFINE DELPHI6}
{$ELSE}
{$DEFINE BCB6}
{$ENDIF}
{$ENDIF}
{$IFDEF FPC}
{$DEFINE COMPILERFPC}
  BDS_VER = 0;
{$ENDIF}
  (*
    Symbol INLININGSUPPORTED:
    -------------------------

    In later Delphi versions procedures and functions that do not contain
    assembler code can be inlined. This can be extremely useful for calls
    to a small portion of code in a loop. However, depending on the instruction
    cache size, this may or may not result in a performance boost compared to a
    call of assembler optimized code.
  *)

{$IF BDS_VER>=7}
  // disabled prior Delphi versions due to a compiler bug
  // see (http://qc.embarcadero.com/wc/qcmain.aspx?d=41166)
{$DEFINE INLININGSUPPORTED}
{$IFEND}
{$IFDEF COMPILERFPC}
{$DEFINE INLININGSUPPORTED}
{$ENDIF}
