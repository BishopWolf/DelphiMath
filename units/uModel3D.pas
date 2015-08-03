unit uModel3D;

{ Unit umemory : 3D modeling Unit

  adapted for tpmath by : Alex Vergara Gil

  Contains the routines for modeling 3D object

  adapted for tpmath from 3DEngine:

  3D rendering engine source code for delphi

  Written by Peter Bone

  http://www.geocities.com/peter_bone_uk

  12 / 5 / 2003 }

interface

uses
  Windows, Graphics, Math, Dialogs, uConstants, utypes;

{ . $I model3d.hdr }
{ ------------------------------------------------------------------
  Space3d types
  ------------------------------------------------------------------ }

type
  Tplane3d = packed record
    A, B, C, D: Float;
  end;

  THLS = record
    H: Integer;
    L: Integer;
    S: Integer;
  end;

  TRGBFloat = record
    R: single;
    G: single;
    B: single;
  end;

  A = TPoint;

  TPointColor = record
    X: Integer;
    Y: Integer;
    RGB: TRGBFloat;
  end;

  TPointColorTriangle = array [0 .. 2] of TPointColor;

  TPoint3D = record
    X: Float;
    Y: Float;
    Z: Float;
  public
    class operator Equal(const Lhs, Rhs: TPoint3D): boolean;
    class operator NotEqual(const Lhs, Rhs: TPoint3D): boolean;
    class operator Add(const Lhs, Rhs: TPoint3D): TPoint3D;
    class operator Subtract(const Lhs, Rhs: TPoint3D): TPoint3D;
  end;

  TIntPoint3D = record
    X: Integer;
    Y: Integer;
    Z: Integer;
  public
    class operator Equal(const Lhs, Rhs: TIntPoint3D): boolean;
    class operator NotEqual(const Lhs, Rhs: TIntPoint3D): boolean;
    class operator Add(const Lhs, Rhs: TIntPoint3D): TIntPoint3D;
    class operator Subtract(const Lhs, Rhs: TIntPoint3D): TIntPoint3D;
  end;

  TPoints = array of TPoint3D;

  TVertex = record
    Point: TPoint3D; // coordinate of vertex
    Normal: TPoint3D; // vector normal to surface at vertex
    Visible: boolean; // flag to show if vertex is part of a visible face
    Lum: Integer; // Luminosity at vertex for gouraud polygon filling
    value: Float; // vertex value for coloring
  end;

  TFace = record
    Corners: array of Integer;
    // indexes the Vertices.Points that make up the face
    CenterZ: Extended; // Z-coordinate of face center
    Normal: TPoint3D; // normal vector the the plane of the face
    HLS: THLS;
    Curved: boolean; // indicates whether face is curved or flat
  end;

  TPoints3d = array of TPoint3D;

  T3DModel = Class(TObject)
  private

    Vertices: array of TVertex;
    Faces: array of TFace;
    VisibleFaces: array of TFace;

    FCenter: TPoint3D;

    function FaceNormal(AFace: Integer): TPoint3D;
    procedure QuickSortFaces(var A: array of TFace; iLo, iHi: Integer);
    procedure FlatFace(AFace: Integer);
    procedure GouraudFace(AFace: Integer);
    procedure GouraudPoly(var ABitmap: TBitmap; V: TPointColorTriangle);
    function CrossProduct(AVector1, AVector2: TPoint3D): TPoint3D;
    function DotProduct(AVector1, AVector2: TPoint3D): Float;
    function UnitVector(AVector: TPoint3D): TPoint3D;
    function Add(AVec1, AVec2: TPoint3D): TPoint3D;
    function Subtract(AVec1, AVec2: TPoint3D): TPoint3D;
    procedure SearchNearestPoints(Point: Integer; out P1, P2, P3: Integer);
    procedure CleanZeroVertices; // included for stability
    procedure CleanZeroFaces; // included for speed
  public
    procedure limpiate; // included for frees memory
    procedure BuildRotationalVolume(Coords, Radius: array of Extended;
      LayerColors: array of TColor; Detail: Integer);
    procedure BuildCube(ACubeSize: Integer; FaceColors: array of TColor);
    procedure Translate(AX, AY: Integer);
    procedure Rotate(AAngle: Float; AAxis: TAxis);
    procedure RenderObject;
    procedure AddVertice(Point: TPoint3D; Valor: Float);
    procedure ProcessVertices; // included for 3Dmatrixes process
    procedure ColorToFaces(min, max: Float; R, G, B: array of byte); overload;
    property Center: TPoint3D read FCenter write FCenter;
  end;

Var
  LightSource: TPoint3D; // position of light source
  SourceDirection: TPoint3D;
  ViewVector: TPoint3D; // viewing position
  OffScrBmp: TBitmap; // off screen bitmap for drawing to
  ScreenRect: TRect;
function Point(AX, AY: Integer): TPoint;
function Point3D(AX, AY, AZ: Extended): TPoint3D;
function PointInt3D(AX, AY, AZ: Integer): TIntPoint3D;

implementation

uses utrigo, u3dspace, uinterpolation, uColorConv;
{ .$i model3d.inc }

function Distance(Point1, Point2: TPoint3D): Float;
var
  temp: TPoint3D;
begin
  temp := restPoints(Point2, Point1);
  result := Pythag(temp.X, Pythag(temp.Y, temp.Z));
end;

function Point(AX, AY: Integer): TPoint;
begin
  try

    result.X := AX;
    result.Y := AY;

  except
    ShowMessage('Exception in Point Method');
  end;
end;

// TPoint3D type-cast
function Point3D(AX, AY, AZ: Extended): TPoint3D;
begin
  try

    result.X := AX;
    result.Y := AY;
    result.Z := AZ;

  except
    ShowMessage('Exception in Point3D Method');
  end;
