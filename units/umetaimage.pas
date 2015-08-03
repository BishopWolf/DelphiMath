/// <summary>
/// Unit uMetaImage handles ITK MetaImage medical images.
/// Created by Alex Vergara Gil.
/// </summary>
/// <remarks>
/// Created jan 15, 2015
/// </remarks>
Unit uMetaImage;

Interface

Uses sysutils, Dialogs, utypes, uConstants, uInterfile, gaugefloat,
  umedicalImage;

Type
  AMetaTypes = (MET_NONE, MET_ASCII_CHAR, MET_CHAR, MET_UCHAR, MET_SHORT,
    MET_USHORT, MET_INT, MET_UINT, MET_LONG, MET_ULONG, MET_LONG_LONG,
    MET_ULONG_LONG, MET_FLOAT, MET_DOUBLE, MET_STRING, MET_CHAR_ARRAY,
    MET_UCHAR_ARRAY, MET_SHORT_ARRAY, MET_USHORT_ARRAY, MET_INT_ARRAY,
    MET_UINT_ARRAY, MET_LONG_ARRAY, MET_ULONG_ARRAY, MET_LONG_LONG_ARRAY,
    MET_ULONG_LONG_ARRAY, MET_FLOAT_ARRAY, MET_DOUBLE_ARRAY, MET_FLOAT_MATRIX,
    MET_OTHER);

  /// <summary>
  /// Standard header of an MetaImage
  /// </summary>
  AMIHdr = Packed Record
    instantiated: boolean;
    // From MetaObject
    Comment: String;
    ObjectType: String;
    ObjectSubType: String;
    TransformType: String;
    NDims: integer;
    Name: String;
    ID: integer; // -1 means undefined
    ParentID: integer; // -1 means undefined
    BinaryData: boolean;
    CompressedData: boolean;
    ElementByteOrderMSB: boolean;
    BinaryDataByteOrderMSB: boolean;
    Color: Array [1 .. 4] Of float;
    Position: TVector;
    Orientation: TMatrix;
    TransformMatrix: TMatrix;
    AnatomicalOrientation: String;
    ElementSpacing: TVector;
    CenterOfRotation: TVector;
    AcquisitionDate: String;
    // Specific to MetaImage
    DimSize: TIntVector;
    HeaderSize: integer; // Number of Bytes to skip at the head of data file.
    Modality: String;
    SequenceID: Array [1 .. 4] Of integer;
    ElementMin: float;
    ElementMax: float;
    ElementNumberOfChannels: integer;
    // Number of values (of type ElementType) per voxel
    ElementSize: TVector; // Physical size of each voxel
    ElementType: AMetaTypes;
    ElementDataFile: String;
    // if LOCAL data begins in next line, else find data in file ElementDataFile
  End;

  TMetaImage = Class(TInterfile) // inherits from uInterfile
  Private
    FHeader: AMIHdr;
    Procedure Preassign;
    Procedure ClearHdr(instancecreated: boolean);
    Procedure FillCommonHdr;
    Procedure FillHdr;
  Protected
    Procedure Read_hdr(Var lHdrOK, lImageFormatOK: boolean; Var lDynStr: String;
      filename: TFileName); Reintroduce; // Override;
  Public
    /// <summary>
    /// Creates an Instance from the header HeaderName
    /// </summary>
    /// <param name="readData">
    /// specify if the image should be readed or not
    /// </param>
    Constructor Create(HeaderName: TFileName; Progreso: TGaugeFloat = Nil;
      readData: boolean = true); Overload;

    /// <summary>
    /// Creates an instance with the data of another instance data
    /// </summary>
    Constructor Create(Another: TMedicalImageData; lImgName: TFileName;
      Progreso: TGaugeFloat); Overload;

    /// <summary>
    /// Creates an instance with the data of another instance data but
    /// doesn't read any image
    /// </summary>
    /// <param name="Initialize">
    /// if the image would be initialized or not
    /// </param>
    Constructor Create(Another: TMedicalImageData;
      Initialize: boolean = true); Overload;
    Constructor Create(Another: TMedicalImage;
      StealImage: boolean = false); Overload;

    Destructor Destroy; Override; // overload;
    Function Write_hdr(lHdrName, lImgName: TFileName): boolean; Reintroduce;
    // Override;
    /// <summary>
    /// Creates an Interfile Image in the hard disk
    /// </summary>
    Procedure SaveToFile(filename: TFileName; Progreso: TGaugeFloat;
      lUnit: float = 1);
  End;

