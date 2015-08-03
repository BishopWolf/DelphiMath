Unit uComplex;

{ Unit uComplex : Complex numbers handling Unit

  Created by : Alex Vergara Gil

  Contains the routines for handling complex numbers

}

Interface

Uses math, uConstants;

{ ------------------------------------------------------------------
  Complex numbers
  ------------------------------------------------------------------ }

{$I Complex.inc}
{ ------------------------------------------------------------------
  Basic operations with Complex
  ------------------------------------------------------------------ }

Function TComplex(Areal, Aimaginary: float;
  wKind: ComplexKind = CKCartesian): Complex;
Function CloneComplex(inComplex: Complex): Complex;
Function IsZero(C: Complex): Boolean; Overload;

Function Abs(C: Complex): float; Overload;
Function SqrAbs(C: Complex): float;
Function Str2Complex(Const Value: String): Complex;
Function Complex2String(C: Complex): String;
Function Conjugate(C: Complex): Complex;
Procedure ToPolar(Var C: Complex; FixedTheeta: Boolean = true);
Procedure ToCartesian(Var C: Complex);

{ ------------------------------------------------------------------
  Advanced operations with Complex
  ------------------------------------------------------------------ }

Function Cos(C: Complex): Complex; Overload;
Function Sin(C: Complex): Complex; Overload;
Function Tan(C: Complex): Complex; Overload;
Function Cot(C: Complex): Complex; Overload;
Function Sec(C: Complex): Complex; Overload;
Function Csc(C: Complex): Complex; Overload;

Function ArcCos(C: Complex): Complex; Overload;
Function ArcSin(C: Complex): Complex; Overload;
Function ArcTan(C: Complex): Complex; Overload;
Function ArcCot(C: Complex): Complex; Overload;
Function ArcSec(C: Complex): Complex; Overload;
Function ArcCsc(C: Complex): Complex; Overload;

Function CosH(C: Complex): Complex; Overload;
Function SinH(C: Complex): Complex; Overload;
Function TanH(C: Complex): Complex; Overload;
Function CotH(C: Complex): Complex; Overload;
Function SecH(C: Complex): Complex; Overload;
Function CscH(C: Complex): Complex; Overload;

Function ArcCosH(C: Complex): Complex; Overload;
Function ArcSinH(C: Complex): Complex; Overload;
Function ArcTanH(C: Complex): Complex; Overload;
Function ArcCotH(C: Complex): Complex; Overload;
Function ArcSecH(C: Complex): Complex; Overload;
Function ArcCscH(C: Complex): Complex; Overload;

Function Ln(C: Complex): Complex; Overload;
Function LogN(C: Complex; N: float): Complex; Overload;
Function EXP(C: Complex): Complex; Overload;
Function CPower(C, Apower: Complex): Complex; Overload;
Function Sqr(C: Complex): Complex; Overload;
Function Sqrt(C: Complex): Complex; Overload;

Var
  ZeroComplex: Complex;

Implementation

Uses rtlConsts, sysutils, sysconst, Windows, uhyper;

{ Overload }

Class Operator Complex.Implicit(a: Complex): float;
Begin
  If a.Imaginary = 0 Then
    result := DefaultVal(FOk, a.Real)
  Else
    result := DefaultVal(FPLoss, a.Real);
End;

Class Operator Complex.Implicit(a: Complex): integer;
Begin
  If a.Imaginary = 0 Then
    result := DefaultIntVal(FOk, trunc(a.Real))
  Else
    result := DefaultIntVal(FPLoss, trunc(a.Real));
End;

Class Operator Complex.Implicit(a: float): Complex;
Begin
  result := TComplex(a, 0.0);
End;

Class Operator Complex.Implicit(a: integer): Complex;
Begin
  result := TComplex(a, 0);
End;

Class Operator Complex.Explicit(a: Complex): float;
Begin
  result := a;
End;

Class Operator Complex.Explicit(a: Complex): integer;
Begin
  result := a;
End;

Class Operator Complex.Explicit(a: float): Complex;
Begin
  result := a;
End;

Class Operator Complex.Explicit(a: integer): Complex;
Begin
  result := a;
End;

Class Operator Complex.Negative(a: Complex): Complex;
Begin
  result.Real := TComplex(-a.Real, -a.Imaginary);
End;

