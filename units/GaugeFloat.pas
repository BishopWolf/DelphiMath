unit GaugeFloat;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, Gauges, ExtCtrls, uConstants;

type
  TWZBoundLabel = class(TBoundLabel)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;

  TGaugeFloat = class(TGraphicControl)
  private
    { Private declarations }
    FMinValue: float;
    FMaxValue: float;
    FCurValue: float;
    FKind: TGaugeKind;
    FBorderStyle: TBorderStyle;
    FShowText: Boolean;
    FForeColor: TColor;
    FBackColor: TColor;
    FLeftText: String;
    FRightText: String;
    FCaptionLabel: TWZBoundLabel;
    FCaptioned: Boolean;
    FLabelSpacing: Integer;
    FLabelPosition: TLabelPosition;
    FAlignment: TAlignment;
    procedure PaintBackground(AnImage: TBitmap);
    procedure PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsText(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
    procedure SetMinValue(Value: float);
    procedure SetMaxValue(Value: float);
    procedure SetProgress(Value: float);
    function GetPercentDone: float;
    procedure SetKind(const Value: TGaugeKind);
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetShowText(const Value: Boolean);
    procedure SetBackColor(const Value: TColor);
    procedure SetForeColor(const Value: TColor);
    procedure SetLeftText(const Value: String);
    procedure SetRightText(const Value: String);
    // procedure SetCaptionLabel(const Value: String);
    procedure SetCaptioned(const Value: Boolean);
    procedure SetLabelSpacing(const Value: Integer);
    procedure SetLabelPosition(const Value: TLabelPosition);
    procedure SetAlignment(const Value: TAlignment);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure CMVisiblechanged(var Message: TMessage);
      message CM_VISIBLECHANGED;
    procedure CMEnabledchanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;
    procedure CMBidimodechanged(var Message: TMessage);
      message CM_BIDIMODECHANGED;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure AddProgress(Value: float);
    procedure updateTime(tiempo0: Integer; progreso: float; mensaje: string);
    property PercentDone: float read GetPercentDone;
    procedure SetupInternalLabel;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer;
      AHeight: Integer); override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property Color;
    property Constraints;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
      default bsSingle;
    property Kind: TGaugeKind read FKind write SetKind default gkHorizontalBar;
    property MinValue: float read FMinValue write SetMinValue;
    property MaxValue: float read FMaxValue write SetMaxValue;
    property Progress: float read FCurValue write SetProgress;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property BackColor: TColor read FBackColor write SetBackColor
      default clWhite;
    property ForeColor: TColor read FForeColor write SetForeColor
      default clBlack;
    property LeftText: String read FLeftText write SetLeftText;
    property RightText: String read FRightText write SetRightText;
    property CaptionLabel: TWZBoundLabel read FCaptionLabel;
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property Captioned: Boolean read FCaptioned write SetCaptioned;
    property LabelPosition: TLabelPosition read FLabelPosition
      write SetLabelPosition default lpAbove;
    property LabelSpacing: Integer read FLabelSpacing write SetLabelSpacing
      default 3;
  end;

procedure Register;

implementation

uses Consts, umemory;

type
  TBltBitmap = class(TBitmap)
    procedure MakeLike(ATemplate: TBitmap);
  public
    function Func: Integer;
  end;

  { TBltBitmap }

procedure TBltBitmap.MakeLike(ATemplate: TBitmap);
begin
  Width := ATemplate.Width;
  Height := ATemplate.Height;
  Canvas.Brush.Color := clWindowFrame;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, Width, Height));
end;

procedure Register;
begin
  RegisterComponents('Samples', [TGaugeFloat]);
end;

{ This function solves for x in the equation "x is y% of z". }
function SolveForX(Y, Z: float): float;
begin
  Result := Z * (Y * 0.01);
end;

{ This function solves for y in the equation "x is y% of z". }
function SolveForY(X, Z: float): float;
begin
  if Z = 0 then
    Result := 0
  else
    Result := (X * 100.0) / Z;
end;

function AdjustedAlignment(RightToLeftAlignment: Boolean; Alignment: TAlignment)
  : TAlignment;
begin
  Result := Alignment;
  if RightToLeftAlignment then
    case Result of
      taLeftJustify:
        Result := taRightJustify;
      taRightJustify:
        Result := taLeftJustify;
    end;
