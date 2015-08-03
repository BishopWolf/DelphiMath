Unit uGraphics;

(* ******************************************************************************
  * Graphics Objects for ROI treatment                                          *
  * Author    :  Alex Vergara Gil                                               *
  * Version   :  0.1                                                            *
  * Date      :  19 December 2012                                               *
  *                                                                             *
  *                                                                             *
  ****************************************************************************** *)

Interface

{$DEFINE USE_FLOAT_PRECISSION}

Uses uconstants, utypes, windows, graphics, sysutils,
{$IFDEF USE_FLOAT_PRECISSION}
  clipperfloat,
{$ELSE}
  clipper,
{$ENDIF}
  uBaseGeometry;

Type
  /// <summary>
  /// Vertex type
  /// </summary>
  /// <remarks>
  /// basically an array of points
  /// </remarks>
  AVertex = {$IFDEF USE_FLOAT_PRECISSION} TfloatPolygon {$ELSE} TIntPolygon
{$ENDIF};
  myPoint = {$IFDEF USE_FLOAT_PRECISSION} TfloatPoint {$ELSE} TIntPoint
{$ENDIF};
  myPoint3D = {$IFDEF USE_FLOAT_PRECISSION} TfloatPoint3D {$ELSE} TIntPoint3D
{$ENDIF};
  myPrecType = {$IFDEF USE_FLOAT_PRECISSION} float {$ELSE} Int64 {$ENDIF};
  APoint = Array Of myPoint;
  vclPoints = Array Of TPoint; // compatibility with vcl
  TPolygons = {$IFDEF USE_FLOAT_PRECISSION} TfloatPolygons {$ELSE} TIntPolygons
{$ENDIF};
  TPolygonOrientation = (TPOClockWise, TPONone, TPOCounterClockWise);
  TPolygonSetOperation = (ctReplace, ctMove, ctRotate, ctUnion, ctDifference,
    ctIntersection, ctXor);

  TBox = Record
    ini, fin: myPoint3D;
  End;

  /// <summary>
  /// Polygon class
  /// </summary>
  /// <remarks>
  /// Consider always a closed loop polygon, last vertex is linked to first
  /// </remarks>
  TPolygon = Class
  Private
    FMax: myPoint;
    FMin: myPoint;
    Procedure SetOrientation(Const Value: TPolygonOrientation);
    Function GetOrientation: TPolygonOrientation;
  Protected
    FVertex: AVertex;
    Fsize: integer;
    Function GetVertex(ind: integer): myPoint;
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
    Procedure SetVertex(ind: integer; Const lVertex: myPoint);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
  Public
    Property Vertex[ind: integer]: myPoint Read GetVertex Write SetVertex;
    Property size: integer Read Fsize;
    Property Min: myPoint Read FMin;
    Property Max: myPoint Read FMax;
    Property Orientation: TPolygonOrientation Read GetOrientation
      Write SetOrientation;
    Constructor Create; Overload;
    Constructor Create(Const lPolygon: TPolygon); Overload;
    Constructor Create(Const lPolygon: TfloatPolygon); Overload;
    Destructor Destroy; Override;
    Procedure AddVertex(ind: integer; Const lVertex: myPoint); Overload;
    Procedure AppendVertex(Const lVertex: myPoint); Overload;
    Procedure AddVertex(ind: integer; X, Y: float); Overload;
    Procedure AppendVertex(X, Y: float); Overload;
    Procedure DeleteVertex(ind: integer);
    // procedure Simplify;
    Procedure Copy(Const lPolygon: TPolygon); Overload;
    Procedure Copy(Const lPolygon: TfloatPolygon); Overload;
    Procedure Clear;
    Procedure ChangeOrientation;
    Function GetPoints(reversed: boolean = false): APoint; Overload;
    Function GetvclPoints(reversed: boolean = false): vclPoints; Overload;
    Function GetPoints(Xscale, Yscale: float; reversed: boolean = false)
      : APoint; Overload;
    Function GetvclPoints(Xscale, Yscale: float; reversed: boolean = false)
      : vclPoints; Overload;
    Procedure MinMax;
    Function Area: float;
    Procedure Move(Const X, Y: float); Overload;
    Procedure Move(Const lvector: myPoint); Overload;
    Procedure Rotate(Const lAngle: float); Overload;
    Procedure Rotate(Const x1, y1, x2, y2: float); Overload;
    Procedure Rotate(Const lCenter: TPoint; Const lAngle: float); Overload;
    Procedure Escala(Const mx, my: float);
    Function Center: myPoint;
    Function PolygonSetOperation(Const Other: TPolygon;
      Operation: TPolygonSetOperation; Out Res: TPolygons;
      wantRegular: boolean = true): boolean;
    /// <summary>
    /// checks if a point is inside the polygon
    /// </summary>
    /// <param name="lPoint">
    /// the point checked
    /// </param>
    /// <returns>
    /// if it is inside then result true
    /// </returns>
    /// <remarks>
    /// This procedure counts how many lines the polygon has over the point y
    /// coodinate. If the point is on the border of the polygon then it is
    /// considered inside.
    /// </remarks>
    Function PointInside(Const lPoint: myPoint): boolean; Overload;
    Function PointInside(Const X, Y: float): boolean; Overload;
    Function PointInBound(Const lPoint: myPoint): boolean; Overload;
    Function PointInBound(Const X, Y: float): boolean; Overload;
  End;

  APolygon = Array Of TPolygon;

  TLayer = Class
    // ToDO: when this is done then TPolyROI will be an array of TLayer
  Private
    FPolygon: APolygon;
    Fsize: integer;
    FPosition: float;
    FMax: myPoint;
    FMin: myPoint;
    Procedure SetPolygon(ind: integer; Const lPolygon: TPolygon);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
    Function GetPolygon(ind: integer): TPolygon;
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
    Procedure SetPosition(Const Value: float);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
    Function clipperpolygons: TPolygons;
  Public
    Constructor Create(Zposition: float); Overload;
    Constructor Create(lOther: TLayer); Overload;
    Constructor Create(Z: float; lOther: TPolygons); Overload;
    Destructor Destroy; Override;
    Procedure Clear;
    Property Min: myPoint Read FMin;
    Property Max: myPoint Read FMax;
    Procedure Copy(lOther: TLayer); Overload;
    Procedure Copy(Z: float; lOther: TPolygons); Overload;
    Procedure ChangeOrientation;
    Property Position: float Read FPosition Write SetPosition;
    Property size: integer Read Fsize;
    Property Polygon[ind: integer]: TPolygon Read GetPolygon Write SetPolygon;
    Procedure AddPolygon(Const lPolygon: TPolygon;
      Operation: TPolygonSetOperation); Overload;
    Procedure AddPolygon(Const lPolygon: TfloatPolygon;
      Operation: TPolygonSetOperation); Overload;
    Procedure AppendPolygon(Const lPolygon: TPolygon;
      Operation: TPolygonSetOperation); Overload;
    Procedure AppendPolygon(Const lPolygon: TfloatPolygon;
      Operation: TPolygonSetOperation); Overload;
    Procedure AddSegment(Head, Tail: myPoint);
    Procedure DeletePolygon(ind: integer);
    Procedure MinMax;
    Procedure Escala(Const mx, my: float);
    Procedure Move(Const X, Y: float); Overload;
    Procedure Rotate(Const lCenter: TPoint; Const lAngle: float);
    Procedure OffSet(Const Delta: double; JoinType: TJoinType = jtSquare;
      MiterLimit: double = 2; ChecksInput: boolean = true);
    Procedure Simplify;
    Function Area: float;
    Function PointInBound(Const lPoint: myPoint): boolean; Overload;
    Function PointInBound(Const X, Y: float): boolean; Overload;
    Function PointInside(Const lPoint: myPoint): boolean; Overload;
    Function PointInside(Const X, Y: float): boolean; Overload;
    Procedure PaintPolygons(Var Bitmap: TBitmap);
    Procedure PaintPolyline(Var Bitmap: TBitmap);
    Procedure PaintPolyBezier(Var Bitmap: TBitmap);
  End;

  ALayer = Array Of TLayer;

  TPolyROI = Class
  Private
    Fsize: integer;
    FLayer: ALayer;
    jsav, dj: integer;
    fcorrelated: boolean;
    Procedure SetLayer(ind: integer; Const lLayer: TLayer);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
    Function GetLayer(ind: integer): TLayer; {$IFDEF INLININGSUPPORTED}Inline;
{$ENDIF}
  Public
    Constructor Create; Overload;
    Constructor Create(lOther: TPolyROI); Overload;
    Destructor Destroy; Override;
    Procedure Clear;
    Property Layer[ind: integer]: TLayer Read GetLayer Write SetLayer;
    Property size: integer Read Fsize;
    Function NumberTotal: integer;
    Procedure AddPolygon(Z: float; lPolygon: TPolygon;
      loperation: TPolygonSetOperation); Overload;
    Procedure AddPolygon(Z: float; lPolygon: TfloatPolygon;
      loperation: TPolygonSetOperation); Overload;
    Procedure AppendPolygon(Z: float; lPolygon: TPolygon;
      loperation: TPolygonSetOperation); Overload;
    Procedure AppendPolygon(Z: float; lPolygon: TfloatPolygon;
      loperation: TPolygonSetOperation); Overload;
    Procedure AddLayer(Const lLayer: TLayer); Overload;

    /// <summary>
    /// Add a layer to TPolyROI in the z position, if there is a layer in the
    /// z position then replace it
    /// </summary>
    /// <param name="Z">
    /// Position in space
    /// </param>
    /// <param name="lLayer">
    /// the layer to be added
    /// </param>
    /// <param name="Ub">
    /// the size of the layer
    /// </param>
    Procedure AddLayer(Z: float; lLayer: TPolygons); Overload;
    Procedure AppendLayer(Const lLayer: TLayer); Overload;
    Procedure AppendLayer(Z: float; lLayer: TPolygons); Overload;
    Procedure ChangeOrientation;
    Procedure DeleteLayer(Zposition: float);
    Procedure Save2File(lFile: TFileName);
    Constructor ReadFromFile(lFile: TFileName);
    Procedure Save2FileI(lFile: TFileName);
    Constructor ReadFromFileI(lFile: TFileName);
    Procedure MinMax(Out lMinMax: TBox);
    Procedure Move(Const X, Y, Z: float); Overload;
    Procedure Escala(Const mx, my, mz: float); Overload;
    Procedure Move(Const lvector: myPoint3D); Overload;
    Procedure Escala(Const lEscala: myPoint3D); Overload;
    Function Volume: float;
    Procedure Sort;
    Procedure Simplify(Ztaken: float);
    Property correlated: boolean Read fcorrelated;
    Function LocateZ(Z: float): integer;
    Function HuntZ(Z: float): integer;
    /// <summary>
    /// Expands the polygons in selected slice over the entire image
    /// </summary>
    /// <param name="Ztaken">
    /// slice selected
    /// </param>
    /// <param name="Zsize">
    /// image z size
    /// </param>
    /// <remarks>
    /// for a quick mask over the entire study
    /// </remarks>
    Procedure ExpandoverZ(Ztaken, Zini, Zfin: float);

    /// <summary>
    /// checks if a point is inside the ROI for a given Z
    /// </summary>
    /// <param name="lPoint">
    /// the point checked
    /// </param>
    /// <returns>
    /// if it is inside then result true
    /// </returns>
    /// <remarks>
    /// This procedure uses the same convention mentioned before for polygons.
    /// </remarks>
    Function PointInside(Const lPoint: myPoint; Ztaken: float)
      : boolean; Overload;
    Function PointInside(Const X, Y: float; Ztaken: float): boolean; Overload;
    Function PointInBound(Const lPoint: myPoint; Ztaken: float)
      : boolean; Overload;
    Function PointInBound(Const X, Y: float; Ztaken: float): boolean; Overload;
    Procedure PaintPolygons(Ztaken: float; Var Bitmap: TBitmap);
    Procedure PaintPolyline(Ztaken: float; Var Bitmap: TBitmap);
    Procedure PaintPolyBezier(Ztaken: float; Var Bitmap: TBitmap);
  End;

  /// <summary>
  /// calculates if three points are colinear
  /// </summary>
  /// <param name="P1">
  /// first point
  /// </param>
  /// <param name="P2">
  /// second point
  /// </param>
  /// <param name="P3">
  /// third point
  /// </param>
  /// <returns>
  /// if they are colinear then result is true
  /// </returns>
  /// <remarks>
  /// compares the slope formed by p3-p2 and p2-p1 and the intercept on y axis
  /// </remarks>
