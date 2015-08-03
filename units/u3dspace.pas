unit u3dSpace;

{ Unit u3dSpace : 3D space processing Unit

  Created by : Alex Vergara Gil

  Contains the routines for 3D handling algorithms

}

interface

uses utypes, umodel3d, uConstants;

function distance_point_to_plane(point: Tpoint3d; plane: Tplane3d): float;
// function Point3D(x,y,z:integer):TPoint3d;
function solveXplane(plane: Tplane3d; y, z: float): float;
function solveYplane(plane: Tplane3d; z, x: float): float;
function solveZplane(plane: Tplane3d; x, y: float): float;
function sumPoints(point2, point1: Tpoint3d): Tpoint3d; overload;
function sumPoints(point2: Tpoint3d; point1: TIntpoint3D): Tpoint3d; overload;
function sumPoints(point2: TIntpoint3D; point1: Tpoint3d): Tpoint3d; overload;
function sumPoints(point2, point1: TIntpoint3D): TIntpoint3D; overload;
function restPoints(point2, point1: Tpoint3d): Tpoint3d;
function DotProduct(Vector1, Vector2: Tpoint3d): float;
function CrossProduct(Vector1, Vector2: Tpoint3d): Tpoint3d;
function proyect_point_into_plane(point: Tpoint3d; plane: Tplane3d): Tpoint3d;
function VectorModule(Vector: Tpoint3d): float;
function VectorProjection(Vectortoproject, Vector2: Tpoint3d): Tpoint3d;
function newPlane(oldplane: Tplane3d; center, initvector, finvector: Tpoint3d)
  : Tplane3d;
function CreatePlaneWithPoints(P1, P2, P3: Tpoint3d): Tplane3d;
function CreatePlaneWithVectors(P1, r1, r2: Tpoint3d): Tplane3d;
function angle_between_vectors(Vector1, Vector2: Tpoint3d): float;
function SolveInterpolatedPlane(matrix: T3DMatrix; m, n, o: integer;
  var initplane: Tplane3d; center, initvector, finvector: Tpoint3d): TMatrix;
procedure Bordes(rotate: TMatrix; m, n, o: integer; Xdim, Ydim, Zdim: float;
  center: Tpoint3d; out minx, maxx, miny, maxy, minz, maxz: float);
function MaximumProjectionInterpolation(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix): TMatrix;
function MaximumProjectionInterpolationI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix): TMatrix;
procedure InitImageProjection(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; Procedimiento: TRenderProcedures = TRPTrilinear);
procedure FinalizeImageProjection;
function ImageProjection(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; zstep: integer = 0;
  Procedimiento: TRenderProcedures = TRPTrilinear; Maximum: boolean = true;
  trunc: boolean = false; layer: float = 0; wid: float = 1): TMatrix;
procedure InitImageProjectionI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; Procedimiento: TRenderProcedures = TRPTrilinear);
procedure FinalizeImageProjectionI;
function ImageProjectionI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; zstep: integer = 0;
  Procedimiento: TRenderProcedures = TRPTrilinear; Maximum: boolean = true;
  trunc: boolean = false; layer: float = 0; wid: float = 1): TMatrix;
function RenderVolume(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY, ie: integer;
  ImgEdges: TVector; cuales: TBoolVector; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix): TMatrix;
function RenderVolumeI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY, ie: integer;
  ImgEdges: TVector; cuales: TBoolVector; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix): TMatrix;
function RenderVolume2(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax, init, fin: float; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix;
  Procedimiento: TRenderProcedures = TRPTrilinear): TMatrix;
function RenderVolume2I(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax, init, fin: float; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix;
  Procedimiento: TRenderProcedures = TRPTrilinear): TMatrix;
function SurfaceInterpolation(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; Zini: float; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; Procedimiento: TRenderProcedures): TMatrix;
function SurfaceInterpolationI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; Zini: float; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; Procedimiento: TRenderProcedures): TMatrix;
function MatrizdeRotacion(EulerAngles: Tpoint3d): TMatrix; { ZXZ - Euler }
function MatrizdeRotacionInversa(EulerAngles: Tpoint3d): TMatrix;
function MatrizdeRotacionX(Angle: float): TMatrix;
function MatrizdeRotacionY(Angle: float): TMatrix;
function MatrizdeRotacionZ(Angle: float): TMatrix;
function MatrizdeRotacionXInversa(Angle: float): TMatrix;
function MatrizdeRotacionYInversa(Angle: float): TMatrix;
function MatrizdeRotacionZInversa(Angle: float): TMatrix;
function MatrizdeRotacionYX(YAngle, XAngle: float): TMatrix;
function MatrizdeRotacionYXInversa(YAngle, XAngle: float): TMatrix;
procedure Corregistro(I1P1, I1P2, I1P3, I2P1, I2P2, I2P3: Tpoint3d;
  out translacion: Tpoint3d; out rotacion: TMatrix);
function HistogramEqualization(matrix: TMatrix; Ub1, Ub2: integer): TMatrix;
// Here we find an object center, considering object all the values near
// to the value defined by P on the Matrix, near values are defined as
// those values inside a BOX and width size
procedure ObjectCenter(matrix: T3DMatrix; m, n, o: integer; P: TIntpoint3D;
  width: float; out center: Tpoint3d);
procedure ObjectCenterI(matrix: T3DIntMatrix; m, n, o: integer; P: TIntpoint3D;
  width: integer; out center: Tpoint3d);
// images match
function MatchImages(ImageOr, ImageRef: T3DMatrix;
  m1, n1, o1, m2, n2, o2: integer; xdim1, ydim1, zdim1, xdim2, ydim2,
  zdim2: float; traslacion: Tpoint3d; rotacion: TMatrix): T3DMatrix;
function MatchImagesI(ImageOr, ImageRef: T3DIntMatrix;
  m1, n1, o1, m2, n2, o2: integer; xdim1, ydim1, zdim1, xdim2, ydim2,
  zdim2: float; traslacion: Tpoint3d; rotacion: TMatrix): T3DIntMatrix;
function MatchImagesFI(ImageOr: T3DMatrix; ImageRef: T3DIntMatrix;
  m1, n1, o1, m2, n2, o2: integer; xdim1, ydim1, zdim1, xdim2, ydim2,
  zdim2: float; traslacion: Tpoint3d; rotacion: TMatrix): T3DMatrix;

implementation

uses Math, uinterpolation, unewteqs, uoperations, urandom, utrigo,
  umath, uminmax, ucolorconv, uHistogram, windows, utypecasts, uspline;

const
  z_s_size = 3;

  { function Point3D(x,y,z:integer):TPoint3d;
    begin
    Result.X:=x;Result.Y:=y;Result.Z:=z;
    end; }

procedure normalize(var Vector: Tpoint3d);
var
  norma: float;
begin
  norma := VectorModule(Vector);
  Vector.x := Vector.x / norma;
  Vector.y := Vector.y / norma;
  Vector.z := Vector.z / norma;
end;

function DotProduct(Vector1, Vector2: Tpoint3d): float;
begin
  result := Vector1.x * Vector2.x + Vector1.y * Vector2.y + Vector1.z *
    Vector2.z;
end;

function CrossProduct(Vector1, Vector2: Tpoint3d): Tpoint3d;
begin
  result.x := Vector1.y * Vector2.z - Vector2.y * Vector1.z;
  result.y := Vector2.x * Vector1.z - Vector1.x * Vector2.z;
  result.z := Vector1.x * Vector2.y - Vector2.x * Vector1.y;
end;

function VectorProjection(Vectortoproject, Vector2: Tpoint3d): Tpoint3d;
var
  product: float;
begin
  product := DotProduct(Vectortoproject, Vector2) / VectorModule(Vector2);
  result.x := Vector2.x * product;
  result.y := Vector2.y * product;
  result.z := Vector2.z * product;
end;

function CreatePlaneWithPoints(P1, P2, P3: Tpoint3d): Tplane3d;
var
  r1, r2: Tpoint3d;
begin
  r1 := restPoints(P2, P1);
  r2 := restPoints(P3, P1);
  result := CreatePlaneWithVectors(P1, r1, r2);
end;

function CreatePlaneWithVectors(P1, r1, r2: Tpoint3d): Tplane3d;
var
  normal: Tpoint3d;
begin
  normal := CrossProduct(r1, r2);
  normalize(normal);
  result.A := normal.x;
  result.B := normal.y;
  result.C := normal.z;
  result.D := -(result.A * P1.x + result.B * P1.y + result.C * P1.z);
end;

function solveXplane(plane: Tplane3d; y, z: float): float;
begin
  if plane.A <> 0 then
    result := (-1 / plane.A) * (plane.B * y + plane.C * z + plane.D)
  else
  begin
    SetErrCode(FInfinity);
    result := Infinity;
  end;
end;

function solveYplane(plane: Tplane3d; z, x: float): float;
begin
  if plane.B <> 0 then
    result := (-1 / plane.B) * (plane.A * x + plane.C * z + plane.D)
  else
  begin
    SetErrCode(FInfinity);
    result := Infinity;
  end;
end;

function solveZplane(plane: Tplane3d; x, y: float): float;
begin
  if plane.C <> 0 then
    result := (-1 / plane.C) * (plane.A * x + plane.B * y + plane.D)
  else
  begin
    SetErrCode(FInfinity);
    result := Infinity;
  end;
end;

function PlaneVectorModule(plane: Tplane3d): float;
begin
  result := sqrt(plane.A * plane.A + plane.B * plane.B + plane.C * plane.C);
end;

function VectorModule(Vector: Tpoint3d): float;
begin
  result := sqrt(Vector.x * Vector.x + Vector.y * Vector.y + Vector.z *
    Vector.z);
end;

function distance_point_to_plane(point: Tpoint3d; plane: Tplane3d): float;
begin
  result := (plane.A * point.x + plane.B * point.y + plane.C * point.z +
    plane.D) / PlaneVectorModule(plane);
end;

function restPoints(point2, point1: Tpoint3d): Tpoint3d;
begin
  result.x := point2.x - point1.x;
  result.y := point2.y - point1.y;
  result.z := point2.z - point1.z;
end;

function sumPoints(point2, point1: Tpoint3d): Tpoint3d;
begin
  result.x := point2.x + point1.x;
  result.y := point2.y + point1.y;
  result.z := point2.z + point1.z;
