unit clipperfloat;

(* float version of the unit clipper by Alex Vergara Gil
  * ******************************************************************************
  * Original                                                                     *
  * Author    :  Angus Johnson                                                   *
  * Version   :  4.9.7                                                           *
  * Date      :  29 November 2012                                                *
  * Website   :  http://www.angusj.com                                           *
  * Copyright :  Angus Johnson 2010-2012                                         *
  *                                                                              *
  * License:                                                                     *
  * Use, modification & distribution is subject to Boost Software License Ver 1. *
  * http://www.boost.org/LICENSE_1_0.txt                                         *
  *                                                                              *
  * Attributions:                                                                *
  * The code in this library is an extension of Bala Vatti's clipping algorithm: *
  * "A generic solution to polygon clipping"                                     *
  * Communications of the ACM, Vol 35, Issue 7 (July 1992) PP 56-63.             *
  * http://portal.acm.org/citation.cfm?id=129906                                 *
  *                                                                              *
  * Computer graphics and geometric modeling: implementation and algorithms      *
  * By Max K. Agoston                                                            *
  * Springer; 1 edition (January 4, 2005)                                        *
  * http://books.google.com/books?q=vatti+clipping+agoston                       *
  *                                                                              *
  * See also:                                                                    *
  * "Polygon Offsetting by Computing Winding Numbers"                            *
  * Paper no. DETC2005-85513 PP. 565-575                                         *
  * ASME 2005 International Design Engineering Technical Conferences             *
  * and Computers and Information in Engineering Conference (IDETC/CIE2005)      *
  * September 24–28, 2005 , Long Beach, California, USA                          *
  * http://www.me.berkeley.edu/~mcmains/pubs/DAC05OffsetPolygon.pdf              *
  *                                                                              *
  ****************************************************************************** *)

interface

uses
  SysUtils, Types, Classes, Math, uconstants, uBaseGeometry;

type
  TClipType = (ctIntersection, ctUnion, ctDifference, ctXor);
  TPolyType = (ptSubject, ptClip);
  // By far the most widely used winding rules for polygon filling are
  // EvenOdd & NonZero (GDI, GDI+, XLib, OpenGL, Cairo, AGG, Quartz, SVG, Gr32)
  // Others rules include Positive, Negative and ABS_GTR_EQ_TWO (only in OpenGL)
  // see http://glprogramming.com/red/chapter11.html
  TPolyFillType = (pftEvenOdd, pftNonZero, pftPositive, pftNegative);

  // TJoinType - used by OffsetPolygons()
  TJoinType = (jtSquare, jtRound, jtMiter);

  // used internally ...
  TEdgeSide = (esLeft, esRight);
  TEdgeSides = set of TEdgeSide;
  TIntersectProtect = (ipLeft, ipRight);
  TIntersectProtects = set of TIntersectProtect;
  TDirection = (dRightToLeft, dLeftToRight);
  TFloatPolygon = array of TFloatPoint;
  TFloatPolygons = array of TFloatPolygon;

  PEdge = ^TEdge;

  TEdge = record
    XBot: float; // bottom
    YBot: float;
    XCurr: float; // current (ie relative to bottom of current scanbeam)
    YCurr: float;
    XTop: float; // top
    YTop: float;
    TmpX: float;
    Dx: double; // the inverse of slope
    DeltaX: float;
    DeltaY: float;
    PolyType: TPolyType;
    Side: TEdgeSide;
    WindDelta: Integer; // 1 or -1 depending on winding direction
    WindCnt: Integer;
    WindCnt2: Integer; // winding count of the opposite PolyType
    OutIdx: Integer;
    Next: PEdge;
    Prev: PEdge;
    NextInLML: PEdge;
    PrevInAEL: PEdge;
    NextInAEL: PEdge;
    PrevInSEL: PEdge;
    NextInSEL: PEdge;
  end;

  PEdgeArray = ^TEdgeArray;
  TEdgeArray = array [0 .. MaxInt div sizeof(TEdge) - 1] of TEdge;

  PScanbeam = ^TScanbeam;

  TScanbeam = record
    Y: float;
    Next: PScanbeam;
  end;

  PIntersectNode = ^TIntersectNode;

  TIntersectNode = record
    Edge1: PEdge;
    Edge2: PEdge;
    Pt: TFloatPoint;
    Next: PIntersectNode;
  end;

  PLocalMinima = ^TLocalMinima;

  TLocalMinima = record
    Y: float;
    LeftBound: PEdge;
    RightBound: PEdge;
    Next: PLocalMinima;
  end;

  POutPt = ^TOutPt;

  POutRec = ^TOutRec;

  TOutRec = record
    Idx: Integer;
    BottomPt: POutPt;
    IsHole: Boolean;
    FirstLeft: POutRec;
    AppendLink: POutRec;
    Pts: POutPt;
    Sides: TEdgeSides;
    BottomFlag: POutPt;
  end;

  TArrayOfOutRec = array of POutRec;

  TOutPt = record
    Idx: Integer;
    Pt: TFloatPoint;
    Next: POutPt;
    Prev: POutPt;
  end;

  TExPolygon = record
    Outer: TFloatPolygon;
    Holes: TFloatPolygons;
  end;

  TExPolygons = array of TExPolygon;

  PJoinRec = ^TJoinRec;

  TJoinRec = record
    Pt1a: TFloatPoint;
    Pt1b: TFloatPoint;
    Poly1Idx: Integer;
    Pt2a: TFloatPoint;
    Pt2b: TFloatPoint;
    Poly2Idx: Integer;
  end;

  PHorzRec = ^THorzRec;

  THorzRec = record
    Edge: PEdge;
    SavedIdx: Integer;
    Next: PHorzRec;
    Prev: PHorzRec;
  end;

  TClipperBase = class // (TThread)
  private
    FEdgeList: TList;
    FLmList: PLocalMinima; // localMinima list
    FCurrLm: PLocalMinima; // current localMinima node
    FUseFullBitRange: Boolean; // see LoRange const note below
    procedure DisposeLocalMinimaList;
  protected
    procedure Reset; virtual;
    procedure PopLocalMinima;
    property CurrentLm: PLocalMinima read FCurrLm;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function AddPolygon(const polygon: TFloatPolygon;
      PolyType: TPolyType): Boolean;
    function AddPolygons(const polygons: TFloatPolygons;
      PolyType: TPolyType): Boolean;
    procedure Clear; virtual;
  end;

  TClipper = class(TClipperBase)
  private
    FPolyOutList: TList;
    FJoinList: TList;
    FClipType: TClipType;
    FScanbeam: PScanbeam; // scanbeam list
    FActiveEdges: PEdge; // active Edge list
    FSortedEdges: PEdge; // used for temporary sorting
    FIntersectNodes: PIntersectNode;
    FClipFillType: TPolyFillType;
    FSubjFillType: TPolyFillType;
    FExecuteLocked: Boolean;
    FHorizJoins: PHorzRec;
    FReverseOutput: Boolean;
    procedure DisposeScanbeamList;
    procedure InsertScanbeam(const Y: float);
    function PopScanbeam: float;
    procedure SetWindingCount(Edge: PEdge);
    function IsEvenOddFillType(Edge: PEdge): Boolean;
    function IsEvenOddAltFillType(Edge: PEdge): Boolean;
    procedure AddEdgeToSEL(Edge: PEdge);
    procedure CopyAELToSEL;
    procedure InsertLocalMinimaIntoAEL(const BotY: float);
    procedure SwapPositionsInAEL(E1, E2: PEdge);
    procedure SwapPositionsInSEL(E1, E2: PEdge);
    function IsTopHorz(const XPos: float): Boolean;
    procedure ProcessHorizontal(HorzEdge: PEdge);
    procedure ProcessHorizontals;
    procedure AddIntersectNode(E1, E2: PEdge; const Pt: TFloatPoint);
    function ProcessIntersections(const BotY, TopY: float): Boolean;
    procedure BuildIntersectList(const BotY, TopY: float);
    procedure ProcessIntersectList;
    procedure DeleteFromAEL(E: PEdge);
    procedure DeleteFromSEL(E: PEdge);
    procedure IntersectEdges(E1, E2: PEdge; const Pt: TFloatPoint;
      protects: TIntersectProtects = []);
    procedure DoMaxima(E: PEdge; const TopY: float);
    procedure UpdateEdgeIntoAEL(var E: PEdge);
    function FixupIntersections: Boolean;
    procedure SwapIntersectNodes(Int1, Int2: PIntersectNode);
    procedure ProcessEdgesAtTopOfScanbeam(const TopY: float);
    function IsContributing(Edge: PEdge): Boolean;
    function CreateOutRec: POutRec;
    procedure AddOutPt(E: PEdge; const Pt: TFloatPoint);
    procedure AddLocalMaxPoly(E1, E2: PEdge; const Pt: TFloatPoint);
    procedure AddLocalMinPoly(E1, E2: PEdge; const Pt: TFloatPoint);
    procedure AppendPolygon(E1, E2: PEdge);
    procedure DisposeBottomPt(OutRec: POutRec);
    procedure DisposePolyPts(PP: POutPt);
    procedure DisposeAllPolyPts;
    procedure DisposeOutRec(Index: Integer);
    procedure DisposeIntersectNodes;
    function GetResult: TFloatPolygons;
    function GetExResult: TExPolygons;
    procedure FixupOutPolygon(OutRec: POutRec);
    procedure SetHoleState(E: PEdge; OutRec: POutRec);
    procedure AddJoin(E1, E2: PEdge; E1OutIdx: Integer = -1;
      E2OutIdx: Integer = -1);
    procedure ClearJoins;
    procedure AddHorzJoin(E: PEdge; Idx: Integer);
    procedure ClearHorzJoins;
    function JoinPoints(JR: PJoinRec; out P1, P2: POutPt): Boolean;
    procedure FixupJoinRecs(JR: PJoinRec; Pt: POutPt; StartIdx: Integer);
    procedure JoinCommonEdges(FixHoleLinkages: Boolean);
    procedure FixHoleLinkage(OutRec: POutRec);
  protected
    procedure Reset; override;
    function ExecuteInternal(FixHoleLinkages: Boolean): Boolean; virtual;
  public
    function Execute(clipType: TClipType; out solution: TFloatPolygons;
      subjFillType: TPolyFillType = pftEvenOdd;
      clipFillType: TPolyFillType = pftEvenOdd): Boolean; overload;
    function Execute(clipType: TClipType; out solution: TExPolygons;
      subjFillType: TPolyFillType = pftEvenOdd;
      clipFillType: TPolyFillType = pftEvenOdd): Boolean; overload;
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear; override;
    // ReverseSolution: reverses the default orientation
    property ReverseSolution: Boolean read FReverseOutput write FReverseOutput;
  end;

function Orientation(const Pts: TFloatPolygon): Boolean; overload;
function Area(const Pts: TFloatPolygon): double; overload;
function Area(const Pts: TFloatPolygon; out Center: TFloatPoint)
  : double; overload;
function ReversePolygon(const Pts: TFloatPolygon): TFloatPolygon;
function ReversePolygons(const Pts: TFloatPolygons): TFloatPolygons;

procedure ClearPolygons(var polygons: TFloatPolygons);

// OffsetPolygons precondition: outer polygons MUST be oriented clockwise,
// and inner 'hole' polygons must be oriented counter-clockwise ...
function OffsetPolygons(const Polys: TFloatPolygons; const Delta: double;
  JoinType: TJoinType = jtSquare; MiterLimit: double = 2;
  ChecksInput: Boolean = true): TFloatPolygons;

// SimplifyPolygon converts a self-intersecting polygon into a simple polygon.
function SimplifyPolygon(const poly: TFloatPolygon;
  FillType: TPolyFillType = pftEvenOdd): TFloatPolygons;
function SimplifyPolygons(const Polys: TFloatPolygons;
  FillType: TPolyFillType = pftEvenOdd): TFloatPolygons;

implementation

type
  TArrayOfDoublePoint = array of TFloatPoint;

const
  Horizontal: double = -1E+308;
  // Cross-Product (see Orientation) places the most limits on coordinate values
  // So, to avoid overflow errors, they must not exceed the following value...
  LoRange: float = 1E154; // sqrt(1.7e308)
  HiRange: float = 1E308; // sqr(LoRange)

resourcestring
  rsMissingRightbound = 'InsertLocalMinimaIntoAEL: missing RightBound';
  rsDoMaxima = 'DoMaxima error';
  rsUpdateEdgeIntoAEL = 'UpdateEdgeIntoAEL error';
  rsHorizontal = 'ProcessHorizontal error';
  rsInvalidFloat = 'Coordinate exceeds range bounds';
  rsJoinError = 'Join Output polygons error';
  rsHoleLinkError = 'HoleLinkage error';

  // ------------------------------------------------------------------------------
  // Miscellaneous Functions ...
  // ------------------------------------------------------------------------------

function FullRangeNeeded(const Pts: TFloatPolygon): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to high(Pts) do
  begin
    if (abs(Pts[I].X) > LoRange) or (abs(Pts[I].Y) > LoRange) then
    begin
      Result := true;
      exit;
    end;
  end;
end;
// ------------------------------------------------------------------------------

function PointCount(Pts: POutPt): Integer;
var
  P: POutPt;
begin
  Result := 0;
  if not assigned(Pts) then
    exit;
  P := Pts;
  repeat
    inc(Result);
    P := P.Next;
  until P = Pts;
end;
// ------------------------------------------------------------------------------

function Orientation(const Pts: TFloatPolygon): Boolean;
var
  I, J, JPlus, JMinus, HighI: Integer;
  Vec1, Vec2: TFloatPoint;
  Cross: extended;
begin
  Result := true;
  HighI := high(Pts);
  if HighI < 2 then
    exit;
  J := 0;
  for I := 0 to HighI do
  begin
    if (Pts[I].Y < Pts[J].Y) then
      Continue;
    if ((Pts[I].Y > Pts[J].Y) or (Pts[I].X < Pts[J].X)) then
      J := I;
  end;
  if J = HighI then
    JPlus := 0
  else
    JPlus := J + 1;
  if J = 0 then
    JMinus := HighI
  else
    JMinus := J - 1;

  // get cross product of vectors of edges adjacent the point with largest Y ...
  Vec1.X := Pts[J].X - Pts[JMinus].X;
  Vec1.Y := Pts[J].Y - Pts[JMinus].Y;
  Vec2.X := Pts[JPlus].X - Pts[J].X;
  Vec2.Y := Pts[JPlus].Y - Pts[J].Y;

  if (abs(Vec1.X) > LoRange) or (abs(Vec1.Y) > LoRange) or
    (abs(Vec2.X) > LoRange) or (abs(Vec2.Y) > LoRange) then
  begin
    Cross := ((Vec1.X * Vec2.Y) - (Vec2.X * Vec1.Y));
    Result := Cross >= 0;
  end
  else
    Result := ((Vec1.X * Vec2.Y) - (Vec2.X * Vec1.Y)) >= 0;
end;
// ------------------------------------------------------------------------------

function Orientation(OutRec: POutRec; UseFullFloatRange: Boolean)
  : Boolean; overload;
var
  Op, OpBottom, OpPrev, OpNext: POutPt;
  Vec1, Vec2: TFloatPoint;
  Cross: extended;
begin
  // first make sure BottomPt is correctly assigned ...
  OpBottom := OutRec.Pts;
  if not assigned(OpBottom) then
  begin
    Result := true;
    exit;
  end;
  Op := OpBottom.Next;
  while Op <> OutRec.Pts do
  begin
    if Op.Pt.Y >= OpBottom.Pt.Y then
    begin
      if (Op.Pt.Y > OpBottom.Pt.Y) or (Op.Pt.X < OpBottom.Pt.X) then
        OpBottom := Op;
    end;
    Op := Op.Next;
  end;
  OutRec.BottomPt := OpBottom;
  OpBottom.Idx := OutRec.Idx;
  Op := OpBottom;

  // find vertices either Side of BottomPt (skipping duplicate points) ....
  OpPrev := Op.Prev;
  while (Op <> OpPrev) and PointsEqual(Op.Pt, OpPrev.Pt) do
    OpPrev := OpPrev.Prev;
  OpNext := Op.Next;
  while (Op <> OpNext) and PointsEqual(Op.Pt, OpNext.Pt) do
    OpNext := OpNext.Next;

  Vec1.X := Op.Pt.X - OpPrev.Pt.X;
  Vec1.Y := Op.Pt.Y - OpPrev.Pt.Y;
  Vec2.X := OpNext.Pt.X - Op.Pt.X;
  Vec2.Y := OpNext.Pt.Y - Op.Pt.Y;

  // perform cross product to determine left or right 'turning' ...
  if UseFullFloatRange then
  begin
    Cross := ((Vec1.X * Vec2.Y) - (Vec2.X * Vec1.Y));
    Result := Cross >= 0;
  end
  else
    Result := ((Vec1.X * Vec2.Y) - (Vec2.X * Vec1.Y)) >= 0;

end;
// ------------------------------------------------------------------------------

function Area(const Pts: TFloatPolygon): double; overload;
var
  I, HighI: Integer;
  A: extended;
  D: double;
