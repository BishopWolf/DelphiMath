{ ******************************************************************
  Marsaglia's Multiply-With-Carry random number generator
  ****************************************************************** }

unit uranmwc;

interface

uses
  uConstants, urandom;

type
  TRanMWC = class(TBaseRandomGen)
  const
    { 32 bits }
    Lower_Mask = $FFFF; // 65535=2^16-1  mask for least significant 16 bits
    M1 = 18000; // Multiplier for most significant 16 bits
    // M1*2^16-1 must be prime =>  1179647999 is prime
    M2 = 30903; // Multiplier for least significant 16 bits
    // M2*2^16-1 must be prime =>  2025259007 is prime
    // check both with uNumProc.IsPrime(number);
    { 64 bits }
    Lower_Mask64 = $FFFFFFFF;
    // 4294967295=2^32-1  mask for least significant 32 bits
    M3 = 100065; // Multiplier for most significant 32 bits
    // M1*2^32-1 must be prime =>  429775902474239 is prime
    M4 = 300077; // Multiplier for least significant 32 bits
    // M2*2^32-1 must be prime =>  1288820901281791 is prime
    // check both with uNumProc.IsPrime(number);
  private
    { 32 bits }
    X1, X2: LongInt; { Uniform random integers }
    C1, C2: LongInt; { Carries }
    { 64 bits }
    X3, X4: Int64; { Uniform random integers }
    C3, C4: Int64; { Carries }
    procedure Init32(Seed: LongInt = 118105245); { X1 = 1802, X2 = 9373 }
    procedure Init64(Seed: Int64 = 7739531076765); { X3 = 1802, X4 = 9373 }
  public
    Constructor Create(Seed: LongInt);
    function IRan32: LongInt; override;
    function IRan64: Int64; override;
    function Random: float; override;
  end;

implementation

uses uNumProc;

constructor TRanMWC.Create(Seed: Integer);
begin
  inherited Create;
  Init32(Seed);
  Init64(Seed);
end;

procedure TRanMWC.Init32(Seed: LongInt);
begin
  // First XorShift the Seed to avoid zeros
  Seed := Seed or $10001; // avoiding Seed=0
  Seed := Seed xor (Seed shl 10);
  Seed := Seed xor (Seed shr 3);
  Seed := Seed xor (Seed shl 1);
  // Then mask the initial seed of both generators
  X1 := Seed shr 16;
  X2 := Seed and Lower_Mask;
  // The following lines are obsolete
  { if (X1=0) and (X2<>0) then X1:=Espejo(smallint(X2))  //X1 must be nonzero
    else if (X2=0) and (X1<>0) then X2:=Espejo(smallint(X1)) //X2 must be nonzero
    else
    if (Seed=0) then begin
    X1 := 1802; X2 := 9373;  //Default initialization if seed is zero
    end; }
  // Initialize Carries
  C1 := 0;
  C2 := 0;
end;

function TRanMWC.IRan32: LongInt;
var
  Y1, Y2: LongInt;
begin
  { Most significant 16 bits }
  Y1 := M1 * X1 + C1;
  Y1 := Y1 xor (Y1 shl 1);
  Y1 := Y1 xor (Y1 shr 3);
  Y1 := Y1 xor (Y1 shl 10);
  X1 := Y1 and Lower_Mask;
  C1 := Y1 shr 16;
  { Least significant 16 bits }
  Y2 := M2 * X2 + C2;
  Y2 := Y2 xor (Y2 shl 17);
  Y2 := Y2 xor (Y2 shr 15);
  Y2 := Y2 xor (Y2 shl 23);
  X2 := Y2 and Lower_Mask;
  C2 := Y2 shr 16;
  { Combine into a 32 bit integer }
  Result := (X1 shl 16) + X2;
end;

{ 64 bits }

procedure TRanMWC.Init64(Seed: Int64);
begin
  // First XorShift the Seed to avoid zeros
  Seed := Seed or $100000001; // avoiding Seed=0
  Seed := Seed xor (Seed shl 17);
  Seed := Seed xor (Seed shr 29);
  Seed := Seed xor (Seed shl 47);
  // Then mask the initial seed of both generators
  X3 := Seed shr 32;
  X4 := Seed and Lower_Mask64;
  // The following lines are obsolete
  { if (X3=0) and (X4<>0) then X3:=Espejo(Cardinal(X4))  //X3 must be nonzero
    else if (X4=0) and (X3<>0) then X4:=Espejo(Cardinal(X3)) //X4 must be nonzero
    else if (Seed=0) then begin
    X3 := 1802; X4 := 9373;  //Default initialization if seed is zero
    end; }
  // Initialize Carries
  C3 := 0;
  C4 := 0;
end;

function TRanMWC.IRan64: Int64;
var
  Y3, Y4: Int64;
begin
  { Most significant 32 bits }
  Y3 := M3 * X3 + C3;
  Y3 := Y3 xor (Y3 shl 17);
  Y3 := Y3 xor (Y3 shr 31);
  Y3 := Y3 xor (Y3 shl 8);
  X3 := Y3 and Lower_Mask64;
  C3 := Y3 shr 32;
  { Least significant 32 bits }
  Y4 := M4 * X4 + C4;
  Y4 := Y4 xor (Y4 shl 14);
  Y4 := Y4 xor (Y4 shr 29);
  Y4 := Y4 xor (Y4 shl 11);
  X4 := Y4 and Lower_Mask64;
  C4 := Y4 shr 32;
  { Combine into a 64 bit integer }
  Result := (X3 shl 32) + X4;
end;

function TRanMWC.Random: float;
begin
  Result := 0;
end;

end.
