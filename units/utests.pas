unit utests;

{ Unit utests : Statistical Tests Unit

  Created by : Alex Vergara Gil

  Contains the routines for statistical tests

}

interface

uses utypes, uComplex, uConstants;

function ProbKS(alam: float): float;
{ Chi Square test }
procedure ChiSquare(real, esperado: TVector; n: integer;
  out d, prob: float); overload;
procedure ChiSquare(real, esperado: TIntVector; n: integer;
  out d, prob: float); overload;
{ Kolgomorov Smirnov test }
procedure Kolmogorov_Smirnov(real, esperado: TVector; n: integer;
  out d, prob: float); overload;
procedure Kolmogorov_Smirnov_Compara(lista1, lista2: TVector; n1, n2: integer;
  out d, prob: float); overload;
procedure Kolmogorov_Smirnov(real, esperado: TIntVector; n: integer;
  out d, prob: float); overload;
procedure Kolmogorov_Smirnov_Compara(lista1, lista2: TIntVector;
  n1, n2: integer; out d, prob: float); overload;
{ Pearson Test }
procedure TablaContingencia(nn: TIntMatrix; ni, nj: integer;
  out h, hx, hy, hygx, hxgy, uygx, uxgy, uxy: float);
procedure Pearson(x, y: TVector; n: integer; out r, prob, z: float);
{ Spearman test }
procedure Spearman(data1, data2: TVector; n: integer;
  out d, zd, probd, rs, probrs: float);
{ Kendall test }
procedure Kendall(data1, data2: TVector; n: integer; out tau, z, prob: float);
procedure KendallTabla(Datos: TMatrix; m, n: integer; out tau, z, prob: float);
function LegendrePolinomials(l, m: longint; x: float): float;
function SphericalHarmonics(l, m: longint; theeta, phi: float): Complex;
function KruskalWallis(x: TMatrix; m, n: integer; out h, prob: float;
  out df: integer; SL: float = 0.05; missing: float = -1): boolean;
{ KW_TEST computes the nonparametric Kruskal-Wallis H-Test for three or
  more populations of equal or unequal size. This test is an extension
  of the Rank Sum Test implemented in the RS_TEST function. When each
  sample population contains at least five observations, the H test
  statistic is approximated very well by a chi-square distribution with
  DF degrees of freedom. The hypothesis that three of more sample
  populations have the same mean of distribution is rejected if two or
  more populations differ with statistical significance. }

implementation

uses Math, uoperations, uqsort, uminmax, uinterpolation, uibtdist, uigamma,
  umeansd, ugamdist, utypecasts, ufact, uspline, umath;

procedure ChiSquare(real, esperado: TVector; n: integer; out d, prob: float);
var
  i: integer;
begin
  d := 0;
  for i := 1 to n do
  begin
    d := d + sqr((real[i] - esperado[i]) / (esperado[i] + tiny));
  end;
  prob := ChiSquareProbability(d, n);
end;

procedure ChiSquare(real, esperado: TIntVector; n: integer; out d, prob: float);
var
  i: integer;
begin
  d := 0;
  for i := 1 to n do
  begin
    d := d + sqr((real[i] - esperado[i]) / (esperado[i] + tiny));
  end;
  prob := ChiSquareProbability(d, n);
end;

function ProbKS(alam: float): float;
// Kolmogorov-Smirnov probability function.
var
  j: integer;
  a2, fac, sum, term, termbf: float;
const
  EPS1 = 0.001;
  EPS2 = 1.0E-8;
begin
  fac := 2.0;
  sum := 0.0;
  termbf := 0.0;
  a2 := -2.0 * alam * alam;
  for j := 1 to 100 do
  begin
    term := fac * system.exp(a2 * j * j);
    sum := sum + term;
    if ((abs(term) <= EPS1 * termbf) or (abs(term) <= EPS2 * sum)) then
    begin
      result := sum;
      exit;
    end;
    fac := -fac; // Alternating signs in sum.
    termbf := abs(term);
  end;
  result := 1.0; // Get here only by failing to converge.
end;

procedure Kolmogorov_Smirnov(real, esperado: TVector; n: integer;
  out d, prob: float);
var
  j: integer;
  dt, en, ff, fn, fo: float;
  temp: TVector;
  lspline: TSpline;
