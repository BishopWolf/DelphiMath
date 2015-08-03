type
 ComplexKind = (CKCartesian, CKPolar);
 Complex = record
  Real, Imaginary : Float;  // If kind = CKPolar then
  Kind : ComplexKind;       // real = radius & imaginary = theeta
  {operator overloading}
  class operator Implicit(a:Complex):float;        //implicit typecast
  class operator Implicit(a:Complex):integer;
  class operator Implicit(a:float):Complex;
  class operator Implicit(a:integer):Complex;
  class operator Explicit(a:Complex):float;        //explicit typecast   b:=a;
  class operator Explicit(a:Complex):integer;
  class operator Explicit(a:float):Complex;
  class operator Explicit(a:integer):Complex;
  class operator Negative(a:Complex):Complex;      //-          b:=-a;
  class operator Positive(a:Complex):Complex;      //+          b:=+a;
  class operator Inc(a:Complex):Complex;           //inc
  class operator Dec(a:Complex):Complex;           //dec
  class operator LogicalNot(a:Complex):Boolean;    //not
  // class operator BitwiseNot(a:Complex):Complex;    //not
  // class operator Trunc(a:Complex):Complex;
  // class operator Round(a:Complex):Complex;
  class operator Equal(a: Complex; b: Complex):Boolean;                 // =
  class operator NotEqual(a: Complex; b: Complex):Boolean;              // <>
  class operator GreaterThan(a: Complex; b: Complex):Boolean;           // >
  class operator GreaterThanOrEqual(a: Complex; b: Complex):Boolean;    // >=
  class operator LessThan(a: Complex; b: Complex):Boolean;              // <
  class operator LessThanOrEqual(a: Complex; b: Complex):Boolean;       // <=
  class operator Add(a: Complex; b: Complex): Complex;         // +       c:=a+b;
  class operator Subtract(a: Complex; b: Complex): Complex;    // -       c:=a-b;
  class operator Multiply(a: Complex; b: Complex): Complex;    // *       c:=a*b;
  class operator Divide(a: Complex; b: Complex): Complex;      // /       c:=a/b;
  class operator IntDivide(a: Complex; b: integer): Complex;   // div     c:=a div b;
  class operator Modulus(a: Complex; b: integer): Complex;     // mod     c:=a mod b;
  //class operator LeftShift(a: Complex; b: integer): Complex;   // shl
  //class operator RightShift(a: Complex; b: integer): Complex;  // shr
  class operator LogicalAnd(a: Complex; b: Complex): Boolean;  // and
  class operator LogicalOr(a: Complex; b: Complex): Boolean;   // or
  class operator LogicalXor(a: Complex; b: Complex): Boolean;  // xor
  //class operator BitwiseAnd(a: Complex; b: Complex): Complex;  // and
  //class operator BitwiseOr(a: Complex; b: Complex): Complex;   // or
  //class operator BitwiseXor(a: Complex; b: Complex): Complex;  // xor
end;
var
  ComplexNumberSymbol: string = 'i';
  ComplexNumberSymbolBeforeImaginary: Boolean = False;
  ComplexNumberDefuzzAtZero: Boolean = True;
