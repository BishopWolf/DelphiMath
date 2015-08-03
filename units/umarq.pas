{ ******************************************************************
  Minimization of a function of several variables by Marquardt's
  method

  Modifications
  20120210 Alex Vergara Gil
  Ported to class design
  ****************************************************************** }

unit umarq;

interface

uses
  utypes, ugausjor, ulinmin, ucompvec, unlfit, uConstants;

type
  { ------------------------------------------------------------------
    Marquard base function type
    ------------------------------------------------------------------ }
  Adjust_Base = (Flat, { No Base, just the guess function }
    Linear, { Guess function plus M*X+N }
    Polinomial, { Guess function plus sum(Mi*X^i,i,0,N) }
    Exponential); { Guess function plus A*exp(B*(X-C)) }

  TMarquardt = class(TBaseOptAlgo)
  public
    procedure Marquardt(Func: TFuncNVar; HessGrad: THessGrad; var X: TVector;
      Lb, Ub, MaxIter: Integer; Tol: Float; out F_min: Float; out G: TVector;
      out H_inv: TMatrix; out Det: Float);
    procedure SaveMarquardt(FileName: string);
    { Save Marquardt iterations in a file }
  end;

  { ------------------------------------------------------------------
    Minimization of a function of several variables by Marquardt's
    method
    ------------------------------------------------------------------
    Input parameters  : Func       = objective function
    Gradient   = procedure to compute gradient
    X          = initial minimum coordinates
    Lb, Ub     = indices of first and last variables
    MaxIter    = maximum number of iterations
    Tol        = required precision
    ------------------------------------------------------------------
    Output parameters : X          = refined minimum coordinates
    F_min      = function value at minimum
    G          = gradient vector
    H_inv      = inverse hessian matrix
    Det        = determinant of hessian
    ------------------------------------------------------------------
    Possible results  : OptOk        = no error
    OptNonConv   = non-convergence
    OptSing      = singular hessian matrix
    OptBigLambda = too high Marquardt parameter Lambda
    ---------------------------------------------------------------------- }

procedure Adjust(X, y, sig: TVector; ndata, ma: Integer; var a, ia: TVector;
  var covar, alpha: TMatrix; out chisqr: Float; var alamda: Float;
  funcion: TFuncNCoef);
