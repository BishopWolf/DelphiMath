(* ==========================================================================

  fourier.pas  -  Don Cross <dcross@intersrv.com>

  Modified by Jean Debord <JDebord@compuserve.com> for use with TP Math.

  This is a Turbo Pascal Unit for calculating the Fast Fourier Transform
  (FFT) and the Inverse Fast Fourier Transform (IFFT).
  Visit the following URL for the latest version of this code.
  This page also has a C/C++ version, and a brief discussion of the
  theory behind the FFT algorithm.

  http://www.intersrv.com/~dcross/fft.html#pascal

  Revision history [most recent first]:

  2007 January 4 [Jean Debord]
  Modified for new TPMath version. Renamed as ufft.pas
  Now uses complex arrays.

  1998 November 27 [Jean Debord]
  Replaced the constant MAXPOWER by a variable which is initialized
  according to the value of MAX_FLT defined in TYPES.INC

  1997 March 1 [Jean Debord]
  Modifications for use with the TP Math library:
  1. Added a USES clause for the TP Math units.
  2. Set real type to Float (defined in FMATH.PAS)
  3. Added a constant MAXPOWER to define the maximum number of points.
  Modified functions IsPowerOfTwo and NumberOfBitsNeeded accordingly.
  4. Changed array types to those defined in TP Math. Modified array
  allocation, deallocation and reference accordingly.
  5. Removed compiler directives, which were no longer necessary.
  6. Modified some typographical and formatting options so that the
  code looks like the other TP Math units.
  No modification was made to the original algorithm.

  1996 December 11 [Don Cross]
  Improved documentation of the procedure CalcFrequency.
  Fixed some messed up comments in procedure IFFT.

  1996 December 6 [Don Cross]
  Made procedure 'fft_integer' more efficient when buffer size changes
  in successive calls:  the buffer is now only resized when the input
  has more samples, not a differing number of samples.
  Also changed the way 'fft_integer_cleanup' works so that it is
  more "bullet-proof".

  1996 December 4 [Don Cross]
  Adding the procedure 'CalcFrequency', which calculates the FFT
  at a specific frequency index p=0..n-1, instead of the whole
  FFT.  This is O(n^2) instead of O(n*log(n)).

  1996 November 30 [Don Cross]
  Adding a routine to allow FFT of an input array of integers.
  It is called 'fft_integer'.

  1996 November 18 [Don Cross]
  Added some comments.

  1996 November 17 [Don Cross]
  Wrote and debugged first version.

  ========================================================================== *)

unit ufft;

interface

uses
  utypes, uComplex;

(* ---------------------------------------------------------------------------
  procedure FFT

  Calculates the Fast Fourier Transform of the array of complex
  numbers represented by 'InArray' to produce the output complex
  numbers in result.
  --------------------------------------------------------------------------- *)
function FFT(InArray: TCompVector; NumSamples: LongInt; Initial: LongInt = 1)
  : TCompVector;
procedure FFT1(NumSamples: LongInt; // if you want the output on the input
  var Data: TVector;
  // and data as pvector [2*i-1] Real part [2*i] Imaginary part
  Sign: Integer); // Taken directly from Numerical Recipes
PROCEDURE four1(VAR Data: TVector; nn, isign: Integer);

(* ---------------------------------------------------------------------------
  procedure IFFT

  Calculates the Inverse Fast Fourier Transform of the array of
  complex numbers represented by 'InArray' to produce the output
  complex numbers in result.
  --------------------------------------------------------------------------- *)
function IFFT(InArray: TCompVector; NumSamples: LongInt; Initial: LongInt = 1)
  : TCompVector;

(* ---------------------------------------------------------------------------
  procedure FFT_Integer

  Same as procedure FFT, but uses Integer input arrays instead of
  double.  Make sure you call FFT_Integer_Cleanup after the last
  time you call FFT_Integer to free up memory it allocates.
  --------------------------------------------------------------------------- *)
function FFT_Integer(RealIn, ImagIn: TIntVector; NumSamples: LongInt;
  Initial: LongInt = 1): TCompVector;