begin
  Result := 0;
  HighI := high(Pts);
  if HighI < 2 then
    exit;
  if FullRangeNeeded(Pts) then
  begin
    A := Pts[HighI].X * Pts[0].Y - Pts[0].X * Pts[HighI].Y;
    for I := 1 to HighI do
      A := A + (Pts[I - 1].X * Pts[I].Y) - (Pts[I].X * Pts[I - 1].Y);
    Result := A / 2;
  end
  else
  begin
    D := Pts[HighI].X * Pts[0].Y - Pts[0].X * Pts[HighI].Y;
    for I := 1 to HighI do
      D := D + (Pts[I - 1].X * Pts[I].Y) - (Pts[I].X * Pts[I - 1].Y);
    Result := D / 2;
  end;
end;

function Area(const Pts: TFloatPolygon; out Center: TFloatPoint)
  : double; overload;
var
  I, HighI: Integer;
  tA, A, resX128, resY128: extended;
  D, resX, resy, temp: double;
begin
  Result := 0;
  HighI := high(Pts);
  if HighI < 2 then
    exit;
  if FullRangeNeeded(Pts) then
  begin
    A := (Pts[HighI].X * Pts[0].Y) - (Pts[0].X * Pts[HighI].Y);
    resX128 := A * (Pts[HighI].X + Pts[0].X);
    resY128 := A * (Pts[HighI].Y + Pts[0].Y);
    for I := 1 to HighI do
    begin
      tA := (Pts[I - 1].X * Pts[I].Y) - (Pts[I].X * Pts[I - 1].Y);
      A := A + tA;
      resX128 := resX128 + tA * (Pts[I - 1].X + Pts[I].X);
      resY128 := resY128 + tA * (Pts[I - 1].Y + Pts[I].Y);
    end;
    Result := A / 2;
    tA := 1 / (3 * A);
    Center := FloatPoint(resX128 * tA, resY128 * tA);
  end
  else
  begin
    D := (Pts[HighI].X * Pts[0].Y) - (Pts[0].X * Pts[HighI].Y);
    resX := D * (Pts[HighI].X + Pts[0].X);
    resy := D * (Pts[HighI].Y + Pts[0].Y);
    for I := 1 to HighI do
    begin
      temp := (Pts[I - 1].X * Pts[I].Y) - (Pts[I].X * Pts[I - 1].Y);
      D := D + temp;
      resX := resX + temp * (Pts[I - 1].X + Pts[I].X);
      resy := resy + temp * (Pts[I - 1].Y + Pts[I].Y);
    end;
    Result := D / 2;
    temp := 1 / (3 * D);
    Center := FloatPoint(resX * temp, resy * temp);
  end;
end;
// ------------------------------------------------------------------------------

function Area(OutRec: POutRec; UseFullFloatRange: Boolean): double; overload;
var
  Op: POutPt;
  D: double;
  A: extended;
begin
  Op := OutRec.Pts;
  if not assigned(Op) then
  begin
    Result := 0;
    exit;
  end;
  if UseFullFloatRange then
  begin
    A := 0;
    repeat
      A := A + (Op.Pt.X * Op.Next.Pt.Y) - (Op.Next.Pt.X * Op.Pt.Y);
      Op := Op.Next;
    until Op = OutRec.Pts;
    Result := A / 2;
  end
  else
  begin
    D := 0;
    repeat
      D := D + (Op.Pt.X * Op.Next.Pt.Y) - (Op.Next.Pt.X * Op.Pt.Y);
      Op := Op.Next;
    until Op = OutRec.Pts;
    Result := D / 2;
  end;
end;
// ------------------------------------------------------------------------------

function ReversePolygon(const Pts: TFloatPolygon): TFloatPolygon;
var
  I, HighI: Integer;
begin
  HighI := high(Pts);
  SetLength(Result, HighI + 1);
  for I := 0 to HighI do
    Result[I] := Pts[HighI - I];
end;
// ------------------------------------------------------------------------------

function ReversePolygons(const Pts: TFloatPolygons): TFloatPolygons;
var
  I, J, highJ: Integer;
begin
  I := length(Pts);
  SetLength(Result, I);
  for I := 0 to I - 1 do
  begin
    highJ := high(Pts[I]);
    SetLength(Result[I], highJ + 1);
    for J := 0 to highJ do
      Result[I][J] := Pts[I][highJ - J];
  end;
end;
// ------------------------------------------------------------------------------

function PointIsVertex(const Pt: TFloatPoint; PP: POutPt): Boolean;
var
  Pp2: POutPt;
begin
  Result := true;
  Pp2 := PP;
  repeat
    if PointsEqual(Pp2.Pt, Pt) then
      exit;
    Pp2 := Pp2.Next;
  until Pp2 = PP;
  Result := False;
end;
// ------------------------------------------------------------------------------

function PointInPolygon(const Pt: TFloatPoint; PP: POutPt;
  UseFullFloatRange: Boolean): Boolean;
var
  Pp2: POutPt;
  A, B: extended;
begin
  Result := False;
  Pp2 := PP;
  if UseFullFloatRange then
  begin
    repeat
      if (((Pp2.Pt.Y <= Pt.Y) and (Pt.Y < Pp2.Prev.Pt.Y)) or
        ((Pp2.Prev.Pt.Y <= Pt.Y) and (Pt.Y < Pp2.Pt.Y))) then
      begin
        A := (Pt.X - Pp2.Pt.X);
        B := ((Pp2.Prev.Pt.X - Pp2.Pt.X) * (Pt.Y - Pp2.Pt.Y) /
          (Pp2.Prev.Pt.Y - Pp2.Pt.Y));
        if (A < B) then
          Result := not Result;
      end;
      Pp2 := Pp2.Next;
    until Pp2 = PP;
  end
  else
  begin
    repeat
      if ((((Pp2.Pt.Y <= Pt.Y) and (Pt.Y < Pp2.Prev.Pt.Y)) or
        ((Pp2.Prev.Pt.Y <= Pt.Y) and (Pt.Y < Pp2.Pt.Y))) and
        (Pt.X < (Pp2.Prev.Pt.X - Pp2.Pt.X) * (Pt.Y - Pp2.Pt.Y) /
        (Pp2.Prev.Pt.Y - Pp2.Pt.Y) + Pp2.Pt.X)) then
        Result := not Result;
      Pp2 := Pp2.Next;
    until Pp2 = PP;
  end;
end;
// ------------------------------------------------------------------------------

function SlopesEqual(E1, E2: PEdge; UseFullFloatRange: Boolean)
  : Boolean; overload;
begin
  if UseFullFloatRange then
    Result := IsZero(E1.DeltaY * E2.DeltaX - E1.DeltaX * E2.DeltaY)
  else
    Result := E1.DeltaY * E2.DeltaX = E1.DeltaX * E2.DeltaY;
end;
// ---------------------------------------------------------------------------

function SlopesEqual(const Pt1, Pt2, Pt3: TFloatPoint;
  UseFullFloatRange: Boolean): Boolean; overload;
begin
  if UseFullFloatRange then
    Result := IsZero(((Pt1.Y - Pt2.Y) * (Pt2.X - Pt3.X)) -
      ((Pt1.X - Pt2.X) * (Pt2.Y - Pt3.Y)))
  else
    Result := (Pt1.Y - Pt2.Y) * (Pt2.X - Pt3.X) = (Pt1.X - Pt2.X) *
      (Pt2.Y - Pt3.Y);
end;
// ---------------------------------------------------------------------------

function SlopesEqual(const Pt1, Pt2, Pt3, Pt4: TFloatPoint;
  UseFullFloatRange: Boolean): Boolean; overload;
begin
  if UseFullFloatRange then
    Result := IsZero(((Pt1.Y - Pt2.Y) * (Pt3.X - Pt4.X)) -
      ((Pt1.X - Pt2.X) * (Pt3.Y - Pt4.Y)))
  else
    Result := (Pt1.Y - Pt2.Y) * (Pt3.X - Pt4.X) = (Pt1.X - Pt2.X) *
      (Pt3.Y - Pt4.Y);
end;
// ---------------------------------------------------------------------------

// 0(90º)                                                  //
// |                                                       //
// +inf (180º) --- o --- -inf (0º)                                         //
function GetDx(const Pt1, Pt2: TFloatPoint): double;
begin
  if (Pt1.Y = Pt2.Y) then
    Result := Horizontal
  else
    Result := (Pt2.X - Pt1.X) / (Pt2.Y - Pt1.Y);
end;
// ---------------------------------------------------------------------------

procedure SetDx(E: PEdge);
begin
  E.DeltaX := (E.XTop - E.XBot);
  E.DeltaY := (E.YTop - E.YBot);
  if E.DeltaY = 0 then
    E.Dx := Horizontal
  else
    E.Dx := E.DeltaX / E.DeltaY;
end;
// ---------------------------------------------------------------------------

procedure SwapSides(Edge1, Edge2: PEdge);
var
  Side: TEdgeSide;
begin
  Side := Edge1.Side;
  Edge1.Side := Edge2.Side;
  Edge2.Side := Side;
end;
// ------------------------------------------------------------------------------

procedure SwapPolyIndexes(Edge1, Edge2: PEdge);
var
  OutIdx: Integer;
begin
  OutIdx := Edge1.OutIdx;
  Edge1.OutIdx := Edge2.OutIdx;
  Edge2.OutIdx := OutIdx;
end;
// ------------------------------------------------------------------------------

function TopX(Edge: PEdge; const currentY: float): float; overload;
begin
  if currentY = Edge.YTop then
    Result := Edge.XTop
  else if Edge.XTop = Edge.XBot then
    Result := Edge.XBot
  else
    Result := Edge.XBot + round(Edge.Dx * (currentY - Edge.YBot));
end;
// ------------------------------------------------------------------------------

function IntersectPoint(Edge1, Edge2: PEdge; out ip: TFloatPoint;
  UseFullFloatRange: Boolean): Boolean; overload;
var
  B1, B2, M: double;
begin
  if SlopesEqual(Edge1, Edge2, UseFullFloatRange) then
  begin
    Result := False;
    exit;
  end;
  if Edge1.Dx = 0 then
  begin
    ip.X := Edge1.XBot;
    if Edge2.Dx = Horizontal then
      ip.Y := Edge2.YBot
    else
    begin
      with Edge2^ do
        B2 := YBot - (XBot / Dx);
      ip.Y := round(ip.X / Edge2.Dx + B2);
    end;
  end
  else if Edge2.Dx = 0 then
  begin
    ip.X := Edge2.XBot;
    if Edge1.Dx = Horizontal then
      ip.Y := Edge1.YBot
    else
    begin
      with Edge1^ do
        B1 := YBot - (XBot / Dx);
      ip.Y := round(ip.X / Edge1.Dx + B1);
    end;
  end
  else
  begin
    with Edge1^ do
      B1 := XBot - YBot * Dx;
    with Edge2^ do
      B2 := XBot - YBot * Dx;
    M := (B2 - B1) / (Edge1.Dx - Edge2.Dx);
    ip.Y := round(M);
    if abs(Edge1.Dx) < abs(Edge2.Dx) then
      ip.X := round(Edge1.Dx * M + B1)
    else
      ip.X := round(Edge2.Dx * M + B2);
  end;

  // The precondition - E.TmpX > eNext.TmpX - indicates that the two edges do
  // intersect below TopY (and hence below the tops of either Edge). However,
  // when edges are almost parallel, rounding errors may cause False positives -
  // indicating intersections when there really aren't any. Also, floating point
  // imprecision can incorrectly place an intersect point beyond/above an Edge.
  // Therfore, further validation of the IP is warranted ...
  if (ip.Y < Edge1.YTop) or (ip.Y < Edge2.YTop) then
  begin
    // Find the lower top of the two edges and compare X's at this Y.
    // If Edge1's X is greater than Edge2's X then it's fair to assume an
    // intersection really has occurred...
    if (Edge1.YTop > Edge2.YTop) then
    begin
      Result := TopX(Edge2, Edge1.YTop) < Edge1.XTop;
      ip.X := Edge1.XTop;
      ip.Y := Edge1.YTop;
    end
    else
    begin
      Result := TopX(Edge1, Edge2.YTop) > Edge2.XTop;
      ip.X := Edge2.XTop;
      ip.Y := Edge2.YTop;
    end;
  end
  else
    Result := true;
end;
// ------------------------------------------------------------------------------

procedure ReversePolyPtLinks(PP: POutPt);
var
  Pp1, Pp2: POutPt;
begin
  if not assigned(PP) then
    exit;
  Pp1 := PP;
  repeat
    Pp2 := Pp1.Next;
    Pp1.Next := Pp1.Prev;
    Pp1.Prev := Pp2;
    Pp1 := Pp2;
  until Pp1 = PP;
end;

// ------------------------------------------------------------------------------
// TClipperBase methods ...
// ------------------------------------------------------------------------------

constructor TClipperBase.Create;
begin
  FEdgeList := TList.Create;
  FLmList := nil;
  FCurrLm := nil;
  FUseFullBitRange := False; // ie default is False
end;
// ------------------------------------------------------------------------------

destructor TClipperBase.Destroy;
begin
  Clear;
  FEdgeList.Free;
  inherited;
end;
// ------------------------------------------------------------------------------

function TClipperBase.AddPolygon(const polygon: TFloatPolygon;
  PolyType: TPolyType): Boolean;

// ----------------------------------------------------------------------

  procedure InitEdge(E, eNext, ePrev: PEdge; const Pt: TFloatPoint);
  begin
    fillChar(E^, sizeof(TEdge), 0);
    E.Next := eNext;
    E.Prev := ePrev;
    E.XCurr := Pt.X;
    E.YCurr := Pt.Y;
    if E.YCurr >= E.Next.YCurr then
    begin
      E.XBot := E.XCurr;
      E.YBot := E.YCurr;
      E.XTop := E.Next.XCurr;
      E.YTop := E.Next.YCurr;
      E.WindDelta := 1;
    end
    else
    begin
      E.XTop := E.XCurr;
      E.YTop := E.YCurr;
      E.XBot := E.Next.XCurr;
      E.YBot := E.Next.YCurr;
      E.WindDelta := -1;
    end;
    SetDx(E);
    E.PolyType := PolyType;
    E.OutIdx := -1;
  end;
// ----------------------------------------------------------------------

  procedure SwapX(E: PEdge);
  begin
    // swap horizontal edges' top and bottom x's so they follow the natural
    // progression of the bounds - ie so their xbots will align with the
    // adjoining lower Edge. [Helpful in the ProcessHorizontal() method.]
    E.XCurr := E.XTop;
    E.XTop := E.XBot;
    E.XBot := E.XCurr;
  end;
// ----------------------------------------------------------------------

  procedure InsertLocalMinima(lm: PLocalMinima);
  var
    TmpLm: PLocalMinima;
  begin
    if not assigned(FLmList) then
    begin
      FLmList := lm;
    end
    else if (lm.Y >= FLmList.Y) then
    begin
      lm.Next := FLmList;
      FLmList := lm;
    end
    else
    begin
      TmpLm := FLmList;
      while assigned(TmpLm.Next) and (lm.Y < TmpLm.Next.Y) do
        TmpLm := TmpLm.Next;
      lm.Next := TmpLm.Next;
      TmpLm.Next := lm;
    end;
  end;
// ----------------------------------------------------------------------

  function AddBoundsToLML(E: PEdge): PEdge;
  var
    NewLm: PLocalMinima;
  begin
    // Starting at the top of one bound we progress to the bottom where there's
    // A local minima. We then go to the top of the Next bound. These two bounds
    // form the left and right (or right and left) bounds of the local minima.
    E.NextInLML := nil;
    E := E.Next;
    repeat
      if E.Dx = Horizontal then
      begin
        // nb: proceed through horizontals when approaching from their right,
        // but break on horizontal minima if approaching from their left.
        // This ensures 'local minima' are always on the left of horizontals.
        if (E.Next.YTop < E.YTop) and (E.Next.XBot > E.Prev.XBot) then
          break;
        if (E.XTop <> E.Prev.XBot) then
          SwapX(E);
        // E.WindDelta := 0; safe option to consider when redesigning
        E.NextInLML := E.Prev;
      end
      else if (E.YBot = E.Prev.YBot) then
        break
      else
        E.NextInLML := E.Prev;
      E := E.Next;
    until False;

    // E and E.Prev are now at a local minima ...
    new(NewLm);
    NewLm.Y := E.Prev.YBot;
    NewLm.Next := nil;
    if E.Dx = Horizontal then // Horizontal edges never start a left bound
    begin
      if (E.XBot <> E.Prev.XBot) then
        SwapX(E);
      NewLm.LeftBound := E.Prev;
      NewLm.RightBound := E;
    end
    else if (E.Dx < E.Prev.Dx) then
    begin
      NewLm.LeftBound := E.Prev;
      NewLm.RightBound := E;
    end
    else
    begin
      NewLm.LeftBound := E;
      NewLm.RightBound := E.Prev;
    end;
    NewLm.LeftBound.Side := esLeft;
    NewLm.RightBound.Side := esRight;

    InsertLocalMinima(NewLm);
    // now process the ascending bound ....
    repeat
      if (E.Next.YTop = E.YTop) and not(E.Next.Dx = Horizontal) then
        break;
      E.NextInLML := E.Next;
      E := E.Next;
      if (E.Dx = Horizontal) and (E.XBot <> E.Prev.XTop) then
        SwapX(E);
    until False;
    Result := E.Next;
  end;
// ----------------------------------------------------------------------