procedure Free_mem_Adjust;
procedure Initialize_Adjust(matry, mbeta, mda, moneda, noneda: cardinal);
{ Adjust of a function with Levenberg-Marquardt's Method see explanation below }

implementation

uses uoperations, uminmax, urandom, math;

var
  WriteLogFile: Boolean;
  LogFile: Text;
  mfit, na: Integer;
  ochisq: Float;
  atry, beta, da: TVector;
  oneda: TMatrix;

procedure Initialize_Adjust(matry, mbeta, mda, moneda, noneda: cardinal);
begin
  DimVector(atry, matry);
  DimVector(beta, mbeta);
  DimVector(da, mda);
  DimMatrix(oneda, moneda, noneda);
end;

procedure Free_mem_Adjust;
begin
  DelVector(atry);
  DelVector(beta);
  DelVector(da);
  DelMatrix(oneda);
end;

procedure covsrt(var covar: TMatrix; mfit, ma: cardinal; ia: TVector);
var
  i, j, k: Integer;
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

procedure HessGradGauss(X: TVector; out G: TVector; out H: TMatrix);
var
  i: integer;
  y, arg, ex, fac: Float;
begin
  y := 0;
  i := 1;
  DimVector(G, na);
  DimMatrix(H, na, na);
  repeat
    arg := (X[i] - X[i + 1]) / X[i + 2]; //
    ex := exp(-arg * arg);
    fac := X[i] * ex * 2.0 * arg;
    y := y + X[i] * ex;
    G[i] := ex;
    G[i + 1] := fac / X[i + 2];
    G[i + 2] := fac * arg / X[i + 2];
    // H[i,i]:=1;
    // H[i+1,i+1]:=;
    inc(i, 3);
  until i >= na;
end;

function SumGauss(y, X, sig, Coef: TVector; out G: TVector;
  out H: TMatrix): Float;
var
  i, j: integer;
  res, arg, ex, fac: Float;
begin
  res := 0;
  i := 1;
  DimVector(G, na);
  repeat
    arg := (X[(i + 2) div 3] - Coef[i + 1]) / Coef[i + 2];
    ex := exp(-arg * arg);
    fac := Coef[i] * ex * 2.0 * arg;
    res := res + X[i] * ex;
    G[i] := ex;
    G[i + 1] := fac / X[i + 2];
    G[i + 2] := fac * arg / X[i + 2];
    for j := i to i + 2 do
    begin
      // H[i,j]
    end;
    inc(i, 3);
  until i >= na;
  result := res;
end;

procedure mrqcof(X, y, sig, a, ia: TVector; ndata, ma: Integer;
  out alpha: TMatrix; out beta: TVector; out chisq: Float; funcion: TFuncNCoef);
// Used by Adjust to evaluate the linearized fitting matrix alpha, and vector beta as in (15.5.8), and calculate chi2.
var
  i, j, k, l, m, mfit: Integer;
  ymod, wt, sig2i, dy: Float;
  dyda: TVector;
begin
  mfit := 0;
  DimVector(dyda, ma);
  for j := 1 to ma do
    if not(ia[j] = 0) then
      inc(mfit);
  chisq := 0.0;
  for i := 1 to ndata do
  begin // Summation loop over all data.
    ymod := funcion(X[i], a, dyda, ma);
    sig2i := 1;
    if sig <> nil then
      sig2i := 1.0 / sqr(sig[i]);
    dy := y[i] - ymod;
    j := 0;
    for l := 1 to ma do
    begin
      if not(ia[l] = 0) then
      begin
        wt := dyda[l] * sig2i;
        inc(j);
        k := 0;
        for m := 1 to l do
          if not(ia[m] = 0) then
          begin
            inc(k);
            alpha[j, k] := alpha[j, k] + wt * dyda[m];
          end;
        beta[j] := beta[j] + dy * wt;
      end;
    end;
    chisq := chisq + dy * dy * sig2i; // And .nd .2.
  end;
  for j := 2 to mfit do // Fill in the symmetric side.
    for k := 1 to j - 1 do
      alpha[k, j] := alpha[j, k];
  DelVector(dyda);
end;

procedure Adjust(X, y, sig: TVector; ndata, ma: Integer; var a, ia: TVector;
  var covar, alpha: TMatrix; out chisqr: Float; var alamda: Float;
  funcion: TFuncNCoef);
{ Levenberg-Marquardt method, attempting to reduce the value chi2 of a fit between a set of data
  points x[1..ndata], y[1..ndata] with individual standard deviations sig[1..ndata],
  and a nonlinear function dependent on ma coefficients a[1..ma]. The input array ia[1..ma]
  indicates by nonzero entries those components of a that should be fitted for, and by zero
  entries those components that should be held fixed at their input values. The program returns
  current best-fit values for the parameters a[1..ma], and chi2 = chisq. The arrays
  covar[1..ma][1..ma], alpha[1..ma][1..ma] are used as working space during most
  iterations. Supply a routine funcs(x,a,yfit,dyda,ma) that evaluates the fitting function
  yfit, and its derivatives dyda[1..ma] with respect to the fitting parameters a at x. On
  the first call provide an initial guess for the parameters a, and set alamda<0 for initialization
  (which then sets alamda=.001). If a step succeeds chisq becomes smaller and alamda decreases
  by a factor of 10. If a step fails alamda grows by a factor of 10. You must call this
  routine repeatedly until convergence is achieved. Then, make one final call with alamda=0, so
  that covar[1..ma][1..ma] returns the covariance matrix, and alpha the curvature matrix.
  (Parameters held fixed will return zero covariances.)
  The base can de flat, linear,polinomial or exponential,
  the real dimension then must be upgraded to var dim.
  If you desire to keep untouch the base pu it's ia coefficients to 0 }
var
  j, k, l: Integer;
  GJE: TGaussJordan;
  temponeda: TMatrix;
begin
  if (alamda = -1) then
  begin // Initialization.
    DimVector(atry, ma);
    mfit := 0;
    for j := 1 to ma do
      if not(ia[j] = 0) then
        inc(mfit);
    DimMatrix(oneda, mfit, 1);
    DimVector(beta, mfit);
    DimVector(da, mfit);
    DimMatrix(alpha, ma, ma);
    mrqcof(X, y, sig, a, ia, ndata, ma, alpha, beta, chisqr, funcion);
    ochisq := chisqr;
    alamda := 0.001;
    DimMatrix(covar, ma, ma);
    for j := 1 to ma do
      atry[j] := a[j];
  end;
  for j := 1 to mfit do
  begin // Alter linearized .tting matrix, by augmenting diagonal elements.
    for k := 1 to mfit do
      covar[j, k] := alpha[j, k];
    covar[j, j] := alpha[j, j] * (1 + alamda);
    oneda[j, 1] := beta[j];
  end;
  GJE := TGaussJordan.Create(covar, 1, mfit);
  temponeda := GJE.Solve(oneda, 1); // Matrix solution.
  DelMatrix(covar);
  covar := Clone(GJE.InverseMatrix, mfit, mfit);
  DelMatrix(oneda);
  oneda := temponeda;
  GJE.Free;
  // GaussJordan_Elimination(covar,oneda,mfit,1);
  for j := 1 to mfit do
    da[j] := oneda[j, 1];
  if (alamda = 0.0) then
  begin // Once converged, evaluate covariance matrix.
    covsrt(covar, mfit, ma, ia);
    covsrt(alpha, mfit, ma, ia); // Spread out alpha to its full size too.
    Free_mem_Adjust;
    exit;
  end;
  j := 0;
  for l := 1 to ma do // Did the trial succeed?
    if not(ia[l] = 0) then
    begin
      inc(j);
      atry[l] := a[l] + da[j];
      if (abs(atry[l]) < mindouble) or (abs(atry[l]) > maxdouble) then
        ia[l] := 0;
    end;
  mrqcof(X, y, sig, atry, ia, ndata, ma, covar, da, chisqr, funcion);
  if (chisqr < ochisq) then
  begin // Success, accept the new solution.
    alamda := alamda * 0.1;
    ochisq := chisqr;
    for j := 1 to mfit do
    begin
      for k := 1 to mfit do
        alpha[j, k] := covar[j, k];
      beta[j] := da[j];
    end;
    for l := 1 to ma do
      a[l] := atry[l];
  end
  else
  begin // Failure, increase alamda and return.
    alamda := alamda * 10.0;
    chisqr := ochisq;
  end;
end;

procedure TMarquardt.SaveMarquardt(FileName: string);
begin
  Assign(LogFile, FileName);
  Rewrite(LogFile);
  WriteLogFile := True;
end;

procedure TMarquardt.Marquardt(Func: TFuncNVar; HessGrad: THessGrad;
  var X: TVector; Lb, Ub: Integer; MaxIter: Integer; Tol: Float;
  out F_min: Float; out G: TVector; out H_inv: TMatrix; out Det: Float);

const
  Lambda0 = 1.0E-2; { Initial lambda value }
  LambdaMax = 1.0E+3; { Highest lambda value }
  FTol = 1.0E-10; { Tolerance on function decrease }

var
  Ub1, i, j, Iter: Integer;
  F1, R: Float;
  OldX, DeltaX: TVector;
  a, H: TMatrix;
  Lambda: Float;
  LambdaOk: Boolean;

  procedure SolveSystem(Lambda: Float);
  { Solve the system of linear equations :

    H' * DeltaX = -G

    where H' is the modified hessian matrix (diagonal terms
    multiplied by (1 + Lambda)), and G is the gradient vector,
    for a given value of Marquardt's Lambda parameter.

    The whole system is stored in a matrix A = [H'|G]
    which is transformed by the Gauss-jordan method.
    The inverse hessian matrix H_inv is then retrieved
    from the transformed matrix. }

  var
    Lambda1: Float;
    i: Integer;
    GJE: TGaussJordan;
  begin
    if Lambda > 0.0 then
    begin
      Lambda1 := 1.0 + Lambda;
      for i := Lb to Ub do
        a[i, i] := Lambda1 * H[i, i];
    end;
    GJE := TGaussJordan.Create(a, Lb, Ub);
    // GaussJordan(A, Lb, Ub, Ub1, Det);

    if MathErr = MatOk then
      H_inv := Clone(GJE.InverseMatrix, Ub, Ub);
    GJE.Free;
  end;

  procedure Terminate(ErrCode: Integer);
  { Set error code and deallocate arrays }
  begin
    DelVector(OldX);
    DelVector(DeltaX);
    DelMatrix(a);
    DelMatrix(H);

    SetErrCode(ErrCode);

    if WriteLogFile then
      Close(LogFile);
  end;

begin
  Ub1 := Ub + 1;

  DimVector(OldX, Ub);
  DimVector(DeltaX, Ub);
  DimMatrix(a, Ub, Ub1);
  DimMatrix(H, Ub, Ub);

  if WriteLogFile then
  begin
    WriteLn(LogFile, 'Marquardt');
    WriteLn(LogFile, 'Iter         F            Lambda');
  end;

  Iter := 0;
  Lambda := Lambda0;
  F_min := Func(X);

  repeat
    if WriteLogFile then
      WriteLn(LogFile, Iter:4, '   ', F_min:12, '   ', Lambda:12);

    { Save old parameters }
    for i := Lb to Ub do
      OldX[i] := X[i];

    { Compute Gradient and Hessian }
    HessGrad(X, G, H);
    for i := Lb to Ub do
    begin
      for j := Lb to Ub do
        a[i, j] := H[i, j];
      a[i, Ub1] := -G[i];
    end;

    if MaxIter < 1 then
    begin
      SolveSystem(0.0);
      if MathErr = MatOk then
        Terminate(OptOk)
      else
        Terminate(OptSing);
      exit;
    end;

    { Prepare next iteration }
    Iter := Iter + 1;
    if Iter > MaxIter then
    begin
      Terminate(OptNonConv);
      exit;
    end;

    repeat
      SolveSystem(Lambda);

      if MathErr <> MatOk then
      begin
        Terminate(OptSing);
        exit;
      end;

      { Initialize parameters and search direction }
      for i := Lb to Ub do
      begin
        X[i] := OldX[i];
        DeltaX[i] := a[i, Ub1];
      end;

      { Minimize along the direction specified by DeltaX }
      { using an initial step of 0.1 * |DeltaX| }
      R := 0.1;
      LinMin(Func, X, DeltaX, Lb, Ub, R, 10, 0.01, F1);

      { Check that the function has decreased, otherwise }
      { increase Lambda, without exceeding LambdaMax }
      LambdaOk := (F1 - F_min) < F_min * FTol;
      if not LambdaOk then
        Lambda := 10.0 * Lambda;
      if Lambda > LambdaMax then
      begin
        Terminate(OptBigLambda);
        exit;
      end;
    until LambdaOk;

    Lambda := 0.1 * Lambda;
    F_min := F1;
  until CompVec(X, OldX, Lb, Ub, Tol);

  Terminate(OptOk);
end;

begin
  WriteLogFile := False;

end.
