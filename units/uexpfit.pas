{ ******************************************************************
  This unit fits a sum of decreasing exponentials:
  y = Ymin + A1.exp(-a1.x) + A2.exp(-a2.x) + A3.exp(-a3.x) + ...
  ****************************************************************** }

unit uexpfit;

interface

uses
  utypes, umath, uqsort, umulfit, unlfit, umachar,
  urtpol1, urtpol2, urtpol3, urtpol4, urootpol, uConstants;

procedure ExpFit(X, Y: TVector; Lb, Ub, Nexp: Integer; ConsTerm: Boolean;
  MaxIter: Integer; Tol: Float; var B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Unweighted fit of sum of exponentials
  ------------------------------------------------------------------
  Input parameters:  X, Y     = point coordinates
  Lb, Ub   = array bounds
  Nexp     = number of exponentials
  ConsTerm = presence of constant term B(0)
  MaxIter  = max. number of iterations
  Tol      = tolerance on parameters
  Output parameters: B        = regression parameters
  V        = inverse matrix
  ------------------------------------------------------------------ }

procedure WExpFit(X, Y, S: TVector; Lb, Ub, Nexp: Integer; ConsTerm: Boolean;
  MaxIter: Integer; Tol: Float; var B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted fit of sum of exponentials
  ------------------------------------------------------------------
  Additional input parameter:
  S = standard deviations of observations
  ------------------------------------------------------------------ }

function ExpFit_Func(X: Float; B: TVector): Float;
{ ------------------------------------------------------------------
  Returns the value of the regression function at point X
  ------------------------------------------------------------------ }

implementation

var
  gNexp: Integer;
  gConsTerm: Boolean;

function FirstParam: Integer;
{ ------------------------------------------------------------------
  Returns the index of the first parameter to be fitted
  ------------------------------------------------------------------ }
begin
  if gConsTerm then
    FirstParam := 1
  else
    FirstParam := 2;
end;

function LastParam: Integer;
{ ------------------------------------------------------------------
  Returns the index of the last parameter to be fitted
  ------------------------------------------------------------------ }
begin
  LastParam := 2 * gNexp + 1
end;

function ExpFit_Func(X: Float; B: TVector): Float;
{ ------------------------------------------------------------------
  The function is of the form:

  y = Ymin + A1.exp(-a1.x) + A2.exp(-a2.x) + A3.exp(-a3.x) + ...

  with:

  B[1] = Ymin
  B[2] = A1         B[3] = a1
  ...............................
  B[2*i] = Ai     B[2*i+1] = ai     i = 1..N_exp
  -------------------------------------------------------------------- }
var
  I: Integer;
  S: Float;
begin
  if gConsTerm then
    S := B[1]
  else
    S := 0.0;
  for I := 1 to gNexp do
    S := S + B[2 * I] * Expo(-B[2 * I + 1] * X);
  ExpFit_Func := S;
end;

procedure ExpFit_Deriv(X, Y: Float; B: TVector; out D: TVector);
{ --------------------------------------------------------------------
  Computes the derivatives of the regression function at point (X, Y)
  with respect to the parameters B. The results are returned in D.
  D[I] contains the derivative with respect to the I-th parameter.
  -------------------------------------------------------------------- }
var
  I, P, Q: Integer;
  E: Float;
begin
  DimVector(D, 2 * gNexp + 1);
  D[1] := 1.0; { dy/dYmin = 1 }
  for I := 1 to gNexp do
  begin
    Q := 2 * I + 1;
    P := Pred(Q);
    E := Expo(-B[Q] * X);
    D[P] := E; { dy/dAi = exp(-ai.x) }
    D[Q] := -X * B[P] * E; { dy/dai = -x.Ai.exp(-ai.x) }
  end;
end;

procedure ApproxFit(Mode: TRegMode; X, Y, S: TVector; Lb, Ub: Integer;
  out B: TVector);
{ --------------------------------------------------------------------
  Approximate fit of a sum of exponentials by linear regression
  --------------------------------------------------------------------
  Input :  Mode   = OLS or WLS
  X, Y   = point coordinates
  S      = standard deviations of Y
  Lb, Ub = array bounds
  Output : B      = estimated regression parameters, must be initialized
  --------------------------------------------------------------------
  Ref. : R. GOMENI & C. GOMENI, Automod : A polyalgorithm for an
  integrated analysis of linear pharmacokinetic models
  Comput. Biol. Med., 1979, 9, 39-48
  -------------------------------------------------------------------- }

var
  I, K, M: Integer;
  Km1: Integer;
  X1, Y1: TVector; { Modified coordinates }
  Ymin: Float; { Minimum of vector Y1 }
  U: TMatrix; { Variables for linear regression }
  P: TVector; { Linear regression parameters }
  C: TVector; { Coefficients of polynomial }
  Z: TCompVector; { Roots of polynomial }
  Nr: Integer; { Number of real roots }
  Alpha: TVector; { Real roots }
  V: TMatrix; { Variance-covariance matrix }
  H: Float; { Integration step }