var
  I, J, len: Integer;
  Edges: PEdgeArray;
  E, EHighest: PEdge;
  Pg: TFloatPolygon;
begin
  { AddPolygon }
  Result := False; // ie assume nothing added
  len := length(polygon);
  if len < 3 then
    exit;
  SetLength(Pg, len);
  Pg[0] := polygon[0];
  J := 0;
  // 1. check that coordinate values are within the valid range, and
  // 2. remove duplicate points and co-linear points
  for I := 1 to len - 1 do
  begin
    if ((abs(polygon[I].X) > LoRange) or (abs(polygon[I].Y) > LoRange)) then
    begin
      FUseFullBitRange := true;
    end;
    if (Pg[J] = polygon[I]) then
      Continue
    else if (J > 0) and SlopesEqual(Pg[J - 1], Pg[J], polygon[I],
      FUseFullBitRange) then
    begin
      if (Pg[J - 1] = polygon[I]) then
        dec(J);
    end
    else
      inc(J);
    Pg[J] := polygon[I];
  end;
  if (J < 2) then
    exit;

  // now remove duplicate points and co-linear edges at the loop around of the
  // start and end coordinates ...
  len := J + 1;
  while len > 2 do
  begin
    // nb: test for point equality before testing slopes ...
    if (Pg[J] = Pg[0]) then
      dec(J)
    else if (Pg[0] = Pg[1]) or SlopesEqual(Pg[J], Pg[0], Pg[1],
      FUseFullBitRange) then
    begin
      Pg[0] := Pg[J];
      dec(J);
    end
    else if SlopesEqual(Pg[J - 1], Pg[J], Pg[0], FUseFullBitRange) then
      dec(J)
    else if SlopesEqual(Pg[0], Pg[1], Pg[2], FUseFullBitRange) then
    begin
      for I := 2 to J do
        Pg[I - 1] := Pg[I];
      dec(J);
    end
    else
      break;
    dec(len);
  end;
  if len < 3 then
    exit;
  Result := true;

  GetMem(Edges, sizeof(TEdge) * len);
  FEdgeList.Add(Edges);

  // convert vertices to a Double-linked-list of edges and initialize ...
  Edges[0].XCurr := Pg[0].X;
  Edges[0].YCurr := Pg[0].Y;
  InitEdge(@Edges[len - 1], @Edges[0], @Edges[len - 2], Pg[len - 1]);
  for I := len - 2 downto 1 do
    InitEdge(@Edges[I], @Edges[I + 1], @Edges[I - 1], Pg[I]);
  InitEdge(@Edges[0], @Edges[1], @Edges[len - 1], Pg[0]);
  Finalize(Pg);
  // reset XCurr & YCurr and find the 'highest' Edge. (nb: since I'm much more
  // familiar with positive downwards Y axes, 'highest' here will be the Edge
  // with the *smallest* YTop.)
  E := @Edges[0];
  EHighest := E;
  repeat
    E.XCurr := E.XBot;
    E.YCurr := E.YBot;
    if E.YTop < EHighest.YTop then
      EHighest := E;
    E := E.Next;
  until E = @Edges[0];

  // make sure eHighest is positioned so the following loop works safely ...
  if EHighest.WindDelta > 0 then
    EHighest := EHighest.Next;
  if (EHighest.Dx = Horizontal) then
    EHighest := EHighest.Next;

  // finally insert each local minima ...
  E := EHighest;
  repeat
    E := AddBoundsToLML(E);
  until (E = EHighest);
  Finalize(Edges^);
end;
// ------------------------------------------------------------------------------

function TClipperBase.AddPolygons(const polygons: TFloatPolygons;
  PolyType: TPolyType): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to high(polygons) do
    if AddPolygon(polygons[I], PolyType) then
      Result := true;
end;
// ------------------------------------------------------------------------------

procedure TClipperBase.Clear;
var
  I: Integer;
begin
  DisposeLocalMinimaList;
  for I := 0 to FEdgeList.Count - 1 do
    dispose(PEdgeArray(FEdgeList[I]));
  FEdgeList.Clear;
  FUseFullBitRange := False;
end;
// ------------------------------------------------------------------------------

procedure TClipperBase.Reset;
var
  E: PEdge;
  lm: PLocalMinima;
begin
  // Reset() allows various clipping operations to be executed
  // multiple times on the same polygon sets.

  FCurrLm := FLmList;
  // reset all edges ...
  lm := FCurrLm;
  while assigned(lm) do
  begin
    E := lm.LeftBound;
    while assigned(E) do
    begin
      E.XCurr := E.XBot;
      E.YCurr := E.YBot;
      E.Side := esLeft;
      E.OutIdx := -1;
      E := E.NextInLML;
    end;
    E := lm.RightBound;
    while assigned(E) do
    begin
      E.XCurr := E.XBot;
      E.YCurr := E.YBot;
      E.Side := esRight;
      E.OutIdx := -1;
      E := E.NextInLML;
    end;
    lm := lm.Next;
  end;
  // Finalize(E^);
end;
// ------------------------------------------------------------------------------

procedure TClipperBase.DisposeLocalMinimaList;
begin
  while assigned(FLmList) do
  begin
    FCurrLm := FLmList.Next;
    dispose(FLmList);
    FLmList := FCurrLm;
  end;
  FCurrLm := nil;
end;
// ------------------------------------------------------------------------------

procedure TClipperBase.PopLocalMinima;
begin
  if not assigned(FCurrLm) then
    exit;
  FCurrLm := FCurrLm.Next;
end;

// ------------------------------------------------------------------------------
// TClipper methods ...
// ------------------------------------------------------------------------------

constructor TClipper.Create;
begin
  inherited Create;
  FJoinList := TList.Create;
  FPolyOutList := TList.Create;
end;
// ------------------------------------------------------------------------------

destructor TClipper.Destroy;
begin
  inherited; // this must be first since inherited Destroy calls Clear.
  DisposeScanbeamList;
  FJoinList.Free;
  FPolyOutList.Free;
end;
// ------------------------------------------------------------------------------

procedure TClipper.Clear;
begin
  DisposeAllPolyPts;
  inherited;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DisposeScanbeamList;
var
  SB: PScanbeam;
begin
  while assigned(FScanbeam) do
  begin
    SB := FScanbeam.Next;
    dispose(FScanbeam);
    FScanbeam := SB;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.Reset;
var
  lm: PLocalMinima;
begin
  inherited Reset;
  FScanbeam := nil;
  DisposeAllPolyPts;
  lm := FLmList;
  while assigned(lm) do
  begin
    InsertScanbeam(lm.Y);
    InsertScanbeam(lm.LeftBound.YTop);
    lm := lm.Next;
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.Execute(clipType: TClipType; out solution: TFloatPolygons;
  subjFillType: TPolyFillType = pftEvenOdd;
  clipFillType: TPolyFillType = pftEvenOdd): Boolean;
begin
  Result := False;
  solution := nil;
  if FExecuteLocked then
    exit;
  try
    FExecuteLocked := true;
    FSubjFillType := subjFillType;
    FClipFillType := clipFillType;
    FClipType := clipType;
    Result := ExecuteInternal(False);
    if Result then
      solution := GetResult;
  finally
    FExecuteLocked := False;
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.Execute(clipType: TClipType; out solution: TExPolygons;
  subjFillType: TPolyFillType = pftEvenOdd;
  clipFillType: TPolyFillType = pftEvenOdd): Boolean;
begin
  Result := False;
  solution := nil;
  if FExecuteLocked then
    exit;
  try
    FExecuteLocked := true;
    FSubjFillType := subjFillType;
    FClipFillType := clipFillType;
    FClipType := clipType;
    Result := ExecuteInternal(true);
    if Result then
      solution := GetExResult;
  finally
    FExecuteLocked := False;
  end;
end;
// ------------------------------------------------------------------------------

function PolySort(item1, item2: pointer): Integer;
var
  P1, P2: POutRec;
  Idx1, Idx2: Integer;
begin
  Result := 0;
  if item1 = item2 then
    exit;
  P1 := item1;
  P2 := item2;
  if not assigned(P1.Pts) or not assigned(P2.Pts) then
  begin
    if assigned(P1.Pts) then
      Result := -1
    else if assigned(P2.Pts) then
      Result := 1;
    exit;
  end;
  if P1.IsHole then
    Idx1 := P1.FirstLeft.Idx
  else
    Idx1 := P1.Idx;
  if P2.IsHole then
    Idx2 := P2.FirstLeft.Idx
  else
    Idx2 := P2.Idx;
  Result := Idx1 - Idx2;
  if (Result = 0) and (P1.IsHole <> P2.IsHole) then
  begin
    if P1.IsHole then
      Result := 1
    else
      Result := -1;
  end;
end;
// ------------------------------------------------------------------------------

function FindAppendLinkEnd(OutRec: POutRec): POutRec;
begin
  while assigned(OutRec.AppendLink) do
    OutRec := OutRec.AppendLink;
  Result := OutRec;
end;
// ------------------------------------------------------------------------------

procedure TClipper.FixHoleLinkage(OutRec: POutRec);
var
  Tmp: POutRec;
begin
  if assigned(OutRec.BottomPt) then
    Tmp := POutRec(FPolyOutList[OutRec.BottomPt.Idx]).FirstLeft
  else
    Tmp := OutRec.FirstLeft;
  if (OutRec = Tmp) then
    raise Exception.Create(rsHoleLinkError);

  if assigned(Tmp) then
  begin
    if assigned(Tmp.AppendLink) then
      Tmp := FindAppendLinkEnd(Tmp);
    if Tmp = OutRec then
      Tmp := nil
    else if Tmp.IsHole then
    begin
      FixHoleLinkage(Tmp);
      Tmp := Tmp.FirstLeft;
    end;
  end;
  OutRec.FirstLeft := Tmp;
  if not assigned(Tmp) then
    OutRec.IsHole := False;
  OutRec.AppendLink := nil;
end;
// ------------------------------------------------------------------------------

function TClipper.ExecuteInternal(FixHoleLinkages: Boolean): Boolean;
var
  I: Integer;
  OutRec: POutRec;
  BotY, TopY: float;
begin
  Result := False;
  try
    try
      Reset;
      if not assigned(FScanbeam) then
      begin
        Result := true;
        exit;
      end;

      BotY := PopScanbeam;
      repeat
        InsertLocalMinimaIntoAEL(BotY);
        ClearHorzJoins;
        ProcessHorizontals;
        TopY := PopScanbeam;
        if not ProcessIntersections(BotY, TopY) then
          exit;
        ProcessEdgesAtTopOfScanbeam(TopY);
        BotY := TopY;
      until FScanbeam = nil;

      // tidy up output polygons and fix orientations where necessary ...
      for I := 0 to FPolyOutList.Count - 1 do
      begin
        OutRec := FPolyOutList[I];
        if not assigned(OutRec.Pts) then
          Continue;
        FixupOutPolygon(OutRec);
        if not assigned(OutRec.Pts) then
          Continue;

        if OutRec.IsHole and FixHoleLinkages then
          FixHoleLinkage(OutRec);
        // OutRec.BottomPt might've been cleaned up already so retest orientation
        if (OutRec.BottomPt = OutRec.BottomFlag) and
          (Orientation(OutRec, FUseFullBitRange) <>
          (Area(OutRec, FUseFullBitRange) > 0)) then
          DisposeBottomPt(OutRec);
        if (OutRec.IsHole = FReverseOutput) xor Orientation(OutRec,
          FUseFullBitRange) then
          ReversePolyPtLinks(OutRec.Pts);
      end;
      if FJoinList.Count > 0 then
        JoinCommonEdges(FixHoleLinkages);

      if FixHoleLinkages then
        FPolyOutList.Sort(PolySort);
      Result := true;
    except
      Result := False;
    end;
  finally
    ClearJoins;
    ClearHorzJoins;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.InsertScanbeam(const Y: float);
var
  SB, Sb2: PScanbeam;
begin
  new(SB);
  SB.Y := Y;
  if not assigned(FScanbeam) then
  begin
    FScanbeam := SB;
    SB.Next := nil;
  end
  else if Y > FScanbeam.Y then
  begin
    SB.Next := FScanbeam;
    FScanbeam := SB;
  end
  else
  begin
    Sb2 := FScanbeam;
    while assigned(Sb2.Next) and (Y <= Sb2.Next.Y) do
      Sb2 := Sb2.Next;
    if Y <> Sb2.Y then
    begin
      SB.Next := Sb2.Next;
      Sb2.Next := SB;
    end
    else
      dispose(SB); // ie ignores duplicates
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.PopScanbeam: float;
var
  SB: PScanbeam;
begin
  Result := FScanbeam.Y;
  SB := FScanbeam;
  FScanbeam := FScanbeam.Next;
  dispose(SB);
end;
// ------------------------------------------------------------------------------

procedure TClipper.DisposeBottomPt(OutRec: POutRec);
var
  Next, Prev: POutPt;
begin
  Next := OutRec.BottomPt.Next;
  Prev := OutRec.BottomPt.Prev;
  if OutRec.Pts = OutRec.BottomPt then
    OutRec.Pts := Next;
  dispose(OutRec.BottomPt);
  Next.Prev := Prev;
  Prev.Next := Next;
  OutRec.BottomPt := Next;
  FixupOutPolygon(OutRec);
end;
// ------------------------------------------------------------------------------

procedure TClipper.DisposePolyPts(PP: POutPt);
var
  TmpPp: POutPt;
begin
  PP.Prev.Next := nil;
  while assigned(PP) do
  begin
    TmpPp := PP;
    PP := PP.Next;
    dispose(TmpPp);
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DisposeAllPolyPts;
var
  I: Integer;
begin
  for I := 0 to FPolyOutList.Count - 1 do
    DisposeOutRec(I);
  FPolyOutList.Clear;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DisposeOutRec(Index: Integer);
var
  OutRec: POutRec;
begin
  OutRec := FPolyOutList[Index];
  if assigned(OutRec.Pts) then
    DisposePolyPts(OutRec.Pts);
  dispose(OutRec);
  FPolyOutList[Index] := nil;
end;
// ------------------------------------------------------------------------------

procedure TClipper.SetWindingCount(Edge: PEdge);
var
  E: PEdge;
begin
  E := Edge.PrevInAEL;
  // find the Edge of the same PolyType that immediately preceeds 'Edge' in AEL
  while assigned(E) and (E.PolyType <> Edge.PolyType) do
    E := E.PrevInAEL;
  if not assigned(E) then
  begin
    Edge.WindCnt := Edge.WindDelta;
    Edge.WindCnt2 := 0;
    E := FActiveEdges; // ie get ready to calc WindCnt2
  end
  else if IsEvenOddFillType(Edge) then
  begin
    // even-odd filling ...
    Edge.WindCnt := 1;
    Edge.WindCnt2 := E.WindCnt2;
    E := E.NextInAEL; // ie get ready to calc WindCnt2
  end
  else
  begin
    // NonZero, Positive, or Negative filling ...
    if E.WindCnt * E.WindDelta < 0 then
    begin
      if (abs(E.WindCnt) > 1) then
      begin
        if (E.WindDelta * Edge.WindDelta < 0) then
          Edge.WindCnt := E.WindCnt
        else
          Edge.WindCnt := E.WindCnt + Edge.WindDelta;
      end
      else
        Edge.WindCnt := E.WindCnt + E.WindDelta + Edge.WindDelta;
    end
    else
    begin
      if (abs(E.WindCnt) > 1) and (E.WindDelta * Edge.WindDelta < 0) then
        Edge.WindCnt := E.WindCnt
      else if E.WindCnt + Edge.WindDelta = 0 then
        Edge.WindCnt := E.WindCnt
      else
        Edge.WindCnt := E.WindCnt + Edge.WindDelta;
    end;
    Edge.WindCnt2 := E.WindCnt2;
    E := E.NextInAEL; // ie get ready to calc WindCnt2
  end;

  // update WindCnt2 ...
  if IsEvenOddAltFillType(Edge) then
  begin
    // even-odd filling ...
    while (E <> Edge) do
    begin
      if Edge.WindCnt2 = 0 then
        Edge.WindCnt2 := 1
      else
        Edge.WindCnt2 := 0;
      E := E.NextInAEL;
    end;
  end
  else
  begin
    // NonZero, Positive, or Negative filling ...
    while (E <> Edge) do
    begin
      inc(Edge.WindCnt2, E.WindDelta);
      E := E.NextInAEL;
    end;
  end;
  //Finalize(E^);  //E es un puntero y el contenido esta en Edge
end;
// ------------------------------------------------------------------------------

function TClipper.IsEvenOddFillType(Edge: PEdge): Boolean;
begin
  if Edge.PolyType = ptSubject then
    Result := FSubjFillType = pftEvenOdd
  else
    Result := FClipFillType = pftEvenOdd;
end;
// ------------------------------------------------------------------------------

function TClipper.IsEvenOddAltFillType(Edge: PEdge): Boolean;
begin
  if Edge.PolyType = ptSubject then
    Result := FClipFillType = pftEvenOdd
  else
    Result := FSubjFillType = pftEvenOdd;
end;
// ------------------------------------------------------------------------------

function TClipper.IsContributing(Edge: PEdge): Boolean;
var
  Pft, Pft2: TPolyFillType;
