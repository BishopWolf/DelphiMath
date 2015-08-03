unit ulinAdj;

{ Made by: Alex Vergara Gil }

interface

uses utypes, uConstants;

procedure AjusteLineal(x, y, sig: TVector; dim: integer;
  out a, b, erra, errb, chi2, q: float); overload;
procedure AjusteLineal(x, y, sigx, sigy: TVector; dim: integer;
  out a, b, erra, errb, chi2, q: float); overload;
procedure AjusteLineal(x, y, sig, ia: TVector; ndata: integer; funcion: TFuncs;
  var a: TVector; dim: integer; out covar: TMatrix; out chisqr: float);
  overload;
function Polinomio(x: float; grado: integer): TVector;

implementation

uses math, ugamma, uoperations, uminmax, ugausjor;

procedure SHFT(var a, b, c: float; d: float);
begin
  a := b;
  b := c;
  c := d;
end;

procedure AjusteLineal(x, y, sig: TVector; dim: integer;
  out a, b, erra, errb, chi2, q: float);
var
  i, ndata: integer;
  wt, t, sxoss, sx, sy, st2, ss, sigdat: float;
  mwt: boolean;
begin
  sx := 0;
  sy := 0;
  st2 := 0;
  mwt := false;
  ndata := dim;
  if sig <> nil then
    mwt := true;
  b := 0.0;
  if (mwt) then
  begin // Accumulate sums ...
    ss := 0.0;
    for i := 1 to ndata do
    begin // ...with weights
      wt := 1.0 / SQR(sig[i]);
      ss := ss + wt;
      sx := sx + x[i] * wt;
      sy := sy + y[i] * wt;
    end;
  end
  else
  begin
    for i := 1 to ndata do
    begin // ...or without weights.
      sx := sx + x[i];
      sy := sy + y[i];
    end;
    ss := ndata;
  end;
  sxoss := sx / ss;
  if (mwt) then
  begin
    for i := 1 to ndata do
    begin
      t := (x[i] - sxoss) / sig[i];
      st2 := st2 + t * t;
      b := b + t * y[i] / sig[i];
    end;
  end
  else
  begin
    for i := 1 to ndata do
    begin
      t := x[i] - sxoss;
      st2 := st2 + t * t;
      b := b + t * y[i];
    end;
  end;
  b := b / st2; // Solve for a, b, óa, and ób.
  a := (sy - sx * b) / ss;
  erra := sqrt((1.0 + sx * sx / (ss * st2)) / ss);
  errb := sqrt(1.0 / st2);
  chi2 := 0.0; // Calculate chi^2.
  q := 1.0;
  if not(mwt) then
  begin
    for i := 1 to ndata do
      chi2 := chi2 + SQR(y[i] - a - b * x[i]);
    sigdat := sqrt(chi2 / (ndata - 2));
    // For unweighted data evaluate typical sig using chi2, and adjust the standard deviations.
    erra := erra * sigdat;
    errb := errb * sigdat;
  end
  else
  begin
    for i := 1 to ndata do
      chi2 := chi2 + SQR((y[i] - a - b * x[i]) / sig[i]);
    if (ndata > 2) then
      q := gammq(0.5 * (ndata - 2), 0.5 * chi2); // Equation (15.2.12).
  end;
end;

function Media(vect: TVector; dim: integer; out varianza: float): float;
var
  i: integer;
  ave, s, p, ep: float;
begin
  ave := 0;
  ep := 0;
  for i := 1 to dim do
    ave := ave + vect[i];
  ave := ave / dim;
  varianza := 0.0;
  for i := 1 to dim do
  begin
    s := vect[i] - ave;
    ep := ep + s;
    p := s * s;
    varianza := varianza + p;
  end;
  varianza := (varianza - (ep * ep / dim)) / (dim - 1);
  result := ave;
end;

function ChiXY(bang: float; var nn: integer; var xx, yy, sx, sy, ww: TVector;
  var aa, offs: float): float;
const
  big = 1.0E30;
var
  i: integer;
  ans, avex, avey, sumw, b: float;
begin
  avex := 0.0;
  avey := 0.0;
  sumw := 0.0;
  b := tan(bang);
  for i := 1 to nn do
  begin
    ww[i] := SQR(b * sx[i]) + SQR(sy[i]);
    if ww[i] < 1.0 / big then
      ww[i] := big
    else
      ww[i] := 1 / ww[i];
    sumw := sumw + ww[i];
    avex := avex + ww[i] * xx[i];
    avey := avey + ww[i] * yy[i];
  end;
  avex := avex / sumw;
  avey := avey / sumw;
  aa := avey - b * avex;
  ans := -offs;
  for i := 1 to nn do
    ans := ans + ww[i] * SQR(yy[i] - aa - b * xx[i]);
  result := ans;
