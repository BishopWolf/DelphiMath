unit UTypeCasts;

{ Unit UTypeCasts : Types Cast Unit

  Created by : Alex Vergara Gil

  Contains the routines for conversions

}

interface

uses utypes, umachar;

function FMatrixToVector(const A: TMatrix; Ub1, Ub2: integer): TVector;
function IMatrixToVector(const A: TIntMatrix; Ub1, Ub2: integer): TIntVector;
function BMatrixToVector(const A: TBoolMatrix; Ub1, Ub2: integer): TBoolVector;
function CMatrixToVector(const A: TCompMatrix; Ub1, Ub2: integer): TCompVector;
function SMatrixToVector(const A: TStrMatrix; Ub1, Ub2: integer): TStrVector;

function FVectorToMatrix(const V: TVector; Ub1, Ub2: integer): TMatrix;
function IVectorToMatrix(const V: TIntVector; Ub1, Ub2: integer): TIntMatrix;
function BVectorToMatrix(const V: TBoolVector; Ub1, Ub2: integer): TBoolMatrix;
function CVectorToMatrix(const V: TCompVector; Ub1, Ub2: integer): TCompMatrix;
function SVectorToMatrix(const V: TStrVector; Ub1, Ub2: integer): TStrMatrix;

function F3DMatrixToVector(const A: T3dMatrix; Ub1, Ub2, Ub3: integer): TVector;
function I3DMatrixToVector(const A: T3dIntMatrix; Ub1, Ub2, Ub3: integer)
  : TIntVector;
function B3DMatrixToVector(const A: T3dBoolMatrix; Ub1, Ub2, Ub3: integer)
  : TBoolVector;
function C3DMatrixToVector(const A: T3dCompMatrix; Ub1, Ub2, Ub3: integer)
  : TCompVector;
function S3DMatrixToVector(const A: T3dStrMatrix; Ub1, Ub2, Ub3: integer)
  : TStrVector;

function FVectorTo3DMatrix(const V: TVector; Ub1, Ub2, Ub3: integer): T3dMatrix;
function IVectorTo3DMatrix(const V: TIntVector; Ub1, Ub2, Ub3: integer)
  : T3dIntMatrix;
function BVectorTo3DMatrix(const V: TBoolVector; Ub1, Ub2, Ub3: integer)
  : T3dBoolMatrix;
function CVectorTo3DMatrix(const V: TCompVector; Ub1, Ub2, Ub3: integer)
  : T3dCompMatrix;
function SVectorTo3DMatrix(const V: TStrVector; Ub1, Ub2, Ub3: integer)
  : T3dStrMatrix;

procedure InttoFloat(const inVector: TIntVector; out outVector: TVector;
  ma: integer); overload;
procedure InttoFloat(const inMatrix: TIntMatrix; out outMatrix: TMatrix;
  m, n: integer); overload;
procedure InttoFloat(const inMatrix: T3dIntMatrix; out outMatrix: T3dMatrix;
  m, n, o: integer); overload;

function CVtoFV(Vector: TCompVector; Ub: integer): TVector;
function FVtoCV(Vector: TVector; Ub: integer): TCompVector;

implementation

uses ucomplex;

function FMatrixToVector(const A: TMatrix; Ub1, Ub2: integer): TVector;
var
  i, j, k: integer;
begin
  DimVector(result, Ub1 * Ub2);
  k := 0;
  for j := 1 to Ub2 do
    for i := 1 to Ub1 do
    begin
      inc(k);
      result[k] := A[i, j];
    end;
end;

function IMatrixToVector(const A: TIntMatrix; Ub1, Ub2: integer): TIntVector;
var
  i, j, k: integer;
begin
  DimVector(result, Ub1 * Ub2);
  k := 0;
  for j := 1 to Ub2 do
    for i := 1 to Ub1 do
    begin
      inc(k);
      result[k] := A[i, j];
    end;
end;

function BMatrixToVector(const A: TBoolMatrix; Ub1, Ub2: integer): TBoolVector;
var
  i, j, k: integer;
begin
  DimVector(result, Ub1 * Ub2);
  k := 0;
  for j := 1 to Ub2 do
    for i := 1 to Ub1 do
    begin
      inc(k);
      result[k] := A[i, j];
    end;
end;

function CMatrixToVector(const A: TCompMatrix; Ub1, Ub2: integer): TCompVector;
var
  i, j, k: integer;
begin
  DimVector(result, Ub1 * Ub2, 0);
  k := 0;
  for j := 1 to Ub2 do
    for i := 1 to Ub1 do
    begin
      inc(k);
      result[k] := CloneComplex(A[i, j]);
    end;