end;

function PointInt3D(AX, AY, AZ: Integer): TIntPoint3D;
begin
  try

    result.X := AX;
    result.Y := AY;
    result.Z := AZ;

  except
    ShowMessage('Exception in PointInt3D Method');
  end;
end;

{ ------------T3DModel------------------- }

// build a general rotational object
procedure T3DModel.BuildRotationalVolume(Coords, Radius: array of Extended;
  LayerColors: array of TColor; Detail: Integer);
Var
  LAngle: Extended;
  LRot: Integer;
  LP: TPoints3d;
  LFace, LVertex: Integer;
  Lsin, Lcos: Extended;
  LRing: Integer;
  NumRings: Integer;
begin
  try

    NumRings := length(Coords);
    SetLength(LP, NumRings);
    SetLength(Vertices, Detail * NumRings);
    SetLength(Faces, Detail * (NumRings - 1) + 2);
    LVertex := 0;
    LFace := 0;

    // set initial point positions and ring heights
    for LRing := 0 to NumRings - 1 do
    begin
      Vertices[LVertex].Point := Point3D(Radius[LRing], Coords[LRing], 0);
      Inc(LVertex);
      LP[LRing].Y := Coords[LRing];
    end;

    // create Vertices by rotating points around rings
    for LRot := 1 to Detail do
    begin
      if LRot < Detail then
      begin
        LAngle := 2 * pi * LRot / Detail;
        SinCos(LAngle, Lsin, Lcos);
        // calculate new point positions
        for LRing := 0 to NumRings - 1 do
        begin
          LP[LRing].X := Radius[LRing] * Lcos;
          LP[LRing].Z := Radius[LRing] * Lsin;
        end;
        // store new points in Vertices
        for LRing := 0 to NumRings - 1 do
        begin
          Vertices[LVertex].Point := LP[LRing];
          Inc(LVertex);
        end;
      end;
      // create a new face by indexing Vertices
      SetLength(Faces[LFace].Corners, 4);
      for LRing := 0 to NumRings - 2 do
      begin
        Faces[LFace].Corners[0] := ((LRot - 1) * NumRings) + LRing;
        Faces[LFace].Corners[1] := ((LRot - 1) * NumRings) + LRing + 1;
        if LRot = Detail then
        begin // join up 1st layer and 2nd layer faces
          Faces[LFace].Corners[2] := Faces[LRing].Corners[1];
          Faces[LFace].Corners[3] := Faces[LRing].Corners[0];
        end
        else
        begin
          Faces[LFace].Corners[2] := (LRot * NumRings) + LRing + 1;
          Faces[LFace].Corners[3] := (LRot * NumRings) + LRing;
        end;

        // face colours
        Faces[LFace].HLS := RGBtoHLS(ColorToRGB(LayerColors[LRing]));

        Faces[LFace].Curved := True;

        Inc(LFace);
      end;
    end;

    // create end faces
    SetLength(Faces[length(Faces) - 2].Corners, Detail);
    SetLength(Faces[length(Faces) - 1].Corners, Detail);
    for LRot := 0 to Detail - 1 do
    begin
      Faces[length(Faces) - 2].Corners[LRot] := LRot * NumRings;
      Faces[length(Faces) - 1].Corners[LRot] := ((LRot + 1) * NumRings) - 1;
    end;
    // colours
    Faces[length(Faces) - 2].HLS :=
      RGBtoHLS(ColorToRGB(LayerColors[length(LayerColors) - 2]));
    Faces[length(Faces) - 1].HLS :=
      RGBtoHLS(ColorToRGB(LayerColors[length(LayerColors) - 1]));

    Faces[length(Faces) - 2].Curved := False; // end faces are not curved
    Faces[length(Faces) - 1].Curved := False;

    // calculate face normals
    for LFace := 0 to length(Faces) - 3 do
    begin
      Faces[LFace].Normal := FaceNormal(LFace);
    end;
    // end faces
    Faces[length(Faces) - 2].Normal := Point3D(0, -1, 0);
    Faces[length(Faces) - 1].Normal := Point3D(0, 1, 0);

    // calculate vertex normals by averaging the face normals that it toaches
    for LVertex := 0 to length(Vertices) - 1 do
    begin
      Vertices[LVertex].Normal := Point3D(0, 0, 0);
    end;
    for LFace := 0 to length(Faces) - 3 do
    begin // don't include end faces
      for LVertex := 0 to length(Faces[LFace].Corners) - 1 do
      begin
        Vertices[Faces[LFace].Corners[LVertex]].Normal :=
          Add(Vertices[Faces[LFace].Corners[LVertex]].Normal,
          Faces[LFace].Normal);
      end;
    end;
    for LVertex := 0 to length(Vertices) - 1 do
    begin
      Vertices[LVertex].Normal := UnitVector(Vertices[LVertex].Normal);
    end;

  except
    ShowMessage('Exception in BuildRotationalVolume Method');
  end;
end;

// Adds a vertice to the model
procedure T3DModel.AddVertice(Point: TPoint3D; Valor: Float);
begin
  SetLength(Vertices, length(Vertices) + 1);
  Vertices[length(Vertices) - 1].Point := Point;
  Vertices[length(Vertices) - 1].value := Valor;
end;

// build a cube with specified size and face colours
procedure T3DModel.BuildCube(ACubeSize: Integer; FaceColors: array of TColor);
Var
  LVertex, LFace: byte; // Face colours assignments
  Lx, Ly, Lz: Integer; // ___
