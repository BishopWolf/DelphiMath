unit uRanXorShift;

{ Unit uRanXorShift : Xor Shift Random generator Unit

  Created by : Alex Vergara Gil

  Contains the Xor Shift Random generator

}

interface

uses
  uConstants, urandom;

type
  TRanXorShift = class(TBaseRandomGen)
  private
    RandSeed32, triple: LongInt;
    RandSeed64: int64;
    procedure InitRXS(Seed, triple32: LongInt);
    { ------------------------------------------------------------------
      Initializes the 'XorShift' random number generator.
      The default initialization corresponds to InitRXS(118105245,0)
      wich means a =  1; b =  3; c = 10  for 32 bits and
      a = 21; b = 35; c = 4   for 64 bits
      and the method y^=y<<a;y^=y>>b;y^=y<<c described on:
      Journal of Modern Applied Statistical Methods,
      May, 2003, Vol.2,No.1,2-13
      "Random Numbers Generators" (George Marsaglia);
      triple32 must be in [1..81] interval
      ------------------------------------------------------------------ }

  public
    Constructor Create(Seed: LongInt = 118105245; triple32: LongInt = 0);
    function IRan32: LongInt; override;
    { ------------------------------------------------------------------
      Returns a 32 bit random number in [-2^31 ; 2^31-1] interval
      ------------------------------------------------------------------ }
    function IRan64: int64; override;
    function Random: float; override;
  end;

implementation

procedure TRanXorShift.InitRXS(Seed, triple32: LongInt);
begin
  RandSeed32 := Seed or $10001;
  RandSeed64 := Seed or $100010001;
  triple := triple32;
end;

function TRanXorShift.IRan32: LongInt;
var
  i: integer;
const
  la: array [0 .. 80] of byte = (1, 1, 1, 2, 2, 3, 3, 3, 4, 5, 5, 5, 6, 7, 7, 9,
    10, 11, 13, 14, 17, 1, 1, 2, 2, 2, 3, 3, 3, 5, 5, 5, 5, 6, 7, 7, 9, 10, 11,
    13, 15, 1, 1, 2, 2, 3, 3, 3, 4, 5, 5, 5, 6, 6, 7, 8, 9, 11, 12, 13, 17, 1,
    1, 2, 2, 3, 3, 3, 4, 5, 5, 5, 6, 7, 7, 8, 9, 11, 13, 14, 17);
  lb: array [0 .. 80] of byte = (3, 11, 27, 7, 15, 3, 5, 25, 5, 9, 17, 27, 17,
    1, 25, 5, 9, 17, 3, 13, 15, 5, 11, 5, 7, 21, 3, 7, 27, 3, 9, 21, 27, 21, 1,
    25, 5, 9, 21, 5, 1, 5, 19, 5, 9, 1, 5, 13, 3, 7, 13, 27, 1, 21, 13, 7, 11,
    7, 9, 17, 15, 9, 21, 7, 15, 3, 5, 23, 3, 9, 15, 27, 3, 1, 17, 9, 21, 7,
    3, 1, 15);
  lc: array [0 .. 80] of byte = (10, 6, 27, 9, 25, 28, 25, 24, 15, 28, 13, 25,
    9, 18, 12, 1, 21, 13, 27, 15, 26, 16, 16, 15, 25, 9, 29, 29, 11, 21, 31, 12,
    28, 7, 25, 20, 25, 25, 13, 19, 29, 19, 3, 21, 15, 14, 20, 7, 17, 22, 6, 8,
    11, 13, 25, 23, 19, 12, 23, 15, 20, 29, 20, 7, 17, 26, 22, 25, 27, 7, 17,
    21, 17, 9, 21, 23, 16, 16, 17, 15, 23);
begin
  triple := triple mod 81;
  for i := 1 to 31 do
  begin
    RandSeed32 := RandSeed32 xor (RandSeed32 shl la[triple]);
    RandSeed32 := RandSeed32 xor (RandSeed32 shr lb[triple]);
    RandSeed32 := RandSeed32 xor (RandSeed32 shl lc[triple]);
  end;
  Result := RandSeed32;
end;

function TRanXorShift.IRan64: int64;
var
  i: integer;
const
  la: array [0 .. 8] of byte = (21, 20, 17, 11, 14, 30, 21, 21, 23);
  lb: array [0 .. 8] of byte = (35, 41, 31, 29, 29, 35, 37, 43, 41);
  lc: array [0 .. 8] of byte = (4, 5, 8, 14, 11, 13, 4, 4, 18);
begin
  triple := triple mod 9;
  for i := 1 to 31 do
  begin
    RandSeed64 := RandSeed64 xor (RandSeed64 shl la[triple]);
    RandSeed64 := RandSeed64 xor (RandSeed64 shr lb[triple]);
    RandSeed64 := RandSeed64 xor (RandSeed64 shl lc[triple]);
  end;
  Result := RandSeed64;
end;

function TRanXorShift.Random: float;
begin
  Result := 0;
end;

{ TRanXorShift }

constructor TRanXorShift.Create(Seed, triple32: LongInt);
begin
  inherited Create;
  InitRXS(Seed, triple32);
end;

end.
