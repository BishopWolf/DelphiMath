{ ******************************************************************
  Minimum, maximum, sign and exchange
  ****************************************************************** }

unit uminmax;

interface

uses
  utypes, uComplex, uConstants;

function DSgn(A, B: Float): Float; { Sgn(B) * |A| }
function DSgn0(A, B: Float): Float; { Sgn0(B) * |A| }

Procedure SWAP(var A, B: Float); { Exchange 2 reals } overload;
Procedure SWAP(var A, B: Integer); { Exchange 2 integers } overload;
Procedure SWAP(var A, B: word); { Exchange 2 words } overload;
Procedure SWAP(var A, B: boolean); { Exchange 2 booleans } overload;
Procedure SWAP(var A, B: complex); { Exchange 2 complex } overload;
Procedure SWAP(var A, B: string); { Exchange 2 strings } overload;

FUNCTION Min(X: tVector; Lb, Ub: Cardinal; out pos: Integer): Float; overload;
FUNCTION Max(X: tVector; Lb, Ub: Cardinal; out pos: Integer): Float; overload;
FUNCTION Min(X: tIntVector; Lb, Ub: Cardinal; out pos: Integer)
  : Integer; overload;
FUNCTION Max(X: tIntVector; Lb, Ub: Cardinal; out pos: Integer)
  : Integer; overload;
Procedure MinMax(X: tVector; Lb, Ub: Cardinal; out Min, Max: Float); overload;
Procedure MinMax(X: tIntVector; Lb, Ub: Cardinal;
  out Min, Max: Integer); overload;
Procedure MinMax(X: TMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max: Float); overload;
Procedure MinMax(X: TIntMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max: Integer); overload;
Procedure MinMax(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max: Float); overload;
Procedure MinMax(X: T3DIntMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max: Integer); overload;
Procedure MinMaxMean(X: tVector; Lb, Ub: Cardinal;
  out Min, Max, mean: Float); overload;
Procedure MinMaxMean(X: tIntVector; Lb, Ub: Cardinal; out Min, Max: Integer;
  out mean: Float); overload;
Procedure MinMaxMean(X: TMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max, mean: Float); overload;
Procedure MinMaxMean(X: TIntMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max: Integer; out mean: Float); overload;
Procedure MinMaxMean(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max, mean: Float); overload;
Procedure MinMaxMean(X: T3DIntMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max: Integer; out mean: Float); overload;
Procedure MinMaxMeanWOZero(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max, mean: Float; out lSize: Integer); overload;
Procedure MinMaxMeanWOZero(X: T3DIntMatrix;
  Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal; out Min, Max: Integer;
  out mean: Float; out lSize: Integer); overload;
function CountNotZeros(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal)
  : Integer; overload;
function CountNotZeros(X: T3DIntMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal)
  : Integer; overload;
function PropagaError(X, Xerr: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: Cardinal): Float;

function min3(P1, P2, P3: Float): Float; overload;
function max3(P1, P2, P3: Float): Float; overload;
function min3(P1, P2, P3: Integer): Integer; overload;
function max3(P1, P2, P3: Integer): Integer; overload;

implementation

uses math, umath;

function DSgn(A, B: Float): Float;
begin
  if B < 0.0 then
    DSgn := -Abs(A)
  else
    DSgn := Abs(A)
end;

function DSgn0(A, B: Float): Float;
begin
  result := Abs(A) * Sign(B);
end;

Procedure SWAP(var A, B: Float);
var
  temp: Float;
begin
  temp := A;
  A := B;
  B := temp;
end;

Procedure SWAP(var A, B: Integer);
var
  temp: Integer;
begin
  temp := A;
  A := B;
  B := temp;
end;

Procedure SWAP(var A, B: word);
var
  temp: word;
begin
  temp := A;
  A := B;
  B := temp;
end;

Procedure SWAP(var A, B: string);
var
  temp: string;
begin
  temp := A;
  A := B;
  B := temp;