end;

function sumPoints(point2: Tpoint3d; point1: TIntpoint3D): Tpoint3d;
begin
  result.x := point2.x + point1.x;
  result.y := point2.y + point1.y;
  result.z := point2.z + point1.z;
end;

function sumPoints(point2: TIntpoint3D; point1: Tpoint3d): Tpoint3d;
begin
  result.x := point2.x + point1.x;
  result.y := point2.y + point1.y;
  result.z := point2.z + point1.z;
end;

function sumPoints(point2, point1: TIntpoint3D): TIntpoint3D;
begin
  result.x := point2.x + point1.x;
  result.y := point2.y + point1.y;
  result.z := point2.z + point1.z;
end;

function damevectordirector(plane: Tplane3d): Tpoint3d;
begin
  result.x := plane.A;
  result.y := plane.B;
  result.z := plane.C;
end;

procedure cogevectordirector(var plane: Tplane3d; Vector: Tpoint3d);
begin
  plane.A := plane.A + Vector.x;
  plane.B := plane.B + Vector.y;
  plane.C := plane.C + Vector.z;
end;

function solveDplane(var plane: Tplane3d; point: Tpoint3d;
  distance: float): float;
begin
  result := distance - (plane.A * point.x + plane.B * point.y + plane.C *
    point.z) * PlaneVectorModule(plane);
end;

function newPlane(oldplane: Tplane3d; center, initvector, finvector: Tpoint3d)
  : Tplane3d;
var
  Vector: Tpoint3d;
  distance: float;
begin
  distance := distance_point_to_plane(center, oldplane);
  Vector := restPoints(finvector, initvector);
  cogevectordirector(oldplane, Vector);
  solveDplane(oldplane, center, distance);
  result := oldplane;
end;

function angle_between_vectors(Vector1, Vector2: Tpoint3d): float;
begin
  result := (Vector1.x * Vector2.x + Vector1.y * Vector2.y + Vector1.z *
    Vector2.z) / (VectorModule(Vector1) * VectorModule(Vector2));
end;

function proyect_point_into_plane(point: Tpoint3d; plane: Tplane3d): Tpoint3d;
var
  distancia: float;
begin
  distancia := distance_point_to_plane(point, plane);
  result.x := point.x - plane.A * distancia;
  result.y := point.y - plane.B * distancia;
  result.z := point.z - plane.C * distancia;
end;

var
  plane: Tplane3d;
  cosn: float = 1;
  initIp: Tpoint3d;
  initJp: Tpoint3d;

procedure NewBaseEquationsX(x: TVector; out F: TVector);
var
  X1, X2, X3: float;
begin
  DimVector(F, 3);
  X1 := x[1] * initIp.x;
  X2 := x[2] * initIp.y;
  X3 := x[3] * initIp.z;
  F[1] := X1 + X2 + X3 - cosn;

  X1 := x[1] * plane.A;
  X2 := x[2] * plane.B;
  X3 := x[3] * plane.C;
  F[2] := X1 + X2 + X3;

  X1 := x[1] * x[1];
  X2 := x[2] * x[2];
  X3 := x[3] * x[3];
  F[2] := X1 + X2 + X3 - 1;
end;

function NewBaseJacobianX(x: TVector): TMatrix;
begin
  DimMatrix(result, 3, 3);
  result[1, 1] := initIp.x;
  result[1, 2] := initIp.y;
  result[1, 3] := initIp.z;
  result[2, 1] := plane.A;
  result[2, 2] := plane.B;
  result[2, 3] := plane.C;
  result[3, 1] := 2 * x[1];
  result[3, 2] := 2 * x[2];
  result[3, 3] := 2 * x[3];
end;

procedure NewBaseEquationsY(x: TVector; out F: TVector);
var
  X1, X2, X3: float;
begin
  DimVector(F, 3);
  X1 := x[1] * initJp.x;
  X2 := x[2] * initJp.y;
  X3 := x[3] * initJp.z;
  F[1] := X1 + X2 + X3 - cosn;

  X1 := x[1] * plane.A;
  X2 := x[2] * plane.B;
  X3 := x[3] * plane.C;
  F[2] := X1 + X2 + X3;

  X1 := x[1] * x[1];
  X2 := x[2] * x[2];
  X3 := x[3] * x[3];
  F[3] := X1 + X2 + X3 - 1;
end;

function NewBaseJacobianY(x: TVector): TMatrix;
begin
  DimMatrix(result, 3, 3);
  result[1, 1] := initJp.x;
  result[1, 2] := initJp.y;
  result[1, 3] := initJp.z;
  result[2, 1] := plane.A;
  result[2, 2] := plane.B;
  result[2, 3] := plane.C;
  result[3, 1] := 2 * x[1];
  result[3, 2] := 2 * x[2];
  result[3, 3] := 2 * x[3];
end;

function VectorToPoint3D(Vector: TVector): Tpoint3d;
begin
  result.x := Vector[1];
  result.y := Vector[2];
  result.z := Vector[3];
end;

function SolveInterpolatedPlane(matrix: T3DMatrix; m, n, o: integer;
  var initplane: Tplane3d; center, initvector, finvector: Tpoint3d): TMatrix;
var
  res: TMatrix;
  Iv, Jv, FI, fJ: TVector;
  Vector1, Vector2, Ip, Jp: Tpoint3d;
  vertice1, vertice2, vertice3, vertice4, vertice5, vertice6, vertice7,
    vertice8: Tpoint3d;
  sizeX, SizeY, cosa, module, minx, maxx, miny, maxy, x, y, z: float;
  i, j, dimx, dimy, tx, ty, tz: integer;
begin
  plane := newPlane(initplane, center, initvector, finvector); // nuevo plano
  Vector1 := damevectordirector(initplane);
  Vector2 := damevectordirector(plane);
  cosn := angle_between_vectors(Vector1, Vector2);
  // coseno del angulo entre los planos viejo y nuevo
  DimVector(Iv, 3);
  DimVector(FI, 3);
  NewtEqs(NewBaseEquationsX, NewBaseJacobianX, Iv, FI, 1, 3, 100, 1.0E-10);
  // nueva base Ip
  Ip := VectorToPoint3D(Iv);
  DelVector(Iv);
  DelVector(FI);
  DimVector(Jv, 3);
  DimVector(fJ, 3);
  NewtEqs(NewBaseEquationsY, NewBaseJacobianY, Jv, fJ, 1, 3, 100, 1.0E-10);
  // nueva base Jp
  Jp := VectorToPoint3D(Jv);
  DelVector(Jv);
  DelVector(fJ);
  vertice1.x := 1;
  vertice1.y := 1;
  vertice1.z := 1; // 2-------6
  vertice2.x := 1;
  vertice2.y := 1;
  vertice2.z := o; // /|      /|
  vertice3.x := m;
  vertice3.y := 1;
  vertice3.z := 1; // / |     / |
  vertice4.x := m;
  vertice4.y := 1;
  vertice4.z := o; // 4 ----- 8  |
  vertice5.x := 1;
  vertice5.y := n;
  vertice5.z := 1; // |  1 ---|- 5
  vertice6.x := 1;
  vertice6.y := n;
  vertice6.z := o; // | /     | /
  vertice7.x := m;
  vertice7.y := n;
  vertice7.z := 1; // |/      |/
  vertice8.x := m;
  vertice8.y := n;
  vertice8.z := o; // 3 ----- 7
  { vertice1 }
  vertice1 := proyect_point_into_plane(vertice1, plane);
  vertice1 := restPoints(vertice1, finvector);
  cosa := angle_between_vectors(vertice1, Ip);
  module := VectorModule(vertice1);
  vertice1.x := module * cosa;
  vertice1.y := module * sqrt(1 - sqr(cosa));
  vertice1.z := 0;
  { vertice2 }
  vertice2 := proyect_point_into_plane(vertice2, plane);
  vertice2 := restPoints(vertice2, finvector);
  cosa := angle_between_vectors(vertice2, Ip);
  module := VectorModule(vertice2);
  vertice2.x := module * cosa;
  vertice2.y := module * sqrt(1 - sqr(cosa));
  vertice2.z := 0;
  { vertice3 }
  vertice3 := proyect_point_into_plane(vertice3, plane);
  vertice3 := restPoints(vertice3, finvector);
  cosa := angle_between_vectors(vertice3, Ip);
  module := VectorModule(vertice3);
  vertice3.x := module * cosa;
  vertice3.y := module * sqrt(1 - sqr(cosa));
  vertice3.z := 0;
  { vertice4 }
  vertice4 := proyect_point_into_plane(vertice4, plane);
  vertice4 := restPoints(vertice4, finvector);
  cosa := angle_between_vectors(vertice4, Ip);
  module := VectorModule(vertice4);
  vertice4.x := module * cosa;
  vertice4.y := module * sqrt(1 - sqr(cosa));
  vertice4.z := 0;
  { vertice5 }
  vertice5 := proyect_point_into_plane(vertice5, plane);
  vertice5 := restPoints(vertice5, finvector);
  cosa := angle_between_vectors(vertice5, Ip);
  module := VectorModule(vertice5);
  vertice5.x := module * cosa;
  vertice5.y := module * sqrt(1 - sqr(cosa));
  vertice5.z := 0;
  { vertice6 }
  vertice6 := proyect_point_into_plane(vertice6, plane);
  vertice6 := restPoints(vertice6, finvector);
  cosa := angle_between_vectors(vertice6, Ip);
  module := VectorModule(vertice6);
  vertice6.x := module * cosa;
  vertice6.y := module * sqrt(1 - sqr(cosa));
  vertice6.z := 0;
  { vertice7 }
  vertice7 := proyect_point_into_plane(vertice7, plane);
  vertice7 := restPoints(vertice7, finvector);
  cosa := angle_between_vectors(vertice7, Ip);
  module := VectorModule(vertice7);
  vertice7.x := module * cosa;
  vertice7.y := module * sqrt(1 - sqr(cosa));
  vertice7.z := 0;
  { vertice8 }
  vertice8 := proyect_point_into_plane(vertice8, plane);
  vertice8 := restPoints(vertice8, finvector);
  cosa := angle_between_vectors(vertice8, Ip);
  module := VectorModule(vertice8);
  vertice8.x := module * cosa;
  vertice8.y := module * sqrt(1 - sqr(cosa));
  vertice8.z := 0;
  { Busqueda de las dimensiones }
  minx := MaxNum;
  maxx := -MaxNum;
  miny := MaxNum;
  maxy := -MaxNum;
  if vertice1.x < minx then
    minx := vertice1.x;
  if vertice1.y < miny then
    miny := vertice1.y;
  if vertice1.x > maxx then
    maxx := vertice1.x;
  if vertice1.y < maxy then
    maxy := vertice1.y;
  if vertice2.x < minx then
    minx := vertice2.x;
  if vertice2.y < miny then
    miny := vertice2.y;
  if vertice2.x > maxx then
    maxx := vertice2.x;
  if vertice2.y < maxy then
    maxy := vertice2.y;
  if vertice3.x < minx then
    minx := vertice3.x;
  if vertice3.y < miny then
    miny := vertice3.y;
  if vertice3.x > maxx then
    maxx := vertice3.x;
  if vertice3.y < maxy then
    maxy := vertice3.y;
  if vertice4.x < minx then
    minx := vertice4.x;
  if vertice4.y < miny then
    miny := vertice4.y;
  if vertice4.x > maxx then
    maxx := vertice4.x;
  if vertice4.y < maxy then
    maxy := vertice4.y;
  if vertice5.x < minx then
    minx := vertice5.x;
  if vertice5.y < miny then
    miny := vertice5.y;
  if vertice5.x > maxx then
    maxx := vertice5.x;
  if vertice5.y < maxy then
    maxy := vertice5.y;
  if vertice6.x < minx then
    minx := vertice6.x;
  if vertice6.y < miny then
    miny := vertice6.y;
  if vertice6.x > maxx then
    maxx := vertice6.x;
  if vertice6.y < maxy then
    maxy := vertice6.y;
  if vertice7.x < minx then
    minx := vertice7.x;
  if vertice7.y < miny then
    miny := vertice7.y;
  if vertice7.x > maxx then
    maxx := vertice7.x;
  if vertice7.y < maxy then
    maxy := vertice7.y;
  if vertice8.x < minx then
    minx := vertice8.x;
  if vertice8.y < miny then
    miny := vertice8.y;
  if vertice8.x > maxx then
    maxx := vertice8.x;
  if vertice8.y < maxy then
    maxy := vertice8.y;
  vertice3.x := minx * Ip.x + miny * Jp.x + finvector.x;
  vertice3.x := minx * Ip.y + miny * Jp.y + finvector.y;
  vertice3.x := minx * Ip.z + miny * Jp.z + finvector.z;
  vertice4.x := maxx * Ip.x + maxy * Jp.x + finvector.x;
  vertice4.x := maxx * Ip.y + maxy * Jp.y + finvector.y;
  vertice4.x := maxx * Ip.z + maxy * Jp.z + finvector.z;
  vertice1 := restPoints(vertice4, vertice3);
  vertice2 := proyect_point_into_plane(vertice1, plane);
  cosn := angle_between_vectors(vertice2, Ip);
  module := VectorModule(vertice2);
  sizeX := module * cosn;
  SizeY := module * sqrt(1 - sqr(cosn));
  dimx := round(sizeX);
  dimy := round(SizeY);
  DimMatrix(result, dimx, dimy);
  for i := 1 to dimx do
    for j := 1 to dimy do
    begin
      x := LinealInterpolation(1, minx, dimx, maxx, i) * Ip.x +
        LinealInterpolation(1, miny, dimy, maxy, j) * Jp.x + finvector.x;
      y := LinealInterpolation(1, minx, dimx, maxx, i) * Ip.y +
        LinealInterpolation(1, miny, dimy, maxy, j) * Jp.y + finvector.y;
      z := LinealInterpolation(1, minx, dimx, maxx, i) * Ip.z +
        LinealInterpolation(1, miny, dimy, maxy, j) * Jp.z + finvector.z;
      tx := trunc(x);
      ty := trunc(y);
      tz := trunc(z);
      result[i, j] := BiLineal3DInterpolation(tx, ty, tz, tx + 1, ty + 1,
        tz + 1, matrix[tx, ty, tz], matrix[tx, ty, tz + 1],
        matrix[tx + 1, ty, tz], matrix[tx + 1, ty, tz + 1],
        matrix[tx, ty + 1, tz], matrix[tx, ty + 1, tz + 1],
        matrix[tx + 1, ty + 1, tz], matrix[tx + 1, ty + 1, tz + 1], x, y, z);
    end;
