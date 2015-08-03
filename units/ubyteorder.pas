unit ubyteorder;

interface

/// <summary>
/// swaps lInt between Big and Little-Endian number formats
/// </summary>
/// <param name="lInt">
/// SmallInt (signed integer 16 bits)
/// </param>
procedure Swap2(var lInt: SmallInt); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps lInt between Big and Little-Endian number formats
/// </summary>
/// <param name="lInt">
/// SmallInt (signed integer 16 bits)
/// </param>
function fswap2(lInt: SmallInt): SmallInt; {$IFDEF INLININGSUPPORTED}inline;
{$ENDIF}
/// <summary>
/// swaps lInt between Big and Little-Endian number formats
/// </summary>
/// <param name="lInt">
/// Word (unsigned integer 16 bits)
/// </param>
procedure Swap2u(var lInt: Word); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps lInt between Big and Little-Endian number formats
/// </summary>
/// <param name="lInt">
/// Word (unsigned integer 16 bits)
/// </param>
function fswap2u(lInt: Word): Word; {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// single (float 32 bits)
/// </param>
procedure swap4r(var s: single); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// single (float 32 bits)
/// </param>
function fswap4r(s: single): single; {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// LongInt (signed integer 32 bits)
/// </param>
procedure swap4(var s: LongInt); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// LongInt (signed integer 32 bits)
/// </param>
function fswap4(s: LongInt): LongInt; {$IFDEF INLININGSUPPORTED}inline;
{$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// LongWord (unsigned integer 32 bits)
/// </param>
procedure swap4u(var s: LongWord); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// LongWord (unsigned integer 32 bits)
/// </param>
function fswap4u(s: LongWord): LongWord; {$IFDEF INLININGSUPPORTED}inline;
{$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// double (float 64 bits)
/// </param>
procedure swap8r(var s: double); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// double (float 64 bits)
/// </param>
function fswap8r(s: double): double; {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// extended (float 80 bits)
/// </param>
procedure swap10r(var s: extended); {$IFDEF INLININGSUPPORTED}inline; {$ENDIF}
/// <summary>
/// swaps s between Big and Little-Endian number formats
/// </summary>
/// <param name="s">
/// extended (float 80 bits)
/// </param>
function fswap10r(s: extended): extended; {$IFDEF INLININGSUPPORTED}inline;
{$ENDIF}
/// <summary>
/// Converts all kind of data type to Little Endian number format regardless
/// of the previous format
/// </summary>
function ToLittleEndian(lInt: SmallInt; little_endian: integer): SmallInt;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;
function ToLittleEndian(lInt: Word; little_endian: integer): Word;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;
function ToLittleEndian(lInt: LongInt; little_endian: integer): LongInt;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;
function ToLittleEndian(lInt: LongWord; little_endian: integer): LongWord;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;
function ToLittleEndian(lInt: single; little_endian: integer): single;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;
function ToLittleEndian(lInt: double; little_endian: integer): double;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;
function ToLittleEndian(lInt: extended; little_endian: integer): extended;
{$IFDEF INLININGSUPPORTED}inline; {$ENDIF}overload;

implementation

procedure Swap2(var lInt: SmallInt);
begin
  lInt := swap(lInt);
end;

function fswap2(lInt: SmallInt): SmallInt;
begin
  fswap2 := swap(lInt);
end;

procedure Swap2u(var lInt: Word);
begin
  lInt := swap(lInt);
end;

function fswap2u(lInt: Word): Word;
begin
  fswap2u := swap(lInt);
end;

procedure swap4r(var s: single);
var
  temp: Word;
  Overlay: array [1 .. 2] of Word absolute s;
begin
  temp := swap(Overlay[1]);
  Overlay[1] := swap(Overlay[2]);
  Overlay[2] := temp;
end;

procedure swap4u(var s: LongWord);
var
  temp: Word;
  Overlay: array [1 .. 2] of Word absolute s;
begin
  temp := swap(Overlay[1]);
  Overlay[1] := swap(Overlay[2]);
  Overlay[2] := temp;
end;

function fswap4r(s: single): single;
var
  l: single;
begin
  l := s;
  swap4r(l);
  fswap4r := l;
end;

function fswap4u(s: LongWord): LongWord;
var
  l: LongWord;
begin
  l := s;
  swap4u(l);
  fswap4u := l;
end;

procedure swap4(var s: LongInt);
var
  temp: Word;
  Overlay: array [1 .. 2] of Word absolute s;
begin
  temp := swap(Overlay[1]);
  Overlay[1] := swap(Overlay[2]);
  Overlay[2] := temp;
end;

function fswap4(s: LongInt): LongInt;
var
  l: LongInt;
begin
  l := s;
  swap4(l);
  fswap4 := l;
end;

procedure swap8r(var s: double);
var
  temp: Word;
  Overlay: array [1 .. 4] of Word absolute s;
begin
  temp := swap(Overlay[1]);
  Overlay[1] := swap(Overlay[4]);
  Overlay[4] := temp;
  temp := swap(Overlay[2]);
  Overlay[2] := swap(Overlay[3]);
  Overlay[3] := temp;
end;

function fswap8r(s: double): double;
var
  l: double;
begin
  l := s;
  swap8r(l);
  fswap8r := l;
end;

procedure swap10r(var s: extended);
var
  temp: Word;
  Overlay: array [1 .. 5] of Word absolute s;
begin
  temp := swap(Overlay[1]);
  Overlay[1] := swap(Overlay[5]);
  Overlay[5] := temp;
  temp := swap(Overlay[2]);
  Overlay[2] := swap(Overlay[4]);
  Overlay[4] := temp;
  Overlay[3] := swap(Overlay[3]);
end;

function fswap10r(s: extended): extended;
var
  l: extended;
begin
  l := s;
  swap10r(l);
  fswap10r := l;
end;

function ToLittleEndian(lInt: Word; little_endian: integer): Word;
begin
  if little_endian <> 1 then
    result := swap(lInt)
  else
    result := lInt;
end;

function ToLittleEndian(lInt: single; little_endian: integer): single;
begin
  if little_endian <> 1 then
    result := fswap4r(lInt)
  else
    result := lInt;
end;

function ToLittleEndian(lInt: SmallInt; little_endian: integer): SmallInt;
begin
  if little_endian <> 1 then
    result := fswap2(lInt)
  else
    result := lInt;
end;

function ToLittleEndian(lInt: LongInt; little_endian: integer): LongInt;
begin
  if little_endian <> 1 then
    result := fswap4(lInt)
  else
    result := lInt;
end;

function ToLittleEndian(lInt: double; little_endian: integer): double;
begin
  if little_endian <> 1 then
    result := fswap8r(lInt)
  else
    result := lInt;
end;

function ToLittleEndian(lInt: LongWord; little_endian: integer): LongWord;
begin
  if little_endian <> 1 then
    result := fswap4u(lInt)
  else
    result := lInt;
end;

function ToLittleEndian(lInt: extended; little_endian: integer): extended;
begin
  if little_endian <> 1 then
    result := fswap10r(lInt)
  else
    result := lInt;
end;

end.
