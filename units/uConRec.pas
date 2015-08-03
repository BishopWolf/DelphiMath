unit uConRec;

(*
  * ******************************************************************************
  *                                                                              *
  * Author    :  Alex Vergara Gil                                                *
  * Version   :  0.1                                                             *
  * Date      :  26 February 2013                                                *
  * Website   :  http://www.cphr.edu.cu                                          *
  * Copyright :  Alex Vergara Gil 2013                                           *
  *                                                                              *
  * Contouring subroutine that returns vector polygons                           *
  *                                                                              *
  ****************************************************************************** *)

interface

uses
  SysUtils, Types, Classes, uconstants, Math, ubasegeometry, ugraphics, utypes;

function ConRec(D: TMatrix; Lb1, Ub1, Lb2, Ub2: integer; Z, Level: float;
  smooth: boolean = false): TLayer; overload;
function ConRec(D: T3DMatrix; Lb1, Ub1, Lb2, Ub2: integer; Z, Level: float;
  smooth: boolean = false): TLayer; overload;

implementation

uses umath, ufilters, uoperations;

function ConRec(D: TMatrix; Lb1, Ub1, Lb2, Ub2: integer; Z, Level: float;
  smooth: boolean): TLayer;
type
  TVectorL4D = Array [0 .. 4] of Double;
  TVectorL4I = Array [0 .. 4] of integer;

  // ------------------------------------------------------------------------------
Const
  im: Array [0 .. 3] of byte = (0, 1, 1, 0); // coord. cast array west - east
  jm: Array [0 .. 3] of byte = (0, 0, 1, 1); // coord. cast array north - south
  casttab: Array [0 .. 2, 0 .. 2, 0 .. 2] of byte =
    (((0, 0, 8), (0, 2, 5), (7, 6, 9)), ((0, 3, 4), (1, 3, 1), (4, 3, 0)),
    ((9, 6, 7), (5, 2, 0), (8, 0, 0)));
  // ------------------------------------------------------------------------------
Var
  m1, m2, m3, deside: integer;
  dmin, dmax: float;
  x1, x2: TFloatPoint;
  lcnt, i, j, k, m: integer;
  h: TVectorL4D;
  sh: TVectorL4I;
  xh, yh: TVectorL4D;
  temp1, temp2: float;
  r: byte;
  res: TLayer;
  SmoothM: TMatrix;
  // ------- service xsec west east lin. interpol -------------------------------
  Function xsec(p1, p2: integer): float;
  Begin
    result := divide(h[p2] * xh[p1] - h[p1] * xh[p2], h[p2] - h[p1]);
  End;

// ------- service ysec north south lin interpol -------------------------------
  Function ysec(p1, p2: integer): float;
  Begin
    result := divide(h[p2] * yh[p1] - h[p1] * yh[p2], h[p2] - h[p1]);
  End;

