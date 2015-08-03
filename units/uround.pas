{ ******************************************************************
  Rounding functions
  Based on FreeBASIC version contributed by R. Keeling
  ****************************************************************** }

unit uround;

interface

uses
  uConstants, math, umath, utypes;

function Round(X: Float): Integer; {$IFDEF INLININGSUPPORTED} inline;
{$ENDIF}overload;
{ Rounds X }

function RoundN(X: Float; N: Integer): Float;
{ Rounds X to N decimal places }

function Round(V: TVector; Ub: Integer): TIntVector; overload;
{ convert a float vector into an integer vector rounding }

function Round(V: TMatrix; Ub1, Ub2: Integer): TIntMatrix; overload;
{ convert a float matrix into an integer matrix rounding }

function Round(V: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DIntMatrix; overload;
{ convert a float 3D matrix into an integer 3D matrix rounding }

implementation

function Round(X: Float): Integer;
begin
  result := system.Round(X);
end;

function RoundN(X: Float; N: Integer): Float;
const
  MaxRoundPlaces = 18;
var
  ReturnAnswer, Dec_Place: Float;
  I: Integer;
begin
  if (N >= 0) and (N < MaxRoundPlaces) then
    I := N
  else
    I := 0;
  Dec_Place := Exp10(I);
  ReturnAnswer := Int((Abs(X) * Dec_Place) + 0.5);
  RoundN := Sign(X) * ReturnAnswer / Dec_Place;
end;

function Round(V: TVector; Ub: Integer): TIntVector;
var
  I: Integer;
begin
  DimVector(result, Ub);
  for I := 1 to Ub do
    result[I] := system.Round(V[I]);
end;

function Round(V: TMatrix; Ub1, Ub2: Integer): TIntMatrix;
var
  I, j: Integer;
begin
  DimMatrix(result, Ub1, Ub2);
  for I := 1 to Ub1 do
    for j := 1 to Ub2 do
      result[I, j] := system.Round(V[I, j]);
end;

function Round(V: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DIntMatrix;
var
  I, j, k: Integer;
begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  for I := 1 to Ub1 do
    for j := 1 to Ub2 do
      for k := 1 to Ub3 do
        result[I, j, k] := system.Round(V[I, j, k]);
end;

end.