(* --------------------------------------------------------------------------
  procedure FFT_Integer_Cleanup

  If you call the procedure 'FFT_Integer', you must call
  'FFT_Integer_Cleanup' after the last time you call 'FFT_Integer'
  in order to free up dynamic memory.
  -------------------------------------------------------------------------- *)
procedure FFT_Integer_Cleanup;

(* --------------------------------------------------------------------------
  procedure CalcFrequency

  This procedure calculates the complex frequency sample at a given
  index directly.  Use this instead of 'FFT' when you only need one
  or two frequency samples, not the whole spectrum.

  It is also useful for calculating the Discrete Fourier Transform (DFT)
  of a number of data which is not an integer power of 2. For example,
  you could calculate the DFT of 100 points instead of rounding up to
  128 and padding the extra 28 array slots with zeroes.
  -------------------------------------------------------------------------- *)
function CalcFrequency(InArray: TCompVector;
  NumSamples, FrequencyIndex: LongInt; Initial: LongInt = 1): Complex;

(* --------------------------------------------------------------------------
  procedure FFTTwo

  This procedure calculates the FFT of two datas simulaneously. Is of great
  use for convolving and deconvolving if the second data is the respònse
  function
  -------------------------------------------------------------------------- *)
procedure FFTTwo(Data, Respns: TVector; n: Cardinal;
  out fftData, fftRespns: TVector);
procedure RealFT(var Data: TVector; n: Cardinal; isign: Integer);
// multiply by 2/n the inverse
PROCEDURE sinft(VAR y: TVector; n: Integer); // multiply by 2/n the inverse
PROCEDURE cosft(VAR y: TVector; n, isign: Integer);
PROCEDURE cosft2(VAR y: TVector; n, isign: Integer);

implementation

uses uoperations, uminmax, uround, umachar, math, uConstants;

function IsPowerOfTwo(X: LongInt): Boolean;
var
  I, y: LongInt;
begin
  y := 2;
  for I := 1 to MaxPower do
  begin
    if X = y then
    begin
      IsPowerOfTwo := True;
      Exit;
    end;
    y := y shl 1;
  end;
  IsPowerOfTwo := False;
end;

function NumberOfBitsNeeded(PowerOfTwo: LongInt): Integer;
var
  I: Integer;
begin
  for I := 0 to MaxPower do
  begin
    if (PowerOfTwo and (1 shl I)) <> 0 then
    begin
      NumberOfBitsNeeded := I;
      Exit;
    end;
  end;
  NumberOfBitsNeeded := 0;
end;

function ReverseBits(Index, NumBits: LongInt): Integer;
var
  I, Rev: Integer;
begin
  Rev := 0;
  for I := 1 to NumBits do
  begin
    Rev := (Rev shl 1) or (Index and 1);
    Index := Index shr 1;
  end;
  ReverseBits := Rev;
end;

function FourierTransform(InArray: TCompVector; AngleNumerator: Float;
  NumSamples: LongInt; Initial: LongInt = 1): TCompVector;
var
  NumBits, I, J, K, n, BlockSize, BlockEnd: LongInt;
  Delta_angle, Delta_ar, Alpha, Beta, Tr, Ti, Ar, Ai: Float;
begin
  if not IsPowerOfTwo(NumSamples) or (NumSamples < 2) then
  begin
    SetErrCode(-1);
    Exit;
  end;

  SetErrCode(0);
  DimVector(Result, NumSamples, 0);

  NumBits := NumberOfBitsNeeded(NumSamples);
  if InArray <> Result then
    for I := Initial { 0 } to NumSamples { - 1 } do
    begin
      J := ReverseBits(I - Initial, NumBits) + Initial;
      Result[J] := CloneComplex(InArray[I]);
    end;

  BlockEnd := 1;
  BlockSize := 2;
  while BlockSize <= NumSamples do
  begin
    Delta_angle := AngleNumerator / BlockSize;
    Alpha := Sin(0.5 * Delta_angle);
    Alpha := 2.0 * Alpha * Alpha;
    Beta := Sin(Delta_angle);

    I := Initial; // }0;
    while I <= NumSamples do
    begin
      Ar := 1.0; (* cos(0) *)
      Ai := 0.0; (* sin(0) *)

      J := I;
      for n := 1 to BlockEnd do
      begin
        K := J + BlockEnd;
        Tr := Ar * Result[K].Real - Ai * Result[K].Imaginary;
        Ti := Ar * Result[K].Imaginary + Ai * Result[K].Real;
        Result[K].Real := Result[J].Real - Tr;
        Result[K].Imaginary := Result[J].Imaginary - Ti;
        Result[J].Real := Result[J].Real + Tr;
        Result[J].Imaginary := Result[J].Imaginary + Ti;
        Delta_ar := Alpha * Ar + Beta * Ai;
        Ai := Ai - (Alpha * Ai - Beta * Ar);
        Ar := Ar - Delta_ar;
        Inc(J);
      end;

      I := I + BlockSize;
    end;

    BlockEnd := BlockSize;
    BlockSize := BlockSize shl 1;
  end;
