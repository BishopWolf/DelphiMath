/// <summary>
/// Unit uAnalyze handles Analyze medical images Created by Alex Vergara Gil
/// based on ezDICOM by Chris Rorden. Changed char definitions to AnsiChar to
/// accomplish standard char size of 1 byte which is different in Delphi
/// SizeOf(char) returns 2 while SizeOf(AnsiChar) returns 1
/// </summary>
/// <remarks>
/// Created sept 29, 2012
/// </remarks>
Unit uAnalyze;

Interface

Uses
  Windows, Dialogs, Controls, classes, SysUtils, GaugeFloat, uConstants, utypes,
  uinterfile, umedicalImage;

Type
  /// <summary>
  /// Standard header of an Analyze image
  /// </summary>
  /// <remarks>
  /// The standard requires char values of 1 byte (Delphi AnsiChar),
  /// the original code declares it as char but in Delphi the char variable
  /// has 2 bytes.
  /// </remarks>
  AHdr = Packed Record
    HdrSz: longint;
    Data_Type: Array [1 .. 10] Of AnsiChar;
    db_name: Array [1 .. 18] Of AnsiChar;
    extents: longint; (* 32 + 4 *)
    session_error: smallint; (* 36 + 2 *)
    regular: AnsiChar; (* 38 + 1 *)
    hkey_un0: AnsiChar; (* 39 + 1 *)
    dim: Array [0 .. 7] Of smallint; (* 0 + 16 *)
    vox_units: Array [1 .. 4] Of AnsiChar; (* 16 + 4 *)
    (* up to 3 characters for the voxels units label; i.e. mm., um., cm. *)
    cal_units: Array [1 .. 8] Of AnsiChar; (* 20 + 4 *)
    (* up to 7 characters for the calibration units label; i.e. HU *)
    unused1: smallint; (* 24 + 2 *)
    datatype: smallint; (* 30 + 2 *)
    (*
      datatype = 1  means binary type
      datatype = 2  means integer 8 bit type
      datatype = 4  means integer 16 bit type
      datatype = 8  means integer 32 bit type
      datatype = 16 means float 32 bit type
      datatype = 32 means float 64 bit type
    *)
    bitpix: smallint; (* 32 + 2 *)
    dim_un0: smallint; (* 34 + 2 *)
    pixdim: Array [1 .. 8] Of single; (* 36 + 32 *)
    (*
      pixdim[] specifies the voxel dimensions:
      pixdim[1] - voxel width  {in SPM [2]}
      pixdim[2] - voxel height  {in SPM [3]}
      pixdim[3] - interslice distance {in SPM [4]}
      ..etc
    *)
    vox_offset: single; (* 68 + 4 *)
    roi_scale: single; (* 72 + 4 *)
    funused1: single; (* 76 + 4 *)
    funused2: single; (* 80 + 4 *)
    cal_max: single; (* 84 + 4 *)
    cal_min: single; (* 88 + 4 *)
    compressed: longint; (* 92 + 4 *)
    verified: longint; (* 96 + 4 *)
    glmax, glmin: longint; (* 100 + 8 *)
    descrip: Array [1 .. 80] Of AnsiChar; (* 0 + 80 *)
    aux_file: Array [1 .. 24] Of AnsiChar; (* 80 + 24 *)
    orient: AnsiChar; (* 104 + 1 *)
    (* originator: array [1..10] of char;                   (* 105 + 10 *)
    originator: Array [1 .. 5] Of smallint; (* 105 + 10 *)
    generated: Array [1 .. 10] Of AnsiChar; (* 115 + 10 *)
    scannum: Array [1 .. 10] Of AnsiChar;
    { array [1..10] of char {extended?? }                       (* 125 + 10 *)
    patient_id: Array [1 .. 10] Of AnsiChar; (* 135 + 10 *)
    exp_date: Array [1 .. 10] Of AnsiChar; (* 145 + 10 *)
    exp_time: Array [1 .. 10] Of AnsiChar; (* 155 + 10 *)
    hist_un0: Array [1 .. 3] Of AnsiChar; (* 165 + 3 *)
    views: longint; (* 168 + 4 *)
    vols_added: longint; (* 172 + 4 *)
    start_field: longint; (* 176 + 4 *)
    field_skip: longint; (* 180 + 4 *)
    omax, omin: longint; (* 184 + 8 *)
    smax, smin: longint; (* 192 + 8 *)
    { } End;

  TAnalyze = Class(TInterfile) // inherits from uInterfile
  Private
    Procedure ClearHdr(Hdr: AHdr);
    Procedure SwapBytes(Hdr: AHdr);
  Protected
    /// <summary>
    /// Reads an interfile header and assigns ImageFileName
    /// </summary>
    Procedure Read_hdr(Var lHdrOK, lImageFormatOK: boolean; Var lDynStr: String;
      lFileName: TFilename); Reintroduce;
  Public
    Constructor Create(HeaderName: TFilename; Progreso: TGaugeFloat = Nil;
      readData: boolean = true); Overload;
    Function Write_hdr(lHdrName, lImgName: TFilename): boolean; Reintroduce;
    Procedure SaveToFile(FileName: TFilename; Progreso: TGaugeFloat;
      lUnit: Float = 1); Reintroduce;

    /// <summary>
    /// Convert to Interfile destroying the instance
    /// </summary>
    /// <remarks>
    /// must free the instance after calling this procedure;
    /// </remarks>
    Function ToInterfile: TInterfile;
  End;

  /// <summary>
  /// function to read an Analyze Image as Interfile
  /// </summary>
Function LeeAnalyze(lFileName: TFilename; Var Progreso: TGaugeFloat)
  : TInterfile;

Implementation

Uses uoperations, ustrings, ubyteorder;

{ TAnalyze }

Procedure TAnalyze.SwapBytes(Hdr: AHdr);
Var
  // l10 : array [1..10] of byte;
  lInc: integer;

Begin
  With Hdr Do
  Begin
    swap4(HdrSz);
    swap4(extents); (* 32 + 4 *)
    Swap2(session_error); (* 36 + 2 *)
    For lInc := 0 To 7 Do
      Swap2(dim[lInc]); (* 0 + 16 *)
    Swap2(unused1); (* 24 + 2 *)
    Swap2(datatype); (* 30 + 2 *)
    Swap2(bitpix); (* 32 + 2 *)
    Swap2(dim_un0); (* 34 + 2 *)
    For lInc := 1 To 4 Do
      swap4r(pixdim[lInc]); (* 36 + 32 *)
    swap4r(vox_offset);
    { roi scale = 1 }
    swap4r(roi_scale);
    swap4r(funused1); (* 76 + 4 *)
    swap4r(funused2); (* 80 + 4 *)
    swap4r(cal_max); (* 84 + 4 *)
    swap4r(cal_min); (* 88 + 4 *)
    swap4(compressed); (* 92 + 4 *)
    swap4(verified); (* 96 + 4 *)
    swap4(glmax);
    swap4(glmin); (* 100 + 8 *)
    orient := chr(0); (* 104 + 1 *)
    (* originator: array [1..10] of char;                   (* 105 + 10 *)
    For lInc := 1 To 5 Do
      Swap2(originator[lInc]); (* 105 + 10 *)
    swap4(views); (* 168 + 4 *)
    swap4(vols_added); (* 172 + 4 *)
    swap4(start_field); (* 176 + 4 *)
    swap4(field_skip); (* 180 + 4 *)
    swap4(omax);
    swap4(omin); (* 184 + 8 *)
    swap4(smax);
    swap4(smin); (* 192 + 8 *)
  End; { with }
End;

Function FSize(lFName: String): longint;
Var
  SearchRec: TSearchRec;
Begin
  FSize := 0;
  If Not FileExists(lFName) Then
    exit;
  FindFirst(lFName, faAnyFile, SearchRec);
  FSize := SearchRec.size;
  FindClose(SearchRec);
End;

Procedure TAnalyze.ClearHdr(Hdr: AHdr);
Var
  lInc: byte;
Begin
  With Hdr Do
  Begin
    { set to 0 }
    HdrSz := sizeof(AHdr);
    For lInc := 1 To 10 Do
      Data_Type[lInc] := chr(0);
    For lInc := 1 To 18 Do
      db_name[lInc] := chr(0);
    extents := 0; (* 32 + 4 *)
    session_error := 0; (* 36 + 2 *)
    regular := 'r' { chr(0) }; (* 38 + 1 *)
    hkey_un0 := chr(0);
    dim[0] := 4; (* 39 + 1 *)
    For lInc := 1 To 7 Do
      dim[lInc] := 0; (* 0 + 16 *)
    For lInc := 1 To 4 Do
      vox_units[lInc] := chr(0); (* 16 + 4 *)
    For lInc := 1 To 4 Do
      cal_units[lInc] := chr(0); (* 20 + 4 *)
    unused1 := 0; (* 24 + 2 *)
    datatype := 0; (* 30 + 2 *)
    bitpix := 0; (* 32 + 2 *)
    dim_un0 := 0; (* 34 + 2 *)
    For lInc := 1 To 4 Do
      pixdim[lInc] := 2.0; (* 36 + 32 *)
    vox_offset := 0.0;
    roi_scale := 0.00392157 { 1.1 };
    funused1 := 0.0; (* 76 + 4 *)
    funused2 := 0.0; (* 80 + 4 *)
    cal_max := 0.0; (* 84 + 4 *)
    cal_min := 0.0; (* 88 + 4 *)
    compressed := 0; (* 92 + 4 *)
    verified := 0; (* 96 + 4 *)
    glmax := 0;
    glmin := 0; (* 100 + 8 *)
    For lInc := 1 To 80 Do
      Hdr.descrip[lInc] := chr(0); { 80 spaces }
    For lInc := 1 To 24 Do
      Hdr.aux_file[lInc] := chr(0); { 24 spaces }
    orient := chr(0); (* 104 + 1 *)
    (* originator: array [1..10] of char;                   (* 105 + 10 *)
    For lInc := 1 To 5 Do
      originator[lInc] := 0; (* 105 + 10 *)
    For lInc := 1 To 10 Do
      generated[lInc] := chr(0); (* 115 + 10 *)
    For lInc := 1 To 10 Do
      scannum[lInc] := chr(0);
    For lInc := 1 To 10 Do
      patient_id[lInc] := chr(0); (* 135 + 10 *)
    For lInc := 1 To 10 Do
      exp_date[lInc] := chr(0); (* 135 + 10 *)
    For lInc := 1 To 10 Do
      exp_time[lInc] := chr(0); (* 135 + 10 *)
    For lInc := 1 To 3 Do
      hist_un0[lInc] := chr(0); (* 135 + 10 *)
    views := 0; (* 168 + 4 *)
    vols_added := 0; (* 172 + 4 *)
    start_field := 0; (* 176 + 4 *)
    field_skip := 0; (* 180 + 4 *)
    omax := 0;
    omin := 0; (* 184 + 8 *)
    smax := 0;
    smin := 0; (* 192 + 8 *)
    { below are standard settings which are not 0 }
    bitpix := 8; { 8 bits per pixel, e.g. unsigned char }
    datatype := 2; { unsigned char }
    vox_offset := 0;
    originator[1] := 0;
    originator[2] := 0;
    originator[3] := 0;
    dim[1] := 91;
    dim[2] := 109;
    dim[3] := 91;
    dim[4] := 1; { n vols }
    glmin := 0;
    glmax := 255; { critical! }
    roi_scale := 0.00392157 { 1.1 };
  End;
End;

Constructor TAnalyze.Create(HeaderName: TFilename; Progreso: TGaugeFloat;
  readData: boolean);
Var
  HdrOK, ImgOK: boolean;
  lDynStr: String;
  lFileName: TFilename;
Begin
  lFileName := HeaderName;
  datacreated := false;
  Read_hdr(HdrOK, ImgOK, lDynStr, lFileName);
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

Procedure TAnalyze.Read_hdr(Var lHdrOK, lImageFormatOK: boolean;
  Var lDynStr: String; lFileName: TFilename);
Var
  F: File;
  lFSz: longint;
  Hdr: AHdr;
  lHdrSz: longint;
Begin
  // result := false;
  lImageFormatOK := false;
  lHdrOK := false;
  lDynStr := '';
  Data.RunLengthEncoding := false;
  Data.JPEGlosslessCpt := false;
  Data.JPEGlossyCpt := false;
  Data.PlanarConfig := 1; // only used in RGB values
  Data.GenesisCpt := false;
  Data.GenesisPackHdr := 0;
  Data.SamplesPerPixel := 1;
  Data.WindowCenter := 0;
  Data.WindowWidth := 0;
  Data.monochrome := 2; { most common }
  Data.XYZmm[1] := 1;
  Data.XYZmm[2] := 1;
  Data.XYZmm[3] := 1;
  Data.XYZdim[1] := 1;
  Data.XYZdim[2] := 1;
  Data.XYZdim[3] := 1;
  Data.ImageStart := 0;
  Data.Little_Endian := 1;
  Data.Float := false;
  If Not FileExists(lFileName) Then
    exit;
  lFSz := FSize(lFileName);
  If (lFSz) <> sizeof(AHdr) Then
  Begin
    { CloseFile(F); }
    {ShowMessage('This header file is the wrong size to be in Analyze format.' +
      ' Required: ' + inttostr(sizeof(AHdr)) + '  Selected:' + inttostr(lFSz));}
    exit;
  End;
  AssignFile(F, lFileName);
  FileMode := 0; { Set file access to read only }
  Reset(F, 1);
{$I+}
  If ioresult <> 0 Then
    ShowMessage('Potential error in reading Analyze header.' +
      inttostr(ioresult));
  BlockRead(F, Hdr { Buffer^ } , lFSz);
  CloseFile(F);
  If (ioresult <> 0) Then
    exit;
  FileMode := 2;
  lHdrSz := Hdr.HdrSz;
  swap4(lHdrSz);
  If Hdr.HdrSz = sizeof(AHdr) Then
  Begin
    Data.Little_Endian := 1;
  End
  Else If sizeof(AHdr) = lHdrSz Then
  Begin
    Data.Little_Endian := 0;
    SwapBytes(Hdr);
  End
  Else
  Begin
    ShowMessage('This software can not read this header file.' +
      'The header file is not in Analyze format.');
    CloseFile(F);
    exit;
  End;
  // result := true;
  lImageFormatOK := true;
  lHdrOK := true;
  If (Hdr.bitpix = 0) Then
    Case Hdr.datatype Of
      1: // datatype = 1  means binary type
        Hdr.bitpix := 1;
      2, 3: // datatype = 2  means integer 8 bit type
        Hdr.bitpix := 8;
      4, 5: // datatype = 4  means integer 16 bit type
        Hdr.bitpix := 16;
      8, 9: // datatype = 8  means integer 32 bit type
        Hdr.bitpix := 32;
      16: // datatype = 16 means float 32 bit type
        Begin
          Hdr.bitpix := 32;
          Data.Float := true;
        End;
      32: // datatype = 32 means float 64 bit type
        Begin
          Hdr.bitpix := 64;
          Data.Float := true;
        End;
    Else
      Begin
        ShowMessage('This software can not read this header file.' +
          'The header file is not in Analyze format.');
        CloseFile(F);
        exit;
      End;
    End;
  Data.XYZdim[1] := Hdr.dim[1];
  Data.XYZdim[2] := Hdr.dim[2];
  Data.XYZdim[3] := Hdr.dim[3];
  Data.IntenScale := Hdr.roi_scale;
  Data.XYZmm[1] := Hdr.pixdim[2];
  Data.XYZmm[2] := Hdr.pixdim[3];
  Data.XYZmm[3] := Hdr.pixdim[4]; { }
  lDynStr := 'Analyze format' + kCR + 'XYZ dim:' + inttostr(Data.XYZdim[1]) +
    '/' + inttostr(Data.XYZdim[2]) + '/' + inttostr(Data.XYZdim[3]) + kCR +
    'XYZ mm:' + floattostrf(Data.XYZmm[1], ffFixed, 8, 2) + '/' +
    floattostrf(Data.XYZmm[2], ffFixed, 8, 2) + '/' + floattostrf(Data.XYZmm[3],
    ffFixed, 8, 2) + kCR + 'Bits per pixel: ' + inttostr(Hdr.bitpix);
  Data.Allocbits_per_pixel := Hdr.bitpix;
  Data.Storedbits_per_pixel := Hdr.bitpix;
  If Hdr.datatype >= 16 Then
  Begin
    // Data.Float := true; Esto ya se hizo
    lDynStr := lDynStr + kCR + 'Floating point data';
  End
  Else
    Data.signed := Not(Hdr.datatype And $1 = 1);
  If Hdr.bitpix = 24 Then
  Begin
    Data.Allocbits_per_pixel := 8;
    Data.Storedbits_per_pixel := 8;
    Data.SamplesPerPixel := 3;
    Data.PlanarConfig := 0;
  End;

  Data.ImageStart := round(Hdr.vox_offset);
  ImageFileName := ExtractFilePath(lFileName) +
    ParseFileName(ExtractFileName(lFileName)) + '.img';
  (* if not fileexists(lFilename) then begin
    lImgOK := false;
    Showmessage('Unable to find the Analyze image named '+lFilename);
    exit;
    end; *)
End;

Function TAnalyze.Write_hdr(lHdrName, lImgName: TFilename): boolean;
Var
  lF: File;
  lStr: String;
  lHdr: AHdr;
  lSwapBytes: boolean;
Begin
  lStr := ExtractFilePath(lHdrName) + ParseFileName(ExtractFileName(lHdrName)
    ) + '.hdr';
  { if (sizeof(AHdr)> DiskFree(lStr)) then begin
    ShowMessage('There is not enough free space on the destination disk to save the header. '+lStr);
    result := false;
    exit;
    end; }
  Result := true;
  ClearHdr(lHdr);
  If Data.Little_Endian = 1 Then
    lSwapBytes := false
  Else
    lSwapBytes := true;
  lHdr.dim[1] := Data.XYZdim[1];
  lHdr.dim[2] := Data.XYZdim[2];
  lHdr.dim[3] := Data.XYZdim[3];
  lHdr.pixdim[2] := Data.XYZmm[1];
  lHdr.pixdim[3] := Data.XYZmm[2];
  lHdr.pixdim[4] := Data.XYZmm[3]; { }
  // lHdr.bitpix := Data.Allocbits_per_pixel;
  lHdr.bitpix := Data.Storedbits_per_pixel;
  lHdr.vox_offset := Data.ImageStart;
  lHdr.roi_scale := Data.IntenScale;
  lHdr.glmin := round(Data.MinIntensity);
  lHdr.glmax := round(Data.MaxIntensity);
  Case lHdr.bitpix Of
    1:
      lHdr.datatype := 1; { binary }
    8:
      If Data.signed Then
        lHdr.datatype := 2 { 8bit int }
      Else
        lHdr.datatype := 3; { 8bit uint }
    16:
      If Data.signed Then
        lHdr.datatype := 4 { 16bit int }
      Else
        lHdr.datatype := 5; { 16bit uint }
    32:
      If Not Data.Float Then
      Begin
        If Data.signed Then
          lHdr.datatype := 8 { 32bit int }
        Else
          lHdr.datatype := 9; { 32bit uint }
      End
      Else
        lHdr.datatype := 16; { 32bit float }
    64:
      If Not Data.Float Then
        lHdr.datatype := 18 { 64bit int }  // Never used
      Else
        lHdr.datatype := 32; { 64bit float }
  Else
    Begin
      ShowMessage('Unable to save Analyze header ' + lHdrName + kCR +
        'Use MRIcro to convert this image (MCID can only convert files with 8/16/32 bits per voxel.');
      // result := false;
      exit;
    End;
    // 4: Hdr.datatype := 16;{float=32bits}
    // 5: Hdr.datatype := 32; {float=64bits}
  End;

  If lSwapBytes Then
    SwapBytes(lHdr); { swap to sun format }
  FileMode := 2; // read/write
  AssignFile(lF, lStr); { WIN }
  Rewrite(lF, sizeof(AHdr));
  BlockWrite(lF, lHdr, 1 { , NumWritten } );
  CloseFile(lF);
End;

Procedure TAnalyze.SaveToFile(FileName: TFilename; Progreso: TGaugeFloat;
  lUnit: Float);
Var
  lFileName: String;
Begin
  // El estandar analyze tiene como header un archivo hdr y como imagen un archivo img
  lFileName := changeFileExt(FileName, '.img');
  If Write_hdr(changeFileExt(FileName, '.hdr'), lFileName) Then
  Begin
    // lFileName := ExtractFileName(lFileName);
    Write_Image(lFileName, Progreso, lUnit);
  End;
End;

Function TAnalyze.ToInterfile: TInterfile;
Begin
  Result := TInterfile.Create(self, true);
  If Result.Data.IntenScale = 0 Then
    Result.Data.IntenScale := 1;
  Result.ImageFileName := ImageFileName;
End;

Function LeeAnalyze(lFileName: TFilename; Var Progreso: TGaugeFloat)
  : TInterfile;
Var
  tempAnalyze: TAnalyze;
Begin
  tempAnalyze := TAnalyze.Create(lFileName, Progreso);
  Result := tempAnalyze.ToInterfile;
  tempAnalyze.Free;
End;

End.
