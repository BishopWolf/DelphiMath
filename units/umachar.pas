unit umachar;

interface

uses uConstants;

procedure machar(out ibeta, it, irnd, ngrd, imachep, negep, iexp, minexp,
  maxexp: Integer; out eps, epsneg, xmin, xmax: Float);
{ Procedure to calculate machine architecture parameters }

implementation

procedure machar(out ibeta, it, irnd, ngrd, imachep, negep, iexp, minexp,
  maxexp: Integer; out eps, epsneg, xmin, xmax: Float);
{ ibeta is the radix in which numbers are represented,
  almost always 2, but occasionally 16, or even 10.
  it is the number of base-ibeta digits in the ﬂoating-point mantissa M.
  imachep is the exponent of the smallest (most negative) power of ibeta
  that, added to 1.0, gives something different from 1.0.
  eps is the ﬂoating-point number ibeta^machep, loosely referred to as the
  “ﬂoating-point precision.” (here it is machep)
  negep is the exponent of the smallest power of ibeta that, subtracted
  from 1.0, gives something different from 1.0.
  epsneg is ibeta^negep, another way of deﬁning ﬂoating-point precision.
  Not infrequently epsneg is 0.5 times eps; occasionally eps and epsneg
  are equal.
  iexp is the number of bits in the exponent (including its sign or bias).
  minexp is the smallest (most negative) power of ibeta consistent with
  there being no leading zeros in the mantissa.  MinLog
  xmin is the ﬂoating-point number ibeta^minexp, generally the smallest
  (in magnitude) useable ﬂoating value.  MinNum
  maxexp is the smallest (positive) power of ibeta that causes overﬂow. MaxLog
  xmax is (1−epsneg)×ibeta^maxexp, generallythe largest (in magnitude)
  useable ﬂoating value.     MaxNum
  irnd returns a code in the range 0..5, giving information on what kind of
  rounding is done in addition, and on how underﬂow is handled. See below.
  If irnd returns 2 or 5, then your computer is compliant with IEEE standard. If it
  returns 1 or 4, then it is doing some kind of rounding, but not the IEEE standard. If
  irnd returns 0 or 3, then it is truncating the result, not rounding it — not desirable.
  ngrd is the number of “guard digits” used when truncating the product of
  two mantissas to ﬁt the representation.
}
  function Conv(a: Integer): Float;
  begin
    result := a;
  end;

var
  i, itemp, iz, j, k, mx, nxres: Integer;
  a, b, beta, betah, betain, one, t, temp, temp1, tempa, two, y, z, zero: Float;
begin
  one := Conv(1);
  two := one + one;
  zero := one - one;
  a := one; // Determine ibeta and beta by the method of M.Malcolm.
  repeat
    a := a + a;
    temp := a + one;
    temp1 := temp - a;
  until (temp1 - one <> zero);
  b := one;
  repeat
    b := b + b;
    temp := a + b;
    itemp := trunc(temp - a);
  until (itemp <> 0);
  ibeta := itemp;
  beta := Conv(ibeta);
  it := 0; // Determine it and irnd.
  b := one;
  repeat
    inc(it);
    b := b * beta;
    temp := b + one;
    temp1 := temp - b;
  until (temp1 - one <> zero);
  irnd := 0;
  betah := beta / two;
  temp := a + betah;
  if (temp - a <> zero) then
    irnd := 1;
  tempa := a + beta;
  temp := tempa + betah;
  if ((irnd = 0) and (temp - tempa <> zero)) then
    irnd := 2;
  negep := (it) + 3; // Determine negep and epsneg.
  betain := one / beta;
  a := one;
  for i := 1 to (negep) do
    a := a * betain;
  b := a;
  repeat
    temp := one - a;
    if (temp - one <> zero) then
      break;
    a := a * beta;
    dec(negep);
  until false;
  negep := -(negep);
  epsneg := a;
  imachep := -(it) - 3; // Determine machep and eps.
  a := b;
  repeat
    temp := one + a;
    if (temp - one <> zero) then
      break;
    a := a * beta;
    inc(imachep);
  until false;
  eps := a;
  ngrd := 0; // Determine ngrd.
  temp := one + (eps);
  if ((irnd = 0) and ((temp * one) - one <> zero)) then
    ngrd := 1;
  i := 0; // Determine iexp.
  k := 1;
  z := betain;
  t := one + (eps);
  nxres := 0;
  repeat // { Loop until an underflow occurs, then exit.
    y := z;
    z := y * y;
    a := z * one; // Check here for the underflow.
    temp := z * t;
    if ((a + a = zero) or (abs(z) >= y)) then
      break;
    temp1 := temp * betain;
    if (temp1 * beta = z) then
      break;
    inc(i);
    k := k + k;
  until false;
  if (ibeta <> 10) then
  begin
    iexp := i + 1;
    mx := k + k;
  end
  else
  begin // { For decimal machines only.
    iexp := 2;
    iz := (ibeta);
    while (k >= iz) do
    begin
      iz := iz * ibeta;
      inc(iexp);
    end;
    mx := iz + iz - 1;
  end;
  repeat // { To determine minexp and xmin, loop until an under.ow occurs, then exit.
    xmin := y;
    y := y * betain;
    a := y * one; // Check here for the under.ow.
    temp := y * t;
    if ((a + a <> zero) and (abs(y) < xmin)) then
    begin
      inc(k);
      temp1 := temp * betain;
      if ((temp1 * beta = y) and (temp <> y)) then
      begin
        nxres := 3;
        xmin := y;
        break;
      end;
    end
    else
      break;
  until false;
  minexp := -k; // Determine maxexp, xmax.
  if ((mx <= k + k - 3) and (ibeta <> 10)) then
  begin
    mx := mx + mx;
    inc(iexp);
  end;
  maxexp := mx + (minexp);
  irnd := irnd + nxres; // Adjust irnd to reject partial underflow.
  if (irnd >= 2) then
    maxexp := maxexp - 2; // Adjust for IEEE-style machines.
  i := (maxexp) + (minexp);
  // Adjust for machines with implicit leading bit in binary mantissa, and machines with radix
  // point at extreme right of mantissa.
  if ((ibeta = 2) and (i = 0)) then
    dec(maxexp);
  if (i > 20) then
    dec(maxexp);
  if (a <> y) then
    maxexp := maxexp - 2;
  xmax := one - (epsneg);
  if (xmax * one <> xmax) then
    xmax := one - beta * (epsneg);
  xmax := xmax / (xmin * beta * beta * beta);
  i := (maxexp) + (minexp) + 3;
  for j := 1 to i do
  begin
    if (ibeta = 2) then
      xmax := xmax + xmax
    else
      xmax := xmax * beta;
  end;

  // MachEp:=eps;            { Floating point precision }
  // MaxNum:=xmax;           { Max. floating point number }
  // MinNum:=xmin;           { Min. floating point number }
  // MaxLog:=Ln(MaxNum);     { Max. argument for Exp = Ln(MaxNum) }
  // MinLog:=Ln(MinNum);     { Min. argument for Exp = Ln(MinNum) }
end;

end.