end;

function FFT(InArray: TCompVector; NumSamples, Initial: LongInt): TCompVector;
begin
  Result := FourierTransform(InArray, 2 * PI, NumSamples, Initial);
end;

procedure FFT1(NumSamples: LongInt; var Data: TVector; Sign: Integer);
var
  TV1: TVector;
  n, I: Integer;
begin
  n := round(system.Exp(ceil(system.Ln(NumSamples) / ln2) * ln2));
  if n <> NumSamples then
  begin
    DimVector(TV1, n);
    for I := 1 to NumSamples do
      TV1[I] := Data[I];
    DelVector(Data);
    Data := TV1;
  end;
  four1(Data, n, Sign);
end;

function IFFT(InArray: TCompVector; NumSamples, Initial: LongInt): TCompVector;
var
  I: Integer;
begin
  Result := FourierTransform(InArray, -2 * PI, NumSamples, Initial);
  if MathErr <> 0 then
    Exit;

  { Normalize the resulting time samples }
  for I := Initial to NumSamples do
  begin
    Result[I] := (Result[I] / NumSamples);
  end;
end;

var
  Temp: TCompVector;
  TempArraySize: Integer;

function FFT_Integer(RealIn, ImagIn: TIntVector; NumSamples, Initial: LongInt)
  : TCompVector;
var
  I: Integer;
begin
  if NumSamples > TempArraySize then
  begin
    FFT_Integer_Cleanup; { free up memory in case we already have some }
    DimVector(Temp, NumSamples, 0);
    TempArraySize := NumSamples;
  end;

  for I := Initial to NumSamples do
  begin
    Temp[I] := TComplex(RealIn[I], ImagIn[I])
  end;

  Result := FourierTransform(Temp, 2 * PI, NumSamples, Initial);
end;

procedure FFT_Integer_Cleanup;
begin
  if TempArraySize > 0 then
  begin
    DelVector(Temp);
    TempArraySize := 0;
  end;
end;

function CalcFrequency(InArray: TCompVector; NumSamples, FrequencyIndex,
  Initial: LongInt): Complex;
var
  K: Integer;
  Cos1, Cos2, Cos3: Float;
  Sin1, Sin2, Sin3: Float;
  Theta, Beta: Float;
begin
  Result := TComplex(0, 0);
  Theta := 2 * PI * FrequencyIndex / NumSamples;
  Sin1 := Sin(-2 * Theta);
  Sin2 := Sin(-Theta);
  Cos1 := Cos(-2 * Theta);
  Cos2 := Cos(-Theta);
  Beta := 2 * Cos2;
  for K := Initial to NumSamples do
  begin
    { Update trig values }
    Sin3 := Beta * Sin2 - Sin1;
    Sin1 := Sin2;
    Sin2 := Sin3;

    Cos3 := Beta * Cos2 - Cos1;
    Cos1 := Cos2;
    Cos2 := Cos3;

    Result.Real := Result.Real + InArray[K].Real * Cos3 - InArray[K]
      .Imaginary * Sin3;
    Result.Imaginary := Result.Imaginary + InArray[K].Imaginary * Cos3 +
      InArray[K].Real * Sin3;
  end;
end;

PROCEDURE four1(VAR Data: TVector; nn, isign: Integer);
VAR
  ii, jj, n, mmax, m, J, istep, I: Integer;
  wtemp, wr, wpr, wpi, wi, Theta: double;
  tempr, tempi: real;