begin // |5  |
  try // ___ ___|___|___
    // |4  |2  |0  |1  |
    // create cube Vertices        //       |___|___|___|___|
    SetLength(Vertices, 8); // |3  |
    LVertex := 0; // |___|
    for Lz := 0 to 1 do
    begin
      for Ly := 0 to 1 do
      begin
        for Lx := 0 to 1 do
        begin
          Vertices[LVertex].Point.X := Lx * ACubeSize;
          Vertices[LVertex].Point.Y := Ly * ACubeSize;
          Vertices[LVertex].Point.Z := Lz * ACubeSize;
          Vertices[LVertex].Normal := Point3D(1, 0, 0); // not used
          Inc(LVertex);
        end; // Vertex indexes
      end; // 0________1
    end; // |\      |\
    // | \4____|_\5
    // create cube faces                      //      |  |    |  |
    SetLength(Faces, 6); // 2|__|____|3 |
    for LFace := 0 to 5 do
    begin // \ |     \ |
      SetLength(Faces[LFace].Corners, 4); // \|______\|
      Faces[LFace].Curved := False; // 6       7
    end;
    for LFace := 0 to 5 do
      Faces[LFace].Corners[3] := LFace;
    Faces[0].Corners[2] := 1;
    Faces[0].Corners[1] := 3;
    Faces[0].Corners[0] := 2;
    Faces[1].Corners[2] := 5;
    Faces[1].Corners[1] := 7;
    Faces[1].Corners[0] := 3;
    Faces[2].Corners[2] := 6;
    Faces[2].Corners[1] := 4;
    Faces[2].Corners[0] := 0;
    Faces[3].Corners[2] := 7;
    Faces[3].Corners[1] := 6;
    Faces[3].Corners[0] := 2;
    Faces[4].Corners[2] := 6;
    Faces[4].Corners[1] := 7;
    Faces[4].Corners[0] := 5;
    Faces[5].Corners[2] := 1;
    Faces[5].Corners[1] := 0;
    Faces[5].Corners[0] := 4;
    // calculate face normals
    for LFace := 0 to 5 do
    begin
      Faces[LFace].Normal := FaceNormal(LFace);
      Faces[LFace].HLS := RGBtoHLS(ColorToRGB(FaceColors[LFace]));
    end;

  except
    ShowMessage('Exception in BuildCube Method');
  end;
end;

// calculate the normal vector of a face
function T3DModel.FaceNormal(AFace: Integer): TPoint3D;
Var
  LVec1, LVec2: TPoint3D;
begin
  try
    // find 2 vectors that lie on the plane
    LVec1 := Subtract(Vertices[Faces[AFace].Corners[1]].Point,
      Vertices[Faces[AFace].Corners[0]].Point);
    LVec2 := Subtract(Vertices[Faces[AFace].Corners[3]].Point,
      Vertices[Faces[AFace].Corners[0]].Point);

    result := UnitVector(CrossProduct(LVec1, LVec2));

  except
    result := UnitVector(Point3D(0, 0, 0));
    // ShowMessage('Exception in FaceNormal Method');
  end;
end;

// translate an object
procedure T3DModel.Translate(AX, AY: Integer);
Var
  LDis: TPoint3D;
  LVertex: Integer;
begin
  try
    LDis.X := AX - Center.X;
    LDis.Y := AY - Center.Y;

    for LVertex := 0 to length(Vertices) - 1 do
    begin
      Vertices[LVertex].Point.X := Vertices[LVertex].Point.X + LDis.X;
      Vertices[LVertex].Point.Y := Vertices[LVertex].Point.Y + LDis.Y;
    end;

    Center := Point3D(Center.X + LDis.X, Center.Y + LDis.Y, Center.Z);

  except
    ShowMessage('Exception in Translate Method');
  end;
end;

// rotate an object around a given axis
procedure T3DModel.Rotate(AAngle: Float; AAxis: TAxis);
Var
  LVertex: Integer;
  TempPoint: TPoint3D;
  Lsin, Lcos: Extended;