end;

Procedure SWAP(var A, B: boolean);
var
  temp: boolean;
begin
  temp := A;
  A := B;
  B := temp;
end;

Procedure SWAP(var A, B: complex);
var
  temp: complex;
begin
  temp := A;
  A := B;
  B := temp;
end;

FUNCTION Min(X: tVector; Lb, Ub: Cardinal; out pos: Integer): Float;
var
  temp: Float;
  i: Cardinal;
begin
  { result:=MinValue(X); }  // This includes the size as a value
  temp := X[Lb];
  pos := Lb;
  for i := Lb + 1 to Ub do
    if temp > X[i] then
    begin
      temp := X[i];
      pos := i;
    end;
  result := temp;
end;

FUNCTION Max(X: tVector; Lb, Ub: Cardinal; out pos: Integer): Float;
var
  temp: Float;
  i: Cardinal;
begin
  temp := X[Lb];
  pos := Lb;
  for i := Lb + 1 to Ub do
    if temp < X[i] then
    begin
      temp := X[i];
      pos := i;
    end;
  result := temp;
end;

FUNCTION Min(X: tIntVector; Lb, Ub: Cardinal; out pos: Integer): Integer;
var
  temp: Integer;
  i: Cardinal;
begin
  temp := X[Lb];
  pos := Lb;
  for i := Lb + 1 to Ub do
    if temp > X[i] then
    begin
      temp := X[i];
      pos := i;
    end;
  result := temp;
end;

FUNCTION Max(X: tIntVector; Lb, Ub: Cardinal; out pos: Integer): Integer;
var
  temp: Integer;
  i: Cardinal;
begin
  temp := X[Lb];
  pos := Lb;
  for i := Lb + 1 to Ub do
    if temp < X[i] then
    begin
      temp := X[i];
      pos := i;
    end;
  result := temp;
end;

Procedure MinMax(X: tVector; Lb, Ub: Cardinal; out Min, Max: Float);
var
  i: Cardinal;
begin
  Min := X[Lb];
  Max := X[Lb];
  for i := Lb + 1 to Ub do
  begin
    if Max < X[i] then
      Max := X[i];
    if Min > X[i] then
      Min := X[i];
  end;
end;

Procedure MinMax(X: tIntVector; Lb, Ub: Cardinal; out Min, Max: Integer);
var
  i: Cardinal;
begin
  Min := X[Lb];
  Max := X[Lb];
  for i := Lb + 1 to Ub do
  begin
    if Max < X[i] then
      Max := X[i];
    if Min > X[i] then
      Min := X[i];
  end;
end;

Procedure MinMax(X: TMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal; out Min, Max: Float);
var
  i, j: Cardinal;
begin
  Min := X[Lb1, Lb2];
  Max := X[Lb1, Lb2];
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
    begin
      if Max < X[i, j] then
        Max := X[i, j];
      if Min > X[i, j] then
        Min := X[i, j];
    end;
end;

Procedure MinMax(X: TIntMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max: Integer);
var
  i, j: Cardinal;
begin
  Min := X[Lb1, Lb2];
  Max := X[Lb1, Lb2];
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
    begin
      if Max < X[i, j] then
        Max := X[i, j];
      if Min > X[i, j] then
        Min := X[i, j];
    end;
end;

Procedure MinMax(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max: Float);
var
  i, j, k: Cardinal;
begin
  Min := X[Lb1, Lb2, Lb3];
  Max := X[Lb1, Lb2, Lb3];
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        if Max < X[i, j, k] then
          Max := X[i, j, k];
        if Min > X[i, j, k] then
          Min := X[i, j, k];
      end;
end;

Procedure MinMax(X: T3DIntMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max: Integer);
var
  i, j, k: Cardinal;
begin
  Min := X[Lb1, Lb2, Lb3];
  Max := X[Lb1, Lb2, Lb3];
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        if Max < X[i, j, k] then
          Max := X[i, j, k];
        if Min > X[i, j, k] then
          Min := X[i, j, k];
      end;
