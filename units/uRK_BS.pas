unit uRK_BS;

interface

uses utypes, uConstants, math;

procedure RungeKutta4(vstart: TVector; nvar: integer; x1, x2: float;
  var nstep: integer; funcion: TStrVector; out yout: TMatrix;
  out xout: TVector);
procedure RungeKutta5(ystart: TVector; nvar: integer;
  x1, x2, eps, h1, hmin: float; funcion: TStrVector; var nok, nbad: integer;
  var dxsav: float; var xp: TVector; kmax: integer; var kount: integer;
  var yp: TMatrix);
procedure RungeKuttaD(ystart: TVector; nvar: integer;
  x1, x2, eps, h1, hmin: float; funcion: TDerivs; var nok, nbad: integer;
  var dxsav: float; var xp: TVector; kmax: integer; var kount: integer;
  var yp: TMatrix);
procedure BulirschStoer(ystart: TVector; nvar: integer;
  x1, x2, eps, h1, hmin: float; funcion: TStrVector; var nok, nbad: integer;
  var dxsav: float; var xp: TVector; kmax: integer; var kount: integer;
  var yp: TMatrix);

implementation

uses uMath, uinterpolation, parser10, uoperations, uminmax;

var
  PFuncion: TParser;

function RK4(y1, dy1: TVector; dim: integer; x1, h: float): TVector;
var
  i, n: integer;
  xh, hh, h6, dytt: float;
  dym, dyt, yt, yout: TVector;
begin
  n := dim;
  DimVector(dym, n);
  DimVector(dyt, n);
  DimVector(yt, n);
  hh := h * 0.5;
  h6 := h / 6.0;
  xh := x1 + hh;
  for i := 1 to n do
    yt[i] := y1[i] + hh * dy1[i]; // First step.
  PFuncion.x := xh;
  for i := 1 to n do
  begin
    PFuncion.y := yt[i];
    dytt := PFuncion.Value; // Second step.
    dyt[i] := dytt;
  end;
  for i := 1 to n do
    yt[i] := y1[i] + hh * dyt[i];
  for i := 1 to n do
  begin
    PFuncion.y := yt[i];
    dytt := PFuncion.Value; // third step.
    dym[i] := dytt;
  end;
  for i := 1 to n do
  begin
    yt[i] := y1[i] + h * dym[i];
    dym[i] := dym[i] + dyt[i];
  end;
  PFuncion.x := x1 + h;
  for i := 1 to n do
  begin
    PFuncion.y := yt[i];
    dytt := PFuncion.Value; // fourth step.
    dyt[i] := dytt;
  end;
  DimVector(yout, n);
  for i := 1 to n do // Accumulate increments with proper weights.
    yout[i] := y1[i] + h6 * (dy1[i] + dyt[i] + 2.0 * dym[i]);
  result := yout;
  DelVector(yt);
  DelVector(dyt);
  DelVector(dym);
end;

procedure RungeKutta4(vstart: TVector; nvar: integer; x1, x2: float;
  var nstep: integer; funcion: TStrVector; out yout: TMatrix;
  out xout: TVector);
var
  i, k: integer;
  xh, h, dvt: float;
  v, vout, dv: TVector;
begin
  // PFuncion.Expression:=funcion;
  DimVector(v, nvar);
  DimVector(dv, nvar);
  DimMatrix(yout, nvar, nstep + 1);
  DimVector(xout, nstep + 1);
  for i := 1 to nvar do
  begin // Load starting values.
    v[i] := vstart[i];
    yout[i, 1] := v[i];
  end;
  xout[1] := x1;
  xh := x1;
  h := (x2 - x1) / nstep;
  for k := 1 to nstep do
  begin // Take nstep steps.
    for i := 1 to nvar do
    begin
      PFuncion.Expression := funcion[i];
      PFuncion.x := xh;
      PFuncion.y := v[i];
      dvt := PFuncion.Value;
      dv[i] := dvt;
    end;
    for i := 1 to nvar do
    begin
      PFuncion.Expression := funcion[i];
      vout := RK4(v, dv, nvar, xh, h);
    end;
    if ((xh + h) = xh) then
    begin
      // nrerror("Step size too small in routine rkdumb");
      nstep := nstep div 2;
      RungeKutta4(vstart, nvar, x1, x2, nstep, funcion, yout, xout);
      exit;
    end;
    xh := xh + h;
    xout[k + 1] := xh; // Store intermediate steps.
    for i := 1 to nvar do
    begin
      v[i] := vout[i];
      yout[i, k + 1] := v[i];
    end;
  end;
  DelVector(dv);
  DelVector(vout);
  DelVector(v);
