Unit uspline;

Interface

Uses utypes, uConstants, uinterpolation;

{ Splines }
Type
  TBaseSpline = Class(TBaseInterpolation)
  Protected
    Function lSpline(xa, Ya: TVector; N: integer;
      lder_Y1, lder_Y2: float): TVector;
    Function CubicSplineInterpolation(xa, Ya, Y2a: TVector; N: integer;
      X: float): float;
  Public
    Function CubicSpline: float; Virtual; Abstract;
  End;

  TSpline = Class(TBaseSpline)
  Private
    X1a, Ya, lder2Ya: TVector;
    N               : integer;
    lder_Y1, lder_Y2: float;
    Function Spline: TVector;
  Public
    Constructor Create(Xs, Ys: TVector; size: integer; derY1: float = 1E30;
      derYn: float = 1E30); Overload;
    Constructor Create(Xs: TVector; Ys: TIntVector; size: integer;
      derY1: float = 1E30; derYn: float = 1E30); Overload;
    Constructor Create(Xs: TIntVector; Ys: TVector; size: integer;
      derY1: float = 1E30; derYn: float = 1E30); Overload;
    Constructor Create(Xs, Ys: TIntVector; size: integer; derY1: float = 1E30;
      derYn: float = 1E30); Overload;
    Constructor Create(Ys: TVector; size: integer; derY1: float = 1E30;
      derYn: float = 1E30); Overload;
    Constructor Create(Ys: TIntVector; size: integer; derY1: float = 1E30;
      derYn: float = 1E30); Overload;
    Destructor Destroy; Override;
    Function CubicSpline(X: float): float; Reintroduce;
    Function Cubic1DSpline(X: TVector; Ub: integer): TVector; Overload;
    Function Cubic1DSpline(Ub: integer): TVector; Overload;
  End;

  TSpline2D = Class(TBaseSpline)
  Private
    X1a, X2a   : TVector;
    Ya, lder2Ya: TMatrix;
    N1, N2     : integer;
    Function Spline2d: TMatrix;
    Function Cubic2DSpline(X1, X2: float): float; Overload;
  Public
    Constructor Create(X1s, X2s: TVector; m, N: integer; Ys: TMatrix); Overload;
    Constructor Create(X1s, X2s: TVector; m, N: integer;
      Ys: TIntMatrix); Overload;
    Constructor Create(X1s, X2s: TIntVector; m, N: integer;
      Ys: TIntMatrix); Overload;
    Constructor Create(Ys: TMatrix; m, N: integer); Overload;
    Constructor Create(Ys: TIntMatrix; m, N: integer); Overload;
    Destructor Destroy; Override;
    Function CubicSpline(X1, X2: float): float; Reintroduce;
    Function Cubic2DSpline(X1, X2: TVector; Ub1, Ub2: integer)
      : TMatrix; Overload;
    Function Cubic2DSpline(Ub1, Ub2: integer): TMatrix; Overload;
  End;

  TSpline3D = Class(TBaseSpline)
  Private
    X1a, X2a, X3a: TVector;
    Ya, lder2Ya  : T3DMatrix;
    N1, N2, N3   : integer;
    Function Spline3d: T3DMatrix;
    Function Cubic3DSpline(X1, X2, X3: float): float; Overload;
  Public
    Constructor Create(X1s, X2s, X3s: TVector; m, N, o: integer;
      Ys: T3DMatrix); Overload;
    Constructor Create(X1s, X2s, X3s: TVector; m, N, o: integer;
      Ys: T3DIntMatrix); Overload;
    Constructor Create(X1s, X2s, X3s: TIntVector; m, N, o: integer;
      Ys: T3DIntMatrix); Overload;
    Constructor Create(Ys: T3DMatrix; m, N, o: integer); Overload;
    Constructor Create(Ys: T3DIntMatrix; m, N, o: integer); Overload;
    Destructor Destroy; Override;
    Function CubicSpline(X1, X2, X3: float): float; Reintroduce;
    Function Cubic3DSpline(X1, X2, X3: TVector; Ub1, Ub2, Ub3: integer)
      : T3DMatrix; Overload;
    Function Cubic3DSpline(Ub1, Ub2, Ub3: integer): T3DMatrix; Overload;
  End;

Implementation

Uses uoperations, utypecasts, usearch, math;

{ TBaseSpline }