BEGIN
  n := nn shl 1;
  J := 1;
  FOR ii := 1 TO nn DO
  BEGIN
    I := 2 * ii - 1;
    IF (J > I) THEN
    BEGIN
      tempr := Data[J];
      tempi := Data[J + 1];
      Data[J] := Data[I];
      Data[J + 1] := Data[I + 1];
      Data[I] := tempr;
      Data[I + 1] := tempi
    END;
    m := nn;
    WHILE ((m >= 2) AND (J > m)) DO
    BEGIN
      J := J - m;
      m := m shr 1;
    END;
    J := J + m
  END;
  mmax := 2;
  WHILE (n > mmax) DO
  BEGIN
    istep := 2 * mmax;
    Theta := 6.28318530717959 / (isign * mmax);
    wpr := -2.0 * sqr(Sin(0.5 * Theta));
    wpi := Sin(Theta);
    wr := 1.0;
    wi := 0.0;
    FOR ii := 1 TO (mmax DIV 2) DO
    BEGIN
      m := 2 * ii - 1;
      FOR jj := 0 TO ((n - m) DIV istep) DO
      BEGIN
        I := m + jj * istep;
        J := I + mmax;
        tempr := wr * Data[J] - wi * Data[J + 1];
        tempi := wr * Data[J + 1] + wi * Data[J];
        Data[J] := Data[I] - tempr;
        Data[J + 1] := Data[I + 1] - tempi;
        Data[I] := Data[I] + tempr;
        Data[I + 1] := Data[I + 1] + tempi
      END;
      wtemp := wr;
      wr := wr * wpr - wi * wpi + wr;
      wi := wi * wpr + wtemp * wpi + wi
    END;
    mmax := istep
  END
END;

procedure FFTTwo(Data, Respns: TVector; n: Cardinal;
  out fftData, fftRespns: TVector);
VAR
  nn3, nn2, nn, jj, J: Integer;
  rep, rem, aip, aim: real;
BEGIN
  nn := n + n;
  nn2 := nn + 2;
  nn3 := nn + 3;
  DimVector(fftData, nn);
  DimVector(fftRespns, nn);
  FOR J := 1 TO n DO
  BEGIN
    jj := J + J;
    fftData[jj - 1] := Data[J];
    fftData[jj] := Respns[J]
  END;
  four1(fftData, n, 1);
  fftRespns[1] := fftData[2];
  fftData[2] := 0.0;
  fftRespns[2] := 0.0;
  FOR jj := 1 TO (n shr 1) DO
  BEGIN
    J := 2 * jj + 1;
    rep := 0.5 * (fftData[J] + fftData[nn2 - J]);
    rem := 0.5 * (fftData[J] - fftData[nn2 - J]);
    aip := 0.5 * (fftData[J + 1] + fftData[nn3 - J]);
    aim := 0.5 * (fftData[J + 1] - fftData[nn3 - J]);
    fftData[J] := rep;
    fftData[J + 1] := aim;
    fftData[nn2 - J] := rep;
    fftData[nn3 - J] := -aim;
    fftRespns[J] := aip;
    fftRespns[J + 1] := -rem;
    fftRespns[nn2 - J] := aip;
    fftRespns[nn3 - J] := rem
  END
END;

procedure RealFT(var Data: TVector; n: Cardinal; isign: Integer);
{ Calculates the Fourier transform of a set of n real-valued data points. Replaces this data (which
  is stored in array data[1..n]) by the positive frequency half of its complex Fourier transform.
  The real-valued first and last components of the complex transform are returned as elements
  data[1] and data[2], respectively. n must be a power of 2. This routine also calculates the
  inverse transform of a complex data array if it is the transform of real data. (Result in this case
  must be multiplied by 2/n.) }
VAR
  wr, wi, wpr, wpi, wtemp, Theta: double;
  I, i1, i2, i3, i4: Integer;
  c1, c2, h1r, h1i, h2r, h2i, wrs, wis: real;
