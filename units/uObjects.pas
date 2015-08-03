unit uObjects;

interface

uses utypes, uComplex, umachar, uconstants, VarCmplx;

type
  TVOKind = (VOFloat, VOinteger, VOWord, VOComplex, VOBoolean, VOString);

  TOVKind = record
    FData: TVector;
    IData: TIntVector;
    WData: TWordVector;
    CData: TCompVector;
    BData: TBoolVector;
    SData: TStrVector;
  end;

  TOVector = record
  private
    Data: TOVKind;
    FKind: TVOKind;
    FSize: Integer;
    procedure SetKind(const Value: TVOKind);
    procedure SetSize(const Value: Integer);
    function GetElemento(n: Integer): Variant;
    procedure SetElemento(n: Integer; const Value: Variant);
  public
    property Kind: TVOKind read FKind write SetKind;
    property Size: Integer read FSize write SetSize;
    constructor Create(Ub: Integer; wKind: TVOKind = VOFloat);
    property Elemento[n: Integer]: Variant read GetElemento
      write SetElemento; default;
    procedure destroy;
    { operator overloading }
    class operator Implicit(a: TOVector): TVector; // implicit typecast
    class operator Implicit(a: TVector): TOVector;
    class operator Implicit(a: TOVector): TIntVector;
    class operator Implicit(a: TIntVector): TOVector;
    class operator Implicit(a: TOVector): TWordVector;
    class operator Implicit(a: TWordVector): TOVector;
    class operator Implicit(a: TOVector): TCompVector;
    class operator Implicit(a: TCompVector): TOVector;
    class operator Implicit(a: TOVector): TStrVector;
    class operator Implicit(a: TStrVector): TOVector;
    class operator Explicit(a: TOVector): TVector; // explicit typecast
    class operator Explicit(a: TVector): TOVector;
    class operator Explicit(a: TOVector): TIntVector;
    class operator Explicit(a: TIntVector): TOVector;
    class operator Explicit(a: TOVector): TWordVector;
    class operator Explicit(a: TWordVector): TOVector;
    class operator Explicit(a: TOVector): TCompVector;
    class operator Explicit(a: TCompVector): TOVector;
    class operator Explicit(a: TOVector): TStrVector;
    class operator Explicit(a: TStrVector): TOVector;
    class operator Negative(a: TOVector): TOVector; // -          b:=-a;
    class operator Positive(a: TOVector): TOVector; // +          b:=+a;
    class operator Inc(a: TOVector): TOVector; // inc
    class operator Dec(a: TOVector): TOVector; // dec
    // class operator LogicalNot(a:TOVector):Boolean;    //not
    // class operator BitwiseNot(a:TOVector):TOVector;    //not
    class operator Trunc(a: TOVector): TOVector;
    class operator Round(a: TOVector): TOVector;
    class operator Equal(a: TOVector; b: TOVector): Boolean; // =
    class operator NotEqual(a: TOVector; b: TOVector): Boolean; // <>
    // class operator GreaterThan(a: TOVector; b: TOVector):Boolean;           // >
    // class operator GreaterThanOrEqual(a: TOVector; b: TOVector):Boolean;    // >=
    // class operator LessThan(a: TOVector; b: TOVector):Boolean;              // <
    // class operator LessThanOrEqual(a: TOVector; b: TOVector):Boolean;       // <=
    class operator Add(a: TOVector; b: TOVector): TOVector; // +       c:=a+b;
    class operator Subtract(a: TOVector; b: TOVector): TOVector;
    // -       c:=a-b;
    class operator Multiply(a: TOVector; b: TOVector): TOVector;
    // *       c:=a*b;
    class operator Divide(a: TOVector; b: TOVector): TOVector;
    // /       c:=a/b;
    class operator IntDivide(a: TOVector; b: TOVector): TOVector;
    // div     c:=a div b;
    class operator Modulus(a: TOVector; b: TOVector): TOVector;
    // mod     c:=a mod b;
    class operator LeftShift(a: TOVector; b: TOVector): TOVector; // shl
    class operator RightShift(a: TOVector; b: TOVector): TOVector; // shr
    // class operator LogicalAnd(a: TOVector; b: TOVector): Boolean;  // and
    // class operator LogicalOr(a: TOVector; b: TOVector): Boolean;   // or
    // class operator LogicalXor(a: TOVector; b: TOVector): Boolean;  // xor
    class operator BitwiseAnd(a: TOVector; b: TOVector): TOVector; // and
    class operator BitwiseOr(a: TOVector; b: TOVector): TOVector; // or
    class operator BitwiseXor(a: TOVector; b: TOVector): TOVector; // xor
  end;

  TOMultiplicationKind = (TOMKItems, TOMKMatrix);

  TOMKind = record
    FData: TMatrix;
    IData: TIntMatrix;
    WData: TWordMatrix;
    CData: TCompMatrix;
    BData: TBoolMatrix;
    SData: TStrMatrix;
  end;

  TOMatrix = record
  private
    Data: TOMKind;
    FKind: TVOKind;
    FSizeX: Integer;
    FSizeY: Integer;
    FMultiplicationKind: TOMultiplicationKind;
    procedure SetKind(const Value: TVOKind);
    procedure SetSizeX(const Value: Integer);
    procedure SetMultiplicationKind(const Value: TOMultiplicationKind);
    procedure SetSizeY(const Value: Integer);
    function GetElemento(m, n: Integer): Variant;
    procedure SetElemento(m, n: Integer; const Value: Variant);
  public
    property Kind: TVOKind read FKind write SetKind;
    property SizeX: Integer read FSizeX write SetSizeX;
    property SizeY: Integer read FSizeY write SetSizeY;
    property Elemento[m, n: Integer]: Variant read GetElemento
      write SetElemento; default;
    property MultiplicationKind: TOMultiplicationKind read FMultiplicationKind
      write SetMultiplicationKind;
    constructor Create(Ub1, Ub2: Integer; wKind: TVOKind = VOFloat); overload;
    constructor Create(a: TMatrix); overload;
    constructor Create(a: TIntMatrix); overload;
    constructor Create(a: TCompMatrix); overload;
    constructor Create(a: TStrMatrix); overload;
    constructor Create(a: TWordMatrix); overload;
    constructor Create(a: TBoolMatrix); overload;
    procedure destroy;
    { operator overloading }
    class operator Implicit(a: TOMatrix): TMatrix;
    class operator Implicit(a: TMatrix): TOMatrix;
    class operator Implicit(a: TOMatrix): TCompMatrix;
    class operator Implicit(a: TCompMatrix): TOMatrix;
    class operator Negative(a: TOMatrix): TOMatrix; // -          b:=-a;
    class operator Positive(a: TOMatrix): TOMatrix; // +          b:=+a;
    class operator Inc(a: TOMatrix): TOMatrix; // inc
    class operator Dec(a: TOMatrix): TOMatrix; // dec
    // class operator LogicalNot(a:TOVector):Boolean;    //not
    // class operator BitwiseNot(a:TOVector):TOVector;    //not
    class operator Trunc(a: TOMatrix): TOMatrix;
    class operator Round(a: TOMatrix): TOMatrix;
    class operator Equal(a: TOMatrix; b: TOMatrix): Boolean; // =
    class operator NotEqual(a: TOMatrix; b: TOMatrix): Boolean; // <>
    // class operator GreaterThan(a: TOVector; b: TOVector):Boolean;           // >
    // class operator GreaterThanOrEqual(a: TOVector; b: TOVector):Boolean;    // >=
    // class operator LessThan(a: TOVector; b: TOVector):Boolean;              // <
    // class operator LessThanOrEqual(a: TOVector; b: TOVector):Boolean;       // <=
    class operator Add(a: TOMatrix; b: TOMatrix): TOMatrix; // +       c:=a+b;
    class operator Subtract(a: TOMatrix; b: TOMatrix): TOMatrix;
    // -       c:=a-b;
    class operator Multiply(a: TOMatrix; b: TOMatrix): TOMatrix;
    // *       c:=a*b;
    class operator Divide(a: TOMatrix; b: TOMatrix): TOMatrix;
    // /       c:=a/b;
    class operator IntDivide(a: TOMatrix; b: TOMatrix): TOMatrix;
    // div     c:=a div b;
    class operator Modulus(a: TOMatrix; b: TOMatrix): TOMatrix;
    // mod     c:=a mod b;
    function Inversa: TOMatrix;
  end;

  TO3DMKind = record
    FData: T3DMatrix;
    IData: T3DIntMatrix;
    WData: T3DWordMatrix;
    CData: T3DCompMatrix;
    BData: T3DBoolMatrix;
    SData: T3DStrMatrix;
  end;

  TO3DMatrix = record
  private
    Data: TO3DMKind;
    FKind: TVOKind;
    FSizeX: Integer;
    FSizeY: Integer;
    FSizeZ: Integer;
    FMultiplicationKind: TOMultiplicationKind;
    procedure SetKind(const Value: TVOKind);
    procedure SetSizeX(const Value: Integer);
    procedure SetSizeY(const Value: Integer);
    function GetElemento(m, n, o: Integer): Variant;
    procedure SetElemento(m, n, o: Integer; const Value: Variant);
    procedure SetSizeZ(const Value: Integer);
  public
    property Kind: TVOKind read FKind write SetKind;
    property SizeX: Integer read FSizeX write SetSizeX;
    property SizeY: Integer read FSizeY write SetSizeY;
    property SizeZ: Integer read FSizeZ write SetSizeZ;
    property Elemento[m, n, o: Integer]: Variant read GetElemento
      write SetElemento; default;
    constructor Create(Ub1, Ub2, Ub3: Integer;
      wKind: TVOKind = VOFloat); overload;
    constructor Create(a: T3DMatrix); overload;
    constructor Create(a: T3DIntMatrix); overload;
    constructor Create(a: T3DCompMatrix); overload;
    constructor Create(a: T3DStrMatrix); overload;
    constructor Create(a: T3DWordMatrix); overload;
    constructor Create(a: T3DBoolMatrix); overload;
    procedure destroy;
    { operator overloading }
    class operator Implicit(a: TO3DMatrix): T3DMatrix;
    class operator Implicit(a: T3DMatrix): TO3DMatrix;
    class operator Implicit(a: TO3DMatrix): T3DCompMatrix;
    class operator Implicit(a: T3DCompMatrix): TO3DMatrix;
    class operator Negative(a: TO3DMatrix): TO3DMatrix; // -          b:=-a;
    class operator Positive(a: TO3DMatrix): TO3DMatrix; // +          b:=+a;
    class operator Inc(a: TO3DMatrix): TO3DMatrix; // inc
    class operator Dec(a: TO3DMatrix): TO3DMatrix; // dec
    // class operator LogicalNot(a:TOVector):Boolean;    //not
    // class operator BitwiseNot(a:TOVector):TOVector;    //not
    class operator Trunc(a: TO3DMatrix): TO3DMatrix;
    class operator Round(a: TO3DMatrix): TO3DMatrix;
    class operator Equal(a: TO3DMatrix; b: TO3DMatrix): Boolean; // =
    class operator NotEqual(a: TO3DMatrix; b: TO3DMatrix): Boolean; // <>
    // class operator GreaterThan(a: TOVector; b: TOVector):Boolean;           // >
    // class operator GreaterThanOrEqual(a: TOVector; b: TOVector):Boolean;    // >=
    // class operator LessThan(a: TOVector; b: TOVector):Boolean;              // <
    // class operator LessThanOrEqual(a: TOVector; b: TOVector):Boolean;       // <=
    class operator Add(a: TO3DMatrix; b: TO3DMatrix): TO3DMatrix;
    // +       c:=a+b;
    class operator Subtract(a: TO3DMatrix; b: TO3DMatrix): TO3DMatrix;
    // -       c:=a-b;
  end;