end;

procedure Chi2Bracket(var ax, bx, cx, fa, fb, fc: float; var nn: integer;
  var xx, yy, sx, sy, ww: TVector; var aa, offs: float);
var
  ulim, u, r, q, fu, dum: float;
const
  GOLD = 1.618034;
  GLIMIT = 100.0;
  TINY = 1.0E-20;
begin
  fa := ChiXY(ax, nn, xx, yy, sx, sy, ww, aa, offs);
  fb := ChiXY(bx, nn, xx, yy, sx, sy, ww, aa, offs);
  if (fb > fa) then
  begin // Switch roles of a and b so that we can go downhill in the direction from a to b.
    SHFT(dum, ax, bx, dum);
    SHFT(dum, fb, fa, dum);
  end;
  cx := bx + GOLD * (bx - ax); // First guess for c.
  fc := ChiXY(cx, nn, xx, yy, sx, sy, ww, aa, offs);
  while (fb > fc) do
  begin // Keep returning here until we bracket.
    r := (bx - ax) * (fb - fc);
    // Compute u by parabolic extrapolation from a, b, c. TINY is used to prevent any possible division by zero.
    q := (bx - cx) * (fb - fa);
    u := bx - ((bx - cx) * q - (bx - ax) * r) /
      (2.0 * DSgn(math.Max(abs(q - r), TINY), q - r));
    ulim := bx + GLIMIT * (cx - bx);
    // We won’t go farther than this. Test various possibilities:
    if ((bx - u) * (u - cx) > 0.0) then
    begin // Parabolic u is between b and c: try it.
      fu := ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs);
      if (fu < fc) then
      begin // Got a minimum between b and c.
        ax := bx;
        bx := u;
        fa := fb;
        fb := fu;
        exit;
      end
      else if (fu > fb) then
      begin // Got a minimum between between a and u.
        cx := u;
        fc := fu;
        exit;
      end;
      u := cx + GOLD * (cx - bx);
      // Parabolic fit was no use. Use default magnification.
      fu := ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs);
    end
    else if ((cx - u) * (u - ulim) > 0.0) then
    begin // Parabolic fit is between c and its allowed limit.
      fu := ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs);
      if (fu < fc) then
      begin
        SHFT(bx, cx, u, cx + GOLD * (cx - bx));
        SHFT(fb, fc, fu, ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs))
      end;
    end
    else if ((u - ulim) * (ulim - cx) >= 0.0) then
    begin // Limit parabolic u to maximum allowed value.
      u := ulim;
      fu := ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs);
    end
    else
    begin // Reject parabolic u, use default magnification.
      u := cx + GOLD * (cx - bx);
      fu := ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs);
    end;
    SHFT(ax, bx, cx, u); // Eliminate oldest point and continue.
    SHFT(fa, fb, fc, fu);
  end;
end;

function Chi2Brent(ax, bx, cx, tol: float; var xmin: float; var nn: integer;
  var xx, yy, sx, sy, ww: TVector; var aa, offs: float): float;
const
  ITMAX = 100;
  CGOLD = 0.3819660;
  ZEPS = 1.0E-10;
var
  iter: integer;
  a, b, d, e, etemp, fu, fv, fw, fx, p, q, r, tol1, tol2, u, v, w, x, xm: float;
