function Distance(Point1,Point2:TPoint3D):float;
var temp:TPoint3D;
begin
  temp:=restPoints(Point2,Point1);
  result:=Pythag(temp.X,Pythag(temp.Y,temp.Z));
end;

{ ------------T3DModel------------------- }

// build a general rotational object
procedure T3DModel.BuildRotationalVolume(Coords, Radius : array of extended ;
                                         LayerColors : array of TColor ;
                                         Detail : integer);
Var
  LAngle : extended;
  LRot : integer;
  LP : TPoints;
  LFace, LVertex : integer;
  Lsin, Lcos : extended;
  LRing : integer;
  NumRings : integer;
begin
  try

    NumRings := length(Coords);
    SetLength(LP, NumRings);
    SetLength(Vertices, Detail * NumRings);
    SetLength(Faces, Detail * (NumRings - 1) + 2);
    LVertex := 0;
    LFace := 0;

    // set initial point positions and ring heights
    for LRing := 0 to NumRings - 1 do begin
      Vertices[LVertex].Point := Point3D(Radius[LRing], Coords[LRing], 0);
      Inc(LVertex);
      LP[LRing].Y := Coords[LRing];
    end;

    // create Vertices by rotating points around rings
    for LRot := 1 to Detail do begin
      if LRot < Detail then begin
        LAngle := 2*pi * LRot / Detail;
        SinCos(LAngle, Lsin, Lcos);
        // calculate new point positions
        for LRing := 0 to NumRings - 1 do begin
          LP[LRing].X := Radius[LRing] * Lcos;
          LP[LRing].Z := Radius[LRing] * Lsin;
        end;
        // store new points in Vertices
        for LRing := 0 to NumRings - 1 do begin
          Vertices[LVertex].Point := LP[LRing];
          Inc(LVertex);
        end;
      end;
      // create a new face by indexing Vertices
      SetLength(Faces[LFace].Corners,4);
      for LRing := 0 to NumRings - 2 do begin
        Faces[LFace].Corners[0] := ((LRot-1) * NumRings) + LRing;
        Faces[LFace].Corners[1] := ((LRot-1) * NumRings) + LRing + 1;
        if LRot = Detail then begin // join up 1st layer and 2nd layer faces
          Faces[LFace].Corners[2] := Faces[LRing].Corners[1];
          Faces[LFace].Corners[3] := Faces[LRing].Corners[0];
        end else begin
          Faces[LFace].Corners[2] := (LRot * NumRings) + LRing + 1;
          Faces[LFace].Corners[3] := (LRot * NumRings) + LRing;
        end;

        // face colours
        Faces[LFace].HLS := RGBtoHLS( ColorToRGB(LayerColors[LRing]) );

        Faces[LFace].Curved := True;

        Inc(LFace);
      end;
    end;

    // create end faces
    SetLength(Faces[length(Faces)-2].Corners, Detail);
    SetLength(Faces[length(Faces)-1].Corners, Detail);
    for LRot := 0 to Detail - 1 do begin
      Faces[length(Faces)-2].Corners[LRot] := LRot * NumRings;
      Faces[length(Faces)-1].Corners[LRot] := ((LRot+1) * NumRings) - 1;
    end;
    // colours
    Faces[length(Faces)-2].HLS := RGBtoHLS( ColorToRGB(LayerColors[length(LayerColors) - 2]) );
    Faces[length(Faces)-1].HLS := RGBtoHLS( ColorToRGB(LayerColors[length(LayerColors) - 1]) );

    Faces[length(Faces)-2].Curved := False; // end faces are not curved
    Faces[length(Faces)-1].Curved := False;

    // calculate face normals
    for LFace := 0 to length(Faces) - 3 do begin
      Faces[LFace].Normal := FaceNormal(LFace);
    end;
    // end faces
    Faces[length(Faces)-2].Normal := Point3D(0, -1, 0);
    Faces[length(Faces)-1].Normal := Point3D(0,  1, 0);

    // calculate vertex normals by averaging the face normals that it toaches
    for LVertex := 0 to length(Vertices) - 1 do begin
      Vertices[LVertex].Normal := Point3D(0, 0, 0);
    end;
    for LFace := 0 to length(Faces) - 3 do begin // don't include end faces
      for LVertex := 0 to length(Faces[LFace].Corners)-1 do begin
        Vertices[Faces[LFace].Corners[LVertex]].Normal :=
          Add(Vertices[Faces[LFace].Corners[LVertex]].Normal, Faces[LFace].Normal);
      end;
    end;
    for LVertex := 0 to length(Vertices) - 1 do begin
      Vertices[LVertex].Normal := UnitVector(Vertices[LVertex].Normal);
    end;

  except
    ShowMessage('Exception in BuildRotationalVolume Method');
  end;