begin
  fo := 0.0;
  QSort(real, 1, n);
  QSort(esperado, 1, n);
  en := n;
  d := 0.0;
  DimVector(temp, n);
  for j := 1 to n do
    temp[j] := j;
  lspline := TSpline.Create(temp, real, n);
  for j := 1 to n do
  begin // Loop over the sorted data points.
    fn := j / en; // Data’s c.d.f. after this step.
    ff := lspline.CubicSpline(esperado[j]);
    dt := max(abs(fo - ff), abs(fn - ff)); // Maximum distance.
    if (dt > d) then
      d := dt;
    fo := fn;
  end;
  DelVector(temp);
  lspline.Free;
  en := system.sqrt(en);
  prob := ProbKS((en + 0.12 + 0.11 / en) * (d)); // Compute signi.cance.
end;

procedure Kolmogorov_Smirnov(real, esperado: TIntVector; n: integer;
  out d, prob: float);
var
  j: integer;
  dt, en, ff, fn, fo: float;
  func, temp: TVector;
  lspline: TSpline;
begin
  fo := 0.0;
  QSort(real, 1, n);
  QSort(esperado, 1, n);
  en := n;
  d := 0.0;
  DimVector(temp, n);
  for j := 1 to n do
    temp[j] := j;
  lspline := TSpline.Create(temp, real, n);
  for j := 1 to n do
  begin // Loop over the sorted data points.
    fn := j / en; // Data’s c.d.f. after this step.
    ff := lspline.CubicSpline(esperado[j]);
    DelVector(func);
    dt := max(abs(fo - ff), abs(fn - ff)); // Maximum distance.
    if (dt > d) then
      d := dt;
    fo := fn;
  end;
  DelVector(temp);
  lspline.Free;
  en := system.sqrt(en);
  prob := ProbKS((en + 0.12 + 0.11 / en) * (d)); // Compute signi.cance.
end;

procedure Kolmogorov_Smirnov_Compara(lista1, lista2: TVector; n1, n2: integer;
  out d, prob: float);
var
  j1, j2: integer;
  d1, d2, dt, en1, en2, en, fn1, fn2: float;
begin
  j1 := 1;
  j2 := 1;
  fn1 := 0.0;
  fn2 := 0.0;
  QSort(lista1, 1, n1);
  QSort(lista2, 1, n2);
  en1 := n1;
  en2 := n2;
  d := 0.0;
  while ((j1 <= n1) and (j2 <= n2)) do
  begin // If we are not done...
    d1 := lista1[j1];
    d2 := lista2[j2];
    if (d1 <= d2) then
    begin
      fn1 := j1 / en1;
      inc(j1);
    end; // Next step is in data1.
    if (d2 <= d1) then
    begin
      fn2 := j2 / en2;
      inc(j2);
    end; // Next step is in data2.
    dt := abs(fn2 - fn1);
    if (dt > d) then
      d := dt;
  end;
  en := system.sqrt(en1 * en2 / (en1 + en2));
  prob := ProbKS((en + 0.12 + 0.11 / en) * (d)); // Compute significance.
end;

procedure Kolmogorov_Smirnov_Compara(lista1, lista2: TIntVector;
  n1, n2: integer; out d, prob: float);
var
  j1, j2: integer;
  d1, d2, dt, en1, en2, en, fn1, fn2: float;
begin
  j1 := 1;
  j2 := 1;
  fn1 := 0.0;
  fn2 := 0.0;
  QSort(lista1, 1, n1);
  QSort(lista2, 1, n2);
  en1 := n1;
  en2 := n2;
  d := 0.0;
  while ((j1 <= n1) and (j2 <= n2)) do
  begin // If we are not done...
    d1 := lista1[j1];
    d2 := lista2[j2];
    if (d1 <= d2) then
    begin
      fn1 := j1 / en1;
      inc(j1);
    end; // Next step is in data1.
    if (d2 <= d1) then
    begin
      fn2 := j2 / en2;
      inc(j2);
    end; // Next step is in data2.
    dt := abs(fn2 - fn1);
    if (dt > d) then
      d := dt;
  end;
  en := system.sqrt(en1 * en2 / (en1 + en2));
  prob := ProbKS((en + 0.12 + 0.11 / en) * (d)); // Compute significance.
end;

procedure TablaContingencia(nn: TIntMatrix; ni, nj: integer;
  out h, hx, hy, hygx, hxgy, uygx, uxgy, uxy: float);
var
  i, j: integer;
  sum, p: float;
  sumi, sumj: TVector;
const
  tiny = 1E-30;