end;

procedure Bordes(rotate: TMatrix; m, n, o: integer; Xdim, Ydim, Zdim: float;
  center: Tpoint3d; out minx, maxx, miny, maxy, minz, maxz: float);
var
  x, y, z, newx, newy, newz: float;
begin
  { obtencion de los bordes }
  // los bordes por z no hacen falta puesto que vemos la matriz en el plano xy
  minx := MaxNum;
  miny := MaxNum;
  minz := MaxNum;
  maxx := -MaxNum;
  maxy := -MaxNum;
  maxz := -MaxNum;
  // 2-------6      Z
  // /|      /|      |
  // / |     / |      |
  // 4 ----- 8  |      |
  // |  1 ---|- 5      0------Y
  // | /     | /      /
  // |/      |/      /
  // 3 ----- 7      X
  // recorremos los vertices
  { 1 }
  x := (1 - center.x) * Xdim;
  y := (1 - center.y) * Ydim;
  z := (1 - center.z) * Zdim;
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 2 }
  // x:=(1-Center.X)*Xdim;y:=(1-Center.Y)*Ydim; //ya estan calculados
  z := (o - center.z) * Zdim;
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 3 }
  x := (m - center.x) * Xdim;
  z := (1 - center.z) * Zdim;
  // y:=(1-Center.Y)*Ydim; //ya esta calculado
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 4 }
  // x:=(m-Center.X)*Xdim;y:=(1-Center.Y)*Ydim; //ya estan calculados
  z := (o - center.z) * Zdim;
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 5 }
  x := (1 - center.x) * Xdim;
  y := (n - center.y) * Ydim;
  z := (1 - center.z) * Zdim;
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 6 }
  // x:=(1-Center.X)*Xdim;y:=(n-Center.Y)*Ydim; //ya estan calculados
  z := (o - center.z) * Zdim;
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 7 }
  x := (m - center.x) * Xdim;
  z := (1 - center.z) * Zdim;
  // y:=(n-Center.Y)*Ydim; //ya esta calculado
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
  { 8 }
  // x:=(m-Center.X)*Xdim;y:=(n-Center.Y)*Ydim; //ya estan calculados
  z := (o - center.z) * Zdim;
  newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
  if newx < minx then
    minx := newx;
  if newx > maxx then
    maxx := newx;
  newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
  if newy < miny then
    miny := newy;
  if newy > maxy then
    maxy := newy;
  newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
  if newz < minz then
    minz := newz;
  if newz > maxz then
    maxz := newz;
end;

procedure Proyectar(sizeX, SizeY: integer; minx, miny, maxx, maxy: float;
  out xini, yini, xfin, yfin, xstep, ystep: integer; out xint, yint: boolean);
begin
  if (maxx - minx < sizeX - 1) and (maxx <> minx) then
  begin
    xini := trunc((sizeX - (maxx - minx + 1)) / 2);
    xfin := sizeX - xini;
    xint := true;
    xstep := trunc((sizeX) / (maxx - minx + 1));
  end
  else
  begin
    xini := 1;
    xfin := sizeX;
    xint := false;
    xstep := 0;
  end;
  if (maxy - miny < SizeY - 1) and (maxy <> miny) then
  begin
    yini := trunc((SizeY - (maxy - miny + 1)) / 2);
    yfin := SizeY - yini;
    yint := true;
    ystep := trunc((SizeY) / (maxy - miny + 1));
  end
  else
  begin
    yini := 1;
    yfin := SizeY;
    yint := false;
    ystep := 0;
  end;
end;

Procedure FixXYRatio(minx, miny, maxx, maxy: float;
  out xini, yini, xfin, yfin: float);
var
  ratio, move: float;
begin
  xini := minx;
  xfin := maxx;
  yini := miny;
  yfin := maxy;
  ratio := (maxx - minx) / (maxy - miny);
  if ratio = 1 then
    exit;
  if ratio > 1 then
  begin
    move := ((maxx - minx) - (maxy - miny)) / 2;
    yini := miny - move;
    yfin := maxy + move;
    exit;
  end;
  if ratio < 1 then
  begin
    move := -((maxx - minx) - (maxy - miny)) / 2;
    xini := minx - move;
    xfin := maxx + move;
  end;
end;

procedure Interpolate(var xstep, ystep: integer; var result: TMatrix;
  sizeX, SizeY: integer; imgmin: float);
var
  i, j, k: integer;
begin
  if xstep > 1 then
    for i := 1 to SizeY do
    begin
      j := 1;
      repeat
        if (j + xstep + 1 > sizeX) then
        begin
          if (result[j + xstep, i] = imgmin) then
            if (result[j + xstep - 1, i] <> imgmin) then
              dec(xstep);
        end
        else if (result[j + xstep, i] = imgmin) then
        begin
          if (result[j + xstep + 1, i] <> imgmin) then
            inc(xstep)
          else if (result[j + xstep - 1, i] <> imgmin) then
            dec(xstep);
        end;
        if xstep <= 1 then
          break;
        for k := j + 1 to j + xstep - 1 do
        begin
          result[k, i] := LinealInterpolation(j, result[j, i], j + xstep,
            result[j + xstep, i], k);
        end;
        j := j + xstep;
      until j + xstep > sizeX;
    end;
  if ystep > 1 then
    for i := 1 to sizeX do
    begin
      j := 1;
      repeat
        if (j + ystep + 1 > SizeY) then
        begin
          if (result[j + ystep, i] = imgmin) then
            if (result[j + ystep - 1, i] <> imgmin) then
              dec(ystep);
        end
        else if (result[i, j + ystep] = imgmin) then
        begin
          if (result[i, j + ystep + 1] <> imgmin) then
            inc(ystep)
          else if (result[i, j + ystep - 1] <> imgmin) then
            dec(ystep);
        end;
        if ystep <= 1 then
          break;
        for k := j + 1 to j + ystep - 1 do
        begin
          result[i, k] := LinealInterpolation(j, result[i, j], j + ystep,
            result[i, j + ystep], k);
        end;
        j := j + ystep;
      until j + ystep > SizeY;
    end;