end;

//Adds a vertice to the model
procedure T3DModel.AddVertice(Point:Tpoint3D;Valor:float);
begin
  SetLength(Vertices,length(Vertices)+1);
  Vertices[length(Vertices)-1].Point:=Point;
  vertices[length(Vertices)-1].value:=Valor;
end;

// build a cube with specified size and face colours
procedure T3DModel.BuildCube(ACubeSize : integer ; FaceColors : array of TColor);
Var                                   
  LVertex, LFace : byte;           //    Face colours assignments
  Lx, Ly, Lz : integer;            //                ___
begin                              //               |5  |
  try                              //        ___ ___|___|___
                                   //       |4  |2  |0  |1  |
    // create cube Vertices        //       |___|___|___|___|
    SetLength(Vertices, 8);        //               |3  |
    LVertex := 0;                  //               |___|
    for Lz := 0 to 1 do begin
      for Ly := 0 to 1 do begin
        for Lx := 0 to 1 do begin
          Vertices[LVertex].Point.X := Lx * ACubeSize;
          Vertices[LVertex].Point.Y := Ly * ACubeSize;
          Vertices[LVertex].Point.Z := Lz * ACubeSize;
          Vertices[LVertex].Normal := Point3D(1, 0, 0); // not used
          Inc(LVertex);
        end;                                  //    Vertex indexes
      end;                                    //      0________1
    end;                                      //      |\      |\
                                              //      | \4____|_\5
    // create cube faces                      //      |  |    |  |
    SetLength(Faces, 6);                      //     2|__|____|3 |
    for LFace := 0 to 5 do begin              //       \ |     \ |
      SetLength(Faces[LFace].Corners, 4);  //        \|______\|
      Faces[LFace].Curved := False;           //         6       7
    end;
    for LFace := 0 to 5 do Faces[LFace].Corners[3] := LFace;
    Faces[0].Corners[2] := 1; Faces[0].Corners[1] := 3; Faces[0].Corners[0] := 2;
    Faces[1].Corners[2] := 5; Faces[1].Corners[1] := 7; Faces[1].Corners[0] := 3;
    Faces[2].Corners[2] := 6; Faces[2].Corners[1] := 4; Faces[2].Corners[0] := 0;
    Faces[3].Corners[2] := 7; Faces[3].Corners[1] := 6; Faces[3].Corners[0] := 2;
    Faces[4].Corners[2] := 6; Faces[4].Corners[1] := 7; Faces[4].Corners[0] := 5;
    Faces[5].Corners[2] := 1; Faces[5].Corners[1] := 0; Faces[5].Corners[0] := 4;
    // calculate face normals
    for LFace := 0 to 5 do begin
      Faces[LFace].Normal := FaceNormal(LFace);
      Faces[LFace].HLS := RGBtoHLS( ColorToRGB(FaceColors[LFace]) );
    end;

  except
    ShowMessage('Exception in BuildCube Method');
  end;
end;

// calculate the normal vector of a face
function T3DModel.FaceNormal(AFace : integer) : TPoint3D;
Var
  LVec1, LVec2 : TPoint3D;
begin
  try
    // find 2 vectors that lie on the plane
    LVec1 := Subtract(Vertices[Faces[AFace].Corners[1]].Point, Vertices[Faces[AFace].Corners[0]].Point);
    LVec2 := Subtract(Vertices[Faces[AFace].Corners[3]].Point, Vertices[Faces[AFace].Corners[0]].Point);

    Result := UnitVector(CrossProduct(LVec1, LVec2));

  except
    result := UnitVector(Point3D(0,0,0));
    //ShowMessage('Exception in FaceNormal Method');
  end;
end;

// translate an object
procedure T3DModel.Translate(AX, AY : integer);
Var
  LDis : TPoint3D;
  LVertex : integer;
