Unit uLUT;

Interface

Uses windows, SysUtils;

Type
  TLUTtype = (TLTLUT, TLTBW, TLTfusion);

  TLUT = Record
  Private
    lut_arr: Array [byte] Of TRGBTriple;
    FName: String;
    Function FMaxColor: COLORREF;
    Function FMinColor: COLORREF;
    Procedure FireLUT(lIntensity, lTotal: integer; index: byte);
    Procedure loadRGB(ind, lR, lG, lB: byte);
    Function GetElemento(ind: byte): TRGBTriple;
    Procedure SetElemento(ind: byte; Const Value: TRGBTriple);
    procedure SetName(const Value: String);
  Public
    Property Elemento[ind: byte]: TRGBTriple Read GetElemento
      Write SetElemento; Default;
    Property Name: String read FName write SetName;
    Procedure LoadColorScheme(lStr: String; lScheme: integer);
    Property MinColor: COLORREF Read FMinColor;
    Property MaxColor: COLORREF Read FMaxColor;
    Function Color(lindex: byte): COLORREF;
  End;

Implementation

Uses ustrings, math, utypes, uConstants;

{ TLUT }

Function TLUT.Color(lindex: byte): COLORREF;
Begin
  result := RGB(lut_arr[lindex].rgbtRed, lut_arr[lindex].rgbtGreen,
    lut_arr[lindex].rgbtBlue);
End;

Procedure TLUT.FireLUT(lIntensity, lTotal: integer; index: byte);
// Generates a 'hot metal' style color lookup table
Var
  l255scale: integer;
  lR, lG, lB: byte;
Begin
  l255scale := round(lIntensity / lTotal * 255);
  lR := (l255scale - 52) * 3;
  lG := (l255scale - 108) * 2;
  Case l255scale Of
    0 .. 55:
      lB := (l255scale * 4);
    56 .. 118:
      lB := 220 - ((l255scale - 55) * 3);
    119 .. 235:
      lB := 0;
  Else
    lB := ((l255scale - 235) * 10);
  End; { case }
  lR := EnsureRange(lR, 0, 255);
  lG := EnsureRange(lG, 0, 255);
  lB := EnsureRange(lB, 0, 255);
  loadRGB(Index, lR, lG, lB);
End;

Function TLUT.FMaxColor: COLORREF;
Begin
  result := RGB(lut_arr[255].rgbtRed, lut_arr[255].rgbtGreen,
    lut_arr[255].rgbtBlue);
End;

Function TLUT.FMinColor: COLORREF;
Begin
  FMinColor := RGB(lut_arr[0].rgbtRed, lut_arr[0].rgbtGreen,
    lut_arr[0].rgbtBlue);
End;

Function TLUT.GetElemento(ind: byte): TRGBTriple;
Begin
  result := lut_arr[ind];
End;

Procedure TLUT.LoadColorScheme(lStr: String; lScheme: integer);
// Loads a color lookup tabel from disk.
// Lookup tables can either be in Osiris format (TEXT) or ImageJ format (BINARY: 768 bytes)
// outputs a LUT record containing gRra,gGra,gBra: array [0..255] of byte;
Const
  UNIXeoln = chr(10);
Var
  lF: textfile;
  lBuff: bytep0;
  lFdata: File;
  lCh: char;
  lNumStr: String;
  lZ: integer;
  lByte, lindex, lRed, lBlue, lGreen: byte;
  lType, lIndx, lLong, lR, lG, lB: boolean;
  Procedure ResetBools;
  Begin
    lType := false;
    lIndx := false;
    lR := false;
    lG := false;
    lB := false;
    lNumStr := '';
  End;