begin
  d := 0;
  e := 0.0; // This will be the distance moved on the step before last.
  if ax < cx then
  begin // a and b must be in ascending order, but input abscissas need not be.
    a := ax;
    b := cx;
  end
  else
  begin
    a := cx;
    b := ax;
  end;
  x := bx;
  w := bx;
  v := bx; // Initializations...
  fx := ChiXY(x, nn, xx, yy, sx, sy, ww, aa, offs);
  fw := fx;
  fv := fx;
  for iter := 1 to ITMAX do
  begin // Main program loop.
    xm := 0.5 * (a + b);
    tol1 := tol * abs(x) + ZEPS;
    tol2 := 2.0 * tol1;
    if (abs(x - xm) <= (tol2 - 0.5 * (b - a))) then
    begin // Test for done here.
      xmin := x;
      result := fx;
      exit;
    end;
    if (abs(e) > tol1) then
    begin // Construct a trial parabolic fit.
      r := (x - w) * (fx - fv);
      q := (x - v) * (fx - fw);
      p := (x - v) * q - (x - w) * r;
      q := 2.0 * (q - r);
      if (q > 0.0) then
        p := -p;
      q := abs(q);
      etemp := e;
      e := d;
      if ((abs(p) >= abs(0.5 * q * etemp)) or (p <= q * (a - x)) or
        (p >= q * (b - x))) then
      begin
        if x >= xm then
          e := a - x
        else
          e := b - x;
        d := CGOLD * e;
      end
      // The above conditions determine the acceptability of the parabolic fit. Here we take the golden section step into the larger of the two segments.
      else
      begin
        d := p / q; // Take the parabolic step.
        u := x + d;
        if ((u - a < tol2) or (b - u < tol2)) then
          d := DSgn(tol1, xm - x);
      end;
    end
    else
    begin
      if x >= xm then
        e := a - x
      else
        e := b - x;
      d := CGOLD * e;
    end;
    if abs(d) >= tol1 then
      u := x + d
    else
      u := x + DSgn(tol1, d);
    fu := ChiXY(u, nn, xx, yy, sx, sy, ww, aa, offs);
    // This is the one function evaluation per iteration.
    if (fu <= fx) then
    begin // Now decide what to do with our function evaluation.
      if (u >= x) then
        a := x
      else
        b := x;
      SHFT(v, w, x, u); // Housekeeping follows:
      SHFT(fv, fw, fx, fu);
    end
    else
    begin
      if (u < x) then
        a := u
      else
        b := u;
      if ((fu <= fw) or (w = x)) then
      begin
        v := w;
        w := u;
        fv := fw;
        fw := fu;
      end
      else if ((fu <= fv) or (v = x) or (v = w)) then
      begin
        v := u;
        fv := fu;
      end;
    end; // Done with housekeeping. Back for another iteration.
  end;
  // nrerror("Too many iterations in brent");
  xmin := x; // Never get here.
  result := fx;
end;

function Chi2ZBrent(x1, x2, tol: float; { var xmin:float; } var nn: longint;
  var xx, yy, sx, sy, ww: TVector; var aa, offs: float): float;
const
  ITMAX = 100;
  EPS = 3.0E-8;
var
  iter: integer;
  a, b, c, d, e, min1, min2, temp: float;
  fa, fb, fc, p, q, r, s, tol1, xm: float;
begin
  a := x1;
  b := x2;
  c := x2;
  d := 0;
  e := 0;
  fa := ChiXY(a, nn, xx, yy, sx, sy, ww, aa, offs);
  fb := ChiXY(b, nn, xx, yy, sx, sy, ww, aa, offs);
  if (((fa > 0.0) and (fb > 0.0)) or ((fa < 0.0) and (fb < 0.0))) then
  begin
    result := NAN;
    exit; // nrerror("Root must be bracketed in zbrent");
  end;
  fc := fb;
  for iter := 1 to ITMAX do
  begin
    if (((fb > 0.0) and (fc > 0.0)) or ((fb < 0.0) and (fc < 0.0))) then
    begin
      c := a; // Rename a, b, c and adjust bounding interval d.
      fc := fa;
      e := b - a;
      d := e;
    end;
    if (abs(fc) < abs(fb)) then
    begin
      a := b;
      b := c;
      c := a;
      fa := fb;
      fb := fc;
      fc := fa;
    end;
    tol1 := 2.0 * EPS * abs(b) + 0.5 * tol; // Convergence check.
    xm := 0.5 * (c - b);
    if ((abs(xm) <= tol1) or (fb = 0.0)) then
    begin
      result := b;
      exit;
    end;
    if ((abs(e) >= tol1) and (abs(fa) > abs(fb))) then
    begin
      s := fb / fa; // Attempt inverse quadratic interpolation.
      if (a = c) then
      begin
        p := 2.0 * xm * s;
        q := 1.0 - s;
      end
      else
      begin
        q := fa / fc;
        r := fb / fc;
        p := s * (2.0 * xm * q * (q - r) - (b - a) * (r - 1.0));
        q := (q - 1.0) * (r - 1.0) * (s - 1.0);
      end;
      if (p > 0.0) then
        q := -q; // Check whether in bounds.
      p := abs(p);
      min1 := 3.0 * xm * q - abs(tol1 * q);
      min2 := abs(e * q);
      if min1 < min2 then
        temp := min1
      else
        temp := min2;
      if (2.0 * p < temp) then
      begin
        e := d; // Accept interpolation.
        d := p / q;
      end
      else
      begin
        d := xm; // Interpolation failed, use bisection.
        e := d;
      end;
    end
    else
    begin // Bounds decreasing too slowly, use bisection.
      d := xm;
      e := d;
    end;
    a := b; // Move last best guess to a.
    fa := fb;
    if (abs(d) > tol1) then // Evaluate new trial root.
      b := b + d
    else
      b := b + DSgn(tol1, xm);
    fb := ChiXY(b, nn, xx, yy, sx, sy, ww, aa, offs);
  end;
  // nrerror("Maximum number of iterations exceeded in zbrent");
  result := 0.0; // Never get here.