begin
  try
    LDis.X := AX - Center.X;
    LDis.Y := AY - Center.Y;

    for LVertex := 0 to length(Vertices) - 1 do begin
      Vertices[LVertex].Point.X := Vertices[LVertex].Point.X + LDis.X;
      Vertices[LVertex].Point.Y := Vertices[LVertex].Point.Y + LDis.Y;
    end;

    Center := Point3D(Center.X + LDis.X, Center.Y + LDis.Y, Center.Z);

  except
    ShowMessage('Exception in Translate Method');
  end;
end;

// rotate an object around a given axis
procedure T3DModel.Rotate(AAngle : extended ; AAxis : TAxis);
Var
  LVertex : integer;
  TempPoint : TPoint3D;
  Lsin, Lcos : extended;
begin
  try
    sincos(AAngle, Lsin, Lcos);

    if AAxis = AxisX then begin
      // rotate about x-axis
      for LVertex := 0 to length(Vertices) - 1 do begin // Vertex Points
        TempPoint.X := Vertices[LVertex].Point.X;
        TempPoint.Y := ((Vertices[LVertex].Point.Y-Center.Y) * Lcos) -
                        ((Vertices[LVertex].Point.Z-Center.Z) * Lsin) + Center.Y;
        TempPoint.Z := ((Vertices[LVertex].Point.Y-Center.Y) * Lsin) +
                        ((Vertices[LVertex].Point.Z-Center.Z) * Lcos) + Center.Z;
        Vertices[LVertex].Point := TempPoint;
      end;
      for LVertex := 0 to length(Faces) - 1 do begin // face normals
        TempPoint.X := Faces[LVertex].Normal.X;
        TempPoint.Y := ((Faces[LVertex].Normal.Y) * Lcos) -
                        ((Faces[LVertex].Normal.Z) * Lsin);
        TempPoint.Z := ((Faces[LVertex].Normal.Y) * Lsin) +
                        ((Faces[LVertex].Normal.Z) * Lcos);
        Faces[LVertex].Normal := TempPoint;
      end;
      for LVertex := 0 to length(Vertices) - 1 do begin // vertex normals
        TempPoint.X := Vertices[LVertex].Normal.X;
        TempPoint.Y := ((Vertices[LVertex].Normal.Y) * Lcos) -
                        ((Vertices[LVertex].Normal.Z) * Lsin);
        TempPoint.Z := ((Vertices[LVertex].Normal.Y) * Lsin) +
                        ((Vertices[LVertex].Normal.Z) * Lcos);
        Vertices[LVertex].Normal := TempPoint;
      end;
    end else if AAxis = AxisY then begin
      // rotate about y-axis
      for LVertex := 0 to length(Vertices) - 1 do begin // Vertex Points
        TempPoint.X := ((Vertices[LVertex].Point.X-Center.X) * Lcos) +
                        ((Vertices[LVertex].Point.Z-Center.Z) * Lsin) + Center.X;
        TempPoint.Y := Vertices[LVertex].Point.Y;
        TempPoint.Z := -((Vertices[LVertex].Point.X-Center.X) * Lsin) +
                         ((Vertices[LVertex].Point.Z-Center.Z) * Lcos) + Center.Z;
        Vertices[LVertex].Point := TempPoint;
      end;
      for LVertex := 0 to length(Faces) - 1 do begin // face normals
        TempPoint.X := ((Faces[LVertex].Normal.X) * Lcos) +
                        ((Faces[LVertex].Normal.Z) * Lsin);
        TempPoint.Y := Faces[LVertex].Normal.Y;
        TempPoint.Z := -((Faces[LVertex].Normal.X) * Lsin) +
                         ((Faces[LVertex].Normal.Z) * Lcos);
        Faces[LVertex].Normal := TempPoint;
      end;
      for LVertex := 0 to length(Vertices) - 1 do begin // vertex normals
        TempPoint.X := ((Vertices[LVertex].Normal.X) * Lcos) +
                        ((Vertices[LVertex].Normal.Z) * Lsin);
        TempPoint.Y := Vertices[LVertex].Normal.Y;
        TempPoint.Z := -((Vertices[LVertex].Normal.X) * Lsin) +
                         ((Vertices[LVertex].Normal.Z) * Lcos);
        Vertices[LVertex].Normal := TempPoint;
      end;
    end else begin
      // rotate about z-axis
      for LVertex := 0 to length(Vertices) - 1 do begin // Vertex Points
        TempPoint.X := ((Vertices[LVertex].Point.X-Center.X) * Lcos) -
                        ((Vertices[LVertex].Point.Y-Center.Y) * Lsin) + Center.X;
        TempPoint.Y := ((Vertices[LVertex].Point.X-Center.X) * Lsin) +
                        ((Vertices[LVertex].Point.Y-Center.Y) * Lcos) + Center.Y;
        TempPoint.Z := Vertices[LVertex].Point.Z;
        Vertices[LVertex].Point := TempPoint;
      end;
      for LVertex := 0 to length(Faces) - 1 do begin // face normals
        TempPoint.X := ((Faces[LVertex].Normal.X) * Lsin) -
                        ((Faces[LVertex].Normal.Y) * Lcos);
        TempPoint.Y := ((Faces[LVertex].Normal.X) * Lcos) +
                        ((Faces[LVertex].Normal.Y) * Lsin);
        TempPoint.Z := Faces[LVertex].Normal.Z;
        Faces[LVertex].Normal := TempPoint;
      end;
      for LVertex := 0 to length(Vertices) - 1 do begin // vertex normals
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
  LFace, LVertex : integer;
  LVisibleVertices : array of integer; // index's of vertices belonging to visible faces
  LIntensityRatio : Extended;
