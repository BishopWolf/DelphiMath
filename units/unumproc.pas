unit uNumProc;

interface

uses utypes, uConstants, unlfit;

function Gaussians(X: Float; A: TVector; var dyda: TVector; na: Integer): Float;
function _Flat(X: Float; A: TVector; var dyda: TVector; na: Integer): Float;
function _Linear(X: Float; A: TVector; var dyda: TVector; na: Integer): Float;
function _Polinomial(X: Float; A: TVector; var dyda: TVector;
  na: Integer): Float;
function _Exponencial(X: Float; A: TVector; var dyda: TVector;
  na: Integer): Float;
function Gradient(X: TVector; Func: TFuncNVar): TVector;
function Jacobian(X: TVector): TMatrix;
procedure HessGrad(X: TVector; Func: TFuncNVar; out G: TVector; out H: TMatrix);
function IsPrime(Number: Integer): boolean; overload;
{ Chequea si el número es primo }
function IsPrime(Number: int64): boolean; overload;
{ Chequea si el número es primo }
Procedure PrimeFactors(Number: Integer; out Factors, Order: TIntVector);
{ da los factores primos }
function MCD(n1, n2: Integer): Integer; { maximum common divisor }
function MCM(n1, n2: Integer): Integer; { minimum common multiple }
function Espejo(Number: Integer): Integer; overload;
function Espejo(Number: int64): int64; overload;
function Espejo(Number: Cardinal): Cardinal; overload;
function Espejo(Number: Smallint): Smallint; overload;
function InttoBin(Number: Integer): string; overload;
function InttoBin(Number: int64): string; overload;
function InttoBin(Number: Cardinal): string; overload;

var
  Nvar, NumberOfGaussians: Cardinal;
  Equations: Procedure(X, F: TVector);

implementation

uses math, sysutils, uoperations, uminmax;

function IsPrime(Number: Integer): boolean;
var
  i: Integer;
begin
  result := true;
  if (Number mod 2 = 0) then
    result := false
  else
  begin
    i := 3;
    repeat
      if (Number mod i = 0) then
      begin
        result := false;
        exit;
      end
      else
        i := i + 2;
    until i > sqrt(Number);
  end;
end;

function IsPrime(Number: int64): boolean;
var
  i: int64;
begin
  result := true;
  if (Number mod 2 = 0) then
    result := false
  else
  begin
    i := 3;
    repeat
      if (Number mod i = 0) then
      begin
        result := false;
        exit;
      end
      else
        i := i + 2;
    until i * i > Number;
  end;
end;

Procedure PrimeFactors(Number: Integer; out Factors, Order: TIntVector);
var
  n, d, fsize, osize, ord: Integer;
begin
  if IsPrime(Number) then
  begin
    DimVector(Factors, 1, Number);
    DimVector(Order, 1, 1);
    exit;
  end;
  n := Number;
  fsize := 0;
  osize := 0;
  ord := 0;
  DimVector(Factors, fsize);
  DimVector(Order, osize);
  while (n mod 2 = 0) and (n <> 1) do
  begin
    inc(ord);
    n := n div 2;
  end;
  if ord >= 1 then
  begin
    Append(Factors, fsize, 2);
    Append(Order, osize, ord);
  end;
  d := 3;
  repeat
    ord := 0;
    while (n mod d = 0) and (n <> 1) do
    begin
      inc(ord);
      n := n div d;
    end;
    if ord >= 1 then
    begin
      Append(Factors, fsize, d);
      Append(Order, osize, ord);
    end;
    repeat
      d := d + 2;
    until IsPrime(d);
  until n = 1;
end;

function MCD(n1, n2: Integer): Integer;
var
  m1, m2, r: Integer;
begin
  // assert m1>m2
  if n2 > n1 then
  begin
    m1 := n2;
    m2 := n1;
  end
  else
  begin
    m1 := n1;
    m2 := n2;
  end;
  // método de Euclides en forma recursiva
  r := m1 mod m2;
  if (r = 0) then
  begin
    result := m2;
    exit;
  end;
  result := MCD(m2, r);
end;

function MCM(n1, n2: Integer): Integer;
var
  factors1, order1, factors2, order2: TIntVector;
  i, j, k, l, mult: Integer;
  present: boolean;
begin
  // Buscar los factores primos
  PrimeFactors(n1, factors1, order1);
  PrimeFactors(n2, factors2, order2);
  mult := 1;
  k := factors1[0];
  l := order1[0];
  for i := 1 to factors2[0] do
  begin
    present := false;
    for j := 1 to k do
      // buscar factores duplicados
      if factors2[i] = factors1[j] then
      begin
        present := true;
        // si está duplicado tomar el de mayor exponente
        order1[j] := max(order1[j], order2[j]);
      end;
    // si no esta duplicado incluirlo
    if not present then
    begin
      Append(factors1, k, factors2[i]);
      Append(order1, l, order2[i]);
    end;
  end;
  DelVector(factors2);
  DelVector(order2);
  // componer el MCM
  for i := 1 to k do
    mult := trunc(mult * intPOWER(factors1[i], order1[i]));
  DelVector(factors1);
  DelVector(order1);
  result := mult;
