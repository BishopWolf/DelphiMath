/// <summary>
/// <para>
/// Unit uInterfile handles Interfile medical images
/// </para>
/// <para>
/// Created by Alex Vergara Gil based on ezDICOM by Chris Rorden
/// </para>
/// </summary>
/// <remarks>
/// <para>
/// Created sept 29, 2012
/// </para>
/// <para>
/// Handles LittleEndian and BigEndian number formats
/// </para>
/// </remarks>
Unit uInterfile;

Interface

Uses
  Windows, Dialogs, Controls, classes, SysUtils, GaugeFloat, uConstants, utypes,
  uMedicalImage;

Type

  /// <summary>
  /// Interfile Medical Image Handler
  /// </summary>
  TInterfile = Class(TMedicalImage)
  Private
    FImageFileName: TFileName;
    Procedure SetImageFileName(Const Value: TFileName);
  Protected
    /// <summary>
    /// Writes the Image in the FileName file
    /// </summary>
    Procedure Write_Image(FileName: TFileName; Progreso: TGaugeFloat;
      lUnit: Float);
    /// <summary>
    /// Read the header located in the lFileName file and sets the ImageFileName variable
    /// </summary>
    Procedure Read_hdr(Var lHdrOK, lImageFormatOK: boolean; Var lDynStr: String;
      lFileName: TFileName);
    /// <summary>
    /// Reads the Image located in the ImageFileName file
    /// </summary>
    Procedure Read_Image(path: String; Progreso: TGaugeFloat);
  Public
    /// <summary>
    /// Writes a header for a raw image converting it into interfile utterly
    /// </summary>
    Function Write_hdr(lHdrName, lImgName: TFileName): boolean;

    /// <summary>
    /// File location of the image
    /// </summary>
    Property ImageFileName: TFileName Read FImageFileName
      Write SetImageFileName;

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

    /// <summary>
    /// Creates an Interfile Image in the hard disk
    /// </summary>
    Procedure SaveToFile(FileName: TFileName; Progreso: TGaugeFloat;
      lUnit: Float = 1);
  End;

  /// <summary>
  /// Integer instance of an interfile
  /// </summary>
  TIntInterfile = Class(TInterfile)
  Private
    Function GetElemento(m, n, o: integer): integer;
    Procedure SetElemento(m, n, o: integer; Const Value: integer);
  Public
    Image: T3DIntMatrix;
    Constructor Create(Another: TIntInterfile); Overload;
    Constructor Create(Another: TInterfile); Overload;
    Constructor Create(Another: TMedicalImageData;
      Initialize: boolean = true); Overload;
    Property Elemento[m, n, o: integer]: integer Read GetElemento
      Write SetElemento; Default;
  End;

Function LeeMedicalImage_asInterfile(FileName: TFileName;
  Data: TMedicalImageData; Progreso: TGaugeFloat;
  IsRaw, UseData, readimage: boolean): TInterfile;

Implementation

Uses Forms, ustrings, ufileoperations, umemory, uinterpolation, uoperations,
  uround, ubyteorder, uMetaImage, uAnalyze, uDICOM;

Resourcestring
  StrErrorInInputBytes = 'Error in input bytes';

Function TInterfile.Write_hdr(lHdrName, lImgName: TFileName): boolean;
Var
  lTextFile: textfile;
  // creates interfile text header "lHdrName" that points to the image "lImgName")
  // pass pDICOMdata that contains the relevant image details