begin
  try
    SinCos(AAngle, Lsin, Lcos);

    if AAxis = AxisX then
    begin
      // rotate about x-axis
      for LVertex := 0 to length(Vertices) - 1 do
      begin // Vertex Points
        TempPoint.X := Vertices[LVertex].Point.X;
        TempPoint.Y := ((Vertices[LVertex].Point.Y - Center.Y) * Lcos) -
          ((Vertices[LVertex].Point.Z - Center.Z) * Lsin) + Center.Y;
        TempPoint.Z := ((Vertices[LVertex].Point.Y - Center.Y) * Lsin) +
          ((Vertices[LVertex].Point.Z - Center.Z) * Lcos) + Center.Z;
        Vertices[LVertex].Point := TempPoint;
      end;
      for LVertex := 0 to length(Faces) - 1 do
      begin // face normals
        TempPoint.X := Faces[LVertex].Normal.X;
        TempPoint.Y := ((Faces[LVertex].Normal.Y) * Lcos) -
          ((Faces[LVertex].Normal.Z) * Lsin);
        TempPoint.Z := ((Faces[LVertex].Normal.Y) * Lsin) +
          ((Faces[LVertex].Normal.Z) * Lcos);
        Faces[LVertex].Normal := TempPoint;
      end;
      for LVertex := 0 to length(Vertices) - 1 do
      begin // vertex normals
        TempPoint.X := Vertices[LVertex].Normal.X;
        TempPoint.Y := ((Vertices[LVertex].Normal.Y) * Lcos) -
          ((Vertices[LVertex].Normal.Z) * Lsin);
        TempPoint.Z := ((Vertices[LVertex].Normal.Y) * Lsin) +
          ((Vertices[LVertex].Normal.Z) * Lcos);
        Vertices[LVertex].Normal := TempPoint;
      end;
    end
    else if AAxis = AxisY then
    begin
      // rotate about y-axis
      for LVertex := 0 to length(Vertices) - 1 do
      begin // Vertex Points
        TempPoint.X := ((Vertices[LVertex].Point.X - Center.X) * Lcos) +
          ((Vertices[LVertex].Point.Z - Center.Z) * Lsin) + Center.X;
        TempPoint.Y := Vertices[LVertex].Point.Y;
        TempPoint.Z := -((Vertices[LVertex].Point.X - Center.X) * Lsin) +
          ((Vertices[LVertex].Point.Z - Center.Z) * Lcos) + Center.Z;
        Vertices[LVertex].Point := TempPoint;
      end;
      for LVertex := 0 to length(Faces) - 1 do
      begin // face normals
        TempPoint.X := ((Faces[LVertex].Normal.X) * Lcos) +
          ((Faces[LVertex].Normal.Z) * Lsin);
        TempPoint.Y := Faces[LVertex].Normal.Y;
        TempPoint.Z := -((Faces[LVertex].Normal.X) * Lsin) +
          ((Faces[LVertex].Normal.Z) * Lcos);
        Faces[LVertex].Normal := TempPoint;
      end;
      for LVertex := 0 to length(Vertices) - 1 do
      begin // vertex normals
        TempPoint.X := ((Vertices[LVertex].Normal.X) * Lcos) +
          ((Vertices[LVertex].Normal.Z) * Lsin);
        TempPoint.Y := Vertices[LVertex].Normal.Y;
        TempPoint.Z := -((Vertices[LVertex].Normal.X) * Lsin) +
          ((Vertices[LVertex].Normal.Z) * Lcos);
        Vertices[LVertex].Normal := TempPoint;
      end;
    end
    else
    begin
      // rotate about z-axis
      for LVertex := 0 to length(Vertices) - 1 do
      begin // Vertex Points
        TempPoint.X := ((Vertices[LVertex].Point.X - Center.X) * Lcos) -
          ((Vertices[LVertex].Point.Y - Center.Y) * Lsin) + Center.X;
        TempPoint.Y := ((Vertices[LVertex].Point.X - Center.X) * Lsin) +
          ((Vertices[LVertex].Point.Y - Center.Y) * Lcos) + Center.Y;
        TempPoint.Z := Vertices[LVertex].Point.Z;
        Vertices[LVertex].Point := TempPoint;
      end;
      for LVertex := 0 to length(Faces) - 1 do
      begin // face normals
        TempPoint.X := ((Faces[LVertex].Normal.X) * Lsin) -
          ((Faces[LVertex].Normal.Y) * Lcos);
        TempPoint.Y := ((Faces[LVertex].Normal.X) * Lcos) +
          ((Faces[LVertex].Normal.Y) * Lsin);
        TempPoint.Z := Faces[LVertex].Normal.Z;
        Faces[LVertex].Normal := TempPoint;
      end;
      for LVertex := 0 to length(Vertices) - 1 do
      begin // vertex normals
        TempPoint.X := ((Vertices[LVertex].Normal.X) * Lsin) -
          ((Vertices[LVertex].Normal.Y) * Lcos);
        TempPoint.Y := ((Vertices[LVertex].Normal.X) * Lcos) +
          ((Vertices[LVertex].Normal.Y) * Lsin);
        TempPoint.Z := Vertices[LVertex].Normal.Z;
        Vertices[LVertex].Normal := TempPoint;
      end;
    end;

  except
    ShowMessage('Exception in Rotate Method');
  end;
end;

// Render an object to the screen
procedure T3DModel.RenderObject;
Var
  LFace, LVertex: Integer;
  LVisibleVertices: array of Integer;
  // index's of vertices belonging to visible faces
  LIntensityRatio: Extended;
begin
  try
    // backface culling
    SetLength(VisibleFaces, 0);
    for LFace := 0 to length(Faces) - 1 do
    begin
      // if face normal is pointing towards viewer then it is visible else it is invisible
      if DotProduct(Faces[LFace].Normal, ViewVector) > 0 then
      begin
        SetLength(VisibleFaces, length(VisibleFaces) + 1);
        VisibleFaces[length(VisibleFaces) - 1] := Faces[LFace];
      end;
    end;

    // calculate Z-coordinate of face centers for Z-buffering
    for LFace := 0 to length(VisibleFaces) - 1 do
    begin
      VisibleFaces[LFace].CenterZ :=
        (Vertices[VisibleFaces[LFace].Corners[0]].Point.Z +
        Vertices[VisibleFaces[LFace].Corners[length(VisibleFaces[LFace].Corners)
        div 2]].Point.Z) / 2;
    end;

    // sort faces by Z
    QuickSortFaces(VisibleFaces, 0, length(VisibleFaces) - 1);

    // calculate light source direction from center of club
    SourceDirection := UnitVector(Subtract(LightSource, Center));

    // clear bitmap
    OffScrBmp.Canvas.Brush.Color := clblack;
    OffScrBmp.Canvas.FillRect(ScreenRect);

    // find visible vertices and calculate the luminosity at each of them
    // this means that luminosities will only have to be calculated once for each vertex
    SetLength(LVisibleVertices, 0);
    for LVertex := 0 to length(Vertices) - 1 do
      Vertices[LVertex].Visible := False;
    for LFace := 0 to length(VisibleFaces) - 1 do
    begin
      for LVertex := 0 to length(VisibleFaces[LFace].Corners) - 1 do
      begin
        if (VisibleFaces[LFace].Curved) and
        // vertex luminance doesn't need to be calculated for flat faces
          (not Vertices[VisibleFaces[LFace].Corners[LVertex]].Visible) then
        begin
          Vertices[VisibleFaces[LFace].Corners[LVertex]].Visible := True;
          SetLength(LVisibleVertices, length(LVisibleVertices) + 1);
          LVisibleVertices[length(LVisibleVertices) - 1] := VisibleFaces[LFace]
            .Corners[LVertex];
        end;
      end;
    end;
    // calculate the luminance of the visible vertices
    for LVertex := 0 to length(LVisibleVertices) - 1 do
    begin
      LIntensityRatio := DotProduct(Vertices[LVisibleVertices[LVertex]].Normal,
        SourceDirection);
      Vertices[LVisibleVertices[LVertex]].Lum :=
        60 + trunc(130 * max(0, LIntensityRatio));
    end;

    // draw faces in order of Z so that nearer faces are drawn last
    for LFace := 0 to length(VisibleFaces) - 1 do
    begin
      if VisibleFaces[LFace].Curved then
        GouraudFace(LFace)
      else
        FlatFace(LFace);
    end;

  except
    ShowMessage('Exception in RenderObject Method');
  end;
