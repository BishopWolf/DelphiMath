unit uImgProc;

{ Unit uImgProc : Image processing Unit

  Created by : Alex Vergara Gil

  Contains the routines for handling and process images

  Smooth (1D, 2D & 3D) : over vectors and matrixes
  the smooth is made by averaging values surrounding each value.
  if the value is near the edge then it is taken the edge value as time as needed

  LeeFilt (1D, 2D & 3D) : Performs the Lee filter derived from
  Jong-Sen Lee, Optical Engineering 25(5), 636-643 (May 1986)
  technique to smooths additive image noise by generating statistics in
  a local neighborhood and comparing them to the expected values..
  if N>7 you should use the exact LeeFilt otherwise it's recommended
  to use the QLeeFilt routines

}

interface

uses utypes, uConstants;

function Smooth(A: TVector; Ub1: integer; BOX: integer = 5): TVector; overload;
function Smooth(A: TMatrix; Ub1, Ub2: integer; BOX: integer = 5)
  : TMatrix; overload;
function Smooth(A: T3DMatrix; Ub1, Ub2, Ub3: integer; BOX: integer = 5)
  : T3DMatrix; overload;
function Smooth(A: TIntVector; Ub1: integer; BOX: integer = 5)
  : TVector; overload;
function Smooth(A: TIntMatrix; Ub1, Ub2: integer; BOX: integer = 5)
  : TMatrix; overload;
function Smooth(A: T3DIntMatrix; Ub1, Ub2, Ub3: integer; BOX: integer = 5)
  : T3DMatrix; overload;

function LeeFilt(A: TVector; Ub1: integer; BOX: integer; Sigma: float)
  : TVector; overload;
function LeeFilt(A: TMatrix; Ub1, Ub2: integer; BOX: integer; Sigma: float)
  : TMatrix; overload;
function LeeFilt(A: T3DMatrix; Ub1, Ub2, Ub3: integer; BOX: integer;
  Sigma: float): T3DMatrix; overload;
function QLeeFilt(A: TVector; Ub1: integer; BOX: integer; Sigma: float)
  : TVector; overload;
function QLeeFilt(A: TMatrix; Ub1, Ub2: integer; BOX: integer; Sigma: float)
  : TMatrix; overload;
function QLeeFilt(A: T3DMatrix; Ub1, Ub2, Ub3: integer; BOX: integer;
  Sigma: float): T3DMatrix; overload;

function Hough(A: TMatrix; Ub1, Ub2: integer; Xdim, Ydim: float;
  out rho, theeta: TVector; out NRho, Ntheeta: integer): TMatrix;
function HoughBackProjection(T: TMatrix; rho, theeta: TVector;
  Ntheeta, NRho: integer; out Nx, Ny: integer; Xdim: float = 1; Ydim: float = 1;
  traspond: boolean = false): TMatrix;
function RebuildScene(Transform: T3DMatrix; Ub1, Ub2, Ub3: integer;
  rho, theeta: TVector; out Nx, Ny, Nz: integer; Xdim: float = 1;
  Ydim: float = 1): T3DMatrix;

implementation

uses uoperations, uminmax, Math, utrigo, uinterpolation;

{ Smooth images } // BOX must be an odd number

function Smooth(A: TVector; Ub1, BOX: integer): TVector;
var
  i, j, k, x: integer;
  cont: float;
begin
  DimVector(Result, Ub1);
  k := BOX div 2;
  for i := 1 to Ub1 do
  begin
    cont := 0;
    for j := -k to k do
    begin
      x := Math.EnsureRange(i + j, 1, Ub1);
      // if it is near the edge take the edge value as time as needed
      cont := cont + A[x];
    end;
    Result[i] := cont / BOX;
  end;
end;

function Smooth(A: TMatrix; Ub1, Ub2, BOX: integer): TMatrix;
var
  i, j, k, l, m, x, y, Box2: integer;
  cont: float;