end;

function MaximumProjectionInterpolation(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix): TMatrix;
var
  xint, yint: boolean;
  i, j, k, mx, my, xini, yini, xfin, yfin, xstep, ystep: integer;
  x, y, z, newx, newy, newz, minx, miny, minz, maxx, maxy, maxz: float;
begin
  Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
    minz, maxz);

  { Ya tenemos los bordes ahora proyectamos }
  Proyectar(sizeX, SizeY, minx, miny, maxx, maxy, xini, yini, xfin, yfin, xstep,
    ystep, xint, yint);
  oimgmin := imgmax;
  oimgmax := imgmin;
  DimMatrix(result, sizeX, SizeY, imgmin);
  DimMatrix(Z_s, sizeX, SizeY, z_s_size,
    round(Max3(m * Xdim, n * Ydim, o * Zdim)));
  for i := 1 to m do
  begin
    x := (i - center.x) * Xdim;
    for j := 1 to n do
    begin
      y := (j - center.y) * Ydim;
      for k := 1 to o do
      begin
        z := (k - center.z) * Zdim;
        newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
        newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
        // newz:=rotate[3,1]*x+rotate[3,2]*y+rotate[3,3]*z;
        mx := trunc(LinealInterpolation(minx, { 1 } xini, maxx,
          { sizex } xfin, newx));
        my := trunc(LinealInterpolation(miny, { 1 } yini, maxy,
          { sizey } yfin, newy));
        if (matrix[i, j, k] > result[mx, my]) then
        begin
          result[mx, my] := matrix[i, j, k];
          Z_s[mx, my, 1] := i;
          Z_s[mx, my, 2] := j;
          Z_s[mx, my, 3] := k;
          if result[mx, my] < oimgmin then
            oimgmin := result[mx, my];
          if result[mx, my] > oimgmax then
            oimgmax := result[mx, my];
        end;
      end;
    end;
  end;
  Interpolate(xstep, ystep, result, sizeX, SizeY, imgmin);
end;

function MaximumProjectionInterpolationI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix): TMatrix;
var
  xint, yint: boolean;
  i, j, k, mx, my, xini, yini, xfin, yfin, xstep, ystep: integer;
  x, y, z, newx, newy, newz, minx, miny, minz, maxx, maxy, maxz: float;
begin
  Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
    minz, maxz);

  { Ya tenemos los bordes ahora proyectamos }
  Proyectar(sizeX, SizeY, minx, miny, maxx, maxy, xini, yini, xfin, yfin, xstep,
    ystep, xint, yint);
  oimgmin := imgmax;
  oimgmax := imgmin;
  DimMatrix(result, sizeX, SizeY, imgmin);
  DimMatrix(Z_s, sizeX, SizeY, z_s_size,
    round(Max3(m * Xdim, n * Ydim, o * Zdim)));
  for i := 1 to m do
  begin
    x := (i - center.x) * Xdim;
    for j := 1 to n do
    begin
      y := (j - center.y) * Ydim;
      for k := 1 to o do
      begin
        z := (k - center.z) * Zdim;
        newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
        newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
        // newz:=rotate[3,1]*x+rotate[3,2]*y+rotate[3,3]*z;
        mx := trunc(LinealInterpolation(minx, { 1 } xini, maxx,
          { sizex } xfin, newx));
        my := trunc(LinealInterpolation(miny, { 1 } yini, maxy,
          { sizey } yfin, newy));
        if (matrix[i, j, k] > result[mx, my]) then
        begin
          result[mx, my] := matrix[i, j, k];
          Z_s[mx, my, 1] := i;
          Z_s[mx, my, 2] := j;
          Z_s[mx, my, 3] := k;
          if result[mx, my] < oimgmin then
            oimgmin := result[mx, my];
          if result[mx, my] > oimgmax then
            oimgmax := result[mx, my];
        end;
      end;
    end;
  end;
  Interpolate(xstep, ystep, result, sizeX, SizeY, imgmin);
end;

var
  lspline: TSpline3D;
  X1, X2, X3: TVector;
  IPInitiated: boolean = false;

procedure InitImageProjection(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; Procedimiento: TRenderProcedures);
var
  i: integer;
begin
  if (Procedimiento <> TRPTrilinear) and (Procedimiento <> TRPTrilinear) then
  begin
    DimVector(X1, m);
    DimVector(X2, n);
    DimVector(X3, o);
    for i := 1 to m do
      X1[i] := i * Xdim;
    for i := 1 to n do
      X2[i] := i * Ydim;
    for i := 1 to o do
      X3[i] := i * Zdim;
    if Procedimiento = TRPTriCubic then
      lspline := TSpline3D.Create(X1, X2, X3, m, n, o, matrix);
  end;
  IPInitiated := true;
end;

procedure FinalizeImageProjection;
begin
  DelVector(X1);
  DelVector(X2);
  DelVector(X3);
  lspline.Free;
  IPInitiated := false;
end;

function ImageProjection(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; zstep: integer; Procedimiento: TRenderProcedures;
  Maximum: boolean; trunc: boolean; layer, wid: float): TMatrix;
var
  xint, yint: boolean;
  i, j, k, mx, my, xstep, ystep, cont: integer;
  x, y, z, xini, yini, xfin, yfin, newx, newy, newz, minx, miny, maxx, maxy,
    minz, maxz, value, error, max: float;
begin
  if IPInitiated then
  begin
    Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
      minz, maxz);
    FixXYRatio(minx, miny, maxx, maxy, xini, yini, xfin, yfin);
    oimgmin := imgmax;
    oimgmax := imgmin;
    if zstep <= 0 then
      zstep := ceil(Pythag(m, Pythag(n, o)));
    DimMatrix(result, sizeX, SizeY, imgmin);
    DimMatrix(Z_s, sizeX, SizeY, z_s_size,
      round(Max3(m * Xdim, n * Ydim, o * Zdim)));
    for i := 1 to sizeX do
    begin
      newx := LinealInterpolation(1, xini, sizeX, xfin, i);
      if (newx >= minx) and (newx <= maxx) then
        for j := 1 to SizeY do
        begin
          newy := LinealInterpolation(1, yini, SizeY, yfin, j);
          max := imgmin;
          cont := 0;
          if (newy >= miny) and (newy <= maxy) then
            for k := 1 to zstep do
            begin
              newz := LinealInterpolation(1, minz, zstep, maxz, k);
              x := (rotate[1, 1] * newx + rotate[2, 1] * newy + rotate[3, 1] *
                newz) / Xdim + center.x;
              y := (rotate[1, 2] * newx + rotate[2, 2] * newy + rotate[3, 2] *
                newz) / Ydim + center.y;
              z := (rotate[1, 3] * newx + rotate[2, 3] * newy + rotate[3, 3] *
                newz) / Zdim + center.z;
              if (x >= 1) and (x <= m) and (y >= 1) and (y <= n) and
                (z >= 1) and (z <= o) then
              begin
                inc(cont);
                case Procedimiento of
                  TRPNearestNeighbor:
                    value := matrix[round(x), round(y), round(z)];
                  TRPTrilinear:
                    value := Lineal3DInterpolation(Floor(x), Floor(y), Floor(z),
                      ceil(x), ceil(y), ceil(z), matrix[Floor(x), Floor(y),
                      Floor(z)], matrix[Floor(x), Floor(y), ceil(z)],
                      matrix[ceil(x), Floor(y), Floor(z)],
                      matrix[ceil(x), Floor(y), ceil(z)],
                      matrix[Floor(x), ceil(y), Floor(z)],
                      matrix[Floor(x), ceil(y), ceil(z)],
                      matrix[ceil(x), ceil(y), Floor(z)],
                      matrix[ceil(x), ceil(y), ceil(z)], x, y, z);
                  TRPTriCubic:
                    value := lspline.CubicSpline(x, y, z);
                  TRPPolinomial3D:
                    value := Polinomial3DInterpolation(X1, X2, X3, matrix, m, n,
                      o, x, y, z, error);
                  TRPRational3D:
                    value := RationalFunction3DInterpolation(X1, X2, X3, matrix,
                      m, n, o, x, y, z, error);
                else
                  value := imgmin;
                end;
                if Maximum then
                begin
                  if value > result[i, j] then
                  begin
                    result[i, j] := value;
                    Z_s[i, j, 1] := x;
                    Z_s[i, j, 2] := y;
                    Z_s[i, j, 3] := z;
                  end;
                end
                else if trunc then
                begin
                  if (abs(value - layer) <= abs(wid)) then
                  begin
                    result[i, j] := value;
                    Z_s[i, j, 1] := x;
                    Z_s[i, j, 2] := y;
                    Z_s[i, j, 3] := z;
                    break;
                  end;
                end
                else
                begin
                  result[i, j] := result[i, j] + value - imgmin;
                  if value > max then
                  begin
                    max := value;
                    Z_s[i, j, 1] := x;
                    Z_s[i, j, 2] := y;
                    Z_s[i, j, 3] := z;
                  end;
                end;
              end;
            end;
          if (cont <> 0) and not Maximum then
          begin
            result[i, j] := result[i, j] / cont + imgmin;
          end;
          if result[i, j] < oimgmin then
            oimgmin := result[i, j];
          if result[i, j] > oimgmax then
            oimgmax := result[i, j];
        end;
    end;
  end;
end;

var
  IPIInitiated: boolean = false;

procedure InitImageProjectionI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; Procedimiento: TRenderProcedures);
var
  i: integer;
begin
  if (Procedimiento <> TRPTrilinear) and (Procedimiento <> TRPNearestNeighbor)
  then
  begin
    DimVector(X1, m);
    DimVector(X2, n);
    DimVector(X3, o);
    for i := 1 to m do
      X1[i] := i * Xdim;
    for i := 1 to n do
      X2[i] := i * Ydim;
    for i := 1 to o do
      X3[i] := i * Zdim;
    if Procedimiento = TRPTriCubic then
      lspline := TSpline3D.Create(X1, X2, X3, m, n, o, matrix);
  end;
  IPIInitiated := true;
end;