end;

Procedure MinMaxMean(X: tVector; Lb, Ub: Cardinal; out Min, Max, mean: Float);
var
  i: Cardinal;
  temp, cont: Float;
begin
  Min := X[Lb];
  Max := X[Lb];
  temp := X[Lb];
  cont := Ub - Lb + 1;
  for i := Lb + 1 to Ub do
  begin
    if Max < X[i] then
      Max := X[i];
    if Min > X[i] then
      Min := X[i];
    temp := temp + X[i];
  end;
  mean := temp / cont;
end;

Procedure MinMaxMean(X: tIntVector; Lb, Ub: Cardinal; out Min, Max: Integer;
  out mean: Float);
var
  i: Cardinal;
  temp, cont: Float;
begin
  Min := X[Lb];
  Max := X[Lb];
  temp := X[Lb];
  cont := Ub - Lb + 1;
  for i := Lb + 1 to Ub do
  begin
    if Max < X[i] then
      Max := X[i];
    if Min > X[i] then
      Min := X[i];
    temp := temp + X[i];
  end;
  mean := temp / cont;
end;

Procedure MinMaxMean(X: TMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max, mean: Float);
var
  i, j: Cardinal;
  temp, cont: Float;
begin
  Min := X[Lb1, Lb2];
  Max := X[Lb1, Lb2];
  temp := 0;
  cont := (Ub1 - Lb1 + 1) * (Ub2 - Lb2 + 1);
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
    begin
      if Max < X[i, j] then
        Max := X[i, j];
      if Min > X[i, j] then
        Min := X[i, j];
      temp := temp + X[i, j];
    end;
  mean := temp / cont;
end;

Procedure MinMaxMean(X: TIntMatrix; Lb1, Ub1, Lb2, Ub2: Cardinal;
  out Min, Max: Integer; out mean: Float);
var
  i, j: Cardinal;
  temp, cont: Float;
begin
  Min := X[Lb1, Lb2];
  Max := X[Lb1, Lb2];
  temp := 0;
  cont := (Ub1 - Lb1 + 1) * (Ub2 - Lb2 + 1);
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
    begin
      if Max < X[i, j] then
        Max := X[i, j];
      if Min > X[i, j] then
        Min := X[i, j];
      temp := temp + X[i, j];
    end;
  mean := temp / cont;
end;

Procedure MinMaxMean(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max, mean: Float);
var
  i, j, k: Cardinal;
  temp, cont: Float;
begin
  Min := X[Lb1, Lb2, Lb3];
  Max := X[Lb1, Lb2, Lb3];
  temp := 0;
  cont := (Ub1 - Lb1 + 1) * (Ub2 - Lb2 + 1) * (Ub3 - Lb3 + 1);
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        if Max < X[i, j, k] then
          Max := X[i, j, k];
        if Min > X[i, j, k] then
          Min := X[i, j, k];
        temp := temp + X[i, j, k];
      end;
  mean := temp / cont;
end;

Procedure MinMaxMean(X: T3DIntMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max: Integer; out mean: Float);
var
  i, j, k: Cardinal;
  temp, cont: Float;
begin
  Min := X[Lb1, Lb2, Lb3];
  Max := X[Lb1, Lb2, Lb3];
  temp := 0;
  cont := (Ub1 - Lb1 + 1) * (Ub2 - Lb2 + 1) * (Ub3 - Lb3 + 1);
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        if Max < X[i, j, k] then
          Max := X[i, j, k];
        if Min > X[i, j, k] then
          Min := X[i, j, k];
        temp := temp + X[i, j, k];
      end;
  mean := temp / cont;
end;

Procedure MinMaxMeanWOZero(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal;
  out Min, Max, mean: Float; out lSize: Integer);
var
  i, j, k, cont: Integer;
  temp, tempmin: Float;
