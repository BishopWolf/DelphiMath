{ ******************************************************************
  Optimization by Genetic Algorithm
  ******************************************************************
  Ref.:  E. Perrin, A. Mandrille, M. Oumoun, C. Fonteix & I. Marc
  Optimisation globale par strategie d'evolution
  Technique utilisant la genetique des individus diploides
  Recherche operationnelle / Operations Research
  1997, 31, 161-201
  Thanks to Magali Camut for her contribution
  Modifications
  20120209 Alex Vergara Gil
  Ported to class design
  ****************************************************************** }

unit ugenalg;

interface

uses
  umachar, uminmax, urandom, unlfit, utypes, math, uConstants;

type
  TGenAlg = class(TBaseOptAlgo)
  private
    FGA_HR: Float;
    FGA_NP: Integer;
    FGA_MR: Float;
    FGA_SR: Float;
    FGA_NG: Integer;
    FWriteLogFile: Boolean;
    FRNG: TRandomGen;
    procedure SetGA_HR(const Value: Float);
    procedure SetGA_MR(const Value: Float);
    procedure SetGA_NG(const Value: Integer);
    procedure SetGA_NP(const Value: Integer);
    procedure SetGA_SR(const Value: Float);
    procedure CompFunc(Func: TFuncNVar; X: TVector; C1, C2, D, P: TMatrix;
      F: TVector; Lb, Ub: Integer; var Iter: Integer; var F_min: Float);
    procedure Cross(I1, I2, I: Integer; C1, C2, D, P: TMatrix; Lb, Ub: Integer);
    function Func(Func: TFuncNVar; I: Integer; P: TMatrix;
      Lb, Ub: Integer): Float;
    procedure GenPop(Func: TFuncNVar; NS: Integer; C1, C2, D, P: TMatrix;
      F, Xmin, Range: TVector; Lb, Ub: Integer);
    procedure Homozygote(I: Integer; C1, C2, P: TMatrix; Lb, Ub: Integer);
    procedure Mutate(I: Integer; C1, C2, D, P: TMatrix; Xmin, Range: TVector;
      Lb, Ub: Integer);
    procedure SetWriteLogFile(const Value: Boolean);
  public
    constructor Create(NP: Integer = 200; NG: Integer = 40; SR: Float = 0.6;
      MR: Float = 0.1; HR: Float = 0.5);
    destructor Destroy; override;
    property GA_NP: Integer read FGA_NP write SetGA_NP default 200;
    { Population size }
    property GA_NG: Integer read FGA_NG write SetGA_NG default 40;
    { Max number of generations }
    property GA_SR: Float read FGA_SR write SetGA_SR; { Survival rate }
    property GA_MR: Float read FGA_MR write SetGA_MR; { Mutation rate }
    property GA_HR: Float read FGA_HR write SetGA_HR;
    { Proportion of homozygotes }
    property WriteLogFile: Boolean read FWriteLogFile write SetWriteLogFile
      default false;
    procedure CreateLogFile(LogFileName: String); { Initialize log file }
    procedure GenAlg(Func: TFuncNVar; var X: TVector; Xmin, Xmax: TVector;
      Lb, Ub: Integer; out F_min: Float);
  end;

implementation

var
  LogFile: Text;

constructor TGenAlg.Create(NP, NG: Integer; SR, MR, HR: Float);
begin
  inherited Create;
  if NP > 0 then
    GA_NP := NP;
  if NG > 0 then
    GA_NG := NG;

  if (SR > 0.0) and (SR < 1.0) then
    GA_SR := SR;
  if (MR > 0.0) and (MR < 1.0) then
    GA_MR := MR;
  if (HR > 0.0) and (HR < 1.0) then
    GA_HR := HR;
  FRNG := TRandomGen.Create(1234543);
end;

procedure TGenAlg.CreateLogFile(LogFileName: String);
begin
  Assign(LogFile, LogFileName);
  Rewrite(LogFile);
  Writeln(LogFile, 'Genetic Algorithm');
  Writeln(LogFile, ' Iter          F ');
  WriteLogFile := True;
