unit uBaseGeometry;

(*
  * ******************************************************************************
  *                                                                              *
  * Author    :  Alex Vergara Gil                                                *
  * Version   :  0.1                                                             *
  * Date      :  26 February 2013                                                *
  * Website   :  http://www.cphr.edu.cu                                          *
  * Copyright :  Alex Vergara Gil 2013                                           *
  *                                                                              *
  * Base objects for geometry processing                                         *
  *                                                                              *
  ****************************************************************************** *)

interface

uses
  SysUtils, Types, Classes, uconstants, Math;

type
  PIntPoint = ^TIntPoint;

  TIntPoint = record
    X: Int64;
    Y: Int64;
  public
    // operator overloads
    class operator Equal(const Lhs, Rhs: TIntPoint): Boolean;
    class operator NotEqual(const Lhs, Rhs: TIntPoint): Boolean;
    class operator Add(const Lhs, Rhs: TIntPoint): TIntPoint;
    class operator Subtract(const Lhs, Rhs: TIntPoint): TIntPoint;
    class operator Implicit(Value: TPoint): TIntPoint;
    class operator Implicit(Value: TIntPoint): TPoint;
    class operator Explicit(Value: TPoint): TIntPoint;
    class operator Explicit(Value: TIntPoint): TPoint;
    procedure Add(const Point: TIntPoint);
    procedure Subtract(const Point: TIntPoint);
    function IsZero: Boolean;
    function distance(const Point: TIntPoint): Double;
  end;

  PFloatPoint = ^TFloatPoint;

  TFloatPoint = record
    X: float;
    Y: float;
  public
    // operator overloads
    class operator Equal(const Lhs, Rhs: TFloatPoint): Boolean;
    class operator NotEqual(const Lhs, Rhs: TFloatPoint): Boolean;
    class operator Add(const Lhs, Rhs: TFloatPoint): TFloatPoint;
    class operator Subtract(const Lhs, Rhs: TFloatPoint): TFloatPoint;
    class operator Implicit(Value: TPoint): TFloatPoint;
    class operator Implicit(Value: TFloatPoint): TPoint;
    class operator Explicit(Value: TPoint): TFloatPoint;
    class operator Explicit(Value: TFloatPoint): TPoint;
    procedure Add(const Point: TFloatPoint);
    procedure Subtract(const Point: TFloatPoint);
    function IsZero: Boolean;
    function distance(const Point: TFloatPoint): float;
  end;

  TFloatPoint3D = record
    X: float;
    Y: float;
    Z: float;
  public
    // operator overloads
    class operator Equal(const Lhs, Rhs: TFloatPoint3D): Boolean;
    class operator NotEqual(const Lhs, Rhs: TFloatPoint3D): Boolean;
    class operator Add(const Lhs, Rhs: TFloatPoint3D): TFloatPoint3D;
    class operator Subtract(const Lhs, Rhs: TFloatPoint3D): TFloatPoint3D;
    procedure Add(const Point: TFloatPoint3D);
    procedure Subtract(const Point: TFloatPoint3D);
    function IsZero: Boolean;
    function distance(const Point: TFloatPoint3D): float;
  end;

  TIntRect = record
  private
    procedure SetHeight(const Value: Int64);
    procedure SetWidth(const Value: Int64);
    function GetHeight: Int64;
    function GetWidth: Int64;
  public
    constructor Create(const Origin: TIntPoint); overload;
    // empty rect at given origin
    constructor Create(const Origin: TIntPoint; Width, Height: Int64); overload;
    // at TPoint of origin with width and height
    constructor Create(const Left, Top, Right, Bottom: Int64); overload;
    // with starting and ending points
    constructor Create(const P1, P2: TIntPoint; Normalize: Boolean = False);
      overload; // with corners specified by p1 and p2
    constructor Create(const R: TIntRect; Normalize: Boolean = False); overload;
    property Width: Int64 read GetWidth write SetWidth;
    property Height: Int64 read GetHeight write SetHeight;
    function CenterPoint: TIntPoint;
    procedure NormalizeRect;
    class function Empty: TIntRect; static;
    case Integer of
      0:
        (Left, Top, Right, Bottom: Int64);
      1:
        (TopLeft, BottomRight: TIntPoint);
  end;

  TfloatRect = record
  private
    procedure SetHeight(const Value: float);
    procedure SetWidth(const Value: float);
    function GetHeight: float;
    function GetWidth: float;
  public
    constructor Create(const Origin: TFloatPoint); overload;
    // empty rect at given origin
    constructor Create(const Origin: TFloatPoint;
      Width, Height: float); overload;
    // at TPoint of origin with width and height
    constructor Create(const Left, Top, Right, Bottom: float); overload;
    // with starting and ending points
    constructor Create(const P1, P2: TFloatPoint; Normalize: Boolean = False);
      overload; // with corners specified by p1 and p2
    constructor Create(const R: TfloatRect;
      Normalize: Boolean = False); overload;
    property Width: float read GetWidth write SetWidth;
    property Height: float read GetHeight write SetHeight;
    function CenterPoint: TFloatPoint;
    procedure NormalizeRect;
    class function Empty: TfloatRect; static;
    case Integer of
      0:
        (Left, Top, Right, Bottom: float);
      1:
        (TopLeft, BottomRight: TFloatPoint);
  end;

  IntRec = packed record
    case Integer of
      0:
        (Lo, Hi: Int64);
      1:
        (large: array [0 .. 1] of Int64);
      2:
        (ints: array [0 .. 3] of Int32);
      3:
        (words: array [0 .. 7] of Int16);
  end;

  FloatRec = packed record
    case Integer of
      0:
        (Lo, Hi: double);
      1:
        (doubles: array [0 .. 1] of double);
      2:
        (singles: array [0 .. 3] of single);
  end;

  // Helper functions
