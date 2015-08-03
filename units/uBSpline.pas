unit uBSpline;

interface

uses uspline, utypes, uConstants;

type
  /// <summary>
  /// Class for BSpline: parametric curves
  /// </summary>
  /// <remarks>
  /// X=f(T) and Y=f(T); where T is the parameter
  /// </remarks>
  TBSpline = class(TBaseSpline)
  private
    Xa, Ya, der2Xa, der2Ya: TVector;
    N: Integer;
    lder_Y1, lder_Y2: float;
  protected
    /// <summary>
    /// second derivative
    /// </summary>
    procedure BSpline(Xa, Ya: TVector; N: Integer; derY1, derYn: float;
      out X2, Y2: TVector);
    /// <summary>
    /// Evaluates T and return X=f(T) and Y=f(T)
    /// </summary>
    procedure CubicBSplineInterpolation(Xa, Ya, der2Xa, der2Ya: TVector;
      N: Integer; T: float; out X, Y: float);
  public
    constructor Create(Xs, Ys: TVector; size: Integer; derY1: float = 1E30;
      derYn: float = 1E30); overload;
    constructor Create(Xs, Ys: TIntVector; size: Integer; derY1: float = 1E30;
      derYn: float = 1E30); overload;
    destructor Destroy; override;
    procedure CubicSpline(T: float; out X, Y: float); reintroduce;
    procedure Cubic1DBSpline(T: TVector; out X, Y: TVector); overload;
    procedure Cubic1DBSpline(Ub: Integer; out X, Y: TVector); overload;
  end;

implementation

uses umath, math, uoperations, utypecasts, uinterpolation;

{ TBSpline }

procedure TBSpline.BSpline(Xa, Ya: TVector; N: Integer; derY1, derYn: float;
  out X2, Y2: TVector);
var
  i, k: Integer;
  p, qn, sig, un: float;
  u1, u2: TVector;
begin
  if N < 1 then
  begin
    X2 := nil;
    Y2 := nil;
    exit;
  end;
  DimVector(u1, N - 1);
  DimVector(u2, N - 1);
  DimVector(X2, N);
  DimVector(Y2, N);
  if (derY1 > 0.99E30) then
  begin // The lower boundary condition is set either to be “natural”
    X2[1] := 0;
    u1[1] := 0;
    Y2[1] := 0;
    u2[1] := 0;
  end
  else
  begin // or else to have a specified first derivative.
    X2[1] := -0.5;
    u1[1] := 3.0 * (Xa[2] - Xa[1] - derY1);
    Y2[1] := -0.5;
    u2[1] := 3.0 * (Ya[2] - Ya[1] - derY1);
  end;
  sig := 0.5;
  for i := 2 to N - 1 do
  begin // This is the decomposition loop of the tridiagonal algorithm.
    // y2 and u are used for temporary storage of the decomposed factors.
    p := sig * X2[i - 1] + 2.0;
    X2[i] := (sig - 1.0) / p;
    u1[i] := Xa[i + 1] - Xa[i] - Xa[i] + Xa[i - 1];
    u1[i] := ((6.0 * u1[i] / 2 - (sig * u1[i - 1]))) / p;
    p := sig * Y2[i - 1] + 2.0;
    Y2[i] := (sig - 1.0) / p;
    u2[i] := Ya[i + 1] - Ya[i] - Ya[i] + Ya[i - 1];
    u2[i] := ((6.0 * u2[i] / 2 - (sig * u2[i - 1]))) / p;
  end;
  if (derYn > 0.99E30) then
  begin // The upper boundary condition is set either to be “natural”
    sig := 0.0;
    qn := 0.0;
    un := 0.0;
  end
  else
  begin // or else to have a specified first derivative.
    sig := 0.5;
    qn := 3.0 * (derYn - Xa[N] + Xa[N - 1]);
    un := 3.0 * (derYn - Ya[N] + Ya[N - 1]);
  end;
  X2[N] := (qn - (sig * u1[N - 1])) / (sig * X2[N - 1] + 1.0);
  Y2[N] := (un - (sig * u2[N - 1])) / (sig * Y2[N - 1] + 1.0);
  for k := N - 1 downto 1 do
  begin
    // This is the backsubstitution loop of the tridiagonal algorithm.
    X2[k] := X2[k] * X2[k + 1] + u1[k];
    Y2[k] := Y2[k] * Y2[k + 1] + u2[k];
  end;
  DelVector(u1);
  DelVector(u2);
