{ ******************************************************************
  Random number generators
  ****************************************************************** }

unit urandom;

interface

uses
  uConstants;

{ ------------------------------------------------------------------
  Random number generators
  ------------------------------------------------------------------ }

type
  RNG_Type = (RNG_Delphi, { Delphi's own generator }
    RNG_Barberis, { Barberis }
    RNG_XorShift, { XorShift }
    RNG_MWC, { Marsaglia's Multiply-With-Carry }
    RNG_MT, { Mersenne Twister }
    RNG_UVAG, { Universal Virtual Array Generator }
    RNG_RANMAR, { RANMAR Geant4 generator }
    RNG_RANECU, { RANECU FORTRAN77 generator }
    RNG_RANLUX); { RANLUX FORTRAN77 generator }

  TBaseRandomGen = class
  public
    Function IRan32: LongInt; virtual; abstract;
    Function IRan64: Int64; virtual; abstract;
    function Random: float; virtual; abstract;
  end;

  TRanDelphi = class(TBaseRandomGen)
  public
    constructor Create(seed: LongInt);
    Function IRan32: LongInt; override;
    Function IRan64: Int64; override;
    function Random: float; override;
  end;

  TRandomGen = class
  const
    Z = 1.0 / 4294967296.0; { 1 / 2^32 }
    Z1 = 1.0 / 4294967295.0; { 1 / (2^32 - 1) }
    Z2 = 1.0 / 9007199254740992.0; { 1 / 2^53 }
    Z53 = 1.0 / 9007199254740991.0; { 1 / (2^53-1) }
    Z52 = 1.0 / 4503599627370496.0; { 1 / 2^52 }
    Z63 = 1.0 / 9223372036854775808.0; { 1/ 2^63 }
    Z631 = 1.0 / 9223372036854775807.0; { 1/ (2^63-1) }
    CWarm = 1000; { A constant for warming up the generator }
    CRANMAR = 16777216 / 16777213;
    CRANMAR1 = 1 / 16777216;
    CRANECU = 2147483648 / 2147483563;
    CRANECU1 = 42 / 2147483648;
  private
    lRNG: TBaseRandomGen;
    FUse64bitsFloat: Boolean;
    procedure WarmUp;
    function IRanGen31: Cardinal; { 31-bit random integer in [0 .. 2^31 - 1] }
    function IRanGen63: Int64;
    procedure SetUse64bitsFloat(const Value: Boolean);
    { 63-bit random integer in [0 .. 2^63 - 1] }
  public
    RNG: RNG_Type;
    property Use64bitsFloat: Boolean read FUse64bitsFloat
      write SetUse64bitsFloat;
    constructor Create(seed: integer = 1234543; gRNG: RNG_Type = RNG_MT);
    destructor Destroy; override;
    procedure InitGen(seed: LongInt); { Initialize generator }
    function IRan32: LongInt; { 32-bit random integer in [-2^31 .. 2^31 - 1] }
    function IRan64: Int64; { 64-bit random integer in [-2^63 .. 2^63 - 1] }
    function Random1: float; { 32-bit random real in [0,1]
      63-bit random real in [0,1] if 64 bit RNG }
    function Random2: float; { 32-bit random real in [0,1)
      63-bit random real in [0,1) if 64 bit RNG }
    function Random3: float; { 32-bit random real in (0,1)
      63-bit random real in (0,1) if 64 bit RNG }
    function Random53: float;
    { 53-bit random real in [0,1) using 2 32-bits generators }
    function RandomMN(Ni, Nf: float): float; overload;
    { returns random number on interval (Ni,Nf) }
    function RandomMN(Ni, Nf: integer): integer; overload;
  end;

implementation

uses
  uranmwc, uranmt, uranuvag, uranxorshift, uranB, uRANMAR, uRANECU, uRANLUX,
  uNumProc, uinterpolation;

constructor TRandomGen.Create(seed: integer; gRNG: RNG_Type);
begin
  inherited Create;
  Use64bitsFloat := (sizeof(float) >= 8);
  RNG := gRNG;
  InitGen(seed);
  WarmUp;
end;

destructor TRandomGen.Destroy;
begin
  lRNG.Free;
  inherited Destroy;
end;

procedure TRandomGen.InitGen(seed: LongInt);
begin
  case RNG of
    RNG_Delphi:
      lRNG := TRanDelphi.Create(seed);
    RNG_Barberis:
      lRNG := TRanBarberis.Create(seed);
    RNG_XorShift:
      lRNG := TRanXorShift.Create(seed);
    RNG_MWC:
      lRNG := TRanMWC.Create(seed);
    RNG_MT:
      lRNG := TRanMT.Create(seed);
    RNG_UVAG:
      lRNG := TRanUVAG.Create(seed);
    RNG_RANMAR:
      lRNG := TRanMar.Create(seed, Espejo(seed shl 1) xor $6AAAAAAA);
    RNG_RANECU:
      lRNG := TRanECU.Create(seed, Espejo(seed shl 1) xor $6AAAAAAA);
    RNG_RANLUX:
      lRNG := TRanLUX.Create(seed);
  end;
end;

function TRandomGen.IRan32: LongInt;
begin
  Result := lRNG.IRan32;
  // If 64 bits number wanted use IRan64 instead!!!
end;

function TRandomGen.IRan64: Int64;
begin
  Result := lRNG.IRan64;
  // If 32 bits number wanted use IRan32 instead!!!
end;

function TRandomGen.IRanGen31: Cardinal;
begin
  if (RNG in [RNG_Delphi, RNG_Barberis, RNG_RANECU, RNG_RANMAR, RNG_RANLUX])
  then
    IRanGen31 := trunc(lRNG.Random * 2147483648)
  else
    IRanGen31 := IRan32 shr 1;
end;

function TRandomGen.IRanGen63: Int64;
begin
  IRanGen63 := IRan64 shr 1;
end;

function TRandomGen.Random1: float; // [0,1]
begin
  if (RNG in [RNG_Delphi, RNG_Barberis, RNG_RANMAR, RNG_RANECU, RNG_RANLUX])
  then
    Result := lRNG.Random * CRANMAR
  else if Use64bitsFloat then
    Result := IRanGen63 * Z631
  else
    Result := (IRan32 + 2147483648.0) * Z1;
end;

function TRandomGen.Random2: float; // [0,1)
begin
  if (RNG in [RNG_Delphi, RNG_Barberis, RNG_RANMAR, RNG_RANECU, RNG_RANLUX])
  then
    Result := lRNG.Random
  else if Use64bitsFloat then
    Result := IRanGen63 * Z63
  else
    Result := (IRan32 + 2147483648.0) * Z;
end;

function TRandomGen.Random3: float; // (0,1)
begin
  case RNG of
    RNG_Delphi, RNG_Barberis, RNG_RANMAR, RNG_RANLUX:
      Result := lRNG.Random + CRANMAR1;
    RNG_RANECU:
      Result := lRNG.Random + CRANECU1;
  else
    if Use64bitsFloat then
      Result := (IRanGen63 + 0.5) * Z63
    else
      Result := (IRan32 + 2147483648.5) * Z;
  end;
end;

function TRandomGen.Random53: float;
var
  A, B: Int64;
begin
  A := IRan32 shr 5;
  B := IRan32 shr 6;

  Result := (A * 67108864.0 + B) * Z2;
end;

function TRandomGen.RandomMN(Ni, Nf: float): float;
begin
  // Assert(Nf>Ni,'Nf tiene que ser mayor que Ni');
  Result := LinealInterpolation(0, Ni, 1, Nf, Random1);
end;

function TRandomGen.RandomMN(Ni, Nf: integer): integer;
begin
  // Assert(Nf>Ni,'Nf tiene que ser mayor que Ni');
  Result := round(LinealInterpolation(0, Ni, 1, Nf, Random1));
end;

procedure TRandomGen.SetUse64bitsFloat(const Value: Boolean);
begin
  FUse64bitsFloat := Value;
end;

procedure TRandomGen.WarmUp;
var
  i: integer;
begin
  for i := 1 to CWarm do
    Random1;
end;

{ TRanDelphi }

constructor TRanDelphi.Create(seed: integer);
begin
  inherited Create;
  RandSeed := seed;
end;

function TRanDelphi.IRan32: LongInt;
begin
  Result := trunc(((Random * 2) - 1) * 2147483647);
end;

function TRanDelphi.IRan64: Int64;
begin
  Result := (IRan32 shl 32) xor IRan32;
end;

function TRanDelphi.Random: float;
begin
  Result := system.Random;
end;

end.
