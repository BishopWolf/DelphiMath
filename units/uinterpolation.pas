{ Unit uinterpolation : Interpolation Unit

  Created by : Alex Vergara Gil

  Contains the routines for interpolation and resizes of vector,
  matrixes and 3DMatrixes; also contains inrange and ensurerange methods

  Conventions:
  y      3______4   the 2D convention
  |      |      |
  |      |      |
  ----x  1------2

  z2-------6   the 3D convention
  /|      /|
  / |     / |
  4 ----- 8  |
  |  1 ---|-y5
  | /     | /
  |/      |/
  x3 ----- 7
}

Unit uinterpolation;

Interface

Uses utypes, uConstants, usearch;

Function InRange(AValue, AMin, AMax: float): Boolean;
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
Function EnsureRange(AValue, AMin, AMax: float): float;
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
Function EnsureRangeI(AValue, AMin, AMax: integer): integer;
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
Function GoToRangeF(AValue, AMin, AMax: float): float;
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
Function GoToRangeI(AValue, AMin, AMax: integer): integer;
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
Function QLinealInterpolation(X1, y1, x2, y2, X: float): float;
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
Function LinealInterpolation(X1, y1, x2, y2, X: float): float;
FUNCTION Lineal2DInterpolation(X1, y1, x2, y2, Z1, Z2, Z3, Z4, X,
  Y: float): float;
FUNCTION Lineal3DInterpolation(X1, y1, Z1, x2, y2, Z2, T1, T2, T3, T4, T5, T6,
  T7, T8, X, Y, Z: float): float;

Type
  TBaseInterpolation = Class
  Protected
    Search: TSearch;
  Public
    Destructor Destroy; Override;
  End;

  TLinealInterpolation = Class(TBaseInterpolation)
  Private
    lX, lT: TVector;
    lUb1: integer;
  Public
    Constructor Create(X, Y: TVector; Ub: integer); Overload;
    Constructor Create(Y: TVector; Ub: integer); Overload;
    Constructor Create(X, Y: TIntVector; Ub: integer); Overload;
    Constructor Create(Y: TIntVector; Ub: integer); Overload;
    Destructor Destroy; Override;
    Function Interpolate(X: float): float;
    Function Interpolate1D(Ub: integer): TVector;
  End;

  TLineal2DInterpolation = Class(TBaseInterpolation)
  Private
    lX, lY: TVector;
    lT: TMatrix;
    lUb1, lUb2: integer;
  Public
    Constructor Create(X, Y: TVector; Z: TMatrix; Ub1, Ub2: integer); Overload;
    Constructor Create(Z: TMatrix; Ub1, Ub2: integer); Overload;
    Constructor Create(X, Y: TIntVector; Z: TIntMatrix;
      Ub1, Ub2: integer); Overload;
    Constructor Create(Z: TIntMatrix; Ub1, Ub2: integer); Overload;
    Destructor Destroy; Override;
    Function Interpolate(X, Y: float): float;
    Function Interpolate2D(Ub1, Ub2: integer): TMatrix;
  End;

  TLineal3DInterpolation = Class(TBaseInterpolation)
  Private
    lX, lY, lZ: TVector;
    lT: T3dMatrix;
    lUb1, lUb2, lUb3: integer;
  Public
    Constructor Create(X, Y, Z: TVector; T: T3dMatrix;
      Ub1, Ub2, Ub3: integer); Overload;
    Constructor Create(T: T3dMatrix; Ub1, Ub2, Ub3: integer); Overload;
    Constructor Create(X, Y, Z: TIntVector; T: T3DIntMatrix;
      Ub1, Ub2, Ub3: integer); Overload;
    Constructor Create(T: T3DIntMatrix; Ub1, Ub2, Ub3: integer); Overload;
    Destructor Destroy; Override;
    Function Interpolate(X, Y, Z: float): float;
    Function Interpolate3D(Ub1, Ub2, Ub3: integer): T3dMatrix;
  End;

FUNCTION BiLinealInterpolation(X1, y1, x2, y2, X: float): float;
FUNCTION BiLineal2DInterpolation(X1, y1, x2, y2, Z1, Z2, Z3, Z4, X,
  Y: float): float;
FUNCTION BiLineal3DInterpolation(X1, y1, Z1, x2, y2, Z2, T1, T2, T3, T4, T5, T6,
  T7, T8, X, Y, Z: float): float;

