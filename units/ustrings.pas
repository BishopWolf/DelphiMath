{ ******************************************************************
  Pascal string routines
  ****************************************************************** }

Unit ustrings;

Interface

Uses
  utypes, uComplex, uConstants;

Function LTrim(S: String; C: Char = ' '): String;
{ ------------------------------------------------------------------
  Removes leading blanks
  ------------------------------------------------------------------ }

Function RTrim(S: String; C: Char = ' '): String;
{ ------------------------------------------------------------------
  Removes trailing blanks
  ------------------------------------------------------------------ }

Function Trim(S: String; C: Char = ' '): String;
{ ------------------------------------------------------------------
  Removes leading and trailing blanks
  ------------------------------------------------------------------ }

Function StrChar(N: Byte; C: Char): String;
{ ------------------------------------------------------------------
  Returns a string made of character C repeated N times
  ------------------------------------------------------------------ }

Function RFill(S: String; L: Byte): String;
{ ------------------------------------------------------------------
  Completes string S with trailing blanks for a total length L
  ------------------------------------------------------------------ }

Function LFill(S: String; L: Byte): String;
{ ------------------------------------------------------------------
  Completes string S with leading blanks for a total length L
  ------------------------------------------------------------------ }

Function CFill(S: String; L: Byte): String;
{ ------------------------------------------------------------------
  Completes string S with leading blanks
  to center the string on a total length L
  ------------------------------------------------------------------ }

Function ReplaceChar(S: String; C1, C2: Char): String; Overload;
Function ReplaceString(S: String; C1, C2: String): String; Overload;
{ ------------------------------------------------------------------
  Replaces in string S all the occurences
  - of character C1 by character C2
  - of string C1 by string C2
  ------------------------------------------------------------------ }

Function Extract(S: String; Var Index: Byte; Delim: Char;
  ConsecutiveAsOne: Boolean = true): String;
{ ------------------------------------------------------------------
  Extracts a field from a string. Index is the position of the first
  character of the field. Delim is the character used to separate
  fields (e.g. blank, comma or tabulation). Blanks immediately
  following Delim are ignored. Index is updated to the position of
  the next field.
  ------------------------------------------------------------------ }

Procedure Parse(S: String; Delim: Char; Out Field: TStrVector; Var N: Byte);
{ ------------------------------------------------------------------
  Parses a string into its constitutive fields. Delim is the field
  separator. The number of fields is returned in N. The fields are
  returned in Field[0]..Field[N - 1]. Field must be dimensioned in
  the calling program.
  ------------------------------------------------------------------ }

Function Split(S: String; Delim: Char): TStrVector;

Procedure SetFormat(NumLength, MaxDec: Integer; FloatPoint, NSZero: Boolean);
{ ------------------------------------------------------------------
  Sets the numeric format

  NumLength  = Length of numeric field
  MaxDec     = Max. number of decimal places
  FloatPoint = True for floating point notation
  NSZero     = True to write non significant zero's
  ------------------------------------------------------------------ }

Function Float2Str(X: Float): String;
Function Float2Hex(Const D: Float): String;
Function Hex2Float(Const Hex: String): Float;
{ ------------------------------------------------------------------
  Converts a real to a string according to the numeric format
  ------------------------------------------------------------------ }

Function Int2Str(N: LongInt): String;
Function Word2Str(W: Word): String;
{ ------------------------------------------------------------------
  Converts an integer to a string
  ------------------------------------------------------------------ }

{ Added by Alex Vergara Gil }
Function CountDelim(str: String; Delim: Char;
  ConsecutiveAsOne: Boolean = true): Integer;
{ ------------------------------------------------------------------
  counts the number of times the char Delim appears on Str
  ------------------------------------------------------------------ }

Function ArreglaString(str: String): String;
{ ------------------------------------------------------------------
  Fixes a string floating point representation to accomplish local
  configuration of the comma
  ------------------------------------------------------------------ }