begin
  sum := 0.0;
  DimVector(sumi, ni);
  DimVector(sumj, nj);
  for i := 1 to ni do
  begin // Get the row totals.
    for j := 1 to nj do
    begin
      sumi[i] := sumi[i] + nn[i, j];
      sum := sum + nn[i, j];
    end;
  end;
  for j := 1 to nj do
  begin // Get the column totals.
    for i := 1 to ni do
      sumj[j] := sumj[j] + nn[i, j];
  end;
  hx := 0.0; // Entropy of the x distribution,
  for i := 1 to ni do
    if not(sumi[i] = 0) then
    begin
      p := sumi[i] / sum;
      hx := hx - p * system.ln(p);
    end;
  hy := 0.0; // and of the y distribution.
  for j := 1 to nj do
    if not(sumj[j] = 0) then
    begin
      p := sumj[j] / sum;
      hy := hy - p * system.ln(p);
    end;
  h := 0.0;
  for i := 1 to ni do // Total entropy: loop over both x
    for j := 1 to nj do // and y.
      if not(nn[i, j] = 0) then
      begin
        p := nn[i, j] / sum;
        h := h - p * system.ln(p);
      end;
  hygx := h - hx; // Uses equation (14.4.18),
  hxgy := h - hy; // as does this.
  uygx := (hy - hygx) / (hy + tiny); // Equation (14.4.15).
  uxgy := (hx - hxgy) / (hx + tiny); // Equation (14.4.16).
  uxy := 2.0 * (hx + hy - h) / (hx + hy + tiny); // Equation (14.4.17).
  DelVector(sumj);
  DelVector(sumi);
end;

procedure Pearson(x, y: TVector; n: integer; out r, prob, z: float);
var
  j: integer;
  df: integer;
  yt, xt, t, syy, sxy, sxx, ay, ax: float;
const
  tiny = 1E-30;
begin
  syy := 0.0;
  sxy := 0.0;
  sxx := 0.0;
  ax := umeansd.Mean(x, 1, n);
  ay := umeansd.Mean(y, 1, n);
  for j := 1 to n do
  begin // Compute the correlation coeficient.
    xt := x[j] - ax;
    yt := y[j] - ay;
    sxx := sxx + xt * xt;
    syy := syy + yt * yt;
    sxy := sxy + xt * yt;
  end;
  r := sxy / (system.sqrt(sxx * syy) + tiny);
  z := 0.5 * system.ln((1.0 + r + tiny) / (1.0 - r + tiny));
  // Fisher’s z transformation.
  df := n - 2;
  t := r * system.sqrt(df / ((1.0 - r + tiny) * (1.0 + r + tiny)));
  // Equation (14.5.5).
  if n < 1000 then
    prob := 1 - Student_Distribution(t, df) // Student’s t probability.
  else
    prob := Erf(abs(z * system.sqrt(n - 1.0)) / 1.4142136);
  // For large n, this easier computation of prob, using the short routine erfcc, would give approximately the same value.
end;

procedure crank(var w: TVector; out s: float; n: integer);
var
  j, ji, jt, jcont: integer;
  t, rank: float;
begin
  j := 1;
  s := 0.0;
  while (j < n) do
  begin
    if (w[j + 1] <> w[j]) then
    begin // Not a tie.
      w[j] := j;
      inc(j);
    end
    else
    begin // A tie:
      jcont := j + 1;
      for jt := j + 1 to n do
        if w[jt] = w[j] then
          inc(jcont); // How far does it go?
      rank := 0.5 * (j + jcont - 1); // This is the mean rank of the tie,
      for ji := j to (jcont - 1) do
        w[ji] := rank; // so enter it into all the tied entries,
      t := jcont - j;
      s := s + t * t * t - t; // and update s.
      j := jcont;
    end;
  end;
  if (j = n) then
    w[n] := n; // If the last element was not tied, this is its rank.
end;

procedure Spearman(data1, data2: TVector; n: integer;
  out d, zd, probd, rs, probrs: float);
var
  j, df, en: integer;
  vard, t, sg, sf, fac, en3n, aved: float;
  wksp1, wksp2: TVector;
begin
  wksp1 := Clone(data1, n);
  wksp2 := Clone(data2, n);
  // Sort each of the data arrays, and convert the entries to ranks. The values sf and sg return the sums (f3k-fk) and (g3m - gm), respectively.
  QSortBy(wksp2, wksp1, 1, n);
  crank(wksp1, sf, n);
  QSortBy(wksp1, wksp2, 1, n);
  crank(wksp2, sg, n);
  d := 0.0;
  for j := 1 to n do // Sum the squared di.erence of ranks.
    d := d + sqr(wksp1[j] - wksp2[j]);
  en := n;
  en3n := en * en * en - en;
  aved := en3n / 6.0 - (sf + sg) / 12.0; // Expectation value of D,
  fac := (1.0 - sf / en3n) * (1.0 - sg / en3n);
  vard := ((en - 1.0) * en * en * sqr(en + 1.0) / 36.0) * fac;
  // and variance of D give
  zd := (d - aved) / system.sqrt(vard);
  // number of standard deviations and signi.cance.
  probd := Erf(abs(zd) / 1.4142136);
  rs := (1.0 - (6.0 / en3n) * (d + (sf + sg) / 12.0)) / system.sqrt(fac);
  // Rank correlation coeficient,
  fac := (rs + 1.0) * (1.0 - (rs));
  if (fac > 0.0) then
  begin
    t := rs * system.sqrt((en - 2.0) / fac); // and its t value,
    df := en - 2;
    probrs := 1 - Student_Distribution(t, df); // give its significance.
  end
  else
    probrs := 0.0;
  DelVector(wksp1);
  DelVector(wksp2);