begin
  try
    // backface culling
    SetLength(VisibleFaces, 0);
    for LFace := 0 to length(Faces) - 1 do begin
      // if face normal is pointing towards viewer then it is visible else it is invisible
      if DotProduct(Faces[LFace].Normal, ViewVector) > 0 then begin
        SetLength(VisibleFaces, length(VisibleFaces) + 1);
        VisibleFaces[length(VisibleFaces) - 1] := Faces[LFace];
      end;
    end;

    // calculate Z-coordinate of face centers for Z-buffering
    for LFace := 0 to length(VisibleFaces) - 1 do begin
      VisibleFaces[LFace].CenterZ := (Vertices[VisibleFaces[LFace].Corners[0]].Point.Z +
        Vertices[VisibleFaces[LFace].Corners[length(VisibleFaces[LFace].Corners) div 2]].Point.Z) / 2;
    end;

    // sort faces by Z
    QuicksortFaces(VisibleFaces, 0, length(VisibleFaces)-1);

    // calculate light source direction from center of club
    SourceDirection := UnitVector( Subtract(LightSource, Center) );

    // clear bitmap
    OffScrBmp.Canvas.Brush.Color := clblack;
    OffScrBmp.Canvas.FillRect(ScreenRect);

    // find visible vertices and calculate the luminosity at each of them
    // this means that luminosities will only have to be calculated once for each vertex
    SetLength(LVisibleVertices, 0);
    for LVertex := 0 to length(Vertices) - 1 do Vertices[LVertex].Visible := False;
    for LFace := 0 to length(VisibleFaces) - 1 do begin
      for LVertex := 0 to length(VisibleFaces[LFace].Corners)-1 do begin
        if (VisibleFaces[LFace].Curved) and // vertex luminance doesn't need to be calculated for flat faces
           (not Vertices[VisibleFaces[LFace].Corners[LVertex]].Visible) then begin
          Vertices[VisibleFaces[LFace].Corners[LVertex]].Visible := True;
          SetLength(LVisibleVertices, length(LVisibleVertices) + 1);
          LVisibleVertices[length(LVisibleVertices) - 1] := VisibleFaces[LFace].Corners[LVertex];
        end;
      end;
    end;
    // calculate the luminance of the visible vertices
    for LVertex := 0 to length(LVisibleVertices) - 1 do begin
      LIntensityRatio := DotProduct( Vertices[LVisibleVertices[LVertex]].Normal, SourceDirection );
      Vertices[LVisibleVertices[LVertex]].Lum := 60 + trunc( 130 * max(0,LIntensityRatio) );
    end;

    // draw faces in order of Z so that nearer faces are drawn last
    for LFace := 0 to length(VisibleFaces) - 1 do begin
      if VisibleFaces[LFace].Curved then GouraudFace(LFace)
                                    else FlatFace(LFace);
    end;

  except
    ShowMessage('Exception in RenderObject Method');
  end;