end;

procedure AjusteLineal(x, y, sigx, sigy: TVector; dim: integer;
  out a, b, erra, errb, chi2, q: float);
const
  POTN = 1.571000;
  big = 1.0E30;
  ACC = 1.0E-3;
var
  nn, i, ndata: integer;
  xx, yy, sx, sy, ww: TVector;
  aa, offs: float;
  swap, amx, amn, avey, varx, vary, scale, bmn, bmx, d1, d2, r2, dum1, dum2,
    dum3, dum4, dum5: float;
  ang, ch: array [1 .. 7] of float;
begin
  ndata := dim;
  DimVector(xx, ndata);
  DimVector(yy, ndata);
  DimVector(sx, ndata);
  DimVector(sy, ndata);
  DimVector(ww, ndata);
  Media(x, ndata, varx);
  avey := Media(y, ndata, vary);
  dum1 := avey;
  scale := sqrt(varx / vary);
  nn := ndata;
  for i := 1 to ndata do
  begin
    xx[i] := x[i];
    yy[i] := y[i] * scale;
    sx[i] := sigx[i];
    sy[i] := sigy[i] * scale;
    ww[i] := sqrt(SQR(sx[i]) + SQR(sy[i]));
    // Use both x and y weights in first trial fit.
  end;
  AjusteLineal(xx, yy, ww, dim, dum1, b, dum2, dum3, dum4, dum5);
  offs := 0;
  ang[1] := 0;
  ang[2] := arctan(b);
  ang[4] := 0.0;
  ang[5] := ang[2];
  ang[6] := POTN;
  for i := 4 to 6 do
    ch[i] := ChiXY(ang[i], nn, xx, yy, sx, sy, ww, aa, offs);
  Chi2Bracket(ang[1], ang[2], ang[3], ch[1], ch[2], ch[3], nn, xx, yy, sx, sy,
    ww, aa, offs);
  // Bracket the chi^2 minimum and then locate it with brent.
  chi2 := Chi2Brent(ang[1], ang[2], ang[3], ACC, b, nn, xx, yy, sx, sy, ww,
    aa, offs);
  chi2 := ChiXY(b, nn, xx, yy, sx, sy, ww, aa, offs);
  a := aa;
  q := gammq(0.5 * (nn - 2), chi2 * 0.5); // Compute chi^2 probability.
  r2 := 0.0;
  for i := 1 to nn do
    r2 := r2 + ww[i]; // Save the inverse sum of weights at the minimum.
  r2 := 1.0 / r2;
  bmx := big; // Now, find standard errors for b as points where chi^2 = 1.
  bmn := big;
  offs := chi2 + 1.0;
  for i := 1 to 6 do
  begin // Go through saved values to bracket the desired roots. Note periodicity in slope angles.
    if (ch[i] > offs) then
    begin
      d1 := abs(ang[i] - b);
      while (d1 >= PI) do
        d1 := d1 - PI;
      d2 := PI - d1;
      if (ang[i] < b) then
      begin
        swap := d1;
        d1 := d2;
        d2 := swap;
      end;
      if (d1 < bmx) then
        bmx := d1;
      if (d2 < bmn) then
        bmn := d2;
    end;
  end;
  if (bmx < big) then
  begin // Call zbrent to find the roots.
    bmx := Chi2ZBrent(b, b + bmx, ACC, nn, xx, yy, sx, sy, ww, aa, offs) - b;
    amx := aa - a;
    bmn := Chi2ZBrent(b, b - bmn, ACC, nn, xx, yy, sx, sy, ww, aa, offs) - b;
    amn := aa - a;
    errb := sqrt(0.5 * (bmx * bmx + bmn * bmn)) / (scale * SQR(cos(b)));
    erra := sqrt(0.5 * (amx * amx + amn * amn) + r2) / scale;
    // Error in a has additional piece r2.
  end
  else
    errb := big;
  erra := big;
  a := a / scale; // Unscale the answers.
  b := tan(b) / scale;
  DelVector(ww);
  DelVector(sy);
  DelVector(sx);
  DelVector(yy);
  DelVector(xx);