end;

procedure TBSpline.CubicBSplineInterpolation(Xa, Ya, der2Xa, der2Ya: TVector;
  N: Integer; T: float; out X, Y: float);
var
  klo, khi, k: Integer;
  h, b, a, min, max: float;
begin
  if N < 1 then
  begin
    X := NAN;
    Y := NAN;
    exit;
  end;
  min := 1;
  max := N;
  if T = min then
  begin
    X := Xa[1];
    Y := Ya[1];
    exit;
  end
  else if T = max then
  begin
    X := Xa[N];
    Y := Ya[N];
    exit;
  end
  else
  begin
    klo := 1;
    khi := N;
    while (khi - klo > 1) do
    begin
      k := (khi + klo) shr 1; // >>1
      if (k > T) then
        khi := k
      else
        klo := k;
    end;
    h := khi - klo;
    if (h = 0.0) then
    begin
      X := DefaultVal(FInfinity, Infinity);
      Y := DefaultVal(FInfinity, Infinity);
      exit; // nrerror("Bad input to routine splint"); The xa’s must be distinct.
    end;
    a := (khi - T) / h;
    b := (T - klo) / h;
    // Cubic Bspline polynomial is now evaluated.
    X := a * Xa[klo] + b * Xa[khi] +
      ((a * a * a - a) * der2Xa[klo] + (b * b * b - b) * der2Xa[khi]) *
      (h * h) / 6.0;
    Y := a * Ya[klo] + b * Ya[khi] +
      ((a * a * a - a) * der2Ya[klo] + (b * b * b - b) * der2Ya[khi]) *
      (h * h) / 6.0;
  end;
end;

constructor TBSpline.Create(Xs, Ys: TVector; size: Integer;
  derY1, derYn: float);
begin
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  Xa := Clone(Xs, size);
  Ya := Clone(Ys, size);
  BSpline(Xa, Ya, N, lder_Y1, lder_Y2, der2Xa, der2Ya);
end;

constructor TBSpline.Create(Xs, Ys: TIntVector; size: Integer;
  derY1, derYn: float);
begin
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  InttoFloat(Xs, Xa, size);
  InttoFloat(Ys, Ya, size);
  BSpline(Xa, Ya, N, lder_Y1, lder_Y2, der2Xa, der2Ya);
end;

procedure TBSpline.Cubic1DBSpline(T: TVector; out X, Y: TVector);
var
  i, m: Integer;
begin
  m := trunc(T[0]);
  DimVector(X, m);
  DimVector(Y, m);
  for i := 1 to m do
    CubicBSplineInterpolation(Xa, Ya, der2Xa, der2Ya, N, T[i], X[i], Y[i]);
end;

procedure TBSpline.Cubic1DBSpline(Ub: Integer; out X, Y: TVector);
var
  i: Integer;
begin
  DimVector(X, Ub);
  DimVector(Y, Ub);
  for i := 1 to Ub do
    CubicBSplineInterpolation(Xa, Ya, der2Xa, der2Ya, N,
      LinealInterpolation(1, 1, Ub, N, i), X[i], Y[i]);
end;

procedure TBSpline.CubicSpline(T: float; out X, Y: float);
begin
  CubicBSplineInterpolation(Xa, Ya, der2Xa, der2Ya, N, T, X, Y);
end;

destructor TBSpline.Destroy;
begin
  DelVector(Xa);
  DelVector(Ya);
  DelVector(der2Xa);
  DelVector(der2Ya);
  inherited Destroy;
end;

end.