Function Colinear(Const P1, P2, P3: myPoint): boolean;
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
Function Angle(Const P1, P2: myPoint): float;
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
Procedure Rotate(Var P1: myPoint; Const Center: myPoint; lAngle: float);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF} Overload;
Procedure Rotate(Var P1: TPoint; Const Center: TPoint; lAngle: float);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF} Overload;
Procedure Rotate(Var P1: myPoint; Const Center: myPoint; SinX, CosX: float);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF} Overload;
Procedure Rotate(Var P1: TPoint; Const Center: TPoint; SinX, CosX: float);
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF} Overload;

Implementation

Uses uinterpolation, math, uoperations, umath, classes, dialogs, utrigo;

Function Colinear(Const P1, P2, P3: myPoint): boolean;
Var
  xdif: float;
Begin
  If (P3.X = P2.X) Then
  Begin
    If (P2.X = P1.X) Then // vertical linearity
      result := true
    Else
      result := false;
  End
  Else
  Begin
    xdif := divide(P2.X - P1.X, P3.X - P2.X); // one divition, 7 multiplications
    result := ((P3.Y - P2.Y) * xdif = (P2.Y - P1.Y)) And
      ((P3.Y * P2.X - P2.Y * P3.X) * xdif = (P2.Y * P1.X - P1.Y * P2.X));
  End;
End;

Function Angle(Const P1, P2: myPoint): float;
Begin
  result := ArcTan2(P1.X * P2.Y - P1.Y * P2.X, P1.X * P2.X + P1.Y * P2.Y);
End;

Procedure Rotate(Var P1: myPoint; Const Center: myPoint; lAngle: float);
Var
  distX, distY: float;
  SinX, CosX: extended; // Mandatory for sincos function!!!
Begin
  distX := P1.X - Center.X;
  distY := P1.Y - Center.Y;
  SinCos(lAngle, SinX, CosX);
  P1 := FloatPoint((Center.X + distX * CosX + distY * SinX),
    (Center.Y - distX * SinX + distY * CosX));
End;

Procedure Rotate(Var P1: TPoint; Const Center: TPoint; lAngle: float);
Var
  distX, distY: float;
  SinX, CosX: extended; // Mandatory for sincos function!!!
Begin
  distX := P1.X - Center.X;
  distY := P1.Y - Center.Y;
  SinCos(lAngle, SinX, CosX);
  P1 := Point(round(Center.X + distX * CosX + distY * SinX),
    round(Center.Y - distX * SinX + distY * CosX));
End;

Procedure Rotate(Var P1: myPoint; Const Center: myPoint; SinX, CosX: float);
Var
  distX, distY: float;
Begin
  distX := P1.X - Center.X;
  distY := P1.Y - Center.Y;
  P1 := FloatPoint(Center.X + distX * CosX + distY * SinX,
    Center.Y - distX * SinX + distY * CosX);
End;

Procedure Rotate(Var P1: TPoint; Const Center: TPoint; SinX, CosX: float);
Var
  distX, distY: float;
Begin
  distX := P1.X - Center.X;
  distY := P1.Y - Center.Y;
  P1 := Point(round(Center.X + distX * CosX + distY * SinX),
    round(Center.Y - distX * SinX + distY * CosX));
End;

{ TPolygon }

Procedure TPolygon.AddVertex(ind: integer; Const lVertex: myPoint);
Var
  i: integer;
