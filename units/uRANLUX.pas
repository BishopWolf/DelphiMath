unit uRANLUX;

// Ranlux random number generator originally implemented in FORTRAN77
// by Fred James as part of the MATHLIB HEP library.

interface

uses uConstants, urandom;

type
  TRanLUX = class(TBaseRandomGen)
  Const
    Int_modulus = $1000000;
    ecuyer_a = 53668;
    ecuyer_b = 40014;
    ecuyer_c = 12211;
    ecuyer_d = 2147483563;
    lux_levels: array [0 .. 4] of integer = (24, 48, 97, 223, 389);
    // original paper
    // }(0,24,73,199,365);  // proposed by Geant4
  private
    nskip, Luxury: integer;
    FloatSeedTable: array [0 .. 23] of float;
    carry: float;
    i_lag, j_lag, Count24: integer;
    Mantissa_bit_24, Mantissa_bit_12: float;
    procedure Init(Sd, Lux: integer);
  public
    constructor Create(Sd: integer; Lux: integer = 3);
    function IRan32: LongInt; override;
    function IRan64: int64; override;
    function Random: float; override; // [0,1)
  end;

implementation

uses umath;

constructor TRanLUX.Create(Sd, Lux: integer);
begin
  inherited Create;
  Mantissa_bit_24 := intPower(0.5, 24);
  Mantissa_bit_12 := intPower(0.5, 12);
  Init(Sd, Lux);
end;

procedure TRanLUX.Init(Sd, Lux: integer);
var
  i, next_seed: integer;
  k_multiple: integer;
  IntSeedTable: array [0 .. 23] of integer;
begin
  next_seed := Sd;
  if ((Lux > 4) or (Lux < 0)) then
  begin
    if (Lux >= 24) then
    begin
      nskip := Lux; // - 24;
    end
    else
    begin
      nskip := lux_levels[3]; // corresponds to default luxury level
    end;
  end
  else
  begin
    Luxury := Lux;
    nskip := lux_levels[Luxury];
  end;
  for i := 0 to 23 do
  begin
    k_multiple := next_seed div ecuyer_a;
    next_seed := ecuyer_b * (next_seed - k_multiple * ecuyer_a) - k_multiple
      * ecuyer_c;
    if (next_seed < 0) then
      next_seed := next_seed + ecuyer_d;
    IntSeedTable[i] := next_seed mod Int_modulus;
  end;

  for i := 0 to 23 do
    FloatSeedTable[i] := IntSeedTable[i] * Mantissa_bit_24;

  i_lag := 23;
  j_lag := 9;
  carry := 0.;

  if FloatSeedTable[23] = 0 then
    carry := Mantissa_bit_24;

  Count24 := 0;
end;

function TRanLUX.Random: float;
var
  next_random, uni: float;
  i: integer;
begin
  uni := FloatSeedTable[j_lag] - FloatSeedTable[i_lag] - carry;
  if (uni < 0) then
  begin
    uni := uni + 1.0;
    carry := Mantissa_bit_24;
  end
  else
    carry := 0;
  FloatSeedTable[i_lag] := uni;
  i_lag := i_lag - 1;
  j_lag := j_lag - 1;
  if (i_lag < 0) then
    i_lag := 23;
  if (j_lag < 0) then
    j_lag := 23;

  if (uni < Mantissa_bit_12) then
  begin
    uni := uni + Mantissa_bit_24 * FloatSeedTable[j_lag];
    if (uni = 0) then
      uni := Mantissa_bit_24 * Mantissa_bit_24;
  end;
  next_random := uni;
  Count24 := Count24 + 1;
  // every 24th number generation, several random numbers are generated
  // and wasted depending upon the luxury level.

  if (Count24 = 24) then
  begin
    Count24 := 0;
    for i := 0 to nskip - 1 do
    begin
      uni := FloatSeedTable[j_lag] - FloatSeedTable[i_lag] - carry;
      if (uni < 0) then
      begin
        uni := uni + 1.0;
        carry := Mantissa_bit_24;
      end
      else
        carry := 0;
      FloatSeedTable[i_lag] := uni;
      i_lag := i_lag - 1;
      j_lag := j_lag - 1;
      if (i_lag < 0) then
        i_lag := 23;
      if (j_lag < 0) then
        j_lag := 23;
    end;
  end;
  result := next_random;
end;

function TRanLUX.IRan32: LongInt;
// (trunc(RANLUX*int_modulus)   gives only 24 bits independent
begin
  result := ((trunc(Random * Int_modulus) shr $8) and $00FFFFFF)
    XOR (trunc(Random * Int_modulus) and $FFFFFF00);
end;

function TRanLUX.IRan64: int64;
begin
  result := ((trunc(Random * Int_modulus) shr $8) and $0000000000FFFFFF)
    XOR ((trunc(Random * Int_modulus) shl $C) and $00000FFFFFF00000)
    XOR ((trunc(Random * Int_modulus) shl $20) and $FFFFFF0000000000);
end;

end.
