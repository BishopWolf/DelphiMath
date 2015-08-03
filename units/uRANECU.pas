unit uRANECU;

// RANECU Random Engine - algorithm originally written in FORTRAN77
// as part of the MATHLIB HEP library.

interface

uses uConstants, urandom;

type
  TRanECU = class(TBaseRandomGen)
  const
    ecuyer_a = 40014;
    ecuyer_b = 53668;
    ecuyer_c = 12211;
    ecuyer_d = 40692;
    ecuyer_e = 52774;
    ecuyer_f = 3791;
    shift1 = 2147483563;
    shift2 = 2147483399;
    prec = 1 / 2147483648; // } = 4.656612873E-10;
    maxSeq = 215;
    Z1 = 2147483648.0;
  private
    Seed1, Seed2: integer;
    procedure Init(ij, kl: integer);
  public
    constructor Create(ij, kl: integer);
    function IRan32: LongInt; override;
    function IRan64: int64; override;
    function Random: float; override; // [0,1)
  end;

implementation

constructor TRanECU.Create(ij, kl: integer);
begin
  inherited Create;
  Init(ij, kl);
end;

procedure TRanECU.Init(ij, kl: integer);
begin
  Seed1 := ij;
  Seed2 := kl;
end;

function TRanECU.Random: float;
var
  k1, k2, diff: integer;
begin
  k1 := Seed1 div ecuyer_b;
  k2 := Seed2 div ecuyer_e;

  Seed1 := ecuyer_a * (Seed1 - k1 * ecuyer_b) - k1 * ecuyer_c;
  if (Seed1 < 0) then
    Seed1 := Seed1 + shift1;
  Seed2 := ecuyer_d * (Seed2 - k2 * ecuyer_e) - k2 * ecuyer_f;
  if (Seed2 < 0) then
    Seed2 := Seed2 + shift2;

  diff := Seed1 - Seed2;

  if (diff < 0) then
    diff := diff + (shift1 - 1);
  result := diff * prec;
end;

// (trunc(RANECU*Z1)   gives only 31 bits independent taking the upper 28
function TRanECU.IRan32: LongInt;
begin
  result := ((trunc(Random * Z1) shr $3) and $0FFFFFFF)
    XOR ((trunc(Random * Z1) shl $1) and $FFFFFFF0);
end;

function TRanECU.IRan64: int64;
begin
  result := ((trunc(Random * Z1) shr $3) and $000000000FFFFFFF)
    XOR ((trunc(Random * Z1) shl $11) and $0000FFFFFFF00000)
    XOR ((trunc(Random * Z1) shl $21) and $FFFFFFF000000000);
end;

end.
