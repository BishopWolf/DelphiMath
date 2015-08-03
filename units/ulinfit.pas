{ ******************************************************************
  Linear regression : Y = B(1) + B(2) * X
  ****************************************************************** }

unit ulinfit;

interface

uses
  utypes;

procedure LinFit(X, Y: TVector; Lb, Ub: Integer; out B: TVector;
  out V: TMatrix);
{ ------------------------------------------------------------------
  Unweighted linear regression
  ------------------------------------------------------------------
  Input parameters:  X, Y   = point coordinates
  Lb, Ub = array bounds
  Output parameters: B      = regression parameters
  V      = inverse matrix
  ------------------------------------------------------------------ }

procedure WLinFit(X, Y, S: TVector; Lb, Ub: Integer; out B: TVector;
  out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted linear regression
  ------------------------------------------------------------------
  Additional input parameter:
  S = standard deviations of observations
  ------------------------------------------------------------------ }

implementation

uses umachar, uConstants;

procedure LinFit(X, Y: TVector; Lb, Ub: Integer; out B: TVector;
  out V: TMatrix);

var
  SX, SY, SX2, SXY, D: Float;
  K, N: Integer;

begin
  N := Ub - Lb + 1;

  SX := 0.0;
  SY := 0.0;
  SX2 := 0.0;
  SXY := 0.0;

  for K := Lb to Ub do
  begin
    SX := SX + X[K];
    SY := SY + Y[K];
    SX2 := SX2 + Sqr(X[K]);
    SXY := SXY + X[K] * Y[K];
  end;

  D := N * SX2 - Sqr(SX);

  if D <= 0.0 then
  begin
    SetErrCode(MatSing);
    Exit;
  end;

  SetErrCode(MatOk);
  DimMatrix(V, 2, 2);
  V[1, 1] := SX2 / D;
  V[1, 2] := -SX / D;
  V[2, 1] := V[1, 2];
  V[2, 2] := N / D;
  DimVector(B, 2);
  B[1] := V[1, 1] * SY + V[1, 2] * SXY;
  B[2] := V[2, 1] * SY + V[2, 2] * SXY;
end;

procedure WLinFit(X, Y, S: TVector; Lb, Ub: Integer; out B: TVector;
  out V: TMatrix);

var
  W, WX, SW, SWX, SWY, SWX2, SWXY, D: Float;
  K: Integer;

begin
  SW := 0.0;
  SWX := 0.0;
  SWY := 0.0;
  SWX2 := 0.0;
  SWXY := 0.0;

  for K := Lb to Ub do
  begin
    if S[K] <= 0.0 then
    begin
      SetErrCode(MatSing);
      Exit;
    end;

    W := 1.0 / Sqr(S[K]);
    WX := W * X[K];

    SW := SW + W;
    SWX := SWX + WX;
    SWY := SWY + W * Y[K];
    SWX2 := SWX2 + WX * X[K];
    SWXY := SWXY + WX * Y[K];
  end;

  D := SW * SWX2 - Sqr(SWX);

  if D <= 0.0 then
  begin
    SetErrCode(MatSing);
    Exit;
  end;

  SetErrCode(MatOk);
  DimMatrix(V, 2, 2);
  V[1, 1] := SWX2 / D;
  V[1, 2] := -SWX / D;
  V[2, 1] := V[1, 2];
  V[2, 2] := SW / D;
  DimVector(B, 2);
  B[1] := V[1, 1] * SWY + V[1, 2] * SWXY;
  B[2] := V[2, 1] * SWY + V[2, 2] * SWXY;
end;

end.
