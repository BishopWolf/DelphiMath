{ ******************************************************************
  Nonlinear regression
  ****************************************************************** }

Unit unlfit;

Interface

Uses
  umachar, utypes, uConstants;

Type
  TBaseOptAlgo = Class

  End;

  { Function of several variables }
  TFuncNVar = Function(X: TVector): Float;
  { Optimization algorithms for nonlinear regression }
  TOptAlgo = (NL_MARQ, { Marquardt algorithm }
    NL_SIMP,           { Simplex algorithm }
    NL_BFGS,           { BFGS algorithm }
    NL_SA,             { Simulated annealing }
    NL_GA);            { Genetic algorithm }

Procedure SetOptAlgo(Algo: TOptAlgo);
{ ------------------------------------------------------------------
  Sets the optimization algorithm according to Algo, which must be
  NL_MARQ, NL_SIMP, NL_BFGS, NL_SA, NL_GA. Default is NL_MARQ
  ------------------------------------------------------------------ }

Function GetOptAlgo: TOptAlgo;
{ ------------------------------------------------------------------
  Returns the optimization algorithm
  ------------------------------------------------------------------ }

Procedure SetMaxParam(N: Byte);
{ ------------------------------------------------------------------
  Sets the maximum number of regression parameters
  ------------------------------------------------------------------ }

Procedure SetParamBounds(I: Byte; ParamMin, ParamMax: Float);
{ ------------------------------------------------------------------
  Sets the bounds on the I-th regression parameter
  ------------------------------------------------------------------ }

Function NullParam(Var B: TVector; Lb, Ub: Integer): Boolean;
{ ------------------------------------------------------------------
  Checks if a regression parameter is not initialized or equal to zero
  ------------------------------------------------------------------ }

Procedure NLFit(RegFunc: TRegFunc; DerivProc: TDerivProc; X, Y: TVector;
  Lb, Ub: Integer; MaxIter: Integer; Tol: Float; Var B: TVector;
  FirstPar, LastPar: Integer; Out V: TMatrix);
{ ------------------------------------------------------------------
  Unweighted nonlinear regression
  ------------------------------------------------------------------
  Input parameters:  RegFunc   = regression function
  DerivProc = procedure to compute derivatives
  X, Y      = point coordinates
  Lb, Ub    = array bounds
  MaxIter   = max. number of iterations
  Tol       = tolerance on parameters
  B         = initial parameter values
  FirstPar  = index of first regression parameter
  LasttPar  = index of last regression parameter
  Output parameters: B         = fitted regression parameters
  V         = inverse matrix
  ------------------------------------------------------------------ }

Procedure WNLFit(RegFunc: TRegFunc; DerivProc: TDerivProc; X, Y, S: TVector;
  Lb, Ub: Integer; MaxIter: Integer; Tol: Float; Var B: TVector;
  FirstPar, LastPar: Integer; Out V: TMatrix);
{ ------------------------------------------------------------------
  Weighted nonlinear regression
  ------------------------------------------------------------------
  S = standard deviations of observations
  Other parameters as in NLFit
  ------------------------------------------------------------------ }

Procedure SetMCFile(FileName: String);
{ ------------------------------------------------------------------
  Set file for saving MCMC simulations
  ------------------------------------------------------------------ }

Procedure SimFit(RegFunc: TRegFunc; X, Y: TVector; Lb, Ub: Integer;
  Out B: TVector; FirstPar, LastPar: Integer; Out V: TMatrix);
{ ------------------------------------------------------------------
  Simulation of unweighted nonlinear regression by MCMC
  ------------------------------------------------------------------ }

Procedure WSimFit(RegFunc: TRegFunc; X, Y, S: TVector; Lb, Ub: Integer;
  Out B: TVector; FirstPar, LastPar: Integer; Out V: TMatrix);
{ ------------------------------------------------------------------
  Simulation of weighted nonlinear regression by MCMC
  ------------------------------------------------------------------ }

Implementation

Uses ugausjor, umarq, ubfgs, usimplex, uoperations,
  usimann, ugenalg, umcmc, ustrings;