begin
  DimMatrix(Result, Ub1, Ub2);
  m := BOX div 2;
  Box2 := (BOX * BOX);
  for i := 1 to Ub1 do
  begin
    for j := 1 to Ub2 do
    begin
      cont := 0;
      for k := -m to m do
      begin
        for l := -m to m do
        begin
          x := Math.EnsureRange(i + k, 1, Ub1);
          y := Math.EnsureRange(j + l, 1, Ub2);
          cont := cont + A[x, y];
        end;
      end;
      Result[i, j] := (cont / Box2);
    end;
  end;
end;

function Smooth(A: T3DMatrix; Ub1, Ub2, Ub3, BOX: integer): T3DMatrix;
var
  i, j, k, l, m, n, o, x, y, z, BOX3: integer;
  cont: float;
begin
  DimMatrix(Result, Ub1, Ub2, Ub3);
  o := BOX div 2;
  BOX3 := (BOX * BOX * BOX);
  for i := 1 to Ub1 do
  begin
    for j := 1 to Ub2 do
    begin
      for k := 1 to Ub3 do
      begin
        cont := 0;
        for l := -o to o do
        begin
          for m := -o to o do
          begin
            for n := -o to o do
            begin
              x := Math.EnsureRange(i + l, 1, Ub1);
              y := Math.EnsureRange(j + m, 1, Ub2);
              z := Math.EnsureRange(k + n, 1, Ub3);
              cont := cont + A[x, y, z];
            end;
          end;
        end;
        Result[i, j, k] := (cont / BOX3);
      end;
    end;
  end;
end;

function Smooth(A: TIntVector; Ub1, BOX: integer): TVector;
var
  i, j, k, x: integer;
  cont: float;
begin
  DimVector(Result, Ub1);
  k := BOX div 2;
  for i := 1 to Ub1 do
  begin
    cont := 0;
    for j := -k to k do
    begin
      x := Math.EnsureRange(i + j, 1, Ub1);
      cont := cont + A[x];
    end;
    Result[i] := cont / BOX;
  end;
end;

function Smooth(A: TIntMatrix; Ub1, Ub2, BOX: integer): TMatrix;
var
  i, j, k, l, m, x, y, Box2: integer;
  cont: float;
begin
  DimMatrix(Result, Ub1, Ub2);
  m := BOX div 2;
  Box2 := (BOX * BOX);
  for i := 1 to Ub1 do
  begin
    for j := 1 to Ub2 do
    begin
      cont := 0;
      for k := -m to m do
      begin
        for l := -m to m do
        begin
          x := Math.EnsureRange(i + k, 1, Ub1);
          y := Math.EnsureRange(j + l, 1, Ub2);
          cont := cont + A[x, y];
        end;
      end;
      Result[i, j] := (cont / Box2);
    end;
  end;
end;

function Smooth(A: T3DIntMatrix; Ub1, Ub2, Ub3, BOX: integer): T3DMatrix;
var
  i, j, k, l, m, n, o, x, y, z, BOX3: integer;
  cont: float;
begin
  DimMatrix(Result, Ub1, Ub2, Ub3);
  o := BOX div 2;
  BOX3 := (BOX * BOX * BOX);
  for i := 1 to Ub1 do
  begin
    for j := 1 to Ub2 do
    begin
      for k := 1 to Ub3 do
      begin
        cont := 0;
        for l := -o to o do
        begin
          for m := -o to o do
          begin
            for n := -o to o do
            begin
              x := Math.EnsureRange(i + l, 1, Ub1);
              y := Math.EnsureRange(j + m, 1, Ub2);
              z := Math.EnsureRange(k + n, 1, Ub3);
              cont := cont + A[x, y, z];
            end;
          end;
        end;
        Result[i, j, k] := (cont / BOX3);
      end;
    end;
  end;
end;

function LeeFilt(A: TVector; Ub1: integer; BOX: integer; Sigma: float): TVector;
var
  i, j, delta: integer;
  mean, z: TVector;
  mean2, cont, varZ: float;
