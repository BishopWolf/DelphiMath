{ ******************************************************************
  Optimization by Simulated Annealing
  ******************************************************************
  Adapted from Fortran program SIMANN by Bill Goffe:
  http://www.netlib.org/opt/simann.f

  Modifications
  20120210 Alex Vergara Gil
  Ported to class design
  ****************************************************************** }

unit usimann;

interface

uses
  utypes, urandom, umedian, unlfit, umachar, uConstants;

type
  TSimAnn = class(TBaseOptAlgo)
  private
    FSA_NCycles: Integer;
    FSA_RT: Float;
    FSA_NS: Integer;
    FSA_NT: Integer;
    FlRNG: TRandomGen;
    procedure SetSA_NCycles(const Value: Integer);
    procedure SetSA_NS(const Value: Integer);
    procedure SetSA_NT(const Value: Integer);
    procedure SetSA_RT(const Value: Float);
    function Accept(DeltaF, T: Float; var N_inc, N_acc: Integer): Boolean;
    function InitTemp(Func: TFuncNVar; X, Xmin, Range: TVector;
      Lb, Ub: Integer): Float;
    procedure SimAnnCycle(Func: TFuncNVar; var X: TVector; Xmin, Xmax: TVector;
      Lb, Ub: Integer; out F_min: Float);
    procedure SetlRNG(const Value: TRandomGen);
    property lRNG: TRandomGen read FlRNG write SetlRNG; { Random Generator }
  public
    constructor Create(NT: Integer = 5; NS: Integer = 15; NCycles: Integer = 1;
      RT: Float = 0.9);
    destructor Destroy; override;
    property SA_NT: Integer read FSA_NT write SetSA_NT;
    { Number of loops at constant temperature }
    property SA_NS: Integer read FSA_NS write SetSA_NS;
    { Number of loops before step adjustment }
    property SA_RT: Float read FSA_RT write SetSA_RT;
    { Temperature reduction factor }
    property SA_NCycles: Integer read FSA_NCycles write SetSA_NCycles;
    { Number of cycles }
    procedure SimAnn(Func: TFuncNVar; var X: TVector; Xmin, Xmax: TVector;
      Lb, Ub: Integer; out F_min: Float);
    procedure SA_CreateLogFile(FileName: String); { Initialize log file }
  end;

  { ------------------------------------------------------------------
    Minimization of a function of several var. by simulated annealing
    ------------------------------------------------------------------
    Input parameters : Func   = objective function to be minimized
    X      = initial minimum coordinates
    Xmin   = minimum value of X
    Xmax   = maximum value of X
    Lb, Ub = indices of first and last variables
    ------------------------------------------------------------------
    Output parameter : X      = refined minimum coordinates
    F_min  = function value at minimum
    ------------------------------------------------------------------ }

implementation

{ Log file headers }
const
  Hdr1 = 'Simulated annealing: Cycle ';
  Hdr2 = 'Iter         T              F        Inc    Acc';

var
  LogFile: Text;
  WriteLogFile: Boolean;

Constructor TSimAnn.Create(NT, NS, NCycles: Integer; RT: Float);
begin
  inherited Create;
  if NT > 0 then
    SA_NT := NT;
  if NS > 0 then
    SA_NS := NS;
  if NCycles > 1 then
    SA_NCycles := NCycles;
  if (RT > 0.0) and (RT < 1.0) then
    SA_RT := RT;
  lRNG := TRandomGen.Create(1234543);
end;

destructor TSimAnn.Destroy;
begin
  lRNG.Free;
  inherited;
end;

procedure TSimAnn.SA_CreateLogFile(FileName: String);
begin
  Assign(LogFile, FileName);
  Rewrite(LogFile);
  WriteLogFile := True;
end;

function TSimAnn.InitTemp(Func: TFuncNVar; X, Xmin, Range: TVector;
  Lb, Ub: Integer): Float;
{ ------------------------------------------------------------------
  Computes the initial temperature so that the probability
  of accepting an increase of the function is about 0.5
  ------------------------------------------------------------------ }
const
  N_EVAL = 50; { Number of function evaluations }
var
  F, F1: Float; { Function values }
  DeltaF: TVector; { Function increases }
  N_inc: Integer; { Number of function increases }
  I: Integer; { Index of function evaluation }
  K: Integer; { Index of parameter }