Function PolinomialInterpolation(Xa, Ya: TVector; n: integer; X: float;
  Out error: float): float; Overload;
Function Polinomial2DInterpolation(X1a, X2a: TVector; Ya: TMatrix;
  m, n: integer; X, Y: float; Out error: float): float; Overload;
Function Polinomial3DInterpolation(X1a, X2a, X3a: TVector; Ya: T3dMatrix;
  m, n, o: integer; X, Y, Z: float; Out error: float): float; Overload;

Function RationalFunctionInterpolation(Xa, Ya: TVector; n: integer; X: float;
  Out error: float): float; Overload;
Function RationalFunction2DInterpolation(X1a, X2a: TVector; Ya: TMatrix;
  m, n: integer; X, Y: float; Out error: float): float; Overload;
Function RationalFunction3DInterpolation(X1a, X2a, X3a: TVector; Ya: T3dMatrix;
  m, n, o: integer; X, Y, Z: float; Out error: float): float; Overload;

Function PolinomialInterpolation(Xa: TVector; Ya: TIntVector; n: integer;
  X: float; Out error: float): float; Overload;
Function Polinomial2DInterpolation(X1a, X2a: TVector; Ya: TIntMatrix;
  m, n: integer; X, Y: float; Out error: float): float; Overload;
Function Polinomial3DInterpolation(X1a, X2a, X3a: TVector; Ya: T3DIntMatrix;
  m, n, o: integer; X, Y, Z: float; Out error: float): float; Overload;

Function RationalFunctionInterpolation(Xa: TVector; Ya: TIntVector; n: integer;
  X: float; Out error: float): float; Overload;
Function RationalFunction2DInterpolation(X1a, X2a: TVector; Ya: TIntMatrix;
  m, n: integer; X, Y: float; Out error: float): float; Overload;
Function RationalFunction3DInterpolation(X1a, X2a, X3a: TVector;
  Ya: T3DIntMatrix; m, n, o: integer; X, Y, Z: float; Out error: float)
  : float; Overload;

Implementation

Uses uoperations, math, utypecasts, uspline, umath;

Function InRange(AValue, AMin, AMax: float): Boolean;
Begin
  Result := (AValue >= AMin) And (AValue <= AMax);
End;

Function EnsureRange(AValue, AMin, AMax: float): float;
Begin
  Result := AValue;
  assert(AMin <= AMax);
  If Result < AMin Then
    Result := AMin;
  If Result > AMax Then
    Result := AMax;
End;

Function EnsureRangeI(AValue, AMin, AMax: integer): integer;
Begin
  Result := math.EnsureRange(AValue, AMin, AMax);
End;

Function GoToRangeF(AValue, AMin, AMax: float): float;
Begin
  Result := AValue;
  assert(AMin <= AMax);
  While Result < AMin Do
    Result := Result + (AMax - AMin + 1);
  While Result > AMax Do
    Result := Result - (AMax - AMin + 1);
End;

Function GoToRangeI(AValue, AMin, AMax: integer): integer;
Begin
  Result := AValue;
  assert(AMin <= AMax);
  While Result < AMin Do
    Result := Result + (AMax - AMin + 1);
  While Result > AMax Do
    Result := Result - (AMax - AMin + 1);
End;

Function LinealInterpolation(X1, y1, x2, y2, X: float): float;
Begin
  If (X1 = x2) And (y1 = y2) Then
    Result := y1
  Else // avoiding divition by zero
    If (X1 <> x2) Then
      Result := QLinealInterpolation(X1, y1, x2, y2, X)
    Else
      Result := DefaulTVal(FSing, (y1 + y2) / 2);
  // Same x's but different y's is an error
  If y1 <= y2 Then // this is only if you doesn't want extrapolation
    Result := EnsureRange(Result, y1, y2)
  Else
    Result := EnsureRange(Result, y2, y1)
End;

Function QLinealInterpolation(X1, y1, x2, y2, X: float): float;
Begin
  // this is a quick lineal interpolation, without checks, not recomended
  Result := Divide(y2 * (X - X1) + y1 * (x2 - X), x2 - X1);
End;

FUNCTION Lineal2DInterpolation(X1, y1, x2, y2, Z1, Z2, Z3, Z4, X,
  Y: float): float;