end;

// sort faces by Z for Z-buffering
procedure T3DModel.QuickSortFaces(var A: array of TFace; iLo, iHi: Integer);
Var
  Lo, Hi: Integer;
  Mid: Extended;
  T: TFace;
begin
  try

    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2].CenterZ;
    repeat
      while A[Lo].CenterZ < Mid do
        Inc(Lo);
      while A[Hi].CenterZ > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      QuickSortFaces(A, iLo, Hi);
    if Lo < iHi then
      QuickSortFaces(A, Lo, iHi);

  except
    ShowMessage('Exception in QuickSortFaces Method');
  end;
end;

// render a face of an object with a given colour
procedure T3DModel.FlatFace(AFace: Integer);
Var
  LPolygon: array of TPoint;
  LColor: TColor;
  LIntensityRatio: Extended;
  LVertex: byte;
begin
  try

    SetLength(LPolygon, length(VisibleFaces[AFace].Corners));

    LIntensityRatio := DotProduct(VisibleFaces[AFace].Normal, SourceDirection);

    VisibleFaces[AFace].HLS.L := 60 + trunc(130 * max(0, LIntensityRatio));
    // if HLS.L > 255 then HLS.L := 255;

    // LColor := (IHS.I shl 16) + (IHS.I shl 8) + IHS.I; // greyscale
    LColor := RGBToCol(HLStoRGB(VisibleFaces[AFace].HLS));

    // create polygon array
    for LVertex := 0 to length(LPolygon) - 1 do
    begin
      LPolygon[LVertex].X := round(Vertices[VisibleFaces[AFace].Corners[LVertex]
        ].Point.X);
      LPolygon[LVertex].Y := round(Vertices[VisibleFaces[AFace].Corners[LVertex]
        ].Point.Y);
    end;

    // set face color
    OffScrBmp.Canvas.Pen.Color := LColor;
    OffScrBmp.Canvas.Brush.Color := LColor;

    // draw face
    OffScrBmp.Canvas.Polygon(LPolygon);

  except
    ShowMessage('Exception in FlatFace Method');
  end;
end;

// render the face of an object using Gouraud shading
procedure T3DModel.GouraudFace(AFace: Integer);
Var
  LPolygon: TPointColorTriangle;
  LVertex: byte;
  LRGB: TRGBTriple;
begin
  try
    // first half of rectangle
    for LVertex := 0 to 2 do
    begin
      LPolygon[LVertex - 1].X :=
        round(Vertices[VisibleFaces[AFace].Corners[LVertex]].Point.X);
      LPolygon[LVertex - 1].Y :=
        round(Vertices[VisibleFaces[AFace].Corners[LVertex]].Point.Y);

      // set luminosity to the precalculated value for this corner vertex
      VisibleFaces[AFace].HLS.L :=
        Vertices[VisibleFaces[AFace].Corners[LVertex]].Lum;

      LRGB := HLStoRGB(VisibleFaces[AFace].HLS);
      LPolygon[LVertex].RGB.R := LRGB.rgbtRed;
      LPolygon[LVertex].RGB.G := LRGB.rgbtGreen;
      LPolygon[LVertex].RGB.B := LRGB.rgbtBlue;
    end;

    GouraudPoly(OffScrBmp, LPolygon);

    // second half of rectangle - just replace the middle corner
    LPolygon[1].X := round(Vertices[VisibleFaces[AFace].Corners[3]].Point.X);
    LPolygon[1].Y := round(Vertices[VisibleFaces[AFace].Corners[3]].Point.Y);

    VisibleFaces[AFace].HLS.L := Vertices[VisibleFaces[AFace].Corners[3]].Lum;

    LRGB := HLStoRGB(VisibleFaces[AFace].HLS);
    LPolygon[1].RGB.R := LRGB.rgbtRed;
    LPolygon[1].RGB.G := LRGB.rgbtGreen;
    LPolygon[1].RGB.B := LRGB.rgbtBlue;

    GouraudPoly(OffScrBmp, LPolygon);

    // for LVertex := 1 to 4 do begin // debugging
    // OffScrBmp.Canvas.Pixels[round(Vertices[VisibleFaces[AFace].Corners^[LVertex]].Point.X), round(Vertices[ VisibleFaces[AFace].Corners^[LVertex] ].Point.Y)] := clyellow;
    // end;

  except
    ShowMessage('Exception in GouraudFace Method');
  end;
end;

// fill a traingular polygon using Gouraud shading
procedure T3DModel.GouraudPoly(var ABitmap: TBitmap; V: TPointColorTriangle);
Var
  Lx, RX, Ldx, Rdx: single;
  Dif1, Dif2: single;
  LRGB, RRGB, RGB, RGBdx, LRGBdy, RRGBdy: TRGBFloat;
  RGBT: RGBTriple;
  Scan: PRGBTripleArray;
  Y, X, Vmax: Integer;
  Right: boolean;
  temp: TPointColor;