function IntPoint(const X, Y: Int64): TIntPoint;
function FloatPoint(const X, Y: float): TFloatPoint;
function FloatPoint3D(const X, Y, Z: float): TFloatPoint3D;
function IntRect(ALeft, ATop, ARight, ABottom: Int64): TIntRect; overload;
function IntRect(const ATopLeft, ABottomRight: TIntPoint): TIntRect; overload;
function FloatRect(ALeft, ATop, ARight, ABottom: float): TfloatRect; overload;
function FloatRect(const ATopLeft, ABottomRight: TFloatPoint)
  : TfloatRect; overload;

implementation

// ------------------------------------------------------------------------------
function IntPoint(const X, Y: Int64): TIntPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

// ------------------------------------------------------------------------------
function FloatPoint(const X, Y: float): TFloatPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

// ------------------------------------------------------------------------------
function FloatPoint3D(const X, Y, Z: float): TFloatPoint3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

// ------------------------------------------------------------------------------
function FloatRect(ALeft, ATop, ARight, ABottom: float): TfloatRect;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

// ------------------------------------------------------------------------------
function FloatRect(const ATopLeft, ABottomRight: TFloatPoint): TfloatRect;
begin
  Result.Left := ATopLeft.X;
  Result.Top := ATopLeft.Y;
  Result.Right := ABottomRight.X;
  Result.Bottom := ABottomRight.Y;
end;

// ------------------------------------------------------------------------------
function IntRect(ALeft, ATop, ARight, ABottom: Int64): TIntRect;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

// ------------------------------------------------------------------------------
function IntRect(const ATopLeft, ABottomRight: TIntPoint): TIntRect;
begin
  Result.Left := ATopLeft.X;
  Result.Top := ATopLeft.Y;
  Result.Right := ABottomRight.X;
  Result.Bottom := ABottomRight.Y;
end;
// ------------------------------------------------------------------------------
{ TIntPoint }

class operator TIntPoint.Add(const Lhs, Rhs: TIntPoint): TIntPoint;
begin
  Result := IntPoint(Lhs.X + Rhs.X, Lhs.Y + Rhs.Y);
