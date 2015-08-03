{ ******************************************************************
  Probability functions related to the incomplete Gamma function
  ****************************************************************** }

unit uigmdist;

interface

uses
  uConstants, ugamma, uigamma;

function FGamma(A, B, X: Float): Float;
{ Cumulative probability for Gamma distrib. with param. A and B }

function FPoisson(Mu: Float; K: Integer): Float;
{ Cumulative probability for Poisson distrib. }

function FNorm(X: Float): Float;
{ Cumulative probability for standard normal distrib. }

function PNorm(X: Float): Float;
{ Prob(|U| > X) for standard normal distrib. }

function DNorm(X: Float): Float;
{ Density of standard normal distribution }

function FKhi2(Nu: Integer; X: Float): Float;
{ Cumulative prob. for khi-2 distrib. with Nu d.o.f. }

function PKhi2(Nu: Integer; X: Float): Float;
{ Prob(Khi2 > X) for khi-2 distrib. with Nu d.o.f. }

function Normal_Distribution(X, xmed, xvar: Float): Float;
function Poisson_Distribution(X, N: Float): Float;
function Cauchy_Distribution(X, mean, HalfWidth: Float): Float;
function Cauchy_CumDist(X, mean, HalfWidth: Float): Float;
function Pareto_Distribution(X, A, B: Float): Float;
function Pareto_CumDist(X, A, B: Float): Float;
function Rayleigh_Distribution(X, mean, Sigma: Float): Float;
function Rayleigh_CumDist(X, mean, Sigma: Float): Float;
function Landau_Distribution(X, Peak, Width: Float): Float;

implementation

uses Math, utrigo, utypes;

function FGamma(A, B, X: Float): Float;
begin
  FGamma := IGamma(A, B * X);
end;

function FPoisson(Mu: Float; K: Integer): Float;
begin
  if (Mu <= 0.0) or (K < 0) then
    FPoisson := DefaultVal(FDomain, 0.0)
  else if K = 0 then
    if (-Mu) < MinLog then
      FPoisson := DefaultVal(FUnderflow, 0.0)
    else
      FPoisson := DefaultVal(FOk, Exp(-Mu))
  else
    FPoisson := 1.0 - IGamma(K + 1, Mu);
end;

function FNorm(X: Float): Float;
begin
  FNorm := 0.5 * (1.0 + Erf(X * Sqrt2div2));
end;

function PNorm(X: Float): Float;
var
  A: Float;
begin
  A := Abs(X);
  if A = 0.0 then
    PNorm := DefaultVal(FOk, 1.0)
  else if A < 1.0 then
    PNorm := 1.0 - Erf(A * Sqrt2div2)
  else
    PNorm := Erfc(A * Sqrt2div2);
end;

function DNorm(X: Float): Float;
var
  Y: Float;
begin
  Y := -0.5 * X * X;
  if Y < MinLog then
    DNorm := DefaultVal(FUnderflow, 0.0)
  else
  begin
    SetErrCode(FOk);
    DNorm := InvSqrt2Pi * Exp(Y);
  end;
end;

function FKhi2(Nu: Integer; X: Float): Float;
begin
  if (Nu < 1) or (X <= 0) then
    FKhi2 := DefaultVal(FDomain, 0.0)
  else
    FKhi2 := IGamma(0.5 * Nu, 0.5 * X);
end;

function PKhi2(Nu: Integer; X: Float): Float;
begin
  if (Nu < 1) or (X <= 0) then
    PKhi2 := DefaultVal(FDomain, 0.0)
  else
    PKhi2 := 1.0 - IGamma(0.5 * Nu, 0.5 * X);
end;

function Normal_Distribution(X, xmed, xvar: Float): Float;
begin
  result := DNorm((X - xmed) / xvar);
end;

function Poisson_Distribution(X, N: Float): Float;
begin
  if (X <= 0) then
    result := 0
  else
    result := Exp(N * ln(X) - X - LnGamma(N + 1));
end;

function Cauchy_Distribution(X, mean, HalfWidth: Float): Float;
begin
  result := (HalfWidth / (2 * pi)) / (sqr(X - mean) + sqr(HalfWidth / 2));
end;

function Cauchy_CumDist(X, mean, HalfWidth: Float): Float;
var
  FWHMdiv2: Float;
begin
  FWHMdiv2 := HalfWidth / 2;
  result := (1 / pi) * ArcSinh((X - mean / sqr(FWHMdiv2)) * Pythag(FWHMdiv2,
    mean) + (mean / sqr(FWHMdiv2)) * Pythag(FWHMdiv2, X - mean));
end;

function Pareto_Distribution(X, A, B: Float): Float;
begin
  if (X = 0) then
    result := DefaultVal(FOverflow, MaxNum)
  else if (X = B) or (B = 0) then
    result := A / X
  else if A > maxlog / ln(Abs(B / X)) then
    result := DefaultVal(FOverflow, MaxNum)
  else
    result := Power(B / X, A) * A / X
end;

function Pareto_CumDist(X, A, B: Float): Float;
begin
  if X = 0 then
    result := DefaultVal(FOverflow, MaxNum)
  else if A > maxlog / ln(Abs(1 - B / X)) then
    result := DefaultVal(FOverflow, MaxNum)
  else
    result := Power(1 - B / X, A)
end;

function Rayleigh_Distribution(X, mean, Sigma: Float): Float;
var
  t: Float;