Begin
  If ((ind > 0) And (ind <= Fsize)) Then
  Begin
    If (FVertex[ind - 1] <> lVertex) Then
    // Don't add the same vertex again!!
    Begin
      inc(Fsize);
      SetLength(FVertex, Fsize);
      For i := Fsize Downto ind + 1 Do
        FVertex[i - 1] := FVertex[i - 2];
      FVertex[ind - 1] := lVertex;
      If (FMin.X > lVertex.X) Or (FMin.X < 0) Then
        FMin.X := lVertex.X;
      If (FMax.X < lVertex.X) Or (FMax.X < 0) Then
        FMax.X := lVertex.X;
      If (FMin.Y > lVertex.Y) Or (FMin.Y < 0) Then
        FMin.Y := lVertex.Y;
      If (FMax.Y < lVertex.Y) Or (FMax.Y < 0) Then
        FMax.Y := lVertex.Y;
    End;
  End
  Else If ind > Fsize Then
    AppendVertex(lVertex);
End;

Procedure TPolygon.AddVertex(ind: integer; X, Y: float);
Begin
  AddVertex(ind, FloatPoint(X, Y));
End;

Procedure TPolygon.AppendVertex(Const lVertex: myPoint);
Begin
  If (Fsize = 0) Or ((Fsize > 0) And (FVertex[Fsize - 1] <> lVertex)) Then
  // Don't add the same vertex again!!
  Begin
    inc(Fsize);
    SetLength(FVertex, Fsize);
    FVertex[Fsize - 1] := lVertex;
    If (FMin.X > lVertex.X) Or (FMin.X < 0) Then
      FMin.X := lVertex.X;
    If (FMax.X < lVertex.X) Or (FMax.X < 0) Then
      FMax.X := lVertex.X;
    If (FMin.Y > lVertex.Y) Or (FMin.Y < 0) Then
      FMin.Y := lVertex.Y;
    If (FMax.Y < lVertex.Y) Or (FMax.Y < 0) Then
      FMax.Y := lVertex.Y;
  End;
End;

Procedure TPolygon.AppendVertex(X, Y: float);
Begin
  AppendVertex(FloatPoint(X, Y));
End;

Function TPolygon.Area: float;
Begin
  Area := clipperfloat.Area(FVertex);
End;

Function TPolygon.Center: myPoint;
Begin
  clipperfloat.Area(FVertex, result);
End;

Procedure TPolygon.ChangeOrientation;
Begin
  If Orientation = TPONone Then
    exit;
  If Orientation = TPOClockWise Then
    SetOrientation(TPOCounterClockWise)
  Else
    SetOrientation(TPOClockWise);
End;

Procedure TPolygon.Clear;
Begin
  If Fsize > 0 Then
  Begin
    Finalize(FVertex);
    Fsize := 0;
  End;
End;

Procedure TPolygon.Copy(Const lPolygon: TPolygon);
Begin
  Copy(lPolygon.FVertex);
End;

Procedure TPolygon.Copy(Const lPolygon: TfloatPolygon);
Var
  i: integer;
Begin
  Fsize := High(lPolygon) + 1;
  SetLength(FVertex, Fsize);
  For i := 0 To Fsize - 1 Do
    FVertex[i] := FloatPoint(lPolygon[i].X, lPolygon[i].Y);
  MinMax;
End;

Constructor TPolygon.Create(Const lPolygon: TPolygon);
Begin
  Copy(lPolygon);
End;

Constructor TPolygon.Create(Const lPolygon: TfloatPolygon);
Begin
  Copy(lPolygon);
End;

Constructor TPolygon.Create;
Begin
  Fsize := 0;
  FMin := FloatPoint(-1, -1);
  FMax := FloatPoint(-1, -1);
End;

Procedure TPolygon.DeleteVertex(ind: integer);
Var
  i: integer;
Begin
  If inRange(ind, 1, Fsize) Then
  Begin
    For i := ind To Fsize - 1 Do
      FVertex[i - 1] := FVertex[i];
    Fsize := Fsize - 1;
    SetLength(FVertex, Fsize);
    MinMax;
  End;
End;

Destructor TPolygon.Destroy;
Begin
  Clear;
  Inherited Destroy;
End;

Procedure TPolygon.Escala(Const mx, my: float);
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    For i := 0 To Fsize - 1 Do
    Begin
      FVertex[i].X := divide(FVertex[i].X, mx);
      FVertex[i].Y := divide(FVertex[i].Y, my);
    End;
    MinMax;
  End;
End;

Function TPolygon.GetOrientation: TPolygonOrientation;
Begin
  If Fsize < 3 Then
    result := TPONone
  Else If clipperfloat.Orientation(FVertex) Then
    result := TPOCounterClockWise
  Else
    result := TPOClockWise;
End;

Function TPolygon.GetPoints(Xscale, Yscale: float; reversed: boolean): APoint;
Var
  Res: APoint;
  i, trueI: integer;
Begin
  SetLength(Res, Fsize + 1);
  For i := 0 To Fsize - 1 Do
  Begin
    If reversed Then
      trueI := Fsize - i - 1
    Else
      trueI := i;
    Res[i] := FloatPoint(((FVertex[trueI].X) * Xscale),
      ((FVertex[trueI].Y) * Yscale));
  End;
  Res[Fsize] := Res[0];
  result := Res;
End;

Function TPolygon.GetvclPoints(Xscale, Yscale: float; reversed: boolean)
  : vclPoints;
Var
  Res: vclPoints;
  i, trueI: integer;
Begin
  SetLength(Res, Fsize + 1);
  For i := 0 To Fsize - 1 Do
  Begin
    If reversed Then
      trueI := Fsize - i - 1
    Else
      trueI := i;
    Res[i] := FloatPoint(((FVertex[trueI].X) * Xscale) - 1,
      ((FVertex[trueI].Y) * Yscale) - 1);
  End;
  Res[Fsize] := Res[0];
  result := Res;
End;

Function TPolygon.GetvclPoints(reversed: boolean): vclPoints;
Var
  Res: vclPoints;
  i, trueI: integer;
Begin
  SetLength(Res, Fsize + 1);
  For i := 0 To Fsize - 1 Do
  Begin
    If reversed Then
      trueI := Fsize - i - 1
    Else
      trueI := i;
    Res[i] := FVertex[trueI] - FloatPoint(1, 1);
  End;
  Res[Fsize] := Res[0];
  result := Res;
End;

Function TPolygon.GetPoints(reversed: boolean): APoint;
Var
  Res: APoint;
  i, trueI: integer;
Begin
  SetLength(Res, Fsize + 1);
  For i := 0 To Fsize - 1 Do
  Begin
    If reversed Then
      trueI := Fsize - i - 1
    Else
      trueI := i;
    Res[i] := FVertex[trueI];
  End;
  Res[Fsize] := Res[0];
  result := Res;
End;

Function TPolygon.GetVertex(ind: integer): myPoint;
Begin
  result := FVertex[ind - 1];
End;

Procedure TPolygon.MinMax;
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    FMin := FVertex[0];
    FMax := FVertex[0];
    For i := 1 To Fsize - 1 Do
    Begin
      If (FVertex[i].X < FMin.X) Or (FMin.X < 0) Then
        FMin.X := FVertex[i].X;
      If (FVertex[i].Y < FMin.Y) Or (FMin.Y < 0) Then
        FMin.Y := FVertex[i].Y;
      If (FVertex[i].X > FMax.X) Or (FMax.X < 0) Then
        FMax.X := FVertex[i].X;
      If (FVertex[i].Y > FMax.Y) Or (FMax.Y < 0) Then
        FMax.Y := FVertex[i].Y;
    End;
  End
  Else
  Begin
    FMin := FloatPoint(-1, -1);
    FMax := FloatPoint(-1, -1);
  End;
End;

Procedure TPolygon.Move(Const lvector: myPoint);
Begin
  Move(lvector.X, lvector.Y);
End;

Procedure TPolygon.Move(Const X, Y: float);
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    For i := 0 To Fsize - 1 Do
    Begin
      FVertex[i].Add(FloatPoint(X, Y));
    End;
    FMin := FMin + FloatPoint(X, Y);
    FMax := FMax + FloatPoint(X, Y);
  End;
