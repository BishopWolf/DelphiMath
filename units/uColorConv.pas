unit uColorConv;

interface

uses Graphics, Windows, umodel3d;

function ColorToRGB(PColor: TColor): TRGBTriple;
function RGBToColor(PR, PG, PB: Integer): TColor;
function RGBToCol(PRGB: TRGBTriple): TColor;
function RGBToHLS(PRGB: TRGBTriple): THLS;
function HLSToRGB(PHLS: THLS): TRGBTriple;
function int2rainbow(I, min, max: Integer): TColor;

implementation

uses uminmax, uinterpolation, uConstants;

function RGBToColor(PR, PG, PB: Integer): TColor;
begin
  Result := TColor((PB * 65536) + (PG * 256) + PR);
end;

function ColorToRGB(PColor: TColor): TRGBTriple;
var
  I: Integer;
begin
  I := PColor;
  Result.rgbtRed := 0;
  Result.rgbtGreen := 0;
  Result.rgbtBlue := 0;
  while I - 65536 >= 0 do
  begin
    I := I - 65536;
    Result.rgbtBlue := Result.rgbtBlue + 1;
  end;
  while I - 256 >= 0 do
  begin
    I := I - 256;
    Result.rgbtGreen := Result.rgbtGreen + 1;
  end;
  Result.rgbtRed := I;
end;

function RGBToCol(PRGB: TRGBTriple): TColor;
begin
  Result := RGBToColor(PRGB.rgbtRed, PRGB.rgbtGreen, PRGB.rgbtBlue);
end;

function RGBToHLS(PRGB: TRGBTriple): THLS;
var
  LR, LG, LB, LH, LL, LS, LMin, LMax: float;
begin
  LR := PRGB.rgbtRed / 256;
  LG := PRGB.rgbtGreen / 256;
  LB := PRGB.rgbtBlue / 256;
  LMin := min3(LR, LG, LB);
  LMax := max3(LR, LG, LB);
  LL := (LMax + LMin) / 2;
  if LMin = LMax then
  begin
    LH := 0;
    LS := 0;
    Result.H := round(LH * 256);
    Result.L := round(LL * 256);
    Result.S := round(LS * 256);
    exit;
  end;
  If LL < 0.5 then
    LS := (LMax - LMin) / (LMax + LMin)
  else
    LS := (LMax - LMin) / (2.0 - LMax - LMin);
  If LR = LMax then
    LH := (LG - LB) / (LMax - LMin)
  else If LG = LMax then
    LH := 2.0 + (LB - LR) / (LMax - LMin)
  else
    LH := 4.0 + (LR - LG) / (LMax - LMin);
  Result.H := round(LH * 42.6);
  Result.L := round(LL * 256);
  Result.S := round(LS * 256);
end;

function HLSToRGB(PHLS: THLS): TRGBTriple;
var
  LR, LG, LB, LH, LL, LS: float;
  L1, L2: float;
begin
  LH := PHLS.H / 255;
  LL := PHLS.L / 255;
  LS := PHLS.S / 255;
  if LS = 0 then
  begin
    Result.rgbtRed := PHLS.L;
    Result.rgbtGreen := PHLS.L;
    Result.rgbtBlue := PHLS.L;
    exit;
  end;
  If LL < 0.5 then
    L2 := LL * (1.0 + LS)
  else
    L2 := LL + LS - LL * LS;
  L1 := 2.0 * LL - L2;
  LR := LH + 1.0 / 3.0;
  if LR < 0 then
    LR := LR + 1.0;
  if LR > 1 then
    LR := LR - 1.0;
  If 6.0 * LR < 1 then
    LR := L1 + (L2 - L1) * 6.0 * LR
  Else if 2.0 * LR < 1 then
    LR := L2
  Else if 3.0 * LR < 2 then
    LR := L1 + (L2 - L1) * ((2.0 / 3.0) - LR) * 6.0
  Else
    LR := L1;
  LG := LH;
  if LG < 0 then
    LG := LG + 1.0;
  if LG > 1 then
    LG := LG - 1.0;
  If 6.0 * LG < 1 then
    LG := L1 + (L2 - L1) * 6.0 * LG
  Else if 2.0 * LG < 1 then
    LG := L2
  Else if 3.0 * LG < 2 then
    LG := L1 + (L2 - L1) * ((2.0 / 3.0) - LG) * 6.0
  Else
    LG := L1;
  LB := LH - 1.0 / 3.0;
  if LB < 0 then
    LB := LB + 1.0;
  if LB > 1 then
    LB := LB - 1.0;
  If 6.0 * LB < 1 then
    LB := L1 + (L2 - L1) * 6.0 * LB
  Else if 2.0 * LB < 1 then
    LB := L2
  Else if 3.0 * LB < 2 then
    LB := L1 + (L2 - L1) * ((2.0 / 3.0) - LB) * 6.0
  Else
    LB := L1;
  Result.rgbtRed := round(LR * 255);
  Result.rgbtGreen := round(LG * 255);
  Result.rgbtBlue := round(LB * 255);
end;

function int2rainbow(I, min, max: Integer): TColor;
var
  med: Integer;
begin
  Assert(min <= max);
  med := (max + min) shr 1;
  if I = med then
  begin
    Result := RGBToColor(0, 255, 0);
    exit;
  end;
  if (I <= min) then
  begin
    Result := RGBToColor(0, 0, 255);
    exit;
  end;
  if (I >= max) then
  begin
    Result := RGBToColor(255, 0, 0);
    exit;
  end;
  if I < med then
  begin
    Result := RGBToColor(0, (255 * (I - min)) div (med - min),
      255 - ((255 * (I - min)) div (med - min)));
  end
  else
  begin
    Result := RGBToColor((255 * (I - med)) div (max - med),
      255 - ((255 * (I - med)) div (max - med)), 0);
    exit;
  end;
end;

end.