end;

procedure RK5(var y1: TVector; dy1, yscal: TVector; dim: integer;
  var x1, hdid, hnext: float; htry, eps: float);
var
  a2, a3, a4, a5, a6, b21, b31, b32, b41, b42, b43, b51, b52, b53, b54, b61,
    b62, b63, b64, b65, c1, c3, c4, c6, dc5: float;
  procedure rkck(y1: TVector; dy1: TVector; dim: integer; x1, h: float;
    out yout, yerr: TVector);
  var
    i, n: longint;
    dc1, dc3, dc4, dc6, akt: float;
    ak2, ak3, ak4, ak5, ak6, ytemp: TVector;
  begin
    dc1 := c1 - 2825.0 / 27648.0;
    dc3 := c3 - 18575.0 / 48384.0;
    dc4 := c4 - 13525.0 / 55296.0;
    dc6 := c6 - 0.25;
    n := dim;
    DimVector(ak2, n);
    DimVector(ak3, n);
    DimVector(ak4, n);
    DimVector(ak5, n);
    DimVector(ak6, n);
    DimVector(ytemp, n);
    DimVector(yout, n);
    DimVector(yerr, n);
    for i := 1 to n do
      ytemp[i] := y1[i] + b21 * h * dy1[i]; // First step.
    PFuncion.x := x1 + a2 * h;
    for i := 1 to n do
    begin
      PFuncion.y := ytemp[i];
      akt := PFuncion.Value; // Second step.
      ak2[i] := akt;
    end;
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b31 * dy1[i] + b32 * ak2[i]);
    PFuncion.x := x1 + a3 * h;
    for i := 1 to n do
    begin
      PFuncion.y := ytemp[i];
      akt := PFuncion.Value; // Third step.
      ak3[i] := akt;
    end;
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b41 * dy1[i] + b42 * ak2[i] + b43 * ak3[i]);
    PFuncion.x := x1 + a4 * h;
    for i := 1 to n do
    begin
      PFuncion.y := ytemp[i];
      akt := PFuncion.Value; // Fourth step.
      ak4[i] := akt;
    end;
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b51 * dy1[i] + b52 * ak2[i] + b53 * ak3[i] + b54
        * ak4[i]);
    PFuncion.x := x1 + a5 * h;
    for i := 1 to n do
    begin
      PFuncion.y := ytemp[i];
      akt := PFuncion.Value; // Fifth step.
      ak5[i] := akt;
    end;
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b61 * dy1[i] + b62 * ak2[i] + b63 * ak3[i] + b64
        * ak4[i] + b65 * ak5[i]);
    PFuncion.x := x1 + a6 * h;
    for i := 1 to n do
    begin
      PFuncion.y := ytemp[i];
      akt := PFuncion.Value; // Sixth step.
      ak6[i] := akt;
    end;
    for i := 1 to n do
    begin // Accumulate increments with proper weights.
      yout[i] := y1[i] + h * (c1 * dy1[i] + c3 * ak3[i] + c4 * ak4[i] + c6
        * ak6[i]);
      yerr[i] := h * (dc1 * dy1[i] + dc3 * ak3[i] + dc4 * ak4[i] + dc5 * ak5[i]
        + dc6 * ak6[i]);
    end;
    // Estimate error as difference between fourth and fifth order methods.
    DelVector(ytemp);
    DelVector(ak2);
    DelVector(ak3);
    DelVector(ak4);
    DelVector(ak5);
    DelVector(ak6);
  end;

var
  i, n: integer;
  errmax, h, htemp, xnew: float;
  yerr, ytemp: TVector;
const
  SAFETY = 0.9;
  PGROW = -0.2;
  PSHRNK = -0.25;
  ERRCON = 1.89E-4; // exp((1/PGROW)*ln(5/SAFETY));