End;

Procedure TPolygon.Rotate(Const lAngle: float);
Var
  lCenter: myPoint;
  i: integer;
  SinX, CosX: extended;
Begin
  If lAngle <> 0 Then
  Begin
    lCenter := Center;
    // This is the polygon center
    // We have the angle but we need its sine and cosine
    SinCos(lAngle, SinX, CosX);
    uGraphics.Rotate(FVertex[0], lCenter, -SinX, CosX);
    For i := 1 To Fsize - 1 Do
    Begin
      uGraphics.Rotate(FVertex[i], lCenter, -SinX, CosX);
    End;
  End;
End;

Procedure TPolygon.Rotate(Const x1, y1, x2, y2: float);
// In this procedure you have a starting point (x1, y1) and
// an ending point (x2, y2), rotate the entire polygon by an angle defined by
// the vectors from the center of the polygon to each point
Var
  lCenter, P1, P2: myPoint;
  i: integer;
  SinX, CosX, mod1mod2: float;
Begin
  lCenter := Center; // This is the polygon center O(n)
  // We need the angle between P1-Center and P2-Center
  P1 := FloatPoint(x1, y1) - lCenter;
  If P1.IsZero Then
    P1.X := 1;
  // rare case where you pick exactly the center
  P2 := FloatPoint(x2, y2) - lCenter;
  If P2.IsZero Then
    P2.X := 1;
  // rare case where you end exactly in the center
  If (P1 <> P2) Then // avoid 0 angle which means no rotation!!!
  Begin
    // This is the best way to find the angle
    { lAngle := ArcTan2(-P1.X * P2.Y + P1.Y * P2.X, P1.X * P2.X + P1.Y * P2.Y);
      SinCos(lAngle, SinX, CosX); }
    // But this way calls arctan, sine and cosine functions!!
    // and we doesn't really need the angle, actually we need its sine and cosine
    // avoiding destructive under(over)flow for near 0 and near pi/2 angles
    // the cost is worthwile
    // also mod1mod2 is never 0
    mod1mod2 := pythag(P1.X, P1.Y) * pythag(P2.X, P2.Y); // = |P1|*|P2| <> 0
    SinX := (P1.X * P2.Y - P2.X * P1.Y) / mod1mod2;
    // |P1 X P2| = |P1|*|P2|*sinX
    CosX := (P1.X * P2.X + P1.Y * P2.Y) / mod1mod2; // P1 * P2 = |P1|*|P2|*cosX
    uGraphics.Rotate(FVertex[0], lCenter, -SinX, CosX);
    // The screen is flipped in y axis so y is negative
    For i := 1 To Fsize - 1 Do // main loop O(n)
    Begin
      uGraphics.Rotate(FVertex[i], lCenter, -SinX, CosX);
    End;
  End;
End;

Procedure TPolygon.Rotate(Const lCenter: TPoint; Const lAngle: float);
Var
  i: integer;
  SinX, CosX: extended;
Begin
  If lAngle <> 0 Then
  Begin
    // This is the polygon center
    // We have the angle but we need its sine and cosine
    SinCos(lAngle, SinX, CosX);
    uGraphics.Rotate(FVertex[0], lCenter, -SinX, CosX);
    For i := 1 To Fsize - 1 Do
    Begin
      uGraphics.Rotate(FVertex[i], lCenter, -SinX, CosX);
    End;
  End;
End;

Function TPolygon.PointInBound(Const lPoint: myPoint): boolean;
Var
  i: integer;
  p0, P1: myPoint;
Begin
  If Fsize < 2 Then
  Begin
    result := false;
    exit;
  End;
  result := false;
  p0 := FVertex[Fsize - 1];
  For i := 0 To Fsize - 1 Do
  Begin
    P1 := FVertex[i];
    If Colinear(p0, lPoint, P1) Then
    Begin
      result := true;
      exit;
    End;
    p0 := P1;
  End;
End;

Function TPolygon.PointInBound(Const X, Y: float): boolean;
Begin
  result := PointInBound(FloatPoint(X, Y));
End;

Function TPolygon.PointInside(Const lPoint: myPoint): boolean;
Begin
  result := PointInside(lPoint.X, lPoint.Y);
End;

Function TPolygon.PointInside(Const X, Y: float): boolean;
Var
  i, winding: integer;
  // temp: float;
  p0, P1: myPoint;
Begin
  If Fsize < 2 Then
  Begin
    result := false;
    exit;
  End;
  winding := 0;
  p0 := FVertex[Fsize - 1];
  For i := 0 To Fsize - 1 Do
  Begin
    P1 := FVertex[i];
    If (p0.Y <= Y) Then
    Begin
      If (P1.Y > Y) And
      // Upward-crossing edge. Is pt to its left?
        ((p0.X - X) * (P1.Y - Y) - (p0.Y - Y) * (P1.X - X) > 0) Then
        inc(winding);
    End
    Else
    Begin
      If (P1.Y <= Y) And
      // Downward-crossing edge. Is pt to its right?
        ((p0.X - X) * (P1.Y - Y) - (p0.Y - Y) * (P1.X - X) < 0) Then
        dec(winding);
      // inc
    End;
    p0 := P1;
  End; // Boundary is not inside
  If Fsize >= 3 { or PointInBound(X, Y) }
  Then
    If (winding And $1 = 1) Then
      result := (Orientation = TPOCounterClockWise)
    Else
      result := (Orientation = TPOClockWise)
  Else
    result := false;
End;

Function TPolygon.PolygonSetOperation(Const Other: TPolygon;
  Operation: TPolygonSetOperation; Out Res: TPolygons;
  wantRegular: boolean): boolean;
Var
  loperation: TClipType;
  clipper: TClipper;
Begin
  If Operation = ctReplace Then
  Begin
    SetLength(Res, 1);
    Res[0] := Other.FVertex;
    result := true;
  End
  Else
  Begin
    Case Operation Of
      ctUnion:
        loperation := TClipType.ctUnion;
      ctDifference:
        loperation := TClipType.ctDifference;
      ctIntersection:
        loperation := TClipType.ctIntersection;
      ctXor:
        loperation := TClipType.ctXor;
    End;
    clipper := TClipper.Create;
    clipper.AddPolygon(FVertex, ptSubject);
    clipper.AddPolygon(Other.FVertex, ptClip);
    clipper.Execute(loperation, Res);
    clipper.free;
    result := High(Res) + 1 > 0;
  End;
End;

Procedure TPolygon.SetOrientation(Const Value: TPolygonOrientation);
Var
  i: integer;
  tempP: myPoint;
Begin
  If (Orientation <> Value) And (Fsize > 2) Then
  Begin
    For i := 0 To (Fsize Div 2) - 1 Do
    Begin
      tempP := FVertex[i];
      FVertex[i] := FVertex[Fsize - i - 1];
      FVertex[Fsize - i - 1] := tempP;
    End;
  End;
End;

Procedure TPolygon.SetVertex(ind: integer; Const lVertex: myPoint);
Begin
  If inRange(ind, 1, Fsize) Then
  Begin
    FVertex[ind - 1] := lVertex;
  End;
End;

{ TLayer }
// ------------------------------------------------------------------------------

Function TLayer.clipperpolygons: TPolygons;
Var
  i, j: integer;
  Res: TPolygons;
Begin
  SetLength(Res, size);
  For i := 1 To size Do
  Begin
    SetLength(Res[i - 1], Polygon[i].size);
    For j := 1 To Polygon[i].size Do
      Res[i - 1][j - 1] := Polygon[i].Vertex[j];
  End;
  result := Res;
End;

Procedure TLayer.AddPolygon(Const lPolygon: TPolygon;
  Operation: TPolygonSetOperation);
Begin
  AddPolygon(lPolygon.FVertex, Operation);
End;

Procedure TLayer.AddPolygon(Const lPolygon: TfloatPolygon;
  Operation: TPolygonSetOperation);
Var
  i, Ub: integer;
  Res: TPolygons;
  loperation: TClipType;
  clipper: TClipper;