end;

procedure TIntPoint.Add(const Point: TIntPoint);
begin
  X := X + Point.X;
  Y := Y + Point.Y;
end;

function TIntPoint.distance(const Point: TIntPoint): Double;
begin
  Result := Sqrt(sqr(Self.X - Point.X) + sqr(Self.Y - Point.Y));
end;

class operator TIntPoint.Equal(const Lhs, Rhs: TIntPoint): Boolean;
begin
  Result := (Lhs.X = Rhs.X) and (Lhs.Y = Rhs.Y);
end;

class operator TIntPoint.Explicit(Value: TPoint): TIntPoint;
begin
  Result := IntPoint(Value.X, Value.Y);
end;

class operator TIntPoint.Explicit(Value: TIntPoint): TPoint;
begin
  if Value.X < Low(Integer) then
    Result.X := Low(Integer)
  else if Value.X > High(Integer) then
    Result.X := High(Integer)
  else
    Result.X := Integer(Value.X);
  if Value.Y < Low(Integer) then
    Result.Y := Low(Integer)
  else if Value.Y > High(Integer) then
    Result.Y := High(Integer)
  else
    Result.Y := Integer(Value.Y);
end;

class operator TIntPoint.Implicit(Value: TPoint): TIntPoint;
begin
  Result := IntPoint(Value.X, Value.Y);
end;

class operator TIntPoint.Implicit(Value: TIntPoint): TPoint;
begin
  if Value.X < Low(Integer) then
    Result.X := Low(Integer)
  else if Value.X > High(Integer) then
    Result.X := High(Integer)
  else
    Result.X := Integer(Value.X);
  if Value.Y < Low(Integer) then
    Result.Y := Low(Integer)
  else if Value.Y > High(Integer) then
    Result.Y := High(Integer)
  else
    Result.Y := Integer(Value.Y);
end;

function TIntPoint.IsZero: Boolean;
begin
  Result := Math.IsZero(X) and Math.IsZero(Y);
end;

class operator TIntPoint.NotEqual(const Lhs, Rhs: TIntPoint): Boolean;
begin
  Result := (Lhs.X <> Rhs.X) or (Lhs.Y <> Rhs.Y);
end;

procedure TIntPoint.Subtract(const Point: TIntPoint);
begin
  X := X - Point.X;
  Y := Y - Point.Y;
end;

class operator TIntPoint.Subtract(const Lhs, Rhs: TIntPoint): TIntPoint;
begin
  Result := IntPoint(Lhs.X - Rhs.X, Lhs.Y - Rhs.Y);
end;

{ TIntRect }

function TIntRect.CenterPoint: TIntPoint;
begin
  Result.X := (Right - Left) div 2 + Left;
  Result.Y := (Bottom - Top) div 2 + Top;
end;

constructor TIntRect.Create(const Origin: TIntPoint; Width, Height: Int64);
begin
  Create(Origin.X, Origin.Y, Origin.X + Width, Origin.Y + Height);
end;

constructor TIntRect.Create(const Origin: TIntPoint);
begin
  Create(Origin.X, Origin.Y, Origin.X, Origin.Y);
end;

constructor TIntRect.Create(const Left, Top, Right, Bottom: Int64);
begin
  Self.Left := Left;
  Self.Top := Top;
  Self.Right := Right;
  Self.Bottom := Bottom;
end;

constructor TIntRect.Create(const R: TIntRect; Normalize: Boolean);
begin
  Self.TopLeft := R.TopLeft;
  Self.BottomRight := R.BottomRight;
  if Normalize then
    Self.NormalizeRect;
end;

constructor TIntRect.Create(const P1, P2: TIntPoint; Normalize: Boolean);
begin
  Self.TopLeft := P1;
  Self.BottomRight := P2;
  if Normalize then
    Self.NormalizeRect;
end;