begin
  M := Pred(2 * gNexp);

  DimVector(X1, Ub);
  DimVector(Y1, Ub);
  DimMatrix(U, Ub, M);
  DimVector(C, gNexp);
  DimVector(Z, gNexp, 0);
  DimVector(Alpha, gNexp);

  DimVector(B, LastParam);

  for K := Lb to Ub do
  begin
    X1[K] := X[K];
    Y1[K] := Y[K];
  end;

  { Change scale so that the X's begin at zero }
  if X[Lb] <> 0.0 then
    for K := Lb to Ub do
      X1[K] := X1[K] - X[Lb];

  { Estimate the constant term at 90% of the lowest observed value,
    then subtract it from each Y value }
  if gConsTerm then
  begin
    Ymin := Y1[Lb];
    for K := Succ(Lb) to Ub do
      if Y1[K] < Ymin then
        Ymin := Y1[K];
    B[1] := 0.9 * Ymin;
    for K := Lb to Ub do
      Y1[K] := Y1[K] - B[1];
  end;

  { ------------------------------------------------------------------
    Fit the linearized form of the function :

    y = p(1) + p(2) * x + p(3) * x^2 + ... + p(Nexp) * x^(Nexp-1)

    (x                       (x    (x
    + p(Nexp+1) | y dx + ... + p(2*Nexp) | ....| y dx
    )0                       )0    )0
    ------------------------------------------------------------------ }

  { Compute increasing powers of X }
  if gNexp > 1 then
    for K := Succ(Lb) to Ub do
    begin
      U[K, 1] := X1[K];
      for I := 2 to Pred(gNexp) do
        U[K, I] := U[K, I - 1] * X1[K];
    end;

  { Compute integrals by the trapezoidal rule }
  for K := Succ(Lb) to Ub do
  begin
    Km1 := K - 1;
    H := 0.5 * (X1[K] - X1[Km1]);
    U[K, gNexp] := U[Km1, gNexp] + (Y1[K] + Y1[Km1]) * H;
    for I := Succ(gNexp) to M do
      U[K, I] := U[Km1, I] + (U[K, I - 1] + U[Km1, I - 1]) * H;
  end;

  { Fit the equation }
  case Mode of
    OLS:
      MulFit(U, Y1, Lb, Ub, M, True, P, V);
    WLS:
      WMulFit(U, Y1, S, Lb, Ub, M, True, P, V);
  end;

  if MathErr = MatOk then
  begin
    { ----------------------------------------------------------------
      The exponents are the roots of the polynomial :
      x^Nexp + p(Nexp+1) * x^(Nexp-1) - p(Nexp+2) * x^(Nexp-2) +...
      ---------------------------------------------------------------- }

    { Compute polynomial coefficients }
    C[gNexp] := 1.0;
    for I := 1 to gNexp do
      if Odd(I) then
        C[gNexp - I + 1] := P[gNexp + I]
      else
        C[gNexp - I + 1] := -P[gNexp + I];

    { Solve polynomial }
    case gNexp of
      1:
        Nr := RootPol1(C[1], C[2], Z[1].Real);
      2:
        Nr := RootPol2(C, Z);
      3:
        Nr := RootPol3(C, Z);
      4:
        Nr := RootPol4(C, Z);
    else
      Nr := RootPol(C, gNexp, Z);
    end;

    if Nr <> gNexp then
      SetErrCode(MatNonConv)
    else
    begin
      { Get exponents and sort them in decreasing order }
      for I := 1 to gNexp do
        Alpha[I] := Z[I].Real;
      DQSort(Alpha, 1, gNexp);

      { Compute the coefficients of the exponentials by
        linear regression on the exponential terms }
      for K := Lb to Ub do
        for I := 1 to gNexp do
          U[K, I] := Expo(-Alpha[I] * X1[K]);

      case Mode of
        OLS:
          MulFit(U, Y1, Lb, Ub, gNexp - 1, False, P, V);
        WLS:
          WMulFit(U, Y1, S, Lb, Ub, gNexp - 1, False, P, V);
      end;

      if MathErr = MatOk then { Extract model parameters }
        for I := 1 to gNexp do
        begin
          { Correct for scale change if necessary }
          if X[1] <> 0.0 then
            P[I] := P[I] * Expo(Alpha[I] * X[1]);

          { Extract coefficients and exponents }
          B[2 * I] := P[I]; { Coefficients }
          B[2 * I + 1] := Alpha[I]; { Exponents }
        end;
    end;
  end;

  DelVector(X1);
  DelVector(Y1);
  DelMatrix(U);
  DelMatrix(V);
  DelVector(P);
  DelVector(C);
  DelVector(Z);
  DelVector(Alpha);
end;

procedure GenExpFit(Mode: TRegMode; X, Y, S: TVector; Lb, Ub, Nexp: Integer;
  ConsTerm: Boolean; MaxIter: Integer; Tol: Float; var B: TVector;
  out V: TMatrix);
begin
  gNexp := Nexp;
  gConsTerm := ConsTerm;
  // DimVector(B,Ub);
  if (GetOptAlgo in [NL_MARQ, NL_BFGS, NL_SIMP]) and
    NullParam(B, FirstParam, LastParam) then
    ApproxFit(Mode, X, Y, S, Lb, Ub, B);

  if MaxIter = 0 then
    Exit;

  case Mode of
    OLS:
      NLFit(ExpFit_Func, ExpFit_Deriv, X, Y, Lb, Ub, MaxIter, Tol, B,
        FirstParam, LastParam, V);
    WLS:
      WNLFit(ExpFit_Func, ExpFit_Deriv, X, Y, S, Lb, Ub, MaxIter, Tol, B,
        FirstParam, LastParam, V);
  end;
end;

procedure ExpFit(X, Y: TVector; Lb, Ub, Nexp: Integer; ConsTerm: Boolean;
  MaxIter: Integer; Tol: Float; var B: TVector; out V: TMatrix);
begin
  GenExpFit(OLS, X, Y, nil, Lb, Ub, Nexp, ConsTerm, MaxIter, Tol, B, V);
end;

procedure WExpFit(X, Y, S: TVector; Lb, Ub, Nexp: Integer; ConsTerm: Boolean;
  MaxIter: Integer; Tol: Float; var B: TVector; out V: TMatrix);
begin
  GenExpFit(WLS, X, Y, S, Lb, Ub, Nexp, ConsTerm, MaxIter, Tol, B, V);
end;

end.