end;

function SMatrixToVector(const A: TStrMatrix; Ub1, Ub2: integer): TStrVector;
var
  i, j, k: integer;
begin
  DimVector(result, Ub1 * Ub2);
  k := 0;
  for j := 1 to Ub2 do
    for i := 1 to Ub1 do
    begin
      inc(k);
      result[k] := A[i, j];
    end;
end;

function FVectorToMatrix(const V: TVector; Ub1, Ub2: integer): TMatrix;
var
  i, j, k: integer;
begin
  DimMatrix(result, Ub1, Ub2);
  for k := 1 to Ub1 * Ub2 do
  begin
    i := (k - 1) mod Ub1 + 1;
    j := (k - 1) div Ub1 + 1;
    result[i, j] := V[k];
  end;
end;

function IVectorToMatrix(const V: TIntVector; Ub1, Ub2: integer): TIntMatrix;
var
  i, j, k: integer;
begin
  DimMatrix(result, Ub1, Ub2);
  for k := 1 to Ub1 * Ub2 do
  begin
    i := (k - 1) mod Ub1 + 1;
    j := (k - 1) div Ub1 + 1;
    result[i, j] := V[k];
  end;
end;

function BVectorToMatrix(const V: TBoolVector; Ub1, Ub2: integer): TBoolMatrix;
var
  i, j, k: integer;
begin
  DimMatrix(result, Ub1, Ub2);
  for k := 1 to Ub1 * Ub2 do
  begin
    i := (k - 1) mod Ub1 + 1;
    j := (k - 1) div Ub1 + 1;
    result[i, j] := V[k];
  end;
end;

function CVectorToMatrix(const V: TCompVector; Ub1, Ub2: integer): TCompMatrix;
var
  i, j, k: integer;
begin
  DimMatrix(result, Ub1, Ub2, 0);
  for k := 1 to Ub1 * Ub2 do
  begin
    i := (k - 1) mod Ub1 + 1;
    j := (k - 1) div Ub1 + 1;
    result[i, j] := CloneComplex(V[k]);
  end;
end;

function SVectorToMatrix(const V: TStrVector; Ub1, Ub2: integer): TStrMatrix;
var
  i, j, k: integer;
begin
  DimMatrix(result, Ub1, Ub2);
  for k := 1 to Ub1 * Ub2 do
  begin
    i := (k - 1) mod Ub1 + 1;
    j := (k - 1) div Ub1 + 1;
    result[i, j] := V[k];
  end;
end;

function F3DMatrixToVector(const A: T3dMatrix; Ub1, Ub2, Ub3: integer): TVector;
var
  i, j, k, m: integer;
begin
  DimVector(result, Ub1 * Ub2 * Ub3);
  m := 0;
  for k := 1 to Ub3 do
    for j := 1 to Ub2 do
      for i := 1 to Ub1 do
      begin
        inc(m);
        result[m] := A[i, j, k];
      end;
end;

function I3DMatrixToVector(const A: T3dIntMatrix; Ub1, Ub2, Ub3: integer)
  : TIntVector;
var
  i, j, k, m: integer;
begin
  DimVector(result, Ub1 * Ub2 * Ub3);
  m := 0;
  for k := 1 to Ub3 do
    for j := 1 to Ub2 do
      for i := 1 to Ub1 do
      begin
        inc(m);
        result[m] := A[i, j, k];
      end;
end;

function B3DMatrixToVector(const A: T3dBoolMatrix; Ub1, Ub2, Ub3: integer)
  : TBoolVector;
var
  i, j, k, m: integer;
begin
  DimVector(result, Ub1 * Ub2 * Ub3);
  m := 0;
  for k := 1 to Ub3 do
    for j := 1 to Ub2 do
      for i := 1 to Ub1 do
      begin
        inc(m);
        result[m] := A[i, j, k];
      end;
end;

function C3DMatrixToVector(const A: T3dCompMatrix; Ub1, Ub2, Ub3: integer)
  : TCompVector;
var
  i, j, k, m: integer;
begin
  DimVector(result, Ub1 * Ub2 * Ub3, 0);
  m := 0;
  for k := 1 to Ub3 do
    for j := 1 to Ub2 do
      for i := 1 to Ub1 do
      begin
        inc(m);
        result[m] := CloneComplex(A[i, j, k]);
      end;
end;

function S3DMatrixToVector(const A: T3dStrMatrix; Ub1, Ub2, Ub3: integer)
  : TStrVector;
var
  i, j, k, m: integer;
