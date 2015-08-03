unit ufusion;
{ ******************************************************************
  Unit for image fusion
  Performs the fusion using the
  Fast discrete biorthogonal CDF 9/7 wavelet
  forward and inverse transform (lifting implementation)
  it can also perform the fusion by fft, sinft and cosft
  2011 - Alex Vergara Gil - alex@cphr.edu.cu
  ****************************************************************** }

interface

uses
  utypes, graphics, Dialogs;

{ ------------------------------------------------------------------
  Image Fusion
  ------------------------------------------------------------------ }
type
  TFusionType = (TFTsum, TFTmultiply, TFTrest, TFTmean, TFTMax);
  TFusionProc = (TFPfwt97, TFPfft, TFPdct, TFPdst);

function fusiona(vec1, vec2: TVector; Ub: integer; FusionType: TFusionType;
  FusionProc: TFusionProc): TVector;
function ImageFusion(Im1, Im2: TMatrix; Ub1, Ub2: integer;
  FusionType: TFusionType = TFTmean; FusionProc: TFusionProc = TFPfwt97)
  : TMatrix; overload;
function ImageFusion(Im1, Im2: TBitmap; FusionType: TFusionType = TFTmean;
  FusionProc: TFusionProc = TFPfwt97): TBitmap; overload;

implementation

uses uoperations, utypecasts, uinterpolation, uminmax, windows, ufwt97, ufft,
  uround, math, uConstants;

function fusiona(vec1, vec2: TVector; Ub: integer; FusionType: TFusionType;
  FusionProc: TFusionProc): TVector;
var
  i, j, n, no2: integer;
  tv1, tv2, res: TVector;