end;

{ TGaugeFloat }

procedure TGaugeFloat.AddProgress(Value: float);
begin
  Progress := FCurValue + Value;
  Refresh;
end;

procedure TGaugeFloat.CMBidimodechanged(var Message: TMessage);
begin
  inherited;
  FCaptionLabel.BiDiMode := BiDiMode;
end;

procedure TGaugeFloat.CMEnabledchanged(var Message: TMessage);
begin
  inherited;
  FCaptionLabel.Enabled := Enabled;
end;

procedure TGaugeFloat.CMVisiblechanged(var Message: TMessage);
begin
  inherited;
  FCaptionLabel.Visible := Visible;
end;

constructor TGaugeFloat.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csFramed, csOpaque];
  { default values }
  FMinValue := 0;
  FMaxValue := 100;
  FCurValue := 0;
  FKind := gkHorizontalBar;
  FShowText := True;
  FBorderStyle := bsSingle;
  FForeColor := clBlack;
  FBackColor := clWhite;
  Width := 100;
  Height := 100;
  LeftText := '';
  RightText := '';
  FLabelSpacing := 3;
  FLabelPosition := lpAbove;
  FCaptioned := True;
  SetupInternalLabel;
end;

function TGaugeFloat.GetPercentDone: float;
begin
  Result := SolveForY(FCurValue - FMinValue, FMaxValue - FMinValue);
end;

procedure TGaugeFloat.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FCaptionLabel) and (Operation = opRemove) then
    FCaptionLabel := nil;
end;

procedure TGaugeFloat.Paint;
var
  TheImage: TBitmap;
  OverlayImage: TBltBitmap;
  PaintRect: TRect;