procedure FinalizeImageProjectionI;
begin
  DelVector(X1);
  DelVector(X2);
  DelVector(X3);
  lspline.Free;
  IPIInitiated := false;
end;

function ImageProjectionI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; zstep: integer; Procedimiento: TRenderProcedures;
  Maximum: boolean; trunc: boolean; layer, wid: float): TMatrix;
var
  xint, yint: boolean;
  i, j, k, mx, my, xstep, ystep, cont: integer;
  x, y, z, xini, yini, xfin, yfin, newx, newy, newz, minx, miny, maxx, maxy,
    minz, maxz, value, error, max: float;
begin
  if IPIInitiated then
  begin
    Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
      minz, maxz);
    FixXYRatio(minx, miny, maxx, maxy, xini, yini, xfin, yfin);
    oimgmin := imgmax;
    oimgmax := imgmin;
    if zstep <= 0 then
      zstep := ceil(Pythag(m, Pythag(n, o)));
    DimMatrix(result, sizeX, SizeY, imgmin);
    DimMatrix(Z_s, sizeX, SizeY, z_s_size,
      round(Max3(m * Xdim, n * Ydim, o * Zdim)));
    for i := 1 to sizeX do
    begin
      newx := LinealInterpolation(1, xini, sizeX, xfin, i);
      if (newx >= minx) and (newx <= maxx) then
        for j := 1 to SizeY do
        begin
          newy := LinealInterpolation(1, yini, SizeY, yfin, j);
          max := imgmin;
          cont := 0;
          if (newy >= miny) and (newy <= maxy) then
            for k := 1 to zstep do
            begin
              newz := LinealInterpolation(1, minz, zstep, maxz, k);
              x := (rotate[1, 1] * newx + rotate[2, 1] * newy + rotate[3, 1] *
                newz) / Xdim + center.x;
              y := (rotate[1, 2] * newx + rotate[2, 2] * newy + rotate[3, 2] *
                newz) / Ydim + center.y;
              z := (rotate[1, 3] * newx + rotate[2, 3] * newy + rotate[3, 3] *
                newz) / Zdim + center.z;
              if (x >= 1) and (x <= m) and (y >= 1) and (y <= n) and
                (z >= 1) and (z <= o) then
              begin
                inc(cont);
                case Procedimiento of
                  TRPNearestNeighbor:
                    value := matrix[round(x), round(y), round(z)];
                  TRPTrilinear:
                    value := Lineal3DInterpolation(Floor(x), Floor(y), Floor(z),
                      ceil(x), ceil(y), ceil(z), matrix[Floor(x), Floor(y),
                      Floor(z)], matrix[Floor(x), Floor(y), ceil(z)],
                      matrix[ceil(x), Floor(y), Floor(z)],
                      matrix[ceil(x), Floor(y), ceil(z)],
                      matrix[Floor(x), ceil(y), Floor(z)],
                      matrix[Floor(x), ceil(y), ceil(z)],
                      matrix[ceil(x), ceil(y), Floor(z)],
                      matrix[ceil(x), ceil(y), ceil(z)], x, y, z);
                  TRPTriCubic:
                    value := lspline.CubicSpline(x, y, z);
                  TRPPolinomial3D:
                    value := Polinomial3DInterpolation(X1, X2, X3, matrix, m, n,
                      o, x, y, z, error);
                  TRPRational3D:
                    value := RationalFunction3DInterpolation(X1, X2, X3, matrix,
                      m, n, o, x, y, z, error);
                else
                  value := imgmin;
                end;
                if Maximum then
                begin
                  if value > result[i, j] then
                  begin
                    result[i, j] := value;
                    Z_s[i, j, 1] := x;
                    Z_s[i, j, 2] := y;
                    Z_s[i, j, 3] := z;
                  end;
                end
                else if trunc then
                begin
                  if (abs(value - layer) <= abs(wid)) then
                  begin
                    result[i, j] := value;
                    Z_s[i, j, 1] := x;
                    Z_s[i, j, 2] := y;
                    Z_s[i, j, 3] := z;
                    break;
                  end;
                end
                else
                begin
                  result[i, j] := result[i, j] + sqr(value - imgmin);
                  if value > max then
                  begin
                    max := value;
                    Z_s[i, j, 1] := x;
                    Z_s[i, j, 2] := y;
                    Z_s[i, j, 3] := z;
                  end;
                end;
              end;
            end;
          if (cont <> 0) and not Maximum and not trunc then
            result[i, j] := sqrt(result[i, j]) / cont + imgmin;
          if (result[i, j] < oimgmin) and (result[i, j] <> imgmin) then
            oimgmin := result[i, j];
          if (result[i, j] > oimgmax) then
            oimgmax := result[i, j];
        end;
    end;
  end;
end;

function RenderVolume(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY, ie: integer;
  ImgEdges: TVector; cuales: TBoolVector; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix): TMatrix;
var
  xint, yint: boolean;
  Zs: TMatrix;
  i, j, k, mx, my, xini, yini, xfin, yfin, xstep, ystep: integer;
  x, y, z, newx, newy, newz, minx, miny, maxx, maxy, minz, maxz: float;
  function sigue(elemento: float): boolean;
  var
    Ip: integer;
  begin
    result := false;
    for Ip := 1 to ie - 1 do
    begin
      if cuales[Ip] then
        result := result or ((elemento >= ImgEdges[Ip]) and
          (elemento <= ImgEdges[Ip + 1]));
    end;
  end;

begin
  Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
    minz, maxz);

  { Ya tenemos los bordes ahora proyectamos }
  Proyectar(sizeX, SizeY, minx, miny, maxx, maxy, xini, yini, xfin, yfin, xstep,
    ystep, xint, yint);
  oimgmin := ImgEdges[ie];
  oimgmax := ImgEdges[1];
  DimMatrix(result, sizeX, SizeY, ImgEdges[1]);
  DimMatrix(Zs, sizeX, SizeY, MaxNum);
  DimMatrix(Z_s, sizeX, SizeY, z_s_size,
    round(Max3(m * Xdim, n * Ydim, o * Zdim)));
  for i := 1 to m do
  begin
    x := (i - center.x) * Xdim;
    for j := 1 to n do
    begin
      y := (j - center.y) * Ydim;
      for k := 1 to o do
      begin
        z := (k - center.z) * Zdim;
        newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
        newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
        newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
        mx := trunc(LinealInterpolation(minx, { 1 } xini, maxx,
          { sizex } xfin, newx));
        my := trunc(LinealInterpolation(miny, { 1 } yini, maxy,
          { sizey } yfin, newy));
        if ((newz < Zs[mx, my]) and sigue(matrix[i, j, k])) then
        begin
          Z_s[mx, my, 1] := i;
          Z_s[mx, my, 2] := j;
          Z_s[mx, my, 3] := k;
          result[mx, my] := matrix[i, j, k];
          if result[mx, my] < oimgmin then
            oimgmin := result[mx, my];
          if result[mx, my] > oimgmax then
            oimgmax := result[mx, my];
        end;
      end;
    end;
  end;
  Interpolate(xstep, ystep, result, sizeX, SizeY, ImgEdges[1]);
  DelMatrix(Zs);
end;

function RenderVolumeI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY, ie: integer;
  ImgEdges: TVector; cuales: TBoolVector; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix): TMatrix;
var
  xint, yint: boolean;
  Zs: TMatrix;
  i, j, k, mx, my, xini, yini, xfin, yfin, xstep, ystep: integer;
  x, y, z, newx, newy, newz, minx, miny, maxx, maxy, minz, maxz: float;
  function sigue(elemento: integer): boolean;
  var
    Ip: integer;
  begin
    result := false;
    for Ip := 1 to ie - 1 do
    begin
      if cuales[Ip] then
        result := result or ((elemento >= ImgEdges[Ip]) and
          (elemento <= ImgEdges[Ip + 1]));
    end;
  end;

begin
  Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
    minz, maxz);

  { Ya tenemos los bordes ahora proyectamos }
  Proyectar(sizeX, SizeY, minx, miny, maxx, maxy, xini, yini, xfin, yfin, xstep,
    ystep, xint, yint);
  oimgmin := ImgEdges[ie];
  oimgmax := ImgEdges[1];
  DimMatrix(result, sizeX, SizeY, ImgEdges[1]);
  DimMatrix(Zs, sizeX, SizeY, MaxNum);
  DimMatrix(Z_s, sizeX, SizeY, z_s_size,
    round(Max3(m * Xdim, n * Ydim, o * Zdim)));
  for i := 1 to m do
  begin
    x := (i - center.x) * Xdim;
    for j := 1 to n do
    begin
      y := (j - center.y) * Ydim;
      for k := 1 to o do
      begin
        z := (k - center.z) * Zdim;
        newx := rotate[1, 1] * x + rotate[1, 2] * y + rotate[1, 3] * z;
        newy := rotate[2, 1] * x + rotate[2, 2] * y + rotate[2, 3] * z;
        newz := rotate[3, 1] * x + rotate[3, 2] * y + rotate[3, 3] * z;
        mx := trunc(LinealInterpolation(minx, { 1 } xini, maxx,
          { sizex } xfin, newx));
        my := trunc(LinealInterpolation(miny, { 1 } yini, maxy,
          { sizey } yfin, newy));
        if ((newz < Zs[mx, my]) and sigue(matrix[i, j, k])) then
        begin
          Z_s[mx, my, 1] := i;
          Z_s[mx, my, 2] := j;
          Z_s[mx, my, 3] := k;
          result[mx, my] := matrix[i, j, k];
          if result[mx, my] < oimgmin then
            oimgmin := result[mx, my];
          if result[mx, my] > oimgmax then
            oimgmax := result[mx, my];
        end;
      end;
    end;
  end;
  Interpolate(xstep, ystep, result, sizeX, SizeY, ImgEdges[1]);
  DelMatrix(Zs);
end;

function RenderVolume2(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax, init, fin: float; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix;
  Procedimiento: TRenderProcedures): TMatrix;
var
  xint, yint, seguir: boolean;
  i, j, k, mx, my, xstep, ystep: integer;
  x, y, z, newx, xini, yini, xfin, yfin, newy, newz, minx, miny, maxx, maxy,
    zstep, minz, maxz, value, error: float;