begin
  a2 := 0.2;
  a3 := 0.3;
  a4 := 0.6;
  a5 := 1.0;
  a6 := 0.875;
  b21 := 0.2;
  b31 := 3.0 / 40.0;
  b32 := 9.0 / 40.0;
  b41 := 0.3;
  b42 := -0.9;
  b43 := 1.2;
  b51 := -11.0 / 54.0;
  b52 := 2.5;
  b53 := -70.0 / 27.0;
  b54 := 35.0 / 27.0;
  b61 := 1631.0 / 55296.0;
  b62 := 175.0 / 512.0;
  b63 := 575.0 / 13824.0;
  b64 := 44275.0 / 110592.0;
  b65 := 253.0 / 4096.0;
  c1 := 37.0 / 378.0;
  c3 := 250.0 / 621.0;
  c4 := 125.0 / 594.0;
  c6 := 512.0 / 1771.0;
  dc5 := -277.00 / 14336.0;
  n := dim;
  h := htry; // Set stepsize to the initial trial value.
  repeat
    rkck(y1, dy1, dim, x1, h, ytemp, yerr); // Take a step.
    errmax := 0.0; // Evaluate accuracy.
    for i := 1 to n do
      errmax := Max(errmax, abs(yerr[i] / yscal[i]));
    errmax := errmax / eps; // Scale relative to required tolerance.
    if (errmax <= 1.0) then
      break; // Step succeeded. Compute size of next step.
    htemp := SAFETY * h * power(errmax, PSHRNK);
    // Truncation error too large, reduce stepsize.
    if h >= 0.0 then
      h := Max(htemp, 0.1 * h)
    else
      h := Min(htemp, 0.1 * h);
    // No more than a factor of 10.
    xnew := x1 + h;
    if (xnew = x1) then
    begin
      exit; // nrerror("stepsize underflow in rkqs");
    end;
  until false;
  if (errmax > ERRCON) then
    hnext := SAFETY * h * power(errmax, PGROW)
  else
    hnext := 5.0 * h; // No more than a factor of 5 increase.
  hdid := h;
  x1 := x1 + hdid;
  DelVector(y1);
  y1 := ytemp;
  DelVector(yerr);
end;

procedure RungeKutta5(ystart: TVector; nvar: integer;
  x1, x2, eps, h1, hmin: float; funcion: TStrVector; var nok, nbad: integer;
  var dxsav: float; var xp: TVector; kmax: integer; var kount: integer;
  var yp: TMatrix);
var
  nstp, i: integer;
  xsav, hnext, hdid, h, dy1t, xh: float;
  yscal, y1, dy1: TVector;
const
  MAXSTP = 10000;
  TINY = 1.0E-30;
begin
  // PFuncion.Expression:=funcion;
  DimVector(yscal, nvar);
  y1 := Clone(ystart, nvar);
  DimVector(dy1, nvar);
  h := DSgn(h1, x2 - x1);
  xh := x1;
  nok := 0;
  nbad := 0;
  kount := 0;
  xsav := xh - dxsav * 2.0; // Assures storage of first step.
  for nstp := 1 to MAXSTP do
  begin // Take at most MAXSTP steps.
    for i := 1 to nvar do
    begin
      PFuncion.Expression := funcion[i];
      PFuncion.x := xh;
      PFuncion.y := y1[i];
      dy1t := PFuncion.Value;
      dy1[i] := dy1t;
    end;
    for i := 1 to nvar do
      // Scaling used to monitor accuracy. This general-purpose choice can be modi.ed if need be.
      yscal[i] := abs(y1[i]) + abs(dy1[i] * h) + TINY;
    if ((kmax > 0) and (kount < kmax - 1) and
      (abs(PFuncion.x - xsav) > abs(dxsav))) then
    begin
      inc(kount);
      xp[kount] := xh; // Store intermediate results.
      for i := 1 to nvar do
        yp[i, kount] := y1[i];
      xsav := xh;
    end;
    if ((xh + h - x2) * (xh + h - x1) > 0.0) then
      h := x2 - xh; // If stepsize can overshoot, decrease.
    for i := 1 to nvar do
    begin
      PFuncion.Expression := funcion[i];
      RK5(y1, dy1, yscal, nvar, xh, hdid, hnext, h, eps);
    end;
    if (hdid = h) then
      inc(nok)
    else
      inc(nbad);
    if ((xh - x2) * (x2 - x1) >= 0.0) then
    begin // Are we done?
      if not(kmax = 0) then
      begin
        inc(kount);
        xp[kount] := xh; // Save final step.
        for i := 1 to nvar do
          yp[i, kount] := y1[i];
      end;
      DelVector(dy1);
      DelVector(y1);
      DelVector(yscal);
      exit; // Normal exit.
    end;
    if (abs(hnext) <= hmin) then
    begin
      RungeKutta5(ystart, nvar, x1, x2, eps, 2 * h1, hmin, funcion, nok, nbad,
        dxsav, xp, kmax, kount, yp);
      exit; // nrerror("Step size too small in odeint");
    end;
    h := hnext;
  end;
  DelVector(dy1);
  DelVector(y1);
  DelVector(yscal);
  // nrerror("Too many steps in routine odeint");
