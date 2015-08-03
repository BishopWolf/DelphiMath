{ ******************************************************************
  Quadratic equation
  ****************************************************************** }

unit urtpol2;

interface

uses
  utypes, urtpol1;

function RootPol2(Coef: TVector; var Z: TCompVector): Integer;
{ ------------------------------------------------------------------
  Solves the quadratic equation:
  Coef[1] + Coef[2] * X + Coef[3] * X^2 = 0
  ------------------------------------------------------------------ }

implementation

uses ucomplex, uConstants;

function RootPol2(Coef: TVector; var Z: TCompVector): Integer;
var
  Delta, F, Q: Float;

begin
  Z[1] := TComplex(0, 0);
  Z[2] := TComplex(0, 0);

  if Coef[3] = 0.0 then
  begin
    RootPol2 := RootPol1(Coef[1], Coef[2], Z[1].Real);
    Exit;
  end;

  if Coef[1] = 0.0 then
  begin
    { 0 is root. Eq. becomes linear }
    if RootPol1(Coef[2], Coef[3], Z[1].Real) = 1 then
      { Linear eq. has 1 solution }
      RootPol2 := 2
    else
      { Linear eq. is undetermined or impossible }
      RootPol2 := 1;
    Exit;
  end;

  Delta := Sqr(Coef[2]) - 4.0 * Coef[1] * Coef[3];

  { 2 real roots }
  if Delta > 0.0 then
  begin
    RootPol2 := 2;

    { Algorithm for minimizing roundoff errors }
    { See `Numerical Recipes' }
    if Coef[1] >= 0.0 then
      Q := -0.5 * (Coef[2] + Sqrt(Delta))
    else
      Q := -0.5 * (Coef[2] - Sqrt(Delta));

    Z[1].Real := Q / Coef[3];
    Z[2].Real := Coef[1] / Q;

    Exit;
  end;

  { Double real root }
  if Delta = 0.0 then
  begin
    RootPol2 := 2;
    Z[1].Real := -0.5 * Coef[2] / Coef[3];
    Z[2].Real := Z[1].Real;
    Exit;
  end;

  { 2 complex roots }
  RootPol2 := 0;
  F := 0.5 / Coef[3];
  Z[1].Real := -F * Coef[2];
  Z[1].Imaginary := Abs(F) * Sqrt(-Delta);
  Z[2].Real := Z[1].Real;
  Z[2].Imaginary := -Z[1].Imaginary;
end;

end.