begin
  if Edge.PolyType = ptSubject then
  begin
    Pft := FSubjFillType;
    Pft2 := FClipFillType;
  end
  else
  begin
    Pft := FClipFillType;
    Pft2 := FSubjFillType
  end;
  case Pft of
    pftEvenOdd, pftNonZero:
      Result := abs(Edge.WindCnt) = 1;
    pftPositive:
      Result := (Edge.WindCnt = 1);
  else
    Result := (Edge.WindCnt = -1);
  end;
  if not Result then
    exit;

  case FClipType of
    ctIntersection:
      case Pft2 of
        pftEvenOdd, pftNonZero:
          Result := (Edge.WindCnt2 <> 0);
        pftPositive:
          Result := (Edge.WindCnt2 > 0);
        pftNegative:
          Result := (Edge.WindCnt2 < 0);
      end;
    ctUnion:
      case Pft2 of
        pftEvenOdd, pftNonZero:
          Result := (Edge.WindCnt2 = 0);
        pftPositive:
          Result := (Edge.WindCnt2 <= 0);
        pftNegative:
          Result := (Edge.WindCnt2 >= 0);
      end;
    ctDifference:
      if Edge.PolyType = ptSubject then
        case Pft2 of
          pftEvenOdd, pftNonZero:
            Result := (Edge.WindCnt2 = 0);
          pftPositive:
            Result := (Edge.WindCnt2 <= 0);
          pftNegative:
            Result := (Edge.WindCnt2 >= 0);
        end
      else
        case Pft2 of
          pftEvenOdd, pftNonZero:
            Result := (Edge.WindCnt2 <> 0);
          pftPositive:
            Result := (Edge.WindCnt2 > 0);
          pftNegative:
            Result := (Edge.WindCnt2 < 0);
        end;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddLocalMinPoly(E1, E2: PEdge; const Pt: TFloatPoint);
var
  E, prevE: PEdge;
begin
  if (E2.Dx = Horizontal) or (E1.Dx > E2.Dx) then
  begin
    AddOutPt(E1, Pt);
    E2.OutIdx := E1.OutIdx;
    E1.Side := esLeft;
    E2.Side := esRight;
    E := E1;
    if E.PrevInAEL = E2 then
      prevE := E2.PrevInAEL
    else
      prevE := E.PrevInAEL;
  end
  else
  begin
    AddOutPt(E2, Pt);
    E1.OutIdx := E2.OutIdx;
    E1.Side := esRight;
    E2.Side := esLeft;
    E := E2;
    if E.PrevInAEL = E1 then
      prevE := E1.PrevInAEL
    else
      prevE := E.PrevInAEL;
  end;

  if assigned(prevE) and (prevE.OutIdx >= 0) and
    (TopX(prevE, Pt.Y) = TopX(E, Pt.Y)) and
    SlopesEqual(E, prevE, FUseFullBitRange) then
    AddJoin(E, prevE);
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddLocalMaxPoly(E1, E2: PEdge; const Pt: TFloatPoint);
begin
  AddOutPt(E1, Pt);
  if (E1.OutIdx = E2.OutIdx) then
  begin
    E1.OutIdx := -1;
    E2.OutIdx := -1;
  end
  else if E1.OutIdx < E2.OutIdx then
    AppendPolygon(E1, E2)
  else
    AppendPolygon(E2, E1);
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddEdgeToSEL(Edge: PEdge);
begin
  // SEL pointers in PEdge are reused to build a list of horizontal edges.
  // However, we don't need to worry about order with horizontal Edge processing.
  if not assigned(FSortedEdges) then
  begin
    FSortedEdges := Edge;
    Edge.PrevInSEL := nil;
    Edge.NextInSEL := nil;
  end
  else
  begin
    Edge.NextInSEL := FSortedEdges;
    Edge.PrevInSEL := nil;
    FSortedEdges.PrevInSEL := Edge;
    FSortedEdges := Edge;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.CopyAELToSEL;
var
  E: PEdge;
begin
  E := FActiveEdges;
  FSortedEdges := E;
  if not assigned(FActiveEdges) then
    exit;

  FSortedEdges.PrevInSEL := nil;
  E := E.NextInAEL;
  while assigned(E) do
  begin
    E.PrevInSEL := E.PrevInAEL;
    E.PrevInSEL.NextInSEL := E;
    E.NextInSEL := nil;
    E := E.NextInAEL;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddJoin(E1, E2: PEdge; E1OutIdx: Integer = -1;
  E2OutIdx: Integer = -1);
var
  JR: PJoinRec;
begin
  new(JR);
  if E1OutIdx >= 0 then
    JR.Poly1Idx := E1OutIdx
  else
    JR.Poly1Idx := E1.OutIdx;
  with E1^ do
  begin
    JR.Pt1a := FloatPoint(XCurr, YCurr);
    JR.Pt1b := FloatPoint(XTop, YTop);
  end;
  if E2OutIdx >= 0 then
    JR.Poly2Idx := E2OutIdx
  else
    JR.Poly2Idx := E2.OutIdx;
  with E2^ do
  begin
    JR.Pt2a := FloatPoint(XCurr, YCurr);
    JR.Pt2b := FloatPoint(XTop, YTop);
  end;
  FJoinList.Add(JR);
end;
// ------------------------------------------------------------------------------

procedure TClipper.ClearJoins;
var
  I: Integer;
begin
  for I := 0 to FJoinList.Count - 1 do
    dispose(PJoinRec(FJoinList[I]));
  FJoinList.Clear;
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddHorzJoin(E: PEdge; Idx: Integer);
var
  Hr: PHorzRec;
begin
  new(Hr);
  Hr.Edge := E;
  Hr.SavedIdx := Idx;
  if FHorizJoins = nil then
  begin
    FHorizJoins := Hr;
    Hr.Next := Hr;
    Hr.Prev := Hr;
  end
  else
  begin
    Hr.Next := FHorizJoins;
    Hr.Prev := FHorizJoins.Prev;
    FHorizJoins.Prev.Next := Hr;
    FHorizJoins.Prev := Hr;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.ClearHorzJoins;
var
  M, M2: PHorzRec;
begin
  if not assigned(FHorizJoins) then
    exit;
  M := FHorizJoins;
  M.Prev.Next := nil;
  while assigned(M) do
  begin
    M2 := M.Next;
    dispose(M);
    M := M2;
  end;
  FHorizJoins := nil;
end;
// ------------------------------------------------------------------------------

procedure SwapPoints(var Pt1, Pt2: TFloatPoint);
var
  Tmp: TFloatPoint;
begin
  Tmp := Pt1;
  Pt1 := Pt2;
  Pt2 := Tmp;
end;
// ------------------------------------------------------------------------------

function GetOverlapSegment(Pt1a, Pt1b, Pt2a, Pt2b: TFloatPoint;
  out Pt1, Pt2: TFloatPoint): Boolean;
begin
  // precondition: segments are colinear
  if (Pt1a.Y = Pt1b.Y) or (abs((Pt1a.X - Pt1b.X) / (Pt1a.Y - Pt1b.Y)) > 1) then
  begin
    if Pt1a.X > Pt1b.X then
      SwapPoints(Pt1a, Pt1b);
    if Pt2a.X > Pt2b.X then
      SwapPoints(Pt2a, Pt2b);
    if (Pt1a.X > Pt2a.X) then
      Pt1 := Pt1a
    else
      Pt1 := Pt2a;
    if (Pt1b.X < Pt2b.X) then
      Pt2 := Pt1b
    else
      Pt2 := Pt2b;
    Result := Pt1.X < Pt2.X;
  end
  else
  begin
    if Pt1a.Y < Pt1b.Y then
      SwapPoints(Pt1a, Pt1b);
    if Pt2a.Y < Pt2b.Y then
      SwapPoints(Pt2a, Pt2b);
    if (Pt1a.Y < Pt2a.Y) then
      Pt1 := Pt1a
    else
      Pt1 := Pt2a;
    if (Pt1b.Y > Pt2b.Y) then
      Pt2 := Pt1b
    else
      Pt2 := Pt2b;
    Result := Pt1.Y > Pt2.Y;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.InsertLocalMinimaIntoAEL(const BotY: float);

  function E2InsertsBeforeE1(E1, E2: PEdge): Boolean;
  begin
    if E2.XCurr = E1.XCurr then
      Result := E2.Dx > E1.Dx
    else
      Result := E2.XCurr < E1.XCurr;
  end;
// ----------------------------------------------------------------------

  procedure InsertEdgeIntoAEL(Edge: PEdge);
  var
    E: PEdge;
  begin
    Edge.PrevInAEL := nil;
    Edge.NextInAEL := nil;
    if not assigned(FActiveEdges) then
    begin
      FActiveEdges := Edge;
    end
    else if E2InsertsBeforeE1(FActiveEdges, Edge) then
    begin
      Edge.NextInAEL := FActiveEdges;
      FActiveEdges.PrevInAEL := Edge;
      FActiveEdges := Edge;
    end
    else
    begin
      E := FActiveEdges;
      while assigned(E.NextInAEL) and
        not E2InsertsBeforeE1(E.NextInAEL, Edge) do
        E := E.NextInAEL;
      Edge.NextInAEL := E.NextInAEL;
      if assigned(E.NextInAEL) then
        E.NextInAEL.PrevInAEL := Edge;
      Edge.PrevInAEL := E;
      E.NextInAEL := Edge;
    end;
  end;
// ----------------------------------------------------------------------

var
  E: PEdge;
  Pt, Pt2: TFloatPoint;
  Lb, Rb: PEdge;
  Hj: PHorzRec;
begin
  while assigned(CurrentLm) and (CurrentLm.Y = BotY) do
  begin
    Lb := CurrentLm.LeftBound;
    Rb := CurrentLm.RightBound;

    InsertEdgeIntoAEL(Lb);
    InsertScanbeam(Lb.YTop);
    InsertEdgeIntoAEL(Rb);

    // set Edge winding states ...
    if IsEvenOddFillType(Lb) then
    begin
      Lb.WindDelta := 1;
      Rb.WindDelta := 1;
    end
    else
    begin
      Rb.WindDelta := -Lb.WindDelta
    end;
    SetWindingCount(Lb);
    Rb.WindCnt := Lb.WindCnt;
    Rb.WindCnt2 := Lb.WindCnt2;

    if Rb.Dx = Horizontal then
    begin
      AddEdgeToSEL(Rb);
      InsertScanbeam(Rb.NextInLML.YTop);
    end
    else
      InsertScanbeam(Rb.YTop);

    if IsContributing(Lb) then
      AddLocalMinPoly(Lb, Rb, FloatPoint(Lb.XCurr, CurrentLm.Y));

    // if output polygons share an Edge with rb, they'll need joining later ...
    if (Rb.OutIdx >= 0) then
    begin
      if (Rb.Dx = Horizontal) then
      begin
        if assigned(FHorizJoins) then
        begin
          Hj := FHorizJoins;
          repeat
            // if horizontals rb & hj.Edge overlap, flag for joining later ...
            if GetOverlapSegment(FloatPoint(Hj.Edge.XBot, Hj.Edge.YBot),
              FloatPoint(Hj.Edge.XTop, Hj.Edge.YTop),
              FloatPoint(Rb.XBot, Rb.YBot), FloatPoint(Rb.XTop, Rb.YTop),
              Pt, Pt2) then
              AddJoin(Hj.Edge, Rb, Hj.SavedIdx);
            Hj := Hj.Next;
          until Hj = FHorizJoins;
        end;
      end;
    end;

    if (Lb.NextInAEL <> Rb) then
    begin
      if (Rb.OutIdx >= 0) and (Rb.PrevInAEL.OutIdx >= 0) and
        SlopesEqual(Rb.PrevInAEL, Rb, FUseFullBitRange) then
        AddJoin(Rb, Rb.PrevInAEL);

      E := Lb.NextInAEL;
      Pt := FloatPoint(Lb.XCurr, Lb.YCurr);
      while E <> Rb do
      begin
        if not assigned(E) then
          raise Exception.Create(rsMissingRightbound);
        // nb: For calculating winding counts etc, IntersectEdges() assumes
        // that param1 will be to the right of param2 ABOVE the intersection ...
        IntersectEdges(Rb, E, Pt);
        E := E.NextInAEL;
      end;
    end;
    PopLocalMinima;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DeleteFromAEL(E: PEdge);
var
  AelPrev, AelNext: PEdge;
begin
  AelPrev := E.PrevInAEL;
  AelNext := E.NextInAEL;
  if not assigned(AelPrev) and not assigned(AelNext) and (E <> FActiveEdges)
  then
    exit; // already deleted
  if assigned(AelPrev) then
    AelPrev.NextInAEL := AelNext
  else
    FActiveEdges := AelNext;
  if assigned(AelNext) then
    AelNext.PrevInAEL := AelPrev;
  E.NextInAEL := nil;
  E.PrevInAEL := nil;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DeleteFromSEL(E: PEdge);
var
  SelPrev, SelNext: PEdge;
begin
  SelPrev := E.PrevInSEL;
  SelNext := E.NextInSEL;
  if not assigned(SelPrev) and not assigned(SelNext) and (E <> FSortedEdges)
  then
    exit; // already deleted
  if assigned(SelPrev) then
    SelPrev.NextInSEL := SelNext
  else
    FSortedEdges := SelNext;
  if assigned(SelNext) then
    SelNext.PrevInSEL := SelPrev;
  E.NextInSEL := nil;
  E.PrevInSEL := nil;
end;
// ------------------------------------------------------------------------------

procedure TClipper.IntersectEdges(E1, E2: PEdge; const Pt: TFloatPoint;
  protects: TIntersectProtects = []);

  procedure DoEdge1;
  begin
    AddOutPt(E1, Pt);
    SwapSides(E1, E2);
    SwapPolyIndexes(E1, E2);
  end;
// ----------------------------------------------------------------------

  procedure DoEdge2;
  begin
    AddOutPt(E2, Pt);
    SwapSides(E1, E2);
    SwapPolyIndexes(E1, E2);
  end;
// ----------------------------------------------------------------------

  procedure DoBothEdges;
  begin
    AddOutPt(E1, Pt);
    AddOutPt(E2, Pt);
    SwapSides(E1, E2);
    SwapPolyIndexes(E1, E2);
  end;
// ----------------------------------------------------------------------

var
  E1stops, E2stops: Boolean;
  E1Contributing, E2contributing: Boolean;
  E1FillType, E2FillType, E1FillType2, E2FillType2: TPolyFillType;
  E1Wc, E2Wc, E1Wc2, E2Wc2: Integer;
begin
  { IntersectEdges }

  // E1 will be to the left of E2 BELOW the intersection. Therefore E1 is before
  // E2 in AEL except when E1 is being inserted at the intersection point ...

  E1stops := not(ipLeft in protects) and not assigned(E1.NextInLML) and
    (E1.XTop = Pt.X) and (E1.YTop = Pt.Y);
  E2stops := not(ipRight in protects) and not assigned(E2.NextInLML) and
    (E2.XTop = Pt.X) and (E2.YTop = Pt.Y);
  E1Contributing := (E1.OutIdx >= 0);
  E2contributing := (E2.OutIdx >= 0);

  // update winding counts...
  // assumes that E1 will be to the right of E2 ABOVE the intersection
  if E1.PolyType = E2.PolyType then
  begin
    if IsEvenOddFillType(E1) then
    begin
      E1Wc := E1.WindCnt;
      E1.WindCnt := E2.WindCnt;
      E2.WindCnt := E1Wc;
    end
    else
    begin
      if E1.WindCnt + E2.WindDelta = 0 then
        E1.WindCnt := -E1.WindCnt
      else
        inc(E1.WindCnt, E2.WindDelta);
      if E2.WindCnt - E1.WindDelta = 0 then
        E2.WindCnt := -E2.WindCnt
      else
        dec(E2.WindCnt, E1.WindDelta);
    end;
  end
  else
  begin
    if not IsEvenOddFillType(E2) then
      inc(E1.WindCnt2, E2.WindDelta)
    else if E1.WindCnt2 = 0 then
      E1.WindCnt2 := 1
    else
      E1.WindCnt2 := 0;
    if not IsEvenOddFillType(E1) then
      dec(E2.WindCnt2, E1.WindDelta)
    else if E2.WindCnt2 = 0 then
      E2.WindCnt2 := 1
    else
      E2.WindCnt2 := 0;
  end;

  if E1.PolyType = ptSubject then
  begin
    E1FillType := FSubjFillType;
    E1FillType2 := FClipFillType;
  end
  else
  begin
    E1FillType := FClipFillType;
    E1FillType2 := FSubjFillType;
  end;
  if E2.PolyType = ptSubject then
  begin
    E2FillType := FSubjFillType;
    E2FillType2 := FClipFillType;
  end
  else
  begin
    E2FillType := FClipFillType;
    E2FillType2 := FSubjFillType;
  end;

  case E1FillType of
    pftPositive:
      E1Wc := E1.WindCnt;
    pftNegative:
      E1Wc := -E1.WindCnt;
  else
    E1Wc := abs(E1.WindCnt);
  end;
  case E2FillType of
    pftPositive:
      E2Wc := E2.WindCnt;
    pftNegative:
      E2Wc := -E2.WindCnt;
  else
    E2Wc := abs(E2.WindCnt);
  end;

  if E1Contributing and E2contributing then
  begin
    if E1stops or E2stops or not(E1Wc in [0, 1]) or not(E2Wc in [0, 1]) or
      ((E1.PolyType <> E2.PolyType) and (FClipType <> ctXor)) then
      AddLocalMaxPoly(E1, E2, Pt)
    else
      DoBothEdges;
  end
  else if E1Contributing then
  begin
    if ((E2Wc = 0) or (E2Wc = 1)) and
      ((FClipType <> ctIntersection) or (E2.PolyType = ptSubject) or
      (E2.WindCnt2 <> 0)) then
      DoEdge1;
  end
  else if E2contributing then
  begin
    if ((E1Wc = 0) or (E1Wc = 1)) and
      ((FClipType <> ctIntersection) or (E1.PolyType = ptSubject) or
      (E1.WindCnt2 <> 0)) then
      DoEdge2;
  end
  else if ((E1Wc = 0) or (E1Wc = 1)) and ((E2Wc = 0) or (E2Wc = 1)) and
    not E1stops and not E2stops then
  begin
    // neither Edge is currently contributing ...

    case E1FillType2 of
      pftPositive:
        E1Wc2 := E1.WindCnt2;
      pftNegative:
        E1Wc2 := -E1.WindCnt2;
    else
      E1Wc2 := abs(E1.WindCnt2);
    end;
    case E2FillType2 of
      pftPositive:
        E2Wc2 := E2.WindCnt2;
      pftNegative:
        E2Wc2 := -E2.WindCnt2;
    else
      E2Wc2 := abs(E2.WindCnt2);
    end;

    if (E1.PolyType <> E2.PolyType) then
      AddLocalMinPoly(E1, E2, Pt)
    else if (E1Wc = 1) and (E2Wc = 1) then
      case FClipType of
        ctIntersection:
          if (E1Wc2 > 0) and (E2Wc2 > 0) then
            AddLocalMinPoly(E1, E2, Pt);
        ctUnion:
          if (E1Wc2 <= 0) and (E2Wc2 <= 0) then
            AddLocalMinPoly(E1, E2, Pt);
        ctDifference:
          if ((E1.PolyType = ptClip) and (E1Wc2 > 0) and (E2Wc2 > 0)) or
            ((E1.PolyType = ptSubject) and (E1Wc2 <= 0) and (E2Wc2 <= 0)) then
            AddLocalMinPoly(E1, E2, Pt);
        ctXor:
          AddLocalMinPoly(E1, E2, Pt);
      end
    else
      SwapSides(E1, E2);
  end;

  if (E1stops <> E2stops) and ((E1stops and (E1.OutIdx >= 0)) or
    (E2stops and (E2.OutIdx >= 0))) then
  begin
    SwapSides(E1, E2);
    SwapPolyIndexes(E1, E2);
  end;

  // finally, delete any non-contributing maxima edges  ...
  if E1stops then
    DeleteFromAEL(E1);
  if E2stops then
    DeleteFromAEL(E2);