begin
  Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
    minz, maxz);
  FixXYRatio(minx, miny, maxx, maxy, xini, yini, xfin, yfin);
  oimgmin := imgmax;
  oimgmax := imgmin;
  zstep := sqrt(sqr(m * Xdim) + sqr(n * Ydim) + sqr(o * Zdim)) / (m + n + o);
  DimMatrix(result, sizeX, SizeY, imgmin);
  DimMatrix(Z_s, sizeX, SizeY, z_s_size,
    round(Max3(m * Xdim, n * Ydim, o * Zdim)));
  if (Procedimiento <> TRPTrilinear) and (Procedimiento <> TRPNearestNeighbor)
    and not IPInitiated then
  begin
    InitImageProjection(matrix, m, n, o, Xdim, Ydim, Zdim, Procedimiento);
  end;
  for i := 1 to sizeX do
  begin
    newx := LinealInterpolation(1, xini, sizeX, xfin, i);
    if (newx >= minx) and (newx <= maxx) then
      for j := 1 to SizeY do
      begin
        newy := LinealInterpolation(1, yini, SizeY, yfin, j);
        if (newy >= miny) and (newy <= maxy) then
        begin
          k := 1;
          seguir := true;
          repeat
            newz := LinealInterpolation(1, minz,
              ceil(sqrt(m * m + n * n + o * o)), maxz, k);
            x := (rotate[1, 1] * newx + rotate[2, 1] * newy + rotate[3, 1] *
              newz) / Xdim + center.x;
            y := (rotate[1, 2] * newx + rotate[2, 2] * newy + rotate[3, 2] *
              newz) / Ydim + center.y;
            z := (rotate[1, 3] * newx + rotate[2, 3] * newy + rotate[3, 3] *
              newz) / Zdim + center.z;
            if (x >= 1) and (x <= m) and (y >= 1) and (y <= n) and (z >= 1) and
              (z <= o) then
            begin
              case Procedimiento of
                TRPNearestNeighbor:
                  value := matrix[round(x), round(y), round(z)];
                TRPTrilinear:
                  begin
                    value := Lineal3DInterpolation(Floor(x), Floor(y), Floor(z),
                      ceil(x), ceil(y), ceil(z), matrix[Floor(x), Floor(y),
                      Floor(z)], matrix[Floor(x), Floor(y), ceil(z)],
                      matrix[ceil(x), Floor(y), Floor(z)],
                      matrix[ceil(x), Floor(y), ceil(z)],
                      matrix[Floor(x), ceil(y), Floor(z)],
                      matrix[Floor(x), ceil(y), ceil(z)],
                      matrix[ceil(x), ceil(y), Floor(z)],
                      matrix[ceil(x), ceil(y), ceil(z)], x, y, z);
                  end;
                TRPTriCubic:
                  value := lspline.CubicSpline(x, y, z);
                TRPPolinomial3D:
                  value := Polinomial3DInterpolation(X1, X2, X3, matrix, m, n,
                    o, x, y, z, error);
                TRPRational3D:
                  value := RationalFunction3DInterpolation(X1, X2, X3, matrix,
                    m, n, o, x, y, z, error);
              else
                value := imgmin;
              end;
              if (value >= init) and (value <= fin) then
              begin
                result[i, j] := value;
                Z_s[i, j, 1] := x;
                Z_s[i, j, 2] := y;
                Z_s[i, j, 3] := z;
                if result[i, j] < oimgmin then
                  oimgmin := result[i, j];
                if result[i, j] > oimgmax then
                  oimgmax := result[i, j];
                seguir := false;
              end;
            end;
            inc(k);
          until (k >= ceil(sqrt(m * m + n * n + o * o))) or not seguir;
        end;
      end;
  end;
  if (Procedimiento <> TRPTrilinear) and (Procedimiento <> TRPNearestNeighbor)
  then
  begin
    FinalizeImageProjection;
  end;
end;

function RenderVolume2I(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; sizeX, SizeY: integer;
  imgmin, imgmax, init, fin: float; var rotate: TMatrix;
  out oimgmin, oimgmax: float; out Z_s: T3DMatrix;
  Procedimiento: TRenderProcedures = TRPTrilinear): TMatrix;
var
  xint, yint, seguir: boolean;
  i, j, k, mx, my, xstep, ystep: integer;
  x, y, z, xini, yini, xfin, yfin, newx, newy, newz, minx, miny, maxx, maxy,
    zstep, minz, maxz, value, error: float;
begin
  Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
    minz, maxz);
  FixXYRatio(minx, miny, maxx, maxy, xini, yini, xfin, yfin);
  oimgmin := imgmax;
  oimgmax := imgmin;
  zstep := sqrt(sqr(m * Xdim) + sqr(n * Ydim) + sqr(o * Zdim)) / (m + n + o);
  DimMatrix(result, sizeX, SizeY, imgmin);
  DimMatrix(Z_s, sizeX, SizeY, z_s_size,
    round(Max3(m * Xdim, n * Ydim, o * Zdim)));
  if (Procedimiento <> TRPTrilinear) and (Procedimiento <> TRPNearestNeighbor)
    and not IPIInitiated then
  begin
    InitImageProjectionI(matrix, m, n, o, Xdim, Ydim, Zdim, Procedimiento);
  end;
  for i := 1 to sizeX do
  begin
    newx := LinealInterpolation(1, xini, sizeX, xfin, i);
    if (newx >= minx) and (newx <= maxx) then
      for j := 1 to SizeY do
      begin
        newy := LinealInterpolation(1, yini, SizeY, yfin, j);
        if (newy >= miny) and (newy <= maxy) then
        begin
          k := 1;
          seguir := true;
          repeat
            newz := LinealInterpolation(1, minz,
              ceil(sqrt(m * m + n * n + o * o)), maxz, k);
            x := (rotate[1, 1] * newx + rotate[2, 1] * newy + rotate[3, 1] *
              newz) / Xdim + center.x;
            y := (rotate[1, 2] * newx + rotate[2, 2] * newy + rotate[3, 2] *
              newz) / Ydim + center.y;
            z := (rotate[1, 3] * newx + rotate[2, 3] * newy + rotate[3, 3] *
              newz) / Zdim + center.z;
            if (x >= 1) and (x <= m) and (y >= 1) and (y <= n) and (z >= 1) and
              (z <= o) then
            begin
              case Procedimiento of
                TRPNearestNeighbor:
                  value := matrix[round(x), round(y), round(z)];
                TRPTrilinear:
                  begin
                    value := Lineal3DInterpolation(Floor(x), Floor(y), Floor(z),
                      ceil(x), ceil(y), ceil(z), matrix[Floor(x), Floor(y),
                      Floor(z)], matrix[Floor(x), Floor(y), ceil(z)],
                      matrix[ceil(x), Floor(y), Floor(z)],
                      matrix[ceil(x), Floor(y), ceil(z)],
                      matrix[Floor(x), ceil(y), Floor(z)],
                      matrix[Floor(x), ceil(y), ceil(z)],
                      matrix[ceil(x), ceil(y), Floor(z)],
                      matrix[ceil(x), ceil(y), ceil(z)], x, y, z);
                  end;
                TRPTriCubic:
                  value := lspline.CubicSpline(x, y, z);
                TRPPolinomial3D:
                  value := Polinomial3DInterpolation(X1, X2, X3, matrix, m, n,
                    o, x, y, z, error);
                TRPRational3D:
                  value := RationalFunction3DInterpolation(X1, X2, X3, matrix,
                    m, n, o, x, y, z, error);
              else
                value := imgmin;
              end;
              if (value >= init) and (value <= fin) then
              begin
                result[i, j] := value;
                Z_s[i, j, 1] := x;
                Z_s[i, j, 2] := y;
                Z_s[i, j, 3] := z;
                if result[i, j] < oimgmin then
                  oimgmin := result[i, j];
                if result[i, j] > oimgmax then
                  oimgmax := result[i, j];
                seguir := false;
              end;
            end;
            inc(k);
          until (k >= ceil(sqrt(m * m + n * n + o * o))) or not seguir;
        end;
      end;
  end;
  if (Procedimiento <> TRPTrilinear) and (Procedimiento <> TRPNearestNeighbor)
  then
  begin
    FinalizeImageProjectionI;
  end;
end;

function SurfaceInterpolation(matrix: T3DMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; Zini: float; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; Procedimiento: TRenderProcedures): TMatrix;
var
  i, j: integer;
  x, y, z, xini, yini, xfin, yfin, newx, newy, newz, minx, miny, maxx, maxy,
    minz, maxz, value, error: float;
begin
  if IPInitiated then
  begin
    Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
      minz, maxz);
    FixXYRatio(minx, miny, maxx, maxy, xini, yini, xfin, yfin);
    oimgmin := imgmax;
    oimgmax := imgmin;
    DimMatrix(result, sizeX, SizeY, imgmin);
    DimMatrix(Z_s, sizeX, SizeY, z_s_size,
      round(Max3(m * Xdim, n * Ydim, o * Zdim)));
    newz := Zini; // !!!! Esto es lo que lo hace mas rápido
    for i := 1 to sizeX do
    begin
      newx := LinealInterpolation(1, xini, sizeX, xfin, i);
      if (newx >= minx) and (newx <= maxx) then
        for j := 1 to SizeY do
        begin
          newy := LinealInterpolation(1, yini, SizeY, yfin, j);
          if (newy >= miny) and (newy <= maxy) then
          begin
            x := (rotate[1, 1] * newx + rotate[2, 1] * newy + rotate[3, 1] *
              newz) / Xdim + center.x;
            y := (rotate[1, 2] * newx + rotate[2, 2] * newy + rotate[3, 2] *
              newz) / Ydim + center.y;
            z := (rotate[1, 3] * newx + rotate[2, 3] * newy + rotate[3, 3] *
              newz) / Zdim + center.z;
            if (x >= 1) and (x <= m) and (y >= 1) and (y <= n) and (z >= 1) and
              (z <= o) then
            begin
              case Procedimiento of
                TRPNearestNeighbor:
                  value := matrix[round(x), round(y), round(z)];
                TRPTrilinear:
                  begin
                    value := Lineal3DInterpolation(Floor(x), Floor(y), Floor(z),
                      ceil(x), ceil(y), ceil(z), matrix[Floor(x), Floor(y),
                      Floor(z)], matrix[Floor(x), Floor(y), ceil(z)],
                      matrix[ceil(x), Floor(y), Floor(z)],
                      matrix[ceil(x), Floor(y), ceil(z)],
                      matrix[Floor(x), ceil(y), Floor(z)],
                      matrix[Floor(x), ceil(y), ceil(z)],
                      matrix[ceil(x), ceil(y), Floor(z)],
                      matrix[ceil(x), ceil(y), ceil(z)], x, y, z);
                  end;
                TRPTriCubic:
                  value := lspline.CubicSpline(x, y, z);
                TRPPolinomial3D:
                  value := Polinomial3DInterpolation(X1, X2, X3, matrix, m, n,
                    o, x, y, z, error);
                TRPRational3D:
                  value := RationalFunction3DInterpolation(X1, X2, X3, matrix,
                    m, n, o, x, y, z, error);
              else
                value := imgmin;
              end;
              Z_s[i, j, 1] := x;
              Z_s[i, j, 2] := y;
              Z_s[i, j, 3] := z;
              result[i, j] := value;
              if result[i, j] < oimgmin then
                oimgmin := result[i, j];
              if result[i, j] > oimgmax then
                oimgmax := result[i, j];
            end;
          end;
        end;
    end;
  end;