Class Operator Complex.Positive(a: Complex): Complex;
Begin
  result := TComplex(a.Real, a.Imaginary);
End;

Class Operator Complex.Inc(a: Complex): Complex;
Begin
  result := TComplex(a.Real + 1, a.Imaginary);
End;

Class Operator Complex.Dec(a: Complex): Complex;
Begin
  result := TComplex(a.Real - 1, a.Imaginary);
End;

Class Operator Complex.LogicalNot(a: Complex): Boolean;
Begin
  result := (a.Real <> 0) And (a.Imaginary <> 0);
End;

Class Operator Complex.Equal(a: Complex; b: Complex): Boolean;
  Function Compara(C, b: Complex): Boolean;
  Begin
    result := math.IsZero(C.Real - b.Real) And
      math.IsZero(C.Imaginary - b.Imaginary);
  End;

Begin
  result := Compara(a, b);
End;

Class Operator Complex.NotEqual(a: Complex; b: Complex): Boolean;
Begin
  result := Not(a = b); // (a.Real<>b.Real)and(a.Imaginary<>b.Imaginary);
End;

Class Operator Complex.GreaterThan(a: Complex; b: Complex): Boolean;
Begin
  result := (Abs(a) > Abs(b)); // (a.Real>b.Real)and(a.Imaginary>b.Imaginary);
End;

Class Operator Complex.GreaterThanOrEqual(a: Complex; b: Complex): Boolean;
Begin
  result := (Abs(a) >= Abs(b));
  // (a.Real>=b.Real)and(a.Imaginary>=b.Imaginary);
End;

Class Operator Complex.LessThan(a: Complex; b: Complex): Boolean;
Begin
  result := (Abs(a) < Abs(b)); // (a.Real<b.Real)and(a.Imaginary<b.Imaginary);
End;

Class Operator Complex.LessThanOrEqual(a: Complex; b: Complex): Boolean;
Begin
  result := (Abs(a) <= Abs(b));
  // (a.Real<=b.Real)and(a.Imaginary<=b.Imaginary);
End;

Function SumaComplex(Const Complex1, Complex2: Complex): Complex;
Begin
  result.Real := Complex1.Real + Complex2.Real;
  result.Imaginary := Complex1.Imaginary + Complex2.Imaginary;
End;

Function RestaComplex(Const Complex1, Complex2: Complex): Complex;
Begin
  result.Real := Complex1.Real - Complex2.Real;
  result.Imaginary := Complex1.Imaginary - Complex2.Imaginary;
End;

Function MultiplyComplex(Const Complex1, Complex2: Complex): Complex;
Var
  ac, bd: float;
Begin
  ac := Complex1.Real * Complex2.Real;
  bd := Complex1.Imaginary * Complex2.Imaginary;
  result.Real := ac - bd;
  result.Imaginary := (Complex1.Real + Complex1.Imaginary) *
    (Complex2.Real + Complex2.Imaginary) - ac - bd;
End;

Function DivideComplex(Const Complex1, Complex2: Complex): Complex;
Var
  num1, num2, den, temp: float;
Begin
  If Abs(Complex2.Real) >= Abs(Complex2.Imaginary) Then
  Begin
    temp := (Complex2.Imaginary / Complex2.Real);
    num1 := Complex1.Real + (Complex1.Imaginary * temp);
    num2 := Complex1.Imaginary - (Complex1.Real * temp);
    den := Complex2.Real + (Complex2.Imaginary * temp);
  End
  Else
  Begin
    temp := (Complex2.Real / Complex2.Imaginary);
    num1 := (Complex1.Real * temp) + Complex1.Imaginary;
    num2 := (Complex1.Imaginary * temp) - Complex1.Real;
    den := (Complex2.Real * temp) + Complex2.Imaginary;
  End;
  result.Real := num1 / den;
  result.Imaginary := num2 / den;
End;

Class Operator Complex.Add(a: Complex; b: Complex): Complex;
Begin
  result := SumaComplex(a, b);
End;

Class Operator Complex.Subtract(a: Complex; b: Complex): Complex;
Begin
  result := RestaComplex(a, b);
End;

Class Operator Complex.Multiply(a: Complex; b: Complex): Complex;
Begin
  result := MultiplyComplex(a, b);
End;

Class Operator Complex.Divide(a: Complex; b: Complex): Complex;
Begin
  result := DivideComplex(a, b);
