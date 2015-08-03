{ ******************************************************************
  Simulation by Markov Chain Monte Carlo (MCMC) with the
  Metropolis-Hastings algorithm.

  This algorithm simulates the probability density function (pdf) of
  a vector X. The pdf P(X) is written as:

  P(X) = C * Exp(- F(X) / T)

  Simulating P by the Metropolis-Hastings algorithm is equivalent to
  minimizing F by simulated annealing at the constant temperature T.
  The constant C is not used in the simulation.

  The series of random vectors generated during the annealing step
  constitutes a Markov chain which tends towards the pdf to be
  simulated.

  It is possible to run several cycles of the algorithm.
  The variance-covariance matrix of the simulated distribution is
  re-evaluated at the end of each cycle and used for the next cycle.

  Modifications
  20120210 Alex Vergara Gil
  Ported to class design
  ****************************************************************** }

unit umcmc;

interface

uses
  utypes, ucholesk, urandom, uranmult, unlfit, umachar, uConstants;

type
  TMCMC = class(TBaseOptAlgo)
  private
    FMH_NCycles: Integer;
    FlRNG: TRanMult;
    FMH_SavedSim: Integer;
    FMH_MaxSim: Integer;
    FlRNGIndep: TRanMultIndep;
    FIndep: boolean;
    procedure SetlRNG(const Value: TRanMult);
    procedure SetMH_MaxSim(const Value: Integer);
    procedure SetMH_NCycles(const Value: Integer);
    procedure SetMH_SavedSim(const Value: Integer);
    function Accept(DeltaF, T: Float): boolean;
    procedure CalcSD(V: TMatrix; out S: TVector; Lb, Ub: Integer);
    procedure HastingsCycle(Func: TFuncNVar; T: Float; var X: TVector;
      var V: TMatrix; Lb, Ub: Integer; Indep: boolean; out Xmat: TMatrix;
      out X_min: TVector; var F_min: Float);
    procedure SetlRNGIndep(const Value: TRanMultIndep);
    procedure SetIndep(const Value: boolean);
    property lRNG: TRanMult read FlRNG write SetlRNG; { Random Generator }
    property lRNGIndep: TRanMultIndep read FlRNGIndep write SetlRNGIndep;
  public
    constructor Create(NCycles: Integer = 10; MaxSim: Integer = 1000;
      SavedSim: Integer = 1000); { Initializes Metropolis-Hastings parameters }
    destructor Destroy; override;
    property MH_NCycles: Integer read FMH_NCycles write SetMH_NCycles;
    { Number of cycles }
    property MH_MaxSim: Integer read FMH_MaxSim write SetMH_MaxSim;
    { Max nb of simulations at each cycle }
    property MH_SavedSim: Integer read FMH_SavedSim write SetMH_SavedSim;
    { Nb of simulations to be saved }
    property Indep: boolean read FIndep write SetIndep default true;
    procedure Hastings(Func: TFuncNVar; T: Float; var X: TVector;
      var V: TMatrix; Lb, Ub: Integer; out Xmat: TMatrix; out X_min: TVector;
      out F_min: Float);
  end;

  { ------------------------------------------------------------------
    Simulation of a probability density function by the
    Metropolis-Hastings algorithm
    ------------------------------------------------------------------
    Input parameters :  Func   = Function such that the pdf is
    P(X) = C * Exp(- Func(X) / T)
    T      = Temperature
    X      = Initial mean vector
    V      = Initial variance-covariance matrix
    Lb, Ub = Indices of first and last variables
    ------------------------------------------------------------------
    Output parameters : Xmat  = Matrix of simulated vectors, stored
    row-wise, i.e.
    Xmat[1..MH_SavedSim, Lb..Ub]
    X     = Mean of distribution
    V     = Variance-covariance matrix of distribution
    X_min = Coordinates of minimum of F(X)
    (mode of the distribution)
    F_min = Value of F(X) at minimum
    ------------------------------------------------------------------
    Possible results : MatOk     : No error
    MatNotPD  : The variance-covariance matrix
    is not positive definite
    ------------------------------------------------------------------ }

implementation

procedure TMCMC.CalcSD(V: TMatrix; out S: TVector; Lb, Ub: Integer);
{ ------------------------------------------------------------------
  Computes the standard deviations for independent random numbers
  from the variance-covariance matrix.
  ------------------------------------------------------------------ }
var
  I, ErrCode: Integer;
begin
  I := Lb;
  ErrCode := MatOk;
  DimVector(S, Ub);
  repeat
    if V[I, I] > 0.0 then
      S[I] := Sqrt(V[I, I])
    else
      ErrCode := MatNotPD;
    Inc(I);
  until (ErrCode <> MatOk) or (I > Ub);
  SetErrCode(ErrCode);
end;

function TMCMC.Accept(DeltaF, T: Float): boolean;
{ ------------------------------------------------------------------
  Checks if a variation DeltaF of the function at temperature T is
  acceptable.
  ------------------------------------------------------------------ }
var
  X: Float;
begin
  if DeltaF < 0.0 then
  begin
    Accept := true;
    Exit;
  end;

  X := DeltaF / T;

  if X >= MaxLog then { Exp(- X) ~ 0 }
    Accept := False
  else
    Accept := (Exp(-X) > lRNG.Random3);
end;