end;

// sort faces by Z for Z-buffering
procedure T3DModel.QuickSortFaces(var A: array of TFace; iLo, iHi: Integer);
Var
  Lo, Hi : Integer;
  Mid : Extended;
  T : TFace;
begin
  try

    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2].CenterZ;
    repeat
      while A[Lo].CenterZ < Mid do Inc(Lo);
      while A[Hi].CenterZ > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSortFaces(A, iLo, Hi);
    if Lo < iHi then QuickSortFaces(A, Lo, iHi);

  except
    ShowMessage('Exception in QuickSortFaces Method');
  end;
end;

// render a face of an object with a given colour
procedure T3DModel.FlatFace(AFace : integer);
Var
  LPolygon : array of TPoint;
  LColor : TColor;
  LIntensityRatio : Extended;
  LVertex : byte;
begin
  try

    SetLength(LPolygon, length(VisibleFaces[AFace].Corners));

    LIntensityRatio := DotProduct(VisibleFaces[AFace].Normal, SourceDirection);

    VisibleFaces[AFace].HLS.L := 60 + trunc( 130 * max(0,LIntensityRatio) );
    //if HLS.L > 255 then HLS.L := 255;

    //LColor := (IHS.I shl 16) + (IHS.I shl 8) + IHS.I; // greyscale
    LColor := RGBToCol( HLStoRGB(VisibleFaces[AFace].HLS) );

    // create polygon array
    for LVertex := 0 to length(LPolygon)-1 do begin
      LPolygon[LVertex].X := round( Vertices[ VisibleFaces[AFace].Corners[LVertex] ].Point.X );
      LPolygon[LVertex].Y := round( Vertices[ VisibleFaces[AFace].Corners[LVertex] ].Point.Y );
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
procedure T3DModel.GouraudFace(AFace : integer);
Var
  LPolygon : TPointColorTriangle;
  LVertex : byte;
  LRGB : TRGBTriple;
begin
  try
    // first half of rectangle
    for LVertex := 0 to 2 do begin
      LPolygon[LVertex-1].X := round( Vertices[ VisibleFaces[AFace].Corners[LVertex] ].Point.X );
      LPolygon[LVertex-1].Y := round( Vertices[ VisibleFaces[AFace].Corners[LVertex] ].Point.Y );

      // set luminosity to the precalculated value for this corner vertex
      VisibleFaces[AFace].HLS.L := Vertices[VisibleFaces[AFace].Corners[LVertex]].Lum;

      LRGB := HLStoRGB( VisibleFaces[AFace].HLS );
      LPolygon[LVertex].RGB.R := LRGB.rgbtRed;
      LPolygon[LVertex].RGB.G := LRGB.rgbtGreen;
      LPolygon[LVertex].RGB.B := LRGB.rgbtBlue;
    end;

    GouraudPoly( OffScrBmp, LPolygon );

    // second half of rectangle - just replace the middle corner
    LPolygon[1].X := round( Vertices[ VisibleFaces[AFace].Corners[3] ].Point.X );
    LPolygon[1].Y := round( Vertices[ VisibleFaces[AFace].Corners[3] ].Point.Y );

    VisibleFaces[AFace].HLS.L := Vertices[VisibleFaces[AFace].Corners[3]].Lum;

    LRGB := HLStoRGB( VisibleFaces[AFace].HLS );
    LPolygon[1].RGB.R := LRGB.rgbtRed;
    LPolygon[1].RGB.G := LRGB.rgbtGreen;
    LPolygon[1].RGB.B := LRGB.rgbtBlue;

    GouraudPoly( OffScrBmp, LPolygon );

//    for LVertex := 1 to 4 do begin // debugging
//      OffScrBmp.Canvas.Pixels[round(Vertices[VisibleFaces[AFace].Corners^[LVertex]].Point.X), round(Vertices[ VisibleFaces[AFace].Corners^[LVertex] ].Point.Y)] := clyellow;
//    end;

  except
    ShowMessage('Exception in GouraudFace Method');
  end;
end;