End;

Class Operator Complex.IntDivide(a: Complex; b: integer): Complex;
Begin
  If (a.Real = trunc(a.Real)) And (a.Imaginary = trunc(a.Imaginary)) Then
  Begin
    result := TComplex(trunc(a.Real) Div b, trunc(a.Imaginary) Div b);
    SetErrCode(FOk);
  End
  Else
  Begin
    result := a;
    SetErrCode(FPLoss);
  End;
End;

Class Operator Complex.Modulus(a: Complex; b: integer): Complex;
Begin
  If (a.Real = trunc(a.Real)) And (a.Imaginary = trunc(a.Imaginary)) Then
  Begin
    result := TComplex(trunc(a.Real) Mod b, trunc(a.Imaginary) Mod b);
    SetErrCode(FOk);
  End
  Else
  Begin
    result := a;
    SetErrCode(FPLoss);
  End;
End;

Class Operator Complex.LogicalAnd(a: Complex; b: Complex): Boolean;
Begin
  result := (Not(Not a)) And (Not(Not b));
End;

Class Operator Complex.LogicalOr(a: Complex; b: Complex): Boolean;
Begin
  result := (Not(Not a)) Or (Not(Not b));
End;

Class Operator Complex.LogicalXor(a: Complex; b: Complex): Boolean;
Begin
  result := (Not(Not a)) Xor (Not(Not b));
End;

{ Operations }

Function TComplex(Areal, Aimaginary: float; wKind: ComplexKind): Complex;
Begin
  result.Real := Areal;
  result.Imaginary := Aimaginary;
  result.Kind := wKind;
End;

Procedure ToPolar(Var C: Complex; FixedTheeta: Boolean);
Var
  x: float;
Begin
  If Not(C.Kind = CKPolar) Then
  Begin
    x := C.Real;
    C.Real := Abs(C);
    C.Imaginary := ArcTan2(C.Imaginary, x);
    If FixedTheeta Then
    Begin
      While C.Imaginary > Pi Do
        C.Imaginary := C.Imaginary - 2.0 * Pi;
      While C.Imaginary <= -Pi Do
        C.Imaginary := C.Imaginary + 2.0 * Pi;
    End;
    C.Kind := CKPolar;
    SetErrCode(FOk);
  End;
End;

Function Conjugate(C: Complex): Complex;
Begin
  result := TComplex(C.Real, -C.Imaginary);
End;

Procedure ToCartesian(Var C: Complex);
Var
  x: float;
Begin
  If (C.Kind = CKPolar) Then
  Begin
    x := C.Real;
    C.Real := C.Real * system.Cos(C.Imaginary);
    C.Imaginary := x * system.Sin(C.Imaginary);
    SetErrCode(FOk);
  End;
End;

Function CloneComplex(inComplex: Complex): Complex;
Begin
  result.Real := inComplex.Real;
  result.Imaginary := inComplex.Imaginary;
  result.Kind := inComplex.Kind;
End;

Function Sqr(C: Complex): Complex;
Begin
  result := TComplex((C.Real * C.Imaginary) - (C.Imaginary * C.Imaginary),
    (C.Real * C.Imaginary) + (C.Imaginary * C.Real));
End;

Function Sqrt(C: Complex): Complex;
Var
  w, temp: float;
Begin
  If IsZero(C) Then
    w := 0
  Else
  Begin
    If Abs(C.Real) >= Abs(C.Imaginary) Then
    Begin
      temp := C.Imaginary / C.Real;
      w := Sqrt(Abs(C.Real)) * Sqrt((1 + Sqrt(1 + Sqr(temp))) / 2);
    End
    Else
    Begin
      temp := C.Real / C.Imaginary;
      w := Sqrt(Abs(C.Imaginary)) * Sqrt((Abs(temp) + Sqrt(1 + Sqr(temp))) / 2);
    End;
  End;
  If w = 0 Then
    result := TComplex(0, 0)
  Else If C.Real >= 0 Then
    result := TComplex(w, C.Imaginary / (2 * w))
  Else If C.Imaginary >= 0 Then
    result := TComplex(Abs(C.Imaginary) / (2 * w), w)
  Else
    result := TComplex(Abs(C.Imaginary) / (2 * w), -w);
End;

