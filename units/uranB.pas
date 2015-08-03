unit uranB;

{ Barberis Random Number Generator

  Gaston E. Barberis,
  "Non-periodic pseudo-random numbers used in Monte Carlo calculations",
  Physica B 398 (2007) 468-471.

  Unit made by Alex Vergara Gil }

interface

uses uConstants, urandom;

type
  TRanBarberis = class(TBaseRandomGen)
  const
    r = 4.0; // with r=4 the numbers are in the interval (0,1)
    Z1 = 1.0 / 4294967295.0; { 1 / (2^32 - 1) }
  private
    fSeed: float;
    procedure InitRanB(Seed: Cardinal);
    // initializes the Barberis RNG with an integer seed
    procedure Luxury;
  public
    constructor Create(Seed: Cardinal = 1234);
    { ------------------------------------------------------------------
      Returns a 32 bit random number in (-2^31 ; 2^31-1)
      ------------------------------------------------------------------ }
    Function IRan32: LongInt; override;
    Function IRan64: Int64; override;
    Function Random: float; override;
  end;

implementation

uses Math, uNumProc, uRound;

constructor TRanBarberis.Create(Seed: Cardinal);
begin
  inherited Create;
  InitRanB(Seed);
end;

procedure TRanBarberis.InitRanB(Seed: Cardinal);
begin
  fSeed := Seed * Z1;
  if (fSeed * 4 = trunc(fSeed * 4)) then
    fSeed := 0.11; // avoid 0,0.25, 0.5, 0.75 and 1
  Luxury; // to avoid dependence of the sequence from the initial seed
end;

function TRanBarberis.IRan32: Integer;
const
  twooverpi = 2 / Pi;
var
  Y: Integer;
begin
  { Mirroring numbers to place independent bits as most significants }
  Y := { } floor(4294967296 * Random); // } Espejo(floor(4294967296*X));

  { Tempering -Taken from Mersenne Twister- }
  Y := Y xor (Y shr 11);
  Y := Y xor ((Y shl 7) and $9D2C5680);
  Y := Y xor ((Y shl 15) and $EFC60000);
  Y := Y xor (Y shr 18); { }

  Result := Y;
end;

function TRanBarberis.IRan64: Int64;
begin
  Result := IRan32 xor (IRan32 shl 32)
end;

procedure TRanBarberis.Luxury;
const
  lux = 300;
var
  i: Integer;
begin
  { Luxury con 300 numeros }
  for i := 1 to lux do
    fSeed := r * fSeed * (1 - fSeed);
end;

function TRanBarberis.Random: float;
const
  twooverpi = 2 / Pi;
begin
  fSeed := r * fSeed * (1 - fSeed); // logistic map
  Result := twooverpi * ArcSin(sqrt(fSeed)); // Ulam-Newmann transformation
  Luxury;
end;

end.