end;

function SurfaceInterpolationI(matrix: T3DIntMatrix; m, n, o: integer;
  Xdim, Ydim, Zdim: float; center: Tpoint3d; Zini: float; sizeX, SizeY: integer;
  imgmin, imgmax: float; var rotate: TMatrix; out oimgmin, oimgmax: float;
  out Z_s: T3DMatrix; Procedimiento: TRenderProcedures): TMatrix;
var
  i, j: integer;
  x, y, z, xini, yini, xfin, yfin, newx, newy, newz, minx, miny, maxx, maxy,
    minz, maxz, value, error: float;
begin
  if IPIInitiated then
  begin
    Bordes(rotate, m, n, o, Xdim, Ydim, Zdim, center, minx, maxx, miny, maxy,
      minz, maxz);
    FixXYRatio(minx, miny, maxx, maxy, xini, yini, xfin, yfin);
    oimgmin := imgmax;
    oimgmax := imgmin;
    DimMatrix(result, sizeX, SizeY, imgmin);
    DimMatrix(Z_s, sizeX, SizeY, z_s_size,
      round(Max3(m * Xdim, n * Ydim, o * Zdim)));
    newz := Zini; // !!!! Esto es lo que lo hace mas rápido
    for i := 1 to sizeX do
    begin
      newx := LinealInterpolation(1, xini, sizeX, xfin, i);
      if (newx >= minx) and (newx <= maxx) then
        for j := 1 to SizeY do
        begin
          newy := LinealInterpolation(1, yini, SizeY, yfin, j);
          if (newy >= miny) and (newy <= maxy) then
          begin
            x := (rotate[1, 1] * newx + rotate[2, 1] * newy + rotate[3, 1] *
              newz) / Xdim + center.x;
            y := (rotate[1, 2] * newx + rotate[2, 2] * newy + rotate[3, 2] *
              newz) / Ydim + center.y;
            z := (rotate[1, 3] * newx + rotate[2, 3] * newy + rotate[3, 3] *
              newz) / Zdim + center.z;
            if (x >= 1) and (x <= m) and (y >= 1) and (y <= n) and (z >= 1) and
              (z <= o) then
            begin
              case Procedimiento of
                TRPNearestNeighbor:
                  value := matrix[round(x), round(y), round(z)];
                TRPTrilinear:
                  begin
                    value := Lineal3DInterpolation(Floor(x), Floor(y), Floor(z),
                      ceil(x), ceil(y), ceil(z), matrix[Floor(x), Floor(y),
                      Floor(z)], matrix[Floor(x), Floor(y), ceil(z)],
                      matrix[ceil(x), Floor(y), Floor(z)],
                      matrix[ceil(x), Floor(y), ceil(z)],
                      matrix[Floor(x), ceil(y), Floor(z)],
                      matrix[Floor(x), ceil(y), ceil(z)],
                      matrix[ceil(x), ceil(y), Floor(z)],
                      matrix[ceil(x), ceil(y), ceil(z)], x, y, z);
                  end;
                TRPTriCubic:
                  value := lspline.CubicSpline(x, y, z);
                TRPPolinomial3D:
                  value := Polinomial3DInterpolation(X1, X2, X3, matrix, m, n,
                    o, x, y, z, error);
                TRPRational3D:
                  value := RationalFunction3DInterpolation(X1, X2, X3, matrix,
                    m, n, o, x, y, z, error);
              else
                value := imgmin;
              end;
              Z_s[i, j, 1] := x;
              Z_s[i, j, 2] := y;
              Z_s[i, j, 3] := z;
              result[i, j] := value;
              if result[i, j] < oimgmin then
                oimgmin := result[i, j];
              if result[i, j] > oimgmax then
                oimgmax := result[i, j];
            end;
          end;
        end;
    end;
  end;
end;

procedure Corregistro(I1P1, I1P2, I1P3, I2P1, I2P2, I2P3: Tpoint3d;
  out translacion: Tpoint3d; out rotacion: TMatrix);
var
  tempx, tempy, temp: TMatrix;
begin
  translacion := restPoints(I2P1, I1P1);
  tempx := MatrizdeRotacionX(Atan(Hypot(I2P2.x, I1P2.y), I2P2.z) -
    Atan(Hypot(I1P2.x, I1P2.y), I1P2.z));
  tempy := MatrizdeRotacionY(Atan(Hypot(I2P3.x, I1P3.z), I2P3.y) -
    Atan(Hypot(I1P3.x, I1P3.z), I1P3.y));
  rotacion := MatrizdeRotacionZ(Atan(I2P2.y, I2P2.x) - Atan(I1P2.y, I1P2.x));
  temp := Multiply(tempx, rotacion, 3, 3, 3);
  DelMatrix(rotacion);
  rotacion := temp;
  temp := Multiply(tempy, rotacion, 3, 3, 3);
  DelMatrix(rotacion);
  rotacion := temp;
  DelMatrix(tempx);
  DelMatrix(tempy);
end;

function MatrizdeRotacion(EulerAngles: Tpoint3d): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Row 1 }
  result[1, 1] := cos(EulerAngles.z) * cos(EulerAngles.x) - cos(EulerAngles.y) *
    sin(EulerAngles.x) * sin(EulerAngles.z);
  result[1, 2] := cos(EulerAngles.z) * sin(EulerAngles.x) + cos(EulerAngles.y) *
    cos(EulerAngles.x) * sin(EulerAngles.z);
  result[1, 3] := sin(EulerAngles.z) * sin(EulerAngles.y);
  { Row 2 }
  result[2, 1] := -sin(EulerAngles.z) * cos(EulerAngles.x) - cos(EulerAngles.y)
    * sin(EulerAngles.x) * cos(EulerAngles.z);
  result[2, 2] := -sin(EulerAngles.z) * sin(EulerAngles.x) + cos(EulerAngles.y)
    * cos(EulerAngles.x) * cos(EulerAngles.z);
  result[2, 3] := cos(EulerAngles.z) * sin(EulerAngles.y);
  { Row 3 }
  result[3, 1] := sin(EulerAngles.y) * sin(EulerAngles.x);
  result[3, 2] := -sin(EulerAngles.y) * cos(EulerAngles.x);
  result[3, 3] := cos(EulerAngles.y);
end;

function MatrizdeRotacionInversa(EulerAngles: Tpoint3d): TMatrix; // Traspuesta
begin
  DimMatrix(result, 3, 3);
  { Column 1 }
  result[1, 1] := cos(EulerAngles.z) * cos(EulerAngles.x) - cos(EulerAngles.y) *
    sin(EulerAngles.x) * sin(EulerAngles.z);
  result[2, 1] := cos(EulerAngles.z) * sin(EulerAngles.x) + cos(EulerAngles.y) *
    cos(EulerAngles.x) * sin(EulerAngles.z);
  result[3, 1] := sin(EulerAngles.z) * sin(EulerAngles.y);
  { Column 2 }
  result[1, 2] := -sin(EulerAngles.z) * cos(EulerAngles.x) - cos(EulerAngles.y)
    * sin(EulerAngles.x) * cos(EulerAngles.z);
  result[2, 2] := -sin(EulerAngles.z) * sin(EulerAngles.x) + cos(EulerAngles.y)
    * cos(EulerAngles.x) * cos(EulerAngles.z);
  result[3, 2] := cos(EulerAngles.z) * sin(EulerAngles.y);
  { Column 3 }
  result[1, 3] := sin(EulerAngles.y) * sin(EulerAngles.x);
  result[2, 3] := -sin(EulerAngles.y) * cos(EulerAngles.x);
  result[3, 3] := cos(EulerAngles.y);
end;

function MatrizdeRotacionX(Angle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }         { Column 2 }                  { Column 3 }
  result[1, 1] := 1;
  result[1, 2] := 0;
  result[1, 3] := 0;
  result[2, 1] := 0;
  result[2, 2] := cos(Angle);
  result[2, 3] := sin(Angle);
  result[3, 1] := 0;
  result[3, 2] := -sin(Angle);
  result[3, 3] := cos(Angle);
end;

function MatrizdeRotacionY(Angle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }                  { Column 2 }         { Column 3 }
  result[1, 1] := cos(Angle);
  result[1, 2] := 0;
  result[1, 3] := -sin(Angle);
  result[2, 1] := 0;
  result[2, 2] := 1;
  result[2, 3] := 0;
  result[3, 1] := sin(Angle);
  result[3, 2] := 0;
  result[3, 3] := cos(Angle);
end;

function MatrizdeRotacionZ(Angle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }                  { Column 2 }                  { Column 3 }
  result[1, 1] := cos(Angle);
  result[1, 2] := sin(Angle);
  result[1, 3] := 0;
  result[2, 1] := -sin(Angle);
  result[2, 2] := cos(Angle);
  result[2, 3] := 0;
  result[3, 1] := 0;
  result[3, 2] := 0;
  result[3, 3] := 1;
end;