begin
  DimVector(DeltaF, N_EVAL);

  N_inc := 0;
  F := Func(X);

  { Compute N_EVAL function values, changing each parameter in turn }
  K := Lb;
  for I := 1 to N_EVAL do
  begin
    X[K] := Xmin[K] + lRNG.Random3 * Range[K];
    F1 := Func(X);
    if F1 > F then
    begin
      Inc(N_inc);
      DeltaF[N_inc] := F1 - F;
    end;
    F := F1;
    Inc(K);
    if K > Ub then
      K := Lb;
  end;

  { The median M of these N_inc increases has a probability of 1/2.
    From Boltzmann's formula: Exp(-M/T) = 1/2 ==> T = M / Ln(2) }
  if N_inc > 0 then
    InitTemp := Median(DeltaF, 1, N_inc) * InvLn2
  else
    InitTemp := 1.0;

  DelVector(DeltaF);
end;

function TSimAnn.Accept(DeltaF, T: Float; var N_inc, N_acc: Integer): Boolean;
{ ----------------------------------------------------------------------
  Checks if a variation DeltaF of the function at temperature T is
  acceptable. Updates the counters N_inc (number of increases of the
  function) and N_acc (number of accepted increases).
  ---------------------------------------------------------------------- }
var
  X: Float;
begin
  if DeltaF < 0.0 then
  begin
    Accept := True;
    Exit;
  end;

  Inc(N_inc);
  X := DeltaF / T;

  if X > MaxLog then { Exp(- X) ~ 0 }
  begin
    Accept := False;
    Exit;
  end;

  if Exp(-X) > lRNG.Random3 then
  begin
    Accept := True;
    Inc(N_acc);
  end
  else
    Accept := False;
end;

procedure TSimAnn.SimAnnCycle(Func: TFuncNVar; var X: TVector;
  Xmin, Xmax: TVector; Lb, Ub: Integer; out F_min: Float);
{ ------------------------------------------------------------------
  Performs one cycle of simulated annealing
  ------------------------------------------------------------------ }
const
  SFact = 2.0; { Factor for step reduction }
  MinTemp = 1.0E-30; { Min. temperature }
  MinFunc = 1.0E-30; { Min. function value }
var
  I, Iter, J, K, N_inc, N_acc: Integer;
  F, F1, DeltaF, Ratio, T, OldX: Float;
  Range, DeltaX, Xopt: TVector;
  Nacc: TIntVector;
begin
  DimVector(Range, Ub);
  DimVector(DeltaX, Ub);
  DimVector(Xopt, Ub);
  DimVector(Nacc, Ub);

  { Determine parameter range, step and optimum }
  for K := Lb to Ub do
  begin
    Range[K] := Xmax[K] - Xmin[K];
    DeltaX[K] := 0.5 * Range[K];
    Xopt[K] := X[K];
  end;

  { Initialize function values }
  F := Func(X);
  F_min := F;

  { Initialize temperature and iteration count }
  T := InitTemp(Func, X, Xmin, Range, Lb, Ub);
  Iter := 0;

  repeat
    N_inc := 0;
    N_acc := 0;

    { Perform SA_NT evaluations at constant temperature }
    for I := 1 to SA_NT do
    begin
      for J := 1 to SA_NS do
        for K := Lb to Ub do
        begin
          { Save current parameter value }
          OldX := X[K];

          { Pick new value, keeping it within Range }
          X[K] := X[K] + (2.0 * lRNG.Random3 - 1.0) * DeltaX[K];
          if (X[K] < Xmin[K]) or (X[K] > Xmax[K]) then
            X[K] := Xmin[K] + lRNG.Random3 * Range[K];

          { Compute new function value }
          F1 := Func(X);
          DeltaF := F1 - F;

          { Check for acceptance }
          if Accept(DeltaF, T, N_inc, N_acc) then
          begin
            Inc(Nacc[K]);
            F := F1;
          end
          else
            { Restore parameter value }
            X[K] := OldX;

          { Update minimum if necessary }
          if F < F_min then
          begin
            Xopt[K] := X[K];
            F_min := F;
          end;
        end;

      { Ajust step length to maintain an acceptance
        ratio of about 50% for each parameter }
      for K := Lb to Ub do
      begin
        Ratio := Nacc[K] / SA_NS;
        if Ratio > 0.6 then
        begin
          { Increase step length, keeping it within Range }
          DeltaX[K] := DeltaX[K] * (1.0 + ((Ratio - 0.6) / 0.4) * SFact);
          if DeltaX[K] > Range[K] then
            DeltaX[K] := Range[K];
        end
        else if Ratio < 0.4 then
          { Reduce step length }
          DeltaX[K] := DeltaX[K] / (1.0 + ((0.4 - Ratio) / 0.4) * SFact);

        { Restore counter }
        Nacc[K] := 0;
      end;
    end;

    if WriteLogFile then
      WriteLn(LogFile, Iter:4, '   ', T:12, '   ', F:12, N_inc:6, N_acc:6);

    { Update temperature and iteration count }
    T := T * SA_RT;
    Inc(Iter);
  until (N_acc = 0) or (T < MinTemp) or (Abs(F_min) < MinFunc);

  for K := Lb to Ub do
    X[K] := Xopt[K];

  DelVector(Range);
  DelVector(DeltaX);
  DelVector(Xopt);
  DelVector(Nacc);
end;

procedure TSimAnn.SimAnn(Func: TFuncNVar; var X: TVector; Xmin, Xmax: TVector;
  Lb, Ub: Integer; out F_min: Float);
var
  Cycle: Integer;
begin
  SetErrCode(OptOk);

  for Cycle := 1 to SA_NCycles do
  begin
    if WriteLogFile then
    begin
      WriteLn(LogFile, Hdr1, Cycle);
      WriteLn(LogFile);
      WriteLn(LogFile, Hdr2);
    end;

    SimAnnCycle(Func, X, Xmin, Xmax, Lb, Ub, F_min);
  end;

  if WriteLogFile then
  begin
    Close(LogFile);
    WriteLogFile := False;
  end;
end;

{ TSimAnn }

procedure TSimAnn.SetlRNG(const Value: TRandomGen);
begin
  FlRNG := Value;
end;

procedure TSimAnn.SetSA_NCycles(const Value: Integer);
begin
  FSA_NCycles := Value;
end;

procedure TSimAnn.SetSA_NS(const Value: Integer);
begin
  FSA_NS := Value;
end;

procedure TSimAnn.SetSA_NT(const Value: Integer);
begin
  FSA_NT := Value;
end;

procedure TSimAnn.SetSA_RT(const Value: Float);
begin
  FSA_RT := Value;
end;

begin

  WriteLogFile := False;

end.