Function StrconPunto(str: String): String;
{ ------------------------------------------------------------------
  Fixes a string floating point representation to accomplish local
  configuration of the comma
  ------------------------------------------------------------------ }

Function stripped(stripchar: Char; str: String): String;
{ ------------------------------------------------------------------
  Eliminates all the ocurrences of character stripchar from string str
  ------------------------------------------------------------------ }

Function strippedword(stripword, str: String): String;
{ ------------------------------------------------------------------
  Eliminates all the ocurrences of string stripword from string str
  ------------------------------------------------------------------ }

Function GetFileExt(FileName: String; setUppercase: Boolean = false): String;
{ ------------------------------------------------------------------
  Returns the file extension
  ------------------------------------------------------------------ }

Function ParseFileName(lFilewExt: String): String;
{ ------------------------------------------------------------------
  Returns the file name
  ------------------------------------------------------------------ }

Function StrCompare(S1, S2: String; MatchCase: Boolean = false): Boolean;
{ ------------------------------------------------------------------
  Compares two strings
  ------------------------------------------------------------------ }

Function FindString(S1: String; S2: TStrVector; Ub: Integer; Out Size: Integer)
  : TStrVector;
{ ------------------------------------------------------------------
  finds a string in a string list
  ------------------------------------------------------------------ }

Function Str2Float(S: String): Float;

{ ------------------------------------------------------------------
  Converts a string to a real according to the numeric format
  ------------------------------------------------------------------ }

Function Str2Int(S: String): Integer;
Function Str2Word(S: String): Word;
{ ------------------------------------------------------------------
  Converts a string to a Integer according to the numeric format
  ------------------------------------------------------------------ }

Function Str2Bool(S: String): Boolean;
Function Bool2Str(B: Boolean): String;

Function Comma: Char; // símbolo decimal  -  Comma

Implementation

Uses Math, Sysutils, uoperations;

{$IFDEF _16BIT}Const {$ELSE}Var {$ENDIF}
  gNumLength: Integer = 10;
  gMaxDec: Integer = 4;
  gFloatPoint: Boolean = false;
  gNSZero: Boolean = false;

Function LTrim(S: String; C: Char): String;
Begin
  If S <> '' Then
    While S[1] = C Do
      Delete(S, 1, 1);
  LTrim := S;
End;

Function RTrim(S: String; C: Char): String;
Var
  L1: Byte;
Begin
  If S <> '' Then
  Begin
    L1 := Length(S);
    While S[L1] = C Do
    Begin
      Delete(S, L1, 1);
      Dec(L1);
    End;
  End;
  RTrim := S;
End;

Function Trim(S: String; C: Char): String;
Begin
  Trim := LTrim(RTrim(S, C), C);
End;

Function StrChar(N: Byte; C: Char): String;
Var
  I: Byte;
  S: String;
Begin
  S := '';
  For I := 1 To N Do
    S := S + C;
  StrChar := S;
End;

Function RFill(S: String; L: Byte): String;
Var
  L1: Byte;
Begin
  L1 := Length(S);
  If L1 >= L Then
    RFill := S
  Else
    RFill := S + StrChar(L - L1, ' ');
End;

Function LFill(S: String; L: Byte): String;
Var
  L1: Byte;
Begin
  L1 := Length(S);
  If L1 >= L Then
    LFill := S
  Else
    LFill := StrChar(L - L1, ' ') + S;
End;

Function CFill(S: String; L: Byte): String;
Var
  L1: Byte;
Begin
  L1 := Length(S);
  If L1 >= L Then
    CFill := S
  Else
    CFill := StrChar((L - L1) Div 2, ' ') + S;
End;

Function ReplaceChar(S: String; C1, C2: Char): String;
Var
  S1: String;
  K: Byte;
Begin
  S1 := S;
  K := Pos(C1, S1);
  While K > 0 Do
  Begin
    S1[K] := C2;
    K := Pos(C1, S1);
  End;
  ReplaceChar := S1;
End;

