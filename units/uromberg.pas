unit URomberg;

{ Unit uRomberg : Romberg numerical integration Unit

  Created by : Alex Vergara Gil

  Contains the routines for numerical integration by Romberg algorithm

}

interface

uses utypes, uConstants;

function RombergIntT(funcion: string; a, b: float; EPS: float = 1E-15;
  JMAX: integer = 20; k: integer = 5): float;
function RombergIntMP(funcion: string; a, b: float; EPS: float = 1E-15;
  JMAX: integer = 20; k: integer = 5): float;
function RombergIntTf(funcion: TFunc; a, b: float; EPS: float = 1E-15;
  JMAX: integer = 20; k: integer = 5): float;
function RombergIntMPf(funcion: TFunc; a, b: float; EPS: float = 1E-15;
  JMAX: integer = 20; k: integer = 5): float;
{ Routines qromb using trapezoidal and middle point rules
  translated from Numerical Recipes in C by Alex Vergara Gil
  input:
  funcion: In the case of a string input it is
  a string containing the one variable function
  to be integrated on interval [a,b] the variable
  must be called 'x'. In the functional input it
  is a user suplied external function.
  EPS    : (optional) the required precision
  JMAX   : (optional) the maximum number of iterations
  k      : (optional) the starting order of the polinomial
  all optional parameters have default inputs
  output:
  a float containig the value of the integral
  it is used also the unit parser10 who provide great capability
  examples:
  String input
  ...
  x:=RombergIntMP('sen(x)',0,pi);//Recommended
  ...
  results => x=2 => error=EPS=1e-15 (Default Recommended for extended float)
  (for double float recommended EPS=1e-10)
  (for single float recommended EPS=1e-5)
  see unit parser10.pas for more description

  functional input => previously declared:
  function sinus(x:float):float;begin sinus:=sin(x);end;
  ...
  y:=RombergIntMPf(sinus,0,pi);
  ...
  results => x=2 => error=EPS=1e-15

  made by Alex Vergara Gil 09/03/2007 }

implementation

uses parser10, uinterpolation;

{ string input }
var
  evaluador: TParser;

  { trapezoidal step }
procedure trapzd(funcion: string; a, b: float; iteration: integer;
  var s: float);
var
  tnm, sum, del, fl, fh: float;
  it, j: integer;
begin
  evaluador.Expression := funcion;
  if (iteration = 1) then
  begin
    evaluador.X := a;
    fl := evaluador.Value;
    evaluador.X := b;
    fh := evaluador.Value;
    s := 0.5 * (b - a) * (fl + fh);
  end
  else
  begin
    it := 1;
    for j := 1 to iteration - 2 do
      it := it shl 1;
    tnm := it;
    del := (b - a) / tnm; // This is the spacing of the points to be added.
    evaluador.X := a + (0.5 * del);
    sum := 0.0;
    for j := 1 to it do
    begin
      sum := sum + evaluador.Value;
      evaluador.X := evaluador.X + del;
    end;
    s := 0.5 * (s + (((b - a) * sum) / tnm));
    // This replaces s by its refined value.
  end;
end;

{ midpoint step }
procedure midpoint(funcion: string; a, b: float; iteration: integer;
  var s: float);
var
  tnm, sum, del, ddel: float;
  it, j: integer;
begin
  evaluador.Expression := funcion;
  if (iteration = 1) then
  begin
    evaluador.X := 0.5 * (a + b);
    s := (b - a) * evaluador.Value;
  end
  else
  begin
    it := 1;
    for j := 1 to iteration - 2 do
      it := it * 3;
    tnm := it;
    del := (b - a) / (3.0 * tnm);
    ddel := del + del;
    // The added points alternate in spacing between del and ddel.
    evaluador.X := a + 0.5 * del;
    sum := 0.0;
    for j := 1 to it do
    begin
      sum := sum + evaluador.Value;
      evaluador.X := evaluador.X + ddel;
      sum := sum + evaluador.Value;
      evaluador.X := evaluador.X + del;
    end;
    s := (s + (((b - a) * sum) / tnm)) / 3.0;
    // The new sum is combined with the old integral to give a refined integral.
  end;
end;

function RombergIntT(funcion: string; a, b, EPS: float;
  JMAX, k: integer): float;
var
  Jmaxp, j: integer;
  dss, ss: float;
  s1: float;
  s, h: TVector;
begin
  Jmaxp := JMAX + 1;
  DimVector(s, Jmaxp);
  DimVector(h, Jmaxp + 1);
  h[1] := 1;
  for j := 1 to JMAX do
  begin
    trapzd(funcion, a, b, j, s1);
    s[j] := s1;
    if (j >= k) then
    begin
      ss := PolinomialInterpolation(h, s, j - k + 1, 0.0, dss);
      if (abs(dss) <= EPS * abs(ss)) then
      begin
        SetErrCode(FOk); // normal exit
        result := ss;
        DelVector(s);
        DelVector(h);
        exit;
      end;
    end;
    h[j + 1] := 0.25 * h[j];
    { This is a key step: The factor is 0.25 even though the stepsize is decreased by only
      0.5. This makes the extrapolation a polynomial in h^2 as allowed by equation (4.2.1),
      not just a polynomial in h. }
  end;
  // nrerror("Too many steps in routine qromb");
  SetErrCode(FOverflow); // overflow step count
  result := 0.0; // Never get here.
end;

function RombergIntMP(funcion: string; a, b, EPS: float;
  JMAX, k: integer): float;