begin
  try

    // sort vertices by Y
    Vmax := 0;
    if V[1].Y > V[0].Y then
      Vmax := 1;
    if V[2].Y > V[Vmax].Y then
      Vmax := 2;
    if Vmax <> 2 then
    begin
      temp := V[2];
      V[2] := V[Vmax]; // /\
      V[Vmax] := temp; // /  \ region 1
    end; // /____\
    if V[1].Y > V[0].Y then
      Vmax := 1 // /    /
    else
      Vmax := 0; // /   / region 2
    if Vmax = 0 then
    begin // /  /
      temp := V[1]; // / /
      V[1] := V[0]; // /
      V[0] := temp;
    end;

    Dif1 := V[2].Y - V[0].Y;
    if Dif1 = 0 then
      Dif1 := 0.001; // prevent EZeroDivide
    Dif2 := V[1].Y - V[0].Y;
    if Dif2 = 0 then
      Dif2 := 0.001;

    { work out if middle point is to the left or right of the line
      connecting upper and lower points }
    if V[1].X > (V[2].X - V[0].X) * Dif2 / Dif1 + V[0].X then
      Right := True
    else
      Right := False;

    // calculate increments in x and colour for stepping through the lines
    if Right then
    begin
      Ldx := (V[2].X - V[0].X) / Dif1;
      Rdx := (V[1].X - V[0].X) / Dif2;
      LRGBdy.B := (V[2].RGB.B - V[0].RGB.B) / Dif1;
      LRGBdy.G := (V[2].RGB.G - V[0].RGB.G) / Dif1;
      LRGBdy.R := (V[2].RGB.R - V[0].RGB.R) / Dif1;
      RRGBdy.B := (V[1].RGB.B - V[0].RGB.B) / Dif2;
      RRGBdy.G := (V[1].RGB.G - V[0].RGB.G) / Dif2;
      RRGBdy.R := (V[1].RGB.R - V[0].RGB.R) / Dif2;
    end
    else
    begin
      Ldx := (V[1].X - V[0].X) / Dif2;
      Rdx := (V[2].X - V[0].X) / Dif1;
      RRGBdy.B := (V[2].RGB.B - V[0].RGB.B) / Dif1;
      RRGBdy.G := (V[2].RGB.G - V[0].RGB.G) / Dif1;
      RRGBdy.R := (V[2].RGB.R - V[0].RGB.R) / Dif1;
      LRGBdy.B := (V[1].RGB.B - V[0].RGB.B) / Dif2;
      LRGBdy.G := (V[1].RGB.G - V[0].RGB.G) / Dif2;
      LRGBdy.R := (V[1].RGB.R - V[0].RGB.R) / Dif2;
    end;

    LRGB := V[0].RGB;
    RRGB := LRGB;

    Lx := V[0].X;
    RX := V[0].X;

    // fill region 1
    for Y := V[0].Y to V[1].Y do
    begin

      // y clipping
      if Y > ABitmap.Height - 1 then
        Break;
      if Y < 0 then
      begin
        Lx := Lx + Ldx;
        RX := RX + Rdx;
        LRGB.B := LRGB.B + LRGBdy.B;
        LRGB.G := LRGB.G + LRGBdy.G;
        LRGB.R := LRGB.R + LRGBdy.R;
        RRGB.B := RRGB.B + RRGBdy.B;
        RRGB.G := RRGB.G + RRGBdy.G;
        RRGB.R := RRGB.R + RRGBdy.R;
        Continue;
      end;

      Scan := ABitmap.ScanLine[Y];

      // calculate increments in color for stepping through pixels
      Dif1 := RX - Lx + 1;
      if Dif1 = 0 then
        Dif1 := 0.001;
      RGBdx.B := (RRGB.B - LRGB.B) / Dif1;
      RGBdx.G := (RRGB.G - LRGB.G) / Dif1;
      RGBdx.R := (RRGB.R - LRGB.R) / Dif1;

      // x clipping
      if Lx < 0 then
      begin
        RGB.B := LRGB.B + (RGBdx.B * abs(Lx));
        RGB.G := LRGB.G + (RGBdx.G * abs(Lx));
        RGB.R := LRGB.R + (RGBdx.R * abs(Lx));
      end
      else
        RGB := LRGB;

      // scan the line
      for X := max(round(Lx), 0) to min(round(RX), ABitmap.Width - 1) do
      begin
        RGBT.rgbtBlue := trunc(RGB.B);
        RGBT.rgbtGreen := trunc(RGB.G);
        RGBT.rgbtRed := trunc(RGB.R);
        Scan[X] := RGBT;
        RGB.B := RGB.B + RGBdx.B;
        RGB.G := RGB.G + RGBdx.G;
        RGB.R := RGB.R + RGBdx.R;
      end;
      // increment edge x positions
      Lx := Lx + Ldx;
      RX := RX + Rdx;

      // increment edge colours by the y colour increments
      LRGB.B := LRGB.B + LRGBdy.B;
      LRGB.G := LRGB.G + LRGBdy.G;
      LRGB.R := LRGB.R + LRGBdy.R;
      RRGB.B := RRGB.B + RRGBdy.B;
      RRGB.G := RRGB.G + RRGBdy.G;
      RRGB.R := RRGB.R + RRGBdy.R;
    end;

    Dif1 := V[2].Y - V[1].Y;
    if Dif1 = 0 then
      Dif1 := 0.001;
    // calculate new increments for region 2
    if Right then
    begin
      Rdx := (V[2].X - V[1].X) / Dif1;
      RX := V[1].X;
      RRGBdy.B := (V[2].RGB.B - V[1].RGB.B) / Dif1;
      RRGBdy.G := (V[2].RGB.G - V[1].RGB.G) / Dif1;
      RRGBdy.R := (V[2].RGB.R - V[1].RGB.R) / Dif1;
      RRGB := V[1].RGB;
    end
    else
    begin
      Ldx := (V[2].X - V[1].X) / Dif1;
      Lx := V[1].X;
      LRGBdy.B := (V[2].RGB.B - V[1].RGB.B) / Dif1;
      LRGBdy.G := (V[2].RGB.G - V[1].RGB.G) / Dif1;
      LRGBdy.R := (V[2].RGB.R - V[1].RGB.R) / Dif1;
      LRGB := V[1].RGB;
    end;

    // fill region 2
    for Y := V[1].Y + 1 to V[2].Y do
    begin

      // y clipping
      if Y > ABitmap.Height - 1 then
        Break;
      if Y < 0 then
      begin
        Lx := Lx + Ldx;
        RX := RX + Rdx;
        LRGB.B := LRGB.B + LRGBdy.B;
        LRGB.G := LRGB.G + LRGBdy.G;
        LRGB.R := LRGB.R + LRGBdy.R;
        RRGB.B := RRGB.B + RRGBdy.B;
        RRGB.G := RRGB.G + RRGBdy.G;
        RRGB.R := RRGB.R + RRGBdy.R;
        Continue;
      end;

      Scan := ABitmap.ScanLine[Y];

      Dif1 := RX - Lx + 1;
      if Dif1 = 0 then
        Dif1 := 0.001;
      RGBdx.B := (RRGB.B - LRGB.B) / Dif1;
      RGBdx.G := (RRGB.G - LRGB.G) / Dif1;
      RGBdx.R := (RRGB.R - LRGB.R) / Dif1;

      // x clipping
      if Lx < 0 then
      begin
        // calculate starting colour from x=0
        RGB.B := LRGB.B + (RGBdx.B * abs(Lx));
        RGB.G := LRGB.G + (RGBdx.G * abs(Lx));
        RGB.R := LRGB.R + (RGBdx.R * abs(Lx));
      end
      else
        RGB := LRGB;

      // scan the line
      for X := max(round(Lx), 0) to min(round(RX), ABitmap.Width - 1) do
      begin
        RGBT.rgbtBlue := trunc(RGB.B);
        RGBT.rgbtGreen := trunc(RGB.G);
        RGBT.rgbtRed := trunc(RGB.R);
        Scan[X] := RGBT;
        RGB.B := RGB.B + RGBdx.B;
        RGB.G := RGB.G + RGBdx.G;
        RGB.R := RGB.R + RGBdx.R;
      end;

      Lx := Lx + Ldx;
      RX := RX + Rdx;

      LRGB.B := LRGB.B + LRGBdy.B;
      LRGB.G := LRGB.G + LRGBdy.G;
      LRGB.R := LRGB.R + LRGBdy.R;
      RRGB.B := RRGB.B + RRGBdy.B;
      RRGB.G := RRGB.G + RRGBdy.G;
      RRGB.R := RRGB.R + RRGBdy.R;
    end;

  except
    ShowMessage('Exception in GouraudPoly Method');
  end;