Begin
  If Not(Data.Allocbits_per_pixel In [8, 16, 32, 64, 80]) Then
  Begin
    showmessage
      ('Can only create Interfile headers for 8, 16, 32, 64 or 80 bit images.');
  End;
  If fileexists(lHdrName) Then
  Begin
    If MessageDlg(format('El fichero %s existe, ¿desea sobreescribirlo?',
      [lHdrName]), mtConfirmation, mbYesNo, 0) = mrNo Then
    Begin
      result := false;
      exit;
    End;
  End;
  assignfile(lTextFile, lHdrName);
  SetLineBreakStyle(lTextFile, tlbsLF);
  rewrite(lTextFile);
  writeln(lTextFile, '!INTERFILE :=');
  writeln(lTextFile, '!imaging modality:=nucmed');
  writeln(lTextFile, '!originating system:=Windows');
  writeln(lTextFile, '!version of keys:=3.3');
  writeln(lTextFile, 'conversion program := MCID');
  writeln(lTextFile, 'program author := Alex Vergara Gil');
  writeln(lTextFile, '!GENERAL DATA:=');
  writeln(lTextFile, format('!data offset in bytes:=%d',
    [0 { Data.ImageStart } ]));
  writeln(lTextFile, format('!name of data file:=%s',
    [extractfilename(lImgName)]));
  writeln(lTextFile, 'data compression := none');
  writeln(lTextFile, 'data encode := none');
  writeln(lTextFile, format('Rescale Intercept:=%4.3f', [Data.IntenIntercept]));
  writeln(lTextFile, format('Rescale Slope:=%4.3f', [Data.IntenScale]));
  writeln(lTextFile, format('patient name := %s', [Data.PatientName]));
  writeln(lTextFile, format('!patient ID := %s', [Data.PatientID]));
  writeln(lTextFile, format('!study ID :=%s', [Data.StudyID { DOSIS_3D } ]));
  writeln(lTextFile, '!GENERAL IMAGE DATA :=');
  If Data.little_endian = 1 Then
    writeln(lTextFile, 'imagedata byte order := LITTLEENDIAN')
  Else
    writeln(lTextFile, 'imagedata byte order := BIGENDIAN');
  writeln(lTextFile, format('!matrix size [1] := %d', [Data.XYZdim[1]]));
  writeln(lTextFile, format('!matrix size [2] := %d', [Data.XYZdim[2]]));
  writeln(lTextFile, format('!matrix size [3] := %d', [Data.XYZdim[3]]));
  writeln(lTextFile, format('!matrix size [1] ORIGINAL:= %d',
    [Data.XYZori[1]]));
  writeln(lTextFile, format('!matrix size [2] ORIGINAL:= %d',
    [Data.XYZori[2]]));
  writeln(lTextFile, format('!matrix size [3] ORIGINAL:= %d',
    [Data.XYZori[3]]));
  writeln(lTextFile,
    format('!Coordenada Relativa [1] respecto a matriz ORIGINAL:= %d',
    [Data.XYZstart[1]]));
  writeln(lTextFile,
    format('!Coordenada Relativa [2] respecto a matriz ORIGINAL:= %d',
    [Data.XYZstart[2]]));
  writeln(lTextFile,
    format('!Coordenada Relativa [3] respecto a matriz ORIGINAL:= %d',
    [Data.XYZstart[3]]));
  If Data.Float Then
  Begin
    Case Data.Allocbits_per_pixel Of
      32:
        writeln(lTextFile, '!number format := short float');
      64:
        writeln(lTextFile, '!number format := float');
      80:
        writeln(lTextFile, '!number format := extended');
    Else
      writeln(lTextFile, '!number format := NAN');
    End;
  End
  Else
  Begin
    Case Data.Allocbits_per_pixel Of
      8:
        If Data.signed Then
          writeln(lTextFile, '!number format := short int')
        Else
          writeln(lTextFile, '!number format := byte');
      16, 32:
        If Data.signed Then
          writeln(lTextFile, '!number format := signed integer')
        Else
          writeln(lTextFile, '!number format := unsigned integer');
    Else
      writeln(lTextFile, '!number format := NAN');
    End;
  End;
  writeln(lTextFile, format('!number of bytes per pixel := %d',
    [Data.Allocbits_per_pixel Div 8]));
  writeln(lTextFile, 'scaling factor (mm/pixel) [1] :=' +
    floattostrf(Data.XYZmm[1], ffFixed, 7, 7));
  writeln(lTextFile, 'scaling factor (mm/pixel) [2] :=' +
    floattostrf(Data.XYZmm[2], ffFixed, 7, 7));
  writeln(lTextFile, 'scaling factor (mm/pixel) [3] :=' +
    floattostrf(Data.XYZmm[3], ffFixed, 7, 7));
  writeln(lTextFile, format('!number of slices := %d', [Data.XYZdim[3]]));
  writeln(lTextFile, format('!total number of images := %d', [Data.XYZdim[3]]));
  writeln(lTextFile, 'slice thickness (pixels) := ' + floattostrf(Data.XYZmm[3],
    ffFixed, 7, 7));
  writeln(lTextFile, '!END OF INTERFILE:=');
  closefile(lTextFile);
  result := true;
End; (* *)

Procedure TInterfile.Read_hdr(Var lHdrOK, lImageFormatOK: boolean;
  Var lDynStr: String; lFileName: TFileName);
Label 333;
Const
  UNIXeoln = chr(10);
Var
  lTmpStr, lInStr, lUpCaseStr: String;
  lHdrEnd, lFloat, lUnsigned: boolean;
  lPos, lLen, FileSz, linPos: integer;
  fp: File;
  lCharRA: Bytep;
  Function readInterFloat: real;
  Var
    lStr: String;
  Begin
    lStr := '';
    If lPos > lLen Then
    Begin
      lPos := pos(':=', lInStr) + 2;
      lLen := Length(lInStr);
    End;
    While (lPos <= lLen) And (lInStr[lPos] <> ';') Do
    Begin
      If charinset(lInStr[lPos], ['+', '-', 'e', 'E', '.', '0' .. '9']) Then
        lStr := lStr + (lInStr[lPos]);
      inc(lPos);
    End;
    Try
      result := str2float(lStr);
    Except
      On EConvertError Do
      Begin
        showmessage('Unable to convert the string ' + lStr + ' to a number');
        result := 1;
        exit;
      End;
    End; { except }
  End;
  Function readInterStr: String;
  Var
    lStr: String;
  Begin
    lStr := '';
    While (lPos <= lLen) And (lInStr[lPos] = ' ') Do
    Begin
      inc(lPos);
    End;
    While (lPos <= lLen) And (lInStr[lPos] <> ';') Do
    Begin
      lStr := lStr + upcase(lInStr[lPos]); // zebra upcase
      inc(lPos);
    End;
    result := lStr;
  End; // interstr func

