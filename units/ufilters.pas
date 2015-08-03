unit ufilters;

interface

uses uConstants, utypes;

type
  arr2 = array [1 .. 3, 1 .. 3] of float;
  arr3 = array [1 .. 3, 1 .. 3, 1 .. 3] of float;

const
  EdgeMatrix2: arr2 = ((-1, -4, -1), (-4, 20, -4), (-1, -4, -1));
  EdgeMatrix3: arr3 = (((-1, -2, -1), (-2, -4, -2), (-1, -2, -1)),
    ((-2, -4, -2), (-4, 32, -4), (-2, -4, -2)), ((-1, -2, -1), (-2, -4, -2),
    (-1, -2, -1)));

function LocalMean(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function LocalMean(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function LocalMean(const InMatrix: TMatrix; const Lb1, Ub1, Lb2, Ub2: integer;
  NumPixels: integer): TMatrix; overload;
function LocalMean(const InMatrix: TIntMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
function LocalMean(const InMatrix: T3DMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix; overload;
function LocalMean(const InMatrix: T3DIntMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix; overload;

function ConvolutionMatrix(const InMatrix: TMatrix; const ConvMatrix: arr2;
  const Lb1, Ub1, Lb2, Ub2: integer): TMatrix; overload;
function ConvolutionMatrix(const InMatrix: T3DMatrix; const ConvMatrix: arr3;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer): T3DMatrix; overload;

function GaussianBlur(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function GaussianBlur(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TIntVector; overload;
function GaussianBlur(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
function GaussianBlur(const InMatrix: T3DMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix; overload;

function BackgroundFromMinima(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function BackgroundFromMinima(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function BackgroundFromMinima(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
function BackgroundFromMinima(const InMatrix: T3DMatrix;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer; NumPixels: integer)
  : T3DMatrix; overload;

function SubstractBackground(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function SubstractBackground(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
function SubstractBackground(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
function SubstractBackground(const InMatrix: T3DMatrix;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer; NumPixels: integer)
  : T3DMatrix; overload;

implementation

uses uminmax, uoperations, math, ufusion, UTypeCasts;

function LocalMean(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector;
var
  I, M, lmax, lStart, lEnd, lNum: integer;
  A: float;
begin
  lmax := High(InVector);
  if NumPixels < 1 then
  begin
    result := Clone(InVector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    A := 0;
    lStart := EnsureRange(I - NumPixels, Lb, Ub);
    lEnd := EnsureRange(I + NumPixels, Lb, Ub);
    lNum := lEnd - lStart + 1;
    for M := lStart to lEnd do
      A := A + InVector[M];
    result[I] := A / lNum; // Calculate local mean
  end;
end;

function LocalMean(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector;
var
  A, I, M, lmax, lStart, lEnd, lNum: integer;
begin
  lmax := High(InVector);
  if NumPixels < 1 then
  begin
    InttoFloat(InVector, result, Ub);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    A := 0;
    lStart := EnsureRange(I - NumPixels, Lb, Ub);
    lEnd := EnsureRange(I + NumPixels, Lb, Ub);
    lNum := lEnd - lStart + 1;
    for M := lStart to lEnd do
      A := A + InVector[M];
    result[I] := A / lNum; // Calculate local mean
  end;
end;

function LocalMean(const InMatrix: TMatrix; const Lb1, Ub1, Lb2, Ub2: integer;
  NumPixels: integer): TMatrix;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
  A, t1: float;
begin
  lmax1 := High(InMatrix);
  lMax2 := High(InMatrix[0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := EnsureRange(I - NumPixels, Lb1, Ub1);
    lEnd1 := EnsureRange(I + NumPixels, Lb1, Ub1);
    for J := Lb2 to Ub2 do
    begin
      A := 0;
      lStart2 := EnsureRange(J - NumPixels, Lb2, Ub2);
      lEnd2 := EnsureRange(J + NumPixels, Lb2, Ub2);
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          A := A + InMatrix[M, N];
      t1 := 1 / ((lEnd1 - lStart1 + 1) * (lEnd2 - lStart2 + 1));
      result[I, J] := A * t1; // Calculate local mean
    end;
  end;
end;

function LocalMean(const InMatrix: TIntMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
  A, t1: float;
begin
  lmax1 := High(InMatrix);
  lMax2 := High(InMatrix[0]);
  if NumPixels < 1 then
  begin
    InttoFloat(InMatrix, result, Ub1, Ub2);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := EnsureRange(I - NumPixels, Lb1, Ub1);
    lEnd1 := EnsureRange(I + NumPixels, Lb1, Ub1);
    for J := Lb2 to Ub2 do
    begin
      A := 0;
      lStart2 := EnsureRange(J - NumPixels, Lb2, Ub2);
      lEnd2 := EnsureRange(J + NumPixels, Lb2, Ub2);
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          A := A + InMatrix[M, N];
      t1 := 1 / ((lEnd1 - lStart1 + 1) * (lEnd2 - lStart2 + 1));
      result[I, J] := A * t1; // Calculate local mean
    end;
  end;
end;

function LocalMean(const InMatrix: T3DMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
  A, t1: float;
begin
  lmax1 := High(InMatrix);
  lMax2 := High(InMatrix[0]);
  lMax3 := High(InMatrix[0, 0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2, lMax3);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2, lMax3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := EnsureRange(I - NumPixels, Lb1, Ub1);
    lEnd1 := EnsureRange(I + NumPixels, Lb1, Ub1);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := EnsureRange(J - NumPixels, Lb2, Ub2);
      lEnd2 := EnsureRange(J + NumPixels, Lb2, Ub2);
      for K := Lb3 to Ub3 do
      begin
        A := 0;
        lStart3 := EnsureRange(K - NumPixels, Lb3, Ub3);
        lEnd3 := EnsureRange(K + NumPixels, Lb3, Ub3);
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              A := A + InMatrix[M, N, O];
        t1 := 1 / ((lEnd1 - lStart1 + 1) * (lEnd2 - lStart2 + 1) *
          (lEnd3 - lStart3 + 1));
        result[I, J, K] := A * t1; // Calculate local mean
      end;
    end;
  end;
end;

function LocalMean(const InMatrix: T3DIntMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
  A, t1: float;
begin
  lmax1 := High(InMatrix);
  lMax2 := High(InMatrix[0]);
  lMax3 := High(InMatrix[0, 0]);
  if NumPixels < 1 then
  begin
    InttoFloat(InMatrix, result, Ub1, Ub2, Ub3);
    exit;
  end;
  DimMatrix(result, Ub1, Ub2, Ub3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := EnsureRange(I - NumPixels, Lb1, Ub1);
    lEnd1 := EnsureRange(I + NumPixels, Lb1, Ub1);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := EnsureRange(J - NumPixels, Lb2, Ub2);
      lEnd2 := EnsureRange(J + NumPixels, Lb2, Ub2);
      for K := Lb3 to Ub3 do
      begin
        A := 0;
        lStart3 := EnsureRange(K - NumPixels, Lb3, Ub3);
        lEnd3 := EnsureRange(K + NumPixels, Lb3, Ub3);
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              A := A + InMatrix[M, N, O];
        t1 := 1 / ((lEnd1 - lStart1 + 1) * (lEnd2 - lStart2 + 1) *
          (lEnd3 - lStart3 + 1));
        result[I, J, K] := A * t1; // Calculate local mean
      end;
    end;
  end;
end;

function ConvolutionMatrix(const InMatrix: TMatrix; const ConvMatrix: arr2;
  const Lb1, Ub1, Lb2, Ub2: integer): TMatrix;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
begin
  lmax1 := High(InMatrix);
  lMax2 := High(InMatrix[0]);
  DimMatrix(result, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - 1);
    lEnd1 := min(lmax1, I + 1);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - 1);
      lEnd2 := min(lMax2, J + 1);
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          result[I, J] := result[I, J] + InMatrix[M, N] * ConvMatrix
            [max(1, min(3, M - I + 2)), max(1, min(3, N - J + 2))];
    end;
  end;
end;

function ConvolutionMatrix(const InMatrix: T3DMatrix; const ConvMatrix: arr3;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer): T3DMatrix;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
begin
  lmax1 := High(InMatrix);
  lMax2 := High(InMatrix[0]);
  lMax3 := High(InMatrix[0, 0]);
  DimMatrix(result, lmax1, lMax2, lMax3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - 1);
    lEnd1 := min(lmax1, I + 1);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - 1);
      lEnd2 := min(lMax2, J + 1);
      for K := Lb3 to Ub3 do
      begin
        lStart3 := max(1, K - 1);
        lEnd3 := min(lMax3, K + 1);
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              result[I, J, K] := result[I, J, K] + InMatrix[M, N, O] *
                ConvMatrix[max(1, min(3, M - I + 2)), max(1, min(3, N - J + 2)),
                max(1, min(3, O - K + 2))];
      end;
    end;
  end;
end;

function GaussianBlur(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector;
var
  I, M, lmax, lStart, lEnd: integer;
  A, t1: float;
begin
  lmax := high(InVector);
  if NumPixels < 1 then
  begin
    result := Clone(InVector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    A := 0;
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    t1 := 1 / (lEnd - lStart + 1);
    for M := lStart to lEnd do
      A := A + exp(-sqr((M - I) * t1));
    if (A <> 0) then
      A := InVector[I] / A; // Calculate peak height
    for M := lStart to lEnd do
      result[M] := result[M] + A * exp(-sqr((M - I) * t1));
  end;
end;

function GaussianBlur(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TIntVector;
var
  I, M, lmax, lStart, lEnd: integer;
  A, t1: float;
begin
  lmax := high(InVector);
  if NumPixels < 1 then
  begin
    result := Clone(InVector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    A := 0;
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    t1 := 1 / (lEnd - lStart + 1);
    for M := lStart to lEnd do
      A := A + exp(-sqr((M - I) * t1));
    if (A <> 0) then
      A := InVector[I] / A; // Calculate peak height
    for M := lStart to lEnd do
      result[M] := result[M] + round(A * exp(-sqr((M - I) * t1)));
  end;
end;

function GaussianBlur(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
  A, t1, t2: float;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    t1 := 1 / (lEnd1 - lStart1 + 1);
    for J := Lb2 to Ub2 do
    begin
      A := 0;
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      t2 := 1 / (lEnd2 - lStart2 + 1);
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          A := A + exp(-((sqr(M - I) * t1) + (sqr(N - J) * t2)));
      if (A <> 0) then
        A := InMatrix[I, J] / A; // Calculate peak height
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          result[M, N] := result[M, N] + A *
            exp(-(t1 * sqr(M - I) + t2 * sqr(N - J)));
    end;
  end;
end;

function GaussianBlur(const InMatrix: T3DMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
  A, t1, t2, t3: float;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  lMax3 := high(InMatrix[0, 0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2, lMax3);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2, lMax3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    t1 := 1 / (lEnd1 - lStart1 + 1);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      t2 := 1 / (lEnd2 - lStart2 + 1);
      for K := Lb3 to Ub3 do
      begin
        A := 0;
        lStart3 := max(1, K - NumPixels);
        lEnd3 := min(lMax3, K + NumPixels);
        t3 := 1 / (lEnd3 - lStart3 + 1);
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              A := A + exp
                (-((t1 * sqr(M - I) + t2 * sqr(N - J) + t3 * sqr(O - K))));
        if (A <> 0) then
          A := InMatrix[I, J, K] / A; // Calculate peak height
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              result[M, N, O] := result[M, N, O] + A *
                exp(-((t1 * sqr(M - I) + t2 * sqr(N - J) + t3 * sqr(O - K))));
      end;
    end;
  end;
end;

function LocalMax(const Vector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  I, M, lmax, lStart, lEnd: integer;
  A: float;
begin
  lmax := high(Vector);
  if NumPixels < 1 then
  begin
    result := Clone(Vector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    A := Vector[lStart];
    for M := lStart + 1 to lEnd do
      if Vector[M] > A then
        A := Vector[M];
    result[I] := A; // Calculate local max
  end;
end;

function LocalMax(const Vector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TIntVector; overload;
var
  A, I, M, lmax, lStart, lEnd: integer;
begin
  lmax := high(Vector);
  if NumPixels < 1 then
  begin
    result := Clone(Vector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    A := Vector[lStart];
    for M := lStart + 1 to lEnd do
      if Vector[M] > A then
        A := Vector[M];
    result[I] := A; // Calculate local max
  end;
end;

function LocalMin(const Vector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  I, M, lmax, lStart, lEnd: integer;
  A: float;
begin
  lmax := high(Vector);
  if NumPixels < 1 then
  begin
    result := Clone(Vector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    A := Vector[lStart];
    for M := lStart + 1 to lEnd do
      if Vector[M] < A then
        A := Vector[M];
    result[I] := A; // Calculate local max
  end;
end;

function LocalMin(const Vector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TIntVector; overload;
var
  A, I, M, lmax, lStart, lEnd: integer;
begin
  lmax := high(Vector);
  if NumPixels < 1 then
  begin
    result := Clone(Vector, lmax);
    exit;
  end;
  DimVector(result, lmax);
  for I := Lb to Ub do
  begin
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    A := Vector[lStart];
    for M := lStart + 1 to lEnd do
      if Vector[M] < A then
        A := Vector[M];
    result[I] := A; // Calculate local max
  end;
end;

function LocalMax(const InMatrix: TMatrix; const Lb1, Ub1, Lb2, Ub2: integer;
  NumPixels: integer): TMatrix; overload;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
  A: float;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      A := InMatrix[lStart1, lStart2];
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          if InMatrix[M, N] > A then
            A := InMatrix[M, N];
      result[I, J] := A; // Calculate local max
    end;
  end;
end;

function LocalMax(const InMatrix: T3DMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix; overload;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
  A, t1: float;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  lMax3 := high(InMatrix[0, 0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2, lMax3);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2, lMax3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      for K := Lb3 to Ub3 do
      begin
        lStart3 := max(1, K - NumPixels);
        lEnd3 := min(lMax3, K + NumPixels);
        A := InMatrix[lStart1, lStart2, lStart3];
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              if InMatrix[M, N, O] > A then
                A := InMatrix[M, N, O];
        result[I, J, K] := A; // Calculate local max
      end;
    end;
  end;
end;

function LocalMin(const InMatrix: TMatrix; const Lb1, Ub1, Lb2, Ub2: integer;
  NumPixels: integer): TMatrix; overload;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
  A: float;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      A := InMatrix[lStart1, lStart2];
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
          if InMatrix[M, N] < A then
            A := InMatrix[M, N];
      result[I, J] := A; // Calculate local min
    end;
  end;
end;

function LocalMin(const InMatrix: T3DMatrix; const Lb1, Ub1, Lb2, Ub2, Lb3,
  Ub3: integer; NumPixels: integer): T3DMatrix; overload;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
  A, t1: float;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  lMax3 := high(InMatrix[0, 0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2, lMax3);
    exit;
  end;
  DimMatrix(result, lmax1, lMax2, lMax3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      for K := Lb3 to Ub3 do
      begin
        lStart3 := max(1, K - NumPixels);
        lEnd3 := min(lMax3, K + NumPixels);
        A := InMatrix[lStart1, lStart2, lStart3];
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
              if InMatrix[M, N, O] < A then
                A := InMatrix[M, N, O];
        result[I, J, K] := A; // Calculate local max
      end;
    end;
  end;
end;

function BackgroundFromMinima(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  temp1, temp2: TVector;
begin
  temp1 := LocalMin(InVector, Lb, Ub, NumPixels);
  temp2 := LocalMax(temp1, Lb, Ub, NumPixels);
  result := LocalMean(temp2, Lb, Ub, NumPixels);
  DelVector(temp1);
  DelVector(temp2);
end;

function BackgroundFromMinima(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  temp1, temp2: TIntVector;
begin
  temp1 := LocalMin(InVector, Lb, Ub, NumPixels);
  temp2 := LocalMax(temp1, Lb, Ub, NumPixels);
  result := LocalMean(temp2, Lb, Ub, NumPixels);
  DelVector(temp1);
  DelVector(temp2);
end;

function BackgroundFromMinima(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
var
  temp1, temp2: TMatrix;
begin
  temp1 := LocalMin(InMatrix, Lb1, Ub1, Lb2, Ub2, NumPixels);
  temp2 := LocalMax(temp1, Lb1, Ub1, Lb2, Ub2, NumPixels);
  result := LocalMean(temp2, Lb1, Ub1, Lb2, Ub2, NumPixels);
  DelMatrix(temp1);
  DelMatrix(temp2);
end;

function BackgroundFromMinima(const InMatrix: T3DMatrix;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer; NumPixels: integer)
  : T3DMatrix; overload;
var
  temp1, temp2: T3DMatrix;
begin
  temp1 := LocalMin(InMatrix, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, NumPixels);
  temp2 := LocalMax(temp1, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, NumPixels);
  result := LocalMean(temp2, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, NumPixels);
  DelMatrix(temp1);
  DelMatrix(temp2);
end;

function LocalThresshold(const Vector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  I, M, lmax, lStart, lEnd: integer;
  A, B: float;
  diff: TVector;
begin
  lmax := High(Vector);
  if NumPixels < 1 then
  begin
    result := Clone(Vector, lmax);
    exit;
  end;
  DimVector(diff, lmax);
  for I := Lb to Ub do
  begin
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    A := Vector[lStart];
    B := A;
    for M := lStart + 1 to lEnd do
    begin
      if Vector[M] < A then
        A := Vector[M];
      if Vector[M] > B then
        B := Vector[M];
    end;
    diff[I] := B - A; // Calculate local diff
  end;
  result := LocalMean(diff, Lb, Ub, NumPixels); // smooth
  DelVector(diff);
end;

function LocalThresshold(const Vector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  A, B, I, M, lmax, lStart, lEnd: integer;
  diff: TIntVector;
begin
  lmax := High(Vector);
  if NumPixels < 1 then
  begin
    InttoFloat(Vector, result, Ub);
    exit;
  end;
  DimVector(diff, lmax);
  for I := Lb to Ub do
  begin
    lStart := max(1, I - NumPixels);
    lEnd := min(lmax, I + NumPixels);
    A := Vector[lStart];
    B := A;
    for M := lStart + 1 to lEnd do
    begin
      if Vector[M] < A then
        A := Vector[M];
      if Vector[M] > B then
        B := Vector[M];
    end;
    diff[I] := B - A; // Calculate local diff
  end;
  result := LocalMean(diff, Lb, Ub, NumPixels);
  DelVector(diff);
end;

function LocalThresshold(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
var
  I, J, M, N, lmax1, lMax2, lStart1, lStart2, lEnd1, lEnd2: integer;
  A, B: float;
  diff: TMatrix;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2);
    exit;
  end;
  DimMatrix(diff, lmax1, lMax2);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      A := InMatrix[lStart1, lStart2];
      B := A;
      for M := lStart1 to lEnd1 do
        for N := lStart2 to lEnd2 do
        begin
          if InMatrix[M, N] < A then
            A := InMatrix[M, N];
          if InMatrix[M, N] > B then
            B := InMatrix[M, N];
        end;
      diff[I, J] := (B - A); // Calculate local thresshold
    end;
  end;
  result := LocalMean(diff, Lb1, Ub1, Lb2, Ub2, NumPixels);
  DelMatrix(diff);
end;

function LocalThresshold(const InMatrix: T3DMatrix;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer; NumPixels: integer)
  : T3DMatrix; overload;
var
  I, J, K, M, N, O, lmax1, lMax2, lMax3, lStart1, lStart2, lStart3, lEnd1,
    lEnd2, lEnd3: integer;
  A, B, t1: float;
  diff: T3DMatrix;
begin
  lmax1 := high(InMatrix);
  lMax2 := high(InMatrix[0]);
  lMax3 := high(InMatrix[0, 0]);
  if NumPixels < 1 then
  begin
    result := Clone(InMatrix, lmax1, lMax2, lMax3);
    exit;
  end;
  DimMatrix(diff, lmax1, lMax2, lMax3);
  for I := Lb1 to Ub1 do
  begin
    lStart1 := max(1, I - NumPixels);
    lEnd1 := min(lmax1, I + NumPixels);
    for J := Lb2 to Ub2 do
    begin
      lStart2 := max(1, J - NumPixels);
      lEnd2 := min(lMax2, J + NumPixels);
      for K := Lb3 to Ub3 do
      begin
        lStart3 := max(1, K - NumPixels);
        lEnd3 := min(lMax3, K + NumPixels);
        A := InMatrix[lStart1, lStart2, lStart3];
        B := A;
        for M := lStart1 to lEnd1 do
          for N := lStart2 to lEnd2 do
            for O := lStart3 to lEnd3 do
            begin
              if InMatrix[M, N, O] < A then
                A := InMatrix[M, N, O];
              if InMatrix[M, N, O] > B then
                B := InMatrix[M, N, O];
            end;
        diff[I, J, K] := B - A; // Calculate local thresshold
      end;
    end;
  end;
  result := LocalMean(diff, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, NumPixels);
  DelMatrix(diff);
end;

function SubstractBackground(const InVector: TVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  minimum, maximum: float;
  temp: TVector;
  I: integer;
begin
  MinMax(InVector, Lb, Ub, minimum, maximum);
  temp := LocalThresshold(InVector, Lb, Ub, NumPixels);
  // temp := BackgroundFromMinima(InVector, Lb, Ub, NumPixels);
  result := fusiona(InVector, temp, Ub, TFTsum, TFPfwt97);
  for I := Lb to Ub do
    result[I] := result[I] - temp[I];
  DelVector(temp);
end;

function SubstractBackground(const InVector: TIntVector; const Lb, Ub: integer;
  NumPixels: integer): TVector; overload;
var
  minimum, maximum: integer;
  temp: TVector;
  I: integer;
begin
  MinMax(InVector, Lb, Ub, minimum, maximum);
  temp := LocalThresshold(InVector, Lb, Ub, NumPixels);
  // temp := BackgroundFromMinima(InVector, Lb, Ub, NumPixels);
  DimVector(result, Ub);
  for I := Lb to Ub do
    result[I] := max(InVector[I] - temp[I], minimum);
  DelVector(temp);
end;

function SubstractBackground(const InMatrix: TMatrix;
  const Lb1, Ub1, Lb2, Ub2: integer; NumPixels: integer): TMatrix; overload;
var
  minimum, maximum: float;
  temp: TMatrix;
  I, J: integer;
begin
  MinMax(InMatrix, Lb1, Ub1, Lb2, Ub2, minimum, maximum);
  temp := LocalThresshold(InMatrix, Lb1, Ub1, Lb2, Ub2, NumPixels);
  // temp := BackgroundFromMinima(InMatrix, Lb1, Ub1, Lb2, Ub2, NumPixels);
  result := ImageFusion(InMatrix, temp, Ub1, Ub2, TFTsum);
  for I := Lb1 to Ub1 do
    for J := Lb2 to Ub2 do
      result[I, J] := result[I, J] - temp[I, J];
  DelMatrix(temp);
end;

function SubstractBackground(const InMatrix: T3DMatrix;
  const Lb1, Ub1, Lb2, Ub2, Lb3, Ub3: integer; NumPixels: integer)
  : T3DMatrix; overload;
var
  minimum, maximum: float;
  temp: T3DMatrix;
  I, J, K: integer;
begin
  MinMax(InMatrix, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, minimum, maximum);
  temp := LocalThresshold(InMatrix, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, NumPixels);
  // temp := BackgroundFromMinima(InMatrix, Lb1, Ub1, Lb2, Ub2, Lb3, Ub3, NumPixels);
  SetLength(result, Ub1);
  for I := Lb1 to Ub1 do
  begin
    result[I] := ImageFusion(InMatrix[I], temp[I], Ub2, Ub3, TFTsum);
    for J := Lb2 to Ub2 do
      for K := Lb3 to Ub3 do
        result[I, J, K] := result[I, J, K] - temp[I, J, K];
  end;
  DelMatrix(temp);
end;

end.
