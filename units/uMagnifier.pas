Unit uMagnifier;

Interface

Uses windows, classes, graphics, extctrls, utypes, uConstants;

Type

  TMagnifier = Class
  Private
    MagRect        : TRect;
    FMagnifierRatio: integer;
    FBackupBitmap  : TBitmap;
    FImage         : TImage;
  Public
    Constructor Create(Image: TImage; MagnifierRatio: integer = 2);
    Destructor Destroy; Override;
    Property MagnifierRatio: integer Read FMagnifierRatio;
    Property BackupBitmap: TBitmap Read FBackupBitmap;
    Procedure ShowMagnifierBox(CONST X, Y: integer);
    Procedure ShowMagnifierRound(CONST X, Y: integer);
  End;

implementation

{ TMagnifier }

Constructor TMagnifier.Create(Image: TImage; MagnifierRatio: integer);
Begin
  FBackupBitmap := TBitmap.Create;
  FBackupBitmap.Assign(Image.Picture.Graphic);
  FImage := Image;
  MagRect := Rect(0, 0, 0, 0);
  FMagnifierRatio := MagnifierRatio;
End;

Destructor TMagnifier.Destroy;
Begin
  If FBackupBitmap <> Nil Then
  Begin
    If FImage <> Nil Then
      FImage.Picture.Graphic := FBackupBitmap;
    FBackupBitmap.Free;
    FBackupBitmap := Nil;
  End;
End;

Procedure TMagnifier.ShowMagnifierBox(Const X, Y: integer);
VAR
  AreaRadius                  : integer;
  Magnification               : integer;
  xActual, yActual, magX, magY: integer;
  ratio                       : float;
Const
  mag = 50; // number of pixels taken
BEGIN
  If BackupBitmap = Nil Then
    exit;
  xActual := round((X * FImage.Picture.Height) / FImage.Height);
  yActual := round((Y * FImage.Picture.Width) / FImage.Width);
  ratio := FImage.Picture.Height / FImage.Picture.Width; // Y/X
  If (xActual < 0) Or (yActual < 0) Or (xActual > FImage.Picture.Width) Or
    (yActual > FImage.Picture.Height) Then
    exit;
  AreaRadius := mag;
  Magnification := (FImage.Picture.Height + FImage.Picture.Width) *
    MagnifierRatio Div 8;
  magX := round(Magnification / (1 + ratio));
  magY := Magnification - magX;
  If (MagRect.Left <> MagRect.Right) Then
  Begin
    FImage.Picture.Bitmap.Canvas.CopyRect(MagRect,
      FBackupBitmap.Canvas, MagRect);
  End;
  MagRect := Rect(xActual - magX, yActual - magY, xActual + magX,
    yActual + magY);
  FImage.Picture.Bitmap.Canvas.CopyRect(MagRect, FBackupBitmap.Canvas,
    Rect(xActual - AreaRadius, yActual - AreaRadius, xActual + AreaRadius,
    yActual + AreaRadius));
  //FImage.refresh; // non visible effects
END;

Procedure TMagnifier.ShowMagnifierRound(Const X, Y: integer);
// FIXME: no pincha
VAR
  AreaRadius                    : integer;
  Magnification                 : integer;
  xActual, yActual, sizeX, sizeY: integer;
Const
  mag = 50; // number of pixels taken
BEGIN
  If BackupBitmap = Nil Then
    exit;
  xActual := round((X * FImage.Picture.Height) / FImage.Height);
  yActual := round((Y * FImage.Picture.Width) / FImage.Width);
  If (xActual < 0) Or (yActual < 0) Or (xActual > FImage.Picture.Width) Or
    (yActual > FImage.Picture.Height) Then
    exit;
  AreaRadius := mag;
  Magnification := AreaRadius * MagnifierRatio;
  If (MagRect.Left <> MagRect.Right) Then
  Begin
    FImage.Picture.Bitmap.Canvas.CopyRect(MagRect,
      FBackupBitmap.Canvas, MagRect);
  End;
  MagRect := Rect(xActual - Magnification, yActual - Magnification,
    xActual + Magnification, yActual + Magnification);
  FImage.Picture.Bitmap.Canvas.Brush.Bitmap := TBitmap.Create;
  sizeX := round((MagnifierRatio * FImage.Picture.Height) / FImage.Height);
  FImage.Picture.Bitmap.Canvas.Brush.Bitmap.Height := sizeX;
  sizeY := round((MagnifierRatio * FImage.Picture.Width) / FImage.Width);
  FImage.Picture.Bitmap.Canvas.Brush.Bitmap.Width := sizeY;
  // image.Picture.Bitmap.Canvas.Brush.Bitmap.Canvas.StretchDraw();
  // image.Picture.Bitmap.Canvas.Brush.Bitmap.Assign(FBackupBitmap);
  FImage.Picture.Bitmap.Canvas.Brush.Bitmap.Canvas.CopyRect(MagRect,
    FBackupBitmap.Canvas, Rect(xActual - AreaRadius, yActual - AreaRadius,
    xActual + AreaRadius, yActual + AreaRadius));
  // no pincha
  FImage.Picture.Bitmap.Canvas.Ellipse(MagRect);
  FImage.Picture.Bitmap.Canvas.Brush.Bitmap.Free;
  FImage.refresh;
END;

end.