Begin
  Ub := High(lPolygon) + 1;
  If Ub < 3 Then
    // Do nothing with non real polygons
    exit;
  If (Operation = ctReplace) Or (Fsize = 0) Then
  Begin
    Clear;
    SetLength(FPolygon, 1);
    Fsize := 1;
    FPolygon[0] := TPolygon.Create(lPolygon);
    MinMax;
    exit;
  End;
  Case Operation Of
    ctUnion:
      loperation := TClipType.ctUnion;
    ctDifference:
      loperation := TClipType.ctDifference;
    ctIntersection:
      loperation := TClipType.ctIntersection;
    ctXor:
      loperation := TClipType.ctXor;
  End;
  clipper := TClipper.Create;
  For i := 0 To Fsize - 1 Do
    clipper.AddPolygon(FPolygon[i].FVertex, ptSubject);
  clipper.AddPolygon(lPolygon, ptClip);
  clipper.Execute(loperation, Res);
  clipper.free;
  Copy(Position, Res);
  MinMax;
End;

Procedure TLayer.AddSegment(Head, Tail: myPoint);
Var
  i, j: integer;
  used: integer;
Begin
  used := 0;
  i := 1;
  // Hay que unir los fragmentos, solo se comparan cabeza y cola
  Repeat
    If (used > 0) Then
    Begin // el segmento ya se pego al poligono con indice "used"
      If (Polygon[used].Vertex[Polygon[used].size] = Polygon[i].Vertex[1]) Then
      Begin // tail[used] = head[i]
        For j := 2 To Polygon[i].size Do // j=1 is already the tail
          Polygon[used].AppendVertex(Polygon[i].Vertex[j]);
        DeletePolygon(i);
        used := -1
      End
      Else If (Polygon[used].Vertex[Polygon[used].size] = Polygon[i].Vertex
        [Polygon[i].size]) Then
      Begin // tail[used] = tail[i]
        For j := Polygon[i].size - 1 Downto 1 Do
          // j=Polygon[i].Size is already the tail
          Polygon[used].AppendVertex(Polygon[i].Vertex[j]);
        DeletePolygon(i);
        used := -1
      End
      Else If (Polygon[used].Vertex[1] = Polygon[i].Vertex[1]) Then
      Begin // head[used] = head[i]
        Polygon[used].ChangeOrientation;
        For j := 2 To Polygon[i].size Do // j=1 is already the head
          Polygon[used].AppendVertex(Polygon[i].Vertex[j]);
        DeletePolygon(i);
        used := -1
      End
      Else If (Polygon[used].Vertex[1] = Polygon[i].Vertex
        [Polygon[i].size]) Then
      Begin // head[used] = tail[i]
        For j := 2 To Polygon[used].size Do
          Polygon[i].AppendVertex(Polygon[used].Vertex[j]);
        DeletePolygon(used);
        used := -1
      End;
    End;
    If i > size Then
      break; // 1 polygon could be deleted
    // si no se ha usado el segmento tratar de pegarlo a un poligono
    // el tratamiento del caso "pinch point" es automatico
    If (used = 0) Then
    Begin
      If (Head = Polygon[i].Vertex[1]) Then
      Begin
        Polygon[i].AddVertex(1, Tail);
        used := i;
      End
      Else If (Head = Polygon[i].Vertex[Polygon[i].size]) Then
      Begin
        Polygon[i].AppendVertex(Tail);
        used := i;
      End
      Else If (Tail = Polygon[i].Vertex[1]) Then
      Begin
        Polygon[i].AddVertex(1, Head);
        used := i;
      End
      Else If (Tail = Polygon[i].Vertex[Polygon[i].size]) Then
      Begin
        Polygon[i].AppendVertex(Head);
        used := i;
      End;
    End;
    inc(i);
  Until i > size;
  // si el segmento no fue usado añadirlo como un nuevo poligono
  If (used = 0) Then
  Begin
    inc(Fsize);
    SetLength(FPolygon, Fsize);
    FPolygon[Fsize - 1] := TPolygon.Create;
    FPolygon[Fsize - 1].AppendVertex(Head);
    FPolygon[Fsize - 1].AppendVertex(Tail);
  End;
End;

Procedure TLayer.AppendPolygon(Const lPolygon: TPolygon;
  Operation: TPolygonSetOperation);
Begin
  AddPolygon(lPolygon, Operation);
End;

Procedure TLayer.AppendPolygon(Const lPolygon: TfloatPolygon;
  Operation: TPolygonSetOperation);
Begin
  AddPolygon(lPolygon, Operation);
End;

Function TLayer.Area: float;
Var
  i: integer;
  count: float;
Begin
  count := 0;
  For i := 0 To Fsize - 1 Do
    count := count + FPolygon[i].Area;
  Area := count;
End;

Procedure TLayer.ChangeOrientation;
Var
  i: integer;
Begin
  For i := 0 To Fsize - 1 Do
    FPolygon[i].ChangeOrientation;
End;

Procedure TLayer.Clear;
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    For i := 0 To Fsize - 1 Do
      FPolygon[i].free;
    Finalize(FPolygon);
    Fsize := 0;
    FMin := FloatPoint(-1, -1);
    FMax := FloatPoint(-1, -1);
  End;
End;

Procedure TLayer.Copy(lOther: TLayer);
Var
  i, cont: integer;
Begin
  Clear;
  Position := lOther.Position;
  Fsize := lOther.size;
  SetLength(FPolygon, Fsize);
  cont := 0;
  For i := 0 To Fsize - 1 Do
    If (lOther.FPolygon[i].Area > 2) Then // avoid non real polygons
    Begin
      FPolygon[cont] := TPolygon.Create(lOther.FPolygon[i]);
      inc(cont);
    End;
  If cont <> Fsize Then
  Begin
    SetLength(FPolygon, cont);
    Fsize := cont;
  End;
  MinMax;
End;

Procedure TLayer.Copy(Z: float; lOther: TPolygons);
Var
  i, cont: integer;
Begin
  Clear;
  Position := Z;
  Fsize := High(lOther) + 1;
  SetLength(FPolygon, Fsize);
  cont := 0;
  For i := 0 To Fsize - 1 Do
  Begin
    If (clipperfloat.Area(lOther[i]) > 2) Then // avoid non real polygons
    Begin
      FPolygon[cont] := TPolygon.Create(lOther[i]);
      inc(cont);
    End;
  End;
  If cont <> Fsize Then
  Begin
    SetLength(FPolygon, cont);
    Fsize := cont;
  End;
  MinMax;
End;

Constructor TLayer.Create(lOther: TLayer);
Begin
  Copy(lOther);
End;

Constructor TLayer.Create(Z: float; lOther: TPolygons);
Begin
  Copy(Z, lOther);
End;

Constructor TLayer.Create(Zposition: float);
Begin
  Fsize := 0;
  Position := Zposition;
  FMin := FloatPoint(-1, -1);
  FMax := FloatPoint(-1, -1);
End;

Procedure TLayer.DeletePolygon(ind: integer);
Var
  i: integer;
Begin
  If ((ind > 0) And (ind <= Fsize)) Then
  Begin
    For i := ind To Fsize - 1 Do
    Begin
      FPolygon[i - 1].Copy(FPolygon[i]);
    End;
    FPolygon[Fsize - 1].free;
    Fsize := Fsize - 1;
    SetLength(FPolygon, Fsize);
    MinMax;
  End;
End;

Destructor TLayer.Destroy;
Begin
  Clear;
  Inherited Destroy;
End;

Procedure TLayer.Escala(Const mx, my: float);
Var
  i: integer;
Begin
  For i := 1 To size Do
    Polygon[i].Escala(mx, my);
  MinMax;
End;

Function TLayer.GetPolygon(ind: integer): TPolygon;
Begin
  If (ind > 0) And (ind <= Fsize) Then
    result := FPolygon[ind - 1]
  Else
    result := Nil;
End;

