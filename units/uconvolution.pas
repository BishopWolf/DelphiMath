Unit uconvolution;

Interface

Uses utypes;

Function Convolucion(Data: TVector; Var Respns: TVector;
  n, m, isign: integer): TVector;
Function Correlacion(Data1, Data2: TVector; n: integer): TVector;
Function SavitzkyGolay(Data: TVector; n, nl, nr, ld, m: integer)
  : TVector; Overload;
Function SavitzkyGolay(Data: TintVector; n, nl, nr, ld, m: integer)
  : TintVector; Overload;

Implementation

Uses uoperations, ufft, umath, uminmax, ulu, utypecasts, uConstants, math;

Function WrapAround(inVector: TVector; n: integer): TVector;
Var
  i, nl, k: integer;
Begin
  nl := n Shr 1;
  DimVector(Result, n);
  For i := -nl + 1 To nl Do
  Begin
    k         := ((n - i) Mod n) + 1;
    Result[k] := inVector[i + nl];
  End;
End;

Function Convolucion(Data: TVector; Var Respns: TVector;
  n, m, isign: integer): TVector;
{ Convolves or deconvolves a real data set data[1..n] (including any user-supplied zero padding)
  with a response function respns[1..n]. The response function must be stored in wrap-around
  order in the first m elements of respns, where m is an odd integer . n. Wrap-around order
  means that the first half of the array respns contains the impulse response function at positive
  times, while the second half of the array contains the impulse response function at negative times,
  counting down from the highest element respns[m]. On input isign is +1 for convolution,
  -1 for deconvolution. The answer is returned in the first n components of ans. However,
  ans must be supplied in the calling program with dimensions [1..2*n], for consistency with
  twofft. n MUST be an integer power of two. }
VAR
  no2, i, ii: integer;
  dum, mag2 : real;
  fft, ans  : TVector;
BEGIN
  FOR i := 1 TO ((m - 1) DIV 2) DO
  BEGIN
    Respns[n + 1 - i] := Respns[m + 1 - i]
  END;
  FOR i := ((m + 3) DIV 2) TO (n - ((m - 1) DIV 2)) DO
  BEGIN
    Respns[i] := 0.0
  END;
  FFTTwo(Data, Respns, n, fft, ans);
  no2   := n DIV 2;
  FOR i := 1 TO (no2 + 1) DO
  BEGIN
    ii := 2 * i;
    IF (isign = 1) THEN
    BEGIN
      dum         := ans[ii - 1];
      ans[ii - 1] := (fft[ii - 1] * ans[ii - 1] - fft[ii] * ans[ii]) / no2;
      ans[ii]     := (fft[ii] * dum + fft[ii - 1] * ans[ii]) / no2
    END
    ELSE IF (isign = -1) THEN
    BEGIN
      IF ((sqr(ans[ii - 1]) + sqr(ans[ii])) = 0.0) THEN
      BEGIN
        writeln('pause in routine CONVLV');
        writeln('deconvolving at response zero');
        readln
      END;
      dum         := ans[ii - 1];
      mag2        := sqr(ans[ii - 1]) + sqr(ans[ii]);
      ans[ii - 1] := (fft[ii - 1] * ans[ii - 1] + fft[ii] * ans[ii]) /
        mag2 / no2;
      ans[ii] := (fft[ii] * dum - fft[ii - 1] * ans[ii]) / mag2 / no2
    END
    ELSE
    BEGIN
      writeln('pause in routine CONVLV');
      writeln('no meaning for ISIGN');
      readln
    END
  END;
  ans[2] := ans[n + 1];
  realft(ans, no2, -1);
  Result := ans;
End;

Function Correlacion(Data1, Data2: TVector; n: integer): TVector;
VAR
  no2, i, ii: integer;
  dum       : real;
  fft, ans  : TVector;
BEGIN
  FFTTwo(Data1, Data2, n, fft, ans);
  no2   := n DIV 2;
  FOR i := 1 TO (no2 + 1) DO
  BEGIN
    ii          := 2 * i;
    dum         := ans[ii - 1];
    ans[ii - 1] := (fft[ii - 1] * ans[ii - 1] + fft[ii] * ans[ii]) / no2;
    ans[ii]     := (fft[ii] * dum - fft[ii - 1] * ans[ii]) / no2
  END;
  ans[2] := ans[n + 1];
  realft(ans, no2, -1);
  Result := ans;