class function TIntRect.Empty: TIntRect;
begin
  Result := TIntRect.Create(0, 0, 0, 0);
end;

function TIntRect.GetHeight: Int64;
begin
  Result := Self.Bottom - Self.Top;
end;

function TIntRect.GetWidth: Int64;
begin
  Result := Self.Right - Self.Left;
end;

procedure TIntRect.NormalizeRect;
begin
  if Top > Bottom then
  begin
    Top := Top xor Bottom;
    Bottom := Top xor Bottom;
    Top := Top xor Bottom;
  end;
  if Left > Right then
  begin
    Left := Left xor Right;
    Right := Left xor Right;
    Left := Left xor Right;
  end
end;

procedure TIntRect.SetHeight(const Value: Int64);
begin
  Self.Bottom := Self.Top + Value;
end;

procedure TIntRect.SetWidth(const Value: Int64);
begin
  Self.Right := Self.Left + Value;
end;

// ------------------------------------------------------------------------------

{ TFloatPoint }

class operator TFloatPoint.Add(const Lhs, Rhs: TFloatPoint): TFloatPoint;
begin
  Result := FloatPoint(Lhs.X + Rhs.X, Lhs.Y + Rhs.Y);
end;

procedure TFloatPoint.Add(const Point: TFloatPoint);
begin
  X := X + Point.X;
  Y := Y + Point.Y;
end;

function TFloatPoint.distance(const Point: TFloatPoint): float;
begin
  Result := Sqrt(sqr(Self.X - Point.X) + sqr(Self.Y - Point.Y));
end;

class operator TFloatPoint.Equal(const Lhs, Rhs: TFloatPoint): Boolean;
begin
  Result := (Lhs.X = Rhs.X) and (Lhs.Y = Rhs.Y);
end;

class operator TFloatPoint.Explicit(Value: TPoint): TFloatPoint;
begin
  Result := FloatPoint(Value.X, Value.Y);
end;

class operator TFloatPoint.Explicit(Value: TFloatPoint): TPoint;
begin
  if Value.X < Low(Integer) then
    Result.X := Low(Integer)
  else if Value.X > High(Integer) then
    Result.X := High(Integer)
  else
    Result.X := round(Value.X);
  if Value.Y < Low(Integer) then
    Result.Y := Low(Integer)
  else if Value.Y > High(Integer) then
    Result.Y := High(Integer)
  else
    Result.Y := round(Value.Y);
end;

class operator TFloatPoint.Implicit(Value: TPoint): TFloatPoint;
begin
  Result := FloatPoint(Value.X, Value.Y);
end;

class operator TFloatPoint.Implicit(Value: TFloatPoint): TPoint;
begin
  if Value.X < Low(Integer) then
    Result.X := Low(Integer)
  else if Value.X > High(Integer) then
    Result.X := High(Integer)
  else
    Result.X := round(Value.X);
  if Value.Y < Low(Integer) then
    Result.Y := Low(Integer)
  else if Value.Y > High(Integer) then
    Result.Y := High(Integer)
  else
    Result.Y := round(Value.Y);
end;

function TFloatPoint.IsZero: Boolean;
begin
  Result := Math.IsZero(X) and Math.IsZero(Y);
end;

class operator TFloatPoint.NotEqual(const Lhs, Rhs: TFloatPoint): Boolean;
begin
  Result := (Lhs.X <> Rhs.X) or (Lhs.Y <> Rhs.Y);
end;

procedure TFloatPoint.Subtract(const Point: TFloatPoint);
begin
  X := X - Point.X;
  Y := Y - Point.Y;
end;

class operator TFloatPoint.Subtract(const Lhs, Rhs: TFloatPoint): TFloatPoint;
begin
  Result := FloatPoint(Lhs.X - Rhs.X, Lhs.Y - Rhs.Y);
end;

{ TFloatRect }

function TfloatRect.CenterPoint: TFloatPoint;
begin
  Result.X := (Right - Left) / 2 + Left;
  Result.Y := (Bottom - Top) / 2 + Top;
