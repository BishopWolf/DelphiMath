unit ufwt97;

{ *********************************************
  2011 - Alex Vergara Gil - alex@cphr.edu.cu
  Translated from original C++ code made by
  2006 - Gregoire Pau - gregoire.pau@ebi.ac.uk
  ********************************************* }

interface

uses
  utypes;

procedure dwt97(var X: TVector; n: integer; isign: integer);
procedure fwt97(var X: TVector; n: integer);
procedure fwt97two(var X, Y: TVector; n: integer);
procedure iwt97(var X: TVector; n: integer);

implementation

uses uConstants;

procedure fwt97(var X: TVector; n: integer);

(* *
  *  fwt97 - Forward biorthogonal 9/7 wavelet transform (lifting implementation)
  *
  *  x is an input signal, which will be replaced by its output transform.
  *  n is the length of the signal, and must be a power of 2.
  *
  *  The first half part of the output signal contains the approximation coefficients.
  *  The second half part contains the detail coefficients (aka. the wavelets coefficients).
  *
  *  See also iwt97.
*)

var
  tempbank: TVector;
  a: float;
  i: integer;
begin
  // Predict 1
  a := -1.586134342;
  i := 2;
  while i < n - 1 do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[n] := X[n] + 2 * a * X[n - 1];

  // Update 1
  a := -0.05298011854;
  i := 3;
  while i < n do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[1] := X[1] + 2 * a * X[2];

  // Predict 2
  a := 0.8829110762;
  i := 2;
  while i < n - 1 do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[n] := X[n] + 2 * a * X[n - 1];

  // Update 2
  a := 0.4435068522;
  i := 3;
  while i < n do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[1] := X[1] + 2 * a * X[2];

  // Scale
  a := 1 / 1.149604398;
  for i := 1 to n do
  begin
    if (i and $1 = 0) then // C mod 2 = C and 1
      X[i] := X[i] * a
    else
      X[i] := X[i] / a;
  end;

  // Pack
  DimVector(tempbank, n);
  for i := 1 to n do
  begin
    if (i and $1 = 1) then // even
      tempbank[(i + 1) shr 1] := X[i] // C div 2 = C shr 1
    else // odd
      tempbank[(n + i + 1) shr 1] := X[i];
  end;
  for i := 1 to n do
    X[i] := tempbank[i];
  DelVector(tempbank);
end;

procedure fwt97two(var X, Y: TVector; n: integer);

(* *
  *  fwt97 - Forward biorthogonal 9/7 wavelet transform (lifting implementation)
  *
  *  X, Y are two input signal, which will be replaced by their output transform.
  *  n is the length of the signal, and must be a power of 2.
  *
  *  The first half part of the output signal contains the approximation coefficients.
  *  The second half part contains the detail coefficients (aka. the wavelets coefficients).
  *
  *  See also iwt97.
*)

var
  tempbank: TVector;
  a: float;
  i: integer;
begin
  // Predict 1
  a := -1.586134342;
  i := 2;
  while i < n - 1 do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    Y[i] := Y[i] + a * (Y[i - 1] + Y[i + 1]);
    i := i + 2;
  end;
  X[n] := X[n] + 2 * a * X[n - 1];
  Y[n] := Y[n] + 2 * a * Y[n - 1];

  // Update 1
  a := -0.05298011854;
  i := 3;
  while i < n do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    Y[i] := Y[i] + a * (Y[i - 1] + Y[i + 1]);
    i := i + 2;
  end;
  X[1] := X[1] + 2 * a * X[2];
  Y[1] := Y[1] + 2 * a * Y[2];

  // Predict 2
  a := 0.8829110762;
  i := 2;
  while i < n - 1 do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    Y[i] := Y[i] + a * (Y[i - 1] + Y[i + 1]);
    i := i + 2;
  end;
  X[n] := X[n] + 2 * a * X[n - 1];
  Y[n] := Y[n] + 2 * a * Y[n - 1];

  // Update 2
  a := 0.4435068522;
  i := 3;
  while i < n do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    Y[i] := Y[i] + a * (Y[i - 1] + Y[i + 1]);
    i := i + 2;
  end;
  X[1] := X[1] + 2 * a * X[2];
  Y[1] := Y[1] + 2 * a * Y[2];

  // Scale
  a := 1 / 1.149604398;
  for i := 1 to n do
  begin
    if (i and $1 = 0) then
    begin
      X[i] := X[i] * a;
      Y[i] := Y[i] * a;
    end
    else
    begin
      X[i] := X[i] / a;
      Y[i] := Y[i] / a;
    end
  end;

  // Pack
  DimVector(tempbank, n shl 1);
  for i := 1 to n do
  begin
    if (i and $1 = 1) then
    begin
      tempbank[(i + 1) shr 1] := X[i];
      tempbank[(i + 1) shr 1 + n] := Y[i];
    end
    else
    begin
      tempbank[(n + i + 1) shr 1] := X[i];
      tempbank[(n + i + 1) shr 1 + n] := Y[i];
    end;
  end;
  for i := 1 to n do
  begin
    X[i] := tempbank[i];
    Y[i] := tempbank[i + n];
  end;
  DelVector(tempbank);
