{ ******************************************************************
  Multiple linear regression (Gauss-Jordan method)
  ****************************************************************** }

unit umulfit;

interface

uses
  utypes, ulineq;

procedure MulFit(X: TMatrix; Y: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; out B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Multiple linear regression: Y = B(1) + B(2) * X + B(3) * X2 + ...
  ------------------------------------------------------------------
  Input parameters:  X        = matrix of independent variables
  Y        = vector of dependent variable
  Lb, Ub   = array bounds
  Nvar     = number of independent variables
  ConsTerm = presence of constant term B(0)
  Output parameters: B        = regression parameters
  V        = inverse matrix
  ------------------------------------------------------------------ }

procedure WMulFit(X: TMatrix; Y, S: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; out B: TVector; out V: TMatrix);
{ ----------------------------------------------------------------------
  Weighted multiple linear regression
  ----------------------------------------------------------------------
  S = standard deviations of observations
  Other parameters as in MulFit
  ---------------------------------------------------------------------- }

implementation

uses umachar, uConstants;

procedure MulFit(X: TMatrix; Y: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; out B: TVector; out V: TMatrix);

var
  Lb1: Integer; { Index of first param. (1 if cst term, 2 otherwise) }
  NVar1: Integer;
  I, J, K: Integer; { Loop variables }
  Det: Float; { Determinant }

begin
  if Ub - Lb < Nvar then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;

  { Initialize }
  NVar1 := Nvar + 1; // Nvar + independent term
  DimVector(B, NVar1);
  DimMatrix(V, NVar1, NVar1);

  { If constant term, set line 1 and column 1 of matrix V }
  if ConsTerm then
  begin
    V[1, 1] := Ub - Lb + 1;
    for K := Lb to Ub do
    begin
      for J := 2 to NVar1 do
        V[1, J] := V[1, J] + X[K, J - 1];
      B[1] := B[1] + Y[K];
    end;
    for J := 2 to NVar1 do
      V[J, 1] := V[1, J];
  end;

  { Set other elements of V }
  for K := Lb to Ub do
    for I := 2 to NVar1 do
    begin
      for J := I to NVar1 do
        V[I, J] := V[I, J] + X[K, I - 1] * X[K, J - 1];
      B[I] := B[I] + X[K, I - 1] * Y[K];
    end;

  { Fill in symmetric matrix }
  for I := 3 to NVar1 do
    for J := 2 to Pred(I) do
      V[I, J] := V[J, I];

  { Solve normal equations }
  if ConsTerm then
    Lb1 := 1
  else
    Lb1 := 2;
  LinEq(V, B, Lb1, NVar1, Det);
end;

procedure WMulFit(X: TMatrix; Y, S: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; out B: TVector; out V: TMatrix);

var
  Lb1: Integer; { Index of first param. (1 if cst term, 2 otherwise) }
  NVar1: Integer;
  I, J, K: Integer; { Loop variables }
  W: TVector; { Vector of weights }
  WX: Float; { W * X }
  Det: Float; { Determinant }

begin
  if Ub - Lb < Nvar then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;

  for K := Lb to Ub do
    if S[K] <= 0.0 then
    begin
      SetErrCode(MatSing);
      Exit;
    end;

  DimVector(W, Ub);

  for K := Lb to Ub do
    W[K] := 1.0 / Sqr(S[K]);

  { Initialize }
  NVar1 := Nvar + 1;
  DimVector(B, NVar1);
  DimMatrix(V, NVar1, NVar1);

  { If constant term, set line 1 and column 1 of matrix V }
  if ConsTerm then
  begin
    for K := Lb to Ub do
    begin
      V[1, 1] := V[1, 1] + W[K];
      for J := 2 to NVar1 do
        V[1, J] := V[1, J] + W[K] * X[K, J - 1];
      B[1] := B[1] + W[K] * Y[K];
    end;
    for J := 2 to NVar1 do
      V[J, 1] := V[1, J];
  end;

  { Set other elements of V }
  for K := Lb to Ub do
    for I := 2 to NVar1 do
    begin
      WX := W[K] * X[K, I - 1];
      for J := I to NVar1 do
        V[I, J] := V[I, J] + WX * X[K, J - 1];
      B[I] := B[I] + WX * Y[K];
    end;

  { Fill in symmetric matrix }
  for I := 3 to NVar1 do
    for J := 2 to Pred(I) do
      V[I, J] := V[J, I];

  { Solve normal equations }
  if ConsTerm then
    Lb1 := 1
  else
    Lb1 := 2;
  LinEq(V, B, Lb1, NVar1, Det);

  DelVector(W);
end;

end.