Function LeeMetaImage(lFileName: TFileName; Var Progreso: TGaugeFloat)
  : TInterfile;

Implementation

Uses ustrings, math;

Const
  CMetatypes = 28;

Var
  SMetaTypes: Array [0 .. CMetatypes] Of String = (
    'MET_NONE',
    'MET_ASCII_CHAR',
    'MET_CHAR',
    'MET_UCHAR',
    'MET_SHORT',
    'MET_USHORT',
    'MET_INT',
    'MET_UINT',
    'MET_LONG',
    'MET_ULONG',
    'MET_LONG_LONG',
    'MET_ULONG_LONG',
    'MET_FLOAT',
    'MET_DOUBLE',
    'MET_STRING',
    'MET_CHAR_ARRAY',
    'MET_UCHAR_ARRAY',
    'MET_SHORT_ARRAY',
    'MET_USHORT_ARRAY',
    'MET_INT_ARRAY',
    'MET_UINT_ARRAY',
    'MET_LONG_ARRAY',
    'MET_ULONG_ARRAY',
    'MET_LONG_LONG_ARRAY',
    'MET_ULONG_LONG_ARRAY',
    'MET_FLOAT_ARRAY',
    'MET_DOUBLE_ARRAY',
    'MET_FLOAT_MATRIX',
    'MET_OTHER'
  );
  SMetaTypesbytes: Array [0 .. CMetatypes] Of ShortInt = (
    0,
    1,
    1,
    1,
    2,
    2,
    4,
    4,
    4,
    4,
    8,
    8,
    4,
    8,
    1,
    1,
    1,
    2,
    2,
    4,
    4,
    4,
    4,
    8,
    8,
    4,
    8,
    4,
    0
  );

  { TMetaImage }

Procedure TMetaImage.ClearHdr(instancecreated: boolean);
Var
  i: integer;
Begin
  FHeader.Comment := 'Image Created by MCID';
  FHeader.ObjectType := 'Image';
  FHeader.ObjectSubType := '';
  FHeader.TransformType := '';
  FHeader.NDims := 0;
  FHeader.Name := '';
  FHeader.ID := 0;
  FHeader.ParentID := 0;
  FHeader.BinaryData := false;
  FHeader.CompressedData := false;
  FHeader.ElementByteOrderMSB := false;
  FHeader.BinaryDataByteOrderMSB := false;
  For i := 1 To 4 Do
    FHeader.Color[i] := 0;
  // If instancecreated Then
  // Begin
  DelVector(FHeader.Position);
  DelMatrix(FHeader.Orientation);
  DelMatrix(FHeader.TransformMatrix);
  DelVector(FHeader.ElementSpacing);
  DelVector(FHeader.DimSize);
  DelVector(FHeader.ElementSize);
  DelVector(FHeader.CenterOfRotation);
  // End;
  FHeader.AnatomicalOrientation := 'RAI';
  FHeader.HeaderSize := 0;
  FHeader.Modality := '';
  FHeader.AcquisitionDate := '';
  For i := 1 To 4 Do
    FHeader.SequenceID[i] := 0;
  FHeader.ElementMin := 0;
  FHeader.ElementMax := 0;
  FHeader.ElementNumberOfChannels := 0;
  FHeader.ElementType := MET_NONE;
  FHeader.ElementDataFile := '';
  FHeader.instantiated := false;
End;

Procedure TMetaImage.Preassign;
Var
  i: integer;
Begin
  DimVector(FHeader.Position, 0);
  dimMatrix(FHeader.Orientation, 0, 0);
  dimMatrix(FHeader.TransformMatrix, 3, 3);
  For i := 1 To 3 Do
    FHeader.TransformMatrix[i, i] := 1;
  DimVector(FHeader.ElementSpacing, 0);
  DimVector(FHeader.DimSize, 0);
  DimVector(FHeader.ElementSize, 0);
  DimVector(FHeader.CenterOfRotation, 0);
End;

Constructor TMetaImage.Create(HeaderName: TFileName; Progreso: TGaugeFloat;
  readData: boolean);
