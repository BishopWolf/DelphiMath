{ ******************************************************************
  Polynomial regression : Y = B(1) + B(2) * X + B(3) * X^2 + ...
  ****************************************************************** }

unit upolfit;

interface

uses
  utypes, ulineq, usvdfit, umachar, uConstants;

procedure PolFit(X, Y: TVector; Lb, Ub, Deg: Integer; out B: TVector;
  out V: TMatrix);
{ ------------------------------------------------------------------
  Unweighted polynomial regression
  ------------------------------------------------------------------
  Input parameters:  X, Y   = point coordinates
  Lb, Ub = array bounds
  Deg    = degree of polynomial
  Output parameters: B      = regression parameters
  V      = inverse matrix
  ------------------------------------------------------------------ }

procedure WPolFit(X, Y, S: TVector; Lb, Ub, Deg: Integer; out B: TVector;
  out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted polynomial regression
  ------------------------------------------------------------------
  Additional input parameter:
  S = standard deviations of observations
  ------------------------------------------------------------------ }

procedure SVDPolFit(X, Y: TVector; Lb, Ub, Deg: Integer; SVDTol: Float;
  out B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Unweighted polynomial regression by singular value decomposition
  ------------------------------------------------------------------
  SVDTol = tolerance on singular values
  ------------------------------------------------------------------ }

procedure WSVDPolFit(X, Y, S: TVector; Lb, Ub, Deg: Integer; SVDTol: Float;
  out B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted polynomial regression by singular value decomposition
  ------------------------------------------------------------------ }

implementation

procedure PolFit(X, Y: TVector; Lb, Ub, Deg: Integer; out B: TVector;
  out V: TMatrix);
var
  I, I1, J, K, D1: Integer;
  XI, Det: Float;

begin
  if Ub - Lb < Deg then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;

  { Initialize }
  D1 := Deg + 1;
  DimVector(B, D1);
  DimMatrix(V, D1, D1);

  V[1, 1] := Ub - Lb + 1;

  for K := Lb to Ub do
  begin
    XI := X[K]; { x^i }
    B[1] := B[1] + Y[K];
    V[1, 2] := V[1, 2] + XI;
    B[2] := B[2] + XI * Y[K];

    for I := 3 to D1 do
    begin
      XI := XI * X[K];
      V[1, I] := V[1, I] + XI; { First line of matrix: 1 --> x^d }
      B[I] := B[I] + XI * Y[K]; { Constant vector: y --> x^d.y }
    end;

    for I := 2 to D1 do
    begin
      XI := XI * X[K];
      V[I, D1] := V[I, D1] + XI; { Last col. of matrix: x^d --> x^2d }
    end;
  end;

  { Fill lower matrix }
  for I := 2 to D1 do
  begin
    I1 := I - 1;
    for J := 1 to Deg do
      V[I, J] := V[I1, J + 1];
  end;

  { Solve system }
  LinEq(V, B, 1, D1, Det);
end;

procedure WPolFit(X, Y, S: TVector; Lb, Ub, Deg: Integer; out B: TVector;
  out V: TMatrix);
var
  I, I1, J, K, D1: Integer;
  W, WXI, Det: Float;

begin
  if Ub - Lb < Deg then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;

  { Initialize }
  D1 := Deg + 1;
  DimVector(B, D1);
  DimMatrix(V, D1, D1);

  for K := Lb to Ub do
  begin
    if S[K] <= 0.0 then
    begin
      SetErrCode(MatSing);
      Exit;
    end;

    W := 1.0 / Sqr(S[K]);
    WXI := W * X[K]; { w.x^i }
    V[1, 1] := V[1, 1] + W;
    B[1] := B[1] + W * Y[K];
    V[1, 2] := V[1, 2] + WXI;
    B[2] := B[2] + WXI * Y[K];

    for I := 3 to D1 do
    begin
      WXI := WXI * X[K];
      V[1, I] := V[1, I] + WXI; { First line of matrix: w --> w.x^d }
      B[I] := B[I] + WXI * Y[K]; { Constant vector: w.y --> w.x^d.y }
    end;

    for I := 2 to D1 do
    begin
      WXI := WXI * X[K];
      V[I, D1] := V[I, D1] + WXI; { Last col. of matrix: w.x^d --> w.x^2d }
    end;
  end;

  { Fill lower matrix }
  for I := 2 to D1 do
  begin
    I1 := I - 1;
    for J := 1 to Deg do
      V[I, J] := V[I1, J + 1];
  end;

  { Solve system }
  LinEq(V, B, 1, D1, Det);
end;

function PowMat(X: TVector; Lb, Ub, Deg: Integer): TMatrix;
{ ------------------------------------------------------------------
  Computes matrix of increasing powers of X for polynomial
  regression by singular value decomposition
  ------------------------------------------------------------------ }
var
  I, K: Integer;
begin
  DimMatrix(Result, Ub, Deg);
  for K := Lb to Ub do
  begin
    Result[K, 1] := X[K];
    for I := 2 to Deg do
      Result[K, I] := Result[K, I - 1] * X[K];
  end;
end;

procedure SVDPolFit(X, Y: TVector; Lb, Ub, Deg: Integer; SVDTol: Float;
  out B: TVector; out V: TMatrix);
var
  P: TMatrix;
begin
  // DimMatrix(P, Ub, Deg); //not need
  P := PowMat(X, Lb, Ub, Deg);
  SVDFit(P, Y, Lb, Ub, Deg, True, SVDTol, B, V);
  DelMatrix(P);
end;

procedure WSVDPolFit(X, Y, S: TVector; Lb, Ub, Deg: Integer; SVDTol: Float;
  out B: TVector; out V: TMatrix);
var
  P: TMatrix;
begin
  // DimMatrix(P, Ub, Deg);
  P := PowMat(X, Lb, Ub, Deg);
  WSVDFit(P, Y, S, Lb, Ub, Deg, True, SVDTol, B, V);
  DelMatrix(P);
end;

end.