end;

function RK5D(y1, dy1, yscal: TVector; dim: integer; funcion: TDerivs;
  var x1, hdid, hnext: float; htry, eps: float): TVector;
var
  a2, a3, a4, a5, a6, b21, b31, b32, b41, b42, b43, b51, b52, b53, b54, b61,
    b62, b63, b64, b65, c1, c3, c4, c6, dc5: float;
  procedure rkck(y1, dy1: TVector; dim: integer; funcion: TDerivs; x1, h: float;
    out yout, yerr: TVector);
  var
    i, n: longint;
    dc1, dc3, dc4, dc6: float;
    ak2, ak3, ak4, ak5, ak6, ytemp: TVector;
  begin
    dc1 := c1 - 2825.0 / 27648.0;
    dc3 := c3 - 18575.0 / 48384.0;
    dc4 := c4 - 13525.0 / 55296.0;
    dc6 := c6 - 0.25;
    n := dim;
    DimVector(ytemp, n);
    DimVector(yout, n);
    DimVector(yerr, n);
    for i := 1 to n do
      ytemp[i] := y1[i] + b21 * h * dy1[i]; // First step.
    ak2 := funcion(x1 + a2 * h, ytemp, n); // Second step.
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b31 * dy1[i] + b32 * ak2[i]);
    ak3 := funcion(x1 + a3 * h, ytemp, n); // Third step.
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b41 * dy1[i] + b42 * ak2[i] + b43 * ak3[i]);
    ak4 := funcion(x1 + a4 * h, ytemp, n); // Fourth step.
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b51 * dy1[i] + b52 * ak2[i] + b53 * ak3[i] + b54
        * ak4[i]);
    ak5 := funcion(x1 + a5 * h, ytemp, n); // Fifth step.
    for i := 1 to n do
      ytemp[i] := y1[i] + h * (b61 * dy1[i] + b62 * ak2[i] + b63 * ak3[i] + b64
        * ak4[i] + b65 * ak5[i]);
    ak6 := funcion(x1 + a6 * h, ytemp, n); // Sixth step.
    for i := 1 to n do
    begin // Accumulate increments with proper weights.
      yout[i] := y1[i] + h * (c1 * dy1[i] + c3 * ak3[i] + c4 * ak4[i] + c6
        * ak6[i]);
      yerr[i] := h * (dc1 * dy1[i] + dc3 * ak3[i] + dc4 * ak4[i] + dc5 * ak5[i]
        + dc6 * ak6[i]);
    end;
    // Estimate error as di.erence between fourth and .fth order methods.
    DelVector(ytemp);
    DelVector(ak6);
    DelVector(ak5);
    DelVector(ak4);
    DelVector(ak3);
    DelVector(ak2);
  end;

var
  i, n: integer;
  errmax, h, htemp, xnew: float;
  yerr, ytemp: TVector;
const
  SAFETY = 0.9;
  PGROW = -0.2;
  PSHRNK = -0.25;
  ERRCON = 1.89E-4; // exp((1/PGROW)*ln(5/SAFETY));