Var
  HdrOK, ImgOK: boolean;
  lDynStr: String;
  lFileName: TFileName;
Begin
  lFileName := HeaderName;
  datacreated := false;
  Read_hdr(HdrOK, ImgOK, lDynStr, lFileName);
  FillCommonHdr;
  If HdrOK And Not readData Then
  Begin
    dimMatrix(Image, 0, 0, 0);
    datacreated := true;
    exit;
  End;
  If HdrOK And ImgOK Then
  Begin
    Read_Image(ExtractFilePath(lFileName), Progreso);
    datacreated := true;
  End
  Else If HdrOK Then
  Begin
    dimMatrix(Image, Data.XYZdim[1], Data.XYZdim[2], Data.XYZdim[3]);
    datacreated := true;
  End;
End;

Constructor TMetaImage.Create(Another: TMedicalImageData; lImgName: TFileName;
  Progreso: TGaugeFloat);
Begin
  Data := Another;
  FillHdr;
  ImageFileName := lImgName;
  Read_Image(ExtractFilePath(lImgName), Progreso);
  datacreated := true;
End;

Constructor TMetaImage.Create(Another: TMedicalImageData; Initialize: boolean);
Begin
  Data := Another;
  FillHdr;
  ImageFileName := '';
  If Initialize Then
  Begin
    dimMatrix(Image, Data.XYZdim[1], Data.XYZdim[2], Data.XYZdim[3]);
    datacreated := true;
  End
  Else
    datacreated := false;
End;

Constructor TMetaImage.Create(Another: TMedicalImage; StealImage: boolean);
Begin
  Inherited Create(Another, StealImage);
  FillHdr;
End;

Destructor TMetaImage.Destroy;
Begin
  ClearHdr(FHeader.instantiated);
  Inherited Destroy;
End;

Procedure TMetaImage.FillCommonHdr;
Var
  i: integer;
Begin
  If FHeader.instantiated Then
  Begin
    Data.Allocbits_per_pixel := SMetaTypesbytes[byte(FHeader.ElementType)] * 8;
    Data.Storedbits_per_pixel := Data.Allocbits_per_pixel;
    Data.float := (FHeader.ElementType In [MET_FLOAT, MET_DOUBLE,
      MET_FLOAT_ARRAY, MET_DOUBLE_ARRAY, MET_FLOAT_MATRIX]);
    Data.signed := (FHeader.ElementType In [MET_SHORT, MET_INT, MET_LONG,
      MET_LONG_LONG, MET_SHORT_ARRAY, MET_INT_ARRAY, MET_LONG_ARRAY,
      MET_LONG_LONG_ARRAY]);
    Data.SamplesPerPixel := FHeader.ElementNumberOfChannels;
    Data.IntenScale := 1;
    Data.IntenIntercept := 0;
    Data.MinIntensity := FHeader.ElementMin;
    Data.MaxIntensity := FHeader.ElementMax;
    Data.MinIntensitySet := true;
    Data.ImageStart := FHeader.HeaderSize;
    Data.StudyID := int2str(FHeader.ID);
    Data.SeriesNum := FHeader.ID;
    Data.Modality := FHeader.Modality;
    Data.AcqTime := FHeader.AcquisitionDate;
    Data.PatientName := FHeader.Name;
    If FHeader.BinaryDataByteOrderMSB Then
      Data.little_endian := 0
    Else
      Data.little_endian := 1;
    For i := 1 To min(3, FHeader.NDims) Do
    Begin
      Data.XYZdim[i] := FHeader.DimSize[i];
      Data.XYZmm[i] := FHeader.ElementSpacing[i];
      Data.XYZstart[i] := round(FHeader.Position[i]);
      Data.XYZori[i] := Data.XYZdim[i];
    End;
    For i := min(3, FHeader.NDims) + 1 To 4 Do
    Begin
      Data.XYZdim[i] := 1;
    End;
    ImageFileName := FHeader.ElementDataFile;
    If FHeader.NDims >= 3 Then
      Data.spacing := FHeader.ElementSpacing[3];
  End;
End;

Procedure TMetaImage.FillHdr;
Var
  i: integer;