end;

procedure iwt97(var X: TVector; n: integer);

(* *
  *  iwt97 - Inverse biorthogonal 9/7 wavelet transform
  *
  *  This is the inverse of fwt97 so that iwt97(fwt97(x,n),n)=x for every signal x of length n.
  *
  *  See also fwt97.
*)

var
  tempbank: TVector;
  a: float;
  i, mid: integer;
begin
  // Unpack
  DimVector(tempbank, n);
  mid := ((n + 1) shr 1); // C div 2 = C shr 1
  for i := 1 to mid do
  begin
    tempbank[i shl 1 - 1] := X[i]; // C * 2 = C shl 1
    tempbank[i shl 1] := X[i + mid];
  end;
  for i := 1 to n do
    X[i] := tempbank[i];
  DelVector(tempbank);

  // Undo scale
  a := 1.149604398;
  for i := 1 to n do
  begin
    if (i and $1 = 0) then
      X[i] := X[i] * a
    else
      X[i] := X[i] / a;
  end;

  // Undo update 2
  a := -0.4435068522;
  i := 3;
  while i < n do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[1] := X[1] + 2 * a * X[2];

  // Undo predict 2
  a := -0.8829110762;
  i := 2;
  while i < n - 1 do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[n] := X[n] + 2 * a * X[n - 1];

  // Undo update 1
  a := 0.05298011854;
  i := 3;
  while i < n do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[1] := X[1] + 2 * a * X[2];

  // Undo predict 1
  a := 1.586134342;
  i := 2;
  while i < n - 1 do
  begin
    X[i] := X[i] + a * (X[i - 1] + X[i + 1]);
    i := i + 2;
  end;
  X[n] := X[n] + 2 * a * X[n - 1];
end;

procedure dwt97(var X: TVector; n: integer; isign: integer);
var
  Y, Z: TVector;
  i, no2: integer;
begin
  if n <= 1 then
    exit;
  if isign >= 0 then
  begin
    fwt97(X, n);
    no2 := n shr 1;
    DimVector(Y, n);
    for i := 1 to no2 do
      Y[i] := X[i];
    iwt97(Y, n);
    DimVector(Z, no2);
    for i := 1 to no2 do
      Z[i] := Y[i shl 1];
    DelVector(Y);
    dwt97(Z, no2, isign);
    for i := 1 to no2 do
      X[i] := Z[i];
    DelVector(Z);
  end
  else
  begin
    no2 := 2;
    while no2 <= n do
    begin
      DimVector(Z, no2);
      for i := 1 to no2 do
        Z[i] := X[i];
      iwt97(Z, no2);
      DimVector(Y, no2 shl 1);
      for i := 1 to no2 do
        Y[i shl 1] := Z[i];
      DelVector(Z);
      fwt97(Y, no2 shl 1);
      for i := 1 to no2 do
        X[i] := Y[i];
      DelVector(Y);
      no2 := no2 shl 1;
    end;
  end;
end;

end.