Var
  p1, p2: float;
Begin
  // On most literatures this function is called Bilineal Interpolation
  // y      3______4
  // |      |      |
  // |      |      |
  // ----x  1------2
  p1 := LinealInterpolation(X1, Z1, x2, Z2, X);
  p2 := LinealInterpolation(X1, Z3, x2, Z4, X);
  Result := LinealInterpolation(y1, p1, y2, p2, Y);
End;

FUNCTION Lineal3DInterpolation(X1, y1, Z1, x2, y2, Z2, T1, T2, T3, T4, T5, T6,
  T7, T8, X, Y, Z: float): float;
Var
  p1, p2, p3, p4: float;
Begin
  // trilinear interpolation
  // ---z2----- 6
  // --/|      /|
  // -/ |     / |
  // 4 ----- 8  |
  // |  1 ---|-y5
  // | /     | /
  // |/      |/
  // x3 ----- 7
  // here there are two method's and both are equivalent
  // First method: finding a plane  (7 LinInt = 4 direct + 3 LinInt2D)
  p1 := LinealInterpolation(Z1, T1, Z2, T2, Z);
  p2 := LinealInterpolation(Z1, T3, Z2, T4, Z);
  p3 := LinealInterpolation(Z1, T5, Z2, T6, Z);
  p4 := LinealInterpolation(Z1, T7, Z2, T8, Z);
  Result := Lineal2DInterpolation(X1, y1, x2, y2, p1, p2, p3, p4, X, Y);
  // sencond method: finding a line (7 LinInt = 2*(3 LinInt2D)+1 direct)
  // p1:=Lineal2DInterpolation(y1,z1,y2,z2,t1,t5,t2,t6,y,z);
  // p2:=Lineal2DInterpolation(y1,z1,y2,z2,t3,t7,t4,t8,y,z);
  // result:=LinealInterpolation(x1,p1,x2,p2,x);
End;

{ Function LinealInterpolation(X1, y1: TVector; X: float): float; overload;
  FUNCTION Lineal2DInterpolation(X1, y1: TVector; Z1: Tmatrix; X, Y: float)
  : float; overload;
  FUNCTION Lineal3DInterpolation(X1, y1, Z1: TVector; T1: T3DMatrix;
  X, Y, Z: float): float; overload; }

Function BiLinealInterpolation(X1, y1, x2, y2, X: float): float;
Var
  d1, d2: float;
Begin
  // this is a variation of the rational function interpolation using only first and second degree
  If X <= X1 Then
    Result := y1
  Else If X >= x2 Then
    Result := y2
  Else
  Begin
    d1 := x2 - X;
    d2 := X - X1;
    // result:=((d2/d1)*y1+(d1/d2)*y2)/((d2/d1)+(d1/d2)); //no sirve si d1 o d2 = 0
    // pero lo anterior se traduce en:
    d1 := d1 * d1;
    d2 := d2 * d2;
    Result := (d2 * y1 + d1 * y2) / (d1 + d2);
    // incluso mas eficiente
  End;
End;

FUNCTION BiLineal2DInterpolation(X1, y1, x2, y2, Z1, Z2, Z3, Z4, X,
  Y: float): float;
Var
  p1, p2: float;
Begin
  p1 := BiLinealInterpolation(X1, Z1, x2, Z2, X);
  p2 := BiLinealInterpolation(X1, Z3, x2, Z4, X);
  Result := BiLinealInterpolation(y1, p1, y2, p2, Y);
End;

FUNCTION BiLineal3DInterpolation(X1, y1, Z1, x2, y2, Z2, T1, T2, T3, T4, T5, T6,
  T7, T8, X, Y, Z: float): float;
Var
  p1, p2, p3, p4: float;
Begin
  p1 := BiLinealInterpolation(Z1, T1, Z2, T2, Z);
  p2 := BiLinealInterpolation(Z1, T3, Z2, T4, Z);
  p3 := BiLinealInterpolation(Z1, T5, Z2, T6, Z);
  p4 := BiLinealInterpolation(Z1, T7, Z2, T8, Z);
  Result := BiLineal2DInterpolation(X1, y1, x2, y2, p1, p2, p3, p4, X, Y);
End;

Function PolinomialInterpolation(Xa, Ya: TVector; n: integer; X: float;
  Out error: float): float;