begin
  DimVector(result, Ub1 * Ub2 * Ub3);
  m := 0;
  for k := 1 to Ub3 do
    for j := 1 to Ub2 do
      for i := 1 to Ub1 do
      begin
        inc(m);
        result[m] := A[i, j, k];
      end;
end;

function FVectorTo3DMatrix(const V: TVector; Ub1, Ub2, Ub3: integer): T3dMatrix;
var
  i, j, k, m: integer;
begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  for m := 1 to Ub1 * Ub2 * Ub3 do
  begin
    i := (m - 1) mod Ub1 + 1;
    j := ((m - 1) div Ub1) mod Ub2 + 1;
    k := ((m - 1) div (Ub1 * Ub2)) + 1;
    result[i, j, k] := V[m];
  end;
end;

function IVectorTo3DMatrix(const V: TIntVector; Ub1, Ub2, Ub3: integer)
  : T3dIntMatrix;
var
  i, j, k, m: integer;
begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  for m := 1 to Ub1 * Ub2 * Ub3 do
  begin
    i := (m - 1) mod Ub1 + 1;
    j := ((m - 1) div Ub1) mod Ub2 + 1;
    k := ((m - 1) div (Ub1 * Ub2)) + 1;
    result[i, j, k] := V[m];
  end;
end;

function BVectorTo3DMatrix(const V: TBoolVector; Ub1, Ub2, Ub3: integer)
  : T3dBoolMatrix;
var
  i, j, k, m: integer;
begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  for m := 1 to Ub1 * Ub2 * Ub3 do
  begin
    i := (m - 1) mod Ub1 + 1;
    j := ((m - 1) div Ub1) mod Ub2 + 1;
    k := ((m - 1) div (Ub1 * Ub2)) + 1;
    result[i, j, k] := V[m];
  end;
end;

function CVectorTo3DMatrix(const V: TCompVector; Ub1, Ub2, Ub3: integer)
  : T3dCompMatrix;
var
  i, j, k, m: integer;
begin
  DimMatrix(result, Ub1, Ub2, Ub3, 0);
  for m := 1 to Ub1 * Ub2 * Ub3 do
  begin
    i := (m - 1) mod Ub1 + 1;
    j := ((m - 1) div Ub1) mod Ub2 + 1;
    k := ((m - 1) div (Ub1 * Ub2)) + 1;
    result[i, j, k] := CloneComplex(V[m]);
  end;
end;

function SVectorTo3DMatrix(const V: TStrVector; Ub1, Ub2, Ub3: integer)
  : T3dStrMatrix;
var
  i, j, k, m: integer;
begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  for m := 1 to Ub1 * Ub2 * Ub3 do
  begin
    i := (m - 1) mod Ub1 + 1;
    j := ((m - 1) div Ub1) mod Ub2 + 1;
    k := ((m - 1) div (Ub1 * Ub2)) + 1;
    result[i, j, k] := V[m];
  end;
end;

procedure InttoFloat(const inVector: TIntVector; out outVector: TVector;
  ma: integer);
var
  i: integer;
begin
  DimVector(outVector, ma);
  for i := 1 to ma do
    outVector[i] := inVector[i];
end;

procedure InttoFloat(const inMatrix: TIntMatrix; out outMatrix: TMatrix;
  m, n: integer);
var
  i, j: integer;
begin
  DimMatrix(outMatrix, m, n);
  for i := 1 to m do
    for j := 1 to n do
      outMatrix[i, j] := inMatrix[i, j];
end;

procedure InttoFloat(const inMatrix: T3dIntMatrix; out outMatrix: T3dMatrix;
  m, n, o: integer);
var
  i, j, k: integer;
begin
  DimMatrix(outMatrix, m, n, o);
  for i := 1 to m do
    for j := 1 to n do
      for k := 1 to o do
        outMatrix[i, j, k] := inMatrix[i, j, k];
end;

function CVtoFV(Vector: TCompVector; Ub: integer): TVector;
var
  i, n: integer;
begin
  n := Ub shl 1;
  DimVector(result, n);
  for i := 1 to Ub do
  begin
    result[i] := Vector[i].Real;
    result[i + Ub] := Vector[i].Imaginary;
  end; { }
  { i:=2;
    repeat
    result[i-1]:=vector[i shr 1].Real;
    result[i]  :=vector[i shr 1].Imaginary;
    inc(i,2);
    until i>n;  { }
end;

function FVtoCV(Vector: TVector; Ub: integer): TCompVector;
var
  i, n: integer;
begin
  n := Ub shr 1;
  DimVector(result, n, 0);
  for i := 1 to n do
    result[i] := TComplex(Vector[2 * i - 1], Vector[2 * i]);
end;

end.