end;

function Espejo(Number: Smallint): Smallint;
var
  b1, b2: Smallint;
  i, j: word;
begin
  result := $0;
  for i := 0 to 7 do
  begin
    j := (15 - (i shl 1));
    b1 := (Number and (1 shl i)) shl j;
    b2 := (Number and (1 shl (15 - i))) shr j;
    result := (result or b1) or b2;
  end;
end;

function Espejo(Number: Integer): Integer;
var
  b1, b2: Integer;
  i, j: word;
begin
  result := $0;
  for i := 0 to 15 do
  begin
    j := (31 - (i shl 1));
    b1 := (Number and (1 shl i)) shl j;
    b2 := (Number and (1 shl (31 - i))) shr j;
    result := (result or b1) or b2;
  end;
end;

function Espejo(Number: int64): int64;
var
  b1, b2: Integer;
begin
  b1 := Espejo(Integer(Number shr 32));
  b2 := Espejo(Integer(Number and $FFFFFFFF));
  result := (int64(b2) shl 32) or int64(b1);
end;

function Espejo(Number: Cardinal): Cardinal;
var
  b1, b2: Cardinal;
  i, j: word;
begin
  result := $0;
  for i := 0 to 15 do
  begin
    j := (31 - (i shl 1));
    b1 := (Number and (1 shl i)) shl j;
    b2 := (Number and (1 shl (31 - i))) shr j;
    result := (result or b1) or b2;
  end;
end;

function InttoBin(Number: Integer): string;
var
  i: word;
begin
  result := '';
  for i := 31 downto 0 do
    result := result + inttostr((Number shr i) and $1);
end;

function InttoBin(Number: int64): string;
var
  i: word;
begin
  result := '';
  for i := 63 downto 0 do
    result := result + inttostr((Number shr i) and $1);
end;

function InttoBin(Number: Cardinal): string;
var
  i: word;
begin
  result := '';
  for i := 31 downto 0 do
    result := result + inttostr((Number shr i) and $1);
end;

{ Sumatory of Gaussians   X = variable x
  A[i] = B(k)
  A[i+1] = E(k)
  A[i+2] = G(k)
  k = NumberOfGaussians
  i=1..3*k=1..na
  out dyda = derivatives with respect of coeficients
  N is considered if BaseType=polinomial and is the order of the polinomium
  if BaseType<>flat then the array A has also the coeficients of the base function }

function Gaussians(X: Float; A: TVector; var dyda: TVector; na: Integer): Float;
var
  i: Integer;
  y, arg, ex, fac: Float;
begin
  y := 0;
  i := 1;
  repeat
    arg := (X - A[i + 1]) / A[i + 2];
    ex := system.exp(-arg * arg);
    fac := A[i] * ex * 2.0 * arg;
    y := y + A[i] * ex;
    dyda[i] := ex;
    dyda[i + 1] := fac / A[i + 2];
    dyda[i + 2] := -fac * arg / A[i + 2];
    inc(i, 3);
  until i >= na;
  result := y;
end;

function _Flat(X: Float; A: TVector; var dyda: TVector; na: Integer): Float;
begin
  dyda[1] := 0;
  result := A[1];
end;

function _Linear(X: Float; A: TVector; var dyda: TVector; na: Integer): Float;
begin
  dyda[1] := A[1];
  dyda[2] := 0;
  result := A[1] * X + A[2];
end;

function _Polinomial(X: Float; A: TVector; var dyda: TVector;
  na: Integer): Float;
var
  i: Integer;
  fac: Float;
begin
  result := 0;
  i := 1;
  repeat
    fac := intPOWER(X, i - 1);
    result := result + A[i] * fac;
    dyda[i] := fac;
    inc(i);
  until i > na;
end;

function _Exponencial(X: Float; A: TVector; var dyda: TVector;
  na: Integer): Float;
var
  ex, fac: Float;
begin
  fac := (X - A[2]) / A[3];
  ex := system.exp(fac);
  result := A[1] * ex;
  dyda[1] := ex;
  dyda[2] := -A[1] * ex / A[3];
  dyda[3] := -A[1] * ex * fac / A[3];
end;

{ ******************************************************************
  Numerical gradient
  ****************************************************************** }

function Gradient(X: TVector; Func: TFuncNVar): TVector;

const
  Eta = 1.0E-4; { Relative increment }