Const
  MAX_BOUND = 1.0E+6; { Default parameter bound }
  MAX_FUNC  = 1.0E+30; { Max. value for objective function
    (used to prevent overflow) }

  {$IFDEF _16BIT}Const {$ELSE}Var {$ENDIF}
  MaxParam: Byte     = 10;         { Max. index of fitted parameter }
  OptAlgo : TOptAlgo = NL_MARQ;    { Optimization algorithm }
  MCFile  : String   = 'mcmc.txt'; { File for saving MCMC simulations }

  { Global variables used by the nonlinear regression routines }
  gLb      : Integer = 0;   { Index of first point }
  gUb      : Integer = 0;   { Index of last point }
  gX       : TVector = Nil; { X coordinates }
  gY       : TVector = Nil; { Y coordinates }
  gW       : TVector = Nil; { Weights }
  gYcalc   : TVector = Nil; { Estimated Y values }
  gR       : TVector = Nil; { Residuals (Y - Ycalc) }
  gFirstPar: Integer = 0;   { Index of first fitted parameter }
  gLastPar : Integer = 0;   { Index of last fitted parameter }
  gBmin    : TVector = Nil; { Lower bounds on parameters }
  gBmax    : TVector = Nil; { Higher bounds on parameters }
  gD       : TVector = Nil; { Derivatives of regression function }

Var
  gRegFunc  : TRegFunc;   { Regression function }
  gDerivProc: TDerivProc; { Derivation procedure }

Procedure SetOptAlgo(Algo: TOptAlgo);
Begin
  OptAlgo := Algo;
End;

Function GetOptAlgo: TOptAlgo;
Begin
  GetOptAlgo := OptAlgo;
End;

Procedure SetMaxParam(N: Byte);
Begin
  If N < MaxParam Then
    Exit;

  DelVector(gBmin);
  DelVector(gBmax);

  DimVector(gBmin, N);
  DimVector(gBmax, N);

  MaxParam := N;
End;

Procedure SetParamBounds(I: Byte; ParamMin, ParamMax: Float);
Begin
  If gBmin = Nil Then
    DimVector(gBmin, MaxParam);

  If gBmax = Nil Then
    DimVector(gBmax, MaxParam);

  If (I > MaxParam) Or (ParamMin >= ParamMax) Then
    Exit;

  gBmin[I] := ParamMin;
  gBmax[I] := ParamMax;
End;

Function NullParam(Var B: TVector; Lb, Ub: Integer): Boolean;
Var
  NP: Boolean;
  I : Integer;
Begin
  Try
    // NP := False;
    I := Lb;
    Repeat
      NP := (B[I] = 0.0);
      Inc(I);
    Until NP Or (I > Ub);
  Except
    NP := true;
    DimVector(B, Ub);
  End;
  NullParam := NP;
End;

Procedure SetGlobalVar(Mode: TRegMode; RegFunc: TRegFunc; DerivProc: TDerivProc;
  X, Y, S: TVector; Lb, Ub: Integer; FirstPar, LastPar: Integer);

{ Checks the data and sets the global variables }

Var
  I, Npar, Npts: Integer;

Begin
  If LastPar > MaxParam Then
  Begin
    SetErrCode(NLMaxPar);
    Exit;
  End;

  Npts := Ub - Lb + 1;            { Number of points }
  Npar := LastPar - FirstPar + 1; { Number of parameters }

  If Npts <= Npar Then
  Begin
    SetErrCode(MatErrDim);
    Exit;
  End;

  If Mode = WLS Then
    For I := Lb To Ub Do
      If S[I] <= 0.0 Then
      Begin
        SetErrCode(MatSing);
        Exit;
      End;

  DelVector(gX);
  DelVector(gY);
  DelVector(gW);
  DelVector(gYcalc);
  DelVector(gR);

  DimVector(gX, Ub);
  DimVector(gY, Ub);
  DimVector(gW, Ub);
  DimVector(gYcalc, Ub);
  DimVector(gR, Ub);

  For I := Lb To Ub Do
  Begin
    gX[I] := X[I];
    gY[I] := Y[I];
  End;

  If Mode = WLS Then
    For I   := Lb To Ub Do
      gW[I] := 1.0 / Sqr(S[I]);

  If gBmin = Nil Then
    DimVector(gBmin, MaxParam);

  If gBmax = Nil Then
    DimVector(gBmax, MaxParam);

  For I := FirstPar To LastPar Do
    If gBmin[I] >= gBmax[I] Then
    Begin
      gBmin[I] := -MAX_BOUND;
      gBmax[I] := MAX_BOUND;
    End;

  DelVector(gD);
  DimVector(gD, LastPar);

  gLb := Lb;
  gUb := Ub;

  gFirstPar := FirstPar;
  gLastPar  := LastPar;

  gRegFunc   := RegFunc;
  gDerivProc := DerivProc;

  SetErrCode(MatOk);