Function Multiply(Const Complex1: Complex; factor: float): Complex;
Begin
  result.Real := Complex1.Real * factor;
  result.Imaginary := Complex1.Imaginary * factor;
End;

Function Divide(Const Complex1: Complex; divisor: float): Complex;
Begin
  If math.IsZero(divisor) Then
    Raise EZeroDivide.Create(SDivByZero);
  result.Real := Complex1.Real / divisor;
  result.Imaginary := Complex1.Imaginary / divisor;
End;

Function Abs(C: Complex): float;
Begin
  If C = 0 Then
  Begin
    result := 0;
    exit;
  End;
  If system.Abs(C.Real) >= system.Abs(C.Imaginary) Then
    result := system.Abs(C.Real) *
      system.sqrt(1 + system.sqr(C.Imaginary / C.Real))
  Else
    result := system.Abs(C.Imaginary) *
      system.sqrt(1 + system.sqr(C.Real / C.Imaginary));
End;

Function IsZero(C: Complex): Boolean;
Begin
  result := math.IsZero(C.Real, MachEp) And math.IsZero(C.Imaginary, MachEp);
End;

Function Str2Complex(Const Value: String): Complex;
Var
  LPart, LLeftover: String;
  LReal, LImaginary: Double;
  LSign: integer;

  Function ParseNumber(Const AText: String; Out ARest: String;
    Out ANumber: Double): Boolean;
  Var
    LAt: integer;
    LFirstPart: String;
  Begin
    result := true;
    Val(AText, ANumber, LAt);
    If LAt <> 0 Then
    Begin
      ARest := Copy(AText, LAt, MaxInt);
      LFirstPart := Copy(AText, 1, LAt - 1);
      Val(LFirstPart, ANumber, LAt);
      If LAt <> 0 Then
        result := False;
    End;
  End;

  Function ParseWhiteSpace(Const AText: String; Out ARest: String): Boolean;
  Var
    LAt: integer;
  Begin
    LAt := 1;
    If AText <> '' Then
    Begin
      While AText[LAt] = ' ' Do
        Inc(LAt);
      ARest := Copy(AText, LAt, MaxInt);
    End;
    result := ARest <> '';
  End;

  Procedure ParseError(Const AMessage: String);
  Begin
    Raise EConvertError.CreateFmt(SCmplxErrorSuffix,
      [AMessage, Copy(Value, 1, Length(Value) - Length(LLeftover)),
      Copy(Value, Length(Value) - Length(LLeftover) + 1, MaxInt)]);
  End;

  Procedure ParseErrorEOS;
  Begin
    Raise EConvertError.CreateFmt(SCmplxUnexpectedEOS, [Value]);
  End;

Begin
  // where to start?
  LLeftover := Value;

  // first get the real portion
  If Not ParseNumber(LLeftover, LPart, LReal) Then
    ParseError(SCmplxCouldNotParseReal);

  // is that it?
  If Not ParseWhiteSpace(LPart, LLeftover) Then
    result.Real := LReal

    // if there is more then parse the complex part
  Else
  Begin

    // look for the concat symbol
    LSign := 1;
    If LLeftover[1] = '-' Then
      LSign := -1
    Else If LLeftover[1] <> '+' Then
      ParseError(SCmplxCouldNotParsePlus);
    LPart := Copy(LLeftover, 2, MaxInt);

    // skip any whitespace
    ParseWhiteSpace(LPart, LLeftover);

    // symbol before?
    If ComplexNumberSymbolBeforeImaginary Then
    Begin
      If Not AnsiSameText(Copy(LLeftover, 1, Length(ComplexNumberSymbol)),
        ComplexNumberSymbol) Then
        ParseError(Format(SCmplxCouldNotParseSymbol, [ComplexNumberSymbol]));
      LPart := Copy(LLeftover, Length(ComplexNumberSymbol) + 1, MaxInt);

      // skip any whitespace
      ParseWhiteSpace(LPart, LLeftover);
    End;

    // imaginary part
    If Not ParseNumber(LLeftover, LPart, LImaginary) Then
      ParseError(SCmplxCouldNotParseImaginary);

    // correct for sign
    LImaginary := LImaginary * LSign;

    // symbol after?
    If Not ComplexNumberSymbolBeforeImaginary Then
    Begin
      // skip any whitespace
      ParseWhiteSpace(LPart, LLeftover);

      // make sure there is symbol!
      If Not AnsiSameText(Copy(LLeftover, 1, Length(ComplexNumberSymbol)),
        ComplexNumberSymbol) Then
        ParseError(Format(SCmplxCouldNotParseSymbol, [ComplexNumberSymbol]));
      LPart := Copy(LLeftover, Length(ComplexNumberSymbol) + 1, MaxInt);
    End;

    // make sure the rest of the string is whitespaces
    ParseWhiteSpace(LPart, LLeftover);
    If LLeftover <> '' Then
      ParseError(SCmplxUnexpectedChars);

    // make it then
    result.Real := LReal;
    result.Imaginary := LImaginary;
  End;