Var
  i, m, ns: integer;
  den, dif, dift, ho, hp, w, Y: float;
  c, d: TVector;
Begin
  ns := 1;
  dif := abs(X - Xa[1]);
  DimVector(c, n);
  DimVector(d, n);
  // Here we find the index ns of the closest table entry, and initialize the tableau of c’s and d’s.
  For i := 1 To n Do
  Begin
    dift := abs(X - Xa[i]);
    If (dift < dif) Then
    Begin
      ns := i;
      dif := dift;
    End;
    c[i] := Ya[i];
    d[i] := Ya[i];
  End;
  error := 1.0E30;
  Y := Ya[ns];
  dec(ns);
  For m := 1 To n - 1 Do
  Begin // For each column of the tableau,
    For i := 1 To n - m Do
    Begin // we loop over the current c’s and d’s and update them.
      ho := Xa[i] - X;
      hp := Xa[i + m] - X;
      w := c[i + 1] - d[i];
      den := ho - hp;
      If (den = 0.0) Then
      Begin
        Result := DefaulTVal(FSing, Infinity);
        exit;
      End;
      // nrerror("Error in routine polint");
      // This error can occur only if two input xa’s are (to within roundoff) identical.
      den := w / den;
      d[i] := hp * den; // Here the c’s and d’s are updated.
      c[i] := ho * den;
    End;
    If (2 * ns < (n - m)) Then
    Begin
      error := c[ns + 1];
      Y := Y + error;
    End
    Else
    Begin
      error := d[ns];
      dec(ns);
      Y := Y + error;
    End;
    {
      After each column in the tableau is completed, we decide which correction, c or d,
      we want to add to our accumulating value of y, i.e., which path to take through the
      tableau—forking up or down. We do this in such a way as to take the most “straight
      line” route through the tableau to its apex, updating ns accordingly to keep track of
      where we are. This route keeps the partial approximations centered (insofar as possible)
      on the target x. The last dy added is thus the error indication.
    }
  End;
  DelVector(d);
  DelVector(c);
  Result := Y;
End;

Function Polinomial2DInterpolation(X1a, X2a: TVector; Ya: TMatrix;
  m, n: integer; X, Y: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  // First we find a line
  For i := 1 To m Do
  Begin
    y2[i] := PolinomialInterpolation(X2a, Ya[i], n, Y, temperror);
    error := error + temperror * temperror;
  End;
  // Now we interpolate among the line
  Result := PolinomialInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (m * m - m)) + (temperror / m);
End;

Function Polinomial3DInterpolation(X1a, X2a, X3a: TVector; Ya: T3dMatrix;
  m, n, o: integer; X, Y, Z: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := Polinomial2DInterpolation(X2a, X3a, Ya[i], n, o, Y, Z, temperror);
    error := error + temperror * temperror;
  End;
  Result := PolinomialInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (m * m - m)) + (temperror / m);
End;

Function RationalFunctionInterpolation(Xa, Ya: TVector; n: integer; X: float;
  Out error: float): float;
Const
  tiny = 1E-25;
Var
  m, i, ns: integer;
  w, T, hh, h, dd, Y: float;
  c, d: TVector;
Begin
  ns := 1;
  DimVector(c, n);
  DimVector(d, n);
  hh := abs(X - Xa[1]);
  For i := 1 To n Do
  Begin
    h := abs(X - Xa[i]);
    If (h = 0.0) Then
    Begin
      Y := Ya[i];
      error := 0.0;
      Result := Y;
      DelVector(c);
      DelVector(d);
      exit;
    End
    Else If (h < hh) Then
    Begin
      ns := i;
      hh := h;
    End;
    c[i] := Ya[i];
    d[i] := Ya[i] + tiny;
    // The TINY part is needed to prevent a rare zero-over-zero condition.
  End;
  Y := Ya[ns];
  dec(ns);
  For m := 1 To n - 1 Do
  Begin
    For i := 1 To n - m Do
    Begin
      w := c[i + 1] - d[i];
      h := Xa[i + m] - X;
      // h will never be zero, since this was tested in the initializing loop.
      T := (Xa[i] - X) * d[i] / h;
      dd := T - c[i + 1];
      If (dd = 0.0) Then
      Begin
        Result := DefaulTVal(FInfinity, Infinity);
        DelVector(c);
        DelVector(d);
        exit
      End;
      // nrerror("Error in routine ratint");
      { This error condition indicates that the interpolating function
        has a pole at the requested value of x. }
      dd := w / dd;
      d[i] := c[i + 1] * dd;
      c[i] := T * dd;
    End;
    If (2 * ns < (n - m)) Then
      error := c[ns + 1]
    Else
    Begin
      error := d[ns];
      dec(ns);
    End;
    Y := Y + error;
  End;
  Result := Y;
  DelVector(c);
  DelVector(d);
  exit;