implementation

uses uoperations, Dialogs, ustrings, uLU, variants;

function DameKind(Kind1, Kind2: TVOKind): TVOKind;
begin
  case Kind1 of
    VOFloat:
      case Kind2 of
        VOComplex:
          result := VOComplex;
        VOBoolean:
          result := VOBoolean;
        VOString:
          result := VOString;
      else
        result := VOFloat;
      end;
    VOinteger:
      case Kind2 of
        VOFloat:
          result := VOFloat;
        VOComplex:
          result := VOComplex;
        VOBoolean:
          result := VOBoolean;
        VOString:
          result := VOString;
      else
        result := VOinteger;
      end;
    VOWord:
      case Kind2 of
        VOinteger:
          result := VOinteger;
        VOFloat:
          result := VOFloat;
        VOComplex:
          result := VOComplex;
        VOBoolean:
          result := VOBoolean;
        VOString:
          result := VOString;
      else
        result := VOWord;
      end;
    VOComplex:
      case Kind2 of
        VOBoolean:
          result := VOBoolean;
        VOString:
          result := VOString;
      else
        result := VOComplex;
      end;
    VOBoolean:
      case Kind2 of
        VOString:
          result := VOString;
      else
        result := VOBoolean;
      end;
  else
    result := VOString;
  end;