end;
// ------------------------------------------------------------------------------

function FirstIsBottomPt(btmPt1, btmPt2: POutPt): Boolean;
var
  Dx1n, Dx1p, Dx2n, Dx2p: double;
  P: POutPt;
begin
  P := btmPt1.Prev;
  while PointsEqual(P.Pt, btmPt1.Pt) and (P <> btmPt1) do
    P := P.Prev;
  Dx1p := abs(GetDx(btmPt1.Pt, P.Pt));
  P := btmPt1.Next;
  while PointsEqual(P.Pt, btmPt1.Pt) and (P <> btmPt1) do
    P := P.Next;
  Dx1n := abs(GetDx(btmPt1.Pt, P.Pt));

  P := btmPt2.Prev;
  while PointsEqual(P.Pt, btmPt2.Pt) and (P <> btmPt2) do
    P := P.Prev;
  Dx2p := abs(GetDx(btmPt2.Pt, P.Pt));
  P := btmPt2.Next;
  while PointsEqual(P.Pt, btmPt2.Pt) and (P <> btmPt2) do
    P := P.Next;
  Dx2n := abs(GetDx(btmPt2.Pt, P.Pt));
  Result := ((Dx1p >= Dx2p) and (Dx1p >= Dx2n)) or
    ((Dx1n >= Dx2p) and (Dx1n >= Dx2n));
end;
// ------------------------------------------------------------------------------

function GetBottomPt(PP: POutPt): POutPt;
var
  P, Dups: POutPt;
begin
  Dups := nil;
  P := PP.Next;
  while P <> PP do
  begin
    if P.Pt.Y > PP.Pt.Y then
    begin
      PP := P;
      Dups := nil;
    end
    else if (P.Pt.Y = PP.Pt.Y) and (P.Pt.X <= PP.Pt.X) then
    begin
      if (P.Pt.X < PP.Pt.X) then
      begin
        Dups := nil;
        PP := P;
      end
      else
      begin
        if (P.Next <> PP) and (P.Prev <> PP) then
          Dups := P;
      end;
    end;
    P := P.Next;
  end;
  if assigned(Dups) then
  begin
    // there appears to be at least 2 vertices at BottomPt so ...
    while Dups <> P do
    begin
      if not FirstIsBottomPt(P, Dups) then
        PP := Dups;
      Dups := Dups.Next;
      while not PointsEqual(Dups.Pt, PP.Pt) do
        Dups := Dups.Next;
    end;
  end;
  Result := PP;
end;
// ------------------------------------------------------------------------------

procedure TClipper.SetHoleState(E: PEdge; OutRec: POutRec);
var
  E2: PEdge;
  IsHole: Boolean;
begin
  IsHole := False;
  E2 := E.PrevInAEL;
  while assigned(E2) do
  begin
    if (E2.OutIdx >= 0) then
    begin
      IsHole := not IsHole;
      if not assigned(OutRec.FirstLeft) then
        OutRec.FirstLeft := POutRec(FPolyOutList[E2.OutIdx]);
    end;
    E2 := E2.PrevInAEL;
  end;
  if IsHole then
    OutRec.IsHole := true;
end;
// ------------------------------------------------------------------------------

function GetLowermostRec(OutRec1, OutRec2: POutRec): POutRec;
var
  OutPt1, OutPt2: POutPt;
begin
  OutPt1 := OutRec1.BottomPt;
  OutPt2 := OutRec2.BottomPt;
  if (OutPt1.Pt.Y > OutPt2.Pt.Y) then
    Result := OutRec1
  else if (OutPt1.Pt.Y < OutPt2.Pt.Y) then
    Result := OutRec2
  else if (OutPt1.Pt.X < OutPt2.Pt.X) then
    Result := OutRec1
  else if (OutPt1.Pt.X > OutPt2.Pt.X) then
    Result := OutRec2
  else if (OutPt1.Next = OutPt1) then
    Result := OutRec2
  else if (OutPt2.Next = OutPt2) then
    Result := OutRec1
  else if FirstIsBottomPt(OutPt1, OutPt2) then
    Result := OutRec1
  else
    Result := OutRec2;
end;
// ------------------------------------------------------------------------------

function Param1RightOfParam2(OutRec1, OutRec2: POutRec): Boolean;
begin
  Result := true;
  repeat
    OutRec1 := OutRec1.FirstLeft;
    if OutRec1 = OutRec2 then
      exit;
  until not assigned(OutRec1);
  Result := False;
end;
// ------------------------------------------------------------------------------

procedure TClipper.AppendPolygon(E1, E2: PEdge);
var
  HoleStateRec, OutRec1, OutRec2: POutRec;
  P1_lft, P1_rt, P2_lft, P2_rt: POutPt;
  NewSide: TEdgeSide;
  I, OKIdx, ObsoleteIdx: Integer;
  E: PEdge;
  JR: PJoinRec;
  H: PHorzRec;
begin
  OutRec1 := FPolyOutList[E1.OutIdx];
  OutRec2 := FPolyOutList[E2.OutIdx];

  // work out which polygon fragment has the correct hole state ...
  if Param1RightOfParam2(OutRec1, OutRec2) then
    HoleStateRec := OutRec2
  else if Param1RightOfParam2(OutRec2, OutRec1) then
    HoleStateRec := OutRec1
  else
    HoleStateRec := GetLowermostRec(OutRec1, OutRec2);

  // get the start and ends of both output polygons ...
  P1_lft := OutRec1.Pts;
  P2_lft := OutRec2.Pts;
  P1_rt := P1_lft.Prev;
  P2_rt := P2_lft.Prev;

  // join E2 poly onto E1 poly and delete pointers to E2 ...
  if E1.Side = esLeft then
  begin
    if E2.Side = esLeft then
    begin
      // z y x a b c
      ReversePolyPtLinks(P2_lft);
      P2_lft.Next := P1_lft;
      P1_lft.Prev := P2_lft;
      P1_rt.Next := P2_rt;
      P2_rt.Prev := P1_rt;
      OutRec1.Pts := P2_rt;
    end
    else
    begin
      // x y z a b c
      P2_rt.Next := P1_lft;
      P1_lft.Prev := P2_rt;
      P2_lft.Prev := P1_rt;
      P1_rt.Next := P2_lft;
      OutRec1.Pts := P2_lft;
    end;
    NewSide := esLeft;
  end
  else
  begin
    if E2.Side = esRight then
    begin
      // a b c z y x
      ReversePolyPtLinks(P2_lft);
      P1_rt.Next := P2_rt;
      P2_rt.Prev := P1_rt;
      P2_lft.Next := P1_lft;
      P1_lft.Prev := P2_lft;
    end
    else
    begin
      // a b c x y z
      P1_rt.Next := P2_lft;
      P2_lft.Prev := P1_rt;
      P1_lft.Prev := P2_rt;
      P2_rt.Next := P1_lft;
    end;
    NewSide := esRight;
  end;

  if HoleStateRec = OutRec2 then
  begin
    OutRec1.BottomPt := OutRec2.BottomPt;
    OutRec1.BottomPt.Idx := OutRec1.Idx;
    if OutRec2.FirstLeft <> OutRec1 then
      OutRec1.FirstLeft := OutRec2.FirstLeft;
    OutRec1.IsHole := OutRec2.IsHole;
  end;
  OutRec2.Pts := nil;
  OutRec2.BottomPt := nil;
  OutRec2.AppendLink := OutRec1;
  OKIdx := OutRec1.Idx;
  ObsoleteIdx := OutRec2.Idx;

  E1.OutIdx := -1; // nb: safe because we only get here via AddLocalMaxPoly
  E2.OutIdx := -1;

  E := FActiveEdges;
  while assigned(E) do
  begin
    if (E.OutIdx = ObsoleteIdx) then
    begin
      E.OutIdx := OKIdx;
      E.Side := NewSide;
      break;
    end;
    E := E.NextInAEL;
  end;

  for I := 0 to FJoinList.Count - 1 do
  begin
    JR := FJoinList[I];
    if JR.Poly1Idx = ObsoleteIdx then
      JR.Poly1Idx := OKIdx;
    if JR.Poly2Idx = ObsoleteIdx then
      JR.Poly2Idx := OKIdx;
  end;
  if assigned(FHorizJoins) then
  begin
    H := FHorizJoins;
    repeat
      if H.SavedIdx = ObsoleteIdx then
        H.SavedIdx := OKIdx;
      H := H.Next;
    until H = FHorizJoins;
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.CreateOutRec: POutRec;
begin
  new(Result);
  Result.IsHole := False;
  Result.FirstLeft := nil;
  Result.AppendLink := nil;
  Result.Pts := nil;
  Result.BottomPt := nil;
  Result.Sides := [];
  Result.BottomFlag := nil;
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddOutPt(E: PEdge; const Pt: TFloatPoint);
var
  OutRec: POutRec;
  Op, op2, opBot: POutPt;
  ToFront: Boolean;
begin
  ToFront := E.Side = esLeft;
  if E.OutIdx < 0 then
  begin
    OutRec := CreateOutRec;
    OutRec.Idx := FPolyOutList.Add(OutRec);
    E.OutIdx := OutRec.Idx;
    new(Op);
    OutRec.Pts := Op;
    OutRec.BottomPt := Op;

    Op.Pt := Pt;
    Op.Next := Op;
    Op.Prev := Op;
    Op.Idx := OutRec.Idx;
    SetHoleState(E, OutRec);
  end
  else
  begin
    OutRec := FPolyOutList[E.OutIdx];
    Op := OutRec.Pts;
    if (ToFront and PointsEqual(Pt, Op.Pt)) or
      (not ToFront and PointsEqual(Pt, Op.Prev.Pt)) then
      exit;

    if not(E.Side in OutRec.Sides) then
    begin

      // check for 'rounding' artefacts ...
      if (OutRec.Sides = []) and (Pt.Y = Op.Pt.Y) then
        if ToFront then
        begin
          if (Pt.X = Op.Pt.X + 1) then
            exit; // ie wrong Side of BottomPt
        end
        else if (Pt.X = Op.Pt.X - 1) then
          exit; // ie wrong Side of BottomPt

      OutRec.Sides := OutRec.Sides + [E.Side];
      if OutRec.Sides = [esLeft, esRight] then
      begin
        // A vertex from each Side has now been added.
        // Vertices of one Side of an output polygon are quite commonly close to
        // or even 'touching' edges of the other Side of the output polygon.
        // Very occasionally vertices from one Side can 'cross' an Edge on the
        // the other Side. The distance 'crossed' is always less that a unit
        // and is purely an artefact of coordinate rounding. Nevertheless, this
        // results in very tiny self-intersections. Because of the way
        // orientation is calculated, even tiny self-intersections can cause
        // the Orientation function to return the wrong result. Therefore, it's
        // important to ensure that any self-intersections close to BottomPt are
        // detected and removed before orientation is assigned.

        if ToFront then
        begin
          opBot := OutRec.Pts;
          op2 := opBot.Next; // op2 == right Side
          if (opBot.Pt.Y <> op2.Pt.Y) and (opBot.Pt.Y <> Pt.Y) and
            ((opBot.Pt.X - Pt.X) / (opBot.Pt.Y - Pt.Y) < (opBot.Pt.X - op2.Pt.X)
            / (opBot.Pt.Y - op2.Pt.Y)) then
            OutRec.BottomFlag := opBot;
        end
        else
        begin
          opBot := OutRec.Pts.Prev;
          op2 := opBot.Prev; // op2 == left Side
          if (opBot.Pt.Y <> op2.Pt.Y) and (opBot.Pt.Y <> Pt.Y) and
            ((opBot.Pt.X - Pt.X) / (opBot.Pt.Y - Pt.Y) > (opBot.Pt.X - op2.Pt.X)
            / (opBot.Pt.Y - op2.Pt.Y)) then
            OutRec.BottomFlag := opBot;
        end;
      end;
    end;

    new(op2);
    op2.Pt := Pt;
    op2.Idx := OutRec.Idx;
    if (op2.Pt.Y = OutRec.BottomPt.Pt.Y) and (op2.Pt.X < OutRec.BottomPt.Pt.X)
    then
      OutRec.BottomPt := op2;
    op2.Next := Op;
    op2.Prev := Op.Prev;
    Op.Prev.Next := op2;
    Op.Prev := op2;
    if ToFront then
      OutRec.Pts := op2;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.ProcessHorizontals;
var
  E: PEdge;
begin
  while assigned(FSortedEdges) do
  begin
    E := FSortedEdges;
    DeleteFromSEL(E);
    ProcessHorizontal(E);
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.IsTopHorz(const XPos: float): Boolean;
var
  E: PEdge;
begin
  Result := False;
  E := FSortedEdges;
  while assigned(E) do
  begin
    if (XPos >= min(E.XCurr, E.XTop)) and (XPos <= max(E.XCurr, E.XTop)) then
      exit;
    E := E.NextInSEL;
  end;
  Result := true;
end;
// ------------------------------------------------------------------------------

function IsMinima(E: PEdge): Boolean;
begin
  Result := assigned(E) and (E.Prev.NextInLML <> E) and (E.Next.NextInLML <> E);
end;
// ------------------------------------------------------------------------------

function IsMaxima(E: PEdge; const Y: float): Boolean;
begin
  Result := assigned(E) and (E.YTop = Y) and not assigned(E.NextInLML);
end;
// ------------------------------------------------------------------------------

function IsIntermediate(E: PEdge; const Y: float): Boolean;
begin
  Result := (E.YTop = Y) and assigned(E.NextInLML);
end;
// ------------------------------------------------------------------------------

function GetMaximaPair(E: PEdge): PEdge;
begin
  Result := E.Next;
  if not IsMaxima(Result, E.YTop) or (Result.XTop <> E.XTop) then
    Result := E.Prev;
end;
// ------------------------------------------------------------------------------

procedure TClipper.SwapPositionsInAEL(E1, E2: PEdge);
var
  Prev, Next: PEdge;
