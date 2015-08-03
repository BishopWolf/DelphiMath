unit uRanTests;

// Statistical Tests of randomness
// Made by Alex Vergara Gil May 7, 2008

interface

uses utypes, uConstants, math;

type
  TMKind = (tmMomentos, tmCorrelacion);
  TDTtype = (TDTNoD, TDTBits);

procedure TestsOfMomentos(const k, N: integer; out mean, stdvar, skew, curt,
  hash, chi2, p: float; kind: TMKind = tmMomentos);
{ ------------------------------------------------------------------
  Computes the test of momentos for random numbers
  if input kind=tmMomentos
  on output
  mean   ~ 1/2  = 0.5
  stdvar ~ 1/12 = 0.08333
  skew   ~ 1/4  = 0.25
  curt   ~ 1/16 = 0.0625
  hash   ~ 1/1024  = 0.0009765625
  if input kind=tmCorrelacion
  on output
  mean   - 1/2    = 0.5
  stdvar ~ 1/12   = 0.08333
  skew   ~ 1/2^k  = 0.25
  curt   ~ skew*exp(-k/2) = 0.0625
  ------------------------------------------------------------------ }

{ all these routines have on output
  chi2   :   Chi square statistic
  pchi2  :   probability of the chi square
  ks     :   Kolgomorov Smirnov statistic
  pks    :   probability of the KS statistic
}
procedure TestofDices(NofDices, size: integer; var NofThrows: integer;
  out chi2, pchi2, ks, pks: float; kind: TDTtype; grouped: boolean = true);
{ ------------------------------------------------------------------
  Computes the test of dices for random numbers
  See D.E.Knuth TAOCP vol II
  pchi2 and pks must be between 0.05 and 0.95 for good generators
  input
  if Kind=TDTNoD then
  NofDices : Number of dices  (2 to 6 for now)
  else if Kind=TDTBits then
  NofDices : Bits tests of dices from bit NofDices to bits NofDices + 2

  NofThrows: Number of throws (must be > 10^NofDices)
  grouped  : if true then the first and the last NofDices values are
  grouped into one value, This makes more robust the method.
  ------------------------------------------------------------------ }

procedure TestofGaps(t: integer; var N: integer; alpha, beta: float;
  out chi2, pchi2, ks, pks: float);
{ ------------------------------------------------------------------
  Computes the test of gaps for random numbers
  See D.E.Knuth TAOCP vol II
  pchi2 must be between 0.05 and 0.95 for good generators
  input
  t     : the order of the test
  n     : number of gaps
  alpha : lower limit
  beta  : upper limit
  ------------------------------------------------------------------ }

procedure TestofEquidistribution(d, N: integer;
  out chi2, pchi2, ks, pks: float);
{ ------------------------------------------------------------------
  Computes the Equidistribution test for random numbers
  See D.E.Knuth TAOCP vol II
  pchi2 must be between 0.05 and 0.95 for good generators
  input
  d     : the number of bytes to be taken from each value
  n     : number of values
  ------------------------------------------------------------------ }

procedure SerialTest(d: integer; var N: integer;
  out chi2, pchi2, ks, pks: float);
{ ------------------------------------------------------------------
  Computes the Equidistribution test for random numbers
  See D.E.Knuth TAOCP vol II
  pchi2 must be between 0.05 and 0.95 for good generators
  input
  d     : the number of bytes to be taken from each value
  n     : number of pairs
  ------------------------------------------------------------------ }

implementation

uses urandom, umath, utests, ugamdist, uround;

procedure TestsOfMomentos(const k, N: integer; out mean, stdvar, skew, curt,
  hash, chi2, p: float; kind: TMKind);
var
  i, j, ndivk: integer;
  U, two, es: float;
  gen: TRandomGen;