end;

procedure Kendall(data1, data2: TVector; n: integer; out tau, z, prob: float);
var
  n1, n2, j, k: integer;
  is1: longint;
  svar, aa, a2, a1: float;
begin
  n1 := 0;
  n2 := 0;
  is1 := 0;
  for j := 1 to n do
  begin // Loop over first member of pair,
    for k := j + 1 to n do
    begin // and second member.
      a1 := data1[j] - data1[k];
      a2 := data2[j] - data2[k];
      aa := a1 * a2;
      if not(aa = 0) then
      begin // Neither array has a tie.
        inc(n1);
        inc(n2);
        if aa > 0.0 then
          inc(is1)
        else
          dec(is1);
      end
      else
      begin // One or both arrays have ties.
        if not(a1 = 0) then
          inc(n1); // An “extra x” event.
        if not(a2 = 0) then
          inc(n2); // An “extra y” event.
      end;
    end;
  end;
  tau := is1 / (system.sqrt(n1 * n2)); // Equation (14.6.8).
  svar := (4.0 * n + 10.0) / (9.0 * n * (n - 1.0)); // Equation (14.6.9).
  z := tau / system.sqrt(svar);
  prob := Erfc(abs(z) / 1.4142136); // Significance.
end;

procedure KendallTabla(Datos: TMatrix; m, n: integer; out tau, z, prob: float);
var
  k, kj, ki, lj, li, l: integer;
  nn, mm, m2, m1: longint;
  svar, s, points, pairs, en2, en1: float;
begin
  s := 0;
  en2 := 0;
  en1 := 0;
  nn := m * n; // Total number of entries in contingency table.
  points := Datos[m, n];
  for k := 0 to nn - 2 do
  begin // Loop over entries in table,
    ki := (k div n); // decoding a row,
    kj := k - n * ki; // and a column.
    points := points + Datos[ki + 1, kj + 1];
    // Increment the total count of events.
    for l := k + 1 to nn - 1 do
    begin // Loop over other member of the pair,
      li := l div n; // decoding its row
      lj := l - n * li; // and column.
      m1 := li - ki;
      m2 := lj - kj;
      mm := m1 * m2;
      pairs := Datos[ki + 1, kj + 1] * Datos[li + 1, lj + 1];
      if not(mm = 0) then
      begin // Not a tie.
        en1 := en1 + pairs;
        en2 := en2 + pairs;
        if mm > 0 then
          s := s + pairs
        else
          s := s - pairs; // Concordant, or discordant.
      end
      else
      begin
        if not(m1 = 0) then
          en1 := en1 + pairs;
        if not(m2 = 0) then
          en2 := en2 + pairs;
      end;
    end;
  end;
  tau := s / system.sqrt(en1 * en2);
  svar := (4.0 * points + 10.0) / (9.0 * points * (points - 1.0));
  z := tau / system.sqrt(svar);
  prob := Erfc(abs(z) / 1.4142136);
end;

function LegendrePolinomials(l, m: longint; x: float): float;
var
  fact, pll, pmm, pmmp1, somx2: float;
  i, ll: longint;
begin
  pll := 0;
  if ((m < 0) or (m > l) or (abs(x) > 1.0)) then
  begin
    result := NAN;
    exit;
  end;
  // nrerror("Bad arguments in routine plgndr");
  pmm := 1.0; // Compute Pmm.
  if (m > 0) then
  begin
    somx2 := system.sqrt((1.0 - x) * (1.0 + x));
    fact := 1.0;
    for i := 1 to m do
    begin
      pmm := pmm * (-fact * somx2);
      fact := fact + 2.0;
    end;
  end;
  if (l = m) then
    result := pmm
  else
  begin // Compute Pmm+1.
    pmmp1 := x * (2 * m + 1) * pmm;
    if (l = (m + 1)) then
      result := pmmp1
    else
    begin // Compute Pml , l > m+ 1.
      for ll := m + 2 to l do
      begin
        pll := (x * (2 * ll - 1) * pmmp1 - (ll + m - 1) * pmm) / (ll - m);
        pmm := pmmp1;
        pmmp1 := pll;
      end;
      result := pll;
    end;
  end;