End;

Function RationalFunction2DInterpolation(X1a, X2a: TVector; Ya: TMatrix;
  m, n: integer; X, Y: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := RationalFunctionInterpolation(X2a, Ya[i], n, Y, temperror);
    error := error + temperror * temperror;
  End;
  Result := RationalFunctionInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (n * n - n)) + (temperror / m);
End;

Function RationalFunction3DInterpolation(X1a, X2a, X3a: TVector; Ya: T3dMatrix;
  m, n, o: integer; X, Y, Z: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := RationalFunction2DInterpolation(X2a, X3a, Ya[i], n, o, Y, Z,
      temperror);
    error := error + temperror * temperror;
  End;
  Result := RationalFunctionInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (m * m - m)) + (temperror / m);
End;

Function PolinomialInterpolation(Xa: TVector; Ya: TIntVector; n: integer;
  X: float; Out error: float): float;
Var
  i, m, ns: integer;
  den, dif, dift, ho, hp, w, Y: float;
  c, d: TVector;
Begin
  ns := 1;
  dif := abs(X - Xa[1]);
  DimVector(c, n);
  DimVector(d, n);
  For i := 1 To n Do
  Begin // { Here we find the index ns of the closest table entry, and initialize the tableau of c’s and d’s.
    dift := abs(X - Xa[i]);
    If (dift < dif) Then
    Begin
      ns := i;
      dif := dift;
    End;
    c[i] := Ya[i];
    d[i] := Ya[i];
  End;
  error := 1.0E30;
  Y := Ya[ns];
  dec(ns);
  For m := 1 To n - 1 Do
  Begin // For each column of the tableau,
    For i := 1 To n - m Do
    Begin // we loop over the current c’s and d’s and update them.
      ho := Xa[i] - X;
      hp := Xa[i + m] - X;
      w := c[i + 1] - d[i];
      den := ho - hp;
      If (den = 0.0) Then
      Begin
        Result := DefaulTVal(FInfinity, Infinity);
        exit;
      End;
      // nrerror("Error in routine polint");
      // This error can occur only if two input xa’s are (to within roundoff) identical.
      den := w / den;
      d[i] := hp * den; // Here the c’s and d’s are updated.
      c[i] := ho * den;
    End;
    If (2 * ns < (n - m)) Then
    Begin
      error := c[ns + 1];
      Y := Y + error;
    End
    Else
    Begin
      error := d[ns];
      dec(ns);
      Y := Y + error;
    End;
    {
      After each column in the tableau is completed, we decide which correction, c or d,
      we want to add to our accumulating value of y, i.e., which path to take through the
      tableau—forking up or down. We do this in such a way as to take the most “straight
      line” route through the tableau to its apex, updating ns accordingly to keep track of
      where we are. This route keeps the partial approximations centered (insofar as possible)
      on the target x. The last dy added is thus the error indication.
    }
  End;
  DelVector(d);
  DelVector(c);
  Result := Y;
End;

Function Polinomial2DInterpolation(X1a, X2a: TVector; Ya: TIntMatrix;
  m, n: integer; X, Y: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := PolinomialInterpolation(X2a, Ya[i], n, Y, temperror);
    error := error + temperror * temperror;
  End;
  Result := PolinomialInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (m * m - m)) + (temperror / m);
End;

Function Polinomial3DInterpolation(X1a, X2a, X3a: TVector; Ya: T3DIntMatrix;
  m, n, o: integer; X, Y, Z: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := Polinomial2DInterpolation(X2a, X3a, Ya[i], n, o, Y, Z, temperror);
    error := error + temperror * temperror;
  End;
  Result := PolinomialInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (m * m - m)) + (temperror / m);
End;

Function RationalFunctionInterpolation(Xa: TVector; Ya: TIntVector; n: integer;
  X: float; Out error: float): float;