Begin
  If lScheme < 3 Then
  Begin
    // AUTOGENERATE LUT 0/1/2 are internally generated: do not read from disk
    Case lScheme Of
      0:
        For lZ := 0 To 255 Do
        Begin
          // 1: low intensity=white, high intensity = black
          loadRGB(lZ, 255 - lZ, 255 - lZ, 255 - lZ);
        End;
      1:
        For lZ := 0 To 255 Do
        Begin
          // 1: low intensity=black, high intensity = white
          loadRGB(lZ, lZ, lZ, lZ);
        End;
      2:
        For lZ := 0 To 255 Do
        Begin // Hot metal LUT
          FireLUT(lZ, 255, lZ);
        End;
    Else
    End; // case
    exit;
  End; // AUTOGENERATE LUT
  lindex := 0;
  lRed := 0;
  lGreen := 0;
  If Not fileexists(lStr) Then
    exit;
  assignfile(lFdata, lStr);
  filemode := 0;
  reset(lFdata, 1);
  lZ := FileSize(lFdata);
  If (lZ = 768) Or (lZ = 800) Or (lZ = 970) Then
  Begin
    // read ImageJ format
    GetMem(lBuff, 768);
    Seek(lFdata, lZ - 768);
    BlockRead(lFdata, lBuff^, 768);
    closeFile(lFdata);
    For lZ := 0 To 255 Do
    Begin
      loadRGB(lZ, lBuff[lZ], lBuff[lZ + 256], lBuff[lZ + 512]);
    End;
    freemem(lBuff);
    exit;
  End;
  // Not ImageJ format -> continue
  closeFile(lFdata);
  lLong := false;
  assignfile(lF, lStr);
  filemode := 0;
  reset(lF);
  ResetBools;
  For lByte := 0 To 255 Do
    loadRGB(lByte, 0, 0, 0);

  (* begin Osiris format reader *)
  While Not EOF(lF) Do
  Begin
    Read(lF, lCh);
    If lCh = '*' Then
      // comment character
      While (Not EOF(lF)) And (lCh <> kCR) And (lCh <> UNIXeoln) Do
        Read(lF, lCh);
    If (lCh = 'L') Or (lCh = 'l') Then
    Begin
      lType := true;
      lLong := true;
    End;
    // 'l'
    If (lCh = 's') Or (lCh = 'S') Then
    Begin
      lType := true;
      lLong := false;
    End;
    // 's'
    If charinset(lCh, ['0' .. '9']) Then
      lNumStr := lNumStr + lCh;
    // note on next line: revised 9/9/2003: will read final line of text even if EOF instead of EOLN for final index
    If (Not(charinset(lCh, ['0' .. '9'])) Or (EOF(lF))) And
      (length(lNumStr) > 0) Then
    Begin // not a number = space??? try to read number string
      If Not lIndx Then
      Begin
        lindex := Str2Int(lNumStr);
        lIndx := true;
      End
      Else
      Begin // not index
        If lLong Then
          lByte := trunc(Str2Int(lNumStr) / 256)
        Else
          lByte := Str2Int(lNumStr);
        If Not lR Then
        Begin
          lRed := lByte;
          lR := true;
        End
        Else If Not lG Then
        Begin
          lGreen := lByte;
          lG := true;
        End
        Else If Not lB Then
        Begin
          lBlue := lByte;
          lB := true;
          loadRGB(lindex, lRed, lGreen, lBlue);
          ResetBools;
        End;
      End;
      lNumStr := '';
    End;
  End;
  // until EOF(lF); //not eof
  (* end osiris reader *)

  closeFile(lF);
  filemode := 2;
End;

Procedure TLUT.loadRGB(ind, lR, lG, lB: byte);
Begin
  lut_arr[ind].rgbtRed := lR;
  lut_arr[ind].rgbtGreen := lG;
  lut_arr[ind].rgbtBlue := lB;
End;

Procedure TLUT.SetElemento(ind: byte; Const Value: TRGBTriple);
Begin
  lut_arr[ind].rgbtRed := Value.rgbtRed;
  lut_arr[ind].rgbtGreen := Value.rgbtGreen;
  lut_arr[ind].rgbtBlue := Value.rgbtBlue;
End;

procedure TLUT.SetName(const Value: String);
begin
  FName := Value;
end;

End.