Begin
  lHdrOK := false;
  lFloat := false;
  lUnsigned := false;
  lImageFormatOK := true;
  clear(Data);
  lDynStr := '';
  FileMode := 0; // set to readonly
  assignfile(fp, lFileName);
  Reset(fp, 1);
  FileSz := FileSize(fp);
  lHdrEnd := false;
  // lDicomData.ImageStart := FileSz;
  GetMem(lCharRA, FileSz + 1);
  BlockRead(fp, lCharRA^, FileSz, linPos);
  If linPos <> FileSz Then
    showmessage('Disk error: Unable to read full input file.');
  linPos := 1;
  closefile(fp);
  FileMode := 2; // set to read/write
  Repeat
    lInStr := '';
    While (linPos < FileSz) And (lCharRA[linPos] <> ord(kCR)) And
      (lCharRA[linPos] <> ord(UNIXeoln)) Do
    Begin
      lInStr := lInStr + chr(lCharRA[linPos]);
      inc(linPos);
    End;
    inc(linPos); // read EOLN
    lLen := Length(lInStr);
    lPos := 1;
    lUpCaseStr := '';
    While (lPos <= lLen) And (lInStr[lPos] <> ';') And (lInStr[lPos] <> '=') And
      (lUpCaseStr <> 'INTERFILE') Do
    Begin
      If charinset(lInStr[lPos], ['[', ']', '(', ')', '/', '+', '-',
        { ' ', } '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
        lUpCaseStr := lUpCaseStr + upcase(lInStr[lPos]);
      inc(lPos);
    End;
    inc(lPos); { read equal sign in := statement }
    If lUpCaseStr = 'INTERFILE' Then
    Begin
      lHdrOK := true;
      Data.little_endian := 0; // Interfile is bigendian
    End;
    If lUpCaseStr = 'DATASTARTINGBLOCK' Then
      Data.ImageStart := 2048 * round(readInterFloat);
    If lUpCaseStr = 'RESCALEINTERCEPT' Then
      Data.IntenIntercept := readInterFloat;
    If lUpCaseStr = 'RESCALESLOPE' Then
      Data.IntenScale := readInterFloat;
    If lUpCaseStr = 'DATAOFFSETINBYTES' Then
      Data.ImageStart := round(readInterFloat);
    If (lUpCaseStr = 'MATRIXSIZE[1]') Or (lUpCaseStr = 'MATRIXSIZE[X]') Then
      Data.XYZdim[1] := round(readInterFloat);
    If (lUpCaseStr = 'MATRIXSIZE[2]') Or (lUpCaseStr = 'MATRIXSIZE[Y]') Then
      Data.XYZdim[2] := round(readInterFloat);
    If (lUpCaseStr = 'MATRIXSIZE[3]') Or (lUpCaseStr = 'MATRIXSIZE[Z]') Or
      (lUpCaseStr = 'NUMBEROFSLICES') Or
      (lUpCaseStr = 'TOTALNUMBEROFIMAGES') Then
      Data.XYZdim[3] := round(readInterFloat);
    If (lUpCaseStr = 'MATRIXSIZE[1]ORIGINAL') Or
      (lUpCaseStr = 'MATRIXSIZE[X]ORIGINAL') Then
      Data.XYZori[1] := round(readInterFloat);
    If (lUpCaseStr = 'MATRIXSIZE[2]ORIGINAL') Or
      (lUpCaseStr = 'MATRIXSIZE[Y]ORIGINAL') Then
      Data.XYZori[2] := round(readInterFloat);
    If (lUpCaseStr = 'MATRIXSIZE[3]ORIGINAL') Or
      (lUpCaseStr = 'MATRIXSIZE[Z]ORIGINAL') Then
      Data.XYZori[3] := round(readInterFloat);
    If (lUpCaseStr = 'COORDENADARELATIVA[1]RESPECTOAMATRIZORIGINAL') Or
      (lUpCaseStr = 'COORDENADARELATIVA[X]RESPECTOAMATRIZORIGINAL') Then
      Data.XYZstart[1] := round(readInterFloat);
    If (lUpCaseStr = 'COORDENADARELATIVA[2]RESPECTOAMATRIZORIGINAL') Or
      (lUpCaseStr = 'COORDENADARELATIVA[Y]RESPECTOAMATRIZORIGINAL') Then
      Data.XYZstart[2] := round(readInterFloat);
    If (lUpCaseStr = 'COORDENADARELATIVA[3]RESPECTOAMATRIZORIGINAL') Or
      (lUpCaseStr = 'COORDENADARELATIVA[Z]RESPECTOAMATRIZORIGINAL') Then
      Data.XYZstart[3] := round(readInterFloat);
    If lUpCaseStr = 'PATIENTNAME' Then
      Data.PatientName := readInterStr;
    If lUpCaseStr = 'PATIENTID' Then
      Data.PatientID := readInterStr;
    If lUpCaseStr = 'STUDYID' Then
      Data.StudyID := readInterStr;
    // if lUpCaseStr ='TOTALNUMBEROFIMAGES' then lDICOMdata.ImageSz:=round(readInterFloat);
    If lUpCaseStr = 'IMAGEDATABYTEORDER' Then
    Begin
      If readInterStr = 'LITTLEENDIAN' Then
        Data.little_endian := 1
      Else
        Data.little_endian := 0;
    End;
    If lUpCaseStr = 'NUMBERFORMAT' Then
    Begin
      lTmpStr := readInterStr;
      If (lTmpStr = 'ASCII') Or (lTmpStr = 'BIT') Then
      Begin
        lHdrOK := false;
        showmessage('This software can not convert ' + lTmpStr + ' data type.');
        Goto 333;
      End;
      If (lTmpStr = 'UNSIGNEDINTEGER') Or (lTmpStr = 'WORD') Or
        (lTmpStr = 'BYTE') Or (lTmpStr = 'LONGWORD') Then
        lUnsigned := true;
      If (lTmpStr = 'FLOAT') Or (lTmpStr = 'SHORTFLOAT') Or
        (lTmpStr = 'LONGFLOAT') Or (lTmpStr = 'SINGLE') Or (lTmpStr = 'DOUBLE')
        Or (lTmpStr = 'EXTENDED') Then
      Begin
        lFloat := true;
      End;
    End;
    If lUpCaseStr = 'NAMEOFDATAFILE' Then
    Begin
      ImageFileName := ExtractFilePath(lFileName) + readInterStr;;
    End;
    If lUpCaseStr = 'NUMBEROFBYTESPERPIXEL' Then
      Data.Allocbits_per_pixel := round(readInterFloat) * 8;
    If (lUpCaseStr = 'SCALINGFACTOR(MM/PIXEL)[1]') Or
      (lUpCaseStr = 'SCALINGFACTOR(MM/PIXEL)[X]') Then
      Data.XYZmm[1] := (readInterFloat);
    If (lUpCaseStr = 'SCALINGFACTOR(MM/PIXEL)[2]') Or
      (lUpCaseStr = 'SCALINGFACTOR(MM/PIXEL)[Y]') Then
      Data.XYZmm[2] := (readInterFloat);
    If (lUpCaseStr = 'SCALINGFACTOR(MM/PIXEL)[3]') Or
      (lUpCaseStr = 'SCALINGFACTOR(MM/PIXEL)[Z]') Or
      (lUpCaseStr = 'SLICETHICKNESS') Then
      Data.XYZmm[3] := (readInterFloat);
    If (lUpCaseStr = 'ENDOFINTERFILE') Then
      lHdrEnd := true;
    If Not lHdrOK Then
      Goto 333;
    If lInStr <> '' Then
      lDynStr := lDynStr + lInStr + kCR;
    lHdrOK := true;
  Until (linPos >= FileSz) Or (lHdrEnd) { EOF(fp) };
  Data.Storedbits_per_pixel := Data.Allocbits_per_pixel;
  Data.signed := Not lUnsigned;
  lImageFormatOK := true;
  If Data.XYZori[1] <= 1 Then
    Data.XYZori[1] := Data.XYZdim[1];
  If Data.XYZori[2] <= 1 Then
    Data.XYZori[2] := Data.XYZdim[2];
  If Data.XYZori[3] <= 1 Then
    Data.XYZori[3] := Data.XYZdim[3];
  If (Not lFloat) And (lUnsigned) And ((Data.Storedbits_per_pixel = 16)) Then
  Begin
    // showmessage('Warning: this Interfile image uses UNSIGNED 16-bit data [values 0..65535]. Analyze specifies SIGNED 16-bit data [-32768..32767]. Some images may not transfer well. [Future versions of MRIcro should fix this].');
    // lImageFormatOK := false;
  End
  Else If (Not lFloat) And (Data.Storedbits_per_pixel > 32) Then
  Begin
    showmessage('WARNING: The image ' + lFileName + ' is a ' +
      IntToStr(Data.Storedbits_per_pixel) +
      '-bit integer data type. This software may display this as SIGNED data. Bits per voxel: '
      + IntToStr(Data.Storedbits_per_pixel));
    // lImageFormatOK := false;
  End
  Else If (lFloat) Then
  Begin // zebra change float check
    // showmessage('WARNING: The image '+lFileName+' uses floating point [real] numbers. The current software can only read integer data type Interfile images.');
    Data.Float := true;
    // lImageFormatOK := false;
  End;
333:
  FreeMem(lCharRA);
End; (* *)

Constructor TInterfile.Create(HeaderName: TFileName; Progreso: TGaugeFloat;
  readData: boolean);
Var
  HdrOK, ImgOK: boolean;
  lDynStr: String;
  lFileName: TFileName;
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

Procedure TInterfile.SaveToFile(FileName: TFileName; Progreso: TGaugeFloat;
  lUnit: Float);
Var
  lFileName: String;
Begin
  // El estandar interfile tiene como header un archivo h33 y como imagen un archivo i33
  lFileName := changeFileExt(FileName, '.i33');
  If Write_hdr(changeFileExt(FileName, '.h33'), lFileName) Then
  Begin
    // lFileName := extractfilename(lFileName);
    Write_Image(lFileName, Progreso, lUnit);
  End;
End;

Procedure TInterfile.SetImageFileName(Const Value: TFileName);
Begin
  FImageFileName := Value;
End;

Procedure TInterfile.Write_Image(FileName: TFileName; Progreso: TGaugeFloat;
  lUnit: Float);
Var
  I, j, k, n, ni, tiempo0: integer;
  progress: Float;
  f: File;
  tempSin: Singlep0;
  tempreal: Doublep0;
  tempext: Extendedp0;
  tempLI: LongIntp0;
  tempCard: LongWordp0;
  tempSmI: SMallIntp0;
  tempWord: Wordp0;
  tempShI: ShortIntp0;
  tempbyte: Bytep0;
  Procedure InitializeGauge;
  Begin
    tiempo0 := tiempo_en_milisegundos;
    Progreso.progress := Progreso.MinValue;
    Progreso.Visible := true;
  End;
  Procedure FinalizeGauge;
  Begin
    Progreso.progress := Progreso.MinValue;
    Progreso.Visible := false;
  End;

Begin
  n := Data.XYZdim[3] * Data.XYZdim[2] * Data.XYZdim[1];
  ni := 0;
  InitializeGauge;
  If Not Data.Float Then
  Begin
    Case Data.Allocbits_per_pixel Of
      8:
        Begin
          If Data.signed Then
          Begin
            GetMem(tempShI, n * sizeof(ShortInt));
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  tempShI[ni] := round(Image[I, j, k] / lUnit);
                  inc(ni)
                  // write(f,temp);
                End;
              progress := LinealInterpolation(1, Progreso.MinValue,
                Data.XYZdim[3], Progreso.MaxValue, k);
              Progreso.updateTime(tiempo0, progress, FileName);
            End;
            assignfile(f, FileName);
            rewrite(f, 1);
            BlockWrite(f, tempShI^, ni);
            FreeMem(tempShI);
            closefile(f);
          End
          Else
          Begin
            GetMem(tempbyte, n * sizeof(byte));
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  tempbyte[ni] := round(Image[I, j, k] / lUnit);
                  inc(ni)
                  // write(f,temp);
                End;
              progress := LinealInterpolation(1, Progreso.MinValue,
                Data.XYZdim[3], Progreso.MaxValue, k);
              Progreso.updateTime(tiempo0, progress, FileName);
            End;
            assignfile(f, FileName);
            rewrite(f, 1);
            BlockWrite(f, tempbyte^, ni);
            FreeMem(tempbyte);
            closefile(f);
          End;
        End;
      16:
        Begin
          If Data.signed Then
          Begin
            GetMem(tempSmI, n * sizeof(SmallInt));
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  tempSmI[ni] := round(Image[I, j, k] / lUnit);
                  inc(ni)
                  // write(f,temp);
                End;
              progress := LinealInterpolation(1, Progreso.MinValue,
                Data.XYZdim[3], Progreso.MaxValue, k);
              Progreso.updateTime(tiempo0, progress, FileName);
            End;
            If Data.little_endian = 0 Then
            Begin
              For I := 0 To n - 1 Do
                Swap2(tempSmI[I]);
            End;
            assignfile(f, FileName);
            rewrite(f, 2);
            BlockWrite(f, tempSmI^, ni);
            FreeMem(tempSmI);
            closefile(f);
          End
          Else
          Begin
            GetMem(tempWord, n * sizeof(Word));
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  tempWord[ni] := round(Image[I, j, k] / lUnit);
                  inc(ni)
                  // write(f,temp);
                End;
              progress := LinealInterpolation(1, Progreso.MinValue,
                Data.XYZdim[3], Progreso.MaxValue, k);
              Progreso.updateTime(tiempo0, progress, FileName);
            End;
            If Data.little_endian = 0 Then
            Begin
              For I := 0 To n - 1 Do
                Swap2u(tempWord[I]);
            End;
            assignfile(f, FileName);
            rewrite(f, 2);
            BlockWrite(f, tempWord^, ni);
            FreeMem(tempWord);
            closefile(f);
          End;
        End;
      32:
        Begin
          If Data.signed Then
          Begin
            GetMem(tempLI, n * sizeof(longint));
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  tempLI[ni] := round(Image[I, j, k] / lUnit);
                  inc(ni)
                  // write(f,temp);
                End;
              progress := LinealInterpolation(1, Progreso.MinValue,
                Data.XYZdim[3], Progreso.MaxValue, k);
              Progreso.updateTime(tiempo0, progress, FileName);
            End;
            If Data.little_endian = 0 Then
            Begin
              For I := 0 To n - 1 Do
                swap4(tempLI[I]);
            End;
            assignfile(f, FileName);
            rewrite(f, 4);
            BlockWrite(f, tempLI^, ni);
            FreeMem(tempLI);
            closefile(f);
          End
          Else
          Begin
            GetMem(tempCard, n * sizeof(cardinal));
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  tempCard[ni] := round(Image[I, j, k] / lUnit);
                  inc(ni)
                  // write(f,temp);
                End;
              progress := LinealInterpolation(1, Progreso.MinValue,
                Data.XYZdim[3], Progreso.MaxValue, k);
              Progreso.updateTime(tiempo0, progress, FileName);
            End;
            If Data.little_endian = 0 Then
            Begin
              For I := 0 To n - 1 Do
                swap4u(tempCard[I]);
            End;
            assignfile(f, FileName);
            rewrite(f, 4);
            BlockWrite(f, tempCard^, ni);
            FreeMem(tempCard);
            closefile(f);
          End;
        End;
    End;
  End
  Else
  Begin
    Case Data.Allocbits_per_pixel Of
      32:
        Begin
          GetMem(tempSin, n * sizeof(single));
          For k := 1 To Data.XYZdim[3] Do
          Begin
            For j := 1 To Data.XYZdim[2] Do
              For I := 1 To Data.XYZdim[1] Do
              Begin
                tempSin[ni] := (Image[I, j, k] / lUnit);
                inc(ni)
                // write(f,temp);
              End;
            progress := LinealInterpolation(1, Progreso.MinValue,
              Data.XYZdim[3], Progreso.MaxValue, k);
            Progreso.updateTime(tiempo0, progress, FileName);
          End;
          If Data.little_endian = 0 Then
          Begin
            For I := 0 To n - 1 Do
              swap4r(tempSin[I]);
          End;
          assignfile(f, FileName);
          rewrite(f, 4);
          BlockWrite(f, tempSin^, ni);
          FreeMem(tempSin);
          closefile(f);
        End;
      64:
        Begin
          GetMem(tempreal, n * sizeof(real));
          For k := 1 To Data.XYZdim[3] Do
          Begin
            For j := 1 To Data.XYZdim[2] Do
              For I := 1 To Data.XYZdim[1] Do
              Begin
                tempreal[ni] := (Image[I, j, k] / lUnit);
                inc(ni)
                // write(f,temp);
              End;
            progress := LinealInterpolation(1, Progreso.MinValue,
              Data.XYZdim[3], Progreso.MaxValue, k);
            Progreso.updateTime(tiempo0, progress, FileName);
          End;
          If Data.little_endian = 0 Then
          Begin
            For I := 0 To n - 1 Do
              tempreal[I] := fswap8r(tempreal[I]);
          End;
          assignfile(f, FileName);
          rewrite(f, 8);
          BlockWrite(f, tempreal^, ni);
          FreeMem(tempreal);
          closefile(f);
        End;
      80:
        Begin
          GetMem(tempext, n * sizeof(extended));
          For k := 1 To Data.XYZdim[3] Do
          Begin
            For j := 1 To Data.XYZdim[2] Do
              For I := 1 To Data.XYZdim[1] Do
              Begin
                tempext[ni] := (Image[I, j, k] / lUnit);
                inc(ni)
                // write(f,temp);
              End;
            progress := LinealInterpolation(1, Progreso.MinValue,
              Data.XYZdim[3], Progreso.MaxValue, k);
            Progreso.updateTime(tiempo0, progress, FileName);
          End;
          assignfile(f, FileName); // only little_endian
          rewrite(f, 10);
          BlockWrite(f, tempext^, ni);
          FreeMem(tempext);
          closefile(f);
        End;
    End;
  End;
  FinalizeGauge;
End;

Constructor TInterfile.Create(Another: TMedicalImageData; lImgName: TFileName;
  Progreso: TGaugeFloat);
Begin
  Data := Another;
  ImageFileName := lImgName;
  datacreated := true;
  Try
    Read_Image(ExtractFilePath(ImageFileName), Progreso);
  Except
    datacreated := false;
  End;
End;

Constructor TInterfile.Create(Another: TMedicalImageData; Initialize: boolean);
Begin
  Data := Another;
  ImageFileName := '';
  If Initialize Then
  Begin
    dimMatrix(Image, Data.XYZdim[1], Data.XYZdim[2], Data.XYZdim[3]);
    datacreated := true;
  End
  Else
    datacreated := false;
End;

Procedure TInterfile.Read_Image(path: String; Progreso: TGaugeFloat);
{ Reads a Raw Data Image from file FileName with specifications given by lData
  and stores it in matrix which must be already initialized, it also returns the
  minimum and maximum value of the data and shows the reading progress in a Gauge.
  If you doesn't want the progress simply enter nil }
Var
  I, j, k: integer;
  showprogress: boolean;
  ftemp: File;
  n, RecSize, tiemp0, ni: longint;
  progress: Float;
  shortinttemp: ShortIntp0;
  bytetemp: Bytep0;
  smallinttemp: SMallIntp0;
  wordtemp: Wordp0;
  longinttemp: LongIntp0;
  longwordtemp: LongWordp0;
  singletemp: Singlep0;
  doubletemp: Doublep0;
  extendedtemp: Extendedp0;
Begin
  Data.MinIntensity := MAX_FLT;
  Data.MaxIntensity := -MAX_FLT;
  RecSize := Data.Allocbits_per_pixel Div 8; // Size in bytes of the transfer
  If fileexists(ImageFileName) Then
    assignfile(ftemp, ImageFileName)
  Else If fileexists(path + ImageFileName) Then
    assignfile(ftemp, path + ImageFileName)
  Else
  Begin
    datacreated := false;
    exit;
  End;
  FileMode := fmOpenRead;
  Reset(ftemp, RecSize); // reset file and set transfer rate to Recsize
  Seek(ftemp, Data.ImageStart);
  n := Data.XYZdim[1] * Data.XYZdim[2] * Data.XYZdim[3]; // = lData.ImageSz;
  showprogress := (Progreso <> Nil);
  dimMatrix(Image, Data.XYZdim[1], Data.XYZdim[2], Data.XYZdim[3]);
  tiemp0 := tiempo_en_milisegundos;
  If Not Data.Float Then
  Begin // integer data type
    Case Data.Allocbits_per_pixel Of
      8:
        Begin
          If Data.signed Then
          Begin // shortint data type
            GetMem(shortinttemp, n * RecSize); // Reserves buffer memory
            // SetLength(shortinttemp,N);
            BlockRead(ftemp, shortinttemp^, n);
            ni := 0; // reads all data at once
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  Image[I, j, k] := Data.IntenIntercept +
                    (Data.IntenScale * shortinttemp[ni]);
                  // moves buffer data to matrix
                  inc(ni);
                  If Image[I, j, k] > Data.MaxIntensity Then
                    Data.MaxIntensity := Image[I, j, k]; // seek max and min
                  If Image[I, j, k] < Data.MinIntensity Then
                    Data.MinIntensity := Image[I, j, k];
                End;
              If showprogress Then
              Begin
                progress := LinealInterpolation(1, Progreso.MinValue,
                  Data.XYZdim[3], Progreso.MaxValue, k);
                Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
              End;
            End;
            FreeMem(shortinttemp, n * RecSize); // frees buffer memory
          End
          Else
          Begin
            GetMem(bytetemp, n * RecSize);
            // SetLength(bytetemp,N);
            BlockRead(ftemp, bytetemp^, n);
            ni := 0;
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  Image[I, j, k] := Data.IntenIntercept +
                    (Data.IntenScale * bytetemp[ni]);
                  inc(ni);
                  If Image[I, j, k] > Data.MaxIntensity Then
                    Data.MaxIntensity := Image[I, j, k]; // seek max and min
                  If Image[I, j, k] < Data.MinIntensity Then
                    Data.MinIntensity := Image[I, j, k];
                End;
              If showprogress Then
              Begin
                progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
                Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
              End;
            End;
            FreeMem(bytetemp, n * RecSize);
          End;
        End;
      16:
        Begin
          If Data.signed Then
          Begin
            GetMem(smallinttemp, n * RecSize);
            // SetLength(smallinttemp,N);
            BlockRead(ftemp, smallinttemp^, n);
            ni := 0;
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  Image[I, j, k] := Data.IntenIntercept +
                    (Data.IntenScale * ToLittleEndian(smallinttemp[ni],
                    Data.little_endian));
                  inc(ni);
                  If Image[I, j, k] > Data.MaxIntensity Then
                    Data.MaxIntensity := Image[I, j, k]; // seek max and min
                  If Image[I, j, k] < Data.MinIntensity Then
                    Data.MinIntensity := Image[I, j, k];
                End;
              If showprogress Then
              Begin
                progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
                Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
              End;
            End;
            FreeMem(smallinttemp, n * RecSize);
          End
          Else
          Begin
            GetMem(wordtemp, n * RecSize);
            // SetLength(wordtemp,N);
            BlockRead(ftemp, wordtemp^, n);
            ni := 0;
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  // N:=((k-1)*gDicomData.XYZdim[1]*gDicomData.XYZdim[2]+(j-1)*gDicomData.XYZdim[1]+(i-1));
                  Image[I, j, k] := Data.IntenIntercept +
                    (Data.IntenScale * ToLittleEndian(wordtemp[ni],
                    Data.little_endian));
                  inc(ni);
                  If Image[I, j, k] > Data.MaxIntensity Then
                    Data.MaxIntensity := Image[I, j, k]; // seek max and min
                  If Image[I, j, k] < Data.MinIntensity Then
                    Data.MinIntensity := Image[I, j, k];
                End;
              If showprogress Then
              Begin
                progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
                Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
              End;
            End;
            FreeMem(wordtemp, n * RecSize);
          End;
        End;
      32:
        Begin
          If Data.signed Then
          Begin
            GetMem(longinttemp, n * RecSize);
            // SetLength(longinttemp,N);
            BlockRead(ftemp, longinttemp^, n);
            ni := 0;
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  Image[I, j, k] := Data.IntenIntercept +
                    (Data.IntenScale * ToLittleEndian(longinttemp[ni],
                    Data.little_endian));
                  inc(ni);
                  If Image[I, j, k] > Data.MaxIntensity Then
                    Data.MaxIntensity := Image[I, j, k]; // seek max and min
                  If Image[I, j, k] < Data.MinIntensity Then
                    Data.MinIntensity := Image[I, j, k];
                End;
              If showprogress Then
              Begin
                progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
                Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
              End;
            End;
            FreeMem(longinttemp, n * RecSize);
          End
          Else
          Begin
            GetMem(longwordtemp, n * RecSize);
            // SetLength(longwordtemp,N);
            BlockRead(ftemp, longwordtemp^, n);
            ni := 0;
            For k := 1 To Data.XYZdim[3] Do
            Begin
              For j := 1 To Data.XYZdim[2] Do
                For I := 1 To Data.XYZdim[1] Do
                Begin
                  Image[I, j, k] := Data.IntenIntercept +
                    (Data.IntenScale * ToLittleEndian(longwordtemp[ni],
                    Data.little_endian));
                  inc(ni);
                  If Image[I, j, k] > Data.MaxIntensity Then
                    Data.MaxIntensity := Image[I, j, k]; // seek max and min
                  If Image[I, j, k] < Data.MinIntensity Then
                    Data.MinIntensity := Image[I, j, k];
                End;
              If showprogress Then
              Begin
                progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
                Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
              End;
            End;
            FreeMem(longwordtemp, n * RecSize);
          End;
        End;
    Else
      Begin
        showmessage(StrErrorInInputBytes);
        closefile(ftemp);
        exit;
      End;
    End;
  End
  Else
  Begin // float data type
    Case Data.Allocbits_per_pixel Of
      32:
        Begin
          GetMem(singletemp, n * RecSize);
          // SetLength(shortinttemp,N);
          BlockRead(ftemp, singletemp^, n);
          ni := 0;
          For k := 1 To Data.XYZdim[3] Do
          Begin
            For j := 1 To Data.XYZdim[2] Do
              For I := 1 To Data.XYZdim[1] Do
              Begin
                Image[I, j, k] := Data.IntenIntercept +
                  (Data.IntenScale * ToLittleEndian(singletemp[ni],
                  Data.little_endian));
                inc(ni);
                If Image[I, j, k] > Data.MaxIntensity Then
                  Data.MaxIntensity := Image[I, j, k]; // seek max and min
                If Image[I, j, k] < Data.MinIntensity Then
                  Data.MinIntensity := Image[I, j, k];
              End;
            If showprogress Then
            Begin
              progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
              Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
            End;
          End;
          FreeMem(singletemp, n * RecSize);
        End;
      64:
        Begin
          GetMem(doubletemp, n * RecSize);
          // SetLength(shortinttemp,N);
          BlockRead(ftemp, doubletemp^, n);
          ni := 0;
          For k := 1 To Data.XYZdim[3] Do
          Begin
            For j := 1 To Data.XYZdim[2] Do
              For I := 1 To Data.XYZdim[1] Do
              Begin
                Image[I, j, k] := Data.IntenIntercept +
                  (Data.IntenScale * ToLittleEndian(doubletemp[ni],
                  Data.little_endian));
                inc(ni);
                If Image[I, j, k] > Data.MaxIntensity Then
                  Data.MaxIntensity := Image[I, j, k]; // seek max and min
                If Image[I, j, k] < Data.MinIntensity Then
                  Data.MinIntensity := Image[I, j, k];
              End;
            If showprogress Then
            Begin
              progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
              Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
            End;
          End;
          FreeMem(doubletemp, n * RecSize);
        End;
      80:
        Begin
          GetMem(extendedtemp, n * RecSize);
          // SetLength(shortinttemp,N);
          BlockRead(ftemp, extendedtemp^, n);
          ni := 0;
          For k := 1 To Data.XYZdim[3] Do
          Begin
            For j := 1 To Data.XYZdim[2] Do
              For I := 1 To Data.XYZdim[1] Do
              Begin
                Image[I, j, k] := Data.IntenIntercept +
                  (Data.IntenScale * ToLittleEndian(extendedtemp[ni],
                  Data.little_endian));
                inc(ni);
                If Image[I, j, k] > Data.MaxIntensity Then
                  Data.MaxIntensity := Image[I, j, k]; // seek max and min
                If Image[I, j, k] < Data.MinIntensity Then
                  Data.MinIntensity := Image[I, j, k];
              End;
            If showprogress Then
            Begin
              progress := LinealInterpolation(1, 0, Data.XYZdim[3], 100, k);
              Progreso.updateTime(tiemp0, progress, 'Leyendo imagen...');
            End;
          End;
          FreeMem(extendedtemp, n * RecSize);
        End;
    Else
      Begin // data type neither allowed nor implemented
        showmessage(StrErrorInInputBytes);
        closefile(ftemp);
        exit;
      End;
    End;
  End;
  Data.MinIntensitySet := true;
  datacreated := true;
  closefile(ftemp);
End;

Constructor TIntInterfile.Create(Another: TIntInterfile);
Begin
  Data := Another.Data;
  Image := Clone(Another.Image, Another.Data.XYZdim[1], Another.Data.XYZdim[2],
    Another.Data.XYZdim[3]);
  datacreated := true;
End;

Constructor TIntInterfile.Create(Another: TInterfile);
Begin
  Data := Another.Data;
  ImageFileName := Another.ImageFileName;
  Image := round(Another.Image, Another.Data.XYZdim[1], Another.Data.XYZdim[2],
    Another.Data.XYZdim[3]);
  datacreated := true;
End;

Constructor TIntInterfile.Create(Another: TMedicalImageData;
  Initialize: boolean);
Begin
  Data := Another;
  ImageFileName := '';
  If Initialize Then
  Begin
    dimMatrix(Image, Data.XYZdim[1], Data.XYZdim[2], Data.XYZdim[3]);
    datacreated := true;
  End
  Else
    datacreated := false;
End;

Function TIntInterfile.GetElemento(m, n, o: integer): integer;
Begin
  result := Image[m, n, o];
End;

Procedure TIntInterfile.SetElemento(m, n, o: integer; Const Value: integer);
Begin
  Image[m, n, o] := Value;
End;

Function LeeMedicalImage_asInterfile(FileName: TFileName;
  Data: TMedicalImageData; Progreso: TGaugeFloat; IsRaw, UseData, readimage: boolean)
  : TInterfile;
Var
  Temp: TInterfile;
  extension: String;
Begin
  extension := GetFileExt(FileName);
  If (StrCompare(extension, 'HDR')) Or (StrCompare(extension, 'H33')) Then
  Begin // Interfile/Analyze
    If UseData Then
      Temp := TInterfile.Create(Data, FileName, Progreso)
    Else
      Temp := TInterfile.Create(FileName, Progreso);
    If Not Temp.datacreated Then // Fallo el interfile, probando con Analyze
    Begin
      Temp.Free;
      Temp := LeeAnalyze(FileName, Progreso);
    End;
    If IsRaw Then
      Temp.Write_hdr(changeFileExt(FileName, '.hdr'), FileName);
  End
  Else If (StrCompare(extension, 'MHD')) Or (StrCompare(extension, 'MHA')) Then
  Begin // MetaImage
    Temp := LeeMetaImage(FileName, Progreso);
  End
  Else // If (StrCompare(extension, 'DCM') OR (extension = '')) Then
  Begin // DICOM
    Temp := LeeDICOM(FileName, Data, Progreso, true, UseData, readimage);
  End;
  result := Temp;
End;

End.
