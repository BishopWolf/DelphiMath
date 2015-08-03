unit P10Build;

{$I+} { I/O checking is always on }
{$DEFINE UseIntegerOP}
// NOTE: Removed old and buggy code for Dyna conditional define - HV

interface

uses
  Parser10,
  SysUtils, Classes;

procedure ParseFunction(FunctionString: string; { the unparsed string }
  Variables: TStringlist; { list of variables }

  { lists of available functions }
  FunctionOne, { functions with ONE argument, e.g. exp() }
  FunctionTwo: TStringlist; { functions with TWO arguments, e.g. max(,) }

  UsePascalNumbers: boolean; { true: -> Val; false: StrToFloat }

  { return pointer to tree, number of performed operations and error state }
  var FirstOP: POperation;

  var Error: boolean);
{ error actually is superfluous as we are now using exceptions }

implementation

uses uConstants;

{ helper functions }

var
  CharTable: array [#0 .. #255] of byte;

  (* function RemoveBlanks(const s: string): string;
    { deletes all blanks in s }
    var
    i : integer;
    begin
    Result := s;

    i := pos(' ', Result);
    while i > 0 do
    begin
    delete(Result, i, 1);
    i := pos(' ', Result);
    end;
    end; *)

function TryStrToFloat(const S: string; var Value: float): boolean;
var
  ExtValue: extended;
begin
  Result := TextToFloat(PChar(S), ExtValue, fvExtended);
  if Result then
    Value := ExtValue;
end;

function HackSetLength(var S: String; NewLen: Integer): Integer;
type
  PInteger = ^Integer;
begin
  Result := Length(S);
{$IFDEF win64}
  PInteger(int64(S) - 4)^ := NewLen;
{$ELSE}
  PInteger(Longint(S) - 4)^ := NewLen;
{$ENDIF}
end;

{ case INSENSITIVE }
procedure MakeCharTable;
var
  I: Integer;
begin
  for I := 0 to 255 do
  begin
    If (I > 64) and (I < 91) then
      CharTable[Char(I)] := I + 32
    else
      CharTable[Char(I)] := I;
  end;
end; { MakeCharTable }

{$IFDEF PIC}
{$OPTIMIZATION OFF}
{$ENDIF}

function IPos(Pat, Text: PChar): Integer;
var
  RunPat, RunText, PosPtr: PChar;
begin
  Result := 0;
  RunPat := Pat;
  RunText := Text;
  while RunText^ <> #0 do
  begin
    if (CharTable[RunPat^] = CharTable[RunText^]) then
    begin
      PosPtr := RunText;
      while RunPat^ <> #0 do
      begin
        if (CharTable[RunPat^] <> CharTable[RunText^]) then
          break;
        inc(RunPat);
        inc(RunText);
      end;
      if RunPat^ = #0 then
      begin
        Result := PosPtr - Text + 1;
        break;
      end;
    end
    else
      inc(RunText);
    RunPat := Pat;
  end;
end; { IPos }

function IPosE(Pat, Text: PChar; StartPos, MaxPos: Longint): Integer;
var
  AChar: Char;

  RunPat, RunText, PosPtr: PChar;
begin
  Result := 0;
  RunPat := Pat;

  RunText := Text + MaxPos;
  AChar := RunText^;
  RunText^ := #0;

  RunText := Text + StartPos - 1;

  while RunText^ <> #0 do
  begin
    if (CharTable[RunPat^] = CharTable[RunText^]) then
    begin
      PosPtr := RunText;

      while RunPat^ <> #0 do
      begin
        if (CharTable[RunPat^] <> CharTable[RunText^]) then
          break;

        inc(RunPat);
        inc(RunText);
      end;

      if (RunPat^ = #0) then
      begin
        Result := PosPtr - Text + 1;
        break;
      end;

    end
    else
      inc(RunText);

    RunPat := Pat;
  end;

  RunText := Text + MaxPos;
  RunText^ := AChar;

end; { IPosE }

{$IFDEF PIC}
{$OPTIMIZATION ON}
{$ENDIF}

function FastPos(Sign: Char; ToScan: PChar): Integer;
var
  Input: PChar;
begin
  Result := 0;
  Input := ToScan;
  while (ToScan^ <> #0) do
  begin
    if ToScan^ = Sign then
    begin
      Result := ToScan - Input;
      break;
    end;
    inc(ToScan);
  end;
end;

{$IFDEF VER100}

resourcestring
{$ELSE}
const
{$ENDIF}
  msgErrBlanks = 'Expression has blanks';
  msgMissingBrackets = 'Missing brackets in expression (%s)';
  msgParseError = 'Error parsing expression:';
  msgNestings = 'Expression contains too many nestings';
  msgTooComplex = 'Expression is too complex';
  msgInternalError = 'TParser internal error';

const
  TokenOperators = [sum, diff, prod, divis, modulo, IntDiv, integerpower,
    realpower];

type
  TermString = string;

procedure ParseFunction(FunctionString: string; Variables: TStringlist;

  FunctionOne, FunctionTwo: TStringlist;

  UsePascalNumbers: boolean;

  var FirstOP: POperation;

  var Error: boolean);

function CheckNumberBrackets(const S: string): Integer; forward;
{ checks whether number of ( = number of ) }

function CheckNumber(const S: string; var FloatNumber: ParserFloat)
  : boolean; forward;
{ checks whether s is a number }

function CheckVariable(const S: string; var VariableID: Integer)
  : boolean; forward;
{ checks whether s is a variable string }

function CheckTerm(var s1: string): boolean; forward;
{ checks whether s is a valid term }

function CheckBracket(const S: string; var s1: string): boolean; forward;
{ checks whether s =(...(s1)...) and s1 is a valid term }

function CheckNegate(const S: string; var s1: string): boolean; forward;
{ checks whether s denotes the negative value of a valid operation }

function CheckAdd(var S: string; var s1, s2: string): boolean; forward;
{ checks whether + is the primary operation in s }

function CheckSubtract(const S: string; var s1, s2: string): boolean; forward;
{ checks whether - is the primary operation in s }

function CheckMultiply(const S: string; var s1, s2: string): boolean; forward;
{ checks whether * is the primary operation in s }

{$IFDEF UseIntegerOP}
function CheckIntegerDiv(const S: string; var s1, s2: string): boolean; forward;
{ checks whether DIV is the primary TOperation in s }

function CheckModulo(const S: string; var s1, s2: string): boolean; forward;
{ checks whether MOD is the primary TOperation in s }
{$ENDIF UseIntegerOP}
function CheckRealDivision(const S: string; var s1, s2: string)
  : boolean; forward;
{ checks whether / is the primary operation in s }

function CheckFuncTwoVar(var S: string; var s1, s2: string): boolean; forward;
{ checks whether s=f(s1,s2); s1,s2 being valid terms }

function CheckFuncOneVar(var S: string; var s1: string): boolean; forward;
{ checks whether s denotes the evaluation of a function fsort(s1) }

function CheckPower(const S: string; var s1, s2: string; var AToken: TToken)
  : boolean; forward;

  function CheckNumberBrackets(const S: string): Integer;
  { checks whether # of '(' equ. # of ')' }
  var
    counter: Integer;
  begin
    Result := 0;

    counter := Length(S);
    while counter <> 0 do
    begin
      case S[counter] of
        '(':
          inc(Result);
        ')':
          dec(Result);
      end;
      dec(counter);
    end;
  end;

  function CheckNumber(const S: string; var FloatNumber: ParserFloat): boolean;
  { checks whether s is a number }
  var
    code: Integer;
  begin
    if S = 'PI' then
    begin
      FloatNumber := Pi;
      Result := true;
    end
    else if S = '-PI' then
    begin
      FloatNumber := -Pi;
      Result := true;
    end
    else
    begin
      if UsePascalNumbers then
      begin
        val(S, FloatNumber, code);
        Result := code = 0;
      end
      else
        Result := TryStrToFloat(S, FloatNumber);
    end;
  end;

  function CheckVariable(const S: string; var VariableID: Integer): boolean;
  { checks whether s is a variable string }
  begin
    Result := Variables.Find(S, VariableID);
  end;

  function CheckTerm(var s1: string): boolean;
  { checks whether s is a valid term }
  var
    s2, s3: TermString;
    FloatNumber: ParserFloat;
    fsort: TToken;
    VariableID: Integer;
  begin
    Result := false;

    if Length(s1) = 0 then
      exit;

    if CheckNumber(s1, FloatNumber) or CheckVariable(s1, VariableID) or
      CheckNegate(s1, s2) or CheckAdd(s1, s2, s3) or CheckSubtract(s1, s2, s3)
      or CheckMultiply(s1, s2, s3) or
{$IFDEF UseIntegerOP}
      CheckIntegerDiv(s1, s2, s3) or CheckModulo(s1, s2, s3) or
{$ENDIF UseIntegerOP}
      CheckRealDivision(s1, s2, s3) or CheckPower(s1, s2, s3, fsort) or
      CheckFuncTwoVar(s1, s2, s3) or CheckFuncOneVar(s1, s2) then
      Result := true
    else if CheckBracket(s1, s2) then
    begin
      s1 := s2;
      Result := true
    end;

  end;

  function CheckBracket(const S: string; var s1: string): boolean;
  { checks whether s =(...(s1)...) and s1 is a valid term }
  var
    SLen: Integer;
  begin
    Result := false;

    SLen := Length(S);
    if (SLen > 0) and (S[SLen] = ')') and (S[1] = '(') then
    begin
      s1 := copy(S, 2, SLen - 2);
      Result := CheckTerm(s1);
    end;
  end;

  function CheckNegate(const S: string; var s1: string): boolean;
  { checks whether s denotes the negative value of a valid TOperation }
  var
    s2, s3: TermString;
    fsort: TToken;
    VariableID: Integer;
  begin
    Result := false;

    if (Length(S) <> 0) and (S[1] = '-') then
    begin

      s1 := copy(S, 2, Length(S) - 1);
      if CheckBracket(s1, s2) then
      begin
        s1 := s2;
        Result := true;
      end
      else
        Result := CheckVariable(s1, VariableID) or CheckPower(s1, s2, s3, fsort)
          or CheckFuncOneVar(s1, s2) or CheckFuncTwoVar(s1, s2, s3);

    end;
  end;

  function CheckAdd(var S: string; var s1, s2: string): boolean;
  { checks whether '+' is the primary TOperation in s }
  var
    s3, s4: TermString;
    OldLen, I, j: Integer;
    FloatNumber: ParserFloat;
    fsort: TToken;
    VariableID: Integer;
  begin
    Result := false;

    I := 0;
    j := Length(S);
    repeat

      while I < j do
      begin
        inc(I);
        if S[I] = '+' then
          break;
      end;

      if (I > 1) and (I < j) then
      begin

        Result := false;

        s2 := copy(S, I + 1, j - I);
        if CheckNumberBrackets(s2) = 0 then
        begin
          OldLen := HackSetLength(S, I - 1);
          Result := CheckNumberBrackets(S) = 0;
          HackSetLength(S, OldLen);

          if Result then
          begin
            s1 := copy(S, 1, I - 1);
            Result := CheckNumber(s1, FloatNumber) or
              CheckVariable(s1, VariableID);

            if not Result then
            begin
              Result := CheckBracket(s1, s3);
              if Result then
                s1 := s3;
            end;

            if not Result then
              Result := CheckNegate(s1, s3) or CheckSubtract(s1, s3, s4) or
                CheckMultiply(s1, s3, s4) or
{$IFDEF UseIntegerOP}
                CheckIntegerDiv(s1, s3, s4) or CheckModulo(s1, s3, s4) or
{$ENDIF UseIntegerOP}
                CheckRealDivision(s1, s3, s4) or CheckPower(s1, s3, s4, fsort)
                or CheckFuncOneVar(s1, s3) or CheckFuncTwoVar(s1, s3, s4);

            if Result then
            begin
              Result := CheckNumber(s2, FloatNumber) or
                CheckVariable(s2, VariableID);

              if not Result then
              begin
                Result := CheckBracket(s2, s3);
                if Result then
                  s2 := s3
                else
                  Result := CheckAdd(s2, s3, s4) or CheckSubtract(s2, s3, s4) or
                    CheckMultiply(s2, s3, s4) or
{$IFDEF UseIntegerOP}
                    CheckIntegerDiv(s2, s3, s4) or CheckModulo(s2, s3, s4) or
{$ENDIF UseIntegerOP}
                    CheckRealDivision(s2, s3, s4) or
                    CheckPower(s2, s3, s4, fsort) or CheckFuncOneVar(s2, s3) or
                    CheckFuncTwoVar(s2, s3, s4);
              end;
            end;

          end
        end
      end
      else
        break;

    until Result;
  end;

  function CheckSubtract(const S: string; var s1, s2: string): boolean;
  { checks whether '-' is the primary TOperation in s }
  var
    s3, s4: TermString;
    I, j: Integer;
    FloatNumber: ParserFloat;
    fsort: TToken;
    VariableID: Integer;
  begin
    Result := false;

    I := 1; { bugfix -1-1 }
    j := Length(S);

    repeat

      while I < j do { bugfix -1-1 }
      begin
        inc(I);
        if S[I] = '-' then
          break;
      end;

      if (I > 1) and (I < j) then
      begin
        s1 := copy(S, 1, I - 1);
        s2 := copy(S, I + 1, j - I);

        Result := (CheckNumberBrackets(s2) = 0) and
          (CheckNumberBrackets(s1) = 0);

        if Result then
        begin
          Result := CheckNumber(s1, FloatNumber) or
            CheckVariable(s1, VariableID);

          if not Result then
          begin
            Result := CheckBracket(s1, s3);
            if Result then
              s1 := s3;
          end;
          if not Result then
            Result := CheckNegate(s1, s3) or CheckSubtract(s1, s3, s4) or
              CheckMultiply(s1, s3, s4) or
{$IFDEF UseIntegerOP}
              CheckIntegerDiv(s1, s3, s4) or CheckModulo(s1, s3, s4) or
{$ENDIF UseIntegerOP}
              CheckRealDivision(s1, s3, s4) or CheckPower(s1, s3, s4, fsort) or
              CheckFuncOneVar(s1, s3) or CheckFuncTwoVar(s1, s3, s4);

          if Result then
          begin
            Result := CheckNumber(s2, FloatNumber) or
              CheckVariable(s2, VariableID);

            if not Result then
            begin
              Result := CheckBracket(s2, s3);
              if Result then
                s2 := s3
              else
                Result := CheckMultiply(s2, s3, s4) or
{$IFDEF UseIntegerOP}
                  CheckIntegerDiv(s2, s3, s4) or CheckModulo(s2, s3, s4) or
{$ENDIF UseIntegerOP}
                  CheckRealDivision(s2, s3, s4) or CheckPower(s2, s3, s4, fsort)
                  or CheckFuncOneVar(s2, s3) or CheckFuncTwoVar(s2, s3, s4);
            end;
          end;

        end;
      end
      else
        break;

    until Result;

  end;

  function CheckMultiply(const S: string; var s1, s2: string): boolean;
  { checks whether '*' is the primary TOperation in s }
  var
    s3, s4: TermString;
    I, j: Integer;
    FloatNumber: ParserFloat;
    fsort: TToken;
    VariableID: Integer;
  begin
    Result := false;

    I := 0;
    j := Length(S);

    repeat
      while I < j do
      begin
        inc(I);
        if S[I] = '*' then
          break;
      end;

      if (I > 1) and (I < j) then
      begin
        s1 := copy(S, 1, I - 1);
        s2 := copy(S, I + 1, j - I);

        Result := (CheckNumberBrackets(s2) = 0) and
          (CheckNumberBrackets(s1) = 0);

        if Result then
        begin
          Result := CheckNumber(s1, FloatNumber) or
            CheckVariable(s1, VariableID);

          if not Result then
          begin
            Result := CheckBracket(s1, s3);
            if Result then
              s1 := s3;
          end;

          if not Result then
            Result := CheckNegate(s1, s3) or
{$IFDEF UseIntegerOP}
              CheckIntegerDiv(s1, s3, s4) or CheckModulo(s1, s3, s4) or
{$ENDIF UseIntegerOP}
              CheckRealDivision(s1, s3, s4) or CheckPower(s1, s3, s4, fsort) or
              CheckFuncOneVar(s1, s3) or CheckFuncTwoVar(s1, s3, s4);

          if Result then
          begin
            Result := CheckNumber(s2, FloatNumber) or
              CheckVariable(s2, VariableID);

            if not Result then
            begin
              Result := CheckBracket(s2, s3);
              if Result then
                s2 := s3
              else
                Result := CheckMultiply(s2, s3, s4) or
{$IFDEF UseIntegerOP}
                  CheckIntegerDiv(s2, s3, s4) or CheckModulo(s2, s3, s4) or
{$ENDIF UseIntegerOP}
                  CheckRealDivision(s2, s3, s4) or CheckPower(s2, s3, s4, fsort)
                  or CheckFuncOneVar(s2, s3) or CheckFuncTwoVar(s2, s3, s4);
            end;
          end;

        end;
      end
      else
        break;

    until Result;
  end;

{$IFDEF UseIntegerOP}
  function CheckIntegerDiv(const S: string; var s1, s2: string): boolean;
  { checks whether 'DIV' is the primary TOperation in s }
  var
    s3, s4: TermString;
    I, j: Integer;
    VariableID: Integer;
    FloatNumber: ParserFloat;
    fsort: TToken;
  begin
    Result := false;

    I := 0;

    repeat

      j := IPosE('DIV', PChar(S), I + 1, Length(S) - I);

      if j > 0 then
      begin

        inc(I, j);
        if (I > 1) and (I < Length(S)) then
        begin
          s1 := copy(S, 1, I - 1);
          s2 := copy(S, I + 3, Length(S) - I - 2);

          Result := (CheckNumberBrackets(s2) = 0) and
            (CheckNumberBrackets(s1) = 0);

          if Result then
          begin
            Result := CheckNumber(s1, FloatNumber) or
              CheckVariable(s1, VariableID);

            if not Result then
            begin
              Result := CheckBracket(s1, s3);
              if Result then
                s1 := s3;
            end;

            if not Result then
              Result := CheckNegate(s1, s3) or CheckIntegerDiv(s1, s3, s4) or
                CheckModulo(s1, s3, s4) or CheckRealDivision(s1, s3, s4) or
                CheckPower(s1, s3, s4, fsort) or CheckFuncOneVar(s1, s3) or
                CheckFuncTwoVar(s1, s3, s4);
            if Result then
            begin
              Result := CheckNumber(s2, FloatNumber) or
                CheckVariable(s2, VariableID);

              if not Result then
              begin
                Result := CheckBracket(s2, s3);
                if Result then
                  s2 := s3
                else
                  Result := CheckPower(s2, s3, s4, fsort) or
                    CheckFuncOneVar(s2, s3) or CheckFuncTwoVar(s2, s3, s4);
              end;
            end;

          end;
        end;
      end;

    until Result or (j = 0) or (I >= Length(S));
  end;

  function CheckModulo(const S: string; var s1, s2: string): boolean;
  { checks whether 'MOD' is the primary TOperation in s }
  var
    s3, s4: TermString;
    I, j: Integer;
    VariableID: Integer;
    FloatNumber: ParserFloat;
    fsort: TToken;
  begin
    Result := false;

    I := 0;

    repeat
      j := IPosE('MOD', PChar(S), I + 1, Length(S) - I);
      if j > 0 then
      begin

        inc(I, j);
        if (I > 1) and (I < Length(S)) then
        begin
          s1 := copy(S, 1, I - 1);
          s2 := copy(S, I + 3, Length(S) - I - 2);

          Result := (CheckNumberBrackets(s2) = 0) and
            (CheckNumberBrackets(s1) = 0);

          if Result then
          begin
            Result := CheckNumber(s1, FloatNumber) or
              CheckVariable(s1, VariableID);

            if not Result then
            begin
              Result := CheckBracket(s1, s3);
              if Result then
                s1 := s3;
            end;
            if not Result then
              Result := CheckNegate(s1, s3) or CheckIntegerDiv(s1, s3, s4) or
                CheckModulo(s1, s3, s4) or CheckRealDivision(s1, s3, s4) or
                CheckPower(s1, s3, s4, fsort) or CheckFuncOneVar(s1, s3) or
                CheckFuncTwoVar(s1, s3, s4);

            if Result then
            begin
              Result := CheckNumber(s2, FloatNumber) or
                CheckVariable(s2, VariableID);

              if not Result then
              begin
                Result := CheckBracket(s2, s3);
                if Result then
                  s2 := s3
                else
                  Result := CheckPower(s2, s3, s4, fsort) or
                    CheckFuncOneVar(s2, s3) or CheckFuncTwoVar(s2, s3, s4);

              end
            end;

          end;
        end;
      end;
    until Result or (j = 0) or (I >= Length(S));
  end;
{$ENDIF UseIntegerOP}
  function CheckRealDivision(const S: string; var s1, s2: string): boolean;
  { checks whether '/' is the primary TOperation in s }
  var
    s3, s4: TermString;
    I, j: Integer;
    VariableID: Integer;
    FloatNumber: ParserFloat;
    fsort: TToken;
  begin
    Result := false;

    I := 0;
    j := Length(S);

    repeat

      while I < j do
      begin
        inc(I);
        if S[I] = '/' then
          break;
      end;

      if (I > 1) and (I < j) then
      begin
        s1 := copy(S, 1, I - 1);
        s2 := copy(S, I + 1, j - I);

        Result := (CheckNumberBrackets(s2) = 0) and
          (CheckNumberBrackets(s1) = 0);

        if Result then
        begin
          Result := CheckNumber(s1, FloatNumber) or
            CheckVariable(s1, VariableID);

          if not Result then
          begin
            Result := CheckBracket(s1, s3);
            if Result then
              s1 := s3;
          end;

          if not Result then
            Result := CheckNegate(s1, s3) or
{$IFDEF UseIntegerOP}
              CheckIntegerDiv(s1, s3, s4) or CheckModulo(s1, s3, s4) or
{$ENDIF UseIntegerOP}
              CheckRealDivision(s1, s3, s4) or CheckPower(s1, s3, s4, fsort) or
              CheckFuncOneVar(s1, s3) or CheckFuncTwoVar(s1, s3, s4);

          if Result then
          begin
            Result := CheckNumber(s2, FloatNumber) or
              CheckVariable(s2, VariableID);

            if not Result then
            begin
              Result := CheckBracket(s2, s3);
              if Result then
                s2 := s3
              else
                Result := CheckPower(s2, s3, s4, fsort) or
                  CheckFuncOneVar(s2, s3) or CheckFuncTwoVar(s2, s3, s4);

            end;
          end;

        end;
      end
      else
        break;

    until Result;
  end;

  function CheckFuncTwoVar(var S: string; var s1, s2: string): boolean;
  { checks whether s=f(s1,s2); s1,s2 being valid terms }

    function CheckComma(const S: string; var s1, s2: string): boolean;
    var
      I, j: Integer;
    begin
      Result := false;

      I := 0;
      j := Length(S);
      repeat

        while I < j do
        begin
          inc(I);
          if S[I] = ',' then
            break;
        end;

        if (I > 1) and (I < j) then
        begin
          s1 := copy(S, 1, I - 1);
          if CheckTerm(s1) then
          begin
            s2 := copy(S, I + 1, j - I);
            Result := CheckTerm(s2);
          end;

        end
        else
          break;

      until Result;
    end;

  var
    OldLen, SLen, counter: Integer;
  begin

    Result := false;

    SLen := FastPos('(', PChar(S));

    if (SLen > 0) and (S[Length(S)] = ')') then
    begin

      OldLen := HackSetLength(S, SLen);
      Result := FunctionTwo.Find(S, counter);
      HackSetLength(S, OldLen);

      { Result := FunctionTwo.Find(copy(s, 1, SLen), counter); }
      if Result then
      begin
        inc(SLen, 2);
        Result := CheckComma(copy(S, SLen, Length(S) - SLen), s1, s2);
      end;
    end;
  end;

  function CheckFuncOneVar(var S: string; var s1: string): boolean;
  { checks whether s denotes the evaluation of a function fsort(s1) }
  var
    OldLen, counter: Integer;
    SLen: Integer;
  begin
    Result := false;

    { change }
    SLen := FastPos('(', PChar(S));

    if (SLen > 0) then
    begin
      OldLen := HackSetLength(S, SLen);
      Result := FunctionOne.Find(S, counter);
      HackSetLength(S, OldLen);

      { Result := FunctionOne.Find(copy(s, 1, SLen), counter); }
      if Result then
      begin
        Result := CheckBracket(copy(S, SLen + 1, Length(S) - SLen), s1);
      end;
    end;
  end;

  function CheckPower(const S: string; var s1, s2: string;
    var AToken: TToken): boolean;
  var
    s3, s4: TermString;
    I, j: Integer;
    FloatNumber: ParserFloat;
    VariableID: Integer;
  begin
    Result := false;

    I := 0;
    j := Length(S);
    repeat

      while I < j do
      begin
        inc(I);
        if S[I] = '^' then
          break;
      end;

      if (I > 1) and (I < j) then
      begin
        s1 := copy(S, 1, I - 1);
        s2 := copy(S, I + 1, j - I);

        Result := (CheckNumberBrackets(s2) = 0) and
          (CheckNumberBrackets(s1) = 0);

        if Result then
        begin
          Result := CheckNumber(s1, FloatNumber) or
            CheckVariable(s1, VariableID);

          if not Result then
          begin
            Result := CheckBracket(s1, s3);
            if Result then
              s1 := s3;
          end;

          if not Result then
            Result := CheckFuncOneVar(s1, s3) or CheckFuncTwoVar(s1, s3, s4);

          if Result then
          begin

            if CheckNumber(s2, FloatNumber) then
            begin
              I := trunc(FloatNumber);

              if (I <> FloatNumber) then
              begin
                { this is a real number }
                AToken := realpower;
              end
              else
              begin
                case I of
                  2:
                    AToken := square;
                  3:
                    AToken := third;
                  4:
                    AToken := fourth;
                else
                  AToken := integerpower;
                end;
              end;
            end
            else
            begin
              Result := CheckVariable(s2, VariableID);

              if not Result then
              begin
                Result := CheckBracket(s2, s3);
                if Result then
                  s2 := s3;
              end;

              if not Result then
              begin
                Result := CheckFuncOneVar(s2, s3) or
                  CheckFuncTwoVar(s2, s3, s4);
              end;

              if Result then
                AToken := realpower;
            end;
          end;

        end;
      end
      else
        break;

    until Result;
  end;

  function CreateOperation(const Term: TToken; const Proc: Pointer): POperation;
  begin
    new(Result);
    with Result^ do
    begin
      Arg1 := nil;
      Arg2 := nil;
      Dest := nil;

      NextOperation := nil;

      Token := Term;

      MathProc := TMathProcedure(Proc);
    end;
  end;

const
  BlankString = ' ';

type
  PTermRecord = ^TermRecord;

  TermRecord = record
    { this usage of string is a bit inefficient,
      as in 16bit always 256 bytes are consumed.
      But since we
      a) are allocating memory dynamically and
      b) this will be released immediately when
      finished with parsing
      this seems to be OK

      One COULD create a "TermClass" where this is handled }
    StartString: string;
    LeftString, RightString: string;

    Token: TToken;

    Position: array [1 .. 3] of Integer;

    Next1, Next2, Previous: PTermRecord;
  end;

const
  { side effect: for each bracketing level added
    SizeOf(integer) bytes additional stack usage
    maxLevelWidth*SizeOf(Pointer) additional global memory used }
  maxBracketLevels = 20;

  { side effect: for each additional (complexity) level width
    maxBracketLevels*SizeOf(Pointer) additional global memory used }
  maxLevelWidth = 50;
type
  LevelArray = array [0 .. maxBracketLevels] of Integer;

  OperationPointerArray = array [0 .. maxBracketLevels, 1 .. maxLevelWidth]
    of POperation;
  POperationPointerArray = ^OperationPointerArray;

var
  Matrix: POperationPointerArray;

  { bracket positions }
  CurrentBracket, I, CurBracketLevels: Integer;

  BracketLevel: LevelArray;

  LastOP: POperation;
  FloatNumber: ParserFloat;
  VariableID: Integer;

  ANewTerm, { need this particlar pointer to guarantee a good, flawless memory cleanup in except }

  FirstTerm, Next1Term, Next2Term, LastTerm: PTermRecord;

  counter1, counter2: Integer;
begin
  { initialize local variables for safe checking in try..finally..end }

  { FirstTerm := nil; } { not necessary since not freed in finally }
  LastTerm := nil;
  ANewTerm := nil;
  Next1Term := nil;
  Next2Term := nil;

  Error := false;

  FillChar(BracketLevel, SizeOf(BracketLevel), 0); { initialize bracket array }
  BracketLevel[0] := 1;
  CurBracketLevels := 0;

  new(Matrix);

  try { this block protects the whole of ALL assignments... }
    FillChar(Matrix^, SizeOf(Matrix^), 0);

    new(ANewTerm);
    with ANewTerm^ do
    begin

      StartString := UpperCase(FunctionString);

      { remove leading and trailing spaces }
      counter1 := 1;
      counter2 := Length(StartString);
      while counter1 <= counter2 do
        if StartString[counter1] <> ' ' then
          break
        else
          inc(counter1);

      counter2 := Length(StartString);
      while counter2 > counter1 do
        if StartString[counter2] <> ' ' then
          break
        else
          dec(counter2);

      StartString := copy(StartString, counter1, counter2 - counter1 + 1);

      { change }
      if FastPos(' ', PChar(StartString)) <> 0 then
        raise EExpressionHasBlanks.Create(msgErrBlanks);
      {
        Old code:

        StartString := RemoveBlanks(UpperCase(FunctionString));

        ...do not use! Using it would create the following situation:

        Passed string:   "e xp(12)"
        Modified string: "exp(12)"

        This MAY or may not be the desired meaning - there may well exist
        a variable "e" and a function "xp" and just the operator would be missing.

        Conclusion: the above line has the potential of changing the meaning
        of an expression.
      }

      I := CheckNumberBrackets(StartString);
      if I > 0 then
        raise EMissMatchingBracket.CreateFmt(msgMissingBrackets, ['")"', I])
      else if I < 0 then
        raise EMissMatchingBracket.CreateFmt(msgMissingBrackets, ['"("', I]);

      { remove enclosing brackets, e.g. ((pi)) }
      while CheckBracket(StartString, FunctionString) do
        StartString := FunctionString;

      LeftString := BlankString;
      RightString := BlankString;

      Token := variab;

      Next1 := nil;
      Next2 := nil;
      Previous := nil;
    end;

    Matrix[0, 1] := CreateOperation(variab, nil);

    LastTerm := ANewTerm;
    FirstTerm := ANewTerm;
    ANewTerm := nil;

    with LastTerm^ do
    begin
      Position[1] := 0;
      Position[2] := 1;
      Position[3] := 1;
    end;

    repeat

      repeat

        with LastTerm^ do
        begin

          CurrentBracket := Position[1];
          I := Position[2];

          if Next1 = nil then
          begin
            if CheckNumber(StartString, FloatNumber) then
            begin
              Token := constant;
              if Position[3] = 1 then
              begin
                new(Matrix[CurrentBracket, I]^.Arg1);
                Matrix[CurrentBracket, I]^.Arg1^ := FloatNumber;
              end
              else
              begin
                new(Matrix[CurrentBracket, I]^.Arg2);
                Matrix[CurrentBracket, I]^.Arg2^ := FloatNumber;
              end;
            end
            else
            begin
              if CheckVariable(StartString, VariableID) then
              begin
                Token := variab;

                if Position[3] = 1 then
                  Matrix[CurrentBracket, I]^.Arg1 :=
                    PParserFloat(Variables.Objects[VariableID])
                else
                  Matrix[CurrentBracket, I]^.Arg2 :=
                    PParserFloat(Variables.Objects[VariableID])
              end
              else
              begin
                if CheckNegate(StartString, LeftString) then
                  Token := minus
                else
                begin
                  if CheckAdd(StartString, LeftString, RightString) then
                    Token := sum
                  else
                  begin
                    if CheckSubtract(StartString, LeftString, RightString) then
                      Token := diff
                    else
                    begin
                      if CheckMultiply(StartString, LeftString, RightString)
                      then
                        Token := prod
                      else
                      begin
{$IFDEF UseIntegerOP}
                        if CheckIntegerDiv(StartString, LeftString, RightString)
                        then
                          Token := IntDiv
                        else
                        begin
                          if CheckModulo(StartString, LeftString, RightString)
                          then
                            Token := modulo
                          else
{$ELSE}
                        begin
{$ENDIF UseIntegerOP}
                          begin
                            if CheckRealDivision(StartString, LeftString,
                              RightString) then
                              Token := divis
                            else
                            begin
                              if not CheckPower(StartString, LeftString,
                                RightString, Token) then
                              begin
                                if CheckFuncOneVar(StartString, LeftString) then
                                  Token := FuncOneVar
                                else
                                begin
                                  if CheckFuncTwoVar(StartString, LeftString,
                                    RightString) then
                                    Token := FuncTwoVar
                                  else
                                  begin
                                    Error := true;
                                    { with an exception raised this is meaningless... }
                                    if (LeftString = BlankString) and
                                      (RightString = BlankString) then
                                      raise ESyntaxError.CreateFmt
                                        (msgParseError + #13'%s', [StartString])
                                    else
                                      raise ESyntaxError.CreateFmt
                                        (msgParseError + #13'%s'#13'%s',
                                        [LeftString, RightString])
                                  end;
                                end;
                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end; { with LastTerm^ }

        if LastTerm^.Token in ([minus, square, third, fourth, FuncOneVar,
          FuncTwoVar] + TokenOperators) then
        begin
          if LastTerm^.Next1 = nil then
          begin
            try
              Next1Term := nil;
              new(Next1Term);

              inc(CurrentBracket);
              if CurrentBracket > maxBracketLevels then
              begin
                Error := true;
                raise ETooManyNestings.Create(msgNestings);
              end;

              I := BracketLevel[CurrentBracket] + 1;
              if I > maxLevelWidth then
              begin
                Error := true;
                raise EExpressionTooComplex.Create(msgTooComplex);
              end;

              if CurBracketLevels < CurrentBracket then
                CurBracketLevels := CurrentBracket;

              with Next1Term^ do
              begin
                StartString := LastTerm^.LeftString;
                LeftString := BlankString;
                RightString := BlankString;

                Position[1] := CurrentBracket;
                Position[2] := I;
                Position[3] := 1;

                Token := variab;

                Previous := LastTerm;
                Next1 := nil;
                Next2 := nil;
              end;

              with LastTerm^ do
              begin
                case Token of
                  FuncOneVar:
                    with FunctionOne do
                    begin
                      SetLength(StartString, FastPos('(', PChar(StartString)));
                      Find(StartString, counter1);

                      Matrix[CurrentBracket, I] :=
                        CreateOperation(Token, Objects[counter1]);

                    end;

                  FuncTwoVar:
                    with FunctionTwo do
                    begin
                      SetLength(StartString, FastPos('(', PChar(StartString)));
                      Find(StartString, counter1);

                      Matrix[CurrentBracket, I] :=
                        CreateOperation(Token, Objects[counter1]);
                    end;
                else
                  Matrix[CurrentBracket, I] := CreateOperation(Token, nil);
                end;

                new(Matrix[CurrentBracket, I]^.Dest);
                Matrix[CurrentBracket, I]^.Dest^ := 0;

                if Position[3] = 1 then
                  Matrix[Position[1], Position[2]]^.Arg1 :=
                    Matrix[CurrentBracket, I]^.Dest
                else
                  Matrix[Position[1], Position[2]]^.Arg2 :=
                    Matrix[CurrentBracket, I]^.Dest;

                Next1 := Next1Term;
                Next1Term := nil;
              end;

              if LastTerm^.Token in [minus, square, third, fourth, FuncOneVar]
              then
                inc(BracketLevel[CurrentBracket]);

            except
              if assigned(Next1Term) then
              begin
                dispose(Next1Term);
                Next1Term := nil;
              end;
              raise;
            end;

          end

          else
          begin
            if LastTerm^.Token in (TokenOperators + [FuncTwoVar]) then
            begin
              try
                Next2Term := nil;
                new(Next2Term);

                inc(CurrentBracket);
                if CurrentBracket > maxBracketLevels then
                begin
                  Error := true;
                  raise ETooManyNestings.Create(msgNestings);
                end;

                I := BracketLevel[CurrentBracket] + 1;
                if I > maxLevelWidth then
                begin
                  Error := true;
                  raise EExpressionTooComplex.Create(msgTooComplex);
                end;

                if CurBracketLevels < CurrentBracket then
                  CurBracketLevels := CurrentBracket;

                with Next2Term^ do
                begin
                  StartString := LastTerm^.RightString;

                  LeftString := BlankString;
                  RightString := BlankString;

                  Token := variab;

                  Position[1] := CurrentBracket;
                  Position[2] := I;
                  Position[3] := 2;

                  Previous := LastTerm;
                  Next1 := nil;
                  Next2 := nil;
                end;

                LastTerm^.Next2 := Next2Term;
                Next2Term := nil;
                inc(BracketLevel[CurrentBracket]);

              except
                if assigned(Next2Term) then
                begin
                  dispose(Next2Term);
                  Next2Term := nil;
                end;

                raise;
              end;
            end
            else
              raise EParserInternalError.Create(msgInternalError);
          end;
        end;

        with LastTerm^ do
          if Next1 = nil then
          begin
            { we are done with THIS loop }
            break;
          end
          else if Next2 = nil then
            LastTerm := Next1
          else
            LastTerm := Next2;

      until false; { endless loop, break'ed 7 lines above }

      if LastTerm = FirstTerm then
      begin
        dispose(LastTerm);
        FirstTerm := nil;
        break; { OK - that is it, we did not find any more terms }
      end;

      repeat
        with LastTerm^ do { cannot use "with LastTerm^" OUTSIDE loop }
        begin
          if Next1 <> nil then
          begin
            dispose(Next1);
            Next1 := nil;
          end;

          if Next2 <> nil then
          begin
            dispose(Next2);
            Next2 := nil;
          end;

          LastTerm := Previous;
        end;
      until ((LastTerm^.Token in (TokenOperators + [FuncTwoVar])) and
        (LastTerm^.Next2 = nil)) or (LastTerm = FirstTerm);

      with FirstTerm^ do
        if (LastTerm = FirstTerm) and
          ((Token in [minus, square, third, fourth, FuncOneVar]) or
          ((Token in (TokenOperators + [FuncTwoVar])) and assigned(Next2))) then
        begin
          break;
        end;

    until false;

    { after having built the expression matrix, translate it into a tree/list }

    with FirstTerm^ do
      if FirstTerm <> nil then
      begin
        if Next1 <> nil then
        begin
          dispose(Next1);
          Next1 := nil;
        end;

        if Next2 <> nil then
        begin
          dispose(Next2);
          Next2 := nil;
        end;

        dispose(FirstTerm);
      end;

    BracketLevel[0] := 1;

    if CurBracketLevels = 0 then
    begin
      FirstOP := Matrix[0, 1];
      Matrix[0, 1] := nil;
      FirstOP^.Dest := FirstOP^.Arg1;
    end
    else
    begin

      FirstOP := Matrix[CurBracketLevels, 1];
      LastOP := FirstOP;

      for counter2 := 2 to BracketLevel[CurBracketLevels] do
      begin
        LastOP^.NextOperation := Matrix[CurBracketLevels, counter2];
        LastOP := LastOP^.NextOperation;
      end;

      for counter1 := CurBracketLevels - 1 downto 1 do
        for counter2 := 1 to BracketLevel[counter1] do
        begin
          LastOP^.NextOperation := Matrix[counter1, counter2];
          LastOP := LastOP^.NextOperation;
        end;

      with Matrix[0, 1]^ do
      begin
        Arg1 := nil;
        Arg2 := nil;
        Dest := nil;
      end;

      dispose(Matrix[0, 1]);
    end;

    dispose(Matrix);

  except
    if assigned(Matrix) then
    begin
      if Matrix[0, 1] <> nil then
        dispose(Matrix[0, 1]);

      for counter1 := CurBracketLevels downto 1 do
        for counter2 := 1 to BracketLevel[counter1] do
          if Matrix[counter1, counter2] <> nil then

            dispose(Matrix[counter1, counter2]);

      dispose(Matrix);
    end;

    if assigned(Next1Term) then
      dispose(Next1Term);

    if assigned(Next2Term) then
      dispose(Next2Term);

    { do NOT kill this one at it is possibly the same as LastTerm (see below)!
      if Assigned(FirstTerm) then
      dispose(FirstTerm);

      instead, DO kill ANewTerm, which will only be <> nil if it has NOT passed
      its value to some other pointer already so it can safely be freed
    }
    if assigned(ANewTerm) then
      dispose(ANewTerm);

    if assigned(LastTerm) and (LastTerm <> Next2Term) and (LastTerm <> Next1Term)
    then
      dispose(LastTerm);

    FirstOP := nil;

    raise; { re-raise exception }
  end;
end;

initialization

MakeCharTable;

end.