End;

Function OutOfBounds(B: TVector): Boolean;
{ Check if the parameters are inside the bounds }
Var
  I  : Integer;
  OoB: Boolean;
Begin
  I := gFirstPar;
  Repeat
    OoB := (B[I] < gBmin[I]) Or (B[I] > gBmax[I]);
    Inc(I);
  Until OoB Or (I > gLastPar);
  OutOfBounds := OoB;
End;

Function OLS_ObjFunc(B: TVector): Float;
{ Objective function for unweighted nonlinear regression }
Var
  K: Integer;
  S: Float;
Begin
  If OutOfBounds(B) Then
  Begin
    OLS_ObjFunc := MAX_FUNC;
    Exit;
  End;

  S := 0.0;
  K := gLb;

  Repeat
    gYcalc[K] := gRegFunc(gX[K], B);
    gR[K]     := gY[K] - gYcalc[K];
    S         := S + Sqr(gR[K]);
    Inc(K);
  Until (K > gUb) Or (S > MAX_FUNC);

  If S > MAX_FUNC Then
    S         := MAX_FUNC;
  OLS_ObjFunc := S;
End;

Function OLS_Gradient(B: TVector): TVector;
{ Gradient for unweighted nonlinear regression }
Var
  I, K: Integer; { Loop variables }
Begin
  { Initialization }
  DimVector(Result, gLastPar);

  { Compute Gradient }
  For K := gLb To gUb Do
  Begin
    gDerivProc(gX[K], gYcalc[K], B, gD);
    For I       := gFirstPar To gLastPar Do
      Result[I] := Result[I] - gD[I] * gR[K];
  End;

  For I       := gFirstPar To gLastPar Do
    Result[I] := 2.0 * Result[I];
End;

Procedure OLS_HessGrad(B: TVector; Out G: TVector; Out H: TMatrix);
{ Gradient and Hessian for unweighted nonlinear regression }
Var
  I, J, K: Integer; { Loop variables }
Begin
  { Initializations }
  DimVector(G, gLastPar);
  DimMatrix(H, gLastPar, gLastPar);

  { Compute Gradient & Hessian }
  For K := gLb To gUb Do
  Begin
    gDerivProc(gX[K], gYcalc[K], B, gD);
    For I := gFirstPar To gLastPar Do
    Begin
      G[I]      := G[I] - gD[I] * gR[K];
      For J     := I To gLastPar Do
        H[I, J] := H[I, J] + gD[I] * gD[J];
    End;
  End;

  { Fill in symmetric matrix }
  For I       := Succ(gFirstPar) To gLastPar Do
    For J     := gFirstPar To Pred(I) Do
      H[I, J] := H[J, I];
End;

Function WLS_ObjFunc(B: TVector): Float;
{ Objective function for weighted nonlinear regression }
Var
  K: Integer;
  S: Float;
Begin
  If OutOfBounds(B) Then
  Begin
    WLS_ObjFunc := MAX_FUNC;
    Exit;
  End;

  S := 0.0;
  K := gLb;

  Repeat
    gYcalc[K] := gRegFunc(gX[K], B);
    gR[K]     := gY[K] - gYcalc[K];
    S         := S + gW[K] * Sqr(gR[K]);
    Inc(K);
  Until (K > gUb) Or (S > MAX_FUNC);

  If S > MAX_FUNC Then
    S         := MAX_FUNC;
  WLS_ObjFunc := S;
End;

Function WLS_Gradient(B: TVector): TVector;
{ Gradient for weighted nonlinear regression }
Var
  I, K: Integer; { Loop variables }
  WR  : Float;   { Weighted residual }
Begin
  { Initialization }
  DimVector(Result, gLastPar);

  { Compute Gradient }
  For K := gLb To gUb Do
  Begin
    WR := gW[K] * gR[K];
    gDerivProc(gX[K], gYcalc[K], B, gD);
    For I       := gFirstPar To gLastPar Do
      Result[I] := Result[I] - gD[I] * WR;
  End;

  For I       := gFirstPar To gLastPar Do
    Result[I] := 2.0 * Result[I];
End;