end;

function Factorial(n: integer): integer;
begin
  // Classic aproximation
  // if n<=1 then result:=1 else
  // result:=n*Factorial(n-1);
  result := Trunc(fact(n));
end;

function SphericalHarmonics(l, m: longint; theeta, phi: float): Complex;
var
  temp: float;
begin
  if m >= 0 then
  begin
    temp := system.sqrt(((2 * l + 1) / (4 * PI)) *
      (Factorial(l - m) / Factorial(l + m))) * LegendrePolinomials(l, m,
      cos(theeta));
    result.Real := temp * cos(m * phi);
    result.Imaginary := temp * Sin(m * phi);
  end
  else
  begin
    m := -m;
    temp := system.sqrt(((2 * l + 1) / (4 * PI)) *
      (Factorial(l - m) / Factorial(l + m))) * LegendrePolinomials(l, m,
      cos(theeta)) * IntPower(-1, m);
    result.Real := temp * cos(m * phi);
    result.Imaginary := -temp * Sin(m * phi);
  end;
end;

function Bool(x: float): boolean;
begin
  if x = 0 then
    result := false
  else
    result := true;
end;

function InvBool(n: boolean): integer;
begin
  if n then
    result := 1
  else
    result := 0;
end;

function SumaColumnas(const A: TMatrix; Ub1, Ub2: integer): TVector;
var
  i, j: integer;
  temp: float;
begin
  DimVector(result, Ub2);
  for i := 1 to Ub2 do
  begin
    temp := 0;
    for j := 1 to Ub1 do
      temp := temp + A[i, j];
    result[i] := temp;
  end;
end;

function KruskalWallis(x: TMatrix; m, n: integer; out h, prob: float;
  out df: integer; SL, missing: float): boolean;
var
  sf, crstemp: float;
  xx, crs: TVector;
  mvi: TIntVector;
  temp: TMatrix;
  nummissing, j, k, nmiss: integer;
  sx, sy, top, bot: integer;
begin

  sy := n;
  sx := m;
  if ((n < 2) or (m < 2)) then
  begin
    SetErrCode(FUnderflow);
    // showmessage('x must be a two-dimensional array with 3 or more columns.');
    result := false; // message,
    exit;
  end;

  // Redimension x as a column vector.
  temp := Traspose(x, m, n);
  nmiss := Contar(x, m, n, missing);
  temp := Reform(temp, m, n, 1, nmiss, missing, nummissing);
  xx := FMatrixToVector(temp, 1, nmiss);
  DelMatrix(temp);
  n := nmiss;
  QSort(xx, 1, n);
  // Clone(xx,ixx,n);
  crank(xx, sf, n); // Sort and rank the combined vector.

  if not(Bool(nummissing)) then
  begin
    // Equal length samples.
    temp := FVectorToMatrix(xx, 1, n);
    temp := Reform(temp, 1, n, sy, sx, missing, nummissing);
    // Compute the individual column
    crs := SumaColumnas(temp, sy, sx); // rank sums by reforming xx.
    crstemp := 0;
    for j := 1 to sy do
      crstemp := crstemp + crs[j] * crs[j];
    crstemp := crstemp / sy;
    DelMatrix(temp);
  end
  else
  begin
    // Unequal length samples.
    DimVector(mvi, sx);
    DimVector(crs, sx);
    top := 1;
    nmiss := 0;
    for k := 1 to sx do
    begin
      for j := 1 to sy do
        if x[k, j] = missing then
          inc(nmiss);
      mvi[k] := nmiss; // Number of missing values per column vector.
      bot := top + sy - mvi[k] - 1;
      crs[k] := crs[k] + xx[bot]; // Column rank sum.
      top := bot + 1;
    end;
    crstemp := 0;
    for k := 1 to sx do
      crstemp := crstemp + (sqr(crs[k]) / (sy - mvi[k]));
  end;
  h := 12.0 / (n * (n + 1)) * crstemp - 3 * (n + 1);
  df := sx;
  prob := ChiSquareProbabilityCompl(h, df);
  result := prob > SL; // Accept hypothesis if prob>SL
  DelVector(crs);
  DelVector(xx);
end;

function prob(x, min, max: float): boolean;
begin
  result := ((x >= min) and (x < max));
end;

end.