begin
  with E1^ do
    if not assigned(NextInAEL) and not assigned(PrevInAEL) then
      exit;
  with E2^ do
    if not assigned(NextInAEL) and not assigned(PrevInAEL) then
      exit;

  if E1.NextInAEL = E2 then
  begin
    Next := E2.NextInAEL;
    if assigned(Next) then
      Next.PrevInAEL := E1;
    Prev := E1.PrevInAEL;
    if assigned(Prev) then
      Prev.NextInAEL := E2;
    E2.PrevInAEL := Prev;
    E2.NextInAEL := E1;
    E1.PrevInAEL := E2;
    E1.NextInAEL := Next;
  end
  else if E2.NextInAEL = E1 then
  begin
    Next := E1.NextInAEL;
    if assigned(Next) then
      Next.PrevInAEL := E2;
    Prev := E2.PrevInAEL;
    if assigned(Prev) then
      Prev.NextInAEL := E1;
    E1.PrevInAEL := Prev;
    E1.NextInAEL := E2;
    E2.PrevInAEL := E1;
    E2.NextInAEL := Next;
  end
  else
  begin
    Next := E1.NextInAEL;
    Prev := E1.PrevInAEL;
    E1.NextInAEL := E2.NextInAEL;
    if assigned(E1.NextInAEL) then
      E1.NextInAEL.PrevInAEL := E1;
    E1.PrevInAEL := E2.PrevInAEL;
    if assigned(E1.PrevInAEL) then
      E1.PrevInAEL.NextInAEL := E1;
    E2.NextInAEL := Next;
    if assigned(E2.NextInAEL) then
      E2.NextInAEL.PrevInAEL := E2;
    E2.PrevInAEL := Prev;
    if assigned(E2.PrevInAEL) then
      E2.PrevInAEL.NextInAEL := E2;
  end;
  if not assigned(E1.PrevInAEL) then
    FActiveEdges := E1
  else if not assigned(E2.PrevInAEL) then
    FActiveEdges := E2;
end;
// ------------------------------------------------------------------------------

procedure TClipper.SwapPositionsInSEL(E1, E2: PEdge);
var
  Prev, Next: PEdge;
begin
  if E1.NextInSEL = E2 then
  begin
    Next := E2.NextInSEL;
    if assigned(Next) then
      Next.PrevInSEL := E1;
    Prev := E1.PrevInSEL;
    if assigned(Prev) then
      Prev.NextInSEL := E2;
    E2.PrevInSEL := Prev;
    E2.NextInSEL := E1;
    E1.PrevInSEL := E2;
    E1.NextInSEL := Next;
  end
  else if E2.NextInSEL = E1 then
  begin
    Next := E1.NextInSEL;
    if assigned(Next) then
      Next.PrevInSEL := E2;
    Prev := E2.PrevInSEL;
    if assigned(Prev) then
      Prev.NextInSEL := E1;
    E1.PrevInSEL := Prev;
    E1.NextInSEL := E2;
    E2.PrevInSEL := E1;
    E2.NextInSEL := Next;
  end
  else
  begin
    Next := E1.NextInSEL;
    Prev := E1.PrevInSEL;
    E1.NextInSEL := E2.NextInSEL;
    if assigned(E1.NextInSEL) then
      E1.NextInSEL.PrevInSEL := E1;
    E1.PrevInSEL := E2.PrevInSEL;
    if assigned(E1.PrevInSEL) then
      E1.PrevInSEL.NextInSEL := E1;
    E2.NextInSEL := Next;
    if assigned(E2.NextInSEL) then
      E2.NextInSEL.PrevInSEL := E2;
    E2.PrevInSEL := Prev;
    if assigned(E2.PrevInSEL) then
      E2.PrevInSEL.NextInSEL := E2;
  end;
  if not assigned(E1.PrevInSEL) then
    FSortedEdges := E1
  else if not assigned(E2.PrevInSEL) then
    FSortedEdges := E2;
end;
// ------------------------------------------------------------------------------

procedure TClipper.ProcessHorizontal(HorzEdge: PEdge);

  function GetNextInAEL(E: PEdge; Direction: TDirection): PEdge;
  begin
    if Direction = dLeftToRight then
      Result := E.NextInAEL
    else
      Result := E.PrevInAEL;
  end;
// ------------------------------------------------------------------------

var
  E, eNext, eMaxPair: PEdge;
  HorzLeft, HorzRight: float;
  Direction: TDirection;
const
  ProtectLeft: array [Boolean] of TIntersectProtects = ([ipRight],
    [ipLeft, ipRight]);
  ProtectRight: array [Boolean] of TIntersectProtects = ([ipLeft],
    [ipLeft, ipRight]);