Procedure WLS_HessGrad(B: TVector; Out G: TVector; Out H: TMatrix);
{ Gradient and Hessian for weighted nonlinear regression }
Var
  I, J, K: Integer; { Loop variables }
  WR, WD : Float;   { Weighted residual and derivative }
Begin
  { Initializations }
  DimVector(G, gLastPar);
  DimMatrix(H, gLastPar, gLastPar);

  { Compute Gradient & Hessian }
  For K := gLb To gUb Do
  Begin
    WR := gW[K] * gR[K];
    gDerivProc(gX[K], gYcalc[K], B, gD);
    For I := gFirstPar To gLastPar Do
    Begin
      G[I]      := G[I] - gD[I] * WR;
      WD        := gW[K] * gD[I];
      For J     := I To gLastPar Do
        H[I, J] := H[I, J] + WD * gD[J];
    End;
  End;

  { Fill in symmetric matrix }
  For I       := Succ(gFirstPar) To gLastPar Do
    For J     := gFirstPar To Pred(I) Do
      H[I, J] := H[J, I];
End;

Procedure GenNLFit(Mode: TRegMode; RegFunc: TRegFunc; DerivProc: TDerivProc;
  X, Y, S: TVector; Lb, Ub: Integer; MaxIter: Integer; Tol: Float;
  Var B: TVector; FirstPar, LastPar: Integer; Out V: TMatrix);
{ --------------------------------------------------------------------
  General nonlinear regression routine
  -------------------------------------------------------------------- }
Var
  F_min   : Float;     { Value of objective function at minimum }
  G       : TVector;   { Gradient vector }
  Det     : Float;     { Determinant of Hessian matrix }
  ObjFunc : TFuncNVar; { Objective function }
  GradProc: TGradient; { Procedure to compute gradient }
  HessProc: THessGrad; { Procedure to compute gradient and hessian }
  base    : TBaseOptAlgo;
  GJE     : TGaussJordan;
Begin
  SetGlobalVar(Mode, RegFunc, DerivProc, X, Y, S, Lb, Ub, FirstPar, LastPar);

  If MathErr <> MatOk Then
    Exit;
  Case OptAlgo Of
    NL_MARQ:
      base := TMarquardt.Create;
    NL_SIMP:
      base := TSimplex.Create;
    NL_BFGS:
      base := TBFGS.Create;
    NL_SA:
      base := TSimAnn.Create;
    NL_GA:
      base := TGenAlg.Create;
  Else
    base := Nil;
  End;
  If (GetOptAlgo In [NL_MARQ, NL_BFGS, NL_SIMP]) Then
  Begin
    If NullParam(B, FirstPar, LastPar) Then
    Begin
      SetErrCode(NLNullPar);
      Exit;
    End;
  End;

  If Mode = OLS Then
  Begin
    ObjFunc  := OLS_ObjFunc;
    GradProc := OLS_Gradient;
    HessProc := OLS_HessGrad;
  End
  Else
  Begin
    ObjFunc  := WLS_ObjFunc;
    GradProc := WLS_Gradient;
    HessProc := WLS_HessGrad;
  End;

  DimVector(G, LastPar);

  Case OptAlgo Of
    NL_MARQ:
      (base As TMarquardt).Marquardt(ObjFunc, HessProc, B, FirstPar, LastPar,
        MaxIter, Tol, F_min, G, V, Det);
    NL_SIMP:
      (base As TSimplex).Simplex(ObjFunc, B, FirstPar, LastPar, MaxIter,
        Tol, F_min);
    NL_BFGS:
      (base As TBFGS).BFGS(ObjFunc, GradProc, B, FirstPar, LastPar, MaxIter,
        Tol, F_min, G, V);
    NL_SA:
      (base As TSimAnn).SimAnn(ObjFunc, B, gBmin, gBmax, FirstPar,
        LastPar, F_min);

    NL_GA:
      (base As TGenAlg).GenAlg(ObjFunc, B, gBmin, gBmax, FirstPar,
        LastPar, F_min);
End;

base.Free;

If (OptAlgo <> NL_MARQ) And (MathErr = MatOk) Then
Begin
  { Compute the Hessian matrix and its inverse }
  HessProc(B, G, V);
  GJE := TGaussJordan.Create(V, FirstPar, LastPar);
  DelMatrix(V);
  V := clone(GJE.InverseMatrix, LastPar, LastPar);
  GJE.Free;