begin
  MinMax(X, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, tempmin, Max);
  if Max = tempmin then
  begin
    Min := Max;
    mean := Max;
    exit;
  end;
  Min := X[Lb1, Lb2, Lb3];
  if Min <= tempmin then
    Min := maxnum;
  temp := 0;
  cont := 0;
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        if (X[i, j, k] > tempmin) then
        begin
          if Max < X[i, j, k] then
            Max := X[i, j, k];
          if Min > X[i, j, k] then
            Min := X[i, j, k];
          temp := temp + X[i, j, k];
          inc(cont);
        end;
      end;
  mean := divide(temp, cont);
  lSize := cont;
end;

Procedure MinMaxMeanWOZero(X: T3DIntMatrix;
  Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: Cardinal; out Min, Max: Integer;
  out mean: Float; out lSize: Integer);
var
  i, j, k, cont: Integer;
  tempmin: Integer;
  temp: Float;
begin
  MinMax(X, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, tempmin, Max);
  Min := X[Lb1, Lb2, Lb3];
  if Min <= tempmin then
    Min := MaxInt;
  temp := 0;
  cont := 0;
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        if (X[i, j, k] > tempmin) then
        begin
          if Max < X[i, j, k] then
            Max := X[i, j, k];
          if Min > X[i, j, k] then
            Min := X[i, j, k];
          temp := temp + X[i, j, k];
          inc(cont);
        end;
      end;
  mean := divide(temp, cont);
  lSize := cont;
end;

function CountNotZeros(X: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: Cardinal): Integer;
var
  i, j, k, cont: Cardinal;
  temp, tempmin: Float;
begin
  MinMax(X, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, tempmin, temp);
  cont := 0;
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
        if (X[i, j, k] > tempmin) then
          inc(cont);
  result := cont;
end;

function CountNotZeros(X: T3DIntMatrix; Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: Cardinal): Integer;
var
  i, j, k, cont: Cardinal;
  tempmin, temp: Integer;
begin
  MinMax(X, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, tempmin, temp);
  cont := 0;
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
        if (X[i, j, k] > tempmin) then
          inc(cont);
  result := cont;
end;

function PropagaError(X, Xerr: T3DMatrix; Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: Cardinal): Float;
var
  i, j, k: Cardinal;
  temp, temp2: Float;
begin
  temp := 0;
  for i := Lb1 to Ub1 do
    for j := Lb2 to Ub2 do
      for k := Lb3 to Ub3 do
      begin
        temp2 := divide(Xerr[i, j, k], X[i, j, k]);
        temp := temp + temp2 * temp2;
      end;
  result := system.sqrt(temp);
end;

function max3(P1, P2, P3: Float): Float;
begin
  if (P1 > P2) then
  begin
    if (P1 > P3) then
    begin
      result := P1;
    end
    else
    begin
      result := P3;
    end;
  end
  else if P2 > P3 then
  begin
    result := P2;
  end
  else
    result := P3;
end;

function min3(P1, P2, P3: Float): Float;
begin
  if (P1 < P2) then
  begin
    if (P1 < P3) then
    begin
      result := P1;
    end
    else
    begin
      result := P3;
    end;
  end
  else if P2 < P3 then
  begin
    result := P2;
  end
  else
    result := P3;
end;

function max3(P1, P2, P3: Integer): Integer;
begin
  if (P1 > P2) then
  begin
    if (P1 > P3) then
    begin
      result := P1;
    end
    else
    begin
      result := P3;
    end;
  end
  else if P2 > P3 then
  begin
    result := P2;
  end
  else
    result := P3;
end;

function min3(P1, P2, P3: Integer): Integer;
begin
  if (P1 < P2) then
  begin
    if (P1 < P3) then
    begin
      result := P1;
    end
    else
    begin
      result := P3;
    end;
  end
  else if P2 < P3 then
  begin
    result := P2;
  end
  else
    result := P3;
end;

end.