var
  i: Integer; { Loop variable }
  Temp: Float; { Temporary variable }
  Delta: Float; { Increment }
  Xm: Float; { X - Delta }
  Xp: Float; { X + Delta }
  Fm: Float; { F(X - Delta) }
  Fp: Float; { F(X + Delta) }

begin
  DimVector(result, Nvar);
  for i := 1 to Nvar do
  begin
    if X[i] <> 0.0 then
      Delta := Eta * Abs(X[i])
    else
      Delta := Eta;

    Xp := X[i] + Delta;
    Xm := X[i] - Delta;

    Temp := X[i];

    X[i] := Xm;
    Fm := Func(X);

    X[i] := Xp;
    Fp := Func(X);

    result[i] := (Fp - Fm) / (2.0 * Delta);

    X[i] := Temp
  end;
end;

{ ******************************************************************
  Numerical jacobian
  ****************************************************************** }

function Jacobian(X: TVector): TMatrix;
const
  EtaMin = 1E-6; { Relative increment used to compute derivatives }
var
  i, j: Integer;
  r, Temp: Float;
  Eta: Float;
  Delta: TVector; { Increment }
  Xminus: TVector; { X - Delta }
  Xplus: TVector; { X + Delta }
  Fminus: TVector; { F(X - Delta) }
  Fplus: TVector; { F(X + Delta) }

begin
  DimVector(Delta, Nvar);
  DimVector(Xminus, Nvar);
  DimVector(Xplus, Nvar);
  DimVector(Fminus, Nvar);
  DimVector(Fplus, Nvar);
  DimMatrix(result, Nvar, Nvar);
  Eta := sqrt(MachEp);
  if Eta < EtaMin then
    Eta := EtaMin;

  for i := 1 to Nvar do
  begin
    if X[i] <> 0 then
      Delta[i] := Eta * Abs(X[i])
    else
      Delta[i] := Eta;
    Xplus[i] := X[i] + Delta[i];
    Xminus[i] := X[i] - Delta[i]
  end;

  for j := 1 to Nvar do
  begin
    Temp := X[j];

    X[j] := Xminus[j];
    Equations(X, Fminus);

    X[j] := Xplus[j];
    Equations(X, Fplus);

    r := 1.0 / (2.0 * Delta[j]);

    for i := 1 to Nvar do
      result[i, j] := r * (Fplus[i] - Fminus[i]);

    X[j] := Temp;
  end;

  DelVector(Delta);
  DelVector(Xminus);
  DelVector(Xplus);
  DelVector(Fminus);
  DelVector(Fplus);
end;

{ ******************************************************************
  Numerical hessian and gradient
  ****************************************************************** }

procedure HessGrad(X: TVector; Func: TFuncNVar; out G: TVector; out H: TMatrix);

const
  Eta = 1.0E-6; { Relative increment }

var
  Delta, Xminus, Xplus, Fminus, Fplus: TVector;
  Temp1, Temp2, F, F2plus: Float;
  i, j: Integer;

begin
  DimVector(Delta, Nvar); { Increments }
  DimVector(Xminus, Nvar); { X - Delta }
  DimVector(Xplus, Nvar); { X + Delta }
  DimVector(Fminus, Nvar); { F(X - Delta) }
  DimVector(Fplus, Nvar); { F(X + Delta) }
  DimVector(G, Nvar);
  DimMatrix(H, Nvar, Nvar);
  F := Func(X);

  for i := 1 to Nvar do
  begin
    if X[i] <> 0.0 then
      Delta[i] := Eta * Abs(X[i])
    else
      Delta[i] := Eta;
    Xplus[i] := X[i] + Delta[i];
    Xminus[i] := X[i] - Delta[i];
  end;

  for i := 1 to Nvar do
  begin
    Temp1 := X[i];
    X[i] := Xminus[i];
    Fminus[i] := Func(X);
    X[i] := Xplus[i];
    Fplus[i] := Func(X);
    X[i] := Temp1;
  end;

  for i := 1 to Nvar do
  begin
    G[i] := (Fplus[i] - Fminus[i]) / (2.0 * Delta[i]);
    H[i, i] := (Fplus[i] + Fminus[i] - 2.0 * F) / Sqr(Delta[i]);
  end;

  for i := 1 to Pred(Nvar) do
  begin
    Temp1 := X[i];
    X[i] := Xplus[i];
    for j := Succ(i) to Nvar do
    begin
      Temp2 := X[j];
      X[j] := Xplus[j];
      F2plus := Func(X);
      H[i, j] := (F2plus - Fplus[i] - Fplus[j] + F) / (Delta[i] * Delta[j]);
      H[j, i] := H[i, j];
      X[j] := Temp2;
    end;
    X[i] := Temp1;
  end;

  DelVector(Delta);
  DelVector(Xminus);
  DelVector(Xplus);
  DelVector(Fminus);
  DelVector(Fplus);
end;

end.