End;

Function Complex2String(C: Complex): String;
Const
  cFormats: Array [Boolean] Of String = ('%2:g %1:s %3:g%0:s',
    '%2:g %1:s %0:s%3:g'); { do not localize }
  cSign: Array [Boolean] Of String = ('-', '+');
Begin
  result := Format(cFormats[ComplexNumberSymbolBeforeImaginary],
    [ComplexNumberSymbol, cSign[C.Imaginary >= 0], C.Real, Abs(C.Imaginary)]);
End;

Function Cos(C: Complex): Complex;
Begin
  result.Real := system.Cos(C.Real) * uhyper.CosH(C.Imaginary);
  result.Imaginary := -system.Sin(C.Real) * uhyper.SinH(C.Imaginary);
End;

Function Sin(C: Complex): Complex;
Begin
  result.Real := system.Sin(C.Real) * uhyper.CosH(C.Imaginary);
  result.Imaginary := system.Cos(C.Real) * uhyper.SinH(C.Imaginary);
End;

Function Tan(C: Complex): Complex;
Var
  LDenominator: float;
Begin
  If (C = Pi / 2) Then
  Begin
    result := Infinity;
  End
  Else
  Begin
    LDenominator := Cos(2.0 * C.Real) + uhyper.CosH(2.0 * C.Imaginary);
    If math.IsZero(LDenominator) Then
      Raise EZeroDivide.Create(SDivByZero);
    result.Real := system.Sin(2.0 * C.Real) / LDenominator;
    result.Imaginary := uhyper.SinH(2.0 * C.Imaginary) / LDenominator;
  End;
End;

Function Cot(C: Complex): Complex;
Begin
  If C = 0 Then
  Begin
    result := Infinity;
  End
  Else
  Begin
    result := Cos(C) / Sin(C);
  End;
End;

Function Csc(C: Complex): Complex;
Begin
  If IsZero(C) Then
    result := Infinity
  Else
    result := 1 / Sin(C);
End;

Function Sec(C: Complex): Complex;
Begin
  If (C = Pi / 2) Then
    result := Infinity
  Else
    result := 1 / Cos(C);
End;

Function DoTimesImaginary(Const AValue: float; C: Complex): Complex;
Begin
  result := TComplex(-AValue * C.Imaginary, AValue * C.Real);
End;

Function DoTimesReal(Const AValue: float; C: Complex): Complex;
Begin
  result := TComplex(AValue * C.Real, AValue * C.Imaginary);
End;

Function ArcCsc(C: Complex): Complex;
Begin
  If C = 0 Then
    result := Infinity
  Else
  Begin
    result := ArcSin(1 / C);
  End;
End;

Function ArcCos(C: Complex): Complex;
Var
  LTemp: Complex;
Begin
  LTemp := Sqrt(1 - Sqr(C));
  LTemp := DoTimesImaginary(1, Ln(DoTimesImaginary(1, C) + LTemp));
  result := LTemp + Pi / 2;
End;

Function ArcCot(C: Complex): Complex;
Begin
  result := ArcTan(1 / C);
End;

Function ArcSec(C: Complex): Complex;
Begin
  If C = 0 Then
    result := Infinity
  Else
  Begin
    result := ArcCos(1 / C);
  End;
End;

Function ArcSin(C: Complex): Complex;
Var
  temp: Complex;
Begin
  temp := Sqrt(1 - Sqr(C));
  result := DoTimesImaginary(-1, Ln(temp + DoTimesImaginary(1, C)));
End;

Function ArcTan(C: Complex): Complex;
Var
  LTemp1, LTemp2: Complex;