begin
  with Canvas do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := Height;
      TheImage.Width := Width;
      PaintBackground(TheImage);
      PaintRect := ClientRect;
      if FBorderStyle = bsSingle then
        InflateRect(PaintRect, -1, -1);
      OverlayImage := TBltBitmap.Create;
      try
        OverlayImage.MakeLike(TheImage);
        PaintBackground(OverlayImage);
        case Kind of
          gkText:
            PaintAsNothing(OverlayImage, PaintRect);
          gkHorizontalBar, gkVerticalBar:
            PaintAsBar(OverlayImage, PaintRect);
          gkPie:
            PaintAsPie(OverlayImage, PaintRect);
          gkNeedle:
            PaintAsNeedle(OverlayImage, PaintRect);
        end;
        TheImage.Canvas.CopyMode := cmSrcInvert;
        TheImage.Canvas.Draw(0, 0, OverlayImage);
        TheImage.Canvas.CopyMode := cmSrcCopy;
        if ShowText then
          PaintAsText(TheImage, PaintRect);
      finally
        OverlayImage.Free;
      end;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.Draw(0, 0, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
end;

procedure TGaugeFloat.PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
var
  FillSize: Longint;
  W, H: Integer;
begin
  W := PaintRect.Right - PaintRect.Left + 1;
  H := PaintRect.Bottom - PaintRect.Top + 1;
  with AnImage.Canvas do
  begin
    Brush.Color := BackColor;
    FillRect(PaintRect);
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Brush.Color := ForeColor;
    case Kind of
      gkHorizontalBar:
        begin
          FillSize := Longint(Trunc(SolveForX(PercentDone, W)));
          if FillSize > W then
            FillSize := W;
          if FillSize > 0 then
            FillRect(Rect(PaintRect.Left, PaintRect.Top, FillSize, H));
        end;
      gkVerticalBar:
        begin
          FillSize := Longint(Trunc(SolveForX(PercentDone, H)));
          if FillSize >= H then
            FillSize := H - 1;
          FillRect(Rect(PaintRect.Left, H - FillSize, W, H));
        end;
    end;
  end;
end;

procedure TGaugeFloat.PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX: Integer;
  Angle: Double;
  X, Y, W, H: Integer;
begin
  with PaintRect do
  begin
    X := Left;
    Y := Top;
    W := Right - Left;
    H := Bottom - Top;
    if BorderStyle = bsSingle then
    begin
      Inc(W);
      Inc(H);
    end;
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Pie(X, Y, W, H * 2 - 1, X + W, PaintRect.Bottom - 1, X,
      PaintRect.Bottom - 1);
    MoveTo(X, PaintRect.Bottom);
    LineTo(X + W, PaintRect.Bottom);
    if PercentDone > 0 then
    begin
      Pen.Color := ForeColor;
      MiddleX := Width div 2;
      MoveTo(MiddleX, PaintRect.Bottom - 1);
      Angle := (Pi * ((PercentDone / 100)));
      LineTo(Integer(Round(MiddleX * (1 - Cos(Angle)))),
        Integer(Round((PaintRect.Bottom - 1) * (1 - Sin(Angle)))));
    end;
  end;
end;

procedure TGaugeFloat.PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
begin
  with AnImage do
  begin
    Canvas.Brush.Color := BackColor;
    Canvas.FillRect(PaintRect);
  end;
end;

procedure TGaugeFloat.PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX, MiddleY: Integer;
  Angle: Double;
  W, H: Integer;
begin
  W := PaintRect.Right - PaintRect.Left;
  H := PaintRect.Bottom - PaintRect.Top;
  if BorderStyle = bsSingle then
  begin
    Inc(W);
    Inc(H);
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Ellipse(PaintRect.Left, PaintRect.Top, W, H);
    if PercentDone > 0 then
    begin
      Brush.Color := ForeColor;
      MiddleX := W div 2;
      MiddleY := H div 2;
      Angle := (Pi * ((PercentDone / 50) + 0.5));
      Pie(PaintRect.Left, PaintRect.Top, W, H,
        Integer(Round(MiddleX * (1 - Cos(Angle)))),
        Integer(Round(MiddleY * (1 - Sin(Angle)))), MiddleX, 0);
    end;
  end;
end;

procedure TGaugeFloat.PaintAsText(AnImage: TBitmap; PaintRect: TRect);
var
  S: string;
  X, Y: Integer;
  OverRect: TBltBitmap;
begin
  OverRect := TBltBitmap.Create;
  try
    OverRect.MakeLike(AnImage);
    PaintBackground(OverRect);
    S := Format('%4.1f%%', [PercentDone]);
    with OverRect.Canvas do
    begin
      Brush.Style := bsClear;
      Font := Self.Font;
      Font.Color := clWhite;
      with PaintRect do
      begin
        X := (Right - Left + 1 - TextWidth(S)) div 2;
        Y := (Bottom - Top + 1 - TextHeight(S)) div 2;
      end;
      TextRect(PaintRect, X, Y, S);
      TextRect(PaintRect, PaintRect.Left + 1, Y, LeftText);
      TextRect(PaintRect, PaintRect.Right - TextWidth(RightText) - 1, Y,
        RightText);
    end;
    AnImage.Canvas.CopyMode := cmSrcInvert;
    AnImage.Canvas.Draw(0, 0, OverRect);
  finally
    OverRect.Free;
  end;
end;

procedure TGaugeFloat.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
    CopyMode := cmBlackness;
    ARect := Rect(0, 0, Width, Height);
    CopyRect(ARect, AnImage.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure TGaugeFloat.SetAlignment(const Value: TAlignment);
begin
  if Value <> FAlignment then
  begin
    FAlignment := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetBackColor(const Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetBorderStyle(const Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  SetLabelPosition(FLabelPosition);
end;

procedure TGaugeFloat.SetCaptioned(const Value: Boolean);
begin
  if Value <> FCaptioned then
  begin
    FCaptioned := Value;
    if Captioned then
      SetupInternalLabel
    else
      FCaptionLabel.Free;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetForeColor(const Value: TColor);
begin
  if Value <> FForeColor then
  begin
    FForeColor := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetKind(const Value: TGaugeKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetLabelPosition(const Value: TLabelPosition);
var
  P: TPoint;
begin
  if (Value <> FLabelPosition) or (FCaptionLabel <> nil) then
  begin
    FLabelPosition := Value;
    case Value of
      lpAbove:
        case AdjustedAlignment(UseRightToLeftAlignment, FAlignment) of
          taLeftJustify:
            P := Point(Left, Top - FCaptionLabel.Height - FLabelSpacing);
          taRightJustify:
            P := Point(Left + Width - FCaptionLabel.Width,
              Top - FCaptionLabel.Height - FLabelSpacing);
          taCenter:
            P := Point(Left + (Width - FCaptionLabel.Width) div 2,
              Top - FCaptionLabel.Height - FLabelSpacing);
        end;
      lpBelow:
        case AdjustedAlignment(UseRightToLeftAlignment, FAlignment) of
          taLeftJustify:
            P := Point(Left, Top + Height + FLabelSpacing);
          taRightJustify:
            P := Point(Left + Width - FCaptionLabel.Width,
              Top + Height + FLabelSpacing);
          taCenter:
            P := Point(Left + (Width - FCaptionLabel.Width) div 2,
              Top + Height + FLabelSpacing);
        end;
      lpLeft:
        P := Point(Left - FCaptionLabel.Width - FLabelSpacing,
          Top + ((Height - FCaptionLabel.Height) div 2));
      lpRight:
        P := Point(Left + Width + FLabelSpacing,
          Top + ((Height - FCaptionLabel.Height) div 2));
    end;
    FCaptionLabel.SetBounds(P.X, P.Y, FCaptionLabel.Width,
      FCaptionLabel.Height);
    Refresh;
  end;
end;

procedure TGaugeFloat.SetLabelSpacing(const Value: Integer);
begin
  if Value <> FLabelSpacing then
  begin
    FLabelSpacing := Value;
    SetLabelPosition(FLabelPosition);
    Refresh;
  end;
end;

procedure TGaugeFloat.SetLeftText(const Value: String);
begin
  if Value <> FLeftText then
  begin
    FLeftText := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetMaxValue(Value: float);
begin
  if Value <> FMaxValue then
  begin
    if Value < FMinValue then
      if not(csLoading in ComponentState) then
        raise EInvalidOperation.CreateFmt(SOutOfRange, [FMinValue + 1, MaxInt]);
    FMaxValue := Value;
    if FCurValue > Value then
      FCurValue := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetMinValue(Value: float);
begin
  if Value <> FMinValue then
  begin
    if Value > FMaxValue then
      if not(csLoading in ComponentState) then
        raise EInvalidOperation.CreateFmt(SOutOfRange,
          [-MaxInt, FMaxValue - 1]);
    FMinValue := Value;
    if FCurValue < Value then
      FCurValue := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if FCaptionLabel = nil then
    exit;
  FCaptionLabel.Parent := AParent;
  FCaptionLabel.Visible := True;
end;

procedure TGaugeFloat.SetProgress(Value: float);
var
  TempPercent: float;
begin
  TempPercent := GetPercentDone; { remember where we were }
  if Value < FMinValue then
    Value := FMinValue
  else if Value > FMaxValue then
    Value := FMaxValue;
  if FCurValue <> Value then
  begin
    FCurValue := Value;
    if TempPercent <> GetPercentDone then { only refresh if percentage changed }
      Refresh;
  end;
end;

procedure TGaugeFloat.SetRightText(const Value: String);
begin
  if Value <> FRightText then
  begin
    FRightText := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetShowText(const Value: Boolean);
begin
  if FShowText <> Value then
  begin
    FShowText := Value;
    Refresh;
  end;
end;

procedure TGaugeFloat.SetupInternalLabel;
begin
  if Assigned(FCaptionLabel) then
    exit;
  FCaptionLabel := TWZBoundLabel.Create(Self);
  FCaptionLabel.FreeNotification(Self);
  FCaptionLabel.FocusControl := Self.Parent;
end;

procedure TGaugeFloat.updateTime(tiempo0: Integer; progreso: float;
  mensaje: string);
const
  ltiny = 0.01;
var
  tiemp: Integer;
begin
  tiemp := tiempo_en_milisegundos - tiempo0;
  FCaptionLabel.Text := mensaje;
  Progress := progreso;
  LeftText := Format('%s', [Tiempo_transcurrido(tiemp, '')]);
  RightText := Format('%s',
    [Tiempo_transcurrido(Round(tiemp * (100 - Progress) /
    (Progress + ltiny)), '')]);
  Application.ProcessMessages;
end;

{ TWZBoundLabel }

constructor TWZBoundLabel.Create(AOwner: TComponent);
begin
  inherited;
end;

function TBltBitmap.Func: Integer;
begin
end;

end.