Const
  tiny = 1E-25;
Var
  m, i, ns: integer;
  w, T, hh, h, dd, Y: float;
  c, d: TVector;
Begin
  ns := 1;
  DimVector(c, n);
  DimVector(d, n);
  hh := abs(X - Xa[1]);
  For i := 1 To n Do
  Begin
    h := abs(X - Xa[i]);
    If (h = 0.0) Then
    Begin
      Y := Ya[i];
      error := 0.0;
      Result := Y;
      DelVector(c);
      DelVector(d);
      exit;
    End
    Else If (h < hh) Then
    Begin
      ns := i;
      hh := h;
    End;
    c[i] := Ya[i];
    d[i] := Ya[i] + tiny;
    // The TINY part is needed to prevent a rare zero-over-zero condition.
  End;
  Y := Ya[ns];
  dec(ns);
  For m := 1 To n - 1 Do
  Begin
    For i := 1 To n - m Do
    Begin
      w := c[i + 1] - d[i];
      h := Xa[i + m] - X;
      // h will never be zero, since this was tested in the initializing loop.
      T := (Xa[i] - X) * d[i] / h;
      dd := T - c[i + 1];
      If (dd = 0.0) Then
      Begin
        Result := DefaulTVal(FInfinity, Infinity);
        DelVector(c);
        DelVector(d);
        exit
      End; // nrerror("Error in routine ratint");
      { This error condition indicates that the interpolating function
        has a pole at the requested value of x. }
      dd := w / dd;
      d[i] := c[i + 1] * dd;
      c[i] := T * dd;
    End;
    If (2 * ns < (n - m)) Then
      error := c[ns + 1]
    Else
    Begin
      error := d[ns];
      dec(ns);
    End;
    Y := Y + error;
  End;
  Result := Y;
  DelVector(c);
  DelVector(d);
  exit;
End;

Function RationalFunction2DInterpolation(X1a, X2a: TVector; Ya: TIntMatrix;
  m, n: integer; X, Y: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := RationalFunctionInterpolation(X2a, Ya[i], n, Y, temperror);
    error := error + temperror * temperror;
  End;
  Result := RationalFunctionInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (n * n - n)) + (temperror / m);
End;

Function RationalFunction3DInterpolation(X1a, X2a, X3a: TVector;
  Ya: T3DIntMatrix; m, n, o: integer; X, Y, Z: float; Out error: float): float;
Var
  y2: TVector;
  i: integer;
  temperror: float;
Begin
  DimVector(y2, m);
  error := 0;
  For i := 1 To m Do
  Begin
    y2[i] := RationalFunction2DInterpolation(X2a, X3a, Ya[i], n, o, Y, Z,
      temperror);
    error := error + temperror * temperror;
  End;
  Result := RationalFunctionInterpolation(X1a, y2, m, X, temperror);
  DelVector(y2);
  error := sqrt(error / (m * m - m)) + (temperror / m);
End;

{ TBaseInterpolation }

Destructor TBaseInterpolation.Destroy;
Begin
  Search.Free;
  Inherited Destroy;
End;

{ TLinealInterpolation }

Constructor TLinealInterpolation.Create(X, Y: TVector; Ub: integer);
Begin
  lX := Clone(X, Ub);
  lT := Clone(Y, Ub);
  lUb1 := Ub;
  Search := TSearch.Create(lUb1);
End;

Constructor TLinealInterpolation.Create(Y: TVector; Ub: integer);
Begin
  SeqVector(lX, Ub);
  lT := Clone(Y, Ub);
  lUb1 := Ub;
  Search := TSearch.Create(lUb1);
End;

Constructor TLinealInterpolation.Create(X, Y: TIntVector; Ub: integer);
Begin
  InttoFloat(X, lX, Ub);
  InttoFloat(Y, lT, Ub);
  lUb1 := Ub;
  Search := TSearch.Create(lUb1);
End;

Constructor TLinealInterpolation.Create(Y: TIntVector; Ub: integer);
Begin
  SeqVector(lX, Ub);
  InttoFloat(Y, lT, Ub);
  lUb1 := Ub;
  Search := TSearch.Create(lUb1);
End;

Destructor TLinealInterpolation.Destroy;
Begin
  DelVector(lX);
  DelVector(lT);
  Inherited Destroy;
End;