Begin
  If C = TComplex(0, 1) Then
    result := TComplex(0, Infinity)
  Else If C = TComplex(0, -1) Then
    result := TComplex(0, NegInfinity)
  Else
  Begin
    LTemp2 := DoTimesImaginary(1, C);
    LTemp1 := Ln(1 - LTemp2);
    LTemp2 := Ln(1 + LTemp2);
    LTemp1 := LTemp1 - LTemp2;
    result := TComplex(0, 1 / 2) * LTemp1;
  End;
End;

Function Ln(C: Complex): Complex;
Begin
  If C = 0 Then
    result := NegInfinity
  Else
  Begin
    If Not(C.Kind = CKPolar) Then
      ToPolar(C);
    result := TComplex(system.Ln(C.Real), C.Imaginary); // ln c = ln ρ + i ϑ
  End;
End;

Function EXP(C: Complex): Complex;
Begin
  result := TComplex(system.EXP(C.Real) * system.Cos(C.Imaginary),
    system.EXP(C.Real) * system.Sin(C.Imaginary));
End;

Function CPower(C, Apower: Complex): Complex;
Begin
  If C = 0 Then
    If (Apower = 0) Then
      result := 1
    Else
      result := 0
  Else
  Begin
    result := EXP(Apower * Ln(C));
  End;
End;

Function SqrAbs(C: Complex): float;
Begin
  result := system.sqr(Abs(C)) // c.Real*c.Real+c.Imaginary*c.Imaginary;
End;

Function LogN(C: Complex; N: float): Complex;
Var
  LTemp: Complex;
Begin
  If (C = 0) And (N > 0) And (N <> 1) Then
    result := NegInfinity
  Else
  Begin
    LTemp := system.Ln(N);
    If Not(C.Kind = CKPolar) Then
      ToPolar(C);
    result := TComplex(system.Ln(C.Real), C.Imaginary);
    result := result / LTemp;
  End;
End;

Function ArcCscH(C: Complex): Complex;
Begin
  If (C = 0) Then
    result := Infinity
  Else
  Begin
    result := ArcSinH(1 / C);
  End;
End;

Function ArcCosH(C: Complex): Complex;
Begin
  result := Ln(C + (Sqrt(C + 1) * Sqrt(C - 1)));
End;

Function ArcCotH(C: Complex): Complex;
Begin
  If C = 1 Then
    result := Infinity
  Else If C = -1 Then
    result := NegInfinity
  Else
  Begin
    result := ArcTan(1 / C);
  End;
End;

Function ArcSecH(C: Complex): Complex;
Begin
  If C = 0 Then
    result := Infinity
  Else
  Begin
    result := ArcCosH(1 / C);
  End;
End;

Function ArcSinH(C: Complex): Complex;
Begin
  result := DoTimesImaginary(-1.0, ArcSin(DoTimesImaginary(1.0, C)));
End;

Function ArcTanH(C: Complex): Complex;
Begin
  If C = 1 Then
    result := Infinity
  Else If C = -1 Then
    result := NegInfinity
  Else
  Begin
    result := DoTimesImaginary(-1.0, ArcTan(DoTimesImaginary(1.0, C)));
  End;
End;

Function CscH(C: Complex): Complex;
Begin
  If C = 0 Then
    result := 0
  Else
  Begin
    result := ArcSinH(1 / C);
  End;
End;

Function CosH(C: Complex): Complex;
Begin
  result := TComplex(uhyper.CosH(C.Real) * system.Cos(C.Imaginary),
    uhyper.SinH(C.Real) * system.Sin(C.Imaginary));
End;

Function CotH(C: Complex): Complex;
Begin
  If C = 0 Then
    result := Infinity
  Else
  Begin
    result := 1 / TanH(C);
  End;
End;

Function SecH(C: Complex): Complex;
Begin
  result := 1 / CosH(C);
End;

Function SinH(C: Complex): Complex;
Begin
  result := TComplex(uhyper.SinH(C.Real) * system.Cos(C.Imaginary),
    uhyper.CosH(C.Real) * system.Sin(C.Imaginary));
End;

Function TanH(C: Complex): Complex;
Begin
  If C = 0 Then
    result := 0
  Else
  Begin
    result := SinH(C) / CosH(C);
  End;
End;

initialization
  ZeroComplex:= TComplex(0,0);

End.