Function TBaseSpline.lSpline(xa, Ya: TVector; N: integer;
  lder_Y1, lder_Y2: float): TVector;
Var
  i, k          : integer;
  p, qn, sig, un: float;
  u, y2         : TVector;
Begin
  If N < 1 Then
  Begin
    result := Nil;
    exit;
  End;
  DimVector(u, N - 1);
  DimVector(y2, N);
  If (lder_Y1 > 0.99E30) Then
  Begin // The lower boundary condition is set either to be “natural”
    y2[1] := 0;
    u[1] := 0;
  End
  Else
  Begin // or else to have a specified first derivative.
    y2[1] := -0.5;
    u[1] := (3.0 / (xa[2] - xa[1])) *
      ((Ya[2] - Ya[1]) / (xa[2] - xa[1]) - lder_Y1);
  End;
  For i := 2 To N - 1 Do
  Begin // This is the decomposition loop of the tridiagonal algorithm.
    // y2 and u are used for temporary storage of the decomposed factors.
    sig := (xa[i] - xa[i - 1]) / (xa[i + 1] - xa[i - 1]);
    p := sig * y2[i - 1] + 2.0;
    y2[i] := (sig - 1.0) / p;
    u[i] := ((Ya[i + 1] - Ya[i]) / (xa[i + 1] - xa[i])) -
      (((Ya[i] - Ya[i - 1]) / (xa[i] - xa[i - 1])));
    u[i] := ((6.0 * u[i] / (xa[i + 1] - xa[i - 1]) - (sig * u[i - 1]))) / p;
  End;
  If (lder_Y2 > 0.99E30) Then
  Begin // The upper boundary condition is set either to be “natural”
    qn := 0.0;
    un := 0.0;
  End
  Else
  Begin // or else to have a specified first derivative.
    qn := 0.5;
    un := (3.0 / (xa[N] - xa[N - 1])) *
      (lder_Y2 - ((Ya[N] - Ya[N - 1]) / (xa[N] - xa[N - 1])));
  End;
  y2[N] := (un - (qn * u[N - 1])) / (qn * y2[N - 1] + 1.0);
  For k := N - 1 Downto 1 Do
    // This is the backsubstitution loop of the tridiagonal algorithm.
    y2[k] := y2[k] * y2[k + 1] + u[k];
  result := y2;
  DelVector(u);
End;

Function TBaseSpline.CubicSplineInterpolation(xa, Ya, Y2a: TVector; N: integer;
  X: float): float;
Var
  klo, khi              : integer;
  h, b, a, y, lmin, lmax: float;
Begin
  If N < 1 Then
  Begin
    result := NAN;
    exit;
  End;
  lmin := xa[1];
  lmax := xa[N];
  If X <= lmin Then
  Begin
    result := Ya[1];
    exit;
  End
  Else If X >= lmax Then
  Begin
    result := Ya[N];
    exit;
  End
  Else
  Begin
    If Search.Correlated Then
      klo := Search.Hunt(xa, N, X)
    Else
      klo := Search.Locate(xa, N, X);
    khi := min(N, klo + 1);
    h := xa[khi] - xa[klo];
    If (h = 0.0) Then
    Begin
      result := Ya[klo]; // case klo = khi
      // result := DefaultVal(FInfinity, Infinity);
      exit; // nrerror("Bad xa input to routine splint"); The xa’s must be distinct.
    End;
    a := (xa[khi] - X) / h;
    b := (X - xa[klo]) / h;
    // Cubic spline polynomial is now evaluated.
    y := a * Ya[klo] + b * Ya[khi] +
      ((a * a * a - a) * Y2a[klo] + (b * b * b - b) * Y2a[khi]) * (h * h) / 6.0;
    result := y;
  End;
End;

{ TSpline }

Function TSpline.Spline: TVector;
Begin
  result := lSpline(X1a, Ya, N, lder_Y1, lder_Y2);
  Search := TSearch.Create(N);
End;

Constructor TSpline.Create(Xs, Ys: TVector; size: integer; derY1, derYn: float);
Begin
  Inherited Create;
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  X1a := Clone(Xs, size);
  Ya := Clone(Ys, size);
  lder2Ya := Spline;
End;

Constructor TSpline.Create(Xs: TVector; Ys: TIntVector; size: integer;
  derY1, derYn: float);