BEGIN
  Theta := 6.28318530717959 / (2.0 * n);
  c1 := 0.5;
  IF (isign = 1) THEN
  BEGIN
    c2 := -0.5;
    four1(Data, n shr 1, 1);
  END
  ELSE
  BEGIN
    c2 := 0.5;
    Theta := -Theta;
  END;
  wpr := -2.0 * sqr(Sin(0.5 * Theta));
  wpi := Sin(Theta);
  wr := 1.0 + wpr;
  wi := wpi;
  FOR I := 2 TO (n shr 2) DO
  BEGIN
    i1 := I + I - 1;
    i2 := i1 + 1;
    i3 := n + 3 - i2;
    i4 := i3 + 1;
    wrs := wr;
    wis := wi;
    h1r := c1 * (Data[i1] + Data[i3]);
    h1i := c1 * (Data[i2] - Data[i4]);
    h2r := -c2 * (Data[i2] + Data[i4]);
    h2i := c2 * (Data[i1] - Data[i3]);
    Data[i1] := h1r + wrs * h2r - wis * h2i;
    Data[i2] := h1i + wrs * h2i + wis * h2r;
    Data[i3] := h1r - wrs * h2r + wis * h2i;
    Data[i4] := -h1i + wrs * h2i + wis * h2r;
    wtemp := wr;
    wr := wr * wpr - wi * wpi + wr;
    wi := wi * wpr + wtemp * wpi + wi
  END;
  IF (isign = 1) THEN
  BEGIN
    h1r := Data[1];
    Data[1] := h1r + Data[2];
    Data[2] := h1r - Data[2]
  END
  ELSE
  BEGIN
    h1r := Data[1];
    Data[1] := c1 * (h1r + Data[2]);
    Data[2] := c1 * (h1r - Data[2]);
    four1(Data, n shr 1, -1)
  END
END;

PROCEDURE cosft(VAR y: TVector; n, isign: Integer);
VAR
  enf0, even, odd, sum, sume, sumo, y1, y2: real;
  Theta, wi, wr, wpi, wpr, wtemp: double;
  jj, J, m, n2: Integer;
BEGIN
  Theta := 3.14159265358979 / n;
  wr := 1.0;
  wi := 0.0;
  wpr := -2.0 * sqr(Sin(0.5 * Theta));
  wpi := Sin(Theta);
  sum := y[1];
  m := n shr 1;
  n2 := n + 2;
  FOR J := 2 TO (m + 1) DO
  BEGIN
    wtemp := wr;
    wr := wr * wpr - wi * wpi + wr;
    wi := wi * wpr + wtemp * wpi + wi;
    y1 := 0.5 * (y[J] + y[n2 - J]);
    y2 := (y[J] - y[n2 - J]);
    y[J] := y1 - wi * y2;
    y[n2 - J] := y1 + wi * y2;
    sum := sum + wr * y2
  END;
  RealFT(y, n, +1);
  y[2] := sum;
  FOR jj := 2 TO m DO
  BEGIN
    J := 2 * jj;
    sum := sum + y[J];
    y[J] := sum
  END;
  IF (isign = -1) THEN
  BEGIN
    even := y[1];
    odd := y[2];
    FOR jj := 1 TO (m - 1) DO
    BEGIN
      J := 2 * jj + 1;
      even := even + y[J];
      odd := odd + y[J + 1]
    END;
    enf0 := 2.0 * (even - odd);
    sumo := y[1] - enf0;
    sume := (2.0 * odd / n) - sumo;
    y[1] := 0.5 * enf0;
    y[2] := y[2] - sume;
    FOR jj := 1 TO (m - 1) DO
    BEGIN
      J := 2 * jj + 1;
      y[J] := y[J] - sumo;
      y[J + 1] := y[J + 1] - sume
    END
  END
END;

PROCEDURE cosft2(VAR y: TVector; n, isign: Integer);
VAR
  I: Integer;
  sum, sum1, y1, y2, ytemp: Float;
  Theta, wi, wi1, wpi, wpr, wr, wr1, wtemp: Float;