begin
  // set line counter
  lcnt := 0;
  res := TLayer.Create(Z);
  if smooth then
    SmoothM := LocalMean(D, Lb1, Ub1, Lb2, Ub2, 2)
  else
    SmoothM := Clone(D, Ub1, Ub2);
  // -----------------------------------------------------------------------------
  For j := Ub2 - 1 DownTo Lb2 Do
  Begin // over all north - south and              +For j
    For i := Lb1 To Ub1 - 1 Do
    Begin // east - west coordinates of datafield    +For i
      // set casting bounds from array
      temp1 := min(SmoothM[i, j], SmoothM[i, j + 1]);
      temp2 := min(SmoothM[i + 1, j], SmoothM[i + 1, j + 1]);
      dmin := min(temp1, temp2);
      temp1 := max(SmoothM[i, j], SmoothM[i, j + 1]);
      temp2 := max(SmoothM[i + 1, j], SmoothM[i + 1, j + 1]);
      dmax := max(temp1, temp2);
      If (dmax >= Level) And (dmin <= Level) Then
      Begin // ask horzintal cut avail.    +If dmin && dmax in z[0] .. z[nc-1]
        If (Level > dmin) And (Level <= dmax) Then
        Begin // aks for cut intervall ----- +If z[k] in dmin .. dmax
          // -----------------------------------------------------------------------
          For m := 4 Downto 1 Do
          Begin // deteriening the cut casts and set the ---- +For m
            // height and coordinate vectors
            h[m] := SmoothM[i + im[m - 1], j + jm[m - 1]] - Level;
            xh[m] := i + im[m - 1];
            yh[m] := j + jm[m - 1];
            If h[m] > 0 Then
              sh[m] := 1
            Else If h[m] < 0 Then
              sh[m] := -1
            Else
              sh[m] := 0;
          End;
          h[0] := (h[1] + h[2] + h[3] + h[4]) / 4;
          xh[0] := (i + i + 1) / 2;
          yh[0] := (j + j + 1) / 2;
          If h[0] > 0 Then
            sh[0] := 1
          Else If h[0] < 0 Then
            sh[0] := -1
          Else
            sh[0] := 0;
          // ----------------------------------------------------------------- -For m

          // -----------------------------------------------------------------------
          For m := 1 to 4 Do
          Begin // set directional casttable
            //
            // Note: at this stage the relative heights of the corners and the
            // centre are in the h array, and the corresponding coordinates are
            // in the xh and yh arrays. The centre of the box is indexed by 0
            // and the 4 corners by 1 to 4 as shown below.
            // Each triangle is then indexed by the parameter m, and the 3
            // vertices of each triangle are indexed by parameters m1,m2,and
            // m3.
            // It is assumed that the centre of the box is always vertex 2
            // though this isimportant only when all 3 vertices lie exactly on
            // the same contour level, in which case only the side of the box
            // is drawn.
            //
            // AS ANY BODY NOWS IST FROM THE ORIGINAL
            //
            // vertex 4 +-------------------+ vertex 3
            // |        | \               / |
            // |        |   \    m=3    /   |
            // |        |     \       /     |
            // |        |       \   /       |
            // |        |  m=2    X   m=2   |       the centre is vertex 0
            // |        |       /   \       |
            // |        |     /       \     |
            // |        |   /    m=1    \   |
            // |        | /               \ |
            // vertex 1 +-------------------+ vertex 2
            //
            //
            //
            // Scan each triangle in the box
            //
            m1 := m;
            m2 := 0;
            If NOT(m = 4) Then
              m3 := m + 1
            Else
              m3 := 1;
            deside := casttab[sh[m1] + 1, sh[m2] + 1, sh[m3] + 1];
            If NOT(deside = 0) Then
            Begin // ask is there a desition available -------- +If If NOT(deside=0)
              Case deside Of
                // ------- determin the by desided cast cuts ------------ +Case deside;
                1:
                  Begin
                    x1 := FloatPoint(xh[m1], yh[m1]);
                    x2 := FloatPoint(xh[m2], yh[m2]);
                  End;
                2:
                  Begin
                    x1 := FloatPoint(xh[m2], yh[m2]);
                    x2 := FloatPoint(xh[m3], yh[m3]);
                  End;
                3:
                  Begin
                    x1 := FloatPoint(xh[m3], yh[m3]);
                    x2 := FloatPoint(xh[m1], yh[m1]);
                  End;
                4:
                  Begin
                    x1 := FloatPoint(xh[m1], yh[m1]);
                    x2 := FloatPoint(xsec(m2, m3), ysec(m2, m3));
                  End;
                5:
                  Begin
                    x1 := FloatPoint(xh[m2], yh[m2]);
                    x2 := FloatPoint(xsec(m3, m1), ysec(m3, m1));
                  End;
                6:
                  Begin
                    x1 := FloatPoint(xh[m3], yh[m3]);
                    x2 := FloatPoint(xsec(m1, m2), ysec(m1, m2));
                  End;
                7:
                  Begin
                    x1 := FloatPoint(xsec(m1, m2), ysec(m1, m2));
                    x2 := FloatPoint(xsec(m2, m3), ysec(m2, m3));
                  End;
                8:
                  Begin
                    x1 := FloatPoint(xsec(m2, m3), ysec(m2, m3));
                    x2 := FloatPoint(xsec(m3, m1), ysec(m3, m1));
                  End;
                9:
                  Begin
                    x1 := FloatPoint(xsec(m3, m1), ysec(m3, m1));
                    x2 := FloatPoint(xsec(m1, m2), ysec(m1, m2));
                  End;
              End; // ---------------------------------------------------------------  -Case deside;

              // ----------add the segment to res, it handles how ----------------------------
              res.AddSegment(x1, x2);
              // -------------------------------------------------------------------
            End; // ----------------------------------------------------------  -If Not(deside=0)
          End; // ---------------------------------------------------------  -For m
        End; // --------------------------------------------------------  -If z[k] in dmin .. dmax
      End; // -------------------------------------------------------  -If dmin && dmax in z[0] .. z[nc-1]
    End; // ------------------------------------------------------  -For i
  End; // -----------------------------------------------------  -For j
  DelMatrix(SmoothM);
  res.Simplify;
  res.MinMax;
  result := res;
end;

function ConRec(D: T3DMatrix; Lb1, Ub1, Lb2, Ub2: integer; Z, Level: float;
  smooth: boolean): TLayer;
Var
  tempM: TMatrix;
  i, j, tz: integer;
begin
  DimMatrix(tempM, Ub1, Ub2);
  tz := round(Z);
  for i := 1 to Ub1 do
    for j := 1 to Ub2 do
      tempM[i, j] := D[i, j, tz];
  result := ConRec(tempM, Lb1, Ub1, Lb2, Ub2, Z, Level, smooth);
  DelMatrix(tempM);
end;

end.