end;

// vector handling routines

// calculates the unit vector normal to 2 vectors
function T3DModel.CrossProduct(AVector1, AVector2: TPoint3D): TPoint3D;
begin
  try

    result.X := ((AVector1.Y * AVector2.Z) - (AVector1.Z * AVector2.Y));
    result.Y := ((AVector1.Z * AVector2.X) - (AVector1.X * AVector2.Z));
    result.Z := ((AVector1.X * AVector2.Y) - (AVector1.Y * AVector2.X));

  except
    ShowMessage('Exception in CrossProduct Method');
  end;
end;

// calculates the dot product of 2 vectors
function T3DModel.DotProduct(AVector1, AVector2: TPoint3D): Float;
begin
  result := (AVector1.X * AVector2.X) + (AVector1.Y * AVector2.Y) +
    (AVector1.Z * AVector2.Z);
end;

// reduces a vector to a unit vector
function T3DModel.UnitVector(AVector: TPoint3D): TPoint3D;
Var
  Modulus: Extended;
begin
  try

    Modulus := Sqrt(Sqr(AVector.X) + Sqr(AVector.Y) + Sqr(AVector.Z));
    result := Point3D(AVector.X / Modulus, AVector.Y / Modulus,
      AVector.Z / Modulus);

  except
    result := Point3D(0, 0, 0);
    // ShowMessage('Exception in UnitVector Method');
  end;
end;

// add two vectors together
function T3DModel.Add(AVec1, AVec2: TPoint3D): TPoint3D;
begin
  try

    result := Point3D(AVec1.X + AVec2.X, AVec1.Y + AVec2.Y, AVec1.Z + AVec2.Z);

  except
    result := Point3D(0, 0, 0);
    // ShowMessage('Exception in Add Method');
  end;
end;

// subtract one vector from another
function T3DModel.Subtract(AVec1, AVec2: TPoint3D): TPoint3D;
begin
  try

    result := Point3D(AVec1.X - AVec2.X, AVec1.Y - AVec2.Y, AVec1.Z - AVec2.Z);

  except
    result := Point3D(0, 0, 0);
    // ShowMessage('Exception in Subtract Method');
  end;
end;

procedure T3DModel.ProcessVertices;
Var
  P2, P3, p4: Integer;
  LFace, LVertex: Integer;
