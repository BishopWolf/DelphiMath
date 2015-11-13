/// <summary>
/// Unit uMedicalImage sets the base component for medical images Created by
/// Alex Vergara Gil based on ezDICOM by Chris Rorden
/// </summary>
/// <remarks>
/// Created Oct 3, 2012: Included a base class for all kind of medical
/// images, byte order treatment
/// </remarks>
Unit uMedicalImage;

Interface

Uses
  Windows, Dialogs, Controls, classes, SysUtils, GaugeFloat, uConstants, utypes;

Type
  /// <summary>
  /// Kinds of medical images
  /// </summary>
  TMedicalImageType = (TITInterfile, TITAnalyze, TITMetaImage, TITDICOM);

  /// <summary>
  /// Contains all posible data in a medical image
  /// </summary>
  TMedicalImageData = Record
    XYZdim: Array [1 .. 4] Of integer; // 4=volume, eg time: some EC*T7 images
    XYZori: Array [1 .. 3] Of integer;
    XYZmm: Array [1 .. 3] Of double;
    XYZstart: Array [1 .. 3] Of integer;
    Rotate180deg, Float, RunLengthEncoding, GenesisCpt, JPEGlosslessCpt,
      JPEGlossyCpt, ElscintCompress, MinIntensitySet, signed: boolean;
    IntenScale, IntenIntercept, kV, mA, TR, TE, spacing, location: single;
    SiemensInterleaved { 0=no,1=yes,2=not defined } , SiemensMosaicX,
      SiemensMosaicY, CompressSz, CompressOffset, Monochrome, SamplesPerPixel,
      PlanarConfig, ImageStart, little_endian, Allocbits_per_pixel,
      Storedbits_per_pixel, ImageSz, PatientIDint, WindowWidth, WindowCenter,
      GenesisPackHdr, NamePos, StudyDatePos, RLEredOffset, RLEgreenOffset,
      RLEblueOffset, RLEredSz, RLEgreenSz, RLEblueSz, nonzerobins: integer;
    { must be 32-bit integer aka longint }
    SiemensSlices, VolumeNumber, SeriesNum, AcquNum, ImageNum,
      accession: integer;
    AcqTime, ImgTime, PatientName, PatientID, StudyDate, StudyID, modality,
      serietag: String;
    MinIntensity, MaxIntensity: Float;
  End;

  /// <summary>
  /// Base component for medical images
  /// </summary>
  TMedicalImage = Class Abstract
  Private
    Fdatacreated: boolean;
    Function GetElemento(m, n, o: integer): Float;
{$IFDEF INLININGSUPPORTED} Inline;
{$ENDIF}
    Procedure SetElemento(m, n, o: integer; Const Value: Float);
    Procedure SetDataCreated(Const Value: boolean);
{$IFDEF INLININGSUPPORTED} Inline; {$ENDIF}
  Public
    /// <summary>
    /// This is where the image data is located
    /// </summary>
    Data: TMedicalImageData;
    /// <summary>
    /// This is where the Image is located
    /// </summary>
    /// <value>
    /// T3DMatrix: refer to utypes
    /// </value>
    Image: T3DMatrix;
    /// <summary>
    /// default property to get an element from the image
    /// </summary>
    /// <param name="m">
    /// row
    /// </param>
    /// <param name="n">
    /// column
    /// </param>
    /// <param name="o">
    /// slide
    /// </param>
    /// <remarks>
    /// if your study is CTStudy just cal CTStudy[m,n,o] to obtain the
    /// element located at row m, column n and slide o
    /// </remarks>
    Property Elemento[m, n, o: integer]: Float Read GetElemento
      Write SetElemento; Default;
    /// <summary>
    /// If Image is created then true else false
    /// </summary>
    /// <remarks>
    /// Useful for destroying
    /// </remarks>
    Property datacreated: boolean Read Fdatacreated Write Setdatacreated;
    /// <summary>
    /// Initializes or clear a Medical Image Data Instance
    /// </summary>
    Procedure clear(Var lData: TMedicalImageData);

    /// <summary>
    /// Destroy an instance of a medical image
    /// </summary>
    Destructor Destroy; Override;

    /// <summary>
    /// Creates a blank instance of a medical image
    /// </summary>
    Constructor Create; Overload;

    /// <summary>
    /// Creates an instance of a medical image based on the information of
    /// another one
    /// </summary>
    /// <param name="Another">
    /// The other instance which contains the data
    /// </param>
    /// <param name="StealImage">
    /// If we would steal the other instance image for transfer speed (true),
    /// it can be returned with GiveImage procedure, or just copy the image
    /// (false, slower)
    /// </param>
    Constructor Create(Another: TMedicalImage;
      StealImage: boolean = false); Overload;
    Constructor Create(Another: TMedicalImageData); Overload;

    /// <summary>
    /// Gives Image to other Medical Image instance, actual image is lost
    /// </summary>
    Procedure GiveImage(Var Another: TMedicalImage);

    /// <summary>
    /// Sets the min and max values
    /// </summary>
    Procedure SetMinMax;

  End;