Function ReplaceString(S: String; C1, C2: String): String;
Var
  S1, preffix, suffix: String;
  K, L, L1: Byte;
Begin
  S1 := S;
  K := Pos(C1, S1);
  If K = 0 Then
  Begin
    ReplaceString := S1;
    exit;
  End;
  L := Length(S1);
  L1 := Length(C1);
  preffix := Copy(S1, 1, K - 1);
  suffix := Copy(S1, K + L1, L - K - L1 + 1);
  ReplaceString := preffix + C2 + ReplaceString(suffix, C1, C2);
End;

Function Extract(S: String; Var Index: Byte; Delim: Char;
  ConsecutiveAsOne: Boolean): String;
Var
  I, L: Byte;
  str: String;
Begin
  Repeat
    str := Trim(S); // remove spaces
    str := Trim(str, Delim); // remove superfluous delims
  Until ((str[1] <> ' ') And (str[1] <> Delim));

  I := Index;
  L := Length(str);

  { Search for Delim }
  While (I <= L) And (str[I] <> Delim) Do
    Inc(I);

  { Extract field }
  If I = Index Then
    Extract := ''
  Else
    Extract := Copy(str, Index, I - Index);

  { Skip blanks after Delim }
  Repeat
    Inc(I);
  Until (I > L) Or (str[I] <> ' ') Or ((str[I] <> Delim) And ConsecutiveAsOne);

  { Update Index }
  Index := I;
End;

Procedure Parse(S: String; Delim: Char; Out Field: TStrVector; Var N: Byte);
Var
  I, Index: Byte;
Begin
  Index := 1;
  N := CountDelim(S, Delim) + 1;
  DimVector(Field, N);
  For I := 1 To N Do
    Field[I] := Extract(S, Index, Delim);
End;

Function Split(S: String; Delim: Char): TStrVector;
Var
  I, Index, N: Byte;
  Field: TStrVector;
Begin
  Index := 1;
  N := CountDelim(S, Delim) + 1;
  DimVector(Field, N);
  For I := 1 To N Do
    Field[I] := Extract(S, Index, Delim);
  Split := Field;
End;

Procedure SetFormat(NumLength, MaxDec: Integer; FloatPoint, NSZero: Boolean);
Begin
  If (NumLength >= 1) And (NumLength <= 80) Then
    gNumLength := NumLength;
  If (MaxDec >= 0) And (MaxDec <= 20) Then
    gMaxDec := MaxDec;

  gFloatPoint := FloatPoint;
  gNSZero := NSZero;
End;

Function RemZero(S: String): String;
Var
  I: Integer;
  S1, S2: String;
  C: Char;
Begin
  I := Pos(Comma, S);

  If I = 0 Then
  Begin
    RemZero := S;
    exit
  End;

  I := Pos('E', S);
  If I = 0 Then
    I := Pos('e', S);

  If I > 0 Then
  Begin
    S1 := Copy(S, 1, I - 1);
    S2 := Copy(S, I, Length(S) - I + 1)
  End
  Else
  Begin
    S1 := S;
    S2 := ''
  End;

  Repeat
    I := Length(S1);
    C := S1[I];
    If (C = '0') Or (C = Comma) Then
      S1 := Copy(S1, 1, I - 1);
  Until C <> '0';

  RemZero := S1 + S2
End;

Function Float2Str(X: Float): String;
Var
  S: String;
Begin
  If gFloatPoint Then
  Begin
    str(X: Pred(gNumLength), S);
    S := ' ' + S;
  End
  Else
    str(X: gNumLength: gMaxDec, S);

  If Not gNSZero Then
    S := RemZero(S);

  Float2Str := S;
End;

Function Int2Str(N: LongInt): String;
Var
  S: String;
Begin
  str(N: (gNumLength - gMaxDec - 1), S);
  Int2Str := S;
End;

Function Word2Str(W: Word): String;
Var
  S: String;
Begin
  str(W: (gNumLength - gMaxDec - 1), S);
  Word2Str := S;