begin
  a2 := 0.2;
  a3 := 0.3;
  a4 := 0.6;
  a5 := 1.0;
  a6 := 0.875;
  b21 := 0.2;
  b31 := 3.0 / 40.0;
  b32 := 9.0 / 40.0;
  b41 := 0.3;
  b42 := -0.9;
  b43 := 1.2;
  b51 := -11.0 / 54.0;
  b52 := 2.5;
  b53 := -70.0 / 27.0;
  b54 := 35.0 / 27.0;
  b61 := 1631.0 / 55296.0;
  b62 := 175.0 / 512.0;
  b63 := 575.0 / 13824.0;
  b64 := 44275.0 / 110592.0;
  b65 := 253.0 / 4096.0;
  c1 := 37.0 / 378.0;
  c3 := 250.0 / 621.0;
  c4 := 125.0 / 594.0;
  c6 := 512.0 / 1771.0;
  dc5 := -277.00 / 14336.0;
  n := dim;
  h := htry; // Set stepsize to the initial trial value.
  repeat
    rkck(y1, dy1, n, funcion, x1, h, ytemp, yerr); // Take a step.
    errmax := 0.0; // Evaluate accuracy.
    for i := 1 to n do
      errmax := Max(errmax, abs(yerr[i] / yscal[i]));
    errmax := errmax / eps; // Scale relative to required tolerance.
    if (errmax <= 1.0) then
      break; // Step succeeded. Compute size of next step.
    htemp := SAFETY * h * power(errmax, PSHRNK);
    // Truncation error too large, reduce stepsize.
    if h >= 0.0 then
      h := Max(htemp, 0.1 * h)
    else
      h := Min(htemp, 0.1 * h);
    // No more than a factor of 10.
    xnew := x1 + h;
    if (xnew = x1) then
    begin
      result := y1;
      exit;
    end; // nrerror("stepsize underflow in rkqs");
  until false;
  if (errmax > ERRCON) then
    hnext := SAFETY * h * power(errmax, PGROW)
  else
    hnext := 5.0 * h; // No more than a factor of 5 increase.
  hdid := h;
  x1 := x1 + hdid;
  result := ytemp;
  DelVector(yerr);
end;

procedure RungeKuttaD(ystart: TVector; nvar: integer;
  x1, x2, eps, h1, hmin: float; funcion: TDerivs; var nok, nbad: integer;
  var dxsav: float; var xp: TVector; kmax: integer; var kount: integer;
  var yp: TMatrix);
var
  nstp, i: integer;
  xsav, hnext, hdid, h, xtemp: float;
  yscal, y1, dy1: TVector;
const
  MAXSTP = 10000;
  TINY = 1.0E-30;
begin
  DimVector(yscal, nvar);
  y1 := Clone(ystart, nvar);
  h := DSgn(h1, x2 - x1);
  xtemp := x1;
  nok := 0;
  nbad := 0;
  kount := 0;
  xsav := xtemp - dxsav * 2.0; // Assures storage of first step.
  for nstp := 1 to MAXSTP do
  begin // Take at most MAXSTP steps.
    dy1 := funcion(x1, y1, nvar);
    for i := 1 to nvar do
      // Scaling used to monitor accuracy. This general-purpose choice can be modi.ed if need be.
      yscal[i] := abs(y1[i]) + abs(dy1[i] * h) + TINY;
    if ((kmax > 0) and (kount < kmax - 1) and (abs(xtemp - xsav) > abs(dxsav)))
    then
    begin
      inc(kount);
      xp[kount] := xtemp; // Store intermediate results.
      for i := 1 to nvar do
        yp[i, kount] := y1[i];
      xsav := xtemp;
    end;
    if ((xtemp + h - x2) * (xtemp + h - x1) > 0.0) then
      h := x2 - xtemp; // If stepsize can overshoot, decrease.
    y1 := RK5D(y1, dy1, yscal, nvar, funcion, xtemp, hdid, hnext, h, eps);
    if (hdid = h) then
      inc(nok)
    else
      inc(nbad);
    if ((xtemp - x2) * (x2 - x1) >= 0.0) then
    begin // Are we done?
      if not(kmax = 0) then
      begin
        inc(kount);
        xp[kount] := xtemp; // Save final step.
        for i := 1 to nvar do
          yp[i, kount] := y1[i];
      end;
      DelVector(dy1);
      DelVector(yscal);
      DelVector(y1);
      exit; // Normal exit.
    end;
    if (abs(hnext) <= hmin) then
    begin
      RungeKuttaD(ystart, nvar, x1, x2, eps, h1 * 2, hmin, funcion, nok, nbad,
        dxsav, xp, kmax, kount, yp);
      exit; // nrerror("Step size too small in odeint");
    end;
    h := hnext;
  end;
  DelVector(dy1);
  DelVector(y1);
  DelVector(yscal);
  // nrerror("Too many steps in routine odeint");