// fill a traingular polygon using Gouraud shading
procedure T3DModel.GouraudPoly(var ABitmap : TBitmap ; V : TPointColorTriangle);
Var
  LX, RX, Ldx, Rdx : Single;
  Dif1, Dif2 : Single;
  LRGB, RRGB, RGB, RGBdx, LRGBdy, RRGBdy : TRGBFloat;
  RGBT : RGBTriple;                      
  Scan : PRGBTripleArray;
  y, x, Vmax : integer;
  Right : boolean;
  Temp : TPointColor;
begin
try

  // sort vertices by Y
  Vmax := 0;
  if V[1].Y > V[0].Y then Vmax := 1;
  if V[2].Y > V[Vmax].Y then Vmax := 2;
  if Vmax <> 2 then begin
    Temp := V[2];
    V[2] := V[Vmax];                     //           /\
    V[Vmax] := Temp;                     //          /  \ region 1
  end;                                   //         /____\
  if V[1].Y > V[0].Y then Vmax := 1      //        /    /
                     else Vmax := 0;     //       /   / region 2
  if Vmax = 0 then begin                 //      /  /
    Temp := V[1];                        //     / /
    V[1] := V[0];                        //    /
    V[0] := Temp;
  end;

  Dif1 := V[2].Y - V[0].Y;
  if Dif1 = 0 then Dif1 := 0.001; // prevent EZeroDivide
  Dif2 := V[1].Y - V[0].Y;
  if Dif2 = 0 then Dif2 := 0.001;

  { work out if middle point is to the left or right of the line
    connecting upper and lower points }
  if V[1].X > (V[2].X - V[0].X) * Dif2 / Dif1 + V[0].X then Right := True
                                                       else Right := False;

  // calculate increments in x and colour for stepping through the lines
  if Right then begin
    Ldx := (V[2].X - V[0].X) / Dif1;
    Rdx := (V[1].X - V[0].X) / Dif2;
    LRGBdy.B := (V[2].RGB.B - V[0].RGB.B) / Dif1;
    LRGBdy.G := (V[2].RGB.G - V[0].RGB.G) / Dif1;
    LRGBdy.R := (V[2].RGB.R - V[0].RGB.R) / Dif1;
    RRGBdy.B := (V[1].RGB.B - V[0].RGB.B) / Dif2;
    RRGBdy.G := (V[1].RGB.G - V[0].RGB.G) / Dif2;
    RRGBdy.R := (V[1].RGB.R - V[0].RGB.R) / Dif2;
  end else begin
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

  LX := V[0].X;
  RX := V[0].X;

  // fill region 1
  for y := V[0].Y to V[1].Y do begin

    // y clipping
    if y > ABitmap.Height - 1 then Break;
    if y < 0 then begin
      LX := LX + Ldx;
      RX := RX + Rdx;
      LRGB.B := LRGB.B + LRGBdy.B;
      LRGB.G := LRGB.G + LRGBdy.G;
      LRGB.R := LRGB.R + LRGBdy.R;
      RRGB.B := RRGB.B + RRGBdy.B;
      RRGB.G := RRGB.G + RRGBdy.G;
      RRGB.R := RRGB.R + RRGBdy.R;
      Continue;
    end;

    Scan := ABitmap.ScanLine[y];

    // calculate increments in color for stepping through pixels
    Dif1 := RX - LX + 1;
    if Dif1 = 0 then Dif1 := 0.001;
    RGBdx.B := (RRGB.B - LRGB.B) / Dif1;
    RGBdx.G := (RRGB.G - LRGB.G) / Dif1;
    RGBdx.R := (RRGB.R - LRGB.R) / Dif1;

    // x clipping
    if LX < 0 then begin
      RGB.B := LRGB.B + (RGBdx.B * abs(LX));
      RGB.G := LRGB.G + (RGBdx.G * abs(LX));
      RGB.R := LRGB.R + (RGBdx.R * abs(LX));
    end else RGB := LRGB;

    // scan the line
    for x := max(round(LX), 0) to min(round(RX), ABitmap.Width - 1) do begin
      RGBT.rgbtBlue := trunc(RGB.B);
      RGBT.rgbtGreen := trunc(RGB.G);
      RGBT.rgbtRed := trunc(RGB.R);
      Scan[x] := RGBT;
      RGB.B := RGB.B + RGBdx.B;
      RGB.G := RGB.G + RGBdx.G;
      RGB.R := RGB.R + RGBdx.R;
    end;
    // increment edge x positions
    LX := LX + Ldx;
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
  if Dif1 = 0 then Dif1 := 0.001;
  // calculate new increments for region 2
  if Right then begin
    Rdx := (V[2].X - V[1].X) / Dif1;
    RX := V[1].X;
    RRGBdy.B := (V[2].RGB.B - V[1].RGB.B) / Dif1;
    RRGBdy.G := (V[2].RGB.G - V[1].RGB.G) / Dif1;
    RRGBdy.R := (V[2].RGB.R - V[1].RGB.R) / Dif1;
    RRGB := V[1].RGB;
  end else begin
    Ldx := (V[2].X - V[1].X) / Dif1;
    LX := V[1].X;
    LRGBdy.B := (V[2].RGB.B - V[1].RGB.B) / Dif1;
    LRGBdy.G := (V[2].RGB.G - V[1].RGB.G) / Dif1;
    LRGBdy.R := (V[2].RGB.R - V[1].RGB.R) / Dif1;
    LRGB := V[1].RGB;
  end;

  // fill region 2
  for y := V[1].Y + 1 to V[2].Y do begin

    // y clipping
    if y > ABitmap.Height - 1 then Break;
    if y < 0 then begin
      LX := LX + Ldx;
      RX := RX + Rdx;
      LRGB.B := LRGB.B + LRGBdy.B;
      LRGB.G := LRGB.G + LRGBdy.G;
      LRGB.R := LRGB.R + LRGBdy.R;
      RRGB.B := RRGB.B + RRGBdy.B;
      RRGB.G := RRGB.G + RRGBdy.G;
      RRGB.R := RRGB.R + RRGBdy.R;
      Continue;
    end;

    Scan := ABitmap.ScanLine[y];

    Dif1 := RX - LX + 1;
    if Dif1 = 0 then Dif1 := 0.001;
    RGBdx.B := (RRGB.B - LRGB.B) / Dif1;
    RGBdx.G := (RRGB.G - LRGB.G) / Dif1;
    RGBdx.R := (RRGB.R - LRGB.R) / Dif1;

    // x clipping
    if LX < 0 then begin
      // calculate starting colour from x=0
      RGB.B := LRGB.B + (RGBdx.B * abs(LX));
      RGB.G := LRGB.G + (RGBdx.G * abs(LX));
      RGB.R := LRGB.R + (RGBdx.R * abs(LX));
    end else RGB := LRGB;

    // scan the line
    for x := max(round(LX), 0) to min(round(RX), ABitmap.Width - 1) do begin
      RGBT.rgbtBlue := trunc(RGB.B);
      RGBT.rgbtGreen := trunc(RGB.G);
      RGBT.rgbtRed := trunc(RGB.R);
      Scan[x] := RGBT;
      RGB.B := RGB.B + RGBdx.B;
      RGB.G := RGB.G + RGBdx.G;
      RGB.R := RGB.R + RGBdx.R;
    end;

    LX := LX + Ldx;
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
function T3DModel.CrossProduct(AVector1, AVector2 : TPoint3D) : TPoint3D;
begin
  try

    Result.X := ((AVector1.Y * AVector2.Z) - (AVector1.Z * AVector2.Y));
    Result.Y := ((AVector1.Z * AVector2.X) - (AVector1.X * AVector2.Z));
    Result.Z := ((AVector1.X * AVector2.Y) - (AVector1.Y * AVector2.X));

  except
    ShowMessage('Exception in CrossProduct Method');
  end;