end;

constructor TfloatRect.Create(const Origin: TFloatPoint; Width, Height: float);
begin
  Create(Origin.X, Origin.Y, Origin.X + Width, Origin.Y + Height);
end;

constructor TfloatRect.Create(const Origin: TFloatPoint);
begin
  Create(Origin.X, Origin.Y, Origin.X, Origin.Y);
end;

constructor TfloatRect.Create(const Left, Top, Right, Bottom: float);
begin
  Self.Left := Left;
  Self.Top := Top;
  Self.Right := Right;
  Self.Bottom := Bottom;
end;

constructor TfloatRect.Create(const R: TfloatRect; Normalize: Boolean);
begin
  Self.TopLeft := R.TopLeft;
  Self.BottomRight := R.BottomRight;
  if Normalize then
    Self.NormalizeRect;
end;

constructor TfloatRect.Create(const P1, P2: TFloatPoint; Normalize: Boolean);
begin
  Self.TopLeft := P1;
  Self.BottomRight := P2;
  if Normalize then
    Self.NormalizeRect;
end;

class function TfloatRect.Empty: TfloatRect;
begin
  Result := TfloatRect.Create(0, 0, 0, 0);
end;

function TfloatRect.GetHeight: float;
begin
  Result := Self.Bottom - Self.Top;
end;

function TfloatRect.GetWidth: float;
begin
  Result := Self.Right - Self.Left;
end;

procedure TfloatRect.NormalizeRect;
var
  temp: float;
begin
  if Top > Bottom then
  begin
    temp := Bottom;
    Bottom := Top;
    Top := temp;
  end;
  if Left > Right then
  begin
    temp := Left;
    Left := Right;
    Right := temp;
  end
end;

procedure TfloatRect.SetHeight(const Value: float);
begin
  Self.Bottom := Self.Top + Value;
end;

procedure TfloatRect.SetWidth(const Value: float);
begin
  Self.Right := Self.Left + Value;
end;

{ TFloatPoint3D }

procedure TFloatPoint3D.Add(const Point: TFloatPoint3D);
begin
  X := X + Point.X;
  Y := Y + Point.Y;
  Z := Z + Point.Z;
end;

class operator TFloatPoint3D.Add(const Lhs, Rhs: TFloatPoint3D): TFloatPoint3D;
begin
  Result := FloatPoint3D(Lhs.X + Rhs.X, Lhs.Y + Rhs.Y, Lhs.Z + Rhs.Z);
end;

function TFloatPoint3D.distance(const Point: TFloatPoint3D): float;
begin
  Result := Sqrt(sqr(Self.X - Point.X) + sqr(Self.Y - Point.Y) +
    sqr(Self.Z - Point.Z));
end;

class operator TFloatPoint3D.Equal(const Lhs, Rhs: TFloatPoint3D): Boolean;
begin
  Result := (Lhs.X = Rhs.X) and (Lhs.Y = Rhs.Y) and (Lhs.Z = Rhs.Z);
end;

function TFloatPoint3D.IsZero: Boolean;
begin
  Result := Math.IsZero(X) and Math.IsZero(Y) and Math.IsZero(Z);
end;

class operator TFloatPoint3D.NotEqual(const Lhs, Rhs: TFloatPoint3D): Boolean;
begin
  Result := (Lhs.X <> Rhs.X) or (Lhs.Y <> Rhs.Y) or (Lhs.Z <> Rhs.Z);
end;

procedure TFloatPoint3D.Subtract(const Point: TFloatPoint3D);
begin
  X := X - Point.X;
  Y := Y - Point.Y;
  Z := Z - Point.Z;
end;

class operator TFloatPoint3D.Subtract(const Lhs, Rhs: TFloatPoint3D)
  : TFloatPoint3D;
begin
  Result := FloatPoint3D(Lhs.X - Rhs.X, Lhs.Y - Rhs.Y, Lhs.Z - Rhs.Z);
end;

end.
