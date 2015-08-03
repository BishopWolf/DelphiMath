{ ******************************************************************
  Multiple linear regression (Singular Value Decomposition)
  ****************************************************************** }

unit usvdfit;

interface

uses
  utypes, usvd, umachar, uConstants;

procedure SVDFit(X: TMatrix; Y: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; SVDTol: Float; out B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Multiple linear regression: Y = B(1) + B(2) * X + B(3) * X2 + ...
  ------------------------------------------------------------------
  Input parameters:  X        = matrix of independent variables
  Y        = vector of dependent variable
  Lb, Ub   = array bounds
  Nvar     = number of independent variables
  ConsTerm = presence of constant term B(0)
  SVDTol   = tolerance on singular values
  Output parameters: B        = regression parameters
  V        = inverse matrix
  ------------------------------------------------------------------ }

procedure WSVDFit(X: TMatrix; Y, S: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; SVDTol: Float; out B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted multiple linear regression
  ------------------------------------------------------------------
  S = standard deviations of observations
  Other parameters as in SVDFit
  ------------------------------------------------------------------ }

implementation

procedure GenSVDFit(Mode: TRegMode; X: TMatrix; Y, S: TVector;
  Lb, Ub, Nvar: Integer; ConsTerm: Boolean; SVDTol: Float; out B: TVector;
  out V: TMatrix);
{ ------------------------------------------------------------------
  General multiple linear regression routine (SVD algorithm)
  ------------------------------------------------------------------ }
var
  U: TMatrix; { Matrix of independent variables for SVD }
  Z: TVector; { Vector of dependent variables for SVD }
  S2inv: TVector; { Inverses of squared singular values }
  LbU: Integer; { Lower bound of U matrix in both dim. }
  UbU: Integer; { Upper bound of U matrix in 1st dim. }
  I, J, K: Integer; { Loop variables }
  Sigma: Float; { Square root of weight }
  Sum: Float; { Element of variance-covariance matrix }
  NVar1: Integer;
  lSVD: TSVD;
begin
  if Ub - Lb < Nvar then
  begin
    SetErrCode(MatErrDim);
    Exit;
  end;
  NVar1 := Nvar + 1;
  if Mode = WLS then
    for K := Lb to Ub do
      if S[K] <= 0.0 then
      begin
        SetErrCode(MatSing);
        Exit;
      end;

  { ----------------------------------------------------------
    Prepare arrays for SVD :
    If constant term, use U[1..(N - Lb + 1), 1..Nvar+1]
    and Z[1..(N - Lb + 1)]
    else              use U[2..(N - Lb + 2), 2..Nvar+1]
    and Z[2..(N - Lb + 2)]
    since the lower bounds of U for the SVD routine must be
    the same in both dimensions
    ---------------------------------------------------------- }

  if ConsTerm then
  begin
    LbU := 1;
    UbU := Ub - Lb + 1;
  end
  else
  begin
    LbU := 2;
    UbU := Ub - Lb + 2;
  end;

  { Dimension arrays }
  DimMatrix(U, UbU, NVar1);
  DimVector(Z, UbU);
  DimVector(S2inv, Nvar);

  if Mode = OLS then
    for I := LbU to UbU do
    begin
      K := I - LbU + Lb;
      Z[I] := Y[K];
      if ConsTerm then
        U[I, 1] := 1.0;
      for J := 2 to NVar1 do
        U[I, J] := X[K, J - 1];
    end
  else
    for I := LbU to UbU do
    begin
      K := I - LbU + Lb;
      Sigma := 1.0 / S[K];
      Z[I] := Y[K] * Sigma;
      if ConsTerm then
        U[I, 1] := Sigma;
      for J := 2 to NVar1 do
        U[I, J] := X[K, J - 1] * Sigma;
    end;

  { Perform singular value decomposition }
  lSVD := TSVD.Create(U, LbU, UbU, Nvar);

  if MathErr = MatOk then
  begin
    { Set the lowest singular values to zero }
    lSVD._SetZero(SVDTol);

    { Solve the system }
    B := lSVD.Solve(Z);

    { Compute variance-covariance matrix }
    for I := LbU to Nvar do
      if lSVD.S[I] > 0.0 then
        S2inv[I] := 1.0 / Sqr(lSVD.S[I])
      else
        S2inv[I] := 0.0;
    for I := LbU to Nvar do
      for J := LbU to I do
      begin
        Sum := 0.0;
        for K := LbU to Nvar do
          Sum := Sum + lSVD.V[I, K] * lSVD.V[J, K] * S2inv[K];
        V[I, J] := Sum;
        V[J, I] := Sum;
      end;
  end;
  lSVD.Free;
  DelMatrix(U);
  DelVector(Z);
  DelVector(S2inv);
end;

procedure SVDFit(X: TMatrix; Y: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; SVDTol: Float; out B: TVector; out V: TMatrix);

begin
  GenSVDFit(OLS, X, Y, nil, Lb, Ub, Nvar, ConsTerm, SVDTol, B, V);
end;

procedure WSVDFit(X: TMatrix; Y, S: TVector; Lb, Ub, Nvar: Integer;
  ConsTerm: Boolean; SVDTol: Float; out B: TVector; out V: TMatrix);

begin
  GenSVDFit(WLS, X, Y, S, Lb, Ub, Nvar, ConsTerm, SVDTol, B, V);
end;

end.