End;

Function SavitzkyGolay(Data: TVector; n, nl, nr, ld, m: integer): TVector;
// Filtro Pasa Bajos de Savitzky-Golay devuelve el doble del orden de los datos iniciales
{ Returns in c[1..np], in wrap-around order (N.B.!) consistent with the argument respns in
  routine convlv, a set of Savitzky-Golay filter coeficients. nl is the number of leftward (past)
  data points used, while nr is the number of rightward (future) data points, making the total
  number of data points used nl+nr+1. ld is the order of the derivative desired (e.g., ld = 0
  for smoothed function). m is the order of the smoothing polynomial, also equal to the highest
  conserved moment; usual values are m = 2 or m = 4. }
Var
  imj, ipj, k, kk, mm: integer;
  fac, sum           : float;
  a                  : TMatrix;
  lLU                : TLU;
  b, res             : TVector;
  Function bool(x: float): boolean;
  Begin
    If x = 0 Then
      Result := false
    Else
      Result := true;
  End;

Begin
  If ((n < nl + nr + 1) Or (nl < 0) Or (nr < 0) Or (ld > m) Or
    (nl + nr < m)) Then
  Begin // if (np < nl+nr+1 || nl < 0 || nr < 0 || ld > m || nl+nr < m)
    Result := Nil; // nrerror("bad args in savgol");
    exit;
  End;
  DimMatrix(a, m + 1, m + 1); // a=matrix(1,m+1,1,m+1);
  DimVector(b, m + 1);        // b=vector(1,m+1);
  For ipj := 0 To (m Shl 1) Do
  Begin // for (ipj=0;ipj<=(m << 1);ipj++) { Set up the normal equations of the desired
    If bool(ipj) Then
      sum := 0
    Else
      sum := 1; // sum=(ipj ? 0.0 : 1.0); least-squares fit.
    For k := 1 To nr Do
      sum := sum + power(k, ipj);
    // for (k=1;k<=nr;k++) sum += pow((double)k,(double)ipj);
    For k := 1 To nl Do
      sum := sum + power(-k, ipj);
    // for (k=1;k<=nl;k++) sum += pow((double)-k,(double)ipj);
    mm  := Min(ipj, 2 * m - ipj); // mm=IMIN(ipj,2*m-ipj);
    imj := -mm;
    While imj <= mm Do
    Begin // for (imj = -mm;imj<=mm;imj+=2) a[1+(ipj+imj)/2][1+(ipj-imj)/2]=sum;
      a[1 + ((ipj + imj) Div 2), 1 + ((ipj - imj) Div 2)] := sum;
      inc(imj, 2);
    End;
  End;
  lLU := TLU.Create(a, 1, m + 1); // Solve them: LU decomposition.
  // LU_Decomp(a,1,m+1);
  b[ld + 1] := 1; // for (j=1;j<=m+1;j++) b[j]=0.0;b[ld+1]=1.0;
  // Right-hand side vector is unit vector, depending on which derivative we want.
  lLU.Solve(b); // Get one row of the inverse matrix.
  // LU_Solve(a,b,1,m+1);//DelIntVector(indx,m+1);
  DimVector(res, n);
  // for (kk=1;kk<=np;kk++) c[kk]=0.0; Zero the output array (it may be bigger than
  For k := -nl To nr Do
  Begin          // for (k = -nl;k<=nr;k++) { number of coefficients).
    sum := b[1]; // Each Savitzky-Golay coefficient is the dot
    // product of powers of an integer with the
    // inverse matrix row.
    fac    := 1.0;
    For mm := 1 To m Do
    Begin
      fac := fac * k;
      sum := sum + b[mm + 1] * fac;
    End;
    kk      := ((n - k) Mod n) + 1; // Store in wrap-around order.
    res[kk] := sum;
  End;

  Result := Convolucion(Data, res, n, n, 1); // original
  lLU.Free;
  DelVector(b);
  DelMatrix(a);
  DelVector(res);
End;

Function SavitzkyGolay(Data: TintVector; n, nl, nr, ld, m: integer): TintVector;
Var
  temp: TVector;
  i   : integer;
Begin
  InttoFloat(Data, temp, n);
  temp := SavitzkyGolay(temp, n, nl, nr, ld, m);
  DimVector(Result, n);
  For i       := 1 To n Do
    Result[i] := round(temp[i]);
  DelVector(temp);
End;

End.