End;

Var
  p: Integer;

Function StrconPunto(str: String): String;
Begin
  p := Pos(',', str);
  If p > 0 Then
    result := Copy(str, 1, p - 1) + '.' { Comma } +
      Copy(str, p + 1, Length(str) - p)
  Else
    result := str; // NAN  or  Integer
End;

Function ArreglaString(str: String): String;
Begin
  str := stripped('þ', stripped('ÿ', stripped(#0, Trim(str))));
  // remove all noise
  p := Pos(Comma, str);
  If p > 0 Then
    result := Copy(str, 1, p - 1) + '.' + Copy(str, p + 1, Length(str) - p)
  Else
  Begin
    p := Pos('.', str);
    If p > 0 Then
      result := str
      // Copy(str, 1, p - 1) + '.' + Copy(str, p + 1, Length(str) - p)
    Else
    Begin
      p := Pos(',', str);
      If p > 0 Then
        result := Copy(str, 1, p - 1) + '.' + Copy(str, p + 1, Length(str) - p)
      Else
        result := str; // NAN  or  Integer
    End;
  End;
End;

Function strippedword(stripword, str: String): String;
Var
  tmpstr: String;
Begin
  tmpstr := str;
  While Pos(stripword, tmpstr) > 0 Do
    Delete(tmpstr, Pos(stripword, tmpstr), Length(stripword));
  strippedword := tmpstr;
End;

Function stripped(stripchar: Char; str: String): String;
Var
  tmpstr: String;
Begin
  tmpstr := str;
  While Pos(stripchar, tmpstr) > 0 Do
    Delete(tmpstr, Pos(stripchar, tmpstr), 1);
  stripped := tmpstr;
End;

Function GetFileExt(FileName: String; setUppercase: Boolean): String;
Begin
  result := stripped('.', strippedword(ChangeFileExt(FileName, ''), FileName));
  If setUppercase Then
    result := UpperCase(result);
  // if Length(result)>4 then // Extension non conformable
  // result:='';
End;

Function Str2Float(S: String): Float;
Var
  code: Integer;
  X: Float;
Begin
  val(ArreglaString(S), X, code);
  If code = 0 Then
    result := DefaultVal(FOk, X)
  Else
  Begin
    // result := DefaultVal(FNAN, X);
    Raise EConvertError.Create('Unable to convert the string ' + S +
      ' to a number');
  End;
End;

Function ParseFileName(lFilewExt: String): String;
Var
  lLen, lInc: Integer;
  lName: String;
Begin
  lName := '';
  lLen := Length(lFilewExt);
  lInc := lLen + 1;
  If lLen > 0 Then
    Repeat
      Dec(lInc);
    Until (lFilewExt[lInc] = '.') Or (lInc = 1);
  If lInc > 1 Then
    For lLen := 1 To (lInc - 1) Do
      lName := lName + lFilewExt[lLen]
  Else
    lName := lFilewExt; // no extension
  ParseFileName := lName;
End;

// --------------------------------------------------------------------------------------------------
Const
  lfloatsize = SizeOf(Float);
  // Sizeof(float) can be:
  // 4 (single)
  // 6 (real48)
  // 8 (double)
  // 10 (extended)

Function Float2Hex(Const D: Float): String;
Var
  Overlay: Array [1 .. lfloatsize] Of Byte Absolute D;
  I: Byte;
Begin
  // Look at last element before first because of "Little Endian" order.
  result := '';
  For I := lfloatsize Downto 1 Do
  Begin
    result := result + IntToHex(Overlay[I], 2); // 1 byte contains 2 chars
  End;
End;

// --------------------------------------------------------------------------------------------------

Function Hex2Float(Const Hex: String): Float;
Var
  D: Float;
  temp: String;
  I: Byte;
  Overlay: Array [1 .. lfloatsize] Of Byte Absolute D;
Begin
  I := lfloatsize Shl 1;
  temp := Hex;
  If Length(temp) > I Then
  Begin
    temp := Copy(temp, 1, I);
  End;
  While Length(temp) <> I Do
  Begin
    temp := temp + '0'; // "Little Endian" order.
  End;
  For I := 1 To lfloatsize Do
  Begin
    Overlay[I] := StrToInt('$' + Copy(temp, (lfloatsize - I) * 2 + 1, 2));
  End;
  result := D;
End;

Function Str2Int(S: String): Integer;
Var
  code: Integer;
  X: Integer;
Begin
  val(ArreglaString(S), X, code);
  If code = 0 Then
    result := DefaultIntVal(FOk, X)
  Else
  Begin
    result := DefaultIntVal(FNAN, X);
    { raise EConvertError.Create('Unable to convert the string ' + S +
      ' to a number'); }
  End;
End;

Function Str2Word(S: String): Word;
Var
  code: Integer;
  X: Word;
Begin
  val(ArreglaString(S), X, code);
  If code = 0 Then
    result := DefaultIntVal(FOk, X)
  Else
  Begin
    // result := DefaultIntVal(FNAN, X);
    Raise EConvertError.Create('Unable to convert the string ' + S +
      ' to a number');
  End;
End;

Function CountDelim(str: String; Delim: Char;
  ConsecutiveAsOne: Boolean): Integer;
Var
  I: Integer;
  S: String;
Begin
  result := 0;
  Repeat
    S := Trim(str); // remove spaces
    S := Trim(S, Delim); // remove superfluous delims
  Until ((S[1] <> ' ') And (S[1] <> Delim));
  If ConsecutiveAsOne Then
  Begin
    For I := 1 To Length(S) - 1 Do
      If ((S[I] = Delim) And (S[I + 1] <> Delim)) Then
        Inc(result);
    If (S[Length(S)] = Delim) And (S[Length(S) - 1] <> Delim) Then
      Inc(result);
  End
  Else
  Begin
    For I := 1 To Length(S) Do
      If (S[I] = Delim) Then
        Inc(result);
  End;
End;

Function StrCompare(S1, S2: String; MatchCase: Boolean): Boolean;
Var
  I: Integer;
  ts1, ts2: String;
Begin
  // remove all noise
  ts1 := stripped(' ', stripped(#0, S1));
  ts2 := stripped(' ', stripped(#0, S2));

  If (Length(ts1) = Length(ts2)) Then
  Begin

    If Not MatchCase Then
    Begin
      ts1 := AnsiLowerCase(ts1);
      ts2 := AnsiLowerCase(ts2);
    End;
    result := true;
    For I := 0 To Length(ts1) - 1 Do
      If ts1[I] <> ts2[I] Then
        result := false;

  End
  Else
    result := false;
End;

Function FindString(S1: String; S2: TStrVector; Ub: Integer; Out Size: Integer)
  : TStrVector;
Var
  I, t1, t2: Integer;
  line: String;
Begin
  DimVector(result, 0);
  Size := 0;
  For I := 1 To Ub Do
    If Pos(S1, S2[I]) > 0 Then
    Begin
      t1 := Pos(S1, S2[I]);
      t2 := t1 + Length(S1);
      line := format('%s/%s/%s', [Copy(S2[I], 1, t1 - 1), S1,
        Copy(S2[I], t2, Length(S2[I]) - t2 + 1)]);
      Append(result, Size, line);
    End;
End;

Function Comma: Char;
Var
  S: String;
Begin
  S := floattoStr(Pi);
  // if pos('.',s)>0 then Comma:='.' else
  // if pos(',',s)>0 then Comma:=',' else
  Comma := S[2];
End;

Function Str2Bool(S: String): Boolean;
Begin
  If StrCompare(S, 'TRUE') Then
    result := true
  Else
    result := false;
End;

Function Bool2Str(B: Boolean): String;
Begin
  If B Then
    result := 'TRUE'
  Else
    result := 'FALSE';
End;

Begin
  SetFormat(10, 8, false, false);

End.