BEGIN
  wi := 0.0;
  wr := 1.0;
  Theta := 0.5 * PI / n; // Initialize the recurrences.
  wr1 := Cos(Theta);
  wi1 := Sin(Theta);
  wpr := -2.0 * wi1 * wi1;
  wpi := Sin(2.0 * Theta);
  if (isign = 1) then
  begin // Forward transform.
    for I := 1 to (n shr 1) do
    begin
      y1 := 0.5 * (y[I] + y[n - I + 1]); // Calculate the auxiliary function.
      y2 := wi1 * (y[I] - y[n - I + 1]);
      y[I] := y1 + y2;
      y[n - I + 1] := y1 - y2;
      wtemp := wr1;
      wr1 := wtemp * wpr - wi1 * wpi + wr1; // Carry out the recurrence.
      wi1 := wi1 * wpr + wtemp * wpi + wi1;
    end;
    RealFT(y, n, 1); // Transform the auxiliary function.
    I := 3;
    while I <= n do
    begin // Even terms.
      wtemp := wr;
      wr := wtemp * wpr - wi * wpi + wr;
      wi := wi * wpr + wtemp * wpi + wi;
      y1 := y[I] * wr - y[I + 1] * wi;
      y2 := y[I + 1] * wr + y[I] * wi;
      y[I] := y1;
      y[I + 1] := y2;
      I := I + 2;
    end;
    sum := 0.5 * y[2]; // Initialize recurrence for odd terms
    // with 1/2 R N/2.
    I := n;
    while I >= 2 do
    begin
      sum1 := sum; // Carry out recurrence for odd terms.
      sum := sum + y[I];
      y[I] := sum1;
      I := I - 2;
    end;
  end
  else if (isign = -1) then
  begin // Inverse transform.
    ytemp := y[n];
    I := n;
    while I >= 4 do
    begin
      y[I] := y[I - 2] - y[I]; // Form difference of odd terms.
      I := I - 2;
    end;
    y[2] := 2.0 * ytemp;
    I := 3;
    while I <= n do
    begin
      wtemp := wr;
      wr := wtemp * wpr - wi * wpi + wr;
      wi := wi * wpr + wtemp * wpi + wi;
      y1 := y[I] * wr + y[I + 1] * wi;
      y2 := y[I + 1] * wr - y[I] * wi;
      y[I] := y1;
      y[I + 1] := y2;
      I := I + 2;
    end;
    RealFT(y, n, -1);
    for I := 1 to (n shr 1) do
    begin // Invert auxiliary array.
      y1 := y[I] + y[n - I + 1];
      y2 := (0.5 / wi1) * (y[I] - y[n - I + 1]);
      y[I] := 0.5 * (y1 + y2) { ;// } * (2 / n);
      y[n - I + 1] := 0.5 * (y1 - y2) { ;// } * (2 / n);
      wtemp := wr1;
      wr1 := wtemp * wpr - wi1 * wpi + wr1;
      wi1 := wi1 * wpr + wtemp * wpi + wi1;
    end;
  end;
END;

PROCEDURE sinft(VAR y: TVector; n: Integer);
VAR
  jj, J, m, n2: Integer;
  sum, y1, y2: real;
  Theta, wi, wr, wpi, wpr, wtemp: double;
BEGIN
  Theta := 3.14159265358979 / n;
  wr := 1.0;
  wi := 0.0;
  wpr := -2.0 * sqr(Sin(0.5 * Theta));
  wpi := Sin(Theta);
  y[1] := 0.0;
  m := n shr 1;
  n2 := n + 2;
  FOR J := 2 TO (m + 1) DO
  BEGIN
    wtemp := wr;
    wr := wr * wpr - wi * wpi + wr;
    wi := wi * wpr + wtemp * wpi + wi;
    y1 := wi * (y[J] + y[n2 - J]);
    y2 := 0.5 * (y[J] - y[n2 - J]);
    y[J] := y1 + y2;
    y[n2 - J] := y1 - y2
  END;
  RealFT(y, n, +1);
  sum := 0.0;
  y[1] := 0.5 * y[1];
  y[2] := 0.0;
  FOR jj := 0 TO (m - 1) DO
  BEGIN
    J := 2 * jj + 1;
    sum := sum + y[J];
    y[J] := y[J + 1];
    y[J + 1] := sum
  END
END;

begin
  TempArraySize := 0; { Flag that buffer Temp is not allocated }
  Temp := nil;

end.