begin
  delta := BOX div 2;
  mean := Smooth(A, Ub1, BOX);
  mean2 := FVSquare(mean, Ub1);
  varZ := 0;
  for i := delta + 1 to Ub1 - delta do
  begin
    cont := 0; // Compute Variance of Z
    for j := i - delta to i + delta do
    begin
      cont := cont + sqr(A[j] - mean[i]);
    end;
    varZ := varZ + (cont / (BOX - 1)); // variance
  end;
  varZ := ((varZ + mean2) / (1 + sqr(Sigma))) - mean2;
  if varZ < 0 then
    varZ := 0;
  z := FResta(A, mean, Ub1);
  MultiplyByNumber(z, Ub1, varZ / (mean2 * sqr(Sigma) + varZ));
  Result := FSuma(mean, z, Ub1);
  DelVector(mean);
  DelVector(z);
end;

function QLeeFilt(A: TVector; Ub1: integer; BOX: integer; Sigma: float)
  : TVector;
var
  i: integer;
  mean, AA, AA2, AA2mean: TVector;
  mean2, meanAA2, varZ: float;
begin
  mean := Smooth(A, Ub1, BOX);
  mean2 := FVSquare(mean, Ub1);
  AA := FResta(A, mean, Ub1);
  DimVector(AA2, Ub1);
  for i := 1 to Ub1 do
    AA2[i] := sqr(AA[i]);
  AA2mean := Smooth(AA2, Ub1, BOX);
  meanAA2 := FVSquare(AA2mean, Ub1);
  DelVector(AA2mean);
  DelVector(AA2);
  varZ := ((meanAA2 + mean2) / (1 + sqr(Sigma))) - mean2;
  MultiplyByNumber(AA, Ub1, varZ / (mean2 * sqr(Sigma) + varZ));
  Result := FSuma(mean, AA, Ub1);
  DelVector(mean);
  DelVector(AA);
end;

function LeeFilt(A: TMatrix; Ub1, Ub2: integer; BOX: integer;
  Sigma: float): TMatrix;
var
  i, j, k, l, delta: integer;
  mean, z: TMatrix;
  mean2, cont, varZ: float;
begin
  delta := BOX div 2;
  mean := Smooth(A, Ub1, Ub2, BOX);
  mean2 := 0;
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      mean2 := mean2 + sqr(mean[i, j]);
  varZ := 0;
  for i := delta + 1 to Ub1 - delta do
    for j := delta + 1 to Ub2 - delta do
    begin
      cont := 0; // Compute Variance of Z
      for k := i - delta to i + delta do
        for l := j - delta to j + delta do
        begin
          cont := cont + sqr(A[k, l] - mean[i, j]);
        end;
      varZ := varZ + (cont / (BOX - 1)); // variance
    end;
  varZ := ((varZ + mean2) / (1 + sqr(Sigma))) - mean2;
  if varZ < 0 then
    varZ := 0;
  z := FResta(A, mean, Ub1, Ub2);
  MultiplyByNumber(z, Ub1, Ub2, varZ / (mean2 * sqr(Sigma) + varZ));
  Result := FSuma(mean, z, Ub1, Ub2);
  DelMatrix(mean);
  DelMatrix(z);
end;

function QLeeFilt(A: TMatrix; Ub1, Ub2: integer; BOX: integer;
  Sigma: float): TMatrix;
var
  i, j: integer;
  mean, AA, AA2, AA2mean: TMatrix;
  mean2, meanAA2, varZ: float;
begin
  mean := Smooth(A, Ub1, Ub2, BOX);
  mean2 := 0;
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      mean2 := mean2 + sqr(mean[i, j]);
  AA := FResta(A, mean, Ub1, Ub2);
  DimMatrix(AA2, Ub1, Ub2);
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      AA2[i, j] := sqr(AA[i, j]);
  AA2mean := Smooth(AA2, Ub1, Ub2, BOX);
  meanAA2 := 0;
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      meanAA2 := meanAA2 + sqr(AA2[i, j]);
  DelMatrix(AA2mean);
  DelMatrix(AA2);
  varZ := ((meanAA2 + mean2) / (1 + sqr(Sigma))) - mean2;
  MultiplyByNumber(AA, Ub1, Ub2, varZ / (mean2 * sqr(Sigma) + varZ));
  Result := FSuma(mean, AA, Ub1, Ub2);
  DelMatrix(mean);
  DelMatrix(AA);