Function TLinealInterpolation.Interpolate(X: float): float;
Var
  xl, xh: integer;
Begin
  If Search.Correlated Then
    xl := Search.Hunt(lX, lUb1, X)
  Else
    xl := Search.Locate(lX, lUb1, X);
  xh := min(lUb1, xl + 1);
  Result := LinealInterpolation(lX[xl], lT[xl], lX[xh], lT[xh], X);
End;

Function TLinealInterpolation.Interpolate1D(Ub: integer): TVector;
Var
  i: integer;
Begin
  DimVector(Result, Ub);
  For i := 1 To Ub Do
    Result[i] := Interpolate(QLinealInterpolation(1, 1, Ub, lUb1, i));
End;

{ TLineal2DInterpolation }

Constructor TLineal2DInterpolation.Create(X, Y: TVector; Z: TMatrix;
  Ub1, Ub2: integer);
Begin
  lX := Clone(X, Ub1);
  lY := Clone(Y, Ub2);
  lT := Clone(Z, Ub1, Ub2);
  lUb1 := Ub1;
  lUb2 := Ub2;
  Search := TSearch.Create(lUb2);
End;

Constructor TLineal2DInterpolation.Create(Z: TMatrix; Ub1, Ub2: integer);
Begin
  SeqVector(lX, Ub1);
  SeqVector(lY, Ub2);
  lT := Clone(Z, Ub1, Ub2);
  lUb1 := Ub1;
  lUb2 := Ub2;
  Search := TSearch.Create(lUb2);
End;

Constructor TLineal2DInterpolation.Create(X, Y: TIntVector; Z: TIntMatrix;
  Ub1, Ub2: integer);
Begin
  InttoFloat(X, lX, Ub1);
  InttoFloat(Y, lY, Ub2);
  InttoFloat(Z, lT, Ub1, Ub2);
  lUb1 := Ub1;
  lUb2 := Ub2;
  Search := TSearch.Create(lUb2);
End;

Constructor TLineal2DInterpolation.Create(Z: TIntMatrix; Ub1, Ub2: integer);
Begin
  SeqVector(lX, Ub1);
  SeqVector(lY, Ub2);
  InttoFloat(Z, lT, Ub1, Ub2);
  lUb1 := Ub1;
  lUb2 := Ub2;
  Search := TSearch.Create(lUb2);
End;

Destructor TLineal2DInterpolation.Destroy;
Begin
  DelVector(lX);
  DelVector(lY);
  DelMatrix(lT);
  Inherited Destroy;
End;

Function TLineal2DInterpolation.Interpolate(X, Y: float): float;
Var
  xl, xh, i: integer;
  templin: TVector;
Begin
  If Search.Correlated Then
    xl := Search.Hunt(lY, lUb2, Y)
  Else
    xl := Search.Locate(lY, lUb2, Y);
  xh := min(lUb2, xl + 1);
  DimVector(templin, lUb1);
  For i := 1 To lUb1 Do
    templin[i] := QLinealInterpolation(lY[xl], lT[i, xl], lY[xh], lT[i, xh], Y);
  With TLinealInterpolation.Create(lX, templin, lUb1) Do
    Try
      Result := Interpolate(X);
    Finally
      Free;
      DelVector(templin);
    End;
End;

Function TLineal2DInterpolation.Interpolate2D(Ub1, Ub2: integer): TMatrix;
Var
  i, j, xl, xh: integer;
  interp: float;
  yytmp: TVector;
Begin
  DimMatrix(Result, Ub1, Ub2);
  For i := 1 To Ub1 Do
  Begin
    interp := QLinealInterpolation(1, 1, Ub1, lUb1, i);
    If Search.Correlated Then
      xl := Search.Hunt(lX, lUb1, interp)
    Else
      xl := Search.Locate(lX, lUb1, interp);
    xh := min(lUb1, xl + 1);
    DimVector(yytmp, lUb2);
    For j := 1 To lUb2 Do
    Begin
      yytmp[j] := QLinealInterpolation(lX[xl], lT[xl, j], lX[xh],
        lT[xh, j], interp);
    End;
    With TLinealInterpolation.Create(lY, yytmp, lUb2) Do
    // Construct the one-dimensional row and evaluate it.
    Begin
      Result[i] := Interpolate1D(Ub2);
      Free;
    End;
    DelVector(yytmp);
  End;
End;

