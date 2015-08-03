{ ******************************************************************
  Quartic equation
  ****************************************************************** }

unit urtpol4;

interface

uses
  utypes, urtpol2, urtpol3;

function RootPol4(Coef: TVector; out Z: TCompVector): Integer;
{ ------------------------------------------------------------------
  Solves the quartic equation:
  Coef[1] + Coef[2] * X + Coef[3] * X^2 + Coef[4] * X^3 +
  Coef[5] * X^4 = 0
  ------------------------------------------------------------------ }

implementation

uses uConstants;

function RootPol4(Coef: TVector; out Z: TCompVector): Integer;
var
  A, AA, B, C, D: Float;
  Q, R, S: Float;
  K, KK, L, M: Float;
  N1, N2: Integer;
  Cf: TVector;
  Z1, Z2: TCompVector;

  function HighestRealRoot(Deg: Integer; Z: TCompVector): Float;
  { Find the highest real root among the roots of a polynomial }
  var
    I: Integer;
    R: Float;
  begin
    R := -MaxNum;
    for I := 1 to Deg do
      if (Z[I].Imaginary = 0.0) and (Z[I].Real > R) then
        R := Z[I].Real;
    HighestRealRoot := R;
  end;

begin
  DimVector(Z, 4, 0);
  { for I := 1 to 4 do //not need
    begin
    Z[I].Real := 0.0;
    Z[I].Imaginary := 0.0;
    end; }

  if Coef[5] = 0 then
  begin
    RootPol4 := RootPol3(Coef, Z);
    Exit;
  end;

  DimVector(Cf, 4);

  if Coef[1] = 0.0 then
  begin
    { 0 is root. Equation becomes cubic }
    Cf[1] := Coef[2];
    Cf[2] := Coef[3];
    Cf[3] := Coef[4];
    Cf[4] := Coef[5];

    { Solve cubic equation }
    RootPol4 := RootPol3(Cf, Z) + 1;

    DelVector(Cf);
    Exit;
  end;

  if Coef[5] = 1.0 then
  begin
    A := Coef[4] * 0.25;
    B := Coef[3];
    C := Coef[2];
    D := Coef[1];
  end
  else
  begin
    A := Coef[4] / Coef[5] * 0.25;
    B := Coef[3] / Coef[5];
    C := Coef[2] / Coef[5];
    D := Coef[1] / Coef[5];
  end;

  AA := A * A;

  Q := B - 6.0 * AA;
  R := C + A * (8.0 * AA - 2.0 * B);
  S := D - A * C + AA * (B - 3.0 * AA);

  { Compute coefficients of cubic equation }
  Cf[4] := 1.0;
  Cf[3] := 0.5 * Q;
  Cf[2] := 0.25 * (Sqr(Cf[1]) - S);

  { Solve cubic equation and set KK = highest real root }
  if (R = 0.0) and (Cf[1] < 0.0) then
  begin
    { Eq. becomes quadratic with 2 real roots }
    Cf[1] := Cf[2];
    Cf[2] := Cf[3];
    Cf[3] := 1.0;
    { N1 := not needed } RootPol2(Cf, Z);
    KK := HighestRealRoot(2, Z);
  end
  else
  begin
    Cf[1] := -0.015625 * Sqr(R);
    { N1 := not needed } RootPol3(Cf, Z);
    KK := HighestRealRoot(3, Z);
  end;

  K := Sqrt(KK);
  if K = 0.0 then
    R := Sqrt(Sqr(Q) - 4.0 * S)
  else
  begin
    Q := Q + 4.0 * KK;
    R := 0.5 * R / K;
  end;

  L := 0.5 * (Q - R);
  M := 0.5 * (Q + R);

  { Solve quadratic equation: Y^2 + 2KY + L = 0 }
  DimVector(Z1, 2, 0);
  Cf[1] := L;
  Cf[2] := 2.0 * K;
  Cf[3] := 1.0;
  N1 := RootPol2(Cf, Z1);

  { Solve quadratic equation: Z^2 - 2KZ + M = 0 }
  DimVector(Z2, 2, 0);
  Cf[1] := M;
  Cf[2] := -Cf[2];
  N2 := RootPol2(Cf, Z2);

  { Transfer roots into vectors Xr and Xi }
  Z[1].Real := Z1[1].Real - A;
  Z[1].Imaginary := Z1[1].Imaginary;
  Z[2].Real := Z1[2].Real - A;
  Z[2].Imaginary := Z1[2].Imaginary;
  Z[3].Real := Z2[1].Real - A;
  Z[3].Imaginary := Z2[1].Imaginary;
  Z[4].Real := Z2[2].Real - A;
  Z[4].Imaginary := Z2[2].Imaginary;

  RootPol4 := N1 + N2;

  DelVector(Cf);
  DelVector(Z1);
  DelVector(Z2);
end;

end.