Implementation

Uses uoperations, uminmax;

{ TMedicalImage }

Constructor TMedicalImage.Create;
Begin
  clear(Data);
  datacreated := false;
End;

Constructor TMedicalImage.Create(Another: TMedicalImage; StealImage: boolean);
Begin
  Data := Another.Data;
  If StealImage Then
  Begin
    Image := Another.Image; // faster but dangerous!!
    Another.datacreated := false; // critical!!!
  End
  Else
    Image := Clone(Another.Image, Another.Data.XYZdim[1],
      Another.Data.XYZdim[2], Another.Data.XYZdim[3]);
  Data.ImageSz := Data.XYZdim[1] * Data.XYZdim[2] * Data.XYZdim[3] *
    Data.Storedbits_per_pixel Div 8;
  datacreated := true;
End;

Constructor TMedicalImage.Create(Another: TMedicalImageData);
Begin
  Data := Another;
  datacreated := true;
End;

Destructor TMedicalImage.Destroy;
Begin
  If datacreated Then
  Begin
    delmatrix(Image);
  End;
  Inherited Destroy;
End;

Function TMedicalImage.GetElemento(m, n, o: integer): Float;
Begin
  result := Image[m, n, o];
End;

Procedure TMedicalImage.GiveImage(Var Another: TMedicalImage);
Begin
  If (Another <> Nil) Then
  Begin
    If (Another.datacreated) Then
      delmatrix(Another.Image);
    Another.Image := Self.Image;
    Self.datacreated := false;
  End;
End;

Procedure TMedicalImage.clear(Var lData: TMedicalImageData);
Begin
  { red_table_size   := 0;
    green_table_size := 0;
    blue_table_size  := 0;
    red_table        := nil;
    green_table      := nil;
    blue_table       := nil; }
  With lData Do
  Begin
    PatientIDint := 0;
    PatientName := 'NO NAME';
    PatientID := 'NO ID';
    StudyDate := '';
    AcqTime := '';
    ImgTime := '';
    TR := 0;
    TE := 0;
    kV := 0;
    mA := 0;
    Rotate180deg := false;
    MaxIntensity := 0;
    MinIntensity := 0;
    MinIntensitySet := false;
    ElscintCompress := false;
    Float := false;
    ImageNum := 0;
    SiemensInterleaved := 2; // 0=no,1=yes,2=undefined
    SiemensSlices := 0;
    SiemensMosaicX := 1;
    SiemensMosaicY := 1;
    IntenScale := 1;
    IntenIntercept := 0;
    SeriesNum := 1;
    AcquNum := 0;
    ImageNum := 1;
    accession := 1;
    PlanarConfig := 0; // only used in RGB values
    RunLengthEncoding := false;
    CompressSz := 0;
    CompressOffset := 0;
    SamplesPerPixel := 1;
    WindowCenter := 0;
    WindowWidth := 0;
    Monochrome := 2; { most common }
    XYZmm[1] := 1;
    XYZmm[2] := 1;
    XYZmm[3] := 1;
    XYZdim[1] := 1;
    XYZdim[2] := 1;
    XYZdim[3] := 1;
    XYZdim[4] := 1;
    XYZori[1] := 1;
    XYZori[2] := 1;
    XYZori[3] := 1;
    XYZstart[1] := 0;
    XYZstart[2] := 0;
    XYZstart[3] := 0;
    ImageStart := 0;
    little_endian := 1;
    Allocbits_per_pixel := 16; // bits
    Storedbits_per_pixel := Allocbits_per_pixel;
    GenesisCpt := false;
    JPEGlosslessCpt := false;
    JPEGlossyCpt := false;
    GenesisPackHdr := 0;
    StudyDatePos := 0;
    NamePos := 0;
    RLEredOffset := 0;
    RLEgreenOffset := 0;
    RLEblueOffset := 0;
    RLEredSz := 0;
    RLEgreenSz := 0;
    RLEblueSz := 0;
    spacing := 0;
    location := 0;
    // Frames:=1;
    modality := 'MR';
    serietag := '';
  End;
End;

Procedure TMedicalImage.Setdatacreated(Const Value: boolean);
Begin
  Fdatacreated := Value;
End;

Procedure TMedicalImage.SetElemento(m, n, o: integer; Const Value: Float);
Begin
  Image[m, n, o] := Value;
End;

Procedure TMedicalImage.SetMinMax;
Var
  lmin, lmax: Float;
Begin
  MINMAX(Image, 1, Data.XYZdim[1], 1, Data.XYZdim[2], 1, Data.XYZdim[3],
    lmin, lmax);
  Data.MinIntensity := lmin;
  Data.MaxIntensity := lmax;
  Data.MinIntensitySet := true;
End;

End.
