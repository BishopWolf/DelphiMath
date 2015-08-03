unit uranmt;

interface

uses uConstants, urandom;
{ ******************************************************************
  Mersenne Twister 64-bit Random Number Generator
  ******************************************************************

  A C-program for MT19937-64 (2004/9/29 version).
  Coded by Takuji Nishimura and Makoto Matsumoto.

  This is a 64-bit version of Mersenne Twister pseudorandom number
  generator.

  Before using, initialize the state by using init_genrand64(seed)
  or init_by_array64(init_key, key_length).

  Copyright (C) 2004, Makoto Matsumoto and Takuji Nishimura,
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The names of its contributors may not be used to endorse or promote
  products derived from this software without specific prior written
  permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  References:
  T. Nishimura, ``Tables of 64-bit Mersenne Twisters''
  ACM Transactions on Modeling and
  Computer Simulation 10. (2000) 348--357.
  M. Matsumoto and T. Nishimura,
  ``Mersenne Twister: a 623-dimensionally equidistributed
  uniform pseudorandom number generator''
  ACM Transactions on Modeling and
  Computer Simulation 8. (Jan. 1998) 3--30.

  Any feedback is very welcome.
  http://www.math.hiroshima-u.ac.jp/~m-mat/MT/emt.html
  email: m-mat @ math.sci.hiroshima-u.ac.jp (remove spaces)
  ****************************************************************** }
{ ******************************************************************
  Mersenne Twister Random Number Generator
  ******************************************************************

  A C-program for MT19937, with initialization improved 2002/1/26.
  Coded by Takuji Nishimura and Makoto Matsumoto.

  Before using, initialize the state by using init_genrand(seed)
  or init_by_array(init_key, key_length) (respectively InitMT and
  InitMTbyArray in the TPMath version)

  Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The names of its contributors may not be used to endorse or promote
  products derived from this software without specific prior written
  permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Any feedback is very welcome.
  http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
  email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
  ****************************************************************** }

type
  TRanMT = class(TBaseRandomGen)
  const
    { 64-bit constants }
    NN = 312;
    MM = 156;
    MATRIX_AA = int64($B5026F5AA96619E9); { constant vector a }
    UPPER_MASK64 = int64($FFFFFFFF80000000); { most significant w-r bits }
    LOWER_MASK64 = int64($7FFFFFFF); { least significant r bits }
    mag64: array [0 .. 1] of int64 = (0, MATRIX_AA);
    { 32-bit constants }
    N = 624;
    M = 397;
    MATRIX_A = $9908B0DF; { constant vector a }
    UPPER_MASK = $80000000; { most significant w-r bits }
    LOWER_MASK = $7FFFFFFF; { least significant r bits }
    mag32: array [0 .. 1] of uint32 = (0, MATRIX_A);
  private
    mtti: Word; { mtti == NN+1 means mtt[NN] is not initialized }
    mti: Word; { mti  == N+1  means mt[N]   is not initialized }
    mtt: array [0 .. (NN - 1)] of int64; { the array for the state vector }
    mt: array [0 .. (N - 1)] of uint32; { the array for the state vector }
    procedure Init64(seed: int64);
    procedure Init32(seed: integer);
  public
    // * initializes mt[NN] with a seed */
    constructor Create(seed: Longint);

    // * initialize by an array with array-length */
    // * init_key is the array for initializing keys */
    // * key_length is its length */
    Constructor Create64(init_key: array of int64; key_length: Word);
    Constructor Create32(init_key: array of Longint; key_length: Word);

    // * generates a random number on [0, 2^64-1]-interval */
    function IRan64: int64; override;

    // * Generates a Random number on [-2^31 .. 2^31 - 1] interval */
    function IRan32: Longint; override;
    function Random: float; override;
  end;

implementation

const
  init: array [0 .. 3] of Longint = ($123, $234, $345, $456);
  Init64: array [0 .. 7] of int64 = ($123456, $234567, $345678, $456789,
    $567890, $678901, $789012, $890123);

constructor TRanMT.Create(seed: Longint);
begin
  inherited Create;
  Init32(seed);
  Init64(seed);
end;

constructor TRanMT.Create64(init_key: array of int64; key_length: Word);
var
  i, j, k, k1: Word;
begin
  inherited Create;
  Init64($12BD6AA { 19650218 } );
  i := 1;
  j := 0;
  if NN > key_length then
    k1 := NN
  else
    k1 := key_length;
  for k := k1 downto 1 do
  begin
    mtt[i] := (mtt[i] XOR ((mtt[i - 1] XOR (mtt[i - 1] SHR 62)) *
      $369DEA0F31A53F85 { 3935559000370003845 } )) + init_key[j] + j;
    // * non linear */
    i := i + 1;
    j := j + 1;
    if i >= N then
    begin
      mtt[0] := mtt[NN - 1];
      i := 1;
    end;
    if j >= key_length then
      j := 0;
  end;
  for k := NN - 1 downto 1 do
  begin
    mtt[i] := (mtt[i] XOR ((mtt[i - 1] XOR (mtt[i - 1] shr 62)) *
      $27BB2EE687B0B0FD { 2862933555777941757 } )) - i; // * non linear */
    i := i + 1;
    if i >= NN then
    begin
      mtt[0] := mtt[NN - 1];
      i := 1;
    end;
  end;

  mtt[0] := 1 shl 63; // * MSB is 1; assuring non-zero initial array */
end;

constructor TRanMT.Create32(init_key: array of Longint; key_length: Word);
var
  i, j, k, k1: Word;
  temp: Longint; // the variable temp here is to avoid integer overflow
