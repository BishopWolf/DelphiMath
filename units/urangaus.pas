{ ******************************************************************
  Gaussian random numbers
  ****************************************************************** }

unit urangaus;

interface

uses
  utypes, urandom, uConstants;

type
  TRanGauss = class(TRandomGen)
  private
    GaussSave: Float; { Saves a Gaussian number }
    GaussNew: Boolean; { Flags a new calculation }
  public
    constructor Create(seed: integer = 1234543; gRNG: RNG_Type = RNG_MT);
    function RanGaussStd: Float;
    { ------------------------------------------------------------------
      Computes 2 random numbers from the standard normal distribution,
      returns one and saves the other for the next call
      ------------------------------------------------------------------ }

    function RanGauss(Mu, Sigma: Float): Float;
    { ------------------------------------------------------------------
      Returns a random number from a Gaussian distribution
      with mean Mu and standard deviation Sigma
      ------------------------------------------------------------------ }
  end;

implementation

uses umachar, math;

function TRanGauss.RanGaussStd: Float;
var
  R, Theta: Float;
  S, C: Extended;
begin
  if GaussNew then
  begin
    R := Sqrt(-2.0 * Ln(Random3));
    Theta := TwoPi * Random3;
	SinCos(Theta, S, C);
    RanGaussStd := R * C; { Return 1st number }
    GaussSave := R * S; { Save 2nd number }
  end
  else
    RanGaussStd := GaussSave; { Return saved number }
  GaussNew := not GaussNew;
end;

constructor TRanGauss.Create(seed: integer; gRNG: RNG_Type);
begin
  inherited Create(seed, gRNG);
  GaussSave := 0.0;
  GaussNew := true;
end;

function TRanGauss.RanGauss(Mu, Sigma: Float): Float;
begin
  RanGauss := Mu + Sigma * RanGaussStd;
end;

end.