end;

function LeeFilt(A: T3DMatrix; Ub1, Ub2, Ub3: integer; BOX: integer;
  Sigma: float): T3DMatrix;
var
  i, j, k, l, m, n, delta: integer;
  mean, z: T3DMatrix;
  mean2, cont, varZ: float;
begin
  delta := BOX div 2;
  mean := Smooth(A, Ub1, Ub2, Ub3, BOX);
  mean2 := 0;
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      for k := 1 to Ub3 do
        mean2 := mean2 + sqr(mean[i, j, k]);
  varZ := 0;
  for i := delta + 1 to Ub1 - delta do
    for j := delta + 1 to Ub2 - delta do
      for k := delta + 1 to Ub3 - delta do
      begin
        cont := 0; // Compute Variance of Z
        for l := i - delta to i + delta do
          for m := j - delta to j + delta do
            for n := k - delta to k + delta do
            begin
              cont := cont + sqr(A[l, m, n] - mean[i, j, k]);
            end;
        varZ := varZ + (cont / (BOX - 1)); // variance
      end;
  varZ := ((varZ + mean2) / (1 + sqr(Sigma))) - mean2;
  if varZ < 0 then
    varZ := 0;
  z := FResta(A, mean, Ub1, Ub2, Ub3);
  MultiplyByNumber(z, Ub1, Ub2, Ub3, varZ / (mean2 * sqr(Sigma) + varZ));
  Result := FSuma(mean, z, Ub1, Ub2, Ub3);
  DelMatrix(mean);
  DelMatrix(z);
end;

function QLeeFilt(A: T3DMatrix; Ub1, Ub2, Ub3: integer; BOX: integer;
  Sigma: float): T3DMatrix;
var
  i, j, k: integer;
  mean, AA, AA2, AA2mean: T3DMatrix;
  mean2, meanAA2, varZ: float;
begin
  mean := Smooth(A, Ub1, Ub2, Ub3, BOX);
  mean2 := 0;
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      for k := 1 to Ub3 do
        mean2 := mean2 + sqr(mean[i, j, k]);
  AA := FResta(A, mean, Ub1, Ub2, Ub3);
  DimMatrix(AA2, Ub1, Ub2, Ub3);
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      for k := 1 to Ub3 do
        AA2[i, j, k] := sqr(AA[i, j, k]);
  AA2mean := Smooth(AA2, Ub1, Ub2, Ub3, BOX);
  meanAA2 := 0;
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      for k := 1 to Ub3 do
        meanAA2 := meanAA2 + sqr(AA2[i, j, k]);
  DelMatrix(AA2mean);
  DelMatrix(AA2);
  varZ := ((meanAA2 + mean2) / (1 + sqr(Sigma))) - mean2;
  MultiplyByNumber(AA, Ub1, Ub2, Ub3, varZ / (mean2 * sqr(Sigma) + varZ));
  Result := FSuma(mean, AA, Ub1, Ub2, Ub3);
  DelMatrix(mean);
  DelMatrix(AA);
end;

function Hough(A: TMatrix; Ub1, Ub2: integer; Xdim, Ydim: float;
  out rho, theeta: TVector; out NRho, Ntheeta: integer): TMatrix;
var
  drho: float;
  i, j, m, n: integer;
  rhoprime: float;
  function delta(A, b: float): integer;
  begin
    if A = b then
      Result := 1
    else
      Result := 0;
  end;