end;

function mmid(y, dydx: TVector; nvar: integer; xs, htot: float;
  nstep: integer): TVector;
var
  yout, ym, yn: TVector;
  n, i: integer;
  x, swap, h2, h: float;
begin
  DimVector(ym, nvar);
  DimVector(yn, nvar);
  h := htot / nstep; // Stepsize this trip.
  for i := 1 to nvar do
  begin
    ym[i] := y[i];
    yn[i] := y[i] + h * dydx[i]; // First step.
  end;
  x := xs + h;
  DimVector(yout, nvar);
  PFuncion.x := x;
  for i := 1 to nvar do
  begin
    PFuncion.y := yn[i];
    yout[i] := PFuncion.Value;
    // Will use yout for temporary storage of derivatives.
  end;
  h2 := 2.0 * h;
  for n := 2 to nstep do
  begin // General step.
    for i := 1 to nvar do
    begin
      swap := ym[i] + h2 * yout[i];
      ym[i] := yn[i];
      yn[i] := swap;
    end;
    x := x + h;
    PFuncion.x := x;
    for i := 1 to nvar do
    begin
      PFuncion.y := yn[i];
      yout[i] := PFuncion.Value;
    end;
  end;
  for i := 1 to nvar do // Last step.
    yout[i] := 0.5 * (ym[i] + yn[i] + h * yout[i]);
  result := yout;
  DelVector(ym);
  DelVector(yn);
end;

procedure pzextr(iest: integer; xest: float; yest: TVector; nv: integer;
  out yz, dy: TVector; var x: TVector; var d: TMatrix);
var
  k1, i, j: integer;
  q, f2, f1, delta: float;
  c: TVector;
begin
  x[iest] := xest; // Save current independent variable.
  dy := Clone(yest, nv);
  yz := Clone(yest, nv);
  if (iest = 1) then // Store first estimate in first column.
    for i := 1 to nv do
      d[i, 1] := yest[i]
  else
  begin
    c := Clone(yest, nv);
    for k1 := 1 to iest - 1 do
    begin
      delta := 1.0 / (x[iest - k1] - xest);
      f1 := xest * delta;
      f2 := x[iest - k1] * delta;
      for j := 1 to nv do
      begin // Propagate tableau 1 diagonal more.
        q := d[j, k1];
        d[j, k1] := dy[j];
        delta := c[j] - q;
        dy[j] := f1 * delta;
        c[j] := f2 * delta;
        yz[j] := yz[j] + dy[j];
      end;
    end;
    for i := 1 to nv do
      d[i, iest] := dy[i];
    DelVector(c);
  end;
end;

const
  KMAXX = 8; // Maximum row number used in the extrapolation.
  IMAXX = (KMAXX + 1);
  SAFE1 = 0.25; // Safety factors.
  SAFE2 = 0.7;
  REDMAX = 1.0E-5; // Maximum factor for stepsize reduction.
  REDMIN = 0.7; // Minimum factor for stepsize reduction.
  TINY = 1.0E-30; // Prevents division by zero.
  SCALMX = 0.1;
  // 1/SCALMX is the maximum factor by which a stepsize can be increased.

var
  first: integer = 1;
  kmax, kopt: integer;
  epsold: float = -1;
  xnew: float;
  a: array [0 .. IMAXX] of float;
  alf: array [0 .. KMAXX, 0 .. KMAXX] of float;
  nseq: array [0 .. IMAXX] of integer = (
    0,
    2,
    4,
    6,
    8,
    10,
    12,
    14,
    16,
    18
  );