Procedure TLayer.MinMax;
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    FMin := FPolygon[0].Min;
    FMax := FPolygon[0].Max;
    For i := 1 To Fsize - 1 Do
    Begin
      If (FMin.X > FPolygon[i].Min.X) Or (FMin.X < 0) Then
        FMin.X := FPolygon[i].Min.X;
      If (FMin.Y > FPolygon[i].Min.Y) Or (FMin.Y < 0) Then
        FMin.Y := FPolygon[i].Min.Y;
      If (FMax.X < FPolygon[i].Max.X) Or (FMax.X < 0) Then
        FMax.X := FPolygon[i].Max.X;
      If (FMax.Y < FPolygon[i].Max.Y) Or (FMax.Y < 0) Then
        FMax.Y := FPolygon[i].Max.Y;
    End;
  End
  Else
  Begin
    FMin := FloatPoint(-1, -1);
    FMax := FloatPoint(-1, -1);
  End;
End;

Procedure TLayer.Move(Const X, Y: float);
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    For i := 0 To Fsize - 1 Do
      FPolygon[i].Move(X, Y);
    FMin := FMin + FloatPoint(X, Y);
    FMax := FMax + FloatPoint(X, Y);
  End;
End;

Procedure TLayer.OffSet(Const Delta: double; JoinType: TJoinType;
  MiterLimit: double; ChecksInput: boolean);
Var
  inpolygons, outpolygons: TPolygons;
  miZ: float;
Begin
  inpolygons := clipperpolygons;
  outpolygons := OffsetPolygons(inpolygons, Delta, JoinType, MiterLimit,
    ChecksInput);
  ClearPolygons(inpolygons);
  miZ := Position;
  Copy(miZ, outpolygons);
  ClearPolygons(outpolygons);
  MinMax;
End;

Function TLayer.PointInside(Const lPoint: myPoint): boolean;
Begin
  result := PointInside(lPoint.X, lPoint.Y);
End;

Function TLayer.PointInBound(Const lPoint: myPoint): boolean;
Begin
  result := PointInBound(lPoint.X, lPoint.Y);
End;

Procedure TLayer.PaintPolyBezier(Var Bitmap: TBitmap);
Var
  i: integer;
Begin
  For i := 0 To Fsize - 1 Do
    Bitmap.Canvas.PolyBezier(FPolygon[i].GetvclPoints);
End;

Procedure TLayer.PaintPolygons(Var Bitmap: TBitmap);
Var
  i: integer;
Begin
  For i := 0 To Fsize - 1 Do
    Bitmap.Canvas.Polygon(FPolygon[i].GetvclPoints);
End;

Procedure TLayer.PaintPolyline(Var Bitmap: TBitmap);
Var
  i: integer;
Begin
  For i := 0 To Fsize - 1 Do
    Bitmap.Canvas.Polyline(FPolygon[i].GetvclPoints);
End;

Function TLayer.PointInBound(Const X, Y: float): boolean;
Var
  i: integer;
Begin
  result := false;
  If inRange(X, FMin.X, FMax.X) And inRange(Y, FMin.Y, FMax.Y) Then
    For i := 0 To Fsize - 1 Do
      If FPolygon[i].PointInBound(X, Y) Then
      Begin
        result := true;
        exit;
      End;
End;

Function TLayer.PointInside(Const X, Y: float): boolean;
Var
  i: integer;
Begin
  result := false;
  If inRange(X, FMin.X, FMax.X) And inRange(Y, FMin.Y, FMax.Y) Then
    For i := 0 To Fsize - 1 Do
      If FPolygon[i].PointInside(X, Y) Then
      Begin
        result := true;
        exit;
      End;
End;

Procedure TLayer.Rotate(Const lCenter: TPoint; Const lAngle: float);
Var
  i: integer;
Begin
  For i := 0 To Fsize - 1 Do
    FPolygon[i].Rotate(lCenter, lAngle);
  MinMax;
End;

Procedure TLayer.SetPolygon(ind: integer; Const lPolygon: TPolygon);
Begin
  If inRange(ind, 1, Fsize) Then
  Begin
    FPolygon[ind - 1].free;
    FPolygon[ind - 1] := lPolygon;
  End;
End;

Procedure TLayer.SetPosition(Const Value: float);
Begin
  FPosition := Value;
End;

Procedure TLayer.Simplify;
Var
  tempres, t1: TPolygons;
  tempz: float;
Begin
  tempz := Position;
  tempres := clipperpolygons;
  t1 := SimplifyPolygons(tempres);
  ClearPolygons(tempres);
  Clear;
  Copy(tempz, t1);
  ClearPolygons(t1);
End;

{ TPolyROI }

Procedure TPolyROI.AddLayer(Const lLayer: TLayer);
Var
  i: integer;
Begin
  For i := 1 To lLayer.size Do
    AddPolygon(lLayer.Position, lLayer.Polygon[i], ctUnion);
End;

Procedure TPolyROI.AddLayer(Z: float; lLayer: TPolygons);
Var
  i: integer;
Begin
  For i := 0 To High(lLayer) Do
    AddPolygon(Z, lLayer[i], ctUnion);
End;

Procedure TPolyROI.AddPolygon(Z: float; lPolygon: TfloatPolygon;
  loperation: TPolygonSetOperation);
Var
  ind, i: integer;
Begin
  ind := LocateZ(Z);
  If ind > size Then
  Begin
    Fsize := ind;
    SetLength(FLayer, Fsize);
    FLayer[Fsize - 1] := TLayer.Create(Z);
  End
  Else If ind < 1 Then
  Begin
    Fsize := Fsize + 1;
    SetLength(FLayer, Fsize);
    FLayer[Fsize - 1] := TLayer.Create(FLayer[Fsize - 2]);
    For i := Fsize - 2 Downto 1 Do
      FLayer[i].Copy(FLayer[i - 1]);
    FLayer[0].Clear;
    FLayer[0].Position := Z;
    ind := 1;
  End
  Else If (FLayer[ind - 1].Position <> Z) Then
  Begin
    Fsize := Fsize + 1;
    SetLength(FLayer, Fsize);
    FLayer[Fsize - 1] := TLayer.Create(FLayer[Fsize - 2]);
    For i := Fsize - 2 Downto ind Do
      FLayer[i].Copy(FLayer[i - 1]);
    FLayer[ind - 1].Clear;
    FLayer[ind - 1].Position := Z;
  End;
  FLayer[ind - 1].AppendPolygon(lPolygon, loperation);
  dj := Min(1, floor(Power(Fsize, 0.25)));
End;

Procedure TPolyROI.AddPolygon(Z: float; lPolygon: TPolygon;
  loperation: TPolygonSetOperation);
Begin
  AddPolygon(Z, lPolygon.FVertex, loperation);
End;

Procedure TPolyROI.AppendLayer(Z: float; lLayer: TPolygons);
Begin
  If Fsize = 0 Then
  Begin
    Fsize := 1;
    SetLength(FLayer, Fsize);
    FLayer[Fsize - 1] := TLayer.Create(Z, lLayer);
    dj := 1;
  End
  Else
    AddLayer(Z, lLayer);
End;

Procedure TPolyROI.AppendPolygon(Z: float; lPolygon: TfloatPolygon;
  loperation: TPolygonSetOperation);
Begin
  AddPolygon(Z, lPolygon, loperation);
End;

Procedure TPolyROI.AppendPolygon(Z: float; lPolygon: TPolygon;
  loperation: TPolygonSetOperation);
Begin
  AddPolygon(Z, lPolygon, loperation);
End;

Procedure TPolyROI.AppendLayer(Const lLayer: TLayer);
Begin
  If Fsize = 0 Then
  Begin
    Fsize := 1;
    SetLength(FLayer, Fsize);
    FLayer[Fsize - 1] := TLayer.Create(lLayer);
    dj := 1;
  End
  Else
    AddLayer(lLayer);
End;

Procedure TPolyROI.ChangeOrientation;
Var
  i: integer;
Begin
  For i := 0 To Fsize - 1 Do
    FLayer[i].ChangeOrientation;
End;

Procedure TPolyROI.Clear;
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    For i := 0 To Fsize - 1 Do
      FLayer[i].free;
    Finalize(FLayer);
    Fsize := 0;
    dj := 1;
  End;