end;

{ TOVector }

class operator TOVector.Add(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOVector.Create(a.Size, lKind);
    case a.Kind of
      VOFloat, VOinteger, VOWord, VOComplex:
        begin
          case b.Kind of
            VOFloat, VOinteger, VOWord, VOComplex:
              begin
                for i := 1 to a.Size do
                  result[i] := a[i] + b[i];
              end;
          else
            goto error;
          end;
        end;
      VOBoolean:
        begin
          case b.Kind of
            VOBoolean:
              begin
                result.Data.BData := FSuma(a.Data.BData, b.Data.BData, a.Size);
              end;
          else
            goto error;
          end;
        end;
      VOString:
        begin
          case b.Kind of
            VOString:
              begin
                result.Data.SData := FSuma(a.Data.SData, b.Data.SData, a.Size);
              end;
          else
            goto error;
          end;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.BitwiseAnd(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOVector.Create(a.Size, lKind);
    case a.Kind of
      VOinteger, VOWord:
        case b.Kind of
          VOinteger, VOWord:
            begin
              for i := 1 to a.Size do
                result[i] := a[i] and b[i];
            end;
        else
          goto error;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.BitwiseOr(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOVector.Create(a.Size, lKind);
    case a.Kind of
      VOinteger, VOWord:
        case b.Kind of
          VOinteger, VOWord:
            begin
              for i := 1 to a.Size do
                result[i] := a[i] or b[i];
            end;
        else
          goto error;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.BitwiseXor(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOVector.Create(a.Size, lKind);
    case a.Kind of
      VOinteger, VOWord:
        case b.Kind of
          VOinteger, VOWord:
            begin
              for i := 1 to a.Size do
                result[i] := a[i] xor b[i];
            end;
        else
          goto error;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

constructor TOVector.Create(Ub: Integer; wKind: TVOKind);
begin
  Size := Ub;
  Kind := wKind;
  case Kind of
    VOFloat:
      DimVector(Data.FData, Size, 0);
    VOinteger:
      DimVector(Data.IData, Size, 0);
    VOWord:
      DimVector(Data.WData, Size, 0);
    VOComplex:
      DimVector(Data.CData, Size, TComplex(0, 0));
    VOBoolean:
      DimVector(Data.BData, Size, false);
    VOString:
      DimVector(Data.SData, Size, '');
  end;
end;

class operator TOVector.Dec(a: TOVector): TOVector;
var
  i: Integer;
begin
  case a.Kind of
    VOFloat, VOinteger, VOWord, VOComplex:
      begin
        for i := 1 to a.Size do
          a[i] := a[i] - 1;
      end
  else
    begin
      SetErrCode(FDomain);
      ShowMessage('Hubo errores');
    end;
  end;
  result := a;
end;

procedure TOVector.destroy;
begin
  case Kind of
    VOFloat:
      DelVector(Data.FData);
    VOinteger:
      DelVector(Data.IData);
    VOWord:
      DelVector(Data.WData);
    VOComplex:
      DelVector(Data.CData);
    VOBoolean:
      DelVector(Data.BData);
    VOString:
      DelVector(Data.SData);
  end;
end;

class operator TOVector.Divide(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    if DameKind(a.Kind, b.Kind) = VOComplex then
      lKind := VOComplex
    else
      lKind := VOFloat;
    result := TOVector.Create(a.Size, lKind);
    for i := 1 to a.Size do
      result[i] := a[i] / b[i];
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.Equal(a, b: TOVector): Boolean;
var
  i: Integer;
begin
  if a.Size = b.Size then
  begin
    result := true;
    case a.Kind of
      VOFloat:
        case b.Kind of
          VOFloat, VOinteger, VOWord, VOComplex:
            for i := 1 to a.Size do
              result := result and (a[i] = b[i]);
          VOBoolean:
            result := false;
          VOString:
            for i := 1 to a.Size do
              result := result and (a[i] = Str2Float(b[i]));
        end;
      VOinteger:
        case b.Kind of
          VOFloat, VOinteger, VOWord, VOComplex:
            for i := 1 to a.Size do
              result := result and (a[i] = b[i]);
          VOBoolean:
            result := false;
          VOString:
            for i := 1 to a.Size do
              result := result and (a[i] = Str2Int(b[i]));
        end;
      VOWord:
        case b.Kind of
          VOFloat, VOinteger, VOWord, VOComplex:
            for i := 1 to a.Size do
              result := result and (a[i] = b[i]);
          VOBoolean:
            result := false;
          VOString:
            for i := 1 to a.Size do
              result := result and (a[i] = Str2Word(b[i]));
        end;
      VOComplex:
        case b.Kind of
          VOFloat, VOinteger, VOWord, VOComplex:
            for i := 1 to a.Size do
              result := result and (a[i] = b[i]);
          VOBoolean:
            result := false;
          VOString:
            for i := 1 to a.Size do
              result := result and (a[i] = Str2Complex(b[i]));
        end;
      VOBoolean:
        case b.Kind of
          VOFloat, VOinteger, VOWord, VOComplex, VOString:
            result := false;
          VOBoolean:
            for i := 1 to a.Size do
              result := result and not(a[i] xor b[i]);
        end;
      VOString:
        case b.Kind of
          VOFloat:
            for i := 1 to a.Size do
              result := result and (Str2Float(a[i]) = b[i]);
          VOinteger:
            for i := 1 to a.Size do
              result := result and (Str2Int(a[i]) = b[i]);
          VOWord:
            for i := 1 to a.Size do
              result := result and (Str2Word(a[i]) = b[i]);
          VOComplex:
            for i := 1 to a.Size do
              result := result and (Str2Complex(a[i]) = b[i]);
          VOBoolean:
            result := false;
          VOString:
            for i := 1 to a.Size do
              result := result and StrCompare(a[i], b[i]);
        end;
    end;
  end
  else
    result := false;
end;

class operator TOVector.Explicit(a: TOVector): TIntVector;
begin
  if a.Kind = VOinteger then
    result := a.Data.IData;
end;

class operator TOVector.Explicit(a: TVector): TOVector;
var
  n: Integer;
begin
  n := Trunc(a[0]);
  result := TOVector.Create(n, VOFloat);
  result.Data.FData := Clone(a, n);
end;

class operator TOVector.Explicit(a: TOVector): TVector;
begin
  if a.Kind = VOFloat then
    result := a.Data.FData;
end;

class operator TOVector.Explicit(a: TIntVector): TOVector;
var
  n: Integer;
begin
  n := a[0];
  result := TOVector.Create(n, VOinteger);
  result.Data.IData := Clone(a, n);
end;

class operator TOVector.Explicit(a: TCompVector): TOVector;
var
  n: Integer;
begin
  n := a[0];
  result := TOVector.Create(n, VOComplex);
  result.Data.CData := Clone(a, n);
end;

class operator TOVector.Explicit(a: TOVector): TStrVector;
begin
  if a.Kind = VOString then
    result := a.Data.SData;
end;

class operator TOVector.Explicit(a: TStrVector): TOVector;
var
  n: Integer;
begin
  n := Str2Int(a[0]);
  result := TOVector.Create(n, VOString);
  result.Data.SData := Clone(a, n);
end;

function TOVector.GetElemento(n: Integer): Variant;
begin
  case FKind of
    VOFloat:
      result := Data.FData[n];
    VOinteger:
      result := Data.IData[n];
    VOWord:
      result := Data.WData[n];
    VOComplex:
      result := VarComplexCreate(Data.CData[n].Real, Data.CData[n].Imaginary);
    VOBoolean:
      result := Data.BData[n];
    VOString:
      result := Data.SData[n];
  end;
end;

class operator TOVector.Explicit(a: TOVector): TWordVector;
begin
  if a.Kind = VOWord then
    result := a.Data.WData;
end;

class operator TOVector.Explicit(a: TWordVector): TOVector;
var
  n: Integer;
begin
  n := a[0];
  result := TOVector.Create(n, VOWord);
  result.Data.WData := Clone(a, n);
end;

class operator TOVector.Explicit(a: TOVector): TCompVector;
begin
  if a.Kind = VOComplex then
    result := a.Data.CData;
end;

class operator TOVector.Implicit(a: TOVector): TIntVector;
begin
  if a.Kind = VOinteger then
    result := a.Data.IData;
end;

class operator TOVector.Implicit(a: TVector): TOVector;
var
  n: Integer;
begin
  n := Trunc(a[0]);
  result := TOVector.Create(n, VOFloat);
  result.Data.FData := Clone(a, n);
end;

class operator TOVector.Implicit(a: TOVector): TVector;
begin
  if a.Kind = VOFloat then
    result := a.Data.FData;
end;

class operator TOVector.Implicit(a: TIntVector): TOVector;
var
  n: Integer;
begin
  n := a[0];
  result := TOVector.Create(n, VOinteger);
  result.Data.IData := Clone(a, n);
end;

class operator TOVector.Implicit(a: TCompVector): TOVector;
var
  n: Integer;
begin
  n := a[0];
  result := TOVector.Create(n, VOComplex);
  result.Data.CData := Clone(a, n);
end;

class operator TOVector.Implicit(a: TOVector): TStrVector;
begin
  if a.Kind = VOString then
    result := a.Data.SData;
end;

class operator TOVector.Implicit(a: TStrVector): TOVector;
var
  n: Integer;
begin
  n := Str2Int(a[0]);
  result := TOVector.Create(n, VOString);
  result.Data.SData := Clone(a, n);
end;

class operator TOVector.Implicit(a: TOVector): TWordVector;
begin
  if a.Kind = VOWord then
    result := a.Data.WData;
end;

class operator TOVector.Implicit(a: TWordVector): TOVector;
var
  n: Integer;
begin
  n := a[0];
  result := TOVector.Create(n, VOWord);
  result.Data.WData := Clone(a, n);
end;

class operator TOVector.Implicit(a: TOVector): TCompVector;
begin
  if a.Kind = VOComplex then
    result := a.Data.CData;
end;

class operator TOVector.Inc(a: TOVector): TOVector;
var
  i: Integer;
begin
  case a.Kind of
    VOFloat, VOinteger, VOWord, VOComplex:
      for i := 1 to a.Size do
        a[i] := a[i] + 1;
  else
    begin
      SetErrCode(FDomain);
      ShowMessage('Hubo errores');
    end;
  end;
  result := a;
end;

class operator TOVector.IntDivide(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    if (lKind = VOinteger) or (lKind = VOWord) then
      result := TOVector.Create(a.Size, lKind)
    else
      goto error;
    for i := 1 to a.Size do
      result[i] := a[i] div b[i];
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.LeftShift(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    if (lKind = VOinteger) or (lKind = VOWord) then
      result := TOVector.Create(a.Size, lKind)
    else
      goto error;
    for i := 1 to a.Size do
      result[i] := a[i] shl b[i];
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.Modulus(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    if (lKind = VOinteger) or (lKind = VOWord) then
      result := TOVector.Create(a.Size, lKind)
    else
      goto error;
    for i := 1 to a.Size do
      result[i] := a[i] mod b[i];
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.Multiply(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    if (lKind = VOinteger) or (lKind = VOWord) then
      result := TOVector.Create(a.Size, lKind)
    else
      goto error;
    case a.Kind of
      VOFloat, VOinteger, VOWord, VOComplex:
        begin
          case b.Kind of
            VOFloat, VOinteger, VOWord, VOComplex:
              begin
                for i := 1 to a.Size do
                  result[i] := a[i] * b[i];
              end;
          else
            goto error;
          end;
        end;
      VOBoolean:
        begin
          case b.Kind of
            VOBoolean:
              begin
                for i := 1 to a.Size do
                  result[i] := a[i] and b[i];;
              end;
          else
            goto error;
          end;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.Negative(a: TOVector): TOVector;
var
  b: TOVector;
  i: Integer;
begin
  b := TOVector.Create(a.Size, VOinteger);
  for i := 1 to a.Size do
    b[i] := -1;
  result := a * b;
  b.destroy;
end;

class operator TOVector.NotEqual(a, b: TOVector): Boolean;
begin
  result := not(a = b);
end;

class operator TOVector.Positive(a: TOVector): TOVector;
var
  b: TOVector;
  i: Integer;
begin
  b := TOVector.Create(a.Size, VOinteger);
  for i := 1 to a.Size do
    b[i] := 1;
  result := a * b;
  b.destroy;
end;

class operator TOVector.RightShift(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    if (lKind = VOinteger) or (lKind = VOWord) then
      result := TOVector.Create(a.Size, lKind)
    else
      goto error;
    for i := 1 to a.Size do
      result[i] := a[i] shr b[i];
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.Round(a: TOVector): TOVector;
var
  i: Integer;
begin
  if a.Kind = VOFloat then
  begin
    result := TOVector.Create(a.Size, VOinteger);
    for i := 1 to a.Size do
      result[i] := Round(a[i]);
  end;
end;

procedure TOVector.SetElemento(n: Integer; const Value: Variant);
begin
  case FKind of
    VOFloat:
      Data.FData[n] := VarAsType(Value, vtExtended);
    VOinteger:
      Data.IData[n] := VarAsType(Value, vtInteger);
    VOWord:
      Data.WData[n] := VarAsType(Value, vtInteger);
    VOComplex:
      begin
        Data.CData[n].Real :=
          (VarAsComplex(Value) + VarComplexConjugate(Value)) / 2;
        Data.CData[n].Imaginary :=
          (VarAsComplex(Value) - VarComplexConjugate(Value)) / 2;
      end;
    VOBoolean:
      Data.BData[n] := VarAsType(Value, vtBoolean);
    VOString:
      Data.SData[n] := VarAsType(Value, vtString);
  end;
end;

procedure TOVector.SetKind(const Value: TVOKind);
begin
  FKind := Value;
end;

procedure TOVector.SetSize(const Value: Integer);
begin
  FSize := Value;
end;

class operator TOVector.Subtract(a, b: TOVector): TOVector;
var
  i: Integer;
  lKind: TVOKind;
label error;
begin
  if a.Size = b.Size then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOVector.Create(a.Size, lKind);
    case a.Kind of
      VOFloat, VOinteger, VOWord, VOComplex:
        begin
          case b.Kind of
            VOFloat, VOinteger, VOWord, VOComplex:
              begin
                for i := 1 to a.Size do
                  result[i] := a[i] - b[i];
              end;
          else
            goto error;
          end;
        end;
      VOBoolean:
        begin
          case b.Kind of
            VOBoolean:
              begin
                result.Data.BData := FResta(a.Data.BData, b.Data.BData, a.Size);
              end;
          else
            goto error;
          end;
        end;
      VOString:
        begin
          case b.Kind of
            VOString:
              begin
                result.Data.SData := FResta(a.Data.SData, b.Data.SData, a.Size);
              end;
          else
            goto error;
          end;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOVector.Trunc(a: TOVector): TOVector;
var
  i: Integer;
begin
  if a.Kind = VOFloat then
  begin
    result := TOVector.Create(a.Size, VOinteger);
    for i := 1 to a.Size do
      result[i] := Trunc(a[i]);
  end;
end;

{ TOMatrix }

class operator TOMatrix.Add(a, b: TOMatrix): TOMatrix;
var
  i, j: Integer;
  lKind: TVOKind;
label error;
begin
  if (a.SizeX = b.SizeX) and (a.SizeY = b.SizeY) then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOMatrix.Create(a.SizeX, a.SizeY, lKind);
    case a.Kind of
      VOFloat, VOinteger, VOWord, VOComplex:
        begin
          case b.Kind of
            VOFloat, VOinteger, VOWord, VOComplex:
              begin
                for i := 1 to a.SizeX do
                  for j := 1 to a.SizeY do
                    result[i, j] := a[i, j] + b[i, j];
              end;
          else
            goto error;
          end;
        end;
      VOBoolean:
        begin
          case b.Kind of
            VOBoolean:
              begin
                result.Data.BData := FSuma(a.Data.BData, b.Data.BData,
                  a.SizeX, a.SizeY);
              end;
          else
            goto error;
          end;
        end;
      VOString:
        begin
          case b.Kind of
            VOString:
              begin
                result.Data.SData := FSuma(a.Data.SData, b.Data.SData,
                  a.SizeX, a.SizeY);
              end;
          else
            goto error;
          end;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

constructor TOMatrix.Create(a: TMatrix);
begin
  SetSizeX(Round(a[1, 0]));
  SetSizeY(Round(a[0, 1]));
  SetKind(VOFloat);
  Data.FData := a;
end;

constructor TOMatrix.Create(Ub1, Ub2: Integer; wKind: TVOKind);
begin
  SetSizeX(Ub1);
  SetSizeY(Ub2);
  SetKind(wKind);
  case Kind of
    VOFloat:
      DimMatrix(Data.FData, Ub1, Ub2);
    VOinteger:
      DimMatrix(Data.IData, Ub1, Ub2);
    VOWord:
      DimMatrix(Data.WData, Ub1, Ub2);
    VOComplex:
      DimMatrix(Data.CData, Ub1, Ub2, 0);
    VOBoolean:
      DimMatrix(Data.BData, Ub1, Ub2);
    VOString:
      DimMatrix(Data.SData, Ub1, Ub2);
  end;
end;

class operator TOMatrix.Dec(a: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := (a[i, j] - 1);
end;

procedure TOMatrix.destroy;
begin
  case Kind of
    VOFloat:
      DelMatrix(Data.FData);
    VOinteger:
      DelMatrix(Data.IData);
    VOWord:
      DelMatrix(Data.WData);
    VOComplex:
      DelMatrix(Data.CData);
    VOBoolean:
      DelMatrix(Data.BData);
    VOString:
      DelMatrix(Data.SData);
  end;
end;

class operator TOMatrix.Divide(a, b: TOMatrix): TOMatrix;
var
  i, j: Integer;
  lKind: TVOKind;
label error;
begin
  if (a.SizeX = b.SizeX) and (a.SizeY = b.SizeY) then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOMatrix.Create(a.SizeX, a.SizeY, lKind);
    case a.Kind of
      VOFloat, VOinteger, VOWord, VOComplex:
        begin
          case b.Kind of
            VOFloat, VOinteger, VOWord, VOComplex:
              begin
                for i := 1 to a.SizeX do
                  for j := 1 to a.SizeY do
                    result[i, j] := a[i, j] / b[i, j];
              end;
          else
            goto error;
          end;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOMatrix.Equal(a, b: TOMatrix): Boolean;
var
  i, j: Integer;
begin
  result := true;
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
    begin
      result := result and (a[i, j] = b[i, j]);
      if not result then
        exit;
    end;
end;

function TOMatrix.GetElemento(m, n: Integer): Variant;
begin
  case FKind of
    VOFloat:
      result := Data.FData[m, n];
    VOinteger:
      result := Data.IData[m, n];
    VOWord:
      result := Data.WData[m, n];
    VOComplex:
      result := VarComplexCreate(Data.CData[m, n].Real,
        Data.CData[m, n].Imaginary);
    VOBoolean:
      result := Data.BData[m, n];
    VOString:
      result := Data.SData[m, n];
  end;
end;

class operator TOMatrix.Implicit(a: TMatrix): TOMatrix;
begin
  result := TOMatrix.Create(a);
end;

class operator TOMatrix.Implicit(a: TOMatrix): TMatrix;
begin
  result := a.Data.FData;
end;

class operator TOMatrix.Implicit(a: TCompMatrix): TOMatrix;
begin
  result := TOMatrix.Create(a);
end;

class operator TOMatrix.Implicit(a: TOMatrix): TCompMatrix;
begin
  result := a.Data.CData;
end;

class operator TOMatrix.Inc(a: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := (a[i, j] + 1);
end;

class operator TOMatrix.IntDivide(a, b: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := (a[i, j] div b[i, j]);
end;

function TOMatrix.Inversa: TOMatrix;
var
  lLu: TLU;
  lLU_Comp: TLU_Comp;
begin
  if (Self.SizeX = Self.SizeY) then
  begin
    case Self.FKind of
      VOFloat:
        begin
          lLu := TLU.Create(Self.Data.FData, 1, Self.FSizeX);
          result := lLu.InverseMatrix;
          lLu.Free;
        end;
      VOComplex:
        begin
          lLU_Comp := TLU_Comp.Create(Self.Data.CData, 1, Self.FSizeX);
          result := lLU_Comp.InverseMatrix;
          lLU_Comp.Free;
        end;
    end;
  end;
end;

class operator TOMatrix.Modulus(a, b: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := (a[i, j] mod b[i, j]);
end;

class operator TOMatrix.Multiply(a, b: TOMatrix): TOMatrix;
var
  i, j, k: Integer;
  Fcount: float;
  ICount: Integer;
  Wcount: word;
  Ccount: Complex;
  lKind: TVOKind;
label error;
begin
  if a.MultiplicationKind = TOMKItems then
  begin
    if (a.SizeX = b.SizeX) and (a.SizeY = b.SizeY) then
    begin
      lKind := DameKind(a.Kind, b.Kind);
      result := TOMatrix.Create(a.SizeX, a.SizeY, lKind);
      case a.Kind of
        VOFloat, VOinteger, VOWord, VOComplex:
          begin
            case b.Kind of
              VOFloat, VOinteger, VOWord, VOComplex:
                begin
                  for i := 1 to a.SizeX do
                    for j := 1 to a.SizeY do
                      result[i, j] := a[i, j] * b[i, j];
                end;
            else
              goto error;
            end;
          end;
      else
        goto error;
      end;
    end
    else
      goto error;
  end
  else
  begin // TOMKMatrix
    if (a.SizeX = b.SizeY) then
    begin
      lKind := DameKind(a.Kind, b.Kind);
      result := TOMatrix.Create(b.SizeX, a.SizeY, lKind);
      case a.Kind of
        VOFloat, VOinteger, VOWord, VOComplex:
          begin
            case b.Kind of
              VOFloat, VOinteger, VOWord, VOComplex:
                begin
                  for i := 1 to a.SizeX do
                    for j := 1 to a.SizeY do
                    begin
                      Ccount := 0;
                      for k := 1 to a.SizeX do
                        Ccount := Ccount + a[k, j] * b[i, k];
                      result[i, j] := Ccount;
                    end;
                end;
            else
              goto error;
            end;
          end;
      else
        goto error;
      end;
    end;
  end;
  exit;
error:
  SetErrCode(FDomain);
  ShowMessage('Hubo errores');
end;

class operator TOMatrix.Negative(a: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := -(a[i, j]);
end;

class operator TOMatrix.NotEqual(a, b: TOMatrix): Boolean;
var
  i, j: Integer;
begin
  result := true;
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
    begin
      result := result and (a[i, j] <> b[i, j]);
      if not result then
        exit;
    end;
end;

class operator TOMatrix.Positive(a: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := +(a[i, j]);
end;

class operator TOMatrix.Round(a: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := Round(a[i, j]);
end;

procedure TOMatrix.SetElemento(m, n: Integer; const Value: Variant);
begin
  case FKind of
    VOFloat:
      Data.FData[m, n] := VarAsType(Value, vtExtended);
    VOinteger:
      Data.IData[m, n] := VarAsType(Value, vtInteger);
    VOWord:
      Data.WData[m, n] := VarAsType(Value, vtInteger);
    VOComplex:
      begin
        Data.CData[m, n].Real :=
          (VarAsComplex(Value) + VarComplexConjugate(Value)) / 2;
        Data.CData[m, n].Imaginary :=
          (VarAsComplex(Value) - VarComplexConjugate(Value)) / 2;
      end;
    VOBoolean:
      Data.BData[m, n] := VarAsType(Value, vtBoolean);
    VOString:
      Data.SData[m, n] := VarAsType(Value, vtString);
  end;
end;

procedure TOMatrix.SetKind(const Value: TVOKind);
begin
  FKind := Value;
end;

procedure TOMatrix.SetMultiplicationKind(const Value: TOMultiplicationKind);
begin
  FMultiplicationKind := Value;
end;

procedure TOMatrix.SetSizeX(const Value: Integer);
begin
  FSizeX := Value;
end;

procedure TOMatrix.SetSizeY(const Value: Integer);
begin
  FSizeY := Value;
end;

class operator TOMatrix.Subtract(a, b: TOMatrix): TOMatrix;
var
  i, j: Integer;
  lKind: TVOKind;
label error;
begin
  if (a.SizeX = b.SizeX) and (a.SizeY = b.SizeY) then
  begin
    lKind := DameKind(a.Kind, b.Kind);
    result := TOMatrix.Create(a.SizeX, a.SizeY, lKind);
    case a.Kind of
      VOFloat, VOinteger, VOWord, VOComplex:
        begin
          case b.Kind of
            VOFloat, VOinteger, VOWord, VOComplex:
              begin
                for i := 1 to a.SizeX do
                  for j := 1 to a.SizeY do
                    result[i, j] := a[i, j] - b[i, j];
              end;
          else
            goto error;
          end;
        end;
      VOBoolean:
        begin
          case b.Kind of
            VOBoolean:
              begin
                result.Data.BData := FResta(a.Data.BData, b.Data.BData,
                  a.SizeX, a.SizeY);
              end;
          else
            goto error;
          end;
        end;
      VOString:
        begin
          case b.Kind of
            VOString:
              begin
                result.Data.SData := FResta(a.Data.SData, b.Data.SData,
                  a.SizeX, a.SizeY);
              end;
          else
            goto error;
          end;
        end;
    else
      goto error;
    end;
  end
  else
  begin
  error:
    SetErrCode(FDomain);
    ShowMessage('Hubo errores');
  end;
end;

class operator TOMatrix.Trunc(a: TOMatrix): TOMatrix;
var
  i, j: Integer;
begin
  result := TOMatrix.Create(a.FSizeX, a.FSizeY);
  for i := 1 to a.FSizeX do
    for j := 1 to a.FSizeY do
      result[i, j] := Trunc(a[i, j]);

end;

constructor TOMatrix.Create(a: TCompMatrix);
begin
  SetSizeX(Round(a[1, 0].Real));
  SetSizeY(Round(a[0, 1].Real));
  SetKind(VOComplex);
  Data.CData := a;
end;

constructor TOMatrix.Create(a: TIntMatrix);
begin
  SetSizeX(a[1, 0]);
  SetSizeY(a[0, 1]);
  SetKind(VOinteger);
  Data.IData := a;
end;

constructor TOMatrix.Create(a: TStrMatrix);
begin
  SetSizeX(Str2Int(a[1, 0]));
  SetSizeY(Str2Int(a[0, 1]));
  SetKind(VOString);
  Data.SData := a;
end;

constructor TOMatrix.Create(a: TBoolMatrix);
begin
  SetKind(VOBoolean);
  Data.BData := a;
end;

constructor TOMatrix.Create(a: TWordMatrix);
begin
  SetSizeX(a[1, 0]);
  SetSizeY(a[0, 1]);
  SetKind(VOWord);
  Data.WData := a;
end;

{ TO3DMatrix }

class operator TO3DMatrix.Add(a, b: TO3DMatrix): TO3DMatrix;
begin

end;

constructor TO3DMatrix.Create(a: T3DIntMatrix);
begin
  SetSizeX(a[1, 0, 0]);
  SetSizeY(a[0, 1, 0]);
  SetSizeY(a[0, 0, 1]);
  SetKind(VOFloat);
  Data.IData := a;
end;

constructor TO3DMatrix.Create(a: T3DCompMatrix);
begin
  SetSizeX(Round(a[1, 0, 0].Real));
  SetSizeY(Round(a[0, 1, 0].Real));
  SetSizeY(Round(a[0, 0, 1].Real));
  SetKind(VOFloat);
  Data.CData := a;
end;

constructor TO3DMatrix.Create(Ub1, Ub2, Ub3: Integer; wKind: TVOKind);
begin
  SetSizeX(Ub1);
  SetSizeY(Ub2);
  SetSizeZ(Ub3);
  SetKind(wKind);
  case Kind of
    VOFloat:
      DimMatrix(Data.FData, Ub1, Ub2, Ub3);
    VOinteger:
      DimMatrix(Data.IData, Ub1, Ub2, Ub3);
    VOWord:
      DimMatrix(Data.WData, Ub1, Ub2, Ub3);
    VOComplex:
      DimMatrix(Data.CData, Ub1, Ub2, Ub3, 0);
    VOBoolean:
      DimMatrix(Data.BData, Ub1, Ub2, Ub3);
    VOString:
      DimMatrix(Data.SData, Ub1, Ub2, Ub3);
  end;
end;

constructor TO3DMatrix.Create(a: T3DMatrix);
begin
  SetSizeX(Round(a[1, 0, 0]));
  SetSizeY(Round(a[0, 1, 0]));
  SetSizeY(Round(a[0, 0, 1]));
  SetKind(VOFloat);
  Data.FData := a;
end;

constructor TO3DMatrix.Create(a: T3DBoolMatrix);
begin

end;

constructor TO3DMatrix.Create(a: T3DWordMatrix);
begin
  SetSizeX(a[1, 0, 0]);
  SetSizeY(a[0, 1, 0]);
  SetSizeY(a[0, 0, 1]);
  SetKind(VOFloat);
  Data.WData := a;
end;

constructor TO3DMatrix.Create(a: T3DStrMatrix);
begin
  begin
    SetSizeX(Str2Int(a[1, 0, 0]));
    SetSizeY(Str2Int(a[0, 1, 0]));
    SetSizeY(Str2Int(a[0, 0, 1]));
    SetKind(VOFloat);
    Data.SData := a;
  end;
end;

class operator TO3DMatrix.Dec(a: TO3DMatrix): TO3DMatrix;
begin

end;

procedure TO3DMatrix.destroy;
begin
  case Kind of
    VOFloat:
      DelMatrix(Data.FData);
    VOinteger:
      DelMatrix(Data.IData);
    VOWord:
      DelMatrix(Data.WData);
    VOComplex:
      DelMatrix(Data.CData);
    VOBoolean:
      DelMatrix(Data.BData);
    VOString:
      DelMatrix(Data.SData);
  end;
end;

class operator TO3DMatrix.Equal(a, b: TO3DMatrix): Boolean;
begin

end;

function TO3DMatrix.GetElemento(m, n, o: Integer): Variant;
begin
  case FKind of
    VOFloat:
      result := Data.FData[m, n, o];
    VOinteger:
      result := Data.IData[m, n, o];
    VOWord:
      result := Data.WData[m, n, o];
    VOComplex:
      result := VarComplexCreate(Data.CData[m, n, o].Real,
        Data.CData[m, n, o].Imaginary);
    VOBoolean:
      result := Data.BData[m, n, o];
    VOString:
      result := Data.SData[m, n, o];
  end;
end;

class operator TO3DMatrix.Implicit(a: TO3DMatrix): T3DCompMatrix;
begin
  if a.Kind = VOComplex then
    result := a.Data.CData;
end;

class operator TO3DMatrix.Implicit(a: T3DCompMatrix): TO3DMatrix;
begin

end;

class operator TO3DMatrix.Implicit(a: TO3DMatrix): T3DMatrix;
begin
  if a.Kind = VOFloat then
    result := a.Data.FData;
end;

class operator TO3DMatrix.Implicit(a: T3DMatrix): TO3DMatrix;
begin

end;

class operator TO3DMatrix.Inc(a: TO3DMatrix): TO3DMatrix;
begin

end;

class operator TO3DMatrix.Negative(a: TO3DMatrix): TO3DMatrix;
begin

end;

class operator TO3DMatrix.NotEqual(a, b: TO3DMatrix): Boolean;
begin

end;

class operator TO3DMatrix.Positive(a: TO3DMatrix): TO3DMatrix;
begin

end;

class operator TO3DMatrix.Round(a: TO3DMatrix): TO3DMatrix;
begin

end;

procedure TO3DMatrix.SetElemento(m, n, o: Integer; const Value: Variant);
begin
  case FKind of
    VOFloat:
      Data.FData[m, n, o] := VarAsType(Value, vtExtended);
    VOinteger:
      Data.IData[m, n, o] := VarAsType(Value, vtInteger);
    VOWord:
      Data.WData[m, n, o] := VarAsType(Value, vtInteger);
    VOComplex:
      begin
        Data.CData[m, n, o].Real :=
          (VarAsComplex(Value) + VarComplexConjugate(Value)) / 2;
        Data.CData[m, n, o].Imaginary :=
          (VarAsComplex(Value) - VarComplexConjugate(Value)) / 2;
      end;
    VOBoolean:
      Data.BData[m, n, o] := VarAsType(Value, vtBoolean);
    VOString:
      Data.SData[m, n, o] := VarAsType(Value, vtString);
  end;
end;

procedure TO3DMatrix.SetKind(const Value: TVOKind);
begin
  FKind := Value;
end;

procedure TO3DMatrix.SetSizeX(const Value: Integer);
begin
  FSizeX := Value;
end;

procedure TO3DMatrix.SetSizeY(const Value: Integer);
begin
  FSizeY := Value;
end;

procedure TO3DMatrix.SetSizeZ(const Value: Integer);
begin
  FSizeZ := Value;
end;

class operator TO3DMatrix.Subtract(a, b: TO3DMatrix): TO3DMatrix;
begin

end;

class operator TO3DMatrix.Trunc(a: TO3DMatrix): TO3DMatrix;
begin

end;

end.