procedure BS5(var y: TVector; dim: integer; dydx, yscal: TVector;
  htry, eps: float; var xx, hdid, hnext: float);
var
  x: TVector;
  d: TMatrix;
  i, iq, k, kk, km, nv, kopt1: integer;
  eps1, errmax, fact, h, red, scale, work, wrkmin, xest: float;
  err, yerr, ysav, yseq: TVector;
  reduct, exitflag: integer;
begin
  exitflag := 0;
  nv := dim;
  errmax := TINY;
  km := 0;
  red := REDMAX;
  DimMatrix(d, nv, KMAXX);
  DimVector(err, KMAXX);
  DimVector(x, KMAXX);
  DimVector(yerr, nv);
  DimVector(ysav, nv);
  DimVector(yseq, nv);
  if (eps <> epsold) then
  begin // A new tolerance, so reinitialize.
    hnext := -1.0E29;
    xnew := -1.0E29; // “Impossible” values.
    eps1 := SAFE1 * eps;
    a[1] := nseq[1] + 1; // Compute work coe.cients Ak.
    for k := 1 to KMAXX do
      a[k + 1] := a[k] + nseq[k + 1];
    for iq := 2 to KMAXX do
    begin // Compute a(k, q).
      for k := 1 to iq - 1 do
        alf[k, iq] := power(eps1, (a[k + 1] - a[iq + 1]) /
          ((a[iq + 1] - a[1] + 1.0) * (2 * k + 1)));
    end;
    epsold := eps;
    for kopt1 := 2 to KMAXX - 1 do
      // Determine optimal row number for convergence.
      if (a[kopt1 + 1] > a[kopt1] * alf[kopt1 - 1][kopt1]) then
      begin
        kopt := kopt1;
        break;
      end;
    kmax := kopt1;
  end;
  h := htry;
  for i := 1 to nv do
    ysav[i] := y[i]; // Save the starting values.
  if ((xx <> xnew) or (h <> hnext)) then
  begin // A new stepsize or a new integration: re-establish the order window.
    first := 1;
    kopt := kmax;
  end;
  reduct := 0;
  repeat
    for k := 1 to kmax do
    begin // Evaluate the sequence of modi.ed midpoint integrations.
      xnew := xx + h;
      if (xnew = xx) then
      begin
        exit
      end; // nrerror("step size underflow in bsstep");
      yseq := mmid(ysav, dydx, dim, xx, h, nseq[k]);
      xest := SQR(h / nseq[k]); // Squared, since error series is even.
      pzextr(k, xest, yseq, dim, y, yerr, x, d); // Perform extrapolation.
      if (k <> 1) then
      begin // Compute normalized error estimate (k).
        errmax := TINY;
        for i := 1 to nv do
          errmax := Max(errmax, abs(yerr[i] / yscal[i]));
        errmax := errmax / eps; // Scale error relative to tolerance.
        km := k - 1;
        err[km] := power(errmax / SAFE1, 1.0 / (2 * km + 1));
      end;
      if ((k <> 1) and ((k >= kopt - 1) or not(first = 0))) then
      begin // In order window.
        if (errmax < 1.0) then
        begin // Converged.
          exitflag := 1;
          break;
        end;
        if ((k = kmax) or (k = kopt + 1)) then
        begin // Check for possible stepsize reduction.
          red := SAFE2 / err[km];
          break;
        end
        else if ((k = kopt) and (alf[kopt - 1][kopt] < err[km])) then
        begin
          red := 1.0 / err[km];
          break;
        end
        else if ((kopt = kmax) and (alf[km][kmax - 1] < err[km])) then
        begin
          red := alf[km][kmax - 1] * SAFE2 / err[km];
          break;
        end
        else if (alf[km][kopt] < err[km]) then
        begin
          red := alf[km][kopt - 1] / err[km];
          break;
        end;
      end;
    end;
    if not(exitflag = 0) then
      break;
    red := Min(red, REDMIN);
    // Reduce stepsize by at least REDMIN and at most REDMAX.
    red := Max(red, REDMAX);
    h := h * red;
    reduct := 1;
  until false; // Try again.
  xx := xnew; // Successful step taken.
  hdid := h;
  first := 0;
  wrkmin := 1.0E35;
  // Compute optimal row for convergence and corresponding stepsize.
  for kk := 1 to km do
  begin
    fact := Max(err[kk], SCALMX);
    work := fact * a[kk + 1];
    if (work < wrkmin) then
    begin
      scale := fact;
      wrkmin := work;
      kopt := kk + 1;
    end;
  end;
  hnext := h / scale;
  if ((kopt >= k) and (kopt <> kmax) and (reduct = 0)) then
  begin
    // Check for possible order increase, but not if stepsize was just reduced.
    fact := Max(scale / alf[kopt - 1, kopt], SCALMX);
    if (a[kopt + 1] * fact <= wrkmin) then
    begin
      hnext := h / fact;
      inc(kopt);
    end;
  end;
  DelVector(yseq);
  DelVector(ysav);
  DelVector(yerr);
  DelVector(err);
  DelVector(x);
  DelMatrix(d);
