{ ******************************************************************
  Polynomials and rational fractions
  ****************************************************************** }

unit upolynom;

interface

uses
  utypes, uConstants;

function Poly(X: Float; Coef: TVector; Deg: Integer): Float;
{ ------------------------------------------------------------------
  Evaluates the polynomial :
  P(X) = Coef[1] + Coef[2] * X + Coef[3] * X^2 + ...
  + Coef[Deg+1] * X^Deg
  ------------------------------------------------------------------ }

function RFrac(X: Float; Coef: TVector; Deg1, Deg2: Integer): Float;
{ ------------------------------------------------------------------
  Evaluates the rational fraction :

  Coef[1] + Coef[2] * X + ... + Coef[Deg1+1] * X^Deg1
  F(X) = -----------------------------------------------------
  1 + Coef[Deg1+2] * X + ... + Coef[Deg1+Deg2+1] * X^Deg2
  ------------------------------------------------------------------ }

implementation

function Poly(X: Float; Coef: TVector; Deg: Integer): Float;
var
  I: Integer;
  P: Float;
begin
  P := Coef[Deg + 1];
  for I := (Deg) downto 1 do
    P := P * X + Coef[I];
  Poly := P;
end;

function RFrac(X: Float; Coef: TVector; Deg1, Deg2: Integer): Float;
var
  I: Integer;
  P, Q: Float;
begin
  P := Coef[Deg1 + 1];
  for I := (Deg1) downto 1 do
    P := P * X + Coef[I];
  Q := 0.0;
  for I := (Deg1 + Deg2 + 1) downto (Deg1 + 2) do
    Q := (Q + Coef[I]) * X;
  RFrac := P / (1.0 + Q);
end;

end.