procedure TMCMC.HastingsCycle(Func: TFuncNVar; T: Float; var X: TVector;
  var V: TMatrix; Lb, Ub: Integer; Indep: boolean; out Xmat: TMatrix;
  out X_min: TVector; var F_min: Float);
{ ------------------------------------------------------------------
  Performs one cycle of the Metropolis-Hastings algorithm
  ------------------------------------------------------------------ }
var
  F, F1: Float; { Function values }
  DeltaF: Float; { Variation of function }
  Sum: Float; { Statistical sum }
  X1: TVector; { New coordinates }
  L: TMatrix; { Standard dev. or Cholesky factor }
  S: TVector; { Standard deviations }
  I, J, K: Integer; { Loop variables }
  Iter: Integer; { Iteration count }
  FirstSavedSim: Integer; { Index of first simulation to be saved }
begin
  { Dimension arrays }
  DimVector(S, Ub);
  // DimVector(X1, Ub);
  DimMatrix(L, Ub, Ub);
  DimVector(X_min, Ub);
  DimMatrix(Xmat, MH_SavedSim, Ub);

  { Compute SD's or Cholesky factor }
  if Indep then
    CalcSD(V, S, Lb, Ub)
  else
    Cholesky(V, L, Lb, Ub);

  if MathErr = MatNotPD then
    Exit;

  { Compute initial function value }
  F := Func(X);

  { Perform MH_MaxSim simulations at constant temperature }
  FirstSavedSim := MH_MaxSim - MH_SavedSim + 1;
  Iter := 1;
  K := 1;

  repeat
    { Generate new vector }
    if Indep then
      X1 := lRNGIndep.Ran(X, S, Lb, Ub)
    else
      X1 := lRNG.Ran(X, L, Lb, Ub);

    { Compute new function value }
    F1 := Func(X1);
    DeltaF := F1 - F;

    { Check for acceptance }
    if Accept(DeltaF, T) then
    begin
      // Write('.');  { Only for command-line programs }

      for I := Lb to Ub do
        X[I] := X1[I];

      if Iter >= FirstSavedSim then
      begin
        { Save simulated vector into line K of matrix Xmat }
        for I := Lb to Ub do
          Xmat[K, I] := X1[I];
        Inc(K);
      end;

      if F1 < F_min then
      begin
        { Update minimum }
        for I := Lb to Ub do
          X_min[I] := X1[I];
        F_min := F1;
      end;

      F := F1;
      Inc(Iter);
    end;
    DelVector(X1);
  until Iter > MH_MaxSim;

  { Update mean vector }
  for I := Lb to Ub do
  begin
    Sum := 0.0;
    for K := 1 to MH_SavedSim do
      Sum := Sum + Xmat[K, I];
    X[I] := Sum / MH_SavedSim;
  end;

  { Update variance-covariance matrix }
  for I := Lb to Ub do
    for J := I to Ub do
    begin
      Sum := 0.0;
      for K := 1 to MH_SavedSim do
        Sum := Sum + (Xmat[K, I] - X[I]) * (Xmat[K, J] - X[J]);
      V[I, J] := Sum / MH_SavedSim;
    end;

  for I := Succ(Lb) to Ub do
    for J := Lb to Pred(I) do
      V[I, J] := V[J, I];

  DelVector(S);
  DelVector(X1);
  DelMatrix(L);
end;

procedure TMCMC.Hastings(Func: TFuncNVar; T: Float; var X: TVector;
  var V: TMatrix; Lb, Ub: Integer; out Xmat: TMatrix; out X_min: TVector;
  out F_min: Float);
var
  K: Integer;
begin

  K := 1;
  F_min := MaxNum;
  if Indep then
    lRNGIndep := TRanMultIndep.Create(1234543, Ub)
  else
    lRNG := TRanMult.Create(1234543);

  repeat
    HastingsCycle(Func, T, X, V, Lb, Ub, Indep, Xmat, X_min, F_min);
    Indep := False;
    Inc(K);
  until (MathErr <> MatOk) or (K > MH_NCycles);
end;

{ TMCMC }

constructor TMCMC.Create(NCycles, MaxSim, SavedSim: Integer);
begin
  inherited Create;
  if NCycles > 0 then
    MH_NCycles := NCycles;
  if MaxSim > 0 then
    MH_MaxSim := MaxSim;
  if (SavedSim > 0) and (SavedSim <= MaxSim) then
    MH_SavedSim := SavedSim;

end;

destructor TMCMC.Destroy;
begin
  if Indep then
    lRNGIndep.Free
  else
    lRNG.Free;
  inherited Destroy;
end;

procedure TMCMC.SetIndep(const Value: boolean);
begin
  FIndep := Value;
end;

procedure TMCMC.SetlRNG(const Value: TRanMult);
begin
  FlRNG := Value;
end;

procedure TMCMC.SetlRNGIndep(const Value: TRanMultIndep);
begin
  FlRNGIndep := Value;
end;

procedure TMCMC.SetMH_MaxSim(const Value: Integer);
begin
  FMH_MaxSim := Value;
end;

procedure TMCMC.SetMH_NCycles(const Value: Integer);
begin
  FMH_NCycles := Value;
end;

procedure TMCMC.SetMH_SavedSim(const Value: Integer);
begin
  FMH_SavedSim := Value;
end;

end.