Begin
  ClearHdr(false);
  Preassign;
  FHeader.instantiated := true;
  If Data.float Then
  Begin
    Case Data.Allocbits_per_pixel Of
      32:
        FHeader.ElementType := MET_FLOAT;
      64:
        FHeader.ElementType := MET_DOUBLE;
    End;
  End
  Else
  Begin
    Case Data.Allocbits_per_pixel Of
      16:
        If Data.signed Then
          FHeader.ElementType := MET_SHORT
        Else
          FHeader.ElementType := MET_USHORT;
      32:
        If Data.signed Then
          FHeader.ElementType := MET_INT
        Else
          FHeader.ElementType := MET_UINT;
      { 32:     // INT y LONG es lo mismo ??
        if Data.signed then
        FHeader.ElementType := MET_LONG
        else
        FHeader.ElementType := MET_ULONG; }
      64:
        If Data.signed Then
          FHeader.ElementType := MET_LONG_LONG
        Else
          FHeader.ElementType := MET_ULONG_LONG;
    End;
  End;
  FHeader.ElementNumberOfChannels := Data.SamplesPerPixel;
  FHeader.ElementMin := Data.MinIntensity;
  FHeader.ElementMax := Data.MaxIntensity;
  FHeader.HeaderSize := Data.ImageStart;
  FHeader.ID := Str2Int(Data.StudyID);
  FHeader.Modality := Data.Modality;
  FHeader.Name := Data.PatientName;
  FHeader.ObjectType := 'Image';
  FHeader.BinaryData := true;
  FHeader.AnatomicalOrientation := 'RAI';
  FHeader.BinaryDataByteOrderMSB := (Data.little_endian = 0);
  FHeader.ElementByteOrderMSB := (Data.little_endian = 0);
  If Data.XYZdim[3] > 1 Then
    FHeader.NDims := 3
  Else
    FHeader.NDims := 2;
  DelVector(FHeader.DimSize);
  DimVector(FHeader.DimSize, FHeader.NDims);
  DelVector(FHeader.ElementSize);
  DimVector(FHeader.ElementSize, FHeader.NDims);
  DelVector(FHeader.Position);
  DimVector(FHeader.Position, FHeader.NDims);
  DelVector(FHeader.ElementSpacing);
  DimVector(FHeader.ElementSpacing, FHeader.NDims);
  DelVector(FHeader.CenterOfRotation);
  DimVector(FHeader.CenterOfRotation, FHeader.NDims);
  For i := 1 To FHeader.NDims Do
  Begin
    FHeader.DimSize[i] := Data.XYZdim[i];
    FHeader.ElementSize[i] := Data.XYZmm[i];
    FHeader.Position[i] := Data.XYZstart[i];
    FHeader.ElementSpacing[i] := Data.XYZmm[i];
    FHeader.CenterOfRotation[i] := Data.XYZdim[i] / 2;
  End;
  FHeader.ElementDataFile := ImageFileName;
End;

Procedure TMetaImage.Read_hdr(Var lHdrOK, lImageFormatOK: boolean;
  Var lDynStr: String; filename: TFileName);
Var
  f: textfile;
  line: String;
  parsed: TStrVector;
  i, j, cont: integer;
  N: byte;
  Function strtobool(str: String): boolean;
  Begin
    If str = 'True' Then
      result := true
    Else
      result := false;
  End;
  Function gettype(str: String): AMetaTypes;
  Var
    c: integer;
  Begin
    result := MET_NONE;
    For c := 0 To CMetatypes Do
      If UpperCase(str) = SMetaTypes[c] Then
      Begin
        result := AMetaTypes(c);
        exit;
      End;
  End;
  Function procesastr(str: TStrVector; linit, lend: integer): String;
  Var
    c: integer;
  Begin
    result := '';
    For c := linit To lend Do
      result := result + str[c] + ' ';
  End;

