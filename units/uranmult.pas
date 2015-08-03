{ ******************************************************************
  Multinormal distribution
  ****************************************************************** }

unit uranmult;

interface

uses
  utypes, urandist, urandom;

type
  TRanMult = class(TRandomGen)
  private
    Gen: TRanGauss;
  public
    constructor Create(Seed: Integer; gRNG: RNG_Type = RNG_MT);
    destructor Destroy; override;
    Function Ran(M: TVector; L: TMatrix; Lb, Ub: Integer): TVector;
    { ------------------------------------------------------------------
      Generates a random vector X from a multinormal distribution.
      M is the mean vector, L is the Cholesky factor (lower triangular)
      of the variance-covariance matrix.
      ------------------------------------------------------------------ }
  end;

type
  TRanMultIndep = class(TRandomGen)
  private
    Gen: array of TRanGauss;
  public
    function Ran(M, S: TVector; Lb, Ub: Integer): TVector;
    destructor Destroy; override;
    constructor Create(Seed, Ub: Integer; gRNG: RNG_Type = RNG_MT);
    { ------------------------------------------------------------------
      Generates a random vector X from a multinormal distribution with
      uncorrelated variables. M is the mean vector, S is the vector
      of standard deviations.
      ------------------------------------------------------------------ }
  end;

implementation

uses uoperations;

constructor TRanMult.Create(Seed: Integer; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Gen := TRanGauss.Create(Seed);
end;

destructor TRanMult.Destroy;
begin
  Gen.Free;
  inherited Destroy;
end;

Function TRanMult.Ran(M: TVector; L: TMatrix; Lb, Ub: Integer): TVector;
var
  I, J: Integer;
  U: TVector;
begin
  { Form a vector U of independent standard normal variates }
  DimVector(U, Ub);
  DimVector(Result, Ub);
  for I := Lb to Ub do
    U[I] := Gen.random;

  { Form X = M + L * U, which follows the multinormal distribution }
  for I := Lb to Ub do
  begin
    Result[I] := M[I];
    for J := Lb to I do
      Result[I] := Result[I] + L[I, J] * U[J]
  end;

  DelVector(U);
end;

{ TRanMultIndep }

constructor TRanMultIndep.Create(Seed, Ub: Integer; gRNG: RNG_Type);
var
  I: Integer;
begin
  inherited Create(Seed, gRNG);
  SetLength(Gen, Ub);
  for I := 0 to Ub - 1 do
    Gen[I] := TRanGauss.Create(Seed + I);
end;

destructor TRanMultIndep.Destroy;
var
  I: Integer;
begin
  for I := 0 to length(Gen) - 1 do
    Gen[I].Free;
  Finalize(Gen);
  inherited Destroy;
end;

function TRanMultIndep.Ran(M, S: TVector; Lb, Ub: Integer): TVector;
var
  I: Integer;
begin
  DimVector(Result, Ub);
  for I := Lb to Ub do
    Result[I] := M[I] + S[I] * Gen[I].random;
end;

end.