Begin
  Inherited Create;
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  X1a := Clone(Xs, size);
  InttoFloat(Ys, Ya, size);
  lder2Ya := Spline;
End;

Constructor TSpline.Create(Xs: TIntVector; Ys: TVector; size: integer;
  derY1, derYn: float);
Begin
  Inherited Create;
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  InttoFloat(Xs, X1a, size);
  Ya := Clone(Ys, size);
  lder2Ya := Spline;
End;

Constructor TSpline.Create(Xs, Ys: TIntVector; size: integer;
  derY1, derYn: float);
Begin
  Inherited Create;
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  InttoFloat(Xs, X1a, size);
  InttoFloat(Ys, Ya, size);
  lder2Ya := Spline;
End;

Function TSpline.Cubic1DSpline(X: TVector; Ub: integer): TVector;
Var
  i: integer;
Begin
  DimVector(result, Ub);
  For i := 1 To Ub Do
    result[i] := CubicSpline(X[i]);
End;

Function TSpline.Cubic1DSpline(Ub: integer): TVector;
Var
  i: integer;
Begin
  DimVector(result, Ub);
  For i := 1 To Ub Do
    result[i] := CubicSpline(QLinealInterpolation(1, 1, Ub, N, i));
End;

Function TSpline.CubicSpline(X: float): float;
Begin
  result := CubicSplineInterpolation(X1a, Ya, lder2Ya, N, X);
End;

Destructor TSpline.Destroy;
Begin
  DelVector(X1a);
  DelVector(Ya);
  DelVector(lder2Ya);
  Inherited Destroy;
End;

Constructor TSpline.Create(Ys: TVector; size: integer; derY1, derYn: float);
Var
  i: integer;
Begin
  Inherited Create;
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  SeqVector(X1a, size);
  Ya := Clone(Ys, size);
  Search := TSearch.Create(N);
  lder2Ya := Spline;
End;

Constructor TSpline.Create(Ys: TIntVector; size: integer; derY1, derYn: float);
Var
  i: integer;
Begin
  Inherited Create;
  N := size;
  lder_Y1 := derY1;
  lder_Y2 := derYn;
  SeqVector(X1a, size);
  InttoFloat(Ys, Ya, size);
  Search := TSearch.Create(N);
  lder2Ya := Spline;
End;

{ TSpline2D }

Function TSpline2D.Spline2d: TMatrix;
Var
  i: integer;
Begin
  DimMatrix(result, N1, N2); // m splines
  For i := 1 To N1 Do
  Begin
    result[i] := lSpline(X2a, Ya[i], N2, 1E30, 1E30);
  End;
  Search := TSearch.Create(N2);
End;

Function TSpline2D.Cubic2DSpline(X1, X2: float): float;
Var
  i          : integer;
  ytmp, yytmp: TVector;
Begin
  DimVector(yytmp, N1);
  // Perform m evaluations of the row splines constructed by splie2,
  // using the one-dimensional spline evaluator splint.
  For i := 1 To N1 Do
  Begin
    yytmp[i] := CubicSplineInterpolation(X2a, Ya[i], lder2Ya[i], N2, X2);
  End;
  With TSpline.Create(X1a, yytmp, N1) Do
    // Construct the one-dimensional column spline and evaluate it.
    Try
      result := CubicSpline(X1)
    Finally
      Free;
      DelVector(yytmp);
      DelVector(ytmp);
    End;
End;

Constructor TSpline2D.Create(X1s, X2s: TVector; m, N: integer; Ys: TIntMatrix);
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  X1a := Clone(X1s, m);
  X2a := Clone(X2s, N);
  InttoFloat(Ys, Ya, m, N);
  lder2Ya := Spline2d;
End;

Constructor TSpline2D.Create(X1s, X2s: TVector; m, N: integer; Ys: TMatrix);
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  X1a := Clone(X1s, N1);
  X2a := Clone(X2s, N2);
  Ya := Clone(Ys, N1, N2);
  lder2Ya := Spline2d;
End;

Constructor TSpline2D.Create(X1s, X2s: TIntVector; m, N: integer;
  Ys: TIntMatrix);
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  InttoFloat(X1s, X1a, N1);
  InttoFloat(X2s, X2a, N2);
  InttoFloat(Ys, Ya, N1, N2);
  lder2Ya := Spline2d;
