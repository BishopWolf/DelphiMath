unit uRANMAR;

{ taked from Function: ranmar.c
  Random number generator, obtained from F. James, CERN Data Division.
  A call to ranmar() returns a random number between 0 and 1 with the last 8 bits dependent.
  A call to IRANMAR32 returns a 32 bit signed integer.
  A call to IRANMAR64 returns a 64 bit signed integer.
  Before calling, the random number generator has to be initialized by calling
  InitRanMAR with two integer seeds, otherwise the RNG takes default initialization. }

interface

uses uConstants, urandom;

type
  TRanMar = class(TBaseRandomGen)
  const
    cmax = $1000000;
  private
    { global variables for ranmar }
    c, cd, cm: float;
    u: array [0 .. 96] of float;
    i97, j97: integer;
    procedure Init(ij, kl: integer);
  public
    constructor Create(ij, kl: integer);
    function IRan32: LongInt; override;
    function IRan64: int64; override;
    function Random: float; override; // [0,1)
  end;

implementation

constructor TRanMar.Create(ij, kl: integer);
begin
  inherited Create;
  Init(ij, kl);
end;

procedure TRanMar.Init(ij, kl: integer);
var
  i, ii, j, jj, k, l, m: integer;
  s, t: float;
begin
  i := ((ij div 177) mod 177) + 2;
  j := (ij mod 177) + 2;
  k := ((kl div 169) mod 178) + 1;
  l := kl mod 169;
  for ii := 0 to 96 do
  begin
    s := 0.0;
    t := 0.5;
    for jj := 0 to 23 do
    begin
      m := (((i * j) mod 179) * k) mod 179;
      i := j;
      j := k;
      k := m;
      l := (53 * l + 1) mod 169;
      if (((l * m) mod 64) >= 32) then
        s := s + t;
      t := t * 0.5;
    end;
    u[ii] := s;
  end;
  c := 362436.0 / cmax;
  cd := 7654321.0 / cmax;
  cm := 16777213.0 / cmax;
  i97 := 96;
  j97 := 32;
end;

function TRanMar.Random: float; // [0,1)
var
  uni: float;
begin
  uni := u[i97] - u[j97];
  if (uni < 0.0) then
    uni := uni + 1.0;
  u[i97] := uni;
  dec(i97);
  if (i97 < 0) then
    i97 := 96;
  dec(j97);
  if (j97 < 0) then
    j97 := 96;
  c := c - cd;
  if (c < 0.0) then
    c := c + cm;
  uni := uni - c;
  if (uni < 0.0) then
    uni := uni + 1.0;
  result := uni;
end;

function TRanMar.IRan32: LongInt;
// (trunc(RANMAR*cmax)   gives only 24 bits independent
begin
  result := ((trunc(Random * cmax) shr $8) and $00FFFFFF)
    XOR (trunc(Random * cmax) and $FFFFFF00);
end;

function TRanMar.IRan64: int64;
begin
  result := ((trunc(Random * cmax) shr $8) and $0000000000FFFFFF)
    XOR ((trunc(Random * cmax) shl $C) and $00000FFFFFF00000)
    XOR ((trunc(Random * cmax) shl $20) and $FFFFFF0000000000);
end;

end.