End;

Constructor TPolyROI.Create(lOther: TPolyROI);
Var
  i: integer;
Begin
  Fsize := lOther.Fsize;
  SetLength(FLayer, Fsize);
  For i := 0 To Fsize - 1 Do
    FLayer[i] := TLayer.Create(lOther.FLayer[i]);
  dj := 1;
  jsav := 1;
  fcorrelated := false;
End;

Constructor TPolyROI.Create;
Begin
  Fsize := 0;
  dj := 1;
  jsav := 1;
  fcorrelated := false;
End;

Procedure TPolyROI.DeleteLayer(Zposition: float);
Var
  i: integer;
  ind: integer;
Begin
  ind := LocateZ(Zposition);
  If inRange(ind, 1, Fsize) Then
  Begin
    If (FLayer[ind - 1].Position <> Zposition) Then
      exit;
    For i := ind To Fsize - 1 Do
    Begin
      FLayer[i - 1].Copy(FLayer[i]);
    End;
    FLayer[Fsize - 1].free;
    Fsize := Fsize - 1;
    SetLength(FLayer, Fsize);
    dj := Min(1, floor(Power(Fsize, 0.25)));
  End;
End;

Destructor TPolyROI.Destroy;
Begin
  Clear;
  Inherited Destroy;
End;

Procedure TPolyROI.Escala(Const mx, my, mz: float);
Var
  i, j: integer;
Begin
  If size > 0 Then
    For i := 0 To Fsize - 1 Do
    Begin
      For j := 0 To FLayer[i].Fsize - 1 Do
        FLayer[i].FPolygon[j].Escala(mx, my);
      FLayer[i].Position := round(divide(FLayer[i].Position, mz));
      FLayer[i].MinMax;
    End;
End;

Procedure TPolyROI.Escala(Const lEscala: myPoint3D);
Begin
  Escala(lEscala.X, lEscala.Y, lEscala.Z);
End;

Procedure TPolyROI.ExpandoverZ(Ztaken, Zini, Zfin: float);
Var
  i, ind, size: integer;
  tempRoi: TLayer;
Begin
  If Fsize > 0 Then
  Begin
    ind := LocateZ(Ztaken);
    If inRange(ind, 1, Fsize) Then
    Begin
      If (FLayer[ind - 1].Position <> Ztaken) Then
      Begin
        Clear;
        exit;
      End;
      tempRoi := TLayer.Create(FLayer[ind - 1]);
      Clear;
      size := round(Zfin - Zini + 1);
      For i := 1 To size Do
      Begin
        tempRoi.Position := i + Zini - 1;
        AppendLayer(tempRoi);
      End;
      tempRoi.free;
    End;
  End;
End;

Function TPolyROI.GetLayer(ind: integer): TLayer;
Begin
  If inRange(ind, 1, Fsize) Then
    result := FLayer[ind - 1]
  Else
    result := Nil;
End;

Function TPolyROI.HuntZ(Z: float): integer;
Var
  jl, jm, jh, inc: integer;
  breaking: boolean;
Begin
  If Not correlated Then
  Begin
    result := LocateZ(Z);
    exit;
  End;
  jl := jsav;
  inc := 1;
  breaking := false;
  If Fsize > 0 Then
  Begin
    If Z < FLayer[0].Position Then
    Begin
      result := 0;
      exit;
    End
    Else
      jl := 1;
    jh := Fsize;
    If Z > FLayer[jh - 1].Position Then
    Begin
      result := jh + 1;
      exit;
    End;
    If (jl < 1) Or (jl > Fsize) Then
    Begin
      jl := 1;
      jh := Fsize;
    End
    Else
    Begin
      If (Z >= FLayer[jl - 1].Position) Then // Hunt up:
        Repeat
          jh := jl + inc;
          If (jh >= Fsize) Then
          Begin
            jh := Fsize;
            breaking := true;
          End // Off end of table.
          Else If (Z < FLayer[jh - 1].Position) Then
            breaking := true // Found bracket.
          Else
          Begin // Not done, so double the increment and try again.
            jl := jh;
            inc := inc Shl 1;
          End;
        Until breaking
      Else
      Begin // Hunt down:
        jh := jl;
        Repeat
          jl := jl - inc;
          If (jl <= 1) Then
          Begin
            jl := 1;
            breaking := true;
          End // Off end of table.
          Else If (Z >= FLayer[jl - 1].Position) Then
            breaking := true // Found bracket.
          Else
          Begin // Not done, so double the increment and try again.
            jh := jl;
            inc := inc Shl 1;
          End;
        Until breaking;
      End;
    End;
    While (jh - jl > 1) Do
    Begin // Hunt is done, so begin the final bisection phase:
      jm := (jh + jl) Div 2;
      If (Z >= FLayer[jm - 1].Position) Then
        jl := jm
      Else
        jh := jm;
    End;
    If (Z = FLayer[jl - 1].Position) Then
      result := jl
    Else
      result := jh;
  End
  Else
    result := Fsize + 1;
  fcorrelated := Not(abs(result - jsav) > dj);
  jsav := result;
End;

Function TPolyROI.LocateZ(Z: float): integer;
Var
  jl, jm, jh: integer;
Begin
  If correlated Then
  Begin
    result := HuntZ(Z);
    exit;
  End;
  fcorrelated := false;
  If Fsize > 0 Then
  Begin
    If Z < FLayer[0].Position Then
    Begin
      result := 0;
      exit;
    End
    Else
      jl := 1;
    jh := Fsize;
    If Z > FLayer[jh - 1].Position Then
    Begin
      result := jh + 1;
      exit;
    End;
    While (jh - jl > 1) Do
    Begin
      jm := (jh + jl) Div 2;
      If Z >= FLayer[jm - 1].Position Then
        jl := jm
      Else
        jh := jm;
    End;
    If (Z = FLayer[jl - 1].Position) Then
      result := jl
    Else
      result := jh;
  End
  Else
    result := Fsize + 1;
  fcorrelated := Not(abs(result - jsav) > dj);
  jsav := result;
End;

Procedure TPolyROI.MinMax(Out lMinMax: TBox);
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    lMinMax.ini := FloatPoint3D(FLayer[0].Min.X, FLayer[0].Min.Y,
      FLayer[0].Position);
    lMinMax.fin := FloatPoint3D(FLayer[0].Max.X, FLayer[0].Max.Y,
      FLayer[Fsize - 1].Position);
    For i := 1 To Fsize - 1 Do
    Begin
      If (FLayer[i].Min.X < lMinMax.ini.X) Then
        lMinMax.ini.X := FLayer[i].Min.X;
      If (FLayer[i].Min.Y < lMinMax.ini.Y) Then
        lMinMax.ini.Y := FLayer[i].Min.Y;
      If (FLayer[i].Max.X > lMinMax.fin.X) Then
        lMinMax.fin.X := FLayer[i].Max.X;
      If (FLayer[i].Max.Y > lMinMax.fin.Y) Then
        lMinMax.fin.Y := FLayer[i].Max.Y;
    End;
  End
  Else
  Begin
    lMinMax.ini := FloatPoint3D(-1, -1, -1);
    lMinMax.fin := FloatPoint3D(-1, -1, -1);
  End;
End;

Procedure TPolyROI.Move(Const lvector: myPoint3D);
Begin
  Move(lvector.X, lvector.Y, lvector.Z);
End;

Function TPolyROI.NumberTotal: integer;
Var
  i, count: integer;
Begin
  count := 0;
  For i := 0 To Fsize - 1 Do
    count := count + FLayer[i].Fsize;
  result := count;
End;

Procedure TPolyROI.Move(Const X, Y, Z: float);
Var
  i: integer;
Begin
  If Fsize > 0 Then
  Begin
    For i := 0 To Fsize - 1 Do
    Begin
      FLayer[i].Move(X, Y);
      FLayer[i].Position := FLayer[i].Position + Z;
    End;
  End;
End;

Function TPolyROI.PointInside(Const lPoint: myPoint; Ztaken: float): boolean;
Begin
  result := PointInside(lPoint.X, lPoint.Y, Ztaken);