end;

// calculates the dot product of 2 vectors
function T3DModel.DotProduct(AVector1, AVector2 : TPoint3D) : Extended;
begin
  Result := (AVector1.X * AVector2.X) +
            (AVector1.Y * AVector2.Y) +
            (AVector1.Z * AVector2.Z);
end;

// reduces a vector to a unit vector
function T3DModel.UnitVector(AVector : TPoint3D) : TPoint3D;
Var
  Modulus : Extended;
begin
  try

    Modulus := Sqrt(Sqr(AVector.X)+Sqr(AVector.Y)+Sqr(AVector.Z));
    Result := Point3D(AVector.X/Modulus, AVector.Y/Modulus, AVector.Z/Modulus);

  except
    result:= Point3D(0,0,0);
    //ShowMessage('Exception in UnitVector Method');
  end;
end;

// add two vectors together
function T3DModel.Add(AVec1, AVec2 : TPoint3D) : TPoint3D;
begin
  try

    Result := Point3D(AVec1.X + AVec2.X, AVec1.Y + AVec2.Y, AVec1.Z + AVec2.Z);

  except
    result:=Point3D(0,0,0);
    //ShowMessage('Exception in Add Method');
  end;
end;

// subtract one vector from another
function T3DModel.Subtract(AVec1, AVec2 : TPoint3D) : TPoint3D;
begin
  try

    Result := Point3D(AVec1.X - AVec2.X, AVec1.Y - AVec2.Y, AVec1.Z - AVec2.Z);

  except
    result:=Point3D(0,0,0);
    //ShowMessage('Exception in Subtract Method');
  end;