end;

procedure TGenAlg.Mutate(I: Integer; C1, C2, D, P: TMatrix;
  Xmin, Range: TVector; Lb, Ub: Integer);
{ ------------------------------------------------------------------
  Mutate individual I
  ------------------------------------------------------------------ }
var
  J: Integer;
begin
  for J := Lb to Ub do
  begin
    C1[I, J] := Xmin[J] + FRNG.Random3 * Range[J];
    C2[I, J] := Xmin[J] + FRNG.Random3 * Range[J];
    D[I, J] := FRNG.Random3;
    P[I, J] := D[I, J] * C1[I, J] + (1.0 - D[I, J]) * C2[I, J];
  end;
end;

procedure TGenAlg.Cross(I1, I2, I: Integer; C1, C2, D, P: TMatrix;
  Lb, Ub: Integer);
{ ------------------------------------------------------------------
  Cross two individuals I1 and I2 --> new individual I
  ------------------------------------------------------------------ }
var
  J, K: Integer;
begin
  for J := Lb to Ub do
  begin
    if FRNG.Random3 < 0.5 then
      K := I1
    else
      K := I2;
    C1[I, J] := C1[K, J];

    if FRNG.Random3 < 0.5 then
      K := I1
    else
      K := I2;
    C2[I, J] := C2[K, J];

    D[I, J] := FRNG.Random3;

    P[I, J] := D[I, J] * C1[I, J] + (1.0 - D[I, J]) * C2[I, J];
  end;
end;

destructor TGenAlg.Destroy;
begin
  FRNG.Free;
  inherited;
end;

procedure TGenAlg.Homozygote(I: Integer; C1, C2, P: TMatrix; Lb, Ub: Integer);
{ ------------------------------------------------------------------
  Make individual I homozygous
  ------------------------------------------------------------------ }
var
  J: Integer;
begin
  for J := Lb to Ub do
  begin
    C1[I, J] := P[I, J];
    C2[I, J] := P[I, J];
  end;
end;

function TGenAlg.Func(Func: TFuncNVar; I: Integer; P: TMatrix;
  Lb, Ub: Integer): Float;
{ ------------------------------------------------------------------
  Computes objective function for individual I
  ------------------------------------------------------------------ }
var
  J: Integer;
  X: TVector;
begin
  DimVector(X, Ub);

  for J := Lb to Ub do
    X[J] := P[I, J];

  Result := Func(X);

  DelVector(X);
end;

procedure TGenAlg.CompFunc(Func: TFuncNVar; X: TVector; C1, C2, D, P: TMatrix;
  F: TVector; Lb, Ub: Integer; var Iter: Integer; var F_min: Float);
{ ------------------------------------------------------------------
  Computes function values
  ------------------------------------------------------------------ }
var
  I, J, K: Integer;
  A: Float;
begin
  { Compute function values }
  for I := 1 to GA_NP do
    F[I] := Self.Func(Func, I, P, Lb, Ub);

  { Sort population according to function values }
  for I := 1 to GA_NP - 1 do
  begin
    K := I;
    A := F[I];

    for J := I + 1 to GA_NP do
      if F[J] < A then
      begin
        K := J;
        A := F[J];
      end;

    Swap(F[I], F[K]);

    for J := Lb to Ub do
    begin
      Swap(C1[I, J], C1[K, J]);
      Swap(C2[I, J], C2[K, J]);
      Swap(D[I, J], D[K, J]);
      Swap(P[I, J], P[K, J]);
    end;
  end;

  { Update log file if necessary }
  if WriteLogFile then
    Writeln(LogFile, Iter:5, F[1]:12);

  { Update minimum }
  if F[1] < F_min then
  begin
    F_min := F[1];
    for J := Lb to Ub do
      X[J] := P[1, J];
  end;

  Inc(Iter);
end;