End;

Function TPolyROI.PointInBound(Const lPoint: myPoint; Ztaken: float): boolean;
Begin
  result := PointInBound(lPoint.X, lPoint.Y, Ztaken);
End;

Procedure TPolyROI.PaintPolyBezier(Ztaken: float; Var Bitmap: TBitmap);
Var
  ind: integer;
Begin
  ind := LocateZ(Ztaken);
  If inRange(ind, 1, Fsize) Then
    If (FLayer[ind - 1].Position = Ztaken) Then
      FLayer[ind - 1].PaintPolyBezier(Bitmap);
End;

Procedure TPolyROI.PaintPolygons(Ztaken: float; Var Bitmap: TBitmap);
Var
  ind: integer;
Begin
  ind := LocateZ(Ztaken);
  If inRange(ind, 1, Fsize) Then
    If (FLayer[ind - 1].Position = Ztaken) Then
      FLayer[ind - 1].PaintPolygons(Bitmap);
End;

Procedure TPolyROI.PaintPolyline(Ztaken: float; Var Bitmap: TBitmap);
Var
  ind: integer;
Begin
  ind := LocateZ(Ztaken);
  If inRange(ind, 1, Fsize) Then
    If (FLayer[ind - 1].Position = Ztaken) Then
      FLayer[ind - 1].PaintPolyline(Bitmap);
End;

Function TPolyROI.PointInBound(Const X, Y: float; Ztaken: float): boolean;
Var
  ind: integer;
Begin
  result := false;
  If Fsize > 0 Then
  Begin
    ind := LocateZ(Ztaken);
    If inRange(ind, 1, Fsize) Then
      If ((FLayer[ind - 1].Position = Ztaken) And
        FLayer[ind - 1].PointInBound(X, Y)) Then
        result := true;
  End;
End;

Function TPolyROI.PointInside(Const X, Y: float; Ztaken: float): boolean;
Var
  ind: integer;
Begin
  result := false;
  If Fsize > 0 Then
  Begin
    ind := LocateZ(Ztaken);
    If inRange(ind, 1, Fsize) Then
      If (FLayer[ind - 1].Position = Ztaken) And
        (FLayer[ind - 1].PointInside(X, Y)) Then
        result := true;
  End;
End;

Constructor TPolyROI.ReadFromFile(lFile: TFileName);
Var
  f: File Of float;
  i, j: integer;
  count, lsize, Ztaken: float;
  temp: TfloatPoint;
  lPolygon: TPolygon;
Begin
  If FileExists(changefileext(lFile, '.roi')) Then
  Begin
    AssignFile(f, changefileext(lFile, '.roi'));
    Reset(f);
    Read(f, lsize);
    If lsize > 0 Then
    Begin
      For i := 1 To round(lsize) Do
      Begin
        Read(f, Ztaken);
        Read(f, count);
        lPolygon := TPolygon.Create;
        For j := 1 To round(count) Do
        Begin
          Read(f, temp.X);
          Read(f, temp.Y);
          lPolygon.AppendVertex(temp);
        End;
        AddPolygon(Ztaken, lPolygon, ctUnion);
        lPolygon.free;
      End;
    End;
    CloseFile(f)
  End
  Else
    Fsize := 0;
End;

Constructor TPolyROI.ReadFromFileI(lFile: TFileName);
Var
  f: File Of integer;
  i, j: integer;
  count, lsize, Ztaken: integer;
  temp: TPoint;
  lPolygon: TPolygon;
Begin
  If FileExists(changefileext(lFile, '.roi')) Then
  Begin
    AssignFile(f, changefileext(lFile, '.roi'));
    Reset(f);
    Read(f, lsize);
    If lsize > 0 Then
    Begin
      For i := 1 To lsize Do
      Begin
        Read(f, Ztaken);
        Read(f, count);
        lPolygon := TPolygon.Create;
        For j := 1 To count Do
        Begin
          Read(f, temp.X);
          Read(f, temp.Y);
          lPolygon.AppendVertex(temp);
        End;
        AddPolygon(Ztaken, lPolygon, ctUnion);
        lPolygon.free;
      End;
    End;
    CloseFile(f)
  End
  Else
    Fsize := 0;
End;

Procedure TPolyROI.Save2File(lFile: TFileName);
Var
  f: File Of float;
  i, j, k: integer;
  count, tint: float;
  temp: TfloatPoint;
Begin
  count := NumberTotal;
  AssignFile(f, changefileext(lFile, '.roi'));
  Rewrite(f);
  Write(f, count);
  For i := 0 To Fsize - 1 Do
  Begin
    For j := 0 To FLayer[i].Fsize - 1 Do
    Begin
      tint := FLayer[i].Position;
      Write(f, tint);
      count := FLayer[i].FPolygon[j].Fsize;
      Write(f, count);
      For k := 0 To FLayer[i].FPolygon[j].Fsize - 1 Do
      Begin
        temp := FLayer[i].FPolygon[j].FVertex[k];
        Write(f, temp.X);
        Write(f, temp.Y);
      End;
    End;
  End;
  CloseFile(f);
  ShowMessage('ROI guardada en ' + lFile);
End;

Procedure TPolyROI.Save2FileI(lFile: TFileName);
Var
  f: File Of integer;
  i, j, k: integer;
  count, tint: integer;
  temp: TPoint;
Begin
  count := NumberTotal;
  AssignFile(f, changefileext(lFile, '.roi'));
  Rewrite(f);
  Write(f, count);
  For i := 0 To Fsize - 1 Do
  Begin
    For j := 0 To FLayer[i].Fsize - 1 Do
    Begin
      tint := round(FLayer[i].Position);
      Write(f, tint);
      count := FLayer[i].FPolygon[j].Fsize;
      Write(f, count);
      For k := 0 To FLayer[i].FPolygon[j].Fsize - 1 Do
      Begin
        temp := FLayer[i].FPolygon[j].FVertex[k];
        Write(f, temp.X);
        Write(f, temp.Y);
      End;
    End;
  End;
  CloseFile(f);
  ShowMessage('ROI guardada en ' + lFile);
End;

Procedure TPolyROI.SetLayer(ind: integer; Const lLayer: TLayer);
Begin
  If inRange(ind, 1, Fsize) Then
  Begin
    FLayer[ind - 1].free;
    FLayer[ind - 1] := lLayer;
  End;
End;

Procedure TPolyROI.Simplify(Ztaken: float);
Var
  ind: integer;
  tempres, t1: TPolygons;
Begin
  ind := LocateZ(Ztaken);
  If inRange(ind, 1, Fsize) Then
  Begin
    If (FLayer[ind - 1].Position = Ztaken) Then
    Begin
      tempres := FLayer[ind - 1].clipperpolygons;
      t1 := SimplifyPolygons(tempres);
      ClearPolygons(tempres);
      DeleteLayer(Ztaken);
      AddLayer(Ztaken, t1);
      ClearPolygons(t1);
    End;
  End;
End;

Procedure TPolyROI.Sort;
  Procedure QSort(L, R: integer);
  Var
    i, j: integer;
    U: float;
    V: TLayer;
  Begin
    i := L;
    j := R;
    U := FLayer[(L + R) Div 2].FPosition;
    Repeat
      While FLayer[i].FPosition < U Do
        i := i + 1;
      While U < FLayer[j].FPosition Do
        j := j - 1;
      If i < j Then
      Begin
        V := TLayer.Create(FLayer[i]);
        FLayer[i].Copy(FLayer[j]);
        FLayer[j].Copy(V);
        V.free;
        i := i + 1;
        j := j - 1;
      End;
    Until i > j;
    If L < j Then
      QSort(L, j);
    If i < R Then
      QSort(i, R);
  End;

Begin
  QSort(1, Fsize);
End;

Function TPolyROI.Volume: float;
Var
  i: integer;
  count: float;
Begin
  count := 0;
  For i := 0 To Fsize - 1 Do
  Begin
    count := count + FLayer[i].Area;
  End;
  Volume := count;
End;

End.