const // Added by Alex Vergara Gil
  a1: Cardinal = $19660D { =1664525 };
  a2: Cardinal = $5D588B65 { =1566083941 };
begin
  inherited Create;
  Init32($12BD6AA { 19650218 } );

  i := 1;
  j := 0;

  if N > key_length then
    k1 := N
  else
    k1 := key_length;

  for k := k1 downto 1 do
  begin
    temp := (mt[i] Xor ((mt[i - 1] Xor (mt[i - 1] shr 30)) * a1)) + init_key[j]
      + j; { non linear }
    mt[i] := temp and $FFFFFFFF; { for WORDSIZE > 32 machines }
    i := i + 1;
    j := j + 1;
    if i >= N then
    begin
      mt[0] := mt[N - 1];
      i := 1;
    end;
    if j >= key_length then
      j := 0;
  end;

  for k := N - 1 downto 1 do
  begin
    temp := (mt[i] Xor ((mt[i - 1] Xor (mt[i - 1] shr 30)) * a2)) - i;
    { non linear }
    mt[i] := temp and $FFFFFFFF; { for WORDSIZE > 32 machines }
    i := i + 1;
    if i >= N then
    begin
      mt[0] := mt[N - 1];
      i := 1;
    end;
  end;

  mt[0] := $80000000; { MSB is 1; assuring non-zero initial array }
end;

procedure TRanMT.Init64(seed: int64);
var
  i: Word;
const
  a = $5851F42D4C957F2D { 6364136223846793005 };
begin
  mtt[0] := seed;
  for i := 1 to NN - 1 do
    mtt[i] := (a * (mtt[i - 1] XOR (mtt[i - 1] shr 62)) + i);
  mtti := NN;
end;

procedure TRanMT.Init32(seed: Longint);
var
  i: Word;
  temp: Longint;
const
  a: Cardinal = $6C078965 { =1812433253 }; // Multiplier
begin
  mt[0] := seed and $FFFFFFFF;
  for i := 1 to N - 1 do
  begin
    temp := (a * (mt[i - 1] Xor (mt[i - 1] shr 30)) + i);
    { See Knuth TAOCP Vol2. 3rd Ed. P.106 For multiplier.
      In the previous versions, MSBs of the seed affect
      only MSBs of the array mt[].
      2002/01/09 modified by Makoto Matsumoto }
    mt[i] := temp and $FFFFFFFF;
    { For >32 Bit machines }
  end;
  mti := N;
end;

function TRanMT.IRan64: int64;
var
  i: Word;
  x: int64;
begin
  if (mtti >= NN) then // * generate NN words at one time */
  begin
    // * if init() has not been called, */
    // * a default initial seed is used     */
    // if (mtti >= NN+1) then Init64(5489); // Siempre se llama

    for i := 0 to NN - MM - 1 do
    begin
      x := (mtt[i] and UPPER_MASK64) or (mtt[i + 1] and LOWER_MASK64);
      mtt[i] := mtt[i + MM] XOR (x shr 1) XOR mag64[x and 1];
    end;
    for i := (NN - MM) to (NN - 2) do
    begin
      x := (mtt[i] and UPPER_MASK64) or (mtt[i + 1] and LOWER_MASK64);
      mtt[i] := mtt[i + (MM - NN)] XOR (x shr 1) XOR mag64[x and 1];
    end;
    x := (mtt[NN - 1] and UPPER_MASK64) or (mtt[0] and LOWER_MASK64);
    mtt[NN - 1] := mtt[MM - 1] XOR (x shr 1) XOR mag64[x and 1];

    mtti := 0;
  end;

  x := mtt[mtti];
  mtti := mtti + 1;

  x := x xor ((x shr 29) and $5555555555555555);
  x := x xor ((x shl 17) and $71D67FFFEDA60000);
  x := x xor ((x shl 37) and $FFF7EEE000000000);
  x := x xor (x shr 43);

  result := x;

end;

function TRanMT.IRan32: Longint;
var
  y: uint32;
  k: Word;
begin
  if mti >= N then { generate N words at one Time }
  begin
    (* If IRanMT() has not been called, a default initial seed is used *)
    // if mti >= N + 1 then Init32(5489);   // Siempre se llama al crear

    for k := 0 to (N - M) - 1 do
    begin
      y := (mt[k] and UPPER_MASK) or (mt[k + 1] and LOWER_MASK);
      mt[k] := mt[k + M] xor (y shr 1) xor mag32[y and $1];
    end;

    for k := (N - M) to (N - 2) do
    begin
      y := (mt[k] and UPPER_MASK) or (mt[k + 1] and LOWER_MASK);
      mt[k] := mt[k - (N - M)] xor (y shr 1) xor mag32[y and $1];
    end;

    y := (mt[N - 1] and UPPER_MASK) or (mt[0] and LOWER_MASK);
    mt[N - 1] := mt[M - 1] xor (y shr 1) xor mag32[y and $1];

    mti := 0;
  end;

  y := mt[mti];
  mti := mti + 1;

  { Tempering }
  y := y xor (y shr 11);
  y := y xor ((y shl 7) and $9D2C5680);
  y := y xor ((y shl 15) and $EFC60000);
  y := y xor (y shr 18);

  result := y
end;

function TRanMT.Random: float;
const
  Z321 = 1.0 / 4294967295.0; { 1 / (2^32 - 1) }
  Z631 = 1.0 / 9223372036854775807.0; { 1/ (2^63 - 1) }
begin
  if (sizeof(float) >= 8) then
    result := (IRan64 shr 1) * Z631
  else 
    result := (IRan32 + 2147483648.0) * Z321;
end;

end.