begin
  mean := 0;
  stdvar := 0;
  skew := 0;
  curt := 0;
  hash := 0;
  ndivk := N div k;
  gen := TRandomGen.Create(1234543);
  case kind of
    tmMomentos:
      for i := 1 to N do
      begin
        U := gen.Random1;
        mean := mean + U;
        stdvar := stdvar + sqr(U);
        for j := 1 to k - 1 do
          gen.Random1;
      end;
    tmCorrelacion:
      for i := 1 to ndivk do
      begin
        for j := 1 to k do
        begin
          U := gen.Random1;
          mean := mean + U;
          stdvar := stdvar + sqr(U);
        end;
        for j := 1 to k do
          gen.Random1;
      end;
  end;
  stdvar := (stdvar - sqr(mean) / N) / (N - 1);
  // this value must be around 1/12
  mean := mean / N; // this value must be around 1/2
  case kind of
    tmMomentos:
      begin
        for i := 1 to N do
        begin
          U := gen.Random1;
          for j := 1 to k - 1 do
            gen.Random1;
          skew := skew + gen.Random1 * U;
          for j := 1 to k - 1 do
            gen.Random1;
        end;
        skew := skew / N; // this value must be around 1/4
      end;
    tmCorrelacion:
      begin
        for i := 1 to ndivk do
        begin
          U := 1;
          for j := 1 to k do
            U := U * gen.Random1;
          skew := skew + U;
          curt := curt + sqr(U);
          for j := 1 to k do
            gen.Random1;
        end;
        curt := (curt - sqr(skew) / ndivk) / (ndivk - 1);
        // this value must be around skew*e^(-k/2)
        skew := skew / ndivk; // this value must be around 1/2^k
        two := IntPower(2, k);
        es := exp(k / 2) / skew;
        chi2 := sqr(((1 / mean) - 2) / 2) + sqr(((1 / stdvar) - 12) / 12) +
          sqr(((1 / skew) - two) / two) + sqr(((1 / curt) - es) / es);
        p := ChiSquareProbabilityCompl(chi2, 2);
      end;
  end;
  if kind = tmMomentos then
  begin
    for i := 1 to N do
    begin
      U := gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      curt := curt + gen.Random1 * U;
      for j := 1 to k - 1 do
        gen.Random1;
    end;
    curt := curt / N; // this value must be around 1/16
    for i := 1 to N do
    begin
      U := gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      U := U * gen.Random1;
      for j := 1 to k - 1 do
        gen.Random1;
      hash := hash + gen.Random1 * U;
      for j := 1 to k - 1 do
        gen.Random1;
    end;
    hash := hash / N; // this value must be around 1/1024
    chi2 := sqr(((1 / mean) - 2) / 2) + sqr(((1 / stdvar) - 12) / 12) +
      sqr(((1 / skew) - 4) / 4) + sqr(((1 / curt) - 16) / 16) +
      sqr(((1 / hash) - 1024) / 1024);
    p := ChiSquareProbabilityCompl(chi2, 4);
  end;
  gen.Free;
end;

procedure TestofDices(NofDices, size: integer; var NofThrows: integer;
  out chi2, pchi2, ks, pks: float; kind: TDTtype; grouped: boolean);
const
  // 2,3,4,5, 6, 7, 8, 9,10, 11, 12
  array2: array [1 .. 11] of integer = (1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1); // 36
  // 3,4,5, 6, 7, 8, 9,10, 11, 12, 13, 14, 15, 16, 17,18
  array3: array [1 .. 16] of integer = (1, 3, 6, 10, 15, 21, 25, 27, 27, 25, 21,
    15, 10, 6, 3, 1); // 216
  // 4,5, 6, 7, 8, 9,10, 11, 12, 13, 14, 15, 16, 17,18,19,20,21,22,23,24
  array4: array [1 .. 21] of integer = (1, 4, 10, 20, 35, 56, 80, 104, 125, 140,
    146, 140, 125, 104, 80, 56, 35, 20, 10, 4, 1); // 1296
  array5: array [1 .. 26] of integer = (1, 5, 15, 35, 70, 126, 205, 305, 420,
    540, 651, 735, 780, 780, 735, 651, 540, 420, 305, 205, 126, 70, 35, 15, 5,
    1); // 7776
  // 206,310,435,575,721,861,986,1090
  array6: array [1 .. 31] of integer = (1, 6, 21, 56, 126, 252, 458, 756, 1161,
    1666, 2247, 2856, 3431, 3906, 4221, 4332, 4221, 3906, 3431, 2856, 2247,
    1666, 1161, 756, 458, 252, 126, 56, 21, 6, 1); // 46656
  // 457,762,1182,1722,2373,3108,3888,4668,5403,6054
  // the way to obtain a new sequence is summing the previous value with their equivalent in the previous sequence
  // and then rest the values corresponding to consecutively rest six places to the position
  // for example to obtain the first value 780 (place 13 on array5) it is just:
  // 861(previous value) plus 125 (previous sequence)=986
  // minus 205 (place 13-6), minus 1 (place 13-6-6)

  // if you can colaborate providing any mathematical formulation to obtain directly these sequences
  // please contact: alex at cphr.edu.cu
  // remove spaces and change 'at' by '@'
  arrayBits8: array [1 .. 15] of integer = (1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5,
    4, 3, 2, 1);
  function Mask32(Number: integer): Byte; // returns a number between 1 and 8
  begin
    Result := ((Number shr (size - NofDices)) and $7) + 1;
  end;
  function Mask64(Number: int64): Byte; // returns a number between 1 and 8
  begin
    Result := ((Number shr (size - NofDices)) and $7) + 1;
  end;

