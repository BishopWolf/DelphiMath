{ ******************************************************************
  This unit fits the Hill equation :

  Ymax . x^n
  y = ----------
  K^n + x^n

  ****************************************************************** }

unit uhillfit;

interface

uses
  utypes, uConstants;

procedure HillFit(X, Y: TVector; Lb, Ub: Integer; MaxIter: Integer; Tol: Float;
  var B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Unweighted fit of model
  ------------------------------------------------------------------
  Input parameters:  X, Y    = point coordinates
  Lb, Ub  = array bounds
  MaxIter = max. number of iterations
  Tol     = tolerance on parameters
  Output parameters: B       = regression parameters
  V       = inverse matrix
  ------------------------------------------------------------------ }

procedure WHillFit(X, Y, S: TVector; Lb, Ub: Integer; MaxIter: Integer;
  Tol: Float; var B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted fit of model
  ------------------------------------------------------------------
  Additional input parameter:
  S = standard deviations of observations
  ------------------------------------------------------------------ }

function HillFit_Func(X: Float; B: TVector): Float;
{ ------------------------------------------------------------------
  Returns the value of the regression function at point X
  ------------------------------------------------------------------ }

implementation

uses umath, umeansd, ulinfit, unlfit, uminmax;

const
  FirstParam = 1;
  LastParam = 3;

function HillFit_Func(X: Float; B: TVector): Float;
{ ------------------------------------------------------------------
  Computes the regression function at point X
  B is the vector of parameters, such that :

  B[1] = Ymax     B[2] = K     B[3] = n
  ------------------------------------------------------------------ }
begin
  if X = 0.0 then
    if B[3] > 0.0 then
      HillFit_Func := 0.0
    else
      HillFit_Func := B[1]
  else
    { Compute function according to y = Ymax / [1 + (K/x)^n] }
    HillFit_Func := B[1] / (1.0 + Power(B[2] / X, B[3]));
end;

procedure HillFit_Deriv(X, Y: Float; B: TVector; out D: TVector);
{ ------------------------------------------------------------------
  Computes the derivatives of the regression function at point (X,Y)
  with respect to the parameters B. The results are returned in D.
  D[I] contains the derivative with respect to the I-th parameter
  ------------------------------------------------------------------ }
var
  Q, R, S: Float;
begin
  DimVector(D, 3);
  if X = 0.0 then
  begin
    if B[3] > 0.0 then
      D[1] := 0.0
    else
      D[1] := 1.0;
    D[2] := 0.0;
    D[3] := 0.0;
  end
  else
  begin
    Q := Power(B[1] / X, B[3]); { (K/x)^n }
    R := 1.0 / (1.0 + Q); { 1 / [1 + (K/x)^n] }
    S := -Y * R * Q; { -Ymax.(K/x)^n / [1 + (K/x)^n]^2 }

    { dy/dYmax = 1 / [1 + (K/x)^n] }
    D[1] := R;

    { dy/dK = -Ymax.(K/x)^n.(n/K)/[1 + (K/x)^n]^2 }
    D[2] := S * B[3] / B[2];

    { dy/dn = -Ymax.(K/x)^n.Ln(K/x)/[1 + (K/x)^n]^2 }
    D[3] := S * Log(B[2] / X);
  end;
end;

procedure ApproxFit(Mode: TRegMode; X, Y, S: TVector; Lb, Ub: Integer;
  out B: TVector);
{ ------------------------------------------------------------------
  Approximate fit of the Hill equation by linear regression:
  Ln(Ymax/y - 1) = n.Ln(K) - n.Ln(x)
  ------------------------------------------------------------------
  Input :  Mode   = OLS for unweighted regression, WLS for weighted
  X, Y   = point coordinates
  S      = standard deviations of Y values
  Lb, Ub = array bounds
  Output : B      = estimated regression parameters
  ------------------------------------------------------------------ }
var
  Ymax: Float; { Estimated value of Ymax }
  X1, Y1: TVector; { Transformed coordinates }
  S1: TVector; { Standard dev. of transformed Y values }
  A: TVector; { Linear regression parameters }
  V: TMatrix; { Variance-covariance matrix }
  P: Integer; { Number of points for linear regression }
  K: Integer; { Loop variable }
  Pos: Integer; { variable needed }
begin
  DimVector(X1, Ub);
  DimVector(Y1, Ub);
  DimVector(S1, Ub);

  P := Pred(Lb);
  Ymax := Max(Y, 1, Ub, Pos);
  for K := Lb to Ub do
    if (X[K] > 0.0) and (Y[K] > 0.0) and (Y[K] < Ymax) then
    begin
      Inc(P);
      X1[P] := Log(X[K]);
      Y1[P] := Log(Ymax / Y[K] - 1.0);
      S1[P] := 1.0 / (Y[K] * (1.0 - Y[K] / Ymax));
      if Mode = WLS then
        S1[P] := S1[P] * S[K];
    end;

  WLinFit(X1, Y1, S1, Lb, P, A, V);
  DimVector(B, LastParam);
  if MathErr = MatOk then
  begin
    B[1] := Ymax;
    B[2] := Expo(-A[1] / A[2]);
    B[3] := -A[2];
  end;

  DelVector(X1);
  DelVector(Y1);
  DelVector(S1);
  DelVector(A);
  DelMatrix(V);
end;

procedure GenHillFit(Mode: TRegMode; X, Y, S: TVector; Lb, Ub: Integer;
  MaxIter: Integer; Tol: Float; var B: TVector; out V: TMatrix);
begin
  if (GetOptAlgo in [NL_MARQ, NL_BFGS, NL_SIMP]) and
    NullParam(B, FirstParam, LastParam) then
    ApproxFit(Mode, X, Y, S, Lb, Ub, B);

  if MaxIter = 0 then
    Exit;

  case Mode of
    OLS:
      NLFit(HillFit_Func, HillFit_Deriv, X, Y, Lb, Ub, MaxIter, Tol, B,
        FirstParam, LastParam, V);
    WLS:
      WNLFit(HillFit_Func, HillFit_Deriv, X, Y, S, Lb, Ub, MaxIter, Tol, B,
        FirstParam, LastParam, V);
  end;
end;

procedure HillFit(X, Y: TVector; Lb, Ub: Integer; MaxIter: Integer; Tol: Float;
  var B: TVector; out V: TMatrix);
begin
  GenHillFit(OLS, X, Y, nil, Lb, Ub, MaxIter, Tol, B, V);
end;

procedure WHillFit(X, Y, S: TVector; Lb, Ub: Integer; MaxIter: Integer;
  Tol: Float; var B: TVector; out V: TMatrix);
begin
  GenHillFit(WLS, X, Y, S, Lb, Ub, MaxIter, Tol, B, V);
end;

end.