End;

Function TSpline2D.Cubic2DSpline(X1, X2: TVector; Ub1, Ub2: integer): TMatrix;
Var
  i, j : integer;
  yytmp: TVector;
Begin
  DimMatrix(result, Ub1, Ub2);
  For j := 1 To Ub2 Do
  Begin
    DimVector(yytmp, N1);
    For i := 1 To N1 Do
    Begin
      yytmp[i] := CubicSplineInterpolation(X2a, Ya[i], lder2Ya[i], N2, X2[j]);
    End;
    With TSpline.Create(X1a, yytmp, N1) Do
    // Construct the one-dimensional column spline and evaluate it.
    Begin
      For i := 1 To Ub1 Do
      Begin
        result[i, j] := CubicSpline(X1[i]);
      End;
      Free;
    End;
    DelVector(yytmp);
  End;
End;

Function TSpline2D.Cubic2DSpline(Ub1, Ub2: integer): TMatrix;
Var
  i, j  : integer;
  interp: float;
  yytmp : TVector;
Begin
  DimMatrix(result, Ub1, Ub2);
  For j := 1 To Ub2 Do
  Begin
    DimVector(yytmp, N1);
    interp := QLinealInterpolation(1, 1, Ub2, N2, j);
    For i := 1 To N1 Do
    Begin
      yytmp[i] := CubicSplineInterpolation(X2a, Ya[i], lder2Ya[i], N2, interp);
    End;
    With TSpline.Create(X1a, yytmp, N1) Do
    // Construct the one-dimensional column spline and evaluate it.
    Begin
      For i := 1 To Ub1 Do
      Begin
        result[i, j] := CubicSpline(QLinealInterpolation(1, 1, Ub1, N1, i));
      End;
      Free;
    End;
    DelVector(yytmp);
  End;
End;

Function TSpline2D.CubicSpline(X1, X2: float): float;
Begin
  result := Cubic2DSpline(X1, X2);
End;

Destructor TSpline2D.Destroy;
Begin
  DelVector(X1a);
  DelVector(X2a);
  DelMatrix(Ya);
  DelMatrix(lder2Ya);
  Inherited Destroy;
End;

Constructor TSpline2D.Create(Ys: TMatrix; m, N: integer);
Var
  i: integer;
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  SeqVector(X1a, N1);
  SeqVector(X2a, N2);
  Ya := Clone(Ys, N1, N2);
  lder2Ya := Spline2d;
End;

Constructor TSpline2D.Create(Ys: TIntMatrix; m, N: integer);
Var
  i: integer;
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  SeqVector(X1a, N1);
  SeqVector(X2a, N2);
  InttoFloat(Ys, Ya, N1, N2);
  lder2Ya := Spline2d;
End;

{ TSpline3D }

Function TSpline3D.Spline3d: T3DMatrix;
Var
  i, j: integer;
Begin
  DimMatrix(result, N1, N2, N3); // m*n splines
  For i := 1 To N1 Do
    For j := 1 To N2 Do
    Begin
      result[i, j] := lSpline(X3a, Ya[i, j], N3, 1E30, 1E30);
    End;
  Search := TSearch.Create(N3);
End;