var
  Jmaxp, j: integer;
  dss, ss: float;
  s1: float;
  s, h: TVector;
begin
  Jmaxp := JMAX + 1;
  DimVector(s, Jmaxp);
  DimVector(h, Jmaxp + 1);
  h[1] := 1;
  for j := 1 to JMAX do
  begin
    midpoint(funcion, a, b, j, s1);
    s[j] := s1;
    if (j >= k) then
    begin
      ss := PolinomialInterpolation(h, s, j - k + 1, 0.0, dss);
      if (abs(dss) <= EPS * abs(ss)) then
      begin
        SetErrCode(FOk); // normal exit
        result := ss;
        DelVector(s);
        DelVector(h);
        exit;
      end;
    end;
    h[j + 1] := 0.25 * h[j];
    { This is a key step: The factor is 0.25 even though the stepsize is decreased by only
      0.5. This makes the extrapolation a polynomial in h^2 as allowed by equation (4.2.1),
      not just a polynomial in h. }
  end;
  // nrerror("Too many steps in routine qromb");
  SetErrCode(FOverflow); // overflow step count
  result := 0.0; // Never get here.
end;

{ functional input }

procedure trapzdf(funcion: TFunc; a, b: float; iteration: integer;
  var s: float);
var
  tnm, sum, del, fl, fh, X: float;
  it, j: integer;
begin
  if (iteration = 1) then
  begin
    fl := funcion(a);
    fh := funcion(b);
    s := 0.5 * (b - a) * (fl + fh);
  end
  else
  begin
    it := 1;
    for j := 1 to iteration - 2 do
      it := it shl 1;
    tnm := it;
    del := (b - a) / tnm; // This is the spacing of the points to be added.
    X := a + (0.5 * del);
    sum := 0.0;
    for j := 1 to it do
    begin
      sum := sum + funcion(X);
      X := X + del;
    end;
    s := 0.5 * (s + (((b - a) * sum) / tnm));
    // This replaces s by its refined value.
  end;
end;

procedure midpointf(funcion: TFunc; a, b: float; iteration: integer;
  var s: float);
var
  tnm, sum, del, ddel, X: float;
  it, j: integer;
begin
  if (iteration = 1) then
  begin
    s := (b - a) * funcion(0.5 * (a + b));
  end
  else
  begin
    it := 1;
    for j := 1 to iteration - 2 do
      it := it * 3;
    tnm := it;
    del := (b - a) / (3.0 * tnm);
    ddel := del + del;
    // The added points alternate in spacing between del and ddel.
    X := a + 0.5 * del;
    sum := 0.0;
    for j := 1 to it do
    begin
      sum := sum + funcion(X);
      X := X + ddel;
      sum := sum + funcion(X);
      X := X + del;
    end;
    s := (s + (((b - a) * sum) / tnm)) / 3.0;
    // The new sum is combined with the old integral to give a refined integral.
  end;
end;

function RombergIntTf(funcion: TFunc; a, b, EPS: float;
  JMAX, k: integer): float;
var
  Jmaxp, j: integer;
  dss, ss: float;
  s1: float;
  s, h: TVector;
begin
  Jmaxp := JMAX + 1;
  DimVector(s, Jmaxp);
  DimVector(h, Jmaxp + 1);
  h[1] := 1;
  for j := 1 to JMAX do
  begin
    trapzdf(funcion, a, b, j, s1);
    s[j] := s1;
    if (j >= k) then
    begin
      ss := PolinomialInterpolation(h, s, j - k + 1, 0.0, dss);
      if (abs(dss) <= EPS * abs(ss)) then
      begin
        SetErrCode(FOk); // normal exit
        result := ss;
        DelVector(s);
        DelVector(h);
        exit;
      end;
    end;
    h[j + 1] := 0.25 * h[j];
    { This is a key step: The factor is 0.25 even though the stepsize is decreased by only
      0.5. This makes the extrapolation a polynomial in h^2 as allowed by equation (4.2.1),
      not just a polynomial in h. }
  end;
  // nrerror("Too many steps in routine qromb");
  SetErrCode(FOverflow); // overflow step count
  result := 0.0; // Never get here.
end;

function RombergIntMPf(funcion: TFunc; a, b, EPS: float;
  JMAX, k: integer): float;
var
  Jmaxp, j: integer;
  dss, ss: float;
  s1: float;
  s, h: TVector;
begin
  Jmaxp := JMAX + 1;
  DimVector(s, Jmaxp);
  DimVector(h, Jmaxp + 1);
  h[1] := 1;
  for j := 1 to JMAX do
  begin
    midpointf(funcion, a, b, j, s1);
    s[j] := s1;
    if (j >= k) then
    begin
      ss := PolinomialInterpolation(h, s, j - k + 1, 0.0, dss);
      if (abs(dss) <= EPS * abs(ss)) then
      begin
        SetErrCode(FOk); // normal exit
        result := ss;
        DelVector(s);
        DelVector(h);
        exit;
      end;
    end;
    h[j + 1] := 0.25 * h[j];
    { This is a key step: The factor is 0.25 even though the stepsize is decreased by only
      0.5. This makes the extrapolation a polynomial in h^2 as allowed by equation (4.2.1),
      not just a polynomial in h. }
  end;
  // nrerror("Too many steps in routine qromb");
  SetErrCode(FOverflow); // overflow step count
  result := 0.0; // Never get here.
end;

Initialization

evaluador := TParser.Create(nil);

Finalization

evaluador.Free;

end.