End;

DelVector(G);
End;

Procedure NLFit(RegFunc: TRegFunc; DerivProc: TDerivProc; X, Y: TVector;
  Lb, Ub: Integer; MaxIter: Integer; Tol: Float; Var B: TVector;
  FirstPar, LastPar: Integer; Out V: TMatrix);
Begin
  GenNLFit(OLS, RegFunc, DerivProc, X, Y, Nil, Lb, Ub, MaxIter, Tol, B,
    FirstPar, LastPar, V);
End;

Procedure WNLFit(RegFunc: TRegFunc; DerivProc: TDerivProc; X, Y, S: TVector;
  Lb, Ub: Integer; MaxIter: Integer; Tol: Float; Var B: TVector;
  FirstPar, LastPar: Integer; Out V: TMatrix);
Begin
  GenNLFit(WLS, RegFunc, DerivProc, X, Y, S, Lb, Ub, MaxIter, Tol, B, FirstPar,
    LastPar, V);
End;

Procedure SetMCFile(FileName: String);
Begin
  MCFile := FileName;
End;

Procedure GenSimFit(Mode: TRegMode; RegFunc: TRegFunc; X, Y, S: TVector;
  Lb, Ub: Integer; Out B: TVector; FirstPar, LastPar: Integer; Out V: TMatrix);
Var
  ObjFunc                      : TFuncNVar; { Objective function }
  { NCycles, MaxSim, } SavedSim: Integer;   { Metropolis-Hastings parameters }
  Xmat                         : TMatrix;   { Matrix of simulated parameters }
  F_min: Float; { Value of objective function at minimum }
  B_min     : TVector;  { Parameter values at minimum }
  R         : Float;    { Range of parameter values }
  I, J      : Integer;  { Loop variables }
  F         : Textfile; { File for storing MCMC simulations }
  lgensimfit: TMCMC;
Begin
  SetGlobalVar(Mode, RegFunc, Nil, X, Y, S, Lb, Ub, FirstPar, LastPar);
  lgensimfit := TMCMC.Create;
  If MathErr <> MatOk Then
    Exit;

  { Initialize variance-covariance matrix }
  DimMatrix(V, LastPar, LastPar);
  DimVector(B, LastPar);
  For I := FirstPar To LastPar Do
  Begin
    R     := gBmax[I] - gBmin[I];
    B[I]  := gBmin[I] + 0.5 * R;
    For J := FirstPar To LastPar Do
      If I = J Then
        { The parameter range is assumed to cover 6 SD's }
        V[I, J] := R * R / 36.0
      Else
        V[I, J] := 0.0;
  End;

  If Mode = OLS Then
    ObjFunc := OLS_ObjFunc
  Else
    ObjFunc := WLS_ObjFunc;

  // NCycles  := lgensimfit.MH_NCycles;
  // MaxSim   := lgensimfit.MH_MaxSim;
  SavedSim := lgensimfit.MH_SavedSim;

  DimMatrix(Xmat, SavedSim, LastPar);
  DimVector(B_min, LastPar);

  lgensimfit.Hastings(ObjFunc, 2.0, B, V, FirstPar, LastPar, Xmat,
    B_min, F_min);

  If MathErr = MatOk Then { Save simulations }
  Begin
    Assign(F, MCFile);
    Rewrite(F);
    For I := 1 To SavedSim Do
    Begin
      Write(F, Int2Str(I));
      For J := FirstPar To LastPar Do
        Write(F, Float2Str(Xmat[I, J]));
      Writeln(F);
    End;
    Close(F);
  End;

  DelMatrix(Xmat);
  lgensimfit.Free;
End;

Procedure SimFit(RegFunc: TRegFunc; X, Y: TVector; Lb, Ub: Integer;
  Out B: TVector; FirstPar, LastPar: Integer; Out V: TMatrix);
Begin
  GenSimFit(OLS, RegFunc, X, Y, Nil, Lb, Ub, B, FirstPar, LastPar, V);
End;

Procedure WSimFit(RegFunc: TRegFunc; X, Y, S: TVector; Lb, Ub: Integer;
  Out B: TVector; FirstPar, LastPar: Integer; Out V: TMatrix);
Begin
  GenSimFit(WLS, RegFunc, X, Y, S, Lb, Ub, B, FirstPar, LastPar, V);
End;

End.