begin
  // It must be converted into a n=2^j lenght vector, filled with 0
  { ldub:=ln(Ub) * InvLn2;  //base 2 logarithm
    j:=ceil(ldUb);     //next integer exponent
    n:=round(exp(j*ln2)); //integer power of two }
  // n := round(exp(ceil(ln(Ub) * InvLn2) * ln2)); // All in one line
  n := $1;
  for i := 0 to MaxPower do // faster!!!
  begin
    n := n shl $1;
    if (Ub <= n) then
      break;
  end;
  DimVector(tv1, n);
  DimVector(tv2, n);
  for j := 1 to Ub do
  begin
    tv1[j] := vec1[j];
    tv2[j] := vec2[j];
  end;
  // get the transforms
  case FusionProc of
    TFPfwt97:
      begin
        fwt97two(tv1, tv2, n);
      end;
    TFPfft:
      begin
        RealFT(tv1, n, 1);
        RealFT(tv2, n, 1);
      end;
    TFPdct:
      begin
        cosft2(tv1, n, 1);
        cosft2(tv2, n, 1);
      end;
    TFPdst:
      begin
        sinft(tv1, n);
        sinft(tv2, n);
      end;
  end;
  no2 := n shr 1;
  // fusion
  DimVector(res, n);
  case FusionType of
    TFTsum:
      begin
        for j := 1 to Ub do
          res[j] := tv1[j] + tv2[j];
      end;
    TFTmultiply:
      begin
        for j := 1 to Ub do
          if tv2[j] = 0 then
            res[j] := tv1[j]
          else
            res[j] := tv1[j] * tv2[j] / no2;
      end;
    TFTrest:
      begin
        for j := 1 to Ub do
          res[j] := tv1[j] - tv2[j];
      end;
    TFTmean:
      begin
        for j := 1 to Ub do
          res[j] := (tv1[j] + tv2[j]) / 2;
      end;
    TFTMax:
      begin
        for j := 1 to Ub do
        begin
          res[j] := Max(abs(tv1[j]), abs(tv2[j]));
        end;
      end;
  end;
  DelVector(tv1);
  DelVector(tv2);
  // inverse transform
  case FusionProc of
    TFPfwt97:
      begin
        iwt97(res, n);
      end;
    TFPfft:
      begin
        RealFT(res, n, -1);
        for j := 1 to n do
          res[j] := res[j] / no2;
      end;
    TFPdct:
      begin
        cosft2(res, n, -1);
        res[1] := vec1[1];
      end;
    TFPdst:
      begin
        sinft(res, n);
        for j := 1 to n do
          res[j] := res[j] / no2;
      end;
  end;
  Result := res;
  // there is not need for n because
  // only the first Ub values of res are valid
end;

function ImageFusion(Im1, Im2: TMatrix; Ub1, Ub2: integer;
  FusionType: TFusionType; FusionProc: TFusionProc): TMatrix;
var
  res: TVector;
  i, j: integer;
begin
  // Initialization
  DimMatrix(Result, Ub1, Ub2);

  for i := 1 to Ub1 do
  begin
    // Get one column of each image
    // vec1:=Im1[i];vec2:=Im2[i];
    // fusion
    res := fusiona(Im1[i], Im2[i], Ub2, FusionType, FusionProc);
    // res[1]:=vec1[1];
    // write one result column
    for j := 1 to Ub2 do
      Result[i, j] := res[j];
    // free allocated memory
    DelVector(res);
  end;
end;

function ImageFusion(Im1, Im2: graphics.TBitmap; FusionType: TFusionType;
  FusionProc: TFusionProc): graphics.TBitmap;
var
  vec1R, vec1G, vec1B, vec2R, vec2G, vec2B, resR, resG, resB: TVector;
  i, i1, i2, j, j1, j2, Ub1, Ub2, temp: integer;
  v1, v2, r: pRGBTripleArray;
  resBMP: graphics.TBitmap;
begin
  // Initialization
  Ub2 := Max(Im1.Height, Im2.Height);
  Ub1 := Max(Im1.Width, Im2.Width);
  resBMP := graphics.TBitmap.Create;
  resBMP.Width := Ub1;
  resBMP.Height := Ub2;
  resBMP.PixelFormat := Im1.PixelFormat;
  DimVector(vec1R, Ub1);
  DimVector(vec2R, Ub1);
  DimVector(vec1G, Ub1);
  DimVector(vec2G, Ub1);
  DimVector(vec1B, Ub1);
  DimVector(vec2B, Ub1);
  for j := 0 to Ub2 - 1 do
  begin
    j1 := round(LinealInterpolation(0, 0, Ub2 - 1, Im1.Height - 1, j));
    j2 := round(LinealInterpolation(0, 0, Ub2 - 1, Im2.Height - 1, j));
    v1 := Im1.ScanLine[j1];
    v2 := Im2.ScanLine[j2];
    for i := 0 to Ub1 - 1 do
    begin
      i1 := round(LinealInterpolation(0, 0, Ub1 - 1, Im1.Width - 1, i));
      vec1R[i + 1] := v1[i1].rgbtRed;
      vec1G[i + 1] := v1[i1].rgbtGreen;
      vec1B[i + 1] := v1[i1].rgbtBlue;
      i2 := round(LinealInterpolation(0, 0, Ub1 - 1, Im2.Width - 1, i));
      vec2R[i + 1] := v2[i2].rgbtRed;
      vec2G[i + 1] := v2[i2].rgbtGreen;
      vec2B[i + 1] := v2[i2].rgbtBlue;
    end;
    // fusion
    resR := fusiona(vec1R, vec2R, Ub1, FusionType, FusionProc); // red
    resG := fusiona(vec1G, vec2G, Ub1, FusionType, FusionProc); // green
    resB := fusiona(vec1B, vec2B, Ub1, FusionType, FusionProc); // blue
    r := resBMP.ScanLine[j];
    for i := 0 to Ub1 - 1 do
    begin
      r[i].rgbtRed := EnsureRangeI(round(resR[i + 1]), 0, 255);
      r[i].rgbtGreen := EnsureRangeI(round(resG[i + 1]), 0, 255);
      r[i].rgbtBlue := EnsureRangeI(round(resB[i + 1]), 0, 255);
    end;
    DelVector(resR);
    DelVector(resG);
    DelVector(resB);
  end;
  Result := resBMP;
  DelVector(vec1R);
  DelVector(vec2R);
  DelVector(vec1G);
  DelVector(vec2G);
  DelVector(vec1B);
  DelVector(vec2B);
end;

end.