end;

procedure BulirschStoer(ystart: TVector; nvar: integer;
  x1, x2, eps, h1, hmin: float; funcion: TStrVector; var nok, nbad: integer;
  var dxsav: float; var xp: TVector; kmax: integer; var kount: integer;
  var yp: TMatrix);
var
  nstp, i: integer;
  xsav, hnext, hdid, h, dy1t, xh: float;
  yscal, y1, dy1: TVector;
const
  MAXSTP = 10000;
  TINY = 1.0E-30;
begin
  // PFuncion.Expression:=funcion;
  DimVector(yscal, nvar);
  y1 := Clone(ystart, nvar);
  DimVector(dy1, nvar);
  h := DSgn(h1, x2 - x1);
  xh := x1;
  nok := 0;
  nbad := 0;
  kount := 0;
  xsav := xh - dxsav * 2.0; // Assures storage of first step.
  for nstp := 1 to MAXSTP do
  begin // Take at most MAXSTP steps.
    for i := 1 to nvar do
    begin
      PFuncion.Expression := funcion[i];
      PFuncion.x := xh;
      PFuncion.y := y1[i];
      dy1t := PFuncion.Value;
      dy1[i] := dy1t;
    end;
    for i := 1 to nvar do
      // Scaling used to monitor accuracy. This general-purpose choice can be modi.ed if need be.
      yscal[i] := abs(y1[i]) + abs(dy1[i] * h) + TINY;
    if ((kmax > 0) and (kount < kmax - 1) and
      (abs(PFuncion.x - xsav) > abs(dxsav))) then
    begin
      inc(kount);
      xp[kount] := xh; // Store intermediate results.
      for i := 1 to nvar do
        yp[i, kount] := y1[i];
      xsav := xh;
    end;
    if ((xh + h - x2) * (xh + h - x1) > 0.0) then
      h := x2 - xh; // If stepsize can overshoot, decrease.
    for i := 1 to nvar do
    begin
      PFuncion.Expression := funcion[i];
      BS5(y1, nvar, dy1, yscal, h, eps, xh, hdid, hnext);
    end;
    if (hdid = h) then
      inc(nok)
    else
      inc(nbad);
    if ((xh - x2) * (x2 - x1) >= 0.0) then
    begin // Are we done?
      if not(kmax = 0) then
      begin
        inc(kount);
        xp[kount] := xh; // Save final step.
        for i := 1 to nvar do
          yp[i, kount] := y1[i];
      end;
      DelVector(dy1);
      DelVector(y1);
      DelVector(yscal);
      exit; // Normal exit.
    end;
    if (abs(hnext) <= hmin) then
    begin
      BulirschStoer(ystart, nvar, x1, x2, eps, 2 * h1, hmin, funcion, nok, nbad,
        dxsav, xp, kmax, kount, yp);
      exit; // nrerror("Step size too small in odeint");
    end;
    h := hnext;
  end;
  DelVector(dy1);
  DelVector(y1);
  DelVector(yscal);
  // nrerror("Too many steps in routine odeint");
end;

initialization

PFuncion := TParser.Create(nil);

Finalization

PFuncion.Free;

end.