begin
  SetLength(Faces, length(Vertices) - 2);
  for LFace := 0 to length(Faces) - 1 do
  begin
    // create a new face by indexing Vertices
    SearchNearestPoints(LFace + 1, P2, P3, p4);
    SetLength(Faces[LFace].Corners, 4);
    Faces[LFace].Corners[0] := P2;
    Faces[LFace].Corners[1] := P3;
    Faces[LFace].Corners[2] := p4;
    Faces[LFace].Corners[3] := LFace;

    Faces[LFace].Curved := True;

  end;

  // calculate face normals
  for LFace := 0 to length(Faces) - 1 do
  begin
    Faces[LFace].Normal := FaceNormal(LFace);
  end;
  CleanZeroFaces; // eliminate faces with normal module = 0
  // calculate vertex normals by averaging the face normals that it toaches
  for LVertex := 0 to length(Vertices) - 1 do
  begin
    Vertices[LVertex].Normal := Point3D(0, 0, 0);
  end;
  for LFace := 0 to length(Faces) - 1 do
  begin
    for LVertex := 1 to length(Faces[LFace].Corners) - 1 do
    begin
      Vertices[Faces[LFace].Corners[LVertex]].Normal :=
        Add(Vertices[Faces[LFace].Corners[LVertex]].Normal,
        Faces[LFace].Normal);
    end;
  end;
  for LVertex := 0 to length(Vertices) - 1 do
  begin
    Vertices[LVertex].Normal := UnitVector(Vertices[LVertex].Normal);
  end;
  CleanZeroVertices;

end;

procedure T3DModel.SearchNearestPoints(Point: Integer; out P1, P2, P3: Integer);
var
  i: Integer;
  d1, d2, d3, dist: Float;
begin
  d1 := MaxNum;
  d2 := d1;
  d3 := d2;
  for i := 0 to length(Vertices) - 1 do
  begin
    dist := Distance(Vertices[Point].Point, Vertices[i].Point);
    if not(dist = 0) then
      if dist <= d1 then
      begin
        d3 := d2;
        P3 := P2;
        d2 := d1;
        P2 := P1;
        d1 := dist;
        P1 := i;
      end
      else if dist <= d2 then
      begin
        d3 := d2;
        P3 := P2;
        d2 := dist;
        P2 := i;
      end
      else if dist < d3 then
      begin
        d3 := dist;
        P3 := i;
      end;
  end;
end;

procedure T3DModel.ColorToFaces(min, max: Float; R, G, B: array of byte);
var
  i: Integer;
  p: tagRGBTRIPLE;
  value: Integer;
begin
  for i := 0 to length(Faces) - 1 do
  begin
    value := round(LinealInterpolation(min, 0, max, 255,
      Vertices[i + 1].value));
    p.rgbtRed := R[value];
    p.rgbtGreen := G[value];
    p.rgbtBlue := B[value];
    // face colours
    Faces[i].HLS := RGBtoHLS(p);
  end;
end;

procedure T3DModel.CleanZeroVertices;
var
  i, cont, old: Integer;
  lvertexs: array of TVertex;
begin
  cont := 0;
  old := length(Vertices);
  for i := 0 to old - 1 do
  begin
    if (VectorModule(Vertices[i].Normal) <> 0) then
    begin
      Inc(cont);
      SetLength(lvertexs, cont);
      lvertexs[cont - 1] := Vertices[i];
    end;
  end;
  if cont < old then
  begin
    SetLength(Vertices, cont);
    for i := 0 to cont - 1 do
      Vertices[i] := lvertexs[i];
    ProcessVertices;
  end;
end;

procedure T3DModel.limpiate;
begin
  SetLength(Vertices, 0);
  SetLength(Faces, 0);
  SetLength(VisibleFaces, 0);
end;

procedure T3DModel.CleanZeroFaces;
var
  i, cont, old: Integer;
  lfaces: array of TFace;
begin
  cont := 0;
  old := length(Faces);
  for i := 0 to old - 1 do
  begin
    if (VectorModule(Faces[i].Normal) <> 0) then
    begin
      Inc(cont);
      SetLength(lfaces, cont);
      lfaces[cont - 1] := Faces[i];
    end;
  end;
  if cont < old then
  begin
    SetLength(Faces, cont);
    for i := 0 to cont - 1 do
      Faces[i] := lfaces[i];
  end;
end;

{ TPoint3D }

class operator TPoint3D.Add(const Lhs, Rhs: TPoint3D): TPoint3D;
begin
  result := Point3D(Lhs.X + Rhs.X, Lhs.Y + Rhs.Y, Lhs.Z + Rhs.Z);
end;

class operator TPoint3D.Equal(const Lhs, Rhs: TPoint3D): boolean;
begin
  result := (Lhs.X = Rhs.X) and (Lhs.Y = Rhs.Y) and (Lhs.Z = Rhs.Z);
end;

class operator TPoint3D.NotEqual(const Lhs, Rhs: TPoint3D): boolean;
begin
  result := (Lhs.X <> Rhs.X) or (Lhs.Y <> Rhs.Y) or (Lhs.Z <> Rhs.Z);
end;

class operator TPoint3D.Subtract(const Lhs, Rhs: TPoint3D): TPoint3D;
begin
  result := Point3D(Lhs.X - Rhs.X, Lhs.Y - Rhs.Y, Lhs.Z - Rhs.Z);
end;

{ TIntPoint3D }

class operator TIntPoint3D.Add(const Lhs, Rhs: TIntPoint3D): TIntPoint3D;
begin
  result := PointInt3D(Lhs.X + Rhs.X, Lhs.Y + Rhs.Y, Lhs.Z + Rhs.Z);
end;

class operator TIntPoint3D.Equal(const Lhs, Rhs: TIntPoint3D): boolean;
begin
  result := (Lhs.X = Rhs.X) and (Lhs.Y = Rhs.Y) and (Lhs.Z = Rhs.Z);
end;

class operator TIntPoint3D.NotEqual(const Lhs, Rhs: TIntPoint3D): boolean;
begin
  result := (Lhs.X <> Rhs.X) or (Lhs.Y <> Rhs.Y) or (Lhs.Z <> Rhs.Z);
end;

class operator TIntPoint3D.Subtract(const Lhs, Rhs: TIntPoint3D): TIntPoint3D;
begin
  result := PointInt3D(Lhs.X - Rhs.X, Lhs.Y - Rhs.Y, Lhs.Z - Rhs.Z);
end;

end.