end;

procedure covsrt(var covar: TMatrix; mfit, ma: cardinal; ia: TVector);
var
  i, j, k: integer;
begin
  for i := mfit + 1 to ma do
    for j := 1 to i do
    begin
      covar[i, j] := 0;
      covar[j, i] := 0;
    end;
  k := mfit;
  for j := ma downto 1 do
  begin
    if not(ia[j] = 0) then
    begin
      TraspondColumns(covar, k, j, ma);
      TraspondRows(covar, k, j, ma);
      dec(k);
    end;
  end;
end;

procedure AjusteLineal(x, y, sig, ia: TVector; ndata: integer; funcion: TFuncs;
  var a: TVector; dim: integer; out covar: TMatrix; out chisqr: float);
var
  i, j, k, l, m, ma, mfit: integer;
  ym, wt, sum, sig2i: float;
  beta: TMatrix;
  GJE: TGaussJordan;
  afunc: TVector;
  temponeda: TMatrix;
begin
  mfit := 0;
  ma := dim;
  for j := 1 to ma do
    if not(ia[j] = 0) then
      inc(mfit);
  if (mfit = 0) then
  begin
    exit;
  end; // nrerror("lfit: no parameters to be fitted");
  DimMatrix(beta, ma, 1);
  DimMatrix(covar, ma, ma);
  for i := 1 to ndata do
  begin // Loop over data to accumulate coe.cients of the normal equations.
    afunc := funcion(x[i], ma);
    ym := y[i];
    if (mfit < ma) then
    begin // Subtract o. dependences on known pieces of the .tting function.
      for j := 1 to ma do
        if (ia[j] = 0) then
          ym := ym - a[j] * afunc[j];
    end;
    sig2i := 1;
    if sig <> nil then
      sig2i := 1.0 / SQR(sig[i]);
    j := 0;
    for l := 1 to ma do
    begin
      if not(ia[l] = 0) then
      begin
        wt := afunc[l] * sig2i;
        k := 0;
        inc(j);
        for m := 1 to l do
        begin
          if not(ia[m] = 0) then
          begin
            inc(k);
            covar[j, k] := covar[j, k] + wt * afunc[m];
          end;
        end;
        beta[j, 1] := beta[j, 1] + ym * wt;
      end;
    end;
  end;
  for j := 2 to mfit do // Fill in above the diagonal from symmetry.
    for k := 1 to j - 1 do
      covar[k, j] := covar[j, k];
  GJE := TGaussJordan.Create(covar, 1, mfit);
  temponeda := GJE.Solve(beta, 1); // Matrix solution.
  DelMatrix(covar);
  covar := Clone(GJE.InverseMatrix, mfit, mfit);
  DelMatrix(beta);
  beta := temponeda;
  GJE.Free;
  // GaussJordan_Elimination(covar,beta,mfit,1);// Matrix solution.
  // if not( covar.Gauss_Jordan_Elimination(beta)) then begin beta.Free;exit;end;
  j := 0;
  for l := 1 to ma do
    if not(ia[l] = 0) then
    begin
      inc(j);
      a[l] := beta[j, 1]; // Partition solution to appropriate coefficients a.
    end;
  chisqr := 0.0;
  for i := 1 to ndata do
  begin // Evaluate chi^2 of the fit.
    afunc := funcion(x[i], ma);
    sum := 0.0;
    for j := 1 to ma do
      sum := sum + a[j] * afunc[j];
    sig2i := 1;
    if sig <> nil then
      sig2i := sig[i];
    chisqr := chisqr + SQR((y[i] - sum) / sig2i);
    DelVector(afunc);
  end;
  covsrt(covar, mfit, ma, ia);
  // Sort covariance matrix to true order of fitting coefficients.
  DelMatrix(beta);
end;

function Polinomio(x: float; grado: integer): TVector;
var
  i: integer;
  xi: float;
begin
  DimVector(result, grado + 1);
  xi := 1;
  for i := 1 to grado + 1 do
  begin
    result[i] := xi;
    xi := xi * x;
  end;
end;

end.
