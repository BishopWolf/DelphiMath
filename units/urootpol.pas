{ ******************************************************************
  Roots of a polynomial from the companion matrix
  ****************************************************************** }

unit urootpol;

interface

uses
  utypes, ubalance, uhqr, uConstants;

function RootPol(Coef: TVector; Deg: Integer; out Z: TCompVector): Integer;
{ ------------------------------------------------------------------
  Solves the polynomial equation:
  Coef(1) + Coef(2) * Z + Coef(3) * Z^2 + ...
  + Coef(Deg+1) * Z^Deg = 0
  ------------------------------------------------------------------ }

implementation

function RootPol(Coef: TVector; Deg: Integer; out Z: TCompVector): Integer;

var
  Lo, Hi: Integer; { Used by Balance }
  I, J: Integer; { Loop variables }
  Nr: Integer; { Number of real roots }
  Deg1: Integer; { Deg + 1 }
  A: TMatrix; { Companion matrix }
  Scale: TVector; { Used by Balance }

begin
  { Dimension arrays }
  DimMatrix(A, Deg, Deg);
  // DimVector(Scale, Deg);  //not need
  Deg1 := Deg + 1;
  { Set up the companion matrix }
  for J := 1 to Deg do
    A[1, J] := -Coef[Deg1 - J] / Coef[Deg1];

  for I := 2 to Deg do
    for J := 1 to Deg do
      if I - 1 = J then
        A[I, J] := 1.0
      else
        A[I, J] := 0.0;

  { The roots of the polynomial are the
    eigenvalues of the companion matrix }
  Balance(A, 1, Deg, Lo, Hi, Scale);
  Hqr(A, 1, Deg, Lo, Hi, Z);

  if MathErr <> 0 then
  begin
    RootPol := MathErr;
    Exit;
  end;

  { Count real roots }
  Nr := 0;
  for I := 1 to Deg do
    if Z[I].Imaginary = 0.0 then
      Nr := Nr + 1;

  RootPol := Nr
end;

end.