function MatrizdeRotacionXInversa(Angle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }        { Column 2 }                  { Column 3 }
  result[1, 1] := 1;
  result[1, 2] := 0;
  result[1, 3] := 0;
  result[2, 1] := 0;
  result[2, 2] := cos(Angle);
  result[2, 3] := -sin(Angle);
  result[3, 1] := 0;
  result[3, 2] := sin(Angle);
  result[3, 3] := cos(Angle);
end;

function MatrizdeRotacionYInversa(Angle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }                  { Column 2 }        { Column 3 }
  result[1, 1] := cos(Angle);
  result[1, 2] := 0;
  result[1, 3] := sin(Angle);
  result[2, 1] := 0;
  result[2, 2] := 1;
  result[2, 3] := 0;
  result[3, 1] := -sin(Angle);
  result[3, 2] := 0;
  result[3, 3] := cos(Angle);
end;

function MatrizdeRotacionZInversa(Angle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }                  { Column 2 }                  { Column 3 }
  result[1, 1] := cos(Angle);
  result[1, 2] := -sin(Angle);
  result[1, 3] := 0;
  result[2, 1] := sin(Angle);
  result[2, 2] := cos(Angle);
  result[2, 3] := 0;
  result[3, 1] := 0;
  result[3, 2] := 0;
  result[3, 3] := 1;
end;

function MatrizdeRotacionYX(YAngle, XAngle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }                   { Column 2 }                               { Column 3 }
  result[1, 1] := cos(YAngle);
  result[1, 2] := sin(XAngle) * sin(YAngle);
  result[1, 3] := -cos(XAngle) * sin(YAngle);
  result[2, 1] := 0;
  result[2, 2] := cos(XAngle);
  result[2, 3] := sin(XAngle);
  result[3, 1] := sin(YAngle);
  result[3, 2] := -sin(XAngle) * cos(YAngle);
  result[3, 3] := cos(XAngle) * cos(YAngle);
end;

function MatrizdeRotacionYXInversa(YAngle, XAngle: float): TMatrix;
begin
  DimMatrix(result, 3, 3);
  { Column 1 }                                { Column 2 }                   { Column 3 }
  result[1, 1] := cos(YAngle);
  result[1, 2] := 0;
  result[1, 3] := sin(YAngle);
  result[2, 1] := sin(XAngle) * sin(YAngle);
  result[2, 2] := cos(XAngle);
  result[2, 3] := -sin(XAngle) * cos(YAngle);
  result[3, 1] := -cos(XAngle) * sin(YAngle);
  result[3, 2] := sin(XAngle);
  result[3, 3] := cos(XAngle) * cos(YAngle);
end;

function HistogramEqualization(matrix: TMatrix; Ub1, Ub2: integer): TMatrix;
const
  size = 65536 div 2;
type
  Tainteger = array [0 .. size - 1] of integer;
var
  Tr, z: Tainteger;
  i, j: integer;
  histo: TIntVector;
  min, max, sk: float;
begin
  MinMax(matrix, 1, Ub1, 1, Ub2, min, max);
  sk := 0;
  histo := Histograma(matrix, Ub1, Ub2, min, max, size - 1);
  for i := 0 to size - 1 do
  begin
    sk := sk + (histo[i + 1] / (Ub1 * Ub2));
    Tr[i] := round(sk * size);
  end;
  DelVector(histo);
  for i := 0 to size - 1 do
  begin
    z[i] := 0;
    while Tr[z[i]] - i < 0 do
      inc(z[i]);
  end;
  DimMatrix(result, Ub1, Ub2);
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
    begin
      sk := LinealInterpolation(min, 0, max, size - 1, matrix[i, j]);
      sk := Tr[round(sk)];
      sk := LinealInterpolation(Tr[0], min, Tr[size - 1], max, sk);
      result[i, j] := sk;
    end;
end;

procedure ObjectCenter(matrix: T3DMatrix; m, n, o: integer; P: TIntpoint3D;
  width: float; out center: Tpoint3d);
var
  reference: float;
  visitados: T3DBoolMatrix;
  cont: integer;
  procedure recursive(ix, iy, iz: integer);
  begin
    if not visitados[ix, iy, iz] then
    begin
      visitados[ix, iy, iz] := true;
      if abs(matrix[ix, iy, iz] - reference) <= abs(width) then
      begin
        inc(cont);
        center := sumPoints(center, Point3d(ix, iy, iz));
        if (ix - 1 > 0) then
          recursive(ix - 1, iy, iz);
        if (ix + 1 <= m) then
          recursive(ix + 1, iy, iz);
        if (iy - 1 > 0) then
          recursive(ix, iy - 1, iz);
        if (iy + 1 <= n) then
          recursive(ix, iy + 1, iz);
        if (iz - 1 > 0) then
          recursive(ix, iy, iz - 1);
        if (iz + 1 <= o) then
          recursive(ix, iy, iz + 1);
      end;
    end;
  end;

begin
  DimMatrix(visitados, m, n, o);
  center := Point3d(0.0, 0.0, 0.0);
  cont := 0;
  reference := matrix[P.x, P.y, P.z];
  recursive(P.x, P.y, P.z);
  center := Point3d(center.x / cont, center.y / cont, center.z / cont);
end;

procedure ObjectCenterI(matrix: T3DIntMatrix; m, n, o: integer; P: TIntpoint3D;
  width: integer; out center: Tpoint3d);
var
  reference: float;
  visitados: T3DBoolMatrix;
  cont: integer;
  procedure recursive(ix, iy, iz: integer);
  begin
    if not visitados[ix, iy, iz] then
    begin
      visitados[ix, iy, iz] := true;
      if abs(matrix[ix, iy, iz] - reference) <= abs(width) then
      begin
        inc(cont);
        center := sumPoints(center, Point3d(ix, iy, iz));
        if (ix - 1 > 0) then
          recursive(ix - 1, iy, iz);
        if (ix + 1 <= m) then
          recursive(ix + 1, iy, iz);
        if (iy - 1 > 0) then
          recursive(ix, iy - 1, iz);
        if (iy + 1 <= n) then
          recursive(ix, iy + 1, iz);
        if (iz - 1 > 0) then
          recursive(ix, iy, iz - 1);
        if (iz + 1 <= o) then
          recursive(ix, iy, iz + 1);
      end;
    end;
  end;

begin
  DimMatrix(visitados, m, n, o);
  center := Point3d(0.0, 0.0, 0.0);
  cont := 0;
  reference := matrix[P.x, P.y, P.z];
  recursive(P.x, P.y, P.z);
  center := Point3d(center.x / cont, center.y / cont, center.z / cont);
end;

function MatchImages(ImageOr, ImageRef: T3DMatrix;
  m1, n1, o1, m2, n2, o2: integer; xdim1, ydim1, zdim1, xdim2, ydim2,
  zdim2: float; traslacion: Tpoint3d; rotacion: TMatrix): T3DMatrix;
var
  i, j, k, mx, my, mz: integer;
  x, y, z: float;
begin
  result := Clone(ImageOr, m1, n1, o1);
  for i := 1 to m1 do
  begin
    x := (i - traslacion.x) * xdim1;
    for j := 1 to n1 do
    begin
      y := (j - traslacion.y) * ydim1;
      for k := 1 to o1 do
      begin
        z := (k - traslacion.z) * zdim1;
        mx := round((rotacion[1, 1] * x + rotacion[2, 1] * y + rotacion[3,
          1] * z) / xdim2);
        my := round((rotacion[1, 2] * x + rotacion[2, 2] * y + rotacion[3,
          2] * z) / ydim2);
        mz := round((rotacion[1, 3] * x + rotacion[2, 3] * y + rotacion[3,
          3] * z) / zdim2);
        result[mx, my, mz] := result[mx, my, mz] + ImageRef[i, j, k];
      end;
    end;
  end;
end;

function MatchImagesI(ImageOr, ImageRef: T3DIntMatrix;
  m1, n1, o1, m2, n2, o2: integer; xdim1, ydim1, zdim1, xdim2, ydim2,
  zdim2: float; traslacion: Tpoint3d; rotacion: TMatrix): T3DIntMatrix;
var
  i, j, k, mx, my, mz: integer;
  x, y, z: float;
begin
  result := Clone(ImageOr, m1, n1, o1);
  for i := 1 to m1 do
  begin
    x := (i - traslacion.x) * xdim1;
    for j := 1 to n1 do
    begin
      y := (j - traslacion.y) * ydim1;
      for k := 1 to o1 do
      begin
        z := (k - traslacion.z) * zdim1;
        mx := round((rotacion[1, 1] * x + rotacion[2, 1] * y + rotacion[3,
          1] * z) / xdim2);
        my := round((rotacion[1, 2] * x + rotacion[2, 2] * y + rotacion[3,
          2] * z) / ydim2);
        mz := round((rotacion[1, 3] * x + rotacion[2, 3] * y + rotacion[3,
          3] * z) / zdim2);
        result[mx, my, mz] := result[mx, my, mz] + ImageRef[i, j, k];
      end;
    end;
  end;
end;

function MatchImagesFI(ImageOr: T3DMatrix; ImageRef: T3DIntMatrix;
  m1, n1, o1, m2, n2, o2: integer; xdim1, ydim1, zdim1, xdim2, ydim2,
  zdim2: float; traslacion: Tpoint3d; rotacion: TMatrix): T3DMatrix;
var
  i, j, k, mx, my, mz: integer;
  x, y, z: float;
begin
  result := Clone(ImageOr, m1, n1, o1);
  for i := 1 to m1 do
  begin
    x := (i - traslacion.x) * xdim1;
    for j := 1 to n1 do
    begin
      y := (j - traslacion.y) * ydim1;
      for k := 1 to o1 do
      begin
        z := (k - traslacion.z) * zdim1;
        mx := round((rotacion[1, 1] * x + rotacion[2, 1] * y + rotacion[3,
          1] * z) / xdim2);
        my := round((rotacion[1, 2] * x + rotacion[2, 2] * y + rotacion[3,
          2] * z) / ydim2);
        mz := round((rotacion[1, 3] * x + rotacion[2, 3] * y + rotacion[3,
          3] * z) / zdim2);
        result[mx, my, mz] := result[mx, my, mz] + ImageRef[i, j, k];
      end;
    end;
  end;
end;

begin
  initIp.x := 1;
  initIp.y := 0;
  initIp.z := 0;
  initJp.x := 0;
  initJp.y := 1;
  initJp.z := 0;

end.