Function TSpline3D.Cubic3DSpline(X1, X2, X3: float): float;
Var
  i, j                              : integer;
  { ytmp, yytmp: TVector; // } yytmp: TMatrix;
Begin
  // finding a plane
  // costs m*(n+1)+1 cubic splines and m+1 splines
  DimMatrix(yytmp, N1, N2);
  For i := 1 To N1 Do // m*(n+1) csp and m sp
    For j := 1 To N2 Do
      yytmp[i, j] := CubicSplineInterpolation(X3a, Ya[i, j],
        lder2Ya[i, j], N3, X3);
  With TSpline2D.Create(X1a, X2a, N1, N2, yytmp) Do // 1 sp
    Try
      result := CubicSpline(X1, X2); // 1 csp
    Finally
      Free;
      DelMatrix(yytmp);
    End;
End;

Constructor TSpline3D.Create(X1s, X2s, X3s: TVector; m, N, o: integer;
  Ys: T3DIntMatrix);
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  N3 := o;
  X1a := Clone(X1s, N1);
  X2a := Clone(X2s, N2);
  X3a := Clone(X3s, N3);
  InttoFloat(Ys, Ya, N1, N2, N3);
  lder2Ya := Spline3d;
End;

Constructor TSpline3D.Create(X1s, X2s, X3s: TVector; m, N, o: integer;
  Ys: T3DMatrix);
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  N3 := o;
  X1a := Clone(X1s, N1);
  X2a := Clone(X2s, N2);
  X3a := Clone(X3s, N3);
  Ya := Clone(Ys, N1, N2, N3);
  lder2Ya := Spline3d;
End;

Constructor TSpline3D.Create(X1s, X2s, X3s: TIntVector; m, N, o: integer;
  Ys: T3DIntMatrix);
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  N3 := o;
  InttoFloat(X1s, X1a, N1);
  InttoFloat(X2s, X2a, N2);
  InttoFloat(X3s, X3a, N3);
  InttoFloat(Ys, Ya, N1, N2, N3);
  lder2Ya := Spline3d;
End;

Function TSpline3D.Cubic3DSpline(X1, X2, X3: TVector; Ub1, Ub2, Ub3: integer)
  : T3DMatrix;
Var
  i, j, k: integer;
  yytmp  : TMatrix;
Begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  For k := 1 To Ub3 Do
  Begin
    DimMatrix(yytmp, N1, N2);
    For i := 1 To N1 Do
      For j := 1 To N2 Do
      Begin
        yytmp[i, j] := CubicSplineInterpolation(X3a, Ya[i, j], lder2Ya[i, j],
          N3, X3[k]);
      End;
    With TSpline2D.Create(X1a, X2a, N1, N2, yytmp) Do
    // Construct the two-dimensional spline and evaluate it.
    Begin
      For i := 1 To Ub1 Do
        For j := 1 To Ub2 Do
        Begin
          result[i, j, k] := CubicSpline(X1[i], X2[j]);
        End;
      Free;
    End;
    DelMatrix(yytmp);
  End;
End;

Function TSpline3D.Cubic3DSpline(Ub1, Ub2, Ub3: integer): T3DMatrix;
Var
  i, j, k: integer;
  interp : float;
  yytmp  : TMatrix;
Begin
  DimMatrix(result, Ub1, Ub2, Ub3);
  For k := 1 To Ub3 Do
  Begin
    DimMatrix(yytmp, N1, N2);
    interp := QLinealInterpolation(1, 1, Ub3, N3, k);
    For i := 1 To N1 Do
      For j := 1 To N2 Do
      Begin
        yytmp[i, j] := CubicSplineInterpolation(X3a, Ya[i, j], lder2Ya[i, j],
          N3, interp);
      End;
    With TSpline2D.Create(X1a, X2a, N1, N2, yytmp) Do
    // Construct the one-dimensional column spline and evaluate it.
    Begin
      For i := 1 To Ub1 Do
      Begin
        interp := QLinealInterpolation(1, 1, Ub1, N1, i);
        For j := 1 To Ub2 Do
        Begin
          result[i, j, k] := CubicSpline(interp, QLinealInterpolation(1, 1,
            Ub2, N2, j));
        End;
      End;
      Free;
    End;
    DelMatrix(yytmp);
  End;
End;

Function TSpline3D.CubicSpline(X1, X2, X3: float): float;
Begin
  result := Cubic3DSpline(X1, X2, X3);
End;

Destructor TSpline3D.Destroy;
Begin
  DelVector(X1a);
  DelVector(X2a);
  DelVector(X3a);
  DelMatrix(Ya);
  DelMatrix(lder2Ya);
  Inherited Destroy;
End;

Constructor TSpline3D.Create(Ys: T3DMatrix; m, N, o: integer);
Var
  i: integer;
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  N3 := o;
  SeqVector(X1a, N1);
  SeqVector(X2a, N2);
  SeqVector(X3a, N3);
  Ya := Clone(Ys, N1, N2, N3);
  lder2Ya := Spline3d;
End;

Constructor TSpline3D.Create(Ys: T3DIntMatrix; m, N, o: integer);
Var
  i: integer;
Begin
  Inherited Create;
  N1 := m;
  N2 := N;
  N3 := o;
  SeqVector(X1a, N1);
  SeqVector(X2a, N2);
  SeqVector(X3a, N3);
  InttoFloat(Ys, Ya, N1, N2, N3);
  lder2Ya := Spline3d;
End;

End.