begin
  (* ******************************************************************************
    * Notes: Horizontal edges (HEs) at scanline intersections (ie at the top or    *
    * bottom of a scanbeam) are processed as if layered. The order in which HEs    *
    * are processed doesn't matter. HEs intersect with other HE xbots only [#],    *
    * and with other non-horizontal edges [*]. Once these intersections are        *
    * processed, intermediate HEs then 'promote' the Edge above (NextInLML) into   *
    * the AEL. These 'promoted' edges may in turn intersect [%] with other HEs.    *
    ****************************************************************************** *)

  (* ******************************************************************************
    *           \   nb: HE processing order doesn't matter         /          /    *
    *            \                                                /          /     *
    * { --------  \  -------------------  /  \  - (3) o==========%==========o  - } *
    * {            o==========o (2)      /    \       .          .               } *
    * {                       .         /      \      .          .               } *
    * { ----  o===============#========*========*=====#==========o  (1)  ------- } *
    *        /                 \      /          \   /                             *
    ****************************************************************************** *)

  if HorzEdge.XCurr < HorzEdge.XTop then
  begin
    HorzLeft := HorzEdge.XCurr;
    HorzRight := HorzEdge.XTop;
    Direction := dLeftToRight;
  end
  else
  begin
    HorzLeft := HorzEdge.XTop;
    HorzRight := HorzEdge.XCurr;
    Direction := dRightToLeft;
  end;

  if assigned(HorzEdge.NextInLML) then
    eMaxPair := nil
  else
    eMaxPair := GetMaximaPair(HorzEdge);

  E := GetNextInAEL(HorzEdge, Direction);
  while assigned(E) do
  begin
    eNext := GetNextInAEL(E, Direction);
    if assigned(eMaxPair) or ((Direction = dLeftToRight) and
      (E.XCurr <= HorzRight)) or ((Direction = dRightToLeft) and
      (E.XCurr >= HorzLeft)) then
    begin
      // ok, so far it looks like we're still in range of the horizontal Edge

      if (E.XCurr = HorzEdge.XTop) and not assigned(eMaxPair) then
      begin
        if SlopesEqual(E, HorzEdge.NextInLML, FUseFullBitRange) then
        begin
          // if output polygons share an Edge, they'll need joining later ...
          if (HorzEdge.OutIdx >= 0) and (E.OutIdx >= 0) then
            AddJoin(HorzEdge.NextInLML, E, HorzEdge.OutIdx);
          break; // we've reached the end of the horizontal line
        end
        else if (E.Dx < HorzEdge.NextInLML.Dx) then
          // we really have got to the end of the intermediate horz Edge so quit.
          // nb: More -ve slopes follow more +ve slopes ABOVE the horizontal.
          break;
      end;

      if (E = eMaxPair) then
      begin
        // HorzEdge is evidently a maxima horizontal and we've arrived at its end.
        if Direction = dLeftToRight then
          IntersectEdges(HorzEdge, E, FloatPoint(E.XCurr, HorzEdge.YCurr))
        else
          IntersectEdges(E, HorzEdge, FloatPoint(E.XCurr, HorzEdge.YCurr));

        if (eMaxPair.OutIdx >= 0) then
          raise Exception.Create(rsHorizontal);
        exit;
      end
      else if (E.Dx = Horizontal) and not IsMinima(E) and not(E.XCurr > E.XTop)
      then
      begin
        // An overlapping horizontal Edge. Overlapping horizontal edges are
        // processed as if layered with the current horizontal Edge (horizEdge)
        // being infinitesimally lower that the Next (E). Therfore, we
        // intersect with E only if E.XCurr is within the bounds of HorzEdge ...
        if Direction = dLeftToRight then
          IntersectEdges(HorzEdge, E, FloatPoint(E.XCurr, HorzEdge.YCurr),
            ProtectRight[not IsTopHorz(E.XCurr)])
        else
          IntersectEdges(E, HorzEdge, FloatPoint(E.XCurr, HorzEdge.YCurr),
            ProtectLeft[not IsTopHorz(E.XCurr)]);
      end
      else if (Direction = dLeftToRight) then
        IntersectEdges(HorzEdge, E, FloatPoint(E.XCurr, HorzEdge.YCurr),
          ProtectRight[not IsTopHorz(E.XCurr)])
      else
        IntersectEdges(E, HorzEdge, FloatPoint(E.XCurr, HorzEdge.YCurr),
          ProtectLeft[not IsTopHorz(E.XCurr)]);
      SwapPositionsInAEL(HorzEdge, E);
    end
    else if ((Direction = dLeftToRight) and (E.XCurr > HorzRight) and
      assigned(FSortedEdges)) or ((Direction = dRightToLeft) and
      (E.XCurr < HorzLeft) and assigned(FSortedEdges)) then
      break;
    E := eNext;
  end;

  if assigned(HorzEdge.NextInLML) then
  begin
    if (HorzEdge.OutIdx >= 0) then
      AddOutPt(HorzEdge, FloatPoint(HorzEdge.XTop, HorzEdge.YTop));
    UpdateEdgeIntoAEL(HorzEdge);
  end
  else
  begin
    if HorzEdge.OutIdx >= 0 then
      IntersectEdges(HorzEdge, eMaxPair, FloatPoint(HorzEdge.XTop,
        HorzEdge.YCurr), [ipLeft, ipRight]);

    if eMaxPair.OutIdx >= 0 then
      raise Exception.Create(rsHorizontal);
    DeleteFromAEL(eMaxPair);
    DeleteFromAEL(HorzEdge);
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.UpdateEdgeIntoAEL(var E: PEdge);
var
  AelPrev, AelNext: PEdge;
begin
  if not assigned(E.NextInLML) then
    raise Exception.Create(rsUpdateEdgeIntoAEL);
  AelPrev := E.PrevInAEL;
  AelNext := E.NextInAEL;
  E.NextInLML.OutIdx := E.OutIdx;
  if assigned(AelPrev) then
    AelPrev.NextInAEL := E.NextInLML
  else
    FActiveEdges := E.NextInLML;
  if assigned(AelNext) then
    AelNext.PrevInAEL := E.NextInLML;
  E.NextInLML.Side := E.Side;
  E.NextInLML.WindDelta := E.WindDelta;
  E.NextInLML.WindCnt := E.WindCnt;
  E.NextInLML.WindCnt2 := E.WindCnt2;
  E := E.NextInLML;
  E.PrevInAEL := AelPrev;
  E.NextInAEL := AelNext;
  if E.Dx <> Horizontal then
    InsertScanbeam(E.YTop);
end;
// ------------------------------------------------------------------------------

function TClipper.ProcessIntersections(const BotY, TopY: float): Boolean;
begin
  Result := true;
  try
    BuildIntersectList(BotY, TopY);
    if FIntersectNodes = nil then
      exit;
    if FixupIntersections then
      ProcessIntersectList
    else
      Result := False;
  finally
    // if there's been an error, clean up the mess ...
    DisposeIntersectNodes;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DisposeIntersectNodes;
var
  N: PIntersectNode;
begin
  while assigned(FIntersectNodes) do
  begin
    N := FIntersectNodes.Next;
    dispose(FIntersectNodes);
    FIntersectNodes := N;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.BuildIntersectList(const BotY, TopY: float);
var
  E, eNext: PEdge;
  Pt: TFloatPoint;
  IsModified: Boolean;
begin
  if not assigned(FActiveEdges) then
    exit;

  // prepare for sorting ...
  E := FActiveEdges;
  E.TmpX := TopX(E, TopY);
  FSortedEdges := E;
  FSortedEdges.PrevInSEL := nil;
  E := E.NextInAEL;
  while assigned(E) do
  begin
    E.PrevInSEL := E.PrevInAEL;
    E.PrevInSEL.NextInSEL := E;
    E.NextInSEL := nil;
    E.TmpX := TopX(E, TopY);
    E := E.NextInAEL;
  end;

  try
    // bubblesort ...
    IsModified := true;
    while IsModified and assigned(FSortedEdges) do
    begin
      IsModified := False;
      E := FSortedEdges;
      while assigned(E.NextInSEL) do
      begin
        eNext := E.NextInSEL;
        if (E.TmpX > eNext.TmpX) and IntersectPoint(E, eNext, Pt,
          FUseFullBitRange) then
        begin
          if Pt.Y > BotY then
          begin
            Pt.Y := BotY;
            Pt.X := TopX(E, Pt.Y);
          end;
          AddIntersectNode(E, eNext, Pt);
          SwapPositionsInSEL(E, eNext);
          IsModified := true;
        end
        else
          E := eNext;
      end;
      if assigned(E.PrevInSEL) then
        E.PrevInSEL.NextInSEL := nil
      else
        break;
    end;
  finally
    FSortedEdges := nil;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.AddIntersectNode(E1, E2: PEdge; const Pt: TFloatPoint);

  function ProcessParam1BeforeParam2(node1, node2: PIntersectNode): Boolean;
  begin
    if node1.Pt.Y = node2.Pt.Y then
    begin
      if (node1.Edge1 = node2.Edge1) or (node1.Edge2 = node2.Edge1) then
      begin
        Result := node2.Pt.X > node1.Pt.X;
        if node2.Edge1.Dx > 0 then
          Result := not Result;
      end
      else if (node1.Edge1 = node2.Edge2) or (node1.Edge2 = node2.Edge2) then
      begin
        Result := node2.Pt.X > node1.Pt.X;
        if node2.Edge2.Dx > 0 then
          Result := not Result;
      end
      else
        Result := node2.Pt.X > node1.Pt.X;
    end
    else
      Result := node1.Pt.Y > node2.Pt.Y;
  end;
// ----------------------------------------------------------------------------

var
  Node, NewNode: PIntersectNode;
begin
  new(NewNode);
  NewNode.Edge1 := E1;
  NewNode.Edge2 := E2;
  NewNode.Pt := Pt;
  NewNode.Next := nil;
  if not assigned(FIntersectNodes) then
    FIntersectNodes := NewNode
  else if ProcessParam1BeforeParam2(NewNode, FIntersectNodes) then
  begin
    NewNode.Next := FIntersectNodes;
    FIntersectNodes := NewNode;
  end
  else
  begin
    Node := FIntersectNodes;
    while assigned(Node.Next) and ProcessParam1BeforeParam2(Node.Next,
      NewNode) do
      Node := Node.Next;
    NewNode.Next := Node.Next;
    Node.Next := NewNode;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.ProcessIntersectList;
var
  Node: PIntersectNode;
begin
  while assigned(FIntersectNodes) do
  begin
    Node := FIntersectNodes.Next;
    with FIntersectNodes^ do
    begin
      IntersectEdges(Edge1, Edge2, Pt, [ipLeft, ipRight]);
      SwapPositionsInAEL(Edge1, Edge2);
    end;
    dispose(FIntersectNodes);
    FIntersectNodes := Node;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.DoMaxima(E: PEdge; const TopY: float);
var
  eNext, eMaxPair: PEdge;
  X: float;
begin
  eMaxPair := GetMaximaPair(E);
  X := E.XTop;
  eNext := E.NextInAEL;
  while eNext <> eMaxPair do
  begin
    if not assigned(eNext) then
      raise Exception.Create(rsDoMaxima);
    IntersectEdges(E, eNext, FloatPoint(X, TopY), [ipLeft, ipRight]);
    eNext := eNext.NextInAEL;
  end;
  if (E.OutIdx < 0) and (eMaxPair.OutIdx < 0) then
  begin
    DeleteFromAEL(E);
    DeleteFromAEL(eMaxPair);
  end
  else if (E.OutIdx >= 0) and (eMaxPair.OutIdx >= 0) then
  begin
    IntersectEdges(E, eMaxPair, FloatPoint(X, TopY));
  end
  else
    raise Exception.Create(rsDoMaxima);
end;
// ------------------------------------------------------------------------------

procedure TClipper.ProcessEdgesAtTopOfScanbeam(const TopY: float);
var
  E, ePrev, eNext: PEdge;
  Hj: PHorzRec;
  Pt, Pt2: TFloatPoint;
begin
  (* ******************************************************************************
    * Notes: Processing edges at scanline intersections (ie at the top or bottom   *
    * of a scanbeam) needs to be done in multiple stages and in the correct order. *
    * Firstly, edges forming a 'maxima' need to be processed and then removed.     *
    * Next, 'intermediate' and 'maxima' horizontal edges are processed. Then edges *
    * that intersect exactly at the top of the scanbeam are processed [%].         *
    * Finally, new minima are added and any intersects they create are processed.  *
    ****************************************************************************** *)

  (* ******************************************************************************
    *     \                          /    /          \   /                         *
    *      \   Horizontal minima    /    /            \ /                          *
    * { --  o======================#====o   --------   .     ------------------- } *
    * {       Horizontal maxima    .                   %  scanline intersect     } *
    * { -- o=======================#===================#========o     ---------- } *
    *      |                      /                   / \        \                 *
    *      + maxima intersect    /                   /   \        \                *
    *     /|\                   /                   /     \        \               *
    *    / | \                 /                   /       \        \              *
    ****************************************************************************** *)

  E := FActiveEdges;
  while assigned(E) do
  begin
    // 1. process maxima, treating them as if they're 'bent' horizontal edges,
    // but exclude maxima with Horizontal edges. nb: E can't be a Horizontal.
    if IsMaxima(E, TopY) and (GetMaximaPair(E).Dx <> Horizontal) then
    begin
      // 'E' might be removed from AEL, as may any following edges so ...
      ePrev := E.PrevInAEL;
      DoMaxima(E, TopY);
      if not assigned(ePrev) then
        E := FActiveEdges
      else
        E := ePrev.NextInAEL;
    end
    else
    begin
      // 2. promote horizontal edges, otherwise update XCurr and YCurr ...
      if IsIntermediate(E, TopY) and (E.NextInLML.Dx = Horizontal) then
      begin
        if (E.OutIdx >= 0) then
        begin
          AddOutPt(E, FloatPoint(E.XTop, E.YTop));

          Hj := FHorizJoins;
          if assigned(Hj) then
            repeat
              if GetOverlapSegment(FloatPoint(Hj.Edge.XBot, Hj.Edge.YBot),
                FloatPoint(Hj.Edge.XTop, Hj.Edge.YTop),
                FloatPoint(E.NextInLML.XBot, E.NextInLML.YBot),
                FloatPoint(E.NextInLML.XTop, E.NextInLML.YTop), Pt, Pt2) then
                AddJoin(Hj.Edge, E.NextInLML, Hj.SavedIdx, E.OutIdx);
              Hj := Hj.Next;
            until Hj = FHorizJoins;

          AddHorzJoin(E.NextInLML, E.OutIdx);
        end;
        UpdateEdgeIntoAEL(E);
        AddEdgeToSEL(E);
      end
      else
      begin
        // this just simplifies horizontal processing ...
        E.XCurr := TopX(E, TopY);
        E.YCurr := TopY;
      end;
      E := E.NextInAEL;
    end;
  end;

  // 3. Process horizontals at the top of the scanbeam ...
  ProcessHorizontals;

  // 4. Promote intermediate vertices ...
  E := FActiveEdges;
  while assigned(E) do
  begin
    if IsIntermediate(E, TopY) then
    begin
      if (E.OutIdx >= 0) then
        AddOutPt(E, FloatPoint(E.XTop, E.YTop));
      UpdateEdgeIntoAEL(E);

      // if output polygons share an Edge, they'll need joining later ...
      ePrev := E.PrevInAEL;
      eNext := E.NextInAEL;
      if assigned(ePrev) and (ePrev.XCurr = E.XBot) and (ePrev.YCurr = E.YBot)
        and (E.OutIdx >= 0) and (ePrev.OutIdx >= 0) and
        (ePrev.YCurr > ePrev.YTop) and SlopesEqual(E, ePrev, FUseFullBitRange)
      then
      begin
        AddOutPt(ePrev, FloatPoint(E.XBot, E.YBot));
        AddJoin(E, ePrev);
      end
      else if assigned(eNext) and (eNext.XCurr = E.XBot) and
        (eNext.YCurr = E.YBot) and (E.OutIdx >= 0) and (eNext.OutIdx >= 0) and
        (eNext.YCurr > eNext.YTop) and SlopesEqual(E, eNext, FUseFullBitRange)
      then
      begin
        AddOutPt(eNext, FloatPoint(E.XBot, E.YBot));
        AddJoin(E, eNext);
      end;
    end;
    E := E.NextInAEL;
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.GetResult: TFloatPolygons;
var
  I, J, K, Cnt: Integer;
  OutRec: POutRec;
  Op: POutPt;
begin
  K := 0;
  SetLength(Result, FPolyOutList.Count);
  for I := 0 to FPolyOutList.Count - 1 do
    if assigned(FPolyOutList[I]) then
    begin
      // make sure each polygon has at least 3 vertices ...
      OutRec := FPolyOutList[I];
      Op := OutRec.Pts;
      if not assigned(Op) then
        Continue; // nb: not sorted
      Cnt := PointCount(Op);
      if (Cnt < 3) then
        Continue;

      SetLength(Result[K], Cnt);
      for J := 0 to Cnt - 1 do
      begin
        Result[K][J].X := Op.Pt.X;
        Result[K][J].Y := Op.Pt.Y;
        Op := Op.Next;
      end;
      inc(K);
    end;
  SetLength(Result, K);
end;
// ------------------------------------------------------------------------------

function TClipper.GetExResult: TExPolygons;
var
  I, J, K, M, PCnt, HCnt: Integer;
  OutRec: POutRec;
  Op: POutPt;
begin
  I := 0;
  M := 0;
  SetLength(Result, FPolyOutList.Count);
  while (M < FPolyOutList.Count) and assigned(FPolyOutList[M]) do
  begin
    OutRec := FPolyOutList[M];
    inc(M);
    Op := OutRec.Pts;
    if not assigned(Op) then
      break; // Continue;
    PCnt := PointCount(Op);
    if (PCnt < 3) then
      Continue;
    SetLength(Result[I].Outer, PCnt);
    for K := 0 to PCnt - 1 do
    begin
      Result[I].Outer[K].X := Op.Pt.X;
      Result[I].Outer[K].Y := Op.Pt.Y;
      Op := Op.Next;
    end;
    HCnt := 0;
    while (M + HCnt < FPolyOutList.Count) and
      (POutRec(FPolyOutList[M + HCnt]).IsHole) and
      assigned(POutRec(FPolyOutList[M + HCnt]).Pts) do
      inc(HCnt);
    SetLength(Result[I].Holes, HCnt);
    for J := 0 to HCnt - 1 do
    begin
      Op := POutRec(FPolyOutList[M]).Pts;
      PCnt := PointCount(Op);
      SetLength(Result[I].Holes[J], PCnt);
      for K := 0 to PCnt - 1 do
      begin
        Result[I].Holes[J][K].X := Op.Pt.X;
        Result[I].Holes[J][K].Y := Op.Pt.Y;
        Op := Op.Next;
      end;
      inc(M);
    end;
    inc(I);
  end;
  SetLength(Result, I);
end;
// ------------------------------------------------------------------------------

procedure TClipper.FixupOutPolygon(OutRec: POutRec);
var
  PP, Tmp, LastOK: POutPt;
begin
  // FixupOutPolygon() - removes duplicate points and simplifies consecutive
  // parallel edges by removing the middle vertex.
  LastOK := nil;
  OutRec.Pts := OutRec.BottomPt;
  PP := OutRec.Pts;
  while true do
  begin
    if (PP.Prev = PP) or (PP.Next = PP.Prev) then
    begin
      DisposePolyPts(PP);
      OutRec.Pts := nil;
      OutRec.BottomPt := nil;
      exit;
    end;

    // test for duplicate points and for colinear edges ...
    if PointsEqual(PP.Pt, PP.Next.Pt) or SlopesEqual(PP.Prev.Pt, PP.Pt,
      PP.Next.Pt, FUseFullBitRange) then
    begin
      // OK, we need to delete a point ...
      LastOK := nil;
      Tmp := PP;
      if PP = OutRec.BottomPt then
        OutRec.BottomPt := nil; // flags need for updating
      PP.Prev.Next := PP.Next;
      PP.Next.Prev := PP.Prev;
      PP := PP.Prev;
      dispose(Tmp);
    end
    else if PP = LastOK then
      break
    else
    begin
      if not assigned(LastOK) then
        LastOK := PP;
      PP := PP.Next;
    end;
  end;
  if not assigned(OutRec.BottomPt) then
  begin
    OutRec.BottomPt := GetBottomPt(PP);
    OutRec.BottomPt.Idx := OutRec.Idx;
    OutRec.Pts := OutRec.BottomPt;
    OutRec.BottomFlag := OutRec.BottomPt;
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.FixupIntersections: Boolean;
var
  E1, E2: PEdge;
  Int1, Int2: PIntersectNode;
begin
  Result := not assigned(FIntersectNodes.Next);
  if Result then
    exit;
  // logic: only swap (intersect) adjacent edges ...
  try
    CopyAELToSEL;
    Int1 := FIntersectNodes;
    Int2 := FIntersectNodes.Next;
    while assigned(Int2) do
    begin
      E1 := Int1.Edge1;
      if (E1.PrevInSEL = Int1.Edge2) then
        E2 := E1.PrevInSEL
      else if (E1.NextInSEL = Int1.Edge2) then
        E2 := E1.NextInSEL
      else
      begin
        // The current intersection is out of order, so try and swap it with
        // A subsequent intersection ...
        while assigned(Int2) do
        begin
          if (Int2.Edge1.NextInSEL = Int2.Edge2) or
            (Int2.Edge1.PrevInSEL = Int2.Edge2) then
            break
          else
            Int2 := Int2.Next;
        end;
        if not assigned(Int2) then
          exit; // oops!!!
        // found an intersect node that can be swapped ...
        SwapIntersectNodes(Int1, Int2);
        E1 := Int1.Edge1;
        E2 := Int1.Edge2;
      end;
      SwapPositionsInSEL(E1, E2);
      Int1 := Int1.Next;
      Int2 := Int1.Next;
    end;

    // finally, check the last intersection too ...
    Result := (Int1.Edge1.PrevInSEL = Int1.Edge2) or
      (Int1.Edge1.NextInSEL = Int1.Edge2);
  finally
    FSortedEdges := nil;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.SwapIntersectNodes(Int1, Int2: PIntersectNode);
var
  E1, E2: PEdge;
  P: TFloatPoint;
begin
  with Int1^ do
  begin
    E1 := Edge1;
    Edge1 := Int2.Edge1;
    E2 := Edge2;
    Edge2 := Int2.Edge2;
    P := Pt;
    Pt := Int2.Pt;
  end;
  with Int2^ do
  begin
    Edge1 := E1;
    Edge2 := E2;
    Pt := P;
  end;
end;
// ------------------------------------------------------------------------------

function FindSegment(var PP: POutPt; var Pt1, Pt2: TFloatPoint): Boolean;
var
  Pp2: POutPt;
  Pt1a, Pt2a: TFloatPoint;
begin
  if not assigned(PP) then
  begin
    Result := False;
    exit;
  end;
  Result := true;
  Pt1a := Pt1;
  Pt2a := Pt2;
  Pp2 := PP;
  repeat
    // test for co-linearity before testing for overlap ...
    if SlopesEqual(Pt1a, Pt2a, PP.Pt, PP.Prev.Pt, true) and
      SlopesEqual(Pt1a, Pt2a, PP.Pt, true) and GetOverlapSegment(Pt1a, Pt2a,
      PP.Pt, PP.Prev.Pt, Pt1, Pt2) then
      exit;
    PP := PP.Next;
  until PP = Pp2;
  Result := False;
end;
// ------------------------------------------------------------------------------

function Pt3IsBetweenPt1AndPt2(const Pt1, Pt2, Pt3: TFloatPoint): Boolean;
begin
  if PointsEqual(Pt1, Pt3) or PointsEqual(Pt2, Pt3) then
    Result := true
  else if (Pt1.X <> Pt2.X) then
    Result := (Pt1.X < Pt3.X) = (Pt3.X < Pt2.X)
  else
    Result := (Pt1.Y < Pt3.Y) = (Pt3.Y < Pt2.Y);
end;
// ------------------------------------------------------------------------------

function InsertPolyPtBetween(P1, P2: POutPt; const Pt: TFloatPoint): POutPt;
begin
  if (P1 = P2) then
    raise Exception.Create(rsJoinError);

  new(Result);
  Result.Pt := Pt;
  Result.Idx := P1.Idx;
  if P2 = P1.Next then
  begin
    P1.Next := Result;
    P2.Prev := Result;
    Result.Next := P2;
    Result.Prev := P1;
  end
  else
  begin
    P2.Next := Result;
    P1.Prev := Result;
    Result.Next := P1;
    Result.Prev := P2;
  end;
end;
// ------------------------------------------------------------------------------

function TClipper.JoinPoints(JR: PJoinRec; out P1, P2: POutPt): Boolean;
var
  OutRec1, OutRec2: POutRec;
  Prev, p3, p4, Pp1a, Pp2a: POutPt;
  Pt1, Pt2, Pt3, Pt4: TFloatPoint;
begin
  Result := False;
  OutRec1 := FPolyOutList[JR.Poly1Idx];
  OutRec2 := FPolyOutList[JR.Poly2Idx];
  if not assigned(OutRec1) then
    exit;
  if not assigned(OutRec2) then
    exit;

  Pp1a := OutRec1.Pts;
  Pp2a := OutRec2.Pts;
  Pt1 := JR.Pt2a;
  Pt2 := JR.Pt2b;
  Pt3 := JR.Pt1a;
  Pt4 := JR.Pt1b;
  if not FindSegment(Pp1a, Pt1, Pt2) then
    exit;
  if (OutRec1 = OutRec2) then
  begin
    // we're searching the same polygon for overlapping segments so
    // segment 2 mustn't be the same as segment 1 ...
    Pp2a := Pp1a.Next;
    if not FindSegment(Pp2a, Pt3, Pt4) or (Pp2a = Pp1a) then
      exit;
  end
  else if not FindSegment(Pp2a, Pt3, Pt4) then
    exit;

  if not GetOverlapSegment(Pt1, Pt2, Pt3, Pt4, Pt1, Pt2) then
    exit;

  Prev := Pp1a.Prev;
  if PointsEqual(Pp1a.Pt, Pt1) then
    P1 := Pp1a
  else if PointsEqual(Prev.Pt, Pt1) then
    P1 := Prev
  else
    P1 := InsertPolyPtBetween(Pp1a, Prev, Pt1);

  if PointsEqual(Pp1a.Pt, Pt2) then
    P2 := Pp1a
  else if PointsEqual(Prev.Pt, Pt2) then
    P2 := Prev
  else if (P1 = Pp1a) or (P1 = Prev) then
    P2 := InsertPolyPtBetween(Pp1a, Prev, Pt2)
  else if Pt3IsBetweenPt1AndPt2(Pp1a.Pt, P1.Pt, Pt2) then
    P2 := InsertPolyPtBetween(Pp1a, P1, Pt2)
  else
    P2 := InsertPolyPtBetween(P1, Prev, Pt2);

  Prev := Pp2a.Prev;
  if PointsEqual(Pp2a.Pt, Pt1) then
    p3 := Pp2a
  else if PointsEqual(Prev.Pt, Pt1) then
    p3 := Prev
  else
    p3 := InsertPolyPtBetween(Pp2a, Prev, Pt1);

  if PointsEqual(Pp2a.Pt, Pt2) then
    p4 := Pp2a
  else if PointsEqual(Prev.Pt, Pt2) then
    p4 := Prev
  else if (p3 = Pp2a) or (p3 = Prev) then
    p4 := InsertPolyPtBetween(Pp2a, Prev, Pt2)
  else if Pt3IsBetweenPt1AndPt2(Pp2a.Pt, p3.Pt, Pt2) then
    p4 := InsertPolyPtBetween(Pp2a, p3, Pt2)
  else
    p4 := InsertPolyPtBetween(p3, Prev, Pt2);

  if (P1.Next = P2) and (p3.Prev = p4) then
  begin
    P1.Next := p3;
    p3.Prev := P1;
    P2.Prev := p4;
    p4.Next := P2;
    Result := true;
  end
  else if (P1.Prev = P2) and (p3.Next = p4) then
  begin
    P1.Prev := p3;
    p3.Next := P1;
    P2.Next := p4;
    p4.Prev := P2;
    Result := true;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.FixupJoinRecs(JR: PJoinRec; Pt: POutPt; StartIdx: Integer);
var
  JR2: PJoinRec;
begin
  for StartIdx := StartIdx to FJoinList.Count - 1 do
  begin
    JR2 := FJoinList[StartIdx];
    if (JR2.Poly1Idx = JR.Poly1Idx) and PointIsVertex(JR2.Pt1a, Pt) then
      JR2.Poly1Idx := JR.Poly2Idx;
    if (JR2.Poly2Idx = JR.Poly1Idx) and PointIsVertex(JR2.Pt2a, Pt) then
      JR2.Poly2Idx := JR.Poly2Idx;
  end;
end;
// ------------------------------------------------------------------------------

procedure TClipper.JoinCommonEdges(FixHoleLinkages: Boolean);
var
  I, J, OKIdx, ObsoleteIdx: Integer;
  JR, JR2: PJoinRec;
  OutRec1, OutRec2: POutRec;
  P1, P2: POutPt;
const
  OutRec2InOutRec1 = 1;
  OutRec1InOutRec2 = 2;
begin
  for I := 0 to FJoinList.Count - 1 do
  begin
    JR := FJoinList[I];
    if not JoinPoints(JR, P1, P2) then
      Continue;

    OutRec1 := FPolyOutList[JR.Poly1Idx];
    OutRec2 := FPolyOutList[JR.Poly2Idx];

    if (OutRec1 = OutRec2) then
    begin
      // instead of joining two polygons, we've just created a new one by
      // splitting one polygon into two.
      OutRec1.Pts := GetBottomPt(P1);
      OutRec1.BottomPt := OutRec1.Pts;
      OutRec1.BottomPt.Idx := OutRec1.Idx;
      OutRec2 := CreateOutRec;
      OutRec2.Idx := FPolyOutList.Add(OutRec2);
      JR.Poly2Idx := OutRec2.Idx;
      OutRec2.Pts := GetBottomPt(P2);
      OutRec2.BottomPt := OutRec2.Pts;
      OutRec2.BottomPt.Idx := OutRec2.Idx;

      if PointInPolygon(OutRec2.Pts.Pt, OutRec1.Pts, FUseFullBitRange) then
      begin
        // OutRec2 is contained by OutRec1 ...
        OutRec2.IsHole := not OutRec1.IsHole;
        OutRec2.FirstLeft := OutRec1;

        // now fixup any subsequent joins that match the new polygon ...
        FixupJoinRecs(JR, P2, I + 1);

        FixupOutPolygon(OutRec1); // nb: do this BEFORE testing orientation
        FixupOutPolygon(OutRec2); // but AFTER calling FixupJoinRecs()

        if (OutRec2.IsHole = FReverseOutput) xor Orientation(OutRec2,
          FUseFullBitRange) then
          ReversePolyPtLinks(OutRec2.Pts);
      end
      else if PointInPolygon(OutRec1.Pts.Pt, OutRec2.Pts, FUseFullBitRange) then
      begin
        // OutRec1 is contained by OutRec2 ...
        OutRec2.IsHole := OutRec1.IsHole;
        OutRec1.IsHole := not OutRec2.IsHole;
        OutRec2.FirstLeft := OutRec1.FirstLeft;
        OutRec1.FirstLeft := OutRec2;

        // now fixup any subsequent joins that match the new polygon ...
        FixupJoinRecs(JR, P2, I + 1);

        FixupOutPolygon(OutRec1); // nb: do this BEFORE testing orientation
        FixupOutPolygon(OutRec2); // but AFTER calling PointIsVertex()

        if (OutRec1.IsHole = FReverseOutput) xor Orientation(OutRec1,
          FUseFullBitRange) then
          ReversePolyPtLinks(OutRec1.Pts);
        // make sure any contained holes now link to the correct polygon ...
        if FixHoleLinkages and OutRec1.IsHole then
          for J := 0 to FPolyOutList.Count - 1 do
            with POutRec(FPolyOutList[J])^ do
              if IsHole and assigned(BottomPt) and (FirstLeft = OutRec1) then
                FirstLeft := OutRec2;
      end
      else
      begin
        // the 2 polygons are completely separate ...
        OutRec2.IsHole := OutRec1.IsHole;
        OutRec2.FirstLeft := OutRec1.FirstLeft;

        // now fixup any subsequent joins that match the new polygon ...
        FixupJoinRecs(JR, P2, I + 1);

        FixupOutPolygon(OutRec1); // nb: do this BEFORE testing orientation
        FixupOutPolygon(OutRec2); // but AFTER calling PointIsVertex()

        if FixHoleLinkages and assigned(OutRec2.Pts) then
          for J := 0 to FPolyOutList.Count - 1 do
            with POutRec(FPolyOutList[J])^ do
              if IsHole and assigned(BottomPt) and (FirstLeft = OutRec1) then
                if PointInPolygon(BottomPt.Pt, OutRec2.Pts, FUseFullBitRange)
                then
                  FirstLeft := OutRec2;
      end;

      // check for self-intersection rounding artifacts and correct ...
      if (Orientation(OutRec1, FUseFullBitRange) <>
        (Area(OutRec1, FUseFullBitRange) >= 0)) then
        DisposeBottomPt(OutRec1);
      if (Orientation(OutRec2, FUseFullBitRange) <>
        (Area(OutRec2, FUseFullBitRange) >= 0)) then
        DisposeBottomPt(OutRec2);
    end
    else
    begin
      // joined 2 polygons together ...

      // make sure any holes contained by OutRec2 now link to OutRec1 ...
      if FixHoleLinkages then
        for J := 0 to FPolyOutList.Count - 1 do
          with POutRec(FPolyOutList[J])^ do
            if IsHole and assigned(BottomPt) and (FirstLeft = OutRec2) then
              FirstLeft := OutRec1;

      // cleanup edges ...
      FixupOutPolygon(OutRec1);

      if assigned(OutRec1.Pts) then
      begin
        OutRec1.IsHole := not Orientation(OutRec1, FUseFullBitRange);
        if OutRec1.IsHole and not assigned(OutRec1.FirstLeft) then
          OutRec1.FirstLeft := OutRec2.FirstLeft;
      end;

      // delete the obsolete pointer ...
      OKIdx := OutRec1.Idx;
      ObsoleteIdx := OutRec2.Idx;
      OutRec2.Pts := nil;
      OutRec2.BottomPt := nil;
      OutRec2.AppendLink := OutRec1;

      // now fixup any subsequent joins ...
      for J := I + 1 to FJoinList.Count - 1 do
      begin
        JR2 := FJoinList[J];
        if (JR2.Poly1Idx = ObsoleteIdx) then
          JR2.Poly1Idx := OKIdx;
        if (JR2.Poly2Idx = ObsoleteIdx) then
          JR2.Poly2Idx := OKIdx;
      end;

    end;
  end;
end;

// ------------------------------------------------------------------------------
// OffsetPolygons ...
// ------------------------------------------------------------------------------

function GetUnitNormal(const Pt1, Pt2: TFloatPoint): TFloatPoint;
var
  Dx, Dy, F: single;
begin
  if (Pt2.X = Pt1.X) and (Pt2.Y = Pt1.Y) then
  begin
    Result.X := 0;
    Result.Y := 0;
    exit;
  end;

  Dx := (Pt2.X - Pt1.X);
  Dy := (Pt2.Y - Pt1.Y);
  F := 1 / Hypot(Dx, Dy);
  Dx := Dx * F;
  Dy := Dy * F;
  Result.X := Dy;
  Result.Y := -Dx
end;
// ------------------------------------------------------------------------------

function BuildArc(const Pt: TFloatPoint; A1, A2, R: single): TFloatPolygon;
var
  I, N: Integer;
  A, D: double;
  Steps: int64;
  S, c: extended; // sin & cos
begin
  Steps := max(6, round(Sqrt(abs(R)) * abs(A2 - A1)));
  if Steps > $100 then
    Steps := $100;
  SetLength(Result, Steps);
  N := Steps - 1;
  D := (A2 - A1) / N;
  A := A1;
  for I := 0 to N do
  begin
    SinCos(A, S, c);
    Result[I].X := Pt.X + round(c * R);
    Result[I].Y := Pt.Y + round(S * R);
    A := A + D;
  end;
end;
// ------------------------------------------------------------------------------

function GetBounds(const Pts: TFloatPolygons): TfloatRect;
var
  I, J: Integer;
begin
  with Result do
  begin
    Left := Pts[0][0].X;
    Top := Pts[0][0].Y;
    Right := Pts[0][0].X;
    Bottom := Pts[0][0].Y;
  end;
  for I := 0 to high(Pts) do
    for J := 0 to high(Pts[I]) do
    begin
      if Pts[I][J].X < Result.Left then
        Result.Left := Pts[I][J].X;
      if Pts[I][J].X > Result.Right then
        Result.Right := Pts[I][J].X;
      if Pts[I][J].Y < Result.Top then
        Result.Top := Pts[I][J].Y;
      if Pts[I][J].Y > Result.Bottom then
        Result.Bottom := Pts[I][J].Y;
    end;
  if Result.Left > HiRange then
    with Result do
    begin
      Left := 0;
      Top := 0;
      Right := 0;
      Bottom := 0;
    end;
end;
// ------------------------------------------------------------------------------

function OffsetPolygons(const Polys: TFloatPolygons; const Delta: double;
  JoinType: TJoinType = jtSquare; MiterLimit: double = 2;
  ChecksInput: Boolean = true): TFloatPolygons;
var
  I, J, K, len, OutLen, BotI: Integer;
  Normals: TArrayOfDoublePoint;
  R, RMin: double;
  Pt1, Pt2: TFloatPoint;
  Outer: TFloatPolygon;
  Bounds: TfloatRect;
  Pts: TFloatPolygons;
  BotPt: TFloatPoint;
  OffSetClipper: TClipper;
const
  BuffLength: Integer = 128;

  procedure AddPoint(const Pt: TFloatPoint);
  var
    len: Integer;
  begin
    len := length(Result[I]);
    if OutLen = len then
      SetLength(Result[I], len + BuffLength);
    Result[I][OutLen] := Pt;
    inc(OutLen);
  end;

  procedure DoSquare(mul: double = 1.0);
  var
    A1, A2, Dx: double;
  begin
    Pt1.X := round(Pts[I][J].X + Normals[K].X * Delta);
    Pt1.Y := round(Pts[I][J].Y + Normals[K].Y * Delta);
    Pt2.X := round(Pts[I][J].X + Normals[J].X * Delta);
    Pt2.Y := round(Pts[I][J].Y + Normals[J].Y * Delta);
    if ((Normals[K].X * Normals[J].Y - Normals[J].X * Normals[K].Y) * Delta >= 0)
    then
    begin
      A1 := ArcTan2(Normals[K].Y, Normals[K].X);
      A2 := ArcTan2(-Normals[J].Y, -Normals[J].X);
      A1 := abs(A2 - A1);
      if A1 > pi then
        A1 := pi * 2 - A1;
      Dx := tan((pi - A1) / 4) * abs(Delta * mul);

      Pt1 := FloatPoint(round(Pt1.X - Normals[K].Y * Dx),
        round(Pt1.Y + Normals[K].X * Dx));
      AddPoint(Pt1);
      Pt2 := FloatPoint(round(Pt2.X + Normals[J].Y * Dx),
        round(Pt2.Y - Normals[J].X * Dx));
      AddPoint(Pt2);
    end
    else
    begin
      AddPoint(Pt1);
      AddPoint(Pts[I][J]);
      AddPoint(Pt2);
    end;
  end;

  procedure DoMiter;
  var
    Q: double;
  begin
    if ((Normals[K].X * Normals[J].Y - Normals[J].X * Normals[K].Y) * Delta >= 0)
    then
    begin
      Q := Delta / R;
      AddPoint(FloatPoint(round(Pts[I][J].X + (Normals[K].X + Normals[J].X) *
        Q), round(Pts[I][J].Y + (Normals[K].Y + Normals[J].Y) * Q)));
    end
    else
    begin
      Pt1.X := round(Pts[I][J].X + Normals[K].X * Delta);
      Pt1.Y := round(Pts[I][J].Y + Normals[K].Y * Delta);
      Pt2.X := round(Pts[I][J].X + Normals[J].X * Delta);
      Pt2.Y := round(Pts[I][J].Y + Normals[J].Y * Delta);
      AddPoint(Pt1);
      AddPoint(Pts[I][J]);
      AddPoint(Pt2);
    end;
  end;

  procedure DoRound;
  var
    M: Integer;
    Arc: TFloatPolygon;
    A1, A2: double;
  begin
    Pt1.X := round(Pts[I][J].X + Normals[K].X * Delta);
    Pt1.Y := round(Pts[I][J].Y + Normals[K].Y * Delta);
    Pt2.X := round(Pts[I][J].X + Normals[J].X * Delta);
    Pt2.Y := round(Pts[I][J].Y + Normals[J].Y * Delta);
    AddPoint(Pt1);
    // round off reflex angles (ie > 180 deg) unless almost flat (ie < 10deg).
    // (N1.X * N2.Y - N2.X * N1.Y) == unit normal "cross product" == sin(angle)
    // (N1.X * N2.X + N1.Y * N2.Y) == unit normal "dot product" == cos(angle)
    // dot product Normals == 1 -> no angle
    if ((Normals[K].X * Normals[J].Y - Normals[J].X * Normals[K].Y) * Delta >= 0)
    then
    begin
      if ((Normals[J].X * Normals[K].X + Normals[J].Y * Normals[K].Y) < 0.985)
      then
      begin
        A1 := ArcTan2(Normals[K].Y, Normals[K].X);
        A2 := ArcTan2(Normals[J].Y, Normals[J].X);
        if (Delta > 0) and (A2 < A1) then
          A2 := A2 + pi * 2
        else if (Delta < 0) and (A2 > A1) then
          A2 := A2 - pi * 2;
        Arc := BuildArc(Pts[I][J], A1, A2, Delta);
        for M := 0 to high(Arc) do
          AddPoint(Arc[M]);
      end;
    end
    else
      AddPoint(Pts[I][J]);
    AddPoint(Pt2);
  end;

  function UpdateBotPt(const Pt: TFloatPoint; var BotPt: TFloatPoint): Boolean;
  begin
    if (Pt.Y > BotPt.Y) or ((Pt.Y = BotPt.Y) and (Pt.X < BotPt.X)) then
    begin
      BotPt := Pt;
      Result := true;
    end
    else
      Result := False;
  end;

begin
  Result := nil;

  // ChecksInput - fixes polygon orientation if necessary and removes
  // duplicate vertices. Can be set false when you're sure that polygon
  // orientation is correct and that there are no duplicate vertices.
  if ChecksInput then
  begin
    len := length(Polys);
    SetLength(Pts, len);
    BotI := 0; // index of outermost polygon
    while (BotI < len) and (length(Polys[BotI]) = 0) do
      inc(BotI);
    if (BotI = len) then
      exit;
    BotPt := Polys[BotI][0];
    for I := BotI to len - 1 do
    begin
      len := length(Polys[I]);
      SetLength(Pts[I], len);
      if len = 0 then
        Continue;
      Pts[I][0] := Polys[I][0];
      if UpdateBotPt(Pts[I][0], BotPt) then
        BotI := I;
      K := 0;
      for J := 1 to len - 1 do
        if not PointsEqual(Pts[I][K], Polys[I][J]) then
        begin
          inc(K);
          Pts[I][K] := Polys[I][J];
          if UpdateBotPt(Pts[I][K], BotPt) then
            BotI := I;
        end;
      if K + 1 < len then
        SetLength(Pts[I], K + 1);
    end;
    if not Orientation(Pts[BotI]) then
      Pts := ReversePolygons(Pts);
  end
  else
    Pts := Polys;

  // MiterLimit defaults to twice Delta's width ...
  if MiterLimit <= 1 then
    MiterLimit := 1;
  RMin := 2 / (sqr(MiterLimit));

  SetLength(Result, length(Pts));
  for I := 0 to high(Pts) do
  begin
    Result[I] := nil;
    len := length(Pts[I]);
    if (len > 1) and (Pts[I][0].X = Pts[I][len - 1].X) and
      (Pts[I][0].Y = Pts[I][len - 1].Y) then
      dec(len);

    if (len = 0) or ((len < 3) and (Delta <= 0)) then
      Continue
    else if (len = 1) then
    begin
      Result[I] := BuildArc(Pts[I][0], 0, 2 * pi, Delta);
      Continue;
    end;

    // build Normals ...
    SetLength(Normals, len);
    for J := 0 to len - 2 do
      Normals[J] := GetUnitNormal(Pts[I][J], Pts[I][J + 1]);
    Normals[len - 1] := GetUnitNormal(Pts[I][len - 1], Pts[I][0]);

    OutLen := 0;
    K := len - 1;
    for J := 0 to len - 1 do
    begin
      case JoinType of
        jtMiter:
          begin
            R := 1 + (Normals[J].X * Normals[K].X + Normals[J].Y *
              Normals[K].Y);
            if (R >= RMin) then
              DoMiter
            else
              DoSquare(MiterLimit);
          end;
        jtSquare:
          DoSquare;
        jtRound:
          DoRound;
      end;
      K := J;
    end;
    SetLength(Result[I], OutLen);
  end;

  // finally, clean up untidy corners ...
  try
    OffSetClipper := TClipper.Create;
    OffSetClipper.AddPolygons(Result, ptSubject);
    if Delta > 0 then
    begin
      OffSetClipper.Execute(ctUnion, Result, pftPositive, pftPositive);
    end
    else
    begin
      Bounds := GetBounds(Result);
      SetLength(Outer, 4);
      Outer[0] := FloatPoint(Bounds.Left - 10, Bounds.Bottom + 10);
      Outer[1] := FloatPoint(Bounds.Right + 10, Bounds.Bottom + 10);
      Outer[2] := FloatPoint(Bounds.Right + 10, Bounds.Top - 10);
      Outer[3] := FloatPoint(Bounds.Left - 10, Bounds.Top - 10);
      OffSetClipper.AddPolygon(Outer, ptSubject);
      OffSetClipper.Execute(ctUnion, Result, pftNegative, pftNegative);
      // delete the outer rectangle ...
      len := length(Result);
      for J := 1 to len - 1 do
        Result[J - 1] := Result[J];
      if len > 0 then
        SetLength(Result, len - 1);
      // restore polygon orientation ...
      Result := ReversePolygons(Result);
    end;
  finally
    OffSetClipper.Free;
  end;
end;
// ------------------------------------------------------------------------------

function SimplifyPolygon(const poly: TFloatPolygon;
  FillType: TPolyFillType = pftEvenOdd): TFloatPolygons;
var
  simpclipper: TClipper;
begin
  try
    simpclipper := TClipper.Create;
    simpclipper.AddPolygon(poly, ptSubject);
    simpclipper.Execute(ctUnion, Result, FillType, FillType);
  finally
    simpclipper.Free;
  end;
end;
// ------------------------------------------------------------------------------

function SimplifyPolygons(const Polys: TFloatPolygons;
  FillType: TPolyFillType = pftEvenOdd): TFloatPolygons;
var
  simpclipper: TClipper;
begin
  try
    simpclipper := TClipper.Create;
    simpclipper.AddPolygons(Polys, ptSubject);
    simpclipper.Execute(ctUnion, Result, FillType, FillType);
  finally
    simpclipper.Free;
  end;
end;

procedure ClearPolygons(var polygons: TFloatPolygons);
var
  I: Integer;
begin
  for I := 0 to High(polygons) do
  begin
    Finalize(polygons[I]);
  end;
  Finalize(polygons);
end;

end.
