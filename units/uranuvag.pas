{ ******************************************************************
  UVAG The Universal Virtual Array Generator
  by Alex Hay zenjew@hotmail.com
  Adapted to TPMath by Jean Debord
  64 bit generator and OO style by Alex Vergara Gil
  ******************************************************************
  In practice, Cardinal (6-7 times the output of Word) is the
  IntType of choice, but to demonstrate UVAG's scalability here,
  IntType can be defined as any integer data type. IRanUVAG globally
  provides (as rp^) an effectively infinite sequence of IntTypes,
  uniformly distributed (0, 2^(8*sizeof(IntType))-1). Output (bps)
  is dependent solely on IntSize=sizeof(IntType) and CPU speed.  UVAG
  cycles at twice the speed of the 64-bit Mersenne Twister in a tenth
  the memory, tests well in DIEHARD, ENT and NIST and has a huge period.
  It is suitable for cryptographic purposes in that state(n) is not
  determinable from state(n+1).  Most attractive is that it uses integers
  of any size and requires an array of only 255 + sizeof(IntType) bytes.
  Thus it is easily adapted to 128 bits and beyond with negligible
  memory increase.  Lastly, seeding is easy.  From near zero entropy
  (s[]=0, b > 0), UVAG bootstraps itself to full entropy in under
  300 cycles.  Very robust, no bad seeds.

  ****************************************************************** }

unit uranuvag;

interface

uses
  uConstants, urandom;

const
  Intsize32 = sizeof(LongInt);
  IntSize64 = sizeof(int64);

type
  TByteArray32 = array [0 .. (255 + Intsize32)] of Byte;
  TByteArray64 = array [0 .. (255 + IntSize64)] of Byte;

  TRanUVAG = class(TBaseRandomGen)
  private
    s32: TByteArray32;
    b32: LongInt;
    rp32: ^LongInt; { pointer to random LongInt somewhere in s32 }
    s64: TByteArray64;
    b64: int64;
    rp64: ^int64; { pointer to random Int64 somewhere in s64 }
    procedure Init32(KeyPhrase: string);
    procedure Init64(KeyPhrase: string);
  public
    constructor Create(KeyPhrase: string = 'abcd'); overload;
    constructor Create(Seed: LongInt = 1234543); overload;
    function IRan32: LongInt; override;
    function IRan64: int64; override;
    function Random: float; override;
  end;

implementation

uses ustrings;

{ 32 bits }

constructor TRanUVAG.Create(KeyPhrase: string);
begin
  inherited Create;

  Init32(KeyPhrase);
  Init64(KeyPhrase);
end;

constructor TRanUVAG.Create(Seed: LongInt);
var
  S: string;
begin
  inherited Create;
  S := int2str(Seed);
  // Str(Seed, S);
  Init32(S);
  Init64(S);
end;

procedure TRanUVAG.Init32(KeyPhrase: string);
var
  i, kindex, lk: Word;
  temp, tot: Byte;
begin
  lk := Length(KeyPhrase);
  kindex := 1;
  tot := 0;
  { Initialize array }
  for i := 0 to 255 do
  begin
    s32[i] := i;
  end;
  for i := 256 to (255 + Intsize32) do
    s32[i] := i - 256;
  { shuffle array on keyphrase }
  for i := 0 to (255 + Intsize32) do
  begin
    tot := tot + Ord(KeyPhrase[kindex]);
    temp := s32[i];
    s32[i] := s32[tot];
    s32[tot] := temp;
    kindex := kindex + 1;
    if kindex > lk then
      kindex := 1; { wrap around key }
  end;

  rp32 := @s32[0];
  b32 := 1
end;

function TRanUVAG.IRan32: LongInt;
var
  i: Byte;
begin
  b32 := b32 + rp32^;
  rp32^ := rp32^ + b32;
  i := (rp32^ and $0000FF00) shr 8; { MSB of rp^ }
  rp32 := @s32[i];
  Result := rp32^
end;

{ 64 bits }

procedure TRanUVAG.Init64(KeyPhrase: string);
var
  i, kindex, lk: Word;
  temp, tot: Byte;
begin
  lk := Length(KeyPhrase);
  kindex := 1;
  tot := 0;
  { Initialize array }
  for i := 0 to 255 do
  begin
    s64[i] := i;
  end;
  for i := 256 to (255 + IntSize64) do
    s64[i] := i - 256;
  { shuffle array on keyphrase }
  for i := 0 to (255 + IntSize64) do
  begin
    tot := tot + Ord(KeyPhrase[kindex]);
    temp := s64[i];
    s64[i] := s64[tot];
    s64[tot] := temp;
    kindex := kindex + 1;
    if kindex > lk then
      kindex := 1; { wrap around key }
  end;

  rp64 := @s64[0];
  b64 := 1
end;

function TRanUVAG.IRan64: int64;
var
  i: Byte;
begin
  b64 := b64 + rp64^;
  rp64^ := rp64^ + b64;
  i := (rp64^ and $000000000000FF00) shr 8; { MSB of rp^ }
  rp64 := @s64[i];
  Result := rp64^
end;

function TRanUVAG.Random: float;
begin
  Result := 0;
end;

end.