Begin
  ClearHdr(false);
  Preassign;
  AssignFile(f, filename);
  reset(f);
  Repeat
    Readln(f, line);
    line := Trim(line);
    Parse(line, ' ', parsed, N);
    If (parsed[2] = '=') And (N > 2) Then // correct
    Begin
      If parsed[1] = 'Comment' Then
        FHeader.Comment := procesastr(parsed, 3, N)
      Else If parsed[1] = 'ObjectType' Then
        FHeader.ObjectType := procesastr(parsed, 3, N)
      Else If parsed[1] = 'ObjectSubType' Then
        FHeader.ObjectSubType := procesastr(parsed, 3, N)
      Else If parsed[1] = 'TransformType' Then
        FHeader.TransformType := procesastr(parsed, 3, N)
      Else If parsed[1] = 'NDims' Then
        FHeader.NDims := Str2Int(parsed[3])
      Else If parsed[1] = 'Name' Then
        FHeader.Name := procesastr(parsed, 3, N)
      Else If parsed[1] = 'ID' Then
        FHeader.ID := Str2Int(parsed[3])
      Else If parsed[1] = 'ParentID' Then
        FHeader.ParentID := Str2Int(parsed[3])
      Else If parsed[1] = 'BinaryData' Then
        FHeader.BinaryData := strtobool(parsed[3])
      Else If parsed[1] = 'AcquisitionDate' Then
        FHeader.AcquisitionDate := (parsed[3])
      Else If parsed[1] = 'CompressedData' Then
        FHeader.CompressedData := strtobool(parsed[3])
      Else If parsed[1] = 'ElementByteOrderMSB' Then
        FHeader.ElementByteOrderMSB := strtobool(parsed[3])
      Else If parsed[1] = 'BinaryDataByteOrderMSB' Then
        FHeader.BinaryDataByteOrderMSB := strtobool(parsed[3])
      Else If parsed[1] = 'Color' Then
        For i := 1 To 4 Do
          FHeader.Color[i] := StrToFloat(parsed[i + 2])
      Else If parsed[1] = 'AnatomicalOrientation' Then
        FHeader.AnatomicalOrientation := procesastr(parsed, 3, N)
      Else If parsed[1] = 'HeaderSize' Then
        FHeader.HeaderSize := Str2Int(parsed[3])
      Else If parsed[1] = 'Modality' Then
        FHeader.Modality := procesastr(parsed, 3, N)
      Else If parsed[1] = 'SequenceID' Then
        For i := 1 To 4 Do
          FHeader.SequenceID[i] := Str2Int(parsed[i + 2])
      Else If parsed[1] = 'ElementMin' Then
        FHeader.ElementMin := StrToFloat(parsed[3])
      Else If parsed[1] = 'ElementMax' Then
        FHeader.ElementMax := StrToFloat(parsed[3])
      Else If parsed[1] = 'ElementNumberOfChannels' Then
        FHeader.ElementNumberOfChannels := Str2Int(parsed[3])
      Else If parsed[1] = 'ElementType' Then
        FHeader.ElementType := gettype(parsed[3])
      Else If parsed[1] = 'ElementDataFile' Then
        FHeader.ElementDataFile := procesastr(parsed, 3, N);

      If (FHeader.NDims > 0) Then // all vector lines must be after ndims
      Begin
        If parsed[1] = 'Position' Then
        Begin
          FHeader.instantiated := true;
          DelVector(FHeader.Position);
          DimVector(FHeader.Position, FHeader.NDims);
          For i := 1 To FHeader.NDims Do
            FHeader.Position[i] := StrToFloat(parsed[i + 2]);
        End
        Else If parsed[1] = 'Orientation' Then
        Begin
          FHeader.instantiated := true;
          DelMatrix(FHeader.Orientation);
          dimMatrix(FHeader.Orientation, FHeader.NDims, FHeader.NDims);
          cont := 3;
          For i := 1 To FHeader.NDims Do
            For j := 1 To FHeader.NDims Do
            Begin
              FHeader.Orientation[i, j] := Str2Int(parsed[cont]);
              inc(cont);
            End;
        End
        Else If parsed[1] = 'TransformMatrix' Then
        Begin
          FHeader.instantiated := true;
          DelMatrix(FHeader.TransformMatrix);
          dimMatrix(FHeader.TransformMatrix, FHeader.NDims, FHeader.NDims);
          cont := 3;
          For i := 1 To FHeader.NDims Do
            For j := 1 To FHeader.NDims Do
            Begin
              FHeader.TransformMatrix[i, j] := StrToFloat(parsed[cont]);
              inc(cont);
            End;
        End
        Else If parsed[1] = 'CenterOfRotation' Then
        Begin
          FHeader.instantiated := true;
          DelVector(FHeader.CenterOfRotation);
          DimVector(FHeader.CenterOfRotation, FHeader.NDims);
          For i := 1 To FHeader.NDims Do
            FHeader.CenterOfRotation[i] := StrToFloat(parsed[i + 2]);
        End
        Else If parsed[1] = 'ElementSpacing' Then
        Begin
          FHeader.instantiated := true;
          DelVector(FHeader.ElementSpacing);
          DimVector(FHeader.ElementSpacing, FHeader.NDims);
          For i := 1 To FHeader.NDims Do
            FHeader.ElementSpacing[i] := StrToFloat(parsed[i + 2]);
        End
        Else If parsed[1] = 'DimSize' Then
        Begin
          FHeader.instantiated := true;
          DelVector(FHeader.DimSize);
          DimVector(FHeader.DimSize, FHeader.NDims);
          For i := 1 To FHeader.NDims Do
            FHeader.DimSize[i] := Str2Int(parsed[i + 2]);
        End
        Else If parsed[1] = 'ElementSize' Then
        Begin
          FHeader.instantiated := true;
          DelVector(FHeader.ElementSize);
          DimVector(FHeader.ElementSize, FHeader.NDims);
          For i := 1 To FHeader.NDims Do
            FHeader.ElementSize[i] := StrToFloat(parsed[i + 2]);
        End;
      End;
    End;
  Until eof(f);
  If FHeader.NDims = 0 Then // Wrong file header
  Begin
    ClearHdr(false);
    lHdrOK := false;
  End
  Else If Not FHeader.instantiated Then // Ndims after vectors
  Begin
    ShowMessage
      ('All vector lines must be after NDims! Please check your header file');
    lHdrOK := false;
  End
  Else
  Begin
    lHdrOK := true;
  End;
  CloseFile(f);
  lImageFormatOK := (FHeader.ElementDataFile = 'LOCAL') Or
    FileExists(ExtractFilePath(filename) + FHeader.ElementDataFile);
  lDynStr := FHeader.Comment;
