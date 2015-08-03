{ ******************************************************************
  Cubic equation
  ****************************************************************** }

unit urtpol3;

interface

uses
  utypes, urtpol2;

function RootPol3(Coef: TVector; out Z: TCompVector): Integer;
{ ------------------------------------------------------------------
  Solves the cubic equation:
  Coef[1] + Coef[2] * X + Coef[3] * X^2 + Coef[4] * X^3 = 0
  ------------------------------------------------------------------ }

implementation

uses umachar, uConstants;

function RootPol3(Coef: TVector; out Z: TCompVector): Integer;
const
  OneThird = 0.333333333333333333; { 1 / 3 }
  TwoPiDiv3 = 2.09439510239319549; { 2 Pi / 3 }
  Sqrt3Div2 = 0.866025403784438647; { Sqrt(3) / 2 }

var
  A, AA, B, C: Float;
  Q, QQQ, R, RR: Float;
  S, T, U: Float;
  Cf: TVector;

begin
  DimVector(Z, 3, 0);
  { for I := 1 to 3 do   //not need
    begin
    Z[I].Real := 0.0;
    Z[I].Imaginary := 0.0;
    end; }

  if Coef[3] = 0.0 then
  begin
    RootPol3 := RootPol2(Coef, Z);
    Exit;
  end;

  if Coef[0] = 0.0 then
  begin
    DimVector(Cf, 3);

    { 0 is root. Equation becomes quadratic }
    Cf[1] := Coef[2];
    Cf[2] := Coef[3];
    Cf[3] := Coef[4];

    { Solve quadratic equation }
    RootPol3 := RootPol2(Cf, Z) + 1;

    DelVector(Cf);
    Exit;
  end;

  if Coef[4] = 1.0 then
  begin
    A := Coef[3] * OneThird;
    B := Coef[2];
    C := Coef[1];
  end
  else
  begin
    A := Coef[3] / Coef[4] * OneThird;
    B := Coef[2] / Coef[4];
    C := Coef[1] / Coef[4];
  end;

  AA := A * A;

  Q := AA - OneThird * B;
  R := A * (AA - 0.5 * B) + 0.5 * C;
  RR := Sqr(R);
  QQQ := Q * Sqr(Q);

  if RR < QQQ then { 3 X roots }
  begin
    RootPol3 := 3;
    S := Sqrt(Q);
    T := R / (Q * S);
    T := PiDiv2 - ArcTan(T / Sqrt(1.0 - T * T)); { ArcCos(T) }
    T := OneThird * T;
    S := -2.0 * S;
    Z[1].Real := S * Cos(T) - A;
    Z[2].Real := S * Cos(T + TwoPiDiv3) - A;
    Z[3].Real := S * Cos(T - TwoPiDiv3) - A;
  end
  else { 1 real root }
  begin
    RootPol3 := 1;
    S := Abs(R) + Sqrt(RR - QQQ);
    if S > 0.0 then
      S := Exp(OneThird * Ln(S));
    if R > 0.0 then
      S := -S;
    if S = 0.0 then
      T := 0.0
    else
      T := Q / S;
    U := S + T;
    Z[1].Real := U - A; { Real root }
    Z[2].Real := -0.5 * U - A;
    Z[2].Imaginary := Sqrt3Div2 * Abs(S - T);
    Z[3].Real := Z[2].Real;
    Z[3].Imaginary := -Z[2].Imaginary;
  end;
end;

end.