var
  misize, s1, i, j, dices, pos: integer;
  throws, expected, t1, e1: TVector;
  six, eigth: float;
  n1, n2: integer;
  gen: TRandomGen;
begin
  gen := TRandomGen.Create(1234543);
  case kind of
    TDTNoD:
      begin
        misize := 5 * NofDices + 1;
        if (Log10(NofThrows) < NofDices) then
          NofThrows := floor(2 * IntPower(10, NofDices));
        // this guarentee the robustness of the test
        six := NofThrows / IntPower(6, NofDices);
        DimVector(expected, misize);
        { for i:=1 to (size+1) div 2 do begin
          expected[i]:=six*Binomial(i+(NofDices-2),NofDices-1);
          expected[size-i+1]:=expected[i];
          end; } // this formulation doesn't work
        case NofDices of
          2:
            for i := 1 to misize do
              expected[i] := six * array2[i];
          3:
            for i := 1 to misize do
              expected[i] := six * array3[i];
          4:
            for i := 1 to misize do
              expected[i] := six * array4[i];
          5:
            for i := 1 to misize do
              expected[i] := six * array5[i];
          6:
            for i := 1 to misize do
              expected[i] := six * array6[i];
        else
          begin
            DelVector(expected);
            chi2 := 0;
            pchi2 := 0;
            ks := 0;
            pks := 0;
            exit;
          end;
        end;
        DimVector(throws, misize, 0);
        for i := 1 to NofThrows do
        begin
          dices := 0;
          for j := 1 to NofDices do
            dices := dices + trunc(6 * gen.Random2) + 1;
          pos := dices - NofDices + 1;
          throws[pos] := throws[pos] + 1;
        end;
        if grouped then
        begin
          s1 := misize - (2 * NofDices) + 2;
          DimVector(t1, s1);
          DimVector(e1, s1);
          for i := 1 to NofDices do
          begin
            t1[1] := t1[1] + throws[i];
            t1[s1] := t1[s1] + throws[misize - i + 1];
            e1[1] := e1[1] + expected[i];
            e1[s1] := e1[1];
          end;
          for i := NofDices + 1 to misize - NofDices do
          begin
            t1[i - NofDices + 1] := throws[i];
            e1[i - NofDices + 1] := expected[i];
          end;
          DelVector(throws);
          DelVector(expected);
          chi2 := 0;
          for i := 1 to s1 do
          begin
            chi2 := chi2 + sqr(t1[i] - e1[i]) / e1[i];
          end;
          pchi2 := ChiSquareProbability(chi2, s1 - 1);
          Kolmogorov_Smirnov_Compara(t1, e1, s1, s1, ks, pks);
          DelVector(t1);
          DelVector(e1);
          exit;
        end;
        chi2 := 0;
        for i := 1 to misize do
        begin
          chi2 := chi2 + sqr(throws[i] - expected[i]) / expected[i];
        end;
        pchi2 := ChiSquareProbability(chi2, misize - 1);
        Kolmogorov_Smirnov_Compara(throws, expected, misize, misize, ks, pks);
        DelVector(throws);
        DelVector(expected);
      end;
    TDTBits:
      begin
        if ((NofDices < 1) or (NofDices > size)) then
        begin
          chi2 := 0;
          pchi2 := 0;
          ks := 0;
          pks := 0;
          exit;
        end;
        misize := 15;
        eigth := NofThrows / 64; // 64=(size+1)^2/4
        if (Log10(NofThrows) < 2) then
          NofThrows := 200; // this guarentee the robustness of the test
        DimVector(expected, misize);
        for i := 1 to misize do
          expected[i] := eigth * arrayBits8[i];
        DimVector(throws, misize);
        for i := 1 to NofThrows do
        begin
          case size of
            30:
              dices := Mask32(gen.IRan32) + Mask32(gen.IRan32);
            62:
              dices := Mask64(gen.IRan64) + Mask64(gen.IRan64);
          else
            dices := 2;
          end;
          pos := dices - 1;
          throws[pos] := throws[pos] + 1;
        end;
        if grouped then
        begin
          s1 := misize - 2;
          DimVector(t1, s1);
          DimVector(e1, s1);
          for i := 1 to 2 do
          begin
            t1[1] := t1[1] + throws[i];
            t1[s1] := t1[s1] + throws[misize - i + 1];
            e1[1] := e1[1] + expected[i];
            e1[s1] := e1[1];
          end;
          for i := 3 to misize - 2 do
          begin
            t1[i - 1] := throws[i];
            e1[i - 1] := expected[i];
          end;
          DelVector(throws);
          DelVector(expected);
          chi2 := 0;
          for i := 1 to s1 do
          begin
            chi2 := chi2 + sqr(t1[i] - e1[i]) / e1[i];
          end;
          pchi2 := ChiSquareProbability(chi2, s1 - 1);
          Kolmogorov_Smirnov_Compara(t1, e1, s1, s1, ks, pks);
          DelVector(t1);
          DelVector(e1);
          exit;
        end;
        ChiSquare(throws, expected, misize, chi2, pchi2);
        Kolmogorov_Smirnov_Compara(throws, expected, misize, misize, ks, pks);
        DelVector(throws);
        DelVector(expected);
      end;
  else
  end;
  gen.Free;