{ TLineal3DInterpolation }

Constructor TLineal3DInterpolation.Create(X, Y, Z: TVector; T: T3dMatrix;
  Ub1, Ub2, Ub3: integer);
Begin
  lX := Clone(X, Ub1);
  lY := Clone(Y, Ub2);
  lZ := Clone(Z, Ub3);
  lT := Clone(T, Ub1, Ub2, Ub3);
  lUb1 := Ub1;
  lUb2 := Ub2;
  lUb3 := Ub3;
  Search := TSearch.Create(lUb3);
End;

Constructor TLineal3DInterpolation.Create(T: T3dMatrix; Ub1, Ub2, Ub3: integer);
Begin
  SeqVector(lX, Ub1);
  SeqVector(lY, Ub2);
  SeqVector(lZ, Ub3);
  lT := Clone(T, Ub1, Ub2, Ub3);
  lUb1 := Ub1;
  lUb2 := Ub2;
  lUb3 := Ub3;
  Search := TSearch.Create(lUb3);
End;

Constructor TLineal3DInterpolation.Create(X, Y, Z: TIntVector; T: T3DIntMatrix;
  Ub1, Ub2, Ub3: integer);
Begin
  InttoFloat(X, lX, Ub1);
  InttoFloat(Y, lY, Ub2);
  InttoFloat(Z, lZ, Ub3);
  InttoFloat(T, lT, Ub1, Ub2, Ub3);
  lUb1 := Ub1;
  lUb2 := Ub2;
  lUb3 := Ub3;
  Search := TSearch.Create(lUb3);
End;

Constructor TLineal3DInterpolation.Create(T: T3DIntMatrix;
  Ub1, Ub2, Ub3: integer);
Begin
  SeqVector(lX, Ub1);
  SeqVector(lY, Ub2);
  SeqVector(lZ, Ub3);
  InttoFloat(T, lT, Ub1, Ub2, Ub3);
  lUb1 := Ub1;
  lUb2 := Ub2;
  lUb3 := Ub3;
  Search := TSearch.Create(lUb3);
End;

Destructor TLineal3DInterpolation.Destroy;
Begin
  DelVector(lX);
  DelVector(lY);
  DelVector(lZ);
  DelMatrix(lT);
  Inherited Destroy;
End;

Function TLineal3DInterpolation.Interpolate(X, Y, Z: float): float;
Var
  xl, xh, i, j: integer;
  templin: TMatrix;
Begin
  If Search.Correlated Then
    xl := Search.Hunt(lZ, lUb3, Z)
  Else
    xl := Search.Locate(lZ, lUb3, Z);
  xh := min(lUb3, xl + 1);
  DimMatrix(templin, lUb1, lUb2);
  For i := 1 To lUb1 Do
    For j := 1 To lUb2 Do
      templin[i, j] := LinealInterpolation(lZ[xl], lT[i, j, xl], lZ[xh],
        lT[i, j, xh], Z);
  With TLineal2DInterpolation.Create(lX, lY, templin, lUb1, lUb2) Do
    Try
      Result := Interpolate(X, Y);
    Finally
      Free;
      DelMatrix(templin);
    End;
End;

Function TLineal3DInterpolation.Interpolate3D(Ub1, Ub2, Ub3: integer)
  : T3dMatrix;
Var
  xl, xh, i, j, k: integer;
  interp: float;
  templin: TMatrix;
Begin
  DimMatrix(Result, Ub1, Ub2, Ub3);
  For i := 1 To Ub1 Do
  Begin
    interp := QLinealInterpolation(1, 1, Ub1, lUb1, i);
    If Search.Correlated Then
      xl := Search.Hunt(lX, lUb1, interp)
    Else
      xl := Search.Locate(lX, lUb1, interp);
    xh := min(lUb1, xl + 1);
    DimMatrix(templin, lUb2, lUb3);
    For j := 1 To lUb2 Do
      For k := 1 To lUb3 Do
        templin[i, j] := LinealInterpolation(lX[xl], lT[xl, j, k], lX[xh],
          lT[xh, j, k], interp);
    With TLineal2DInterpolation.Create(lY, lZ, templin, lUb2, lUb3) Do
    Begin
      Result[i] := Interpolate2D(Ub2, Ub3);
      Free;
    End;
    DelMatrix(templin);
  End;
End;

End.