begin
  drho := Pythag(Xdim, Ydim) / Sqrt2; // [(DX^2+ DY^2)/2]^1/2
  NRho := 2 * Ceil(Pythag(Ub1 * Xdim / 2, Ub2 * Ydim / 2) / drho) + 1;
  // 2 CEIL([MAX(X^2 + Y^2)]^1/2 / DRHO) + 1
  Ntheeta := Ceil(Pi * Pythag(Ub1 * Xdim / 2, Ub2 * Ydim / 2) / drho);
  // CEIL(p [MAX(X^2  + Y^2)]^1/2 / DRHO)
  DimMatrix(Result, Ntheeta, NRho);
  DimVector(rho, NRho);
  DimVector(theeta, Ntheeta);
  for i := 1 to Ntheeta do
  begin
    theeta[i] := linealinterpolation(1, 0, Ntheeta, Pi, i);
    for j := 1 to NRho do
    begin
      rho[j] := linealinterpolation(1, -0.5 * (NRho - 1), NRho,
        0.5 * (NRho - 1), j);
      for m := 1 to Ub1 do
        for n := 1 to Ub2 do
        begin
          rhoprime := ((m - 1) * Xdim) * cos(theeta[i]) + ((n - 1) * Ydim) *
            sin(theeta[i]);
          Result[i, j] := Result[i, j] +
            (A[m, n] * delta(round(rho[j]), round(rhoprime)));
        end;
    end;
  end;
end;

function HoughBackProjection(T: TMatrix; rho, theeta: TVector;
  Ntheeta, NRho: integer; out Nx, Ny: integer; Xdim, Ydim: float;
  traspond: boolean): TMatrix;
var
  i, j, m, n: integer;
  A, b, xmin, ymin, prime: float;
  function delta(A, b: float): integer;
  begin
    if A = b then
      Result := 1
    else
      Result := 0;
  end;

begin
  Nx := Floor((2 * rho[NRho] / Pythag(Xdim, Ydim)) + 1);
  // FLOOR(2 MAX(|RHO|)(DX^2 + DY^2)^-1/2 + 1)
  Ny := Nx; // same equation
  DimMatrix(Result, Nx, Ny);
  xmin := -Xdim * (Nx - 1) / 2;
  ymin := -Ydim * (Ny - 1) / 2;
  for i := 1 to Ntheeta do
  begin
    if (sin(theeta[i]) > Sqrt2 / 2) then
    begin
      A := -(Xdim * cos(theeta[i])) / (Ydim * sin(theeta[i]));
      for j := 1 to NRho do
      begin
        b := (rho[j] - xmin * cos(theeta[i]) - ymin * sin(theeta[i])) /
          (Ydim * sin(theeta[i]));
        for m := 1 to Nx do
          for n := 1 to Ny do
          begin
            prime := A * m + b;
            if traspond then
              Result[m, n] := Result[m, n] + (T[j, i] * delta(n, round(prime)))
            else
              Result[m, n] := Result[m, n] + (T[i, j] * delta(n, round(prime)));
          end;
      end;
    end
    else
    begin
      A := -(Ydim * sin(theeta[i])) / (Xdim * cos(theeta[i]));
      for j := 1 to NRho do
      begin
        b := (rho[j] - xmin * cos(theeta[i]) - ymin * sin(theeta[i])) /
          (Xdim * cos(theeta[i]));
        for m := 1 to Nx do
          for n := 1 to Ny do
          begin
            prime := A * n + b;
            if traspond then
              Result[m, n] := Result[m, n] + (T[j, i] * delta(m, round(prime)))
            else
              Result[m, n] := Result[m, n] + (T[i, j] * delta(m, round(prime)));
          end;
      end;
    end;
  end;
end;

function RebuildScene(Transform: T3DMatrix; Ub1, Ub2, Ub3: integer;
  rho, theeta: TVector; out Nx, Ny, Nz: integer; Xdim: float = 1;
  Ydim: float = 1): T3DMatrix;
var
  i: integer;
  temp: TMatrix;
begin
  Nz := Ub1;
  temp := HoughBackProjection(Transform[1], rho, theeta, Ub3, Ub2, Nx, Ny, Xdim,
    Ydim, true); // first get the missing sizes
  DimMatrix(Result, Nx, Ny, Nz); // dimension result now
  Result[1] := temp; // use calculated values
  for i := 2 to Nz do
    Result[i] := HoughBackProjection(Transform[i], rho, theeta, Ub3, Ub2, Nx,
      Ny, Xdim, Ydim, true);
end;

end.