end;

procedure TestofGaps(t: integer; var N: integer; alpha, beta: float;
  out chi2, pchi2, ks, pks: float);
var
  s, j, r: integer;
  count, esperado: TVector;
  Uj, p: float;
  seguir: boolean;
  gen: TRandomGen;
begin
  DimVector(count, t + 1);
  r := 1;
  gen := TRandomGen.Create(1234543);
  if N < 1000 * t then
    N := 1000 * t;
  for s := 1 to N do
  begin
    repeat
      Uj := gen.Random1;
      if (Uj >= alpha) and (Uj < beta) then
      begin
        if r > t then
          count[t + 1] := count[t + 1] + 1
        else
          count[r] := count[r] + 1;
        seguir := false;
        r := 1;
      end
      else
      begin
        inc(r);
        seguir := true;
      end;
    until not seguir;
  end;
  p := beta - alpha;
  DimVector(esperado, t + 1);
  for j := 1 to t do
  begin
    esperado[j] := p * power(1 - p, j - 1) * N;
  end;
  esperado[t + 1] := power(1 - p, t) * N;
  ChiSquare(count, esperado, t + 1, chi2, pchi2);
  Kolmogorov_Smirnov_Compara(count, esperado, t + 1, t + 1, ks, pks);
  DelVector(count);
  DelVector(esperado);
  gen.Free;
end;

procedure TestofEquidistribution(d, N: integer;
  out chi2, pchi2, ks, pks: float);
var
  j, k, two: integer;
  count, esperado: TVector;
  gen: TRandomGen;
begin
  two := floor(IntPower(2, d));
  gen := TRandomGen.Create;
  DimVector(count, two);
  DimVector(esperado, two, N / two);
  for j := 1 to N do
  begin
    k := floor(two * gen.Random3) + 1;
    count[k] := count[k] + 1;
  end;
  ChiSquare(count, esperado, two, chi2, pchi2);
  Kolmogorov_Smirnov_Compara(count, esperado, two, two, ks, pks);
  DelVector(count);
  DelVector(esperado);
  gen.Free;
end;

procedure SerialTest(d: integer; var N: integer;
  out chi2, pchi2, ks, pks: float);
var
  j, q, r, two, twosqr: integer;
  count, esperado: TVector;
  gen: TRandomGen;
begin
  two := floor(IntPower(2, d));
  twosqr := sqr(two);
  gen := TRandomGen.Create;
  if N < 5 * twosqr then
    N := 5 * twosqr;
  DimVector(count, twosqr);
  DimVector(esperado, twosqr, N / twosqr);
  for j := 1 to N do
  begin
    q := floor(two * gen.Random3);
    r := floor(two * gen.Random3);
    count[two * q + r + 1] := count[two * q + r + 1] + 1;
  end;
  ChiSquare(count, esperado, twosqr, chi2, pchi2);
  Kolmogorov_Smirnov_Compara(count, esperado, twosqr, twosqr, ks, pks);
  DelVector(count);
  DelVector(esperado);
  gen.Free;
end;

end.