end;



procedure T3DModel.ProcessVertices;
Var
  p1,p2,p3,p4:integer;
  LFace, LVertex : integer;
begin
    SetLength(Faces,length(Vertices)-2);
    for LFace := 0 to length(Faces)-1 do begin
      // create a new face by indexing Vertices
        SearchNearestPoints(Lface+1,P2,P3,P4);
        SetLength(Faces[LFace].Corners, 4);
          Faces[LFace].Corners[0] := P2;
          Faces[LFace].Corners[1] := P3;
          Faces[LFace].Corners[2] := P4;
          Faces[LFace].Corners[3] := lface;

          Faces[LFace].Curved := True;

    end;

    // calculate face normals
    for LFace := 0 to length(Faces) - 1 do begin
      Faces[LFace].Normal := FaceNormal(LFace);
    end;

    // calculate vertex normals by averaging the face normals that it toaches
    for LVertex := 0 to length(Vertices) - 1 do begin
      Vertices[LVertex].Normal := Point3D(0, 0, 0);
    end;
    for LFace := 0 to length(Faces) - 1 do begin
      for LVertex := 1 to length(Faces[LFace].Corners)-1 do begin
        Vertices[Faces[LFace].Corners[LVertex]].Normal :=
          Add(Vertices[Faces[LFace].Corners[LVertex]].Normal, Faces[LFace].Normal);
      end;
    end;
    for LVertex := 0 to length(Vertices) - 1 do begin
      Vertices[LVertex].Normal := UnitVector(Vertices[LVertex].Normal);
    end;
    CleanZeroVertices;
end;

procedure T3DModel.SearchNearestPoints(Point: integer; out P1,P2,P3:integer);
var i:integer;d1,d2,d3,dist:float;
begin
  d1:=MaxNum;d2:=d1;d3:=d2;
  for i:=0 to length(Vertices) - 1 do begin
      dist:=Distance(Vertices[Point].Point,Vertices[i].Point);
      if not (dist=0) then
      if dist<=d1 then begin
         d3:=d2;p3:=p2;
         d2:=d1;p2:=p1;
         d1:=dist;p1:=i;
      end else if dist<=d2 then begin
         d3:=d2;p3:=p2;
         d2:=dist;p2:=i;
      end else if dist<d3 then begin
         d3:=dist;p3:=i;
      end;
  end;
end;

procedure T3DModel.ColorToFaces(min,max:float;r, g, b: array of byte);
  var i:integer;p:tagRGBTRIPLE;value:integer;
begin
for i := 0 to length(Faces) - 1 do begin
  value:=round(LinealInterpolation(min,0,max,255,vertices[i+1].value));
  p.rgbtRed:=r[value];
  p.rgbtGreen:=g[value];
  p.rgbtBlue:=b[value];
  // face colours
        Faces[i].HLS := RGBtoHLS(p);
end;
end;

procedure T3DModel.CleanZeroVertices;
var i,cont,old:integer;lvertexs:array of TVertex;
begin
  cont:=0;old:=length(Vertices);
  for i:=0 to old-1 do begin
      if (VectorModule(Vertices[i].Normal)<>0) then begin
         inc(cont);
         SetLength(lvertexs,cont);
         lvertexs[cont-1]:=Vertices[i];
      end;
  end;
  if cont<old then begin
    SetLength(Vertices,cont);
    for i:=0 to cont-1 do vertices[i]:=lvertexs[i];
    ProcessVertices;
  end;
end;

procedure T3DModel.limpiate;
begin
  SetLength(Vertices,0);SetLength(Faces,0);SetLength(VisibleFaces,0);
end;