End;

Procedure TMetaImage.SaveToFile(filename: TFileName; Progreso: TGaugeFloat;
  lUnit: float);
Begin
  // El estandar MetaImage tiene como header un archivo mhd y como imagen un archivo raw
  ImageFileName := changeFileExt(filename, '.raw');
  FHeader.ElementMin := FHeader.ElementMin / lUnit;
  FHeader.ElementMax := FHeader.ElementMax / lUnit;
  If Write_hdr(changeFileExt(filename, '.mhd'), ImageFileName) Then
  Begin
    // lFileName := extractfilename(lFileName);
    Write_Image(ImageFileName, Progreso, lUnit);
  End;
End;

Function TMetaImage.Write_hdr(lHdrName, lImgName: TFileName): boolean;
Var
  f: textfile;
  line: String;
  i, j: integer;
  cont: float;
  Function writebool(bool: boolean): String;
  Begin
    If bool Then
      result := 'True'
    Else
      result := 'False';
  End;

Begin
  If FHeader.instantiated Then
  Begin
    AssignFile(f, lHdrName);
    SetLineBreakStyle(f, tlbsLF);
    Rewrite(f);
    If FHeader.Comment <> '' Then
      writeln(f, 'Comment = ' + FHeader.Comment);
    If FHeader.ObjectType <> '' Then
      writeln(f, 'ObjectType = ' + FHeader.ObjectType);
    If FHeader.ObjectSubType <> '' Then
      writeln(f, 'ObjectSubType = ' + FHeader.ObjectSubType);
    If FHeader.TransformType <> '' Then
      writeln(f, 'TransformType = ' + FHeader.TransformType);
    If FHeader.Name <> '' Then
      writeln(f, 'Name = ' + FHeader.Name);
    If FHeader.ID > 0 Then
      writeln(f, 'ID = ' + int2str(FHeader.ID));
    If FHeader.ParentID > 0 Then
      writeln(f, 'ParentID = ' + int2str(FHeader.ParentID));
    If FHeader.AcquisitionDate <> '' Then
      writeln(f, 'AcquisitionDate = ' + FHeader.AcquisitionDate);
    writeln(f, 'BinaryData = ' + writebool(FHeader.BinaryData));
    writeln(f, 'ElementByteOrderMSB = ' +
      writebool(FHeader.ElementByteOrderMSB));
    writeln(f, 'BinaryDataByteOrderMSB = ' +
      writebool(FHeader.BinaryDataByteOrderMSB));
    writeln(f, 'CompressedData = ' + writebool(FHeader.CompressedData));
    line := '';
    cont := 0;
    For i := 1 To 4 Do
    Begin
      line := line + FloatToStr(FHeader.Color[i]) + ' ';
      cont := cont + FHeader.Color[i];
    End;
    If cont > 0 Then
      writeln(f, 'Color = ' + Trim(line));
    If FHeader.AnatomicalOrientation <> '' Then
      writeln(f, 'AnatomicalOrientation = ' + FHeader.AnatomicalOrientation);
    If FHeader.HeaderSize > 0 Then
      writeln(f, 'HeaderSize = ' + int2str(FHeader.HeaderSize));
    If FHeader.Modality <> '' Then
      writeln(f, 'Modality = ' + FHeader.Modality);
    writeln(f, 'ElementMin = ' + FloatToStr(FHeader.ElementMin));
    writeln(f, 'ElementMax = ' + FloatToStr(FHeader.ElementMax));
    line := '';
    cont := 0;
    For i := 1 To 4 Do
    Begin
      line := line + int2str(FHeader.SequenceID[i]) + ' ';
      cont := cont + FHeader.SequenceID[i];
    End;
    If cont > 0 Then
      writeln(f, 'SequenceID = ' + Trim(line));
    If FHeader.ElementNumberOfChannels > 1 Then
      writeln(f, 'ElementNumberOfChannels = ' +
        int2str(FHeader.ElementNumberOfChannels));
    If FHeader.ElementType <> MET_NONE Then
      writeln(f, 'ElementType = ' + SMetaTypes[ord(FHeader.ElementType)]);

    If FHeader.NDims > 0 Then
    Begin
      writeln(f, 'NDims = ' + int2str(FHeader.NDims));
      If (Length(FHeader.DimSize) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          line := line + int2str(FHeader.DimSize[i]) + ' ';
        writeln(f, 'DimSize = ' + Trim(line));
      End;
      If (Length(FHeader.Position) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          line := line + FloatToStr(FHeader.Position[i]) + ' ';
        writeln(f, 'Position = ' + Trim(line));
      End;
      If (Length(FHeader.ElementSpacing) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          line := line + FloatToStr(FHeader.ElementSpacing[i]) + ' ';
        writeln(f, 'ElementSpacing = ' + Trim(line));
      End;
      If (Length(FHeader.ElementSize) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          line := line + FloatToStr(FHeader.ElementSize[i]) + ' ';
        writeln(f, 'ElementSize = ' + Trim(line));
      End;
      If (Length(FHeader.Orientation) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          For j := 1 To FHeader.NDims Do
            line := line + FloatToStr(FHeader.Orientation[i, j]) + ' ';
        writeln(f, 'Orientation = ' + Trim(line));
      End;
      If (Length(FHeader.TransformMatrix) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          For j := 1 To FHeader.NDims Do
            line := line + FloatToStr(FHeader.TransformMatrix[i, j]) + ' ';
        writeln(f, 'TransformMatrix = ' + Trim(line));
      End;
      If (Length(FHeader.CenterOfRotation) - 1 = FHeader.NDims) Then
      Begin
        line := '';
        For i := 1 To FHeader.NDims Do
          line := line + FloatToStr(FHeader.CenterOfRotation[i]) + ' ';
        writeln(f, 'CenterOfRotation = ' + Trim(line));
      End;
    End;
    // This must go at the end of the file
    If ImageFileName <> '' Then
      writeln(f, 'ElementDataFile = ' + ExtractFileName(ImageFileName))
    Else
      writeln(f, 'ElementDataFile = LOCAL');

    CloseFile(f);
  End;
  result := true;
End;

Function LeeMetaImage(lFileName: TFileName; Var Progreso: TGaugeFloat)
  : TInterfile;
Var
  tempMImage: TMetaImage;
Begin
  tempMImage := TMetaImage.Create(lFileName, Progreso);
  result := TInterfile.Create(tempMImage.Data, false);
  result.Image := tempMImage.Image;
  result.ImageFileName := ExtractFilePath(lFileName) + tempMImage.ImageFileName;
  tempMImage.datacreated := false;
  tempMImage.Free;
End;

End.