procedure TGenAlg.GenPop(Func: TFuncNVar; NS: Integer; C1, C2, D, P: TMatrix;
  F, Xmin, Range: TVector; Lb, Ub: Integer);
{ ------------------------------------------------------------------
  Generates new population
  ------------------------------------------------------------------ }
var
  I, I1, I2: Integer;
  F0: Float;
begin
  for I := NS + 1 to GA_NP do
  begin
    I1 := Trunc(FRNG.Random3 * NS) + 1;

    repeat
      I2 := Trunc(FRNG.Random3 * NS) + 1
    until I2 <> I1;

    F0 := Max(F[I1], F[I2]);

    repeat
      Cross(I1, I2, I, C1, C2, D, P, Lb, Ub);
    until Self.Func(Func, I, P, Lb, Ub) <= F0;
  end;

  for I := 1 to GA_NP do
  begin
    if FRNG.Random3 < GA_MR then
      Mutate(I, C1, C2, D, P, Xmin, Range, Lb, Ub);
    if FRNG.Random3 < GA_HR then
      Homozygote(I, C1, C2, P, Lb, Ub);
  end;
end;

procedure TGenAlg.GenAlg(Func: TFuncNVar; var X: TVector; Xmin, Xmax: TVector;
  Lb, Ub: Integer; out F_min: Float);
{ ------------------------------------------------------------------
  Minimization of a function of several variables
  by genetic algorithm
  ------------------------------------------------------------------
  Input parameters : Func   = objective function to be minimized
  X      = initial minimum coordinates
  Xmin   = minimum value of X
  Xmax   = maximum value of X
  Lb, Ub =
  ------------------------------------------------------------------
  Output parameters: X    = refined minimum coordinates
  F_min = function value at minimum
  ------------------------------------------------------------------ }
var
  I, NS, Iter: Integer;
  C1, C2, D, P: TMatrix;
  Range, F: TVector;

begin
  SetErrCode(OptOk);

  { Initialize the random number generator
    using the standard generator }
  { Randomize;
    InitGen(Trunc(Random * 1.0E+8)); }

  { Dimension arrays }
  DimMatrix(C1, GA_NP, Ub);
  DimMatrix(C2, GA_NP, Ub);
  DimMatrix(D, GA_NP, Ub);
  DimMatrix(P, GA_NP, Ub);

  DimVector(F, GA_NP);
  DimVector(Range, Ub);

  for I := Lb to Ub do
    Range[I] := Xmax[I] - Xmin[I];

  NS := Trunc(GA_NP * GA_SR); { Number of survivors }

  Iter := 0;
  F_min := MaxNum;

  for I := 1 to GA_NP do
    Mutate(I, C1, C2, D, P, Xmin, Range, Lb, Ub);

  CompFunc(Func, X, C1, C2, D, P, F, Lb, Ub, Iter, F_min);

  for I := 1 to GA_NG do
  begin
    GenPop(Func, NS, C1, C2, D, P, F, Xmin, Range, Lb, Ub);
    CompFunc(Func, X, C1, C2, D, P, F, Lb, Ub, Iter, F_min);
  end;

  if WriteLogFile then
  begin
    Close(LogFile);
    WriteLogFile := false;
  end;

  DelMatrix(C1);
  DelMatrix(C2);
  DelMatrix(D);
  DelMatrix(P);

  DelVector(F);
  DelVector(Range);
end;

procedure TGenAlg.SetGA_HR(const Value: Float);
begin
  FGA_HR := Value;
end;

procedure TGenAlg.SetGA_MR(const Value: Float);
begin
  FGA_MR := Value;
end;

procedure TGenAlg.SetGA_NG(const Value: Integer);
begin
  FGA_NG := Value;
end;

procedure TGenAlg.SetGA_NP(const Value: Integer);
begin
  FGA_NP := Value;
end;

procedure TGenAlg.SetGA_SR(const Value: Float);
begin
  FGA_SR := Value;
end;

procedure TGenAlg.SetWriteLogFile(const Value: Boolean);
begin
  FWriteLogFile := Value;
end;

end.
