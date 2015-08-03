{ ******************************************************************
  This unit fits the integrated Michaelis equation:

  p(t) = Km [x0 - W[x0 exp(x0 - k0 t)]]

  with x0 = s0 / Km and k0 = Vmax / Km

  W is Lambert's function (see ULAMBERT.PAS)
  ****************************************************************** }

unit umintfit;

interface

uses
  utypes, umath, ulambert, umeansd, ulinfit, unlfit, uminmax, uConstants;

procedure MintFit(X, Y: TVector; Lb, Ub: Integer; MaxIter: Integer; Tol: Float;
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

procedure WMintFit(X, Y, S: TVector; Lb, Ub: Integer; MaxIter: Integer;
  Tol: Float; var B: TVector; out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted fit of model
  ------------------------------------------------------------------
  Additional input parameter:
  S = standard deviations of observations
  ------------------------------------------------------------------ }

function MintFit_Func(X: Float; B: TVector): Float;
{ ------------------------------------------------------------------
  Returns the value of the regression function at point X
  ------------------------------------------------------------------ }

implementation

const
  FirstParam = 1;
  LastParam = 3;

function MintFit_Func(X: Float; B: TVector): Float;
{ ------------------------------------------------------------------
  Computes the regression function at point X
  B is the vector of parameters, such that :

  B[1] = Km     B[2] = x0     B[3] = k0
  ------------------------------------------------------------------ }
var
  L: Float;
begin
  L := LambertW(B[2] * Expo(B[2] - B[3] * X), True, False);
  MintFit_Func := B[1] * (B[2] - L);
end;

procedure MintFit_Deriv(X, Y: Float; B: TVector; out D: TVector);
{ ------------------------------------------------------------------
  Computes the derivatives of the regression function at point X
  with respect to the parameters B. The results are returned in D.
  D[I] contains the derivative with respect to the I-th parameter.
  ------------------------------------------------------------------ }
var
  L, Q: Float;
begin
  DimVector(D, 3);
  D[1] := Y / B[1];
  L := B[2] - D[1];
  Q := 1.0 / (1.0 + L);
  D[2] := B[1] * (B[2] - L) * Q / B[2];
  D[3] := B[1] * X * L * Q;
end;

procedure ApproxFit(X, Y: TVector; Lb, Ub: Integer; out B: TVector);
{ ------------------------------------------------------------------
  Computes initial estimates of the regression parameters by linear
  regression:

  p / t = Vmax + Km (1 / t) Ln(1 - p / s0)
  ------------------------------------------------------------------
  Input :  X, Y   = point coordinates
  Lb, Ub = array bounds
  Output : B      = estimated regression parameters
  ------------------------------------------------------------------ }
var
  I: Integer;
  S0: Float;
  XX, YY: TVector;
  A: TVector;
  V: TMatrix;
  Pos: Integer; { variable needed }
begin
  DimVector(XX, Ub);
  DimVector(YY, Ub);

  { s0 is estimated at 10% higher than the maximum Y value }
  S0 := 1.1 * Max(Y, 1, Ub, Pos);

  { Compute transformed coordinates }
  for I := Lb to Ub do
  begin
    XX[I] := Ln(1.0 - Y[I] / S0) / X[I];
    YY[I] := Y[I] / X[I];
  end;

  { Perform linear regression }
  LinFit(XX, YY, Lb, Ub, A, V);
  DimVector(B, LastParam);
  { Retrieve parameters }
  DimVector(B, 3);
  B[1] := A[2]; { Km }
  B[2] := S0 / A[2]; { s0 / Km }
  B[3] := Abs(A[1] / A[2]); { Vmax / Km }

  DelVector(XX);
  DelVector(YY);
  DelVector(A);
  DelMatrix(V);
end;

procedure GenMintFit(Mode: TRegMode; X, Y, S: TVector; Lb, Ub: Integer;
  MaxIter: Integer; Tol: Float; var B: TVector; out V: TMatrix);
begin
  if (GetOptAlgo in [NL_MARQ, NL_BFGS, NL_SIMP]) and
    NullParam(B, FirstParam, LastParam) then
    ApproxFit(X, Y, Lb, Ub, B);

  if MaxIter = 0 then
    Exit;

  case Mode of
    OLS:
      NLFit(MintFit_Func, MintFit_Deriv, X, Y, Lb, Ub, MaxIter, Tol, B,
        FirstParam, LastParam, V);
    WLS:
      WNLFit(MintFit_Func, MintFit_Deriv, X, Y, S, Lb, Ub, MaxIter, Tol, B,
        FirstParam, LastParam, V);
  end;
end;

procedure MintFit(X, Y: TVector; Lb, Ub: Integer; MaxIter: Integer; Tol: Float;
  var B: TVector; out V: TMatrix);
begin
  GenMintFit(OLS, X, Y, nil, Lb, Ub, MaxIter, Tol, B, V);
end;

procedure WMintFit(X, Y, S: TVector; Lb, Ub: Integer; MaxIter: Integer;
  Tol: Float; var B: TVector; out V: TMatrix);
begin
  GenMintFit(WLS, X, Y, S, Lb, Ub, MaxIter, Tol, B, V);
end;

end.