begin
  t := (X - mean) / Sigma;
  result := t * Exp(-sqr(t) / 2);
end;

function Rayleigh_CumDist(X, mean, Sigma: Float): Float;
var
  t: Float;
begin
  t := (X - mean) / Sigma;
  result := 1 - Exp(-sqr(t) / 2);
end;

function Landau_Distribution(X, Peak, Width: Float): Float;
  function DLandau(lx: Float): Float;
  const
    p1: array [0 .. 4] of Float = (0.4259894875, -0.124976255, 0.039842437,
      -0.006298287635, 0.001511162253);
    q5: array [0 .. 4] of Float = (1.0, 156.9424537, 3745.310488, 9834.698876,
      66924.28357);
    p6: array [0 .. 4] of Float = (1.000827619, 664.9143136, 62972.92665,
      475554.6998, -5743609.109);
    q6: array [0 .. 4] of Float = (1.0, 651.4101098, 56974.73333, 165917.4725,
      -2815759.939);
    a1: array [0 .. 2] of Float = (0.04166666667, -0.001996527778,
      0.02709538966);
    a2: array [0 .. 1] of Float = (-1.84556867, -4.284640743);
    q1: array [0 .. 4] of Float = (1.0, -0.3388260629, 0.09594393323,
      -0.01608042283, 0.003778942063);
    p2: array [0 .. 4] of Float = (0.1788541609, 0.1173957403, 0.01488850518,
      -0.001394989411, 1.283617211E-4);
    q2: array [0 .. 4] of Float = (1.0, 0.7428795082, 0.3153932961,
      0.06694219548, 0.008790609714);
    p3: array [0 .. 4] of Float = (0.1788544503, 0.09359161662, 0.006325387654,
      6.611667319E-5, -2.031049101E-6);
    q3: array [0 .. 4] of Float = (1.0, 0.6097809921, 0.2560616665,
      0.04746722384, 0.006957301675);
    p4: array [0 .. 4] of Float = (0.9874054407, 118.6723273, 849.279436,
      -743.7792444, 427.0262186);
    q4: array [0 .. 4] of Float = (1.0, 106.8615961, 337.6496214, 2016.712389,
      1597.063511);
    p5: array [0 .. 4] of Float = (1.003675074, 167.5702434, 4789.711289,
      21217.86767, -22324.9491);
  var
    // * System generated locals */
    ret_val, r__1: Float;

    // * Local variables */
    u, v: Float;
  begin
    v := lx;
    if (v < -5.5) then
    begin
      u := Exp(v + 1.0);
      ret_val := Exp(-1 / u) / sqrt(u) * 0.3989422803 *
        ((a1[0] + (a1[1] + a1[2] * u) * u) * u + 1);
    end
    else if (v < -1.0) then
    begin
      u := Exp(-v - 1);
      ret_val := Exp(-u) * sqrt(u) *
        (p1[0] + (p1[1] + (p1[2] + (p1[3] + p1[4] * v) * v) * v) * v) /
        (q1[0] + (q1[1] + (q1[2] + (q1[3] + q1[4] * v) * v) * v) * v);
    end
    else if (v < 1.0) then
    begin
      ret_val := (p2[0] + (p2[1] + (p2[2] + (p2[3] + p2[4] * v) * v) * v) * v) /
        (q2[0] + (q2[1] + (q2[2] + (q2[3] + q2[4] * v) * v) * v) * v);
    end
    else if (v < 5.0) then
    begin
      ret_val := (p3[0] + (p3[1] + (p3[2] + (p3[3] + p3[4] * v) * v) * v) * v) /
        (q3[0] + (q3[1] + (q3[2] + (q3[3] + q3[4] * v) * v) * v) * v);
    end
    else if (v < 12.0) then
    begin
      u := 1 / v;
      // * Computing 2nd power */
      r__1 := u;
      ret_val := r__1 * r__1 *
        (p4[0] + (p4[1] + (p4[2] + (p4[3] + p4[4] * u) * u) * u) * u) /
        (q4[0] + (q4[1] + (q4[2] + (q4[3] + q4[4] * u) * u) * u) * u);
    end
    else if (v < 50.0) then
    begin
      u := 1 / v;
      // * Computing 2nd power */
      r__1 := u;
      ret_val := r__1 * r__1 *
        (p5[0] + (p5[1] + (p5[2] + (p5[3] + p5[4] * u) * u) * u) * u) /
        (q5[0] + (q5[1] + (q5[2] + (q5[3] + q5[4] * u) * u) * u) * u);
    end
    else if (v < 300.0) then
    begin
      u := 1 / v;
      // * Computing 2nd power */
      r__1 := u;
      ret_val := r__1 * r__1 *
        (p6[0] + (p6[1] + (p6[2] + (p6[3] + p6[4] * u) * u) * u) * u) /
        (q6[0] + (q6[1] + (q6[2] + (q6[3] + q6[4] * u) * u) * u) * u);
    end
    else
    begin
      u := 1 / (v - v * ln(v) / (v + 1));
      // * Computing 2nd power */
      r__1 := u;
      ret_val := r__1 * r__1 * ((a2[0] + a2[1] * u) * u + 1);
    end;
    result := ret_val;
  end;

var
  t: Float;
begin
  t := Peak + 0.222782 * Width;
  result := DLandau((X - t) / Width) / Width;
end;

end.
