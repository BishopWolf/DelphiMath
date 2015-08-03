/// <summary>
/// Unit uDICOM handles DICOM medical images Created by Alex Vergara Gil
/// based on ezDICOM by Chris Rorden Included a base class for all kind of
/// medical images
/// </summary>
/// <remarks>
/// <para>
/// Created oct 3, 2012 Alex Vergara Gil
/// <see href="mailto:alexvergaragil@gmail.com">alexvergaragil@gmail.com</see>
/// </para>
/// <para>
/// Revisions
/// </para>
/// <para>
/// 17/11/2012: Added support for all kind of data types
/// </para>
/// <para>
/// Limitations
/// </para>
/// <para>
/// - compiling for Pascal other than Delphi 2.0+: gDynStr gets VERY big,
/// e.g. not standard Pascal string with maximum size of 256 bytes
/// </para>
/// <para>
/// - write_dicom: currently only writes little endian, data should be
/// little_endian
/// </para>
/// <para>
/// -
/// <see href="mailto:chris.rorden@nottingham.ac.uk">chris.rorden@nottingham.ac.uk</see>
/// </para>
/// <para>
/// - rev 7 has disk caching: speeds DCOM header reading
/// </para>
/// <para>
/// - rev 8 can read interfile format images
/// </para>
/// <para>
/// - rev 9 Siemens Magnetom, GELX
/// </para>
/// <para>
/// - rev 10 ECAT6/7, DICOM runlengthencoding[RLE] parameters
/// </para>
/// <para>
/// *NOTE: If your software does not decompress images, check to make sure
/// that DICOMdata.CompressOffset = 0. This value will be &gt; 0 for any
/// DICOM/GE/Elscint file with compressed image data
/// </para>
/// </remarks>
Unit uDICOM;

Interface

Uses
  Windows, Dialogs, Controls, classes, SysUtils,
  GaugeFloat, uConstants, utypes, uMedicalImage, uinterfile;

Type
  /// <summary>
  /// The DICOM handler
  /// </summary>
  /// <remarks>
  /// Inherits from the base Medical Image
  /// </remarks>
  TDICOM = Class(TMedicalImage)
    lHdrOk, lImageFormatOK: boolean;
    lDynStr: String;
    gECATJPEG_table_entries: integer;
    gECATJPEG_pos_table, gECATJPEG_size_table: LongIntp;
    gFileList: TStringList;
    CurrentPosInFileList, FileListSz: integer;
    red_table: ByteP;
    green_table: ByteP;
    blue_table: ByteP;
    red_table_size: integer;
    green_table_size: integer;
    blue_table_size: integer;
    lFileName: TFileName;
    lStudyPath: String;
  Private
    Procedure ShellSortItems(first, last: integer;
      Var lPositionRA, lIndexRA: LongIntp; Var lRepeatedValues: boolean);
    Procedure read_elscint_data;
    Procedure read_ge_data;
    Procedure read_tiff_data(Var lReadOffsets: boolean);
    Procedure read_biorad_data;
    Procedure read_afni_data(Var lRotation1, lRotation2, lRotation3: integer);
    Procedure read_VFF_data;
    Procedure read_PAR_data(lReadOffsetTables: boolean;
      Var lOffset_pos_table: LongIntp; Var lOffsetTableEntries: integer;
      lReadVaryingScaleFactors: boolean; Var lVaryingScaleFactors_table,
      lVaryingIntercept_table: Singlep; Var lVaryingScaleFactorsTableEntries,
      lnum4Ddatasets: integer);
    Procedure read_siemens_data;
    Procedure read_minc_data;
    Procedure read_ecat_data(lVerboseRead, lReadECAToffsetTables: boolean);
    Procedure read_picker_data(lVerboseRead: boolean);
  Public
    /// <summary>
    /// Reads the header of a single file DICOM image
    /// </summary>
    /// <param name="FileName">
    /// The FileName of the DICOM File
    /// </param>
    /// <param name="lVerboseRead">
    /// extracts the header information in lDynStr if true
    /// </param>
    Procedure Read_DICOM_HDR(FileName: TFileName;
      lVerboseRead: boolean = false);

    /// <summary>
    /// Reads the image of a single file DICOM image considering it as
    /// 2-dimensional
    /// </summary>
    /// <remarks>
    /// Useful for DICOM directories
    /// </remarks>
    Function Read_Image: TMatrix;

    /// <summary>
    /// Reads the image of a single file DICOM image considering it as
    /// 3-dimensional
    /// </summary>
    /// <remarks>
    /// Useful for single DICOM files with multiple frames
    /// </remarks>
    Function Read_Image3D: T3DMatrix;

    /// <summary>
    /// Writes a DICOM single file with the image as 3D, if you want 2D
    /// images then asign xyzdim[3] as 1
    /// </summary>
    Procedure Write_DICOM(FileName: TFileName; Progreso: TGaugeFloat;
      lUnit: float; Out lSz: integer; lDICOM3: boolean = true);

    /// <summary>
    /// Loads all DICOM files with the same PatientID and sorts them based in
    /// the ImageNum parameter
    /// </summary>
    Procedure LoadFileList(FileName: TFileName);

    /// <summary>
    /// Reads all the DICOM images defined by LoadFileList and creates the
    /// Image
    /// </summary>
    Procedure ReadDICOMDir(Progreso: TGaugeFloat);
    Constructor Create(lFileName: TFileName; Progreso: TGaugeFloat;
      signed: boolean); Overload;

    /// <summary>
    /// Converts the DICOM object into an Interfile one destroying the
    /// instance utterly
    /// </summary>
    /// <remarks>
    /// must free the instance after calling this procedure
    /// </remarks>
    Function ToInterfile: TInterfile;

    /// <summary>
    /// Clear/Initializes the data and the DICOM variables
    /// </summary>
    Procedure clear;
  End;

  /// <summary>
  /// Function to read a DICOM study as Interfile
  /// </summary>
Function LeeDICOM(lFileName: TFileName; lData: TMedicalImageData;
  Var Progreso: TGaugeFloat; signed, useData: boolean): TInterfile;

Implementation

Uses uoperations, umemory, uinterpolation, ustrings, uminmax, uround,
  ubyteorder;

Const
  kA = ord('A');
  kB = ord('B');
  kC = ord('C');
  kD = ord('D');
  kE = ord('E');
  kF = ord('F');
  kH = ord('H');
  kI = ord('I');
  kL = ord('L');
  kM = ord('M');
  kN = ord('N');
  kO = ord('O');
  kP = ord('P');
  kQ = ord('Q');
  kS = ord('S');
  kT = ord('T');
  kU = ord('U');
  kW = ord('W');
  AnsiCharSz = 1; // SizeOf(AnsiChar);

  { TDICOM }

Procedure TDICOM.ReadDICOMDir(Progreso: TGaugeFloat);
{ Reads a DICOM directory and outputs into a data matrix }
Var
  tempDicomData: TMedicalImageData;
  i, j, k, N, tiemp0: integer;
  tempmatrix: TMatrix;
  progress: float;
  showprogress: boolean;
  Procedure InitializeGauge;
  Begin
    tiemp0 := tiempo_en_milisegundos;
    Progreso.progress := Progreso.MinValue;
    Progreso.Visible := true;
  End;
  Procedure FinalizeGauge;
  Begin
    Progreso.progress := Progreso.MinValue;
    Progreso.Visible := false;;
  End;

Begin
  If gFileList = Nil Then
    LoadFileList(lFileName);
  If Not datacreated Then
  Begin
    data.XYZdim[3] := FileListSz;
    DimMatrix(Image, data.XYZdim[1], data.XYZdim[2], data.XYZdim[3]);
    data.ImageSz := data.XYZdim[1] * data.XYZdim[2] * data.XYZdim[3] *
      data.Storedbits_per_pixel Div 8;
    datacreated := true;
  End;
  tempDicomData := data;
  data.MinIntensity := MAX_FLT;
  data.MaxIntensity := -MAX_FLT;
  showprogress := (Progreso <> Nil);
  DimMatrix(tempmatrix, tempDicomData.XYZdim[1], tempDicomData.XYZdim[2], 1);
  N := gFileList.Count;
  If showprogress Then
    InitializeGauge;
  For k := 1 To N Do
  Begin
    lFileName := lStudyPath + gFileList[k - 1];
    Read_DICOM_HDR(lFileName); // se supone que todos los headers son iguales
    data.XYZdim[3] := 1;
    tempmatrix := Read_Image;
    For i := 1 To data.XYZdim[1] Do
      For j := 1 To data.XYZdim[2] Do
      Begin
        Image[i, j, k] := tempmatrix[i, j];
      End;
    If tempDicomData.MinIntensity < data.MinIntensity Then
      data.MinIntensity := tempDicomData.MinIntensity;
    If tempDicomData.MaxIntensity > data.MaxIntensity Then
      data.MaxIntensity := tempDicomData.MaxIntensity;
    If showprogress Then
    Begin
      progress := LinealInterpolation(1, Progreso.MinValue, N,
        Progreso.MaxValue, k);
      Progreso.updateTime(tiemp0, progress, 'Leyendo directorio...' +
        gFileList[k - 1]);
    End;
  End;
  data.MinIntensitySet := true;
  data := tempDicomData;
  DelMatrix(tempmatrix);
  If showprogress Then
    FinalizeGauge;
End;

/// <summary>
/// Shell sort chuck uses this- see 'Numerical Recipes in C' for similar sorts.
/// </summary>
/// <remarks>
/// shellsort is fast and requires less memory than quicksort
/// </remarks>
Procedure TDICOM.ShellSortItems(first, last: integer;
  Var lPositionRA, lIndexRA: LongIntp; Var lRepeatedValues: boolean);
Label
  555;
Const
  tiny = 1.0E-5;
  aln2i = 1.442695022;
Var
  N, t, nn, m, lognb2, l, k, j, i: LongInt;
Begin
  lRepeatedValues := false;
  N := abs(last - first + 1);
  lognb2 := trunc(ln(N) * aln2i + tiny);
  m := last;
  For nn := 1 To lognb2 Do
  Begin
    m := m Div 2;
    k := last - m;
    For j := 1 To k Do
    Begin
      i := j;
    555: { <- LABEL }
      l := i + m;
      If (lIndexRA[lPositionRA[l]] = lIndexRA[lPositionRA[i]]) Then
      Begin
        lRepeatedValues := true;
        exit;
      End;
      If (lIndexRA[lPositionRA[l]] < lIndexRA[lPositionRA[i]]) Then
      Begin
        // swap values for i and l
        t := lPositionRA[i];
        lPositionRA[i] := lPositionRA[l];
        lPositionRA[l] := t;
        i := i - m;
        If (i >= 1) Then
          Goto 555;
      End
    End
  End
End;

Function TDICOM.ToInterfile: TInterfile;
Begin
  result := TInterfile.Create(self, true);
  If result.data.IntenScale = 0 Then
    result.data.IntenScale := 1;
  If Not result.data.MinIntensitySet Then
  Begin
    MinMax(result.Image, 1, result.data.XYZdim[1], 1, result.data.XYZdim[2], 1,
      result.data.XYZdim[3], result.data.MinIntensity,
      result.data.MaxIntensity);
    result.data.MinIntensitySet := true;
  End;
  result.ImageFileName := ChangeFileExt(lFileName, '.img');
  result.data.ImageStart := 0;
  result.datacreated := datacreated;
  datacreated := false;
End;

// begin elscint
Procedure TDICOM.read_elscint_data;
Label
  539;
Var
  // lExamHdr,lImgHdr,lDATFormatOffset,lHdrOffset,
  { lDate, } lI, lCompress, N, filesz: LongInt;
  tx: Array [0 .. 41] Of AnsiChar;
  FP: File;
  Function readStr(lPos, lLen: integer): String;
  Var
    lStr: String;
    lStrInc: integer;
  Begin
    seek(FP, lPos);
    BlockRead(FP, tx, lLen, N);
    lStr := '';
    For lStrInc := 0 To (lLen - 1) Do
      lStr := lStr + tx[lStrInc];
    result := lStr
  End;
  Function read8ch(lPos: integer): AnsiChar;
  Begin
    seek(FP, 40);
    BlockRead(FP, result, 1, N);
    // lData.ImageNum := ord(tx[0]);
  End;
  Procedure read16i(lPos: LongInt; Out lVal: integer); Overload;
  Var
    lInWord: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInWord, 2);
    lVal := lInWord;
  End;
  Procedure read32i(lPos: LongInt; Out lVal: integer); Overload;
  Var
    lInINt: integer;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInINt, 4);
    lVal := lInINt;
  End;
  Procedure read16i(lPos: LongInt; Out lVal: uint32); Overload;
  Var
    lInWord: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInWord, 2);
    lVal := lInWord;
  End;
  Procedure read32i(lPos: LongInt; Out lVal: uint32); Overload;
  Var
    lInINt: integer;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInINt, 4);
    lVal := lInINt;
  End;

Begin
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  clear;
  If filesz < (3240) Then
  Begin
    showmessage('This file is too small to be a Elscint format image.');
    Goto 539;
  End;
  lDynStr := '';
  read16i(0, lI);
  If (lI <> 64206) Then
  Begin
    showmessage
      ('Unable to read this file: it does start with the Elscint signature.');
    Goto 539;
  End;
  data.little_endian := 1;
  lDynStr := 'Elscint Format' + kCR;
  lDynStr := lDynStr + 'Patient Name: ' + readStr(4, 20) + kCR;
  lDynStr := lDynStr + 'Patient ID: ' + readStr(24, 13) + kCR;
  read16i(38, data.AcquNum);
  data.ImageNum := ord(read8ch(40));
  lDynStr := lDynStr + 'Doctor & Ward: ' + readStr(100, 20) + kCR;
  lDynStr := lDynStr + 'Comments: ' + readStr(120, 40) + kCR;
  If ord(read8ch(163)) = 1 Then
    lDynStr := lDynStr + 'Sex: M' + kCR
  Else
    lDynStr := lDynStr + 'Sex: F' + kCR;
  (* read16i(180,lI);
    read16i(182,lI2);
    //lDate :=(lI shl 16)+ lI2;
    lDate := lI2;
    lDynStr := lDynStr+'Date: '+IntToStr(lDate)+kCR; *)
  read16i(200, lI);
  data.XYZmm[3] := lI * 0.1;
  read16i(370, data.XYZdim[1]);
  read16i(372, data.XYZdim[2]);
  read16i(374, lI);
  data.XYZmm[1] := lI / 256;
  data.XYZmm[2] := data.XYZmm[1];
  lCompress := ord(read8ch(376));
  data.ElscintCompress := true;
  read16i(400, data.WindowWidth);
  read16i(398, data.WindowCenter);
  // read16i(400,lI);
  // read16i(854,lI2);
  // showmessage(IntToStr(Data.WindowWidth)+'w abba c'+IntToStr(Data.WindowCenter));
  Case lCompress Of
    0:
      Begin
        lDynStr := lDynStr + 'Compression: None' + kCR;
        data.ElscintCompress := false;
      End;
    1:
      lDynStr := lDynStr + 'Compression: Old' + kCR;
    2:
      lDynStr := lDynStr + 'Compression: 2400 Elite' + kCR;
    22:
      lDynStr := lDynStr + 'Compression: Twin' + kCR;
  Else
    Begin
      lDynStr := lDynStr + 'Compression: Unknown ' + IntToStr(lCompress) + kCR;
      // Data.ElscintCompress := false;
    End;
  End;
  // Data.XYZdim[1] := swap32i(linitialoffset+8); //width
  // Data.XYZdim[2] := swap32i(linitialoffset+12);//height
  data.ImageStart := 396;
  data.Allocbits_per_pixel := 16;
  data.Storedbits_per_pixel := data.Allocbits_per_pixel;
  If (data.XYZdim[1] = 160) And (data.XYZdim[2] = 160) And (filesz = 52224) Then
  Begin
    data.ImageStart := 1024;
    data.ElscintCompress := false;
  End;
  // Data.XYZmm[3] := fswap4r (2310+26);// slice thickness mm
  lDynStr := lDynStr + 'Image/Study Number: ' + IntToStr(data.ImageNum) + '/' +
    IntToStr(data.AcquNum) + kCR + 'XYZ dim: ' + IntToStr(data.XYZdim[1]) + '/'
    + IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR +
    'Window Center/Width: ' + IntToStr(data.WindowCenter) + '/' +
    IntToStr(data.WindowWidth) + kCR + 'XYZ mm: ' + floattostrf(data.XYZmm[1],
    ffFixed, 8, 2) + '/' + floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
    floattostrf(data.XYZmm[3], ffFixed, 8, 2);
  lHdrOk := true;
  lImageFormatOK := true;
539:
  closefile(FP);
  FileMode := 2; // set to read/write
End;
// end elscint

Procedure TDICOM.read_ge_data;
Label
  539;
Var
  lGap, lSliceThick, lTempFloat: single;
  lTemp16, lI: word;
  lSeriesOffset, lTemp32, lExamHdr, lImgHdr, lDATFormatOffset, lHdrOffset,
    lCompress, linitialoffset, N, filesz: LongInt;
  tx: Array [0 .. 36] Of AnsiChar;
  FP: File;
  lGEodd, lGEFlag, { lSpecial, } lMR: boolean;
  Function GEflag: boolean;
  Begin
    If (tx[0] = 'I') AND (tx[1] = 'M') AND (tx[2] = 'G') AND (tx[3] = 'F') Then
      result := true
    Else
      result := false;
  End;
  Function swap16i(lPos: LongInt): word;
  Var
    w: word;
  Begin
    seek(FP, lPos - 2);
    BlockRead(FP, w, 2);
    result := fswap2u(w);
  End;

  Function swap32i(lPos: LongInt): LongInt;
  Var
    s: LongInt;

  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 4, N);
    swap32i := fswap4(s);
  End;
  Function fswap4r(lPos: LongInt): single;
  Var
    s: single;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 4, N);
    fswap4r := ubyteorder.fswap4r(s);
  End;

Begin
  lImageFormatOK := true;
  lSeriesOffset := 0;
  lSliceThick := 0;
  lGap := 0;
  lHdrOk := false;
  lHdrOffset := 0;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  lDATFormatOffset := 0;
  clear;
  If filesz < (3240) Then
  Begin
    showmessage('This file is too small to be a Genesis DAT format image.');
    Goto 539;
  End;
  lDynStr := '';
  // lGEFlag := false;
  linitialoffset := 3228; // 3240;
  seek(FP, linitialoffset);
  BlockRead(FP, tx, 4 * AnsiCharSz, N);
  lGEFlag := GEflag;
  If Not lGEFlag Then
  Begin
    linitialoffset := 3240;
    seek(FP, linitialoffset);
    BlockRead(FP, tx, 4 * AnsiCharSz, N);
    lGEFlag := GEflag;
  End;
  lGEodd := lGEFlag;
  If Not lGEFlag Then
  Begin
    linitialoffset := 0;
    seek(FP, linitialoffset);
    BlockRead(FP, tx, 4 * AnsiCharSz, N);
    If Not GEflag Then
    Begin { DAT format }
      lDynStr := lDynStr + 'GE Genesis Signa DAT tape format' + kCR;
      seek(FP, 114);
      BlockRead(FP, tx, 4 * AnsiCharSz, N);
      lDynStr := lDynStr + 'Suite: ';
      For lI := 0 To 3 Do
        lDynStr := lDynStr + tx[lI];
      lDynStr := lDynStr + kCR;

      seek(FP, 114 + 97);
      BlockRead(FP, tx, 25 * AnsiCharSz, N);
      lDynStr := lDynStr + 'Patient Name: ';
      For lI := 0 To 24 Do
        lDynStr := lDynStr + tx[lI];
      lDynStr := lDynStr + kCR;
      seek(FP, 114 + 84);
      BlockRead(FP, tx, 13 * AnsiCharSz, N);
      lDynStr := lDynStr + 'Patient ID: ';
      For lI := 0 To 12 Do
        lDynStr := lDynStr + tx[lI];
      lDynStr := lDynStr + kCR;
      seek(FP, 114 + 305);
      BlockRead(FP, tx, 3 * AnsiCharSz, N);
      If (tx[0] = 'M') And (tx[1] = 'R') Then
        lMR := true
      Else If (tx[0] = 'C') And (tx[1] = 'T') Then
        lMR := false
      Else
      Begin
        showmessage('Is this a Genesis DAT image? The modality is ' + tx[0] +
          tx[1] + tx[3] + '. Expected ''MR'' or ''CT''.');
        Goto 539;
      End;
      If lMR Then
        linitialoffset := 3180
      Else
        linitialoffset := 3178;
      seek(FP, linitialoffset);
      BlockRead(FP, tx, 4 * AnsiCharSz, N);
      If (tx[0] <> 'I') OR (tx[1] <> 'M') OR (tx[2] <> 'G') OR
        (tx[3] <> 'F') Then
      Begin
        showmessage
          ('This image does not have the required label ''IMGF''. This is not a Genesis DAT image.');
        Goto 539;
      End
      Else
        data.ImageNum := swap16i(2158 + 12);
      data.XYZmm[3] := fswap4r(2158 + 26); // slice thickness mm
      data.XYZmm[1] := fswap4r(2158 + 50); // pixel size- X
      data.XYZmm[2] := fswap4r(2158 + 54); // pixel size - Y
      lSliceThick := data.XYZmm[3];
      lGap := fswap4r(lHdrOffset + 118); // 1410 gap thickness mm
      If lGap > 0 Then
        data.XYZmm[3] := data.XYZmm[3] + lGap;
      lDATFormatOffset := 4;
      If lMR Then
      Begin
        lTemp32 := swap32i(2158 + 194);
        lDynStr := lDynStr + 'TR[usec]: ' + IntToStr(lTemp32) + kCR;
        lTemp32 := swap32i(2158 + 198);
        lDynStr := lDynStr + 'TInvert[usec]: ' + IntToStr(lTemp32) + kCR;
        lTemp32 := swap32i(2158 + 202);
        lDynStr := lDynStr + 'TE[usec]: ' + IntToStr(lTemp32) + kCR;
        lTemp16 := swap16i(2158 + 210);
        lDynStr := lDynStr + 'Number of echoes: ' + IntToStr(lTemp16) + kCR;
        lTemp16 := swap16i(2158 + 212);
        lDynStr := lDynStr + 'Echo: ' + IntToStr(lTemp16) + kCR;

        lTempFloat := fswap4r(2158 + 50);
        // not sure why I changed this to 50... 218 in Clunie's Description
        lDynStr := lDynStr + 'NEX: ' + floattostr(lTempFloat) + kCR;

        seek(FP, 2158 + 308);
        BlockRead(FP, tx, 33 * AnsiCharSz, N);
        lDynStr := lDynStr + 'Sequence: ';
        For lI := 0 To 32 Do
          lDynStr := lDynStr + tx[lI];
        lDynStr := lDynStr + kCR;

        seek(FP, 2158 + 362);
        BlockRead(FP, tx, 17 * AnsiCharSz, N);
        lDynStr := lDynStr + 'Coil: ';
        For lI := 0 To 16 Do
          lDynStr := lDynStr + tx[lI];
        lDynStr := lDynStr + kCR;

      End;

    End; { DAT format }
  End;
  data.ImageStart := lDATFormatOffset + linitialoffset +
    swap32i(linitialoffset + 4); // byte displacement to image data
  data.XYZdim[1] := swap32i(linitialoffset + 8); // width
  data.XYZdim[2] := swap32i(linitialoffset + 12); // height
  data.Allocbits_per_pixel := swap32i(linitialoffset + 16); // bits
  data.Storedbits_per_pixel := data.Allocbits_per_pixel;
  lCompress := swap32i(linitialoffset + 20); // compression
  lExamHdr := swap32i(linitialoffset + 136);
  lImgHdr := swap32i(linitialoffset + 152);
  If (lImgHdr = 0) And (data.ImageStart = 8432) Then
  Begin
    data.ImageNum := swap16i(2310 + 12);
    // showmessage(IntToStr(Data.ImageNum));
    data.XYZmm[3] := fswap4r(2310 + 26); // slice thickness mm
    data.XYZmm[1] := fswap4r(2310 + 50); // pixel size- X
    data.XYZmm[2] := fswap4r(2310 + 54); // pixel size - Y
    lSliceThick := data.XYZmm[3];
    lGap := fswap4r(lHdrOffset + 118); // 1410 gap thickness mm
    If lGap > 0 Then
      data.XYZmm[3] := data.XYZmm[3] + lGap;

  End
  Else If { (lSpecial = false) and } (lDATFormatOffset = 0) Then
  Begin
    lDynStr := lDynStr + 'GE Genesis Signa format' + kCR;
    If (Not lGEodd) And (lExamHdr <> 0) Then
    Begin
      lHdrOffset := swap32i(linitialoffset + 132);
      // x132- int ptr to exam heade
      // Patient ID
      seek(FP, lHdrOffset + 84);
      BlockRead(FP, tx, 13 * AnsiCharSz, N);
      lDynStr := lDynStr + 'Patient ID: ';
      For lI := 0 To 12 Do
        lDynStr := lDynStr + tx[lI];
      lDynStr := lDynStr + kCR;
      // Patient Name
      seek(FP, lHdrOffset + 97);
      BlockRead(FP, tx, 25 * AnsiCharSz, N);
      lDynStr := lDynStr + 'Patient Name: ';
      For lI := 0 To 24 Do
        lDynStr := lDynStr + tx[lI];
      lDynStr := lDynStr + kCR;
      // Patient Age
      lI := swap16i(lHdrOffset + 122);
      lDynStr := lDynStr + 'Patient Age: ' + IntToStr(lI) + kCR;
      // Modality: MR or CT
      seek(FP, lHdrOffset + 305);
      BlockRead(FP, tx, 3 * AnsiCharSz, N);
      lDynStr := lDynStr + 'Type: ';
      For lI := 0 To 1 Do
        lDynStr := lDynStr + tx[lI];
      lDynStr := lDynStr + kCR;
      // Read series header
      lSeriesOffset := swap32i(linitialoffset + 144);
      // read size of series header: only read if >0
      // showmessage(IntToStr(lseriesoffset));
      If lSeriesOffset > 12 Then
      Begin
        lSeriesOffset := swap32i(linitialoffset + 140);
        // read size of series header: only read if >0
        lI := swap16i(lSeriesOffset + 10);
        // lDynStr := lDynStr+'Series number: '+IntToStr(lI)+kCR;
        data.SeriesNum := lI;
      End;

      // image data
      lHdrOffset := swap32i(linitialoffset + 148);
      // x148- int ptr to image heade
    End;
    If lGEodd Then
      lHdrOffset := 2158 + 28;
    If ((lHdrOffset + 58) < filesz) And (lImgHdr <> 0) Then
    Begin
      // showmessage(IntToStr(lHdrOffset));
      data.AcquNum := swap16i(lHdrOffset + 12);
      // note SERIES not IMAGE number, despite what Clunies FAQ says
      data.ImageNum := swap16i(lHdrOffset + 14); // this is IMAGEnum

      // lDynStr := lDynStr +'Image number: '+IntToStr(Data.ImageNum)+ kCR;
      data.XYZmm[3] :=
        fswap4r( { } lHdrOffset { linitialoffset+lHdrOffset } + 26);
      // slice thickness mm
      data.XYZmm[1] :=
        fswap4r( { } lHdrOffset { linitialoffset+lHdrOffset } + 50);
      // pixel size- X
      data.XYZmm[2] :=
        fswap4r( { } lHdrOffset { linitialoffset+lHdrOffset } + 54);
      // pixel size - Y
      lSliceThick := data.XYZmm[3];
      // showmessage(IntToStr(lHdrOffset)+'  '+floattostr(lSliceThick));

      lGap := fswap4r(lHdrOffset + 118); // 1410 gap thickness mm
      If lGap > 0 Then
        data.XYZmm[3] := data.XYZmm[3] + lGap;
    End;
  End;
  If (lCompress = 3) Or (lCompress = 4) Then
  Begin
    data.GenesisCpt := true;
    lDynStr := lDynStr + 'Compressed data' + kCR;
  End
  Else
    data.GenesisCpt := false;
  If (lCompress = 2) Or (lCompress = 4) Then
  Begin
    data.GenesisPackHdr := swap32i(linitialoffset + 64);
    lDynStr := lDynStr + 'Packed data' + kCR;
  End
  Else
    data.GenesisPackHdr := 0;
  lDynStr := lDynStr + 'Series Number: ' + IntToStr(data.SeriesNum) + kCR +
    'Acquisition Number: ' + IntToStr(data.AcquNum) + kCR + 'Image Number: ' +
    IntToStr(data.ImageNum) + kCR + 'Slice Thickness/Gap: ' +
    floattostrf(lSliceThick, ffFixed, 8, 2) + '/' + floattostrf(lGap, ffFixed,
    8, 2) + kCR + 'XYZ dim: ' + IntToStr(data.XYZdim[1]) + '/' +
    IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR + 'XYZ mm: '
    + floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/' +
    floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' + floattostrf(data.XYZmm[3],
    ffFixed, 8, 2);
  lHdrOk := true;
539:
  closefile(FP);
  FileMode := 2; // set to read/write
End;
// read_ge

// start TIF
Procedure TDICOM.read_tiff_data(Var lReadOffsets: boolean);
Label
  566, 564;
Const
  kMaxnSLices = 6000;
Var
  lLongRA: LongIntp;
  lStackSameDim, lContiguous: boolean;
  l1stDicomData: TMedicalImageData;
  // lDouble : double;
  // lXmm,lYmm,lZmm: double;
  lSingle: single;
  lImageDataEndPosition, lStripPositionOffset, lStripPositionType,
    lStripPositionItems, lStripCountOffset, lStripCountType, lStripCountItems,
    lItem, lTagItems, lTagItemBytes, lTagPointer, lNumerator, lDenominator,
    lImage_File_Directory, lTagType, lVal, lDirOffset, lOffset, lFileSz,
    lnDirectories, lDir, lnSlices: integer;
  lTag, lWord, lWord2: word;
  FP: File;

  Function read64r(lPos: integer): double;
  Var
    s: double;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 8);
    result := ToLittleEndian(s, data.little_endian);
  End;

  Function read32i(lPos: LongInt): LongInt;
  Var
    s: LongInt;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 4);
    result := ToLittleEndian(s, data.little_endian);
  End;
  Function read16(lPos: LongInt): LongInt;
  Var
    s: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 2);
    result := ToLittleEndian(s, data.little_endian);
  End;

  Function read8(lPos: LongInt): LongInt;
  Var
    s: byte;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 1);
    result := s;
  End;

  Function readItem(lItemNum, lTagTypeI, lTagPointerI: integer): integer;
  Begin
    If lTagTypeI = 4 Then
      result := read32i(lTagPointerI + ((lItemNum - 1) * 4))
    Else
      result := read16(lTagPointerI + ((lItemNum - 1) * 2));
  End;

Begin
  clear;
  If gECATJPEG_table_entries <> 0 Then
  Begin
    freemem(gECATJPEG_pos_table);
    freemem(gECATJPEG_size_table);
    gECATJPEG_table_entries := 0;
  End;
  // lXmm := -1; //not read
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  // lLongRASz := kMaxnSlices * sizeof(longint);
  getmem(lLongRA, kMaxnSLices * SizeOf(LongInt));
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  lFileSz := FileSize(FP);
  clear;
  data.PlanarConfig := 0;
  If lFileSz < (28) Then
  Begin
    // showmessage('This file is to small to be a TIFF image.');
    Goto 566;
  End;
  // TmpStr := string(StrUpper(PAnsiChar(ExtractFileExt(lFileName))));
  // if not (TmpStr = '.TIF') or (TmpStr = '.TIFF') then exit;
  lWord := read16(0);
  If lWord = $4D4D Then
    data.little_endian := 0
  Else If lWord = $4949 Then
    data.little_endian := 1;
  lWord2 := read16(2); // bits per pixel
  If ((lWord = $4D4D) Or (lWord = $4949)) And (lWord2 = $002A) Then
  Else
    Goto 566;
  lOffset := read32i(4);
  lImage_File_Directory := 0;
  lContiguous := true;
  lnSlices := 0;
  data.SamplesPerPixel := 1;
  // START while for each image_file_directory
  While (lOffset > 0) And ((lOffset + 2 + 12 + 4) < lFileSz) Do
  Begin
    inc(lImage_File_Directory);
    lnDirectories := read16(lOffset);
    If (lnDirectories < 1) Or ((lOffset + 2 + (12 * lnDirectories) + 4) >
      lFileSz) Then
      Goto 566;
    For lDir := 1 To lnDirectories Do
    Begin
      lDirOffset := lOffset + 2 + ((lDir - 1) * 12);
      lTag := read16(lDirOffset);
      lTagType := read16(lDirOffset + 2);
      lTagItems := read32i(lDirOffset + 4);
      Case lTagType Of
        1:
          lVal := 1; // bytes
        3:
          lVal := 2; // word
        4:
          lVal := 4; // long
        5:
          lVal := 8; // rational
      Else
        lVal := 1; // AnsiChar variable length
      End;
      lTagItemBytes := lVal * lTagItems;
      If lTagItemBytes > 4 Then
        lTagPointer := read32i(lDirOffset + 8)
      Else
        lTagPointer := (lDirOffset + 8);
      Case lTagType Of
        1:
          lVal := read8(lDirOffset + 8);
        3:
          lVal := read16(lDirOffset + 8);
        4:
          lVal := read32i(lDirOffset + 8);
        5:
          Begin // rational: two longs representing numerator and denominator
            lVal := read32i(lDirOffset + 8);
            lNumerator := read32i(lVal);
            lDenominator := read32i(lVal + 4);
            If lDenominator <> 0 Then
              lSingle := lNumerator / lDenominator
            Else
              lSingle := 1;
            If lSingle <> 0 Then
              lSingle := 1 / lSingle;
            // Xresolution/Yresolution refer to number of pixels per resolution_unit
            If lTag = 282 Then
              data.XYZmm[1] := lSingle;
            If lTag = 283 Then
              data.XYZmm[2] := lSingle;
          End;
      Else
        lVal := 0;
      End;
      Case lTag Of
        // 254: ;//NewSubFileType
        256:
          data.XYZdim[1] := lVal; // image_width
        257:
          data.XYZdim[2] := lVal; // image_height
        258:
          Begin // bits per sample
            If lTagItemBytes > 4 Then
              lVal := 8;
            // if lVal <> 8 then goto 566;
            data.Allocbits_per_pixel := lVal; // bits
            data.Storedbits_per_pixel := data.Allocbits_per_pixel;
          End;
        259:
          Begin
            If lVal <> 1 Then
            Begin
              showmessage
                ('TIFF Read Error: Image data is compressed. Currently only uncompressed data is supported.');
              Goto 566; // compressed data
            End;
          End;
        262:
          If lVal = 0 Then
            data.monochrome := 1;
        // invert colors //photometric_interpretation  //MinIsWhite,MinIsBlack,Palette
        // 270: ; //ImageDescription
        273:
          Begin // get offset to data
            lStripPositionOffset := lTagPointer;
            lStripPositionType := lTagType;
            lStripPositionItems := lTagItems;
            If (lImage_File_Directory = 1) Then
              data.ImageStart := readItem(1, lStripPositionType,
                lStripPositionOffset);
          End; // StripOffsets
        // 274: ; //orientation
        277:
          Begin
            data.SamplesPerPixel := lVal;
            // showmessage(IntToStr(Data.SamplesPerPixel));
            // if lVal <> 1 then goto 566; //samples per pixel
          End;
        // 278: showmessage('278rowsPerStrip'+IntToStr(lTagItems));//RowsPerStrip Used for compression, usually about 8kb
        279:
          Begin
            lStripCountOffset := lTagPointer;
            lStripCountType := lTagType;
            lStripCountItems := lTagItems;
          End;
        // 278: showmessage('rows:'+IntToStr(lVal));//StripByteCount
        // 279: showmessage('count:'+IntToStr(lVal));//StripByteCount
        // 282 and 283 are rational values and read separately
        284:
          Begin
            If lVal = 1 Then
              data.PlanarConfig := 0
            Else
              data.PlanarConfig := 1; // planarConfig
          End;
        34412:
          Begin
            // Zeiss data header
            // 0020h  float       x size of a pixel (µm or s)
            // 0024h  float       y size of a pixel (µm or s)
            // 0028h  float       z distance in a sequence (µm or s)
            { stream.seek((int)position + 40);
              VOXELSIZE_X = swap(stream.readDouble());
              stream.seek((int)position + 48);
              VOXELSIZE_Y = swap(stream.readDouble());
              stream.seek((int)position + 56);
              VOXELSIZE_Z = swap(stream.readDouble()); }
            lVal := read16(lTagPointer + 2);
            If lVal = 1024 Then
            Begin // LSM510 v2.8 images
              data.XYZmm[1] { lXmm } := read64r(lTagPointer + 40) * 1000000;
              data.XYZmm[2] { lYmm } := read64r(lTagPointer + 48) * 1000000;
              data.XYZmm[3] { lZmm } := read64r(lTagPointer + 56) * 1000000;
            End;
            // following may work if lVal = 2, different type of LSM file I have not seen
            // lXmm := longint2single(read32i(lTagPointer+$0020));
            // lYmm := longint2single(read32i(lTagPointer+$0024));
            // lZmm := longint2single(read32i(lTagPointer+$0028));
            // showmessage(floattostr(lXmm)+':'+floattostr(lYmm)+':'+floattostr(lZmm));
          End;
        // 296: ;//resolutionUnit 1=undefined, 2=inch, 3=centimeter
        // 320??
        // LEICA: 34412
        // SOFTWARE = 305
        // DATE_TIME = 306
        // ARTIST = 315
        // PREDICTOR = 317
        // COLORMAP = 320 => essntially custom LookUpTable
        // EXTRASAMPLES = 338
        // SAMPLEFORMAT = 339
        // JPEGTABLES = 347
        // Data.ImageStart := lVal
        // else if lImage_File_Directory = 1 then showmessage(IntToStr(lTag)+'@'+IntToStr(lTagPointer)+' value: '+IntToStr(lVal));
      End; // case lTag{}
    End; // For Each Directory in Image_File_Directory
    lOffset := read32i(lOffset + 2 + (12 * lnDirectories));
    // NEXT: check that each slice in 3D slice is the same dimension
    lStackSameDim := true;
    If (lImage_File_Directory = 1) Then
    Begin
      l1stDicomData := data;
      lnSlices := 1; // inc(lnSlices);
    End
    Else
    Begin
      If data.XYZdim[1] <> l1stDicomData.XYZdim[1] Then
        lStackSameDim := false;
      If data.XYZdim[2] <> l1stDicomData.XYZdim[2] Then
        lStackSameDim := false;
      If data.Allocbits_per_pixel <> l1stDicomData.Allocbits_per_pixel Then
        lStackSameDim := false;
      If data.SamplesPerPixel <> l1stDicomData.SamplesPerPixel Then
        lStackSameDim := false;
      If data.PlanarConfig <> l1stDicomData.PlanarConfig Then
        lStackSameDim := false;
      If Not lStackSameDim Then
      Begin
        // showmessage(IntToStr(Data.XYZdim[1])+'x'+IntToStr(l1stDicomData.XYZdim[1]));
        If (data.XYZdim[1] * data.XYZdim[2]) >
          (l1stDicomData.XYZdim[1] * l1stDicomData.XYZdim[2]) Then
        Begin
          l1stDicomData := data;
          lnSlices := 1;
          lStackSameDim := true;
        End;
        // showmessage('TIFF Read Error: Different 2D slices in this 3D stack have different dimensions.');
        // goto 566;
      End
      Else
        inc(lnSlices); // if not samedim
    End; // check that each slice is same dimension as 1st
    // END check each 2D slice in 3D stack is same dimension
    // NEXT: check if image data is contiguous
    If (lStripCountItems > 0) And (lStripCountItems = lStripPositionItems) Then
    Begin
      If (lnSlices = 1) Then
        lImageDataEndPosition := data.ImageStart;
      For lItem := 1 To lStripCountItems Do
      Begin
        lVal := readItem(lItem, lStripPositionType, lStripPositionOffset);
        If (lVal <> lImageDataEndPosition) Then
          lContiguous := false;
        // showmessage(IntToStr(lImage_File_Directory)+'@'+IntToStr(lItem));
        lImageDataEndPosition := lImageDataEndPosition +
          readItem(lItem, lStripCountType, lStripCountOffset);
        If Not lContiguous Then
        Begin
          If (lReadOffsets) And (lStackSameDim) Then
          Begin
            lLongRA[lnSlices] := lVal;
          End
          Else If (lReadOffsets) Then
            // not correct size, but do not generate an error as we will read non-contiguous files
          Else
          Begin
            showmessage
              ('TIFF Read Error: Image data is not stored contiguously. ' +
              'Solution: convert this image using MRIcro''s ''Convert TIFF/Zeiss to Analyze...'' command [Import menu].');
            Goto 564;
          End;
        End; // if not contiguous
      End; // for each item
    End; // at least one StripItem}
    // END check image data is contiguous
  End; // END while each Image_file_directory
  data := l1stDicomData;
  data.XYZdim[3] := lnSlices;
  If (lReadOffsets) And (lnSlices > 1) And (Not lContiguous) Then
  Begin
    gECATJPEG_table_entries := lnSlices; // Offset tables for TIFF
    getmem(gECATJPEG_pos_table, gECATJPEG_table_entries * SizeOf(LongInt));
    getmem(gECATJPEG_size_table, gECATJPEG_table_entries * SizeOf(LongInt));
    gECATJPEG_pos_table[1] := l1stDicomData.ImageStart;
    For lVal := 2 To gECATJPEG_table_entries Do
      gECATJPEG_pos_table[lVal] := lLongRA[lVal]
  End;
  lHdrOk := true;
564:
  lDynStr := 'TIFF image' + kCR + 'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/' +
    IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR +
    'XYZ size [mm or micron]:' + floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/'
    + floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
    floattostrf(data.XYZmm[3], ffFixed, 8, 2) + kCR +
    'Bits per sample/Samples per pixel: ' + IntToStr(data.Allocbits_per_pixel) +
    '/' + IntToStr(data.SamplesPerPixel) + kCR + 'Data offset:' +
    IntToStr(data.ImageStart);
  { if lXmm > 0 then
    lDynStr := lDynStr +kCR+'Zeiss XYZ mm:'+floattostr(lXmm)+'/'
    +floattostr(lYmm)+'/'
    +floattostr(lZmm); }
566:
  freemem(lLongRA);
  // showmessage(IntToStr(lTag)+'@'+IntToStr(lVal)+'@'+floattostr(lSingle));
  closefile(FP);
  FileMode := 2; // set to read/write
End; // tiff

Procedure TDICOM.read_biorad_data;
Var
  lCh: AnsiChar;
  lByte: byte;
  lSpaces, liPos, lFileSz, lWord, lNotes, lStart, lEnd: integer;
  tx: Array [0 .. 80] Of AnsiChar;
  lInfo, lStr, lTmpStr: String;
  FP: File;
  Procedure read16(lPos: LongInt; Out lVal: integer); Overload;
  Var
    lInWord: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInWord, 2);
    lVal := lInWord;
  End;
  Procedure read32(lPos: LongInt; Out lVal: integer); Overload;
  Var
    lInINt: integer;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInINt, 4);
    lVal := lInINt;
  End;
  Procedure read16(lPos: LongInt; Out lVal: uint32); Overload;
  Var
    lInWord: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInWord, 2);
    lVal := lInWord;
  End;
  Procedure read32(lPos: LongInt; Out lVal: uint32); Overload;
  Var
    lInINt: integer;
  Begin
    seek(FP, lPos);
    BlockRead(FP, lInINt, 4);
    lVal := lInINt;
  End;

Begin
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  lFileSz := FileSize(FP);
  clear;
  If lFileSz < (77) Then
    exit; // to small to be biorad
  read16(54, lWord);
  If (lWord = 12345) Then
  Begin
    data.little_endian := 1;
    read16(0, data.XYZdim[1]);
    read16(2, data.XYZdim[2]);
    read16(4, data.XYZdim[3]);
    read16(14, lWord); // byte format
    If lWord = 1 Then
      data.Allocbits_per_pixel := 8
    Else
      data.Allocbits_per_pixel := 16; // bits
    data.Storedbits_per_pixel := data.Allocbits_per_pixel;
    data.ImageStart := 76;
    read32(10, lNotes);
    lStart := (data.XYZdim[1] * data.XYZdim[2] * data.XYZdim[3]) + 76;
    lEnd := lStart + 96;
    lDynStr := 'BIORAD PIC image' + kCR;
    While (lNotes > 0) And (lFileSz >= lEnd) Do
    Begin
      read32(lStart + 2, lNotes); // final note has bytes 2..5 set to zero
      // read16(lStart+10,lNoteType);
      // if lNoteType <> 1 then begin //ignore 'LIVE' notes - they do not include calibration info
      seek(FP, lStart + 16);
      BlockRead(FP, tx, 80 { , n } );
      lStr := '';
      liPos := 0;
      Repeat
        lCh := tx[liPos];
        lByte := ord(lCh);
        If (lByte >= 32) And (lByte <= 126) Then
          lStr := lStr + lCh
        Else
          lByte := 0;
        inc(liPos);
      Until (liPos = 80) Or (lByte = 0);
      If Length(lStr) > 6 Then
      Begin
        lInfo := '';
        For liPos := 1 To 6 Do
          lInfo := lInfo + upcase(lStr[liPos]);
        lTmpStr := '';
        lSpaces := 0;
        For liPos := 1 To 80 Do
        Begin
          If lStr[liPos] = ' ' Then
            inc(lSpaces)
          Else If lSpaces = 3 Then
            lTmpStr := lTmpStr + lStr[liPos];
        End;
        If lTmpStr = '' Then { no value to read }
        Else If lInfo = 'AXIS_2' Then
          data.XYZmm[1] := str2float(lTmpStr)
        Else If lInfo = 'AXIS_3' Then
          data.XYZmm[2] := str2float(lTmpStr)
        Else If lInfo = 'AXIS_4' Then
          data.XYZmm[3] := str2float(lTmpStr);
        lDynStr := lDynStr + lStr + kCR;
      End; // Str length > 6
      // end;//notetype
      lStart := lEnd;
      lEnd := lEnd + 96;
    End; // while notes
    lHdrOk := true;
    // lImageFormatOK := true;
  End; // biorad signature
  closefile(FP);
  FileMode := 2; // set to read/write
  lDynStr := 'BioRad image' + kCR + 'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/'
    + IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR +
    'XYZ size [mm or micron]:' + floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/'
    + floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
    floattostrf(data.XYZmm[3], ffFixed, 8, 2) + kCR +
    'Bits per sample/Samples per pixel: ' + IntToStr(data.Allocbits_per_pixel) +
    '/' + IntToStr(data.SamplesPerPixel) + kCR + 'Data offset:' +
    IntToStr(data.ImageStart);
End; // biorad

Procedure TDICOM.clear;
Begin
  Inherited clear(data);
  red_table_size := 0;
  green_table_size := 0;
  blue_table_size := 0;
  red_table := Nil;
  green_table := Nil;
  blue_table := Nil;
End;

Constructor TDICOM.Create(lFileName: TFileName; Progreso: TGaugeFloat;
  signed: boolean);
Begin
  self.lFileName := lFileName;
  Read_DICOM_HDR(lFileName);
  data.signed := signed; // DICOM is always signed???
  If (data.XYZdim[3] <= 1) Then
  Begin
    ReadDICOMDir(Progreso);
    data.XYZdim[3] := gFileList.Count;
  End
  Else
  Begin
    Image := Read_Image3D;
    datacreated := true;
  End;
End;

Procedure TDICOM.LoadFileList(FileName: TFileName);
// Searches for other DICOM images in the same folder (so user can cycle through images
Var
  lSearchRec: TSearchRec;
  lName, lFilePath, lFilenameWOPath, lExt: String;
  lSz, lDICMcode: integer;
  lDICM: boolean;
  FP: File;
  lIndex: DWord;
  lInc, lItems: LongInt; // vixen
  lDICOMData: TMedicalImageData; // vixen
  lRepeatedValues: boolean; // vixen
  miFilename, lFoldername: String; // vixen
  lStringList: TStringList; // vixen
  // lTimeD:DWord;
  lIndexRA: LongIntp { DWordP };
  lPositionRA { ,lIndexRA } : LongIntp; // vixen
Begin
  lFilePath := ExtractFilePath(FileName);
  lStudyPath := lFilePath;
  lFilenameWOPath := extractfilename(FileName);
  lExt := ExtractFileExt(FileName);
  lDICOMData := data;
  If gFileList <> Nil Then
    gFileList.Free;
  gFileList := TStringList.Create;
  If Length(lExt) > 0 Then
    For lSz := 1 To Length(lExt) Do
      lExt[lSz] := upcase(lExt[lSz]);
  If (data.NamePos > 0) Then
  Begin // real DICOM file
    If FindFirst(lFilePath + '*.*', faAnyFile - faSysFile - faDirectory,
      lSearchRec) = 0 Then
    Begin
      Repeat
        // if copy(lSearchRec.Name,1,20)=copy(lFilenameWOPath,1,20) then begin  //no siempre ocurre
        lExt := AnsiUpperCase(ExtractFileExt(lSearchRec.Name));
        lName := AnsiUpperCase(lSearchRec.Name);
        If (lSearchRec.size > 1024) And (lName <> 'DICOMDIR') Then
        Begin
          lDICM := false;
          If ('.DCM' = lExt) Then
            lDICM := true;
          If ('.DCM' <> lExt) Then
          Begin
            FileMode := 0;
            assignfile(FP, lFilePath + lSearchRec.Name);
            Try
              FileMode := 0; // read only - might be CD
              Reset(FP, 1);
              seek(FP, 128);
              BlockRead(FP, lDICMcode, 4);
              If lDICMcode = 1296255300 Then
                lDICM := true;
            Finally
              closefile(FP);
            End; // try..finally open file
            FileMode := 2; // read/write
          End; // Ext <> DCM
          If lDICM Then
          Begin
            miFilename := lFilePath + lName;
            Read_DICOM_HDR(miFilename);
            If lDICOMData.PatientID = data.PatientID Then
              gFileList.Add(lSearchRec.Name); { }
          End;
        End; // FileSize > 512
      Until (FindNext(lSearchRec) <> 0);
      FileMode := 2;
    End; // some files found
    SysUtils.FindClose(lSearchRec);
    If gFileList.Count > 0 Then
    Begin
      { start vixen }
      lItems := gFileList.Count;
      getmem(lIndexRA, lItems * SizeOf(LongInt { DWord } ));
      getmem(lPositionRA, lItems * SizeOf(LongInt));
      lFoldername := extractfiledir(FileName);
      // lTimeD := GetTickCount;
      For lInc := 1 To lItems Do
      Begin
        miFilename := lFoldername + pathdelim + gFileList.Strings[lInc - 1];
        Read_DICOM_HDR(miFilename);
        lIndex := (int64(data.PatientIDint And $FFFF) Shl 32) +
          (int64(data.SeriesNum And $FF) Shl 24) +
          (int64(data.AcquNum And $FF) Shl 16) + data.ImageNum;
        lIndexRA[lInc] := lIndex;
        lPositionRA[lInc] := lInc;
      End;
      // lTimeD := GetTickCount-lTimeD; //70 ms
      ShellSortItems(1, lItems, lPositionRA, lIndexRA, lRepeatedValues);

      If Not lRepeatedValues Then
      Begin
        lStringList := TStringList.Create;
        For lInc := 1 To lItems Do
          lStringList.Add(gFileList[lPositionRA[lInc] - 1]);
        For lInc := 1 To lItems Do
          gFileList[lInc - 1] := lStringList[lInc - 1];
        // put sorted items into correct list
        lStringList.Free;
      End
      Else
        gFileList.Sort; // repeated index - sort name by filename instead
      // sort stringlist based on indexRA
      freemem(lPositionRA);
      freemem(lIndexRA);
      { end vixen }
      For lSz := (gFileList.Count - 1) Downto 0 Do
      Begin
        If gFileList.Strings[lSz] = lFilenameWOPath Then
          CurrentPosInFileList := lSz;
      End;
    End;
    FileListSz := gFileList.Count;

  End
  Else
    gFileList.Add(lFilenameWOPath); // NamePos > 0    *)
  data := lDICOMData;
End; (* *)

Procedure TDICOM.read_afni_data(Var lRotation1, lRotation2,
  lRotation3: integer);
// label 333;
Const
  UNIXeoln = chr(10);
  kTab = ord(chr(9));
  kSpace = ord(' ');
Var
  lTmpStr, lInStr, lUpCaseStr: String;
  lHdrEnd: boolean;
  lMSBch: Char;
  lOri: Array [1 .. 4] Of single;
  lTmpInt, lPos, lLen, filesz, linPos: integer;
  FP: File;
  lCharRA: ByteP;
  Procedure readAFNIeoln;
  Begin
    While (linPos < filesz) And (lCharRA[linPos] <> ord(kCR)) And
      (lCharRA[linPos] <> ord(UNIXeoln)) Do
      inc(linPos);
    inc(linPos); // read EOLN
  End;
  Function readAFNIFloat: real;
  Var
    lStr: String;
    lCh: Char;
  Begin
    lStr := '';
    While (linPos < filesz) And
      ((lStr = '') Or ((lCharRA[linPos] <> kTab) And
      (lCharRA[linPos] <> kSpace))) Do
    Begin
      lCh := chr(lCharRA[linPos]);
      If charinset(lCh, ['+', '-', 'e', 'E', '.', '0' .. '9']) Then
        lStr := lStr + lCh;
      inc(linPos);
    End;
    // showmessage(lStr);
    // exit;
    If lStr = '' Then
      exit;
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

(* function readInterStr:string;
  var lStr: string;
  begin
  lStr := '';
  While (lPos <= lLen) and (lInStr[lPos] = ' ') do begin
  inc(lPos);
  end;
  While (lPos <= lLen) and (lInStr[lPos] <> ';') do begin
  lStr := lStr+upcase(linStr[lPos]); //zebra upcase
  inc(lPos);
  end;
  result := lStr;
  end; //interstr func *)
Begin
  lHdrOk := false;
  lImageFormatOK := true;
  clear;
  lDynStr := '';
  lTmpStr := String(StrUpper(PAnsiChar(ExtractFileExt(lFileName))));
  If lTmpStr <> '.HEAD' Then
    exit;
  For linPos := 1 To 3 Do
    lOri[linPos] := -6666;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  lHdrEnd := false;
  // Data.ImageStart := FileSz;
  getmem(lCharRA, filesz + 1);
  BlockRead(FP, lCharRA^, filesz, linPos);
  If linPos <> filesz Then
    showmessage('Disk error: Unable to read full input file.');
  linPos := 1;
  closefile(FP);
  FileMode := 2; // set to read/write
  Repeat
    lInStr := '';
    While (linPos < filesz) And (lCharRA[linPos] <> ord(kCR)) And
      (lCharRA[linPos] <> ord(UNIXeoln)) Do
    Begin
      lInStr := lInStr + chr(lCharRA[linPos]);
      inc(linPos);
    End;
    inc(linPos); // read EOLN
    lLen := Length(lInStr);
    lPos := 1;
    lUpCaseStr := '';
    While (lPos <= lLen) Do
    Begin
      If charinset(lInStr[lPos], ['_', '[', ']', '(', ')', '/', '+', '-', '=',
        { ' ', } '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
        lUpCaseStr := lUpCaseStr + upcase(lInStr[lPos]);
      inc(lPos);
    End;
    inc(lPos); { read equal sign in := statement }
    If lUpCaseStr = 'NAME=DATASET_DIMENSIONS' Then
    Begin
      lImageFormatOK := true;
      lHdrOk := true;
      lFileName := ParseFileName(lFileName) + '.BRIK'; // always UPPERcase
      readAFNIeoln;
      data.XYZdim[1] := round(readAFNIFloat);
      data.XYZdim[2] := round(readAFNIFloat);
      data.XYZdim[3] := round(readAFNIFloat);
      // Data.ImageStart := 2048 * round(readInterFloat);
    End;
    If lUpCaseStr = 'NAME=BRICK_FLOAT_FACS' Then
    Begin
      readAFNIeoln;
      data.IntenScale := readAFNIFloat; // 1380 read slope of intensity
    End;
    If lUpCaseStr = 'NAME=DATASET_RANK' Then
    Begin
      readAFNIeoln;
      // 2nd value is number of volumes
      readAFNIFloat;
      data.XYZdim[4] := round(readAFNIFloat);
      // showmessage(IntToStr((Data.XYZdim[4])));
    End;
    If lUpCaseStr = 'NAME=BRICK_TYPES' Then
    Begin
      readAFNIeoln;
      lTmpInt := round(readAFNIFloat);
      Case lTmpInt Of
        0:
          data.Allocbits_per_pixel := 8;
        1:
          Begin
            data.Allocbits_per_pixel := 16;
            // Data.MaxIntensity := 65535; //Old AFNI were UNSIGNED, new ones are SIGNED???
          End;
        3:
          Begin
            data.Allocbits_per_pixel := 32;
            data.float := true;
          End;
      Else
        Begin
          lHdrEnd := true;
          showmessage('Unsupported AFNI BRICK_TYPES: ' + IntToStr(lTmpInt));
        End;

      End; // case
      { datatype
        0 = byte    (unsigned AnsiChar; 1 byte)
        1 = short   (2 bytes, signed)
        3 = float   (4 bytes, assumed to be IEEE format)
        5 = complex (8 bytes: real+imaginary parts) }
    End;
    If lUpCaseStr = 'NAME=BYTEORDER_STRING' Then
    Begin
      readAFNIeoln;
      If ((linPos + 2) < filesz) Then
      Begin
        lMSBch := chr(lCharRA[linPos + 1]);
        // showmessage(lMSBch);
        If lMSBch = 'L' Then
          data.little_endian := 1;
        If lMSBch = 'M' Then
        Begin
          data.little_endian := 0;
        End;
        linPos := linPos + 2;
      End;
      // littleendian
    End;
    If lUpCaseStr = 'NAME=ORIGIN' Then
    Begin
      readAFNIeoln;
      lOri[1] := (abs(readAFNIFloat));
      lOri[2] := (abs(readAFNIFloat));
      lOri[3] := (abs(readAFNIFloat));
      { Data.XYZori[1] := round(abs(readAFNIFloat));
        Data.XYZori[2] := round(abs(readAFNIFloat));
        Data.XYZori[3] := round(abs(readAFNIFloat));
      }     // Xori,YOri,ZOri
    End;
    If lUpCaseStr = 'NAME=DELTA' Then
    Begin
      readAFNIeoln;
      data.XYZmm[1] := abs(readAFNIFloat);
      data.XYZmm[2] := abs(readAFNIFloat);
      data.XYZmm[3] := abs(readAFNIFloat);
      // showmessage('xxx');
      // Xmm,Ymm,Zmm
    End;
    If lUpCaseStr = 'NAME=ORIENT_SPECIFIC' Then
    Begin
      readAFNIeoln;
      lRotation1 := round(readAFNIFloat);
      lRotation2 := round(readAFNIFloat);
      lRotation3 := round(readAFNIFloat);
    End; // ORIENT_SPECIFIC rotation details
    If lInStr <> '' Then
      lDynStr := lDynStr + lInStr + kCR;
  Until (linPos >= filesz) Or (lHdrEnd) { EOF(fp) };
  data.Storedbits_per_pixel := data.Allocbits_per_pixel;
  For linPos := 1 To 3 Do
  Begin
    // showmessage(floattostr(lOri[lInPos]));
    If lOri[linPos] < -6666 Then // value not set
      data.XYZori[linPos] := round((1.0 + data.XYZdim[linPos]) / 2)
    Else If data.XYZmm[linPos] <> 0 Then
      data.XYZori[linPos] := round(1.5 + lOri[linPos] / data.XYZmm[linPos]);
    // showmessage(floattostr(lOri[lInPos])+'@'+floattostr(Data.XYZori[lInPos] ));
  End;
  // Data.Float := true;
  freemem(lCharRA);
End; // interfile

// afni end
Procedure TDICOM.read_VFF_data;
Label 333;
Const
  UNIXeoln = chr(10);
Var
  lInStr, lUpCaseStr: String;
  // lHdrEnd: boolean;
  lPos, lLen, filesz, linPos: integer;
  lDummy1, lDummy2, lDummy3: double;
  FP: File;
  lCharRA: ByteP;
  Procedure readVFFvals(Var lFloat1, lFloat2, lFloat3: double);
  Var
    lStr: String;
    lDouble: double;
    lInc: integer;
  Begin
    For lInc := 1 To 3 Do
    Begin
      lStr := '';
      While (lPos <= lLen) And (lInStr[lPos] = ' ') Do
      Begin
        inc(lPos);
      End;
      While (lPos <= lLen) And (lInStr[lPos] <> ';') And
        (lInStr[lPos] <> ' ') Do
      Begin
        If charinset(lInStr[lPos], ['+', '-', 'e', 'E', '.', '0' .. '9']) Then
          lStr := lStr + (lInStr[lPos]);
        inc(lPos);
      End;
      If lStr <> '' Then
      Begin
        Try
          lDouble := str2float(lStr);
        Except
          On EConvertError Do
          Begin
            showmessage('Unable to convert the string ' + lStr +
              ' to a number');
            // lDouble := 1;
            exit;
          End;
        End; { except }
        Case lInc Of
          2:
            lFloat2 := lDouble;
          3:
            lFloat3 := lDouble;
        Else
          lFloat1 := lDouble;
        End;
      End; // lStr <> ''
    End; // lInc 1..3
  End; // interstr func

Begin
  lHdrOk := false;
  lImageFormatOK := true;
  clear;
  data.little_endian := 0; // big-endian
  lDynStr := '';
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  If filesz > 2047 Then
    filesz := 2047;
  getmem(lCharRA, filesz + 1);
  BlockRead(FP, lCharRA^, filesz, linPos);
  If linPos <> filesz Then
    showmessage('Disk error: Unable to read full input file.');
  linPos := 1;
  While (lCharRA[linPos] <> 12) And (linPos < filesz) Do
  Begin
    inc(linPos);
  End;
  inc(linPos);
  If (linPos >= filesz) Or (linPos < 12) Then
    Goto 333; // unable to find
  lDynStr := lDynStr + 'Sun VFF Volume File Format' + kCR;
  data.ImageStart := linPos;
  filesz := linPos - 1;
  linPos := 1;
  closefile(FP);
  FileMode := 2; // set to read/write
  Repeat
    lInStr := '';
    While (linPos < filesz) And (lCharRA[linPos] <> ord(kCR)) And
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
      (lUpCaseStr <> 'NCAA') Do
    Begin
      If charinset(lInStr[lPos], ['[', ']', '(', ')', '/', '+', '-',
        { ' ', } '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
        lUpCaseStr := lUpCaseStr + upcase(lInStr[lPos]);
      inc(lPos);
    End;
    inc(lPos); { read equal sign in := statement }
    If lUpCaseStr = 'NCAA' Then
    Begin
      lHdrOk := true;
    End;
    If lUpCaseStr = 'BITS' Then
    Begin
      lDummy1 := 8;
      readVFFvals(lDummy1, lDummy2, lDummy3);
      data.Allocbits_per_pixel := round(lDummy1);
    End;
    If lUpCaseStr = 'SIZE' Then
    Begin
      lDummy1 := 1;
      lDummy2 := 1;
      lDummy3 := 1;
      readVFFvals(lDummy1, lDummy2, lDummy3);
      data.XYZdim[1] := round(lDummy1);
      data.XYZdim[2] := round(lDummy2);
      data.XYZdim[3] := round(lDummy3);
    End;
    If lUpCaseStr = 'ASPECT' Then
    Begin
      lDummy1 := 1;
      lDummy2 := 1;
      lDummy3 := 1;
      readVFFvals(lDummy1, lDummy2, lDummy3);
      data.XYZmm[1] := (lDummy1);
      data.XYZmm[2] := (lDummy2);
      data.XYZmm[3] := (lDummy3);
    End;
    If Not lHdrOk Then
      Goto 333;
    If lInStr <> '' Then
      lDynStr := lDynStr + lInStr + kCR;
    // lHdrOK := true;
  Until (linPos >= filesz);
  data.Storedbits_per_pixel := data.Allocbits_per_pixel;
  lImageFormatOK := true;
333:
  freemem(lCharRA);
End;
// end VFF

// start PAR
Procedure TDICOM.read_PAR_data(lReadOffsetTables: boolean;
  Var lOffset_pos_table: LongIntp; Var lOffsetTableEntries: integer;
  lReadVaryingScaleFactors: boolean; Var lVaryingScaleFactors_table,
  lVaryingIntercept_table: Singlep; Var lVaryingScaleFactorsTableEntries,
  lnum4Ddatasets: integer);
Label 333; // 1384 now reads up to 8 dimensional data....
Type
  tRange = Record
    Min, Val, Max: double; // some vals are ints, others floats
  End;
Const
  UNIXeoln = chr(10);
  kMaxnSLices = 32000;
  kXdim = 1;
  kYdim = 2;
  kBitsPerVoxel = 3;
  kSliceThick = 4;
  kSliceGap = 5;
  kXmm = 6;
  kYmm = 7;
  kSlope = 8;
  kIntercept = 9;
  kDynTime = 10;
  kSlice = 11;
  kEcho = 12;
  kDyn = 13;
  kCardiac = 14;
  kType = 15;
  kSequence = 16;
  kIndex = 17;
Var
  lErrorStr, lInStr, lUpCaseStr, lReportedTRStr { ,lUpcase20Str } : String;
  lSliceSequenceRA, lSortedSliceSequence: LongIntp;
  lSliceIndexRA: Array [1 .. kMaxnSLices] Of LongInt;
  lSliceSlopeRA, lSliceInterceptRA: Array [1 .. kMaxnSLices] Of single;
  lSliceHeaderRA: Array [1 .. 32] Of double;
  lRepeatedValues, lSlicesNotInSequence, lIsParVers3: boolean;
  // ,lMissingVolumes,{,lLongRAtooSmall,lMissingVolumes,lConstantScale,lContiguousSlices,}
  lRangeRA: Array [kXdim .. kIndex] Of tRange;
  lMaxSlice, lMaxIndex, lSliceSz, lSliceInfoCount, lPos, lLen, lFileSz, lHdrPos,
    linPos, lInc: integer;
  FP: File;
  lCharRA: ByteP;
  Procedure MinMaxTRange(Var lDimension: tRange; lNewVal: double); // nested
  Begin
    lDimension.Val := lNewVal;
    If lSliceInfoCount < 2 Then
    Begin
      lDimension.Min := lDimension.Val;
      lDimension.Max := lDimension.Val;
    End;
    If lNewVal < lDimension.Min Then
      lDimension.Min := lNewVal;
    If lNewVal > lDimension.Max Then
      lDimension.Max := lNewVal;
  End; // nested InitTRange proc
  Function readParStr: String; // nested
  Var
    lStr: String;
  Begin
    lStr := '';
    While (lPos <= lLen) Do
    Begin
      If (lStr <> '') Or (lInStr[lPos] <> ' ') Then // strip leading spaces
        lStr := lStr + (lInStr[lPos]);
      inc(lPos);
    End; // while lPOs < lLen
    result := lStr;
  End; // nested func ReadParStr
  Function readParFloat: double; // nested
  Var
    lStr: String;
  Begin
    lStr := '';
    result := 1;
    While (lPos <= lLen) And ((lStr = '') Or (lInStr[lPos] <> ' ')) Do
    Begin
      If charinset(lInStr[lPos], ['+', '-', 'e', 'E', '.', '0' .. '9']) Then
        lStr := lStr + (lInStr[lPos]);
      inc(lPos);
    End;
    If lStr = '' Then
      exit;
    Try
      result := str2float(lStr);
    Except
      On EConvertError Do
      Begin
        showmessage('read_PAR_data: Unable to convert the string ' + lStr +
          ' to a number');
        result := 1;
        exit;
      End;
    End; { except }
  End; // nested func ReadParFloat
// ********************************************************************

Begin
  // Initialize parameters
  lnum4Ddatasets := 1;
  lIsParVers3 := true;
  lSliceInfoCount := 0;
  For lInc := kXdim To kIndex Do
    // initialize all values: important as PAR3 will not explicitly report all
    MinMaxTRange(lRangeRA[lInc], 0);
  lHdrOk := false;
  lImageFormatOK := false;
  lOffsetTableEntries := 0;
  lVaryingScaleFactorsTableEntries := 0;
  clear;
  lDynStr := '';
  // Read text header to buffer (lCharRA)
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  lFileSz := FileSize(FP);
  getmem(lCharRA, lFileSz + 1);
  // note: must free dynamic memory: goto 333 if any error
  getmem(lSliceSequenceRA, kMaxnSLices * SizeOf(LongInt));
  // note: must free dynamic memory: goto 333 if any error
  BlockRead(FP, lCharRA^, lFileSz, linPos);
  If linPos <> lFileSz Then
  Begin
    showmessage('read_PAR_data: Disk error, unable to read full input file.');
    Goto 333;
  End;
  linPos := 1;
  closefile(FP);
  FileMode := 2; // set to read/write
  // Next: read each line of header file...
  Repeat // for each line in file....
    lInStr := '';
    While (linPos < lFileSz) And (lCharRA[linPos] <> ord(kCR)) And
      (lCharRA[linPos] <> ord(UNIXeoln)) Do
    Begin
      lInStr := lInStr + chr(lCharRA[linPos]);
      inc(linPos);
    End;
    inc(linPos); // read EOLN
    lLen := Length(lInStr);
    lPos := 1;
    lUpCaseStr := '';
    If lLen < 1 Then
      // ignore blank lines
    Else If (lInStr[1] = '*') And (Not lHdrOk) Then // # -> comment
      // ignore comment lines prior to start of header
    Else If (lInStr[1] = '#') And (lHdrOk) Then // # -> comment
      // ignore comment lines
    Else If (lInStr[1] = '.') Or (Not lHdrOk) Then
    Begin // GENERAL_INFORMATION section (line starts with '.')
      // Note we also read in lines that do not have '.' if we have HdrOK=false, this allows us to detect the DATADESCRIPTIONFILE signature
      While (lPos <= lLen) And (lInStr[lPos] <> ':') And
        ((Not lHdrOk) Or (lInStr[lPos] <> '#')) Do
      Begin
        If charinset(lInStr[lPos], ['[', ']', '(', ')', '/', '+', '-',
          { ' ', } '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
          lUpCaseStr := lUpCaseStr + upcase(lInStr[lPos]);
        inc(lPos);
      End; // while reading line
      inc(lPos); { read equal sign in := statement }
      lDynStr := lDynStr + lInStr + kCR;
      // showmessage(IntToStr(length(lUpCaseStr)));
      If (Not lHdrOk) And (lUpCaseStr = ('DATADESCRIPTIONFILE')) Then
      Begin // 1389 PAR file
        lHdrOk := true;
        data.little_endian := 1;
      End;

      (* if (not lHdrOK) and (length(lUpCaseStr) >= 19) then begin
        //lUpcase20Str := xx
        lUpcase20Str := '';
        for lInc := 1 to 19 do
        lUpcase20Str := lUpCase20Str + lUpcaseStr[lInc];
        //showmessage(lUpcase20Str);
        if (lUpcase20Str = ('DATADESCRIPTIONFILE')) or (lUpcase20Str = ('EXPERIMENTALPRIDEDA')) then begin //PAR file
        lHdrOK := true;
        Data.little_endian := 1;
        end;
        end;
      *)
      If (lUpCaseStr = 'REPETITIONTIME[MSEC]') Then
        data.TR := round(readParFloat);
      If (lUpCaseStr = 'MAXNUMBEROFSLICES/LOCATIONS') Then
        data.XYZdim[3] := round(readParFloat);
      If (lUpCaseStr = 'SLICETHICKNESS[MM]') Then
        MinMaxTRange(lRangeRA[kSliceThick], readParFloat);
      If (lUpCaseStr = 'SLICEGAP[MM]') Then
        MinMaxTRange(lRangeRA[kSliceGap], readParFloat);
      { if lUpCaseStr = 'FOV(APFHRL)[MM]' then begin
        Data.XYZmm[2] :=  (readParFloat); //AP anterior->posterior
        Data.XYZmm[3] :=  (readParFloat); //FH foot head
        Data.XYZmm[1] :=  (readParFloat); //RL Right-Left
        end;
        if lUpCaseStr = 'SCANRESOLUTION(XY)' then begin
        lScanResX :=  round(readParFloat);
        lScanResY :=  round(readParFloat);
        end;
        if lUpCaseStr = 'SCANPERCENTAGE' then begin
        lScanPct :=  round(readParFloat);
        end; }
      If lUpCaseStr = 'RECONRESOLUTION(XY)' Then
      Begin
        MinMaxTRange(lRangeRA[kXdim], readParFloat);
        MinMaxTRange(lRangeRA[kYdim], readParFloat);
      End;
      If lUpCaseStr = 'RECONSTRUCTIONNR' Then
        data.AcquNum := round(readParFloat);
      If lUpCaseStr = 'ACQUISITIONNR' Then
        data.SeriesNum := round(readParFloat);
      If lUpCaseStr = 'MAXNUMBEROFDYNAMICS' Then
      Begin
        data.XYZdim[4] := round(readParFloat);
      End;
      If lUpCaseStr = 'EXAMINATIONDATE/TIME' Then
        data.StudyDate := readParStr;
      If lUpCaseStr = 'PROTOCOLNAME' Then
        data.Modality := readParStr;
      If lUpCaseStr = 'PATIENTNAME' Then
        data.PatientName := readParStr;
      If lUpCaseStr = 'IMAGEPIXELSIZE[8OR16BITS]' Then
      Begin
        MinMaxTRange(lRangeRA[kBitsPerVoxel], readParFloat);
      End;
      If Not lHdrOk Then
      Begin
        showmessage('read_PAR_data: Error reading header');
        Goto 333;
      End;
    End
    Else
    Begin // SliceInfo: IMAGE_INFORMATION (line does NOT start with '.' or '#')
      inc(lSliceInfoCount);
      If (lSliceInfoCount < 2) And (lRangeRA[kBitsPerVoxel].Val < 1) Then
        // PARvers3 has imagedepth in general header, only in image header for later versions
        lIsParVers3 := false;
      For lHdrPos := 1 To 26 Do
        lSliceHeaderRA[lHdrPos] := readParFloat;
      // The next few values are in the same location for both PAR3 and PAR4
      MinMaxTRange(lRangeRA[kSlice], round(lSliceHeaderRA[1]));
      MinMaxTRange(lRangeRA[kEcho], round(lSliceHeaderRA[2]));
      MinMaxTRange(lRangeRA[kDyn], round(lSliceHeaderRA[3]));
      MinMaxTRange(lRangeRA[kCardiac], round(lSliceHeaderRA[4]));
      MinMaxTRange(lRangeRA[kType], round(lSliceHeaderRA[5]));
      MinMaxTRange(lRangeRA[kSequence], round(lSliceHeaderRA[6]));
      MinMaxTRange(lRangeRA[kIndex], round(lSliceHeaderRA[7]));
      If lIsParVers3 Then
      Begin // Read PAR3 data
        MinMaxTRange(lRangeRA[kIntercept], lSliceHeaderRA[8]);;
        // 8=intercept in PAR3
        MinMaxTRange(lRangeRA[kSlope], lSliceHeaderRA[9]); // 9=slope in PAR3
        MinMaxTRange(lRangeRA[kXmm], lSliceHeaderRA[23]);
        // 23 PIXEL SPACING X  in PAR3
        MinMaxTRange(lRangeRA[kYmm], lSliceHeaderRA[24]);
        // 24 PIXEL SPACING Y IN PAR3
        MinMaxTRange(lRangeRA[kDynTime], (lSliceHeaderRA[26]));
        // 26= dyn_scan_begin_time in PAR3
      End
      Else
      Begin // not PAR: assume PAR4
        For lHdrPos := 27 To 32 Do
          lSliceHeaderRA[lHdrPos] := readParFloat;
        MinMaxTRange(lRangeRA[kBitsPerVoxel], lSliceHeaderRA[8]);
        // 8 BITS in PAR4
        MinMaxTRange(lRangeRA[kXdim], lSliceHeaderRA[10]); // 10 XDim in PAR4
        MinMaxTRange(lRangeRA[kYdim], lSliceHeaderRA[11]); // 11 YDim in PAR4
        MinMaxTRange(lRangeRA[kIntercept], lSliceHeaderRA[12]);
        // 12=intercept in PAR4
        MinMaxTRange(lRangeRA[kSlope], lSliceHeaderRA[13]);
        // 13=lslope in PAR4
        MinMaxTRange(lRangeRA[kSliceThick], lSliceHeaderRA[23]);
        // 23 SLICE THICK in PAR4
        MinMaxTRange(lRangeRA[kSliceGap], lSliceHeaderRA[24]);
        // 24 SLICE GAP in PAR4
        MinMaxTRange(lRangeRA[kXmm], lSliceHeaderRA[29]);
        // 29 PIXEL SPACING X  in PAR4
        MinMaxTRange(lRangeRA[kYmm], lSliceHeaderRA[30]);
        // 30 PIXEL SPACING Y in PAR4
        MinMaxTRange(lRangeRA[kDynTime], (lSliceHeaderRA[32]));
        // 32= dyn_scan_begin_time in PAR4
      End; // PAR4
      If lSliceInfoCount < kMaxnSLices Then
      Begin
        lSliceSequenceRA[lSliceInfoCount] :=
          ((round(lRangeRA[kSequence].Val) + round(lRangeRA[kType].Val) +
          round(lRangeRA[kCardiac].Val + lRangeRA[kEcho].Val)) Shl 24) +
          (round(lRangeRA[kDyn].Val) Shl 10) + round(lRangeRA[kSlice].Val);
        lSliceSlopeRA[lSliceInfoCount] := lRangeRA[kSlope].Val;
        lSliceInterceptRA[lSliceInfoCount] := lRangeRA[kIntercept].Val;
        lSliceIndexRA[lSliceInfoCount] := round(lRangeRA[kIndex].Val);
      End;
    End; // SliceInfo Line
  Until (linPos >= lFileSz); // until done reading entire file...
  // describe generic DICOM parameters
  data.XYZdim[1] := round(lRangeRA[kXdim].Val);
  data.XYZdim[2] := round(lRangeRA[kYdim].Val);
  data.XYZdim[3] := 1 + round(lRangeRA[kSlice].Max - lRangeRA[kSlice].Min);
  If (lSliceInfoCount Mod data.XYZdim[3]) <> 0 Then
    showmessage
      ('read_PAR_data: Total number of slices not divisible by number of slices per volume. Reconstruction error?');
  If data.XYZdim[3] > 0 Then
    data.XYZdim[4] := lSliceInfoCount Div data.XYZdim[3]
    // nVolumes = nSlices/nSlicePerVol
  Else
    data.XYZdim[4] := 1;

  data.XYZmm[1] := lRangeRA[kXmm].Val;
  data.XYZmm[2] := lRangeRA[kYmm].Val;
  data.XYZmm[3] := lRangeRA[kSliceThick].Val + lRangeRA[kSliceGap].Val;
  data.Allocbits_per_pixel := round(lRangeRA[kBitsPerVoxel].Val);
  data.IntenScale := lRangeRA[kSlope].Val;
  data.IntenIntercept := lRangeRA[kIntercept].Val;

  // Next: report number of Dynamic scans, this allows people to parse DynScans from Type/Cardiac/Echo/Sequence 4D files
  lnum4Ddatasets := (round(lRangeRA[kDyn].Max - lRangeRA[kDyn].Min) + 1) *
    data.XYZdim[3]; // slices in each dynamic session
  If ((lSliceInfoCount Mod lnum4Ddatasets) = 0) And
    ((lSliceInfoCount Div lnum4Ddatasets) > 1) Then
    lnum4Ddatasets := (lSliceInfoCount Div lnum4Ddatasets)
    // infer multiple Type/Cardiac/Echo/Sequence
  Else
    lnum4Ddatasets := 1;
  // next: Determine actual interscan interval
  If (data.XYZdim[4] > 1) And ((lRangeRA[kDynTime].Max - lRangeRA[kDynTime].Min)
    > 0) { 1384 } Then
  Begin
    lReportedTRStr := 'Reported TR: ' + floattostrf(data.TR, ffFixed,
      8, 2) + kCR;
    data.TR := (lRangeRA[kDynTime].Max - lRangeRA[kDynTime].Min) /
      (data.XYZdim[4] - 1) * 1000; // infer TR in ms
  End
  Else
    lReportedTRStr := '';
  // next: report header details
  lDynStr := 'Philips PAR/REC Format' // 'PAR/REC Format'
    + kCR + 'Patient name:' + data.PatientName + kCR + 'XYZ dim: ' +
    IntToStr(data.XYZdim[1]) + '/' + IntToStr(data.XYZdim[2]) + '/' +
    IntToStr(data.XYZdim[3]) + kCR + 'Volumes: ' + IntToStr(data.XYZdim[4]) +
    kCR + 'XYZ mm: ' + floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/' +
    floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' + floattostrf(data.XYZmm[3],
    ffFixed, 8, 2) + kCR + 'TR: ' + floattostrf(data.TR, ffFixed, 8, 2) + kCR +
    lReportedTRStr + kCR + lDynStr;
  // if we get here, the header is fine, next steps will see if image format is readable...
  lHdrOk := true;
  If lSliceInfoCount < 1 Then
    Goto 333;
  // next: see if slices are in sequence
  lSlicesNotInSequence := false;
  If lSliceInfoCount > 1 Then
  Begin
    lMaxSlice := lSliceSequenceRA[1];
    lMaxIndex := lSliceIndexRA[1];
    lInc := 1;
    Repeat
      inc(lInc);
      If lSliceSequenceRA[lInc] < lMaxSlice Then
        // not in sequence if image has lower slice order than previous image
        lSlicesNotInSequence := true
      Else
        lMaxSlice := lSliceSequenceRA[lInc];
      If lSliceIndexRA[lInc] < lMaxIndex Then
        // not in sequence if image has lower slice index than previous image
        lSlicesNotInSequence := true
      Else
        lMaxIndex := lSliceIndexRA[lInc];
    Until (lInc = lSliceInfoCount) Or (lSlicesNotInSequence);
  End; // at least 2 slices
  // Next: report any errors
  lErrorStr := '';
  If (lSlicesNotInSequence) And (Not lReadOffsetTables) Then
    lErrorStr := lErrorStr +
      ' Slices not saved sequentially [using MRIcro''s ''Philips PAR to Analyze'' command may solve this]'
      + kCR;
  If lSliceInfoCount > kMaxnSLices Then
    lErrorStr := lErrorStr + ' Too many slices: >' +
      IntToStr(kMaxnSLices) + kCR;
  If (Not lReadVaryingScaleFactors) And
    ((lRangeRA[kSlope].Min <> lRangeRA[kSlope].Max) Or
    (lRangeRA[kIntercept].Min <> lRangeRA[kIntercept].Max)) Then
    lErrorStr := lErrorStr +
      ' Differing intensity slope/intercept [using MRIcro''s ''Philips PAR to Analyze'' command may solve this]'
      + kCR;
  If (lRangeRA[kBitsPerVoxel].Min <> lRangeRA[kBitsPerVoxel].Max) Then
    // 5D file space+time+cardiac
    lErrorStr := lErrorStr + ' Differing bits per voxel' + kCR;
  // if (lRangeRA[kCardiac].min <> lRangeRA[kCardiac].max) then  //5D file space+time+cardiac
  // lErrorStr := lErrorStr + 'Multiple cardiac timepoints'+kCR;
  // if (lRangeRA[kEcho].min <> lRangeRA[kEcho].max) then  //5D file space+time+echo
  // lErrorStr := lErrorStr + 'Multiple echo timepoints'+kCR;
  If (lRangeRA[kSliceThick].Min <> lRangeRA[kSliceThick].Max) Or
    (lRangeRA[kSliceGap].Min <> lRangeRA[kSliceGap].Max) Or
    (lRangeRA[kXdim].Min <> lRangeRA[kXdim].Max) Or
    (lRangeRA[kYdim].Min <> lRangeRA[kYdim].Max) Or
    (lRangeRA[kXmm].Min <> lRangeRA[kXmm].Max) Or
    (lRangeRA[kYmm].Min <> lRangeRA[kYmm].Max) Then
    lErrorStr := lErrorStr + ' Multiple/varying slice dimensions' + kCR;
  // if any errors were encountered, report them....
  If lErrorStr <> '' Then
  Begin
    showmessage
      ('read_PAR_data: This software can not convert this Philips data:' + kCR +
      lErrorStr);
    Goto 333;
  End;
  // Next sort image indexes here...
  If (lSliceInfoCount > 1) And (lSlicesNotInSequence) And
    (lReadOffsetTables) Then
  Begin // sort image order...
    // ShellSort (first, last: integer; var lPositionRA, lIndexLoRA,lIndexHiRA: LongintP; var lRepeatedValues: boolean)
    getmem(lOffset_pos_table, lSliceInfoCount * SizeOf(LongInt));
    For lInc := 1 To lSliceInfoCount Do
      lOffset_pos_table[lInc] := lInc;
    ShellSortItems(1, lSliceInfoCount, lOffset_pos_table, lSliceSequenceRA,
      lRepeatedValues);
    { for lInc := 1 to  lSliceInfoCount do
      if (lInc > 79) and (lInc < 84) then
      showmessage(IntToStr(lInc)+'@'+IntToStr(lOffset_pos_table[lInc]));{ }
    If lRepeatedValues Then
    Begin
      showmessage
        ('read_PAR_data: fatal error, slices do not appear to have unique indexes [multiple copies of same slice]');
      freemem(lOffset_pos_table);
      Goto 333;
    End;
    lOffsetTableEntries := lSliceInfoCount;
  End; // sort image order...
  // Next, generate list of scale slope
  If (lSliceInfoCount > 1) And (lReadVaryingScaleFactors) And
    ((lRangeRA[kSlope].Min <> lRangeRA[kSlope].Max) Or
    (lRangeRA[kIntercept].Min <> lRangeRA[kIntercept].Max)) Then
  Begin { create offset LUT }
    lVaryingScaleFactorsTableEntries := lSliceInfoCount;
    getmem(lVaryingScaleFactors_table, lVaryingScaleFactorsTableEntries *
      SizeOf(single));
    getmem(lVaryingIntercept_table, lVaryingScaleFactorsTableEntries *
      SizeOf(single));
    If lOffsetTableEntries = lSliceInfoCount Then
    Begin // need to sort slices
      For lInc := 1 To lSliceInfoCount Do
      Begin
        lVaryingScaleFactors_table[lInc] :=
          lSliceSlopeRA[lOffset_pos_table[lInc]];
        lVaryingIntercept_table[lInc] := lSliceInterceptRA
          [lOffset_pos_table[lInc]];
      End;
    End
    Else
    Begin // if sorted, else unsorted
      For lInc := 1 To lSliceInfoCount Do
      Begin
        lVaryingScaleFactors_table[lInc] := lSliceSlopeRA[lInc];
        lVaryingIntercept_table[lInc] := lSliceInterceptRA[lInc];
      End;
    End; // slices sorted
  End; // read scale factors
  // Next: now adjust Offsets to point to byte offset instead of slice number
  lSliceSz := data.XYZdim[1] * data.XYZdim[2] *
    (data.Allocbits_per_pixel Div 8);
  If lOffsetTableEntries = lSliceInfoCount Then
    For lInc := 1 To lSliceInfoCount Do
      lOffset_pos_table[lInc] := lSliceSz *
        (lSliceIndexRA[lOffset_pos_table[lInc]]);
  // report if 5D/6D/7D file is being saved as 4D
  If (lRangeRA[kCardiac].Min <> lRangeRA[kCardiac].Max) Or
    (lRangeRA[kEcho].Min <> lRangeRA[kEcho].Max) // 5D file space+time+echo
    Or (lRangeRA[kType].Min <> lRangeRA[kType].Max) // 5D file space+time+echo
    Or (lRangeRA[kSequence].Min <> lRangeRA[kSequence].Max) Then
    // 5D file space+time+echo
    showmessage
      ('Warning: note that this image has more than 4 dimensions (multiple Cardiac/Echo/Type/Sequence)');
  // if we get here, the Image Format is OK
  lImageFormatOK := true;
  lFileName := ChangeFileExt(lFileName, '.rec');
  // for Linux: case sensitive extension search '.rec' <> '.REC'
333: // abort clause: skips lHdrOK and lImageFormatOK
  // next: free dynamically allocated memory
  freemem(lCharRA);
  freemem(lSliceSequenceRA);
End;

// end PAR
// start siemens
Procedure TDICOM.read_siemens_data;
Label
  567;
Var
  lI: word;
  lYear, lMonth, lDay, N, filesz, lFullSz, lMatrixSz, lIHour, lIMin,
    lISec { ,lAHour,lAMin,lASec } : LongInt;
  lFlipAngle, lGap, lSliceThick: double;
  tx: Array [0 .. 26] Of AnsiChar;
  lMagField, lTE, lTR: double;
  lInstitution, lName, lID, lMinStr, lSecStr { ,lAMinStr,lASecStr } : String;
  FP: File;
  Function swap32i(lPos: LongInt): LongInt;
  Var
    s: LongInt;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 4, N);
    swap32i := fswap4(s)
  End;
  Function fswap8r(lPos: LongInt): double;
  Var
    s: double;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 8, N);
    fswap8r := ubyteorder.fswap8r(s);
  End;

Begin
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  clear;
  If filesz < (6144) Then
  Begin
    showmessage('This file is to small to be a Siemens Magnetom Vision image.');
    Goto 567;
  End;
  seek(FP, 96);
  BlockRead(FP, tx, 7 * AnsiCharSz, N);
  If (tx[0] <> 'S') OR (tx[1] <> 'I') OR (tx[2] <> 'E') OR (tx[3] <> 'M') Then
  Begin { manufacturer is not SIEMENS }
    showmessage
      ('Is this a Siemens Magnetom Vision image [Manufacturer tag should be ''SIEMENS''].');
    Goto 567;
  End; { manufacturer not siemens }
  seek(FP, 105);
  BlockRead(FP, tx, 25 * AnsiCharSz, N);
  lInstitution := '';
  For lI := 0 To 24 Do
  Begin
    If charinset(tx[lI], ['/', '\', 'a' .. 'z', 'A' .. 'Z', ' ', '+', '-', '.',
      ',', '0' .. '9']) Then
      lInstitution := lInstitution + tx[lI];
  End;
  seek(FP, 768);
  BlockRead(FP, tx, 25 * AnsiCharSz, N);
  lName := '';
  For lI := 0 To 24 Do
  Begin
    If charinset(tx[lI], ['/', '\', 'a' .. 'z', 'A' .. 'Z', ' ', '+', '-', '.',
      ',', '0' .. '9']) Then
      lName := lName + tx[lI];
  End;
  seek(FP, 795);
  BlockRead(FP, tx, 12 * AnsiCharSz, N);
  lID := '';
  For lI := 0 To 11 Do
  Begin
    If charinset(tx[lI], ['/', '\', 'a' .. 'z', 'A' .. 'Z', ' ', '+', '-', '.',
      ',', '0' .. '9']) Then
      lID := lID + tx[lI];
  End;
  data.ImageStart := 6144;
  lYear := swap32i(0);
  lMonth := swap32i(4);
  lDay := swap32i(8);
  { lAHour := swap32i(52);
    lAMin := swap32i(56);
    lASec := swap32i(60); }
  lIHour := swap32i(68);
  lIMin := swap32i(72);
  lISec := swap32i(76);
  data.XYZmm[3] := fswap8r(1544);
  lMagField := fswap8r(2560);
  lTR := fswap8r(1560);
  lTE := fswap8r(1568);
  // showmessage(IntToStr(swap32i(3212)));
  data.AcquNum := swap32i(3212);
  lMatrixSz := swap32i(2864);
  data.SiemensSlices := swap32i(4004); // 1366
  // lFullSz := swap32i(4008);
  // lInterleaveIf4 := swap32i(2888);
  lFullSz := (2 * lMatrixSz * lMatrixSz); // 16bitdata
  If ((filesz - 6144) Mod lFullSz) = 0 Then
  Begin
    Case ((filesz - 6144) Div lFullSz) Of
      4:
        lFullSz := 2 * lMatrixSz;
      9:
        lFullSz := 3 * lMatrixSz;
      16:
        lFullSz := 4 * lMatrixSz;
      25:
        lFullSz := 5 * lMatrixSz;
      36:
        lFullSz := 6 * lMatrixSz;
      49:
        lFullSz := 7 * lMatrixSz;
      64:
        lFullSz := 8 * lMatrixSz;
    Else
      lFullSz := lMatrixSz;
    End;
  End
  Else
    lFullSz := lMatrixSz;
  { 3744/3752 are XY FOV in mm! }
  data.XYZdim[1] := lFullSz; // lMatrixSz; //width
  data.XYZdim[2] := lFullSz; // lMatrixSz;//height
  { 5000/5008 are size in mm, but wrong for mosaics }
  // showmessage(floattostr(fswap8r (3856))+'@'+floattostr(fswap8r (3864)));
  If lMatrixSz <> 0 Then
  Begin
    data.XYZmm[2] := fswap8r(3744) / lMatrixSz;
    data.XYZmm[1] := fswap8r(3752) / lMatrixSz;
    If ((data.XYZdim[1] Mod lMatrixSz) = 0) Then
      data.SiemensMosaicX := data.XYZdim[1] Div lMatrixSz;
    If ((data.XYZdim[2] Mod lMatrixSz) = 0) Then
      data.SiemensMosaicY := data.XYZdim[2] Div lMatrixSz;
    If data.SiemensMosaicX < 1 Then
      data.SiemensMosaicX := 1; // 1366
    If data.SiemensMosaicY < 1 Then
      data.SiemensMosaicY := 1; // 1366
  End;
  lFlipAngle := fswap8r(2112); // 1414
  { Data.XYZmm[2] := fswap8r (5000);
    Data.XYZmm[1] := fswap8r (5008); }
  lSliceThick := data.XYZmm[3];
  lGap := fswap8r(4136); // gap as ratio of slice thickness?!?!
  If { lGap > 0 } (lGap = -1) Or (lGap = -19222) Then
    // 1410: exclusion values: do not ask me why 19222: from John Ashburner
  Else
  Begin
    // Data.XYZmm[3] := abs(Data.XYZmm[3] * (1+lGap));
    lGap := data.XYZmm[3] * (lGap);
    data.XYZmm[3] := abs(data.XYZmm[3] + lGap);
  End;
  data.Allocbits_per_pixel := 16; // bits
  data.Storedbits_per_pixel := data.Allocbits_per_pixel;
  data.GenesisCpt := false;
  data.GenesisPackHdr := 0;
  lMinStr := IntToStr(lIMin);
  If Length(lMinStr) = 1 Then
    lMinStr := '0' + lMinStr;
  lSecStr := IntToStr(lISec);
  If Length(lSecStr) = 1 Then
    lSecStr := '0' + lSecStr;
  { lAMinStr := IntToStr(lAMin);
    if length(lAMinStr) = 1 then lAMinStr := '0'+lAMinStr;
    lASecStr := IntToStr(lASec);
    if length(lASecStr) = 1 then lASecStr := '0'+lASecStr; }

  lDynStr := 'Siemens Magnetom Vision Format' + kCR + 'Name: ' + lName + kCR +
    'ID: ' + lID + kCR + 'Institution: ' + lInstitution + kCR +
    'Study DD/MM/YYYY: ' + IntToStr(lDay) + '/' + IntToStr(lMonth) + '/' +
    IntToStr(lYear) + kCR + 'Image Hour/Min/Sec: ' + IntToStr(lIHour) + ':' +
    lMinStr + ':' + lSecStr + kCR +
  // 'Acquisition Hour/Min/Sec: '+IntToStr(lAHour)+':'+lAMinStr+':'+lASecStr+kCR+
    'Magnetic Field Strength: ' + floattostrf(lMagField, ffFixed, 8, 2) + kCR +
    'Image index: ' + IntToStr(data.AcquNum) + kCR +
    'Time Repitition/Echo [TR/TE]: ' + floattostrf(lTR, ffFixed, 8, 2) + '/' +
    floattostrf(lTE, ffFixed, 8, 2) + kCR + 'Flip Angle: ' +
    floattostrf(lFlipAngle, ffFixed, 8, 2) + kCR + 'Slice Thickness/Gap: ' +
    floattostrf(lSliceThick, ffFixed, 8, 2) + '/' + floattostrf(lGap, ffFixed,
    8, 2) + kCR + 'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/' +
    IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR +
    'XY matrix:' + IntToStr(data.SiemensMosaicX) + '/' +
    IntToStr(data.SiemensMosaicY) + kCR + 'XYZ mm:' + floattostrf(data.XYZmm[1],
    ffFixed, 8, 2) + '/' + floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
    floattostrf(data.XYZmm[3], ffFixed, 8, 2);
  lHdrOk := true;
  // Data.AcquNum := 0;
567:
  closefile(FP);
  FileMode := 2; // set to read/write
End;

// end siemens
// minc
Procedure TDICOM.read_minc_data;
Var
  // lReal: double;
  lnOri, lnDim, lStartPosition, nelem0, jj, lDT0, vSizeRA, BeginRA, m, nnelem,
    nc_type, nc_size, lLen, nelem, j, lFilePosition, lDT, lFileSz, lSignature,
    lWord: integer;

  lOri: Array [1 .. 3] Of double;
  // tx     : array [0..80] of AnsiChar;
  lVarStr, lStr: String;
  FP: File;
  Function dTypeStr(lV: integer): integer;
  Begin
    Case lV Of
      1, 2:
        result := 1;
      3:
        result := 2; // int16
      4:
        result := 4; // int32
      5:
        result := 4; // single
      6:
        result := 8; // double
    End;
  End; // nested fcn dTypeStr

  Function read32i: LongInt;
  Var
    s: LongInt;
  Begin
    seek(FP, lFilePosition);
    lFilePosition := lFilePosition + 4;
    BlockRead(FP, s, 4);
    result := ToLittleEndian(s, data.little_endian);
  End;

  Function read64r(lDataType: integer): double;
  Var
    s: double;
  Begin
    result := 1;
    If lDataType <> 6 Then
    Begin
      showmessage
        ('Unknown data type: MRIcro is unable to determine the voxel size.');
      exit;
    End;
    seek(FP, lFilePosition);
    lFilePosition := lFilePosition + 8;
    BlockRead(FP, s, 8);
    result := ToLittleEndian(s, data.little_endian);
  End;

  Function readname: String;
  Var
    lI, lLen: integer;
    lCh: AnsiChar;
  Begin
    result := '';
    seek(FP, lFilePosition);
    lLen := read32i;
    If lLen < 1 Then
    Begin
      showmessage
        ('Terminal error reading netCDF/MINC header (String length < 1)');
      exit; // problem
    End;
    For lI := 1 To lLen Do
    Begin
      BlockRead(FP, lCh, 1);
      result := result + lCh;
    End;
    lFilePosition := lFilePosition + (((lLen + 3) Div 4) * 4);
  End;

Begin
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  For lnOri := 1 To 3 Do
    lOri[lnOri] := 0;
  lnOri := 4;
  lnDim := 4;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  lFileSz := FileSize(FP);
  clear;
  If lFileSz < (77) Then
    exit; // to small to be MINC
  { if (tx[0]='C') and (tx[1]='D') and (tx[2]='F') and (ord(tx[3]) = 1) then begin
    CloseFile(fp);
    if lDiskCacheSz > 0 then
    freemem(lDiskCacheRA);
    FileMode := 2; //set to read/write
    //read_minc_data(Data, lVerboseRead,lReadECAToffsetTables,lHdrOK, lImageFormatOK, lDynStr, lFileName);
    Showmessage('minc');
    exit;

    end; }
  lFilePosition := 0;
  lSignature := read32i;
  If Not(lSignature = 1128547841) Then
  Begin
    closefile(FP);
    FileMode := 2; // set to read/write
    showmessage('Problem with MINC signature: ' + IntToStr(lSignature));
    exit;
  End;
  // Showmessage('MINC format file. Warning: MRIcro employs a primitive MINC reader. You may get better results with minc2ana.');
  data.Rotate180deg := true;
  lWord := read32i; // numrecs
  lDT := read32i;
  While (lDT = 10) Or (lDT = 11) Or (lDT = 12) Do
  Begin
    If lDT = 10 Then
    Begin // DT=10, Dimensions
      nelem := read32i;
      For j := 1 To nelem Do
      Begin
        lStr := readname;
        lLen := read32i;
        If lStr = 'xspace' Then
          data.XYZdim[3] := lLen;
        // DOES MINC always reverse X and Z? see also XYZmm
        If lStr = 'yspace' Then
          data.XYZdim[2] := lLen;
        If lStr = 'zspace' Then
          data.XYZdim[1] := lLen;
        // Showmessage(IntToStr(lDT)+':'+lStr+IntToStr(lLen));
        // if j < 5 then
        // Data.XYZdim[j] := lLen;
      End; // for 1..nelem
      lDT := read32i;
    End; // DT=10, Dimensions
    If lDT = 11 Then
    Begin // DT=11, Variables
      nelem := read32i;
      For j := 1 To nelem Do
      Begin
        lVarStr := readname;
        nnelem := read32i;
        // Showmessage(lVarStr);
        // Showmessage(IntToStr(lDT)+':'+lVarStr+IntToStr(lLen));
        For m := 1 To nnelem Do
          lLen := read32i;
        lDT0 := read32i;
        If lDT0 = 12 Then
        Begin
          nelem0 := read32i;
          For jj := 1 To nelem0 Do
          Begin
            lStr := readname;
            nc_type := read32i;
            nc_size := dTypeStr(nc_type);
            nnelem := read32i;
            lStartPosition := lFilePosition;
            { if nc_Type = 2 then begin
              //read string here
              end else
              Showmessage('Unspecified Type'+IntToStr(nc_Type)); }
            If (lStr = 'step') Then
            Begin
              (* if lVarStr = 'xspace' then
                Data.XYZmm[3] := read64r(nc_Type)
                else if lVarStr = 'yspace' then
                Data.XYZmm[2] := read64r(nc_Type)
                else if lVarStr = 'zspace' then
                Data.XYZmm[1] := read64r(nc_Type);
                showmessage(lVarStr); *)
              If (lVarStr = 'xspace') Or (lVarStr = 'yspace') Or
                (lVarStr = 'zspace') Then
              Begin
                dec(lnDim);
                If (lnDim < 4) And (lnDim > 0) Then
                  data.XYZmm[lnDim] := read64r(nc_type)
              End;

            End
            Else If (lStr = 'start') Then
            Begin
              // showmessage(lVarStr);
              If (lVarStr = 'xspace') Or (lVarStr = 'yspace') Or
                (lVarStr = 'zspace') Then
              Begin
                dec(lnOri);
                If (lnOri < 4) And (lnOri > 0) Then
                  lOri[lnOri] := read64r(nc_type)
              End;
              // showmessage(lVarStr+floattostr(lReal));
            End; { }
            // showmessage(lStr); //spacing
            lFilePosition := lStartPosition +
              ((((nnelem * nc_size) + 3) Div 4) * 4);
            // if lVarStr = 'image' then begin
            // if lStr = 'signtype' then ;
            // Showmessage(lVarStr+IntToStr(jj)+'/'+IntToStr(nelem0)+'NESTED DT11:DT12'+lStr);
            // end;
          End;
          lDT0 := read32i;
          If lVarStr = 'image' Then
          Begin
            Case lDT0 Of
              1, 2:
                data.Allocbits_per_pixel := 8;
              3:
                data.Allocbits_per_pixel := 16; // int16
              4:
                data.Allocbits_per_pixel := 32; // int32
              5:
                data.Allocbits_per_pixel := 32; // single
              6:
                data.Allocbits_per_pixel := 64; // double
              7:
                data.Allocbits_per_pixel := 80; // extended
            End;
            If (lDT0 In [5 .. 7]) Then
              data.float := true;
            data.Storedbits_per_pixel := data.Allocbits_per_pixel;
            // lImgNC_Type := lDT0;
          End;
          // Showmessage('END DT11:DT12='+IntToStr(lDT0));
        End;
        vSizeRA := read32i;
        BeginRA := read32i;
        If lVarStr = 'image' Then
        Begin
          // Showmessage(IntToStr(BeginRA)+'DONE');
          data.ImageStart := BeginRA;
        End;
      End; // for 1..nelem
      lDT := read32i;
    End; // DT=11
    If lDT = 12 Then
    Begin // DT=12, Attributes
      nelem := read32i;
      For j := 1 To nelem Do
      Begin
        lStr := readname;
        // Showmessage(IntToStr(lDT)+':'+lStr+IntToStr(lLen));
        nc_type := read32i;
        nc_size := dTypeStr(nc_type);
        nnelem := read32i;
        { if nc_Type = 2 then begin
          //read string here
          end else
          Showmessage(IntToStr(nc_Type)); }
        lFilePosition := lFilePosition + ((((nnelem * nc_size) + 3) Div 4) * 4);
        // Showmessage(lStr);
      End; // for 1..nelem
      lDT := read32i;
    End; // DT=12, Dimensions
  End; // while DT

  If lOri[1] <> 0 Then
    data.XYZori[1] := round((-lOri[1]) / data.XYZmm[1]) + 1;
  If lOri[2] <> 0 Then
    data.XYZori[2] := round((-lOri[2]) / data.XYZmm[2]) + 1;
  If lOri[3] <> 0 Then
    data.XYZori[3] := round((-lOri[3]) / data.XYZmm[3]) + 1;
  // Data.XYZori[1] := round(lOri[1]);
  // Data.XYZori[2] := round(lOri[2]);
  // Data.XYZori[3] := round(lOri[3]);
  lDynStr := 'MINC image' + kCR + 'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/' +
    IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR +
    'XYZ origin:' + IntToStr(data.XYZori[1]) + '/' + IntToStr(data.XYZori[2]) +
    '/' + IntToStr(data.XYZori[3]) + kCR + 'XYZ size [mm or micron]:' +
    floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/' + floattostrf(data.XYZmm[2],
    ffFixed, 8, 2) + '/' + floattostrf(data.XYZmm[3], ffFixed, 8, 2) + kCR +
    'Bits per sample/Samples per pixel: ' + IntToStr(data.Allocbits_per_pixel) +
    '/' + IntToStr(data.SamplesPerPixel) + kCR + 'Data offset:' +
    IntToStr(data.ImageStart);
  lHdrOk := true;
  lImageFormatOK := true;
  closefile(FP);
  FileMode := 2; // set to read/write
End; // read_minc

// ECAT
Procedure TDICOM.read_ecat_data(lVerboseRead, lReadECAToffsetTables: boolean);
Label
  121, 539;
Const
  kMaxnSLices = 6000;
  kStrSz = 40;
Var
  lLongRA: LongIntp;
  lECAT7sigUpcase, lECAT7sig: Array [0 .. 6] Of AnsiChar;
  lParse, lSPos, lFPos { ,lScomplement } , lF, lS, lYear, lFrames, lVox,
    lHlfVox, lJ, lPass, lVolume, lNextDirectory, lSlice, lSliceSz, lVoxelType,
    lPos, lEntry, lSlicePos, lLongRApos, lLongRAsz,
  { lSingleRApos,lSingleRAsz, }{ lMatri, } lX, lY, lZ, lCacheSz, lImgSz,
    lTransferred, lSubHeadStart, lMatrixStart, lMatrixEnd, lInt, lInt2, lInt3,
    lINt4, N, filesz: LongInt;
  lPlanes, lGates, lAqcType, lFileType, lI, lWord, lWord22: word;
  lXmm, lYmm, lZmm, lCalibrationFactor, lQuantScale: real;
  FP: File;
  lCreateTable, lSwapBytes, lMR, lECAT6: boolean;
  Function xWord(lPos: LongInt): word;
  Var
    s: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 2, N);
    If lSwapBytes Then
      result := system.swap(s)
    Else
      result := s; // assign address of s to inguy
  End;

  Function swap32i(lPos: LongInt): LongInt;
  Var
    s: LongInt;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 4, N);
    swap32i := fswap4(s);
  End;
  Function StrRead(lPos, lSz: LongInt): String;
  Var
    i: integer;
    tx: Array [1 .. kStrSz] Of AnsiChar;
  Begin
    result := '';
    If lSz > kStrSz Then
      exit;
    seek(FP, lPos { -1 } );
    BlockRead(FP, tx, lSz * AnsiCharSz, N);
    For i := 1 To (lSz - 1) Do
    Begin
      If charinset(tx[i], [' ', '[', ']', '+', '-', '.', '\', '~', '/',
        '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
        { if (tx[I] <> kCR) and (tx[I] <> UNIXeoln) then }
        result := result + tx[i];
    End;
  End;
  Function fswap4r(lPos: LongInt): single;
  Var
    s: single;
  Begin
    seek(FP, lPos);
    If Not lSwapBytes Then
    Begin
      BlockRead(FP, result, 4, N);
      exit;
    End;
    BlockRead(FP, s, 4, N);
    result := ubyteorder.fswap4r(s);
  End;
  Function fvax4r(lPos: LongInt): single;
  Var
    s: single;
    Overlay: Array [1 .. 2] Of word Absolute s;
    lT1, lT2: word;
  Begin
    seek(FP, lPos);
    BlockRead(FP, s, 4, N);
    If (Overlay[1] = 0) And (Overlay[2] = 0) Then
    Begin
      result := 0;
      exit;
    End;
    lT1 := Overlay[1] And $80FF;
    lT2 := ((Overlay[1] And $7F00) + $FF00) And $7F00;
    Overlay[1] := Overlay[2];
    Overlay[2] := (lT1 + lT2);
    fvax4r := s;
  End;

Begin
  clear;
  If gECATJPEG_table_entries <> 0 Then
  Begin
    freemem(gECATJPEG_pos_table);
    freemem(gECATJPEG_size_table);
    gECATJPEG_table_entries := 0;
  End;
  lHdrOk := false;
  lQuantScale := 1;
  lCalibrationFactor := 1;
  lLongRAsz := 0;
  lLongRApos := 0;
  lImageFormatOK := false;
  lVolume := 1;
  If Not fileexists(lFileName) Then
  Begin
    showmessage('Unable to find the image ' + lFileName);
    exit;
  End;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  If filesz < (2048) Then
  Begin
    showmessage('This file is to small to be a ECAT format image.');
    Goto 539;
  End;
  seek(FP, 0);
  BlockRead(FP, lECAT7sig, 6 * AnsiCharSz { , n } );
  For lINt4 := 0 To (5) Do
  Begin
    If charinset(lECAT7sig[lINt4], ['a' .. 'z', 'A' .. 'Z']) Then
      lECAT7sigUpcase[lINt4] := upcase(lECAT7sig[lINt4])
    Else
      lECAT7sigUpcase[lINt4] := ' ';
  End;
  If (lECAT7sigUpcase[0] = 'M') And (lECAT7sigUpcase[1] = 'A') And
    (lECAT7sigUpcase[2] = 'T') And (lECAT7sigUpcase[3] = 'R') And
    (lECAT7sigUpcase[4] = 'I') And (lECAT7sigUpcase[5] = 'X') Then
    lECAT6 := false
  Else
    lECAT6 := true;
  If lECAT6 Then
  Begin
    lSwapBytes := false;
    lFileType := xWord(27 * 2);
    If lFileType > 255 Then
      lSwapBytes := Not lSwapBytes;
    lFileType := xWord(27 * 2);
    lAqcType := xWord(175 * 2);
    lPlanes := xWord(188 * 2);
    lFrames := xWord(189 * 2);
    lGates := xWord(190 * 2);
    lYear := xWord(70);
    If (lPlanes < 1) Or (lFrames < 1) Or (lGates < 1) Then
    Begin
      Case MessageDlg
        ('Warning: one of the planes/frames/gates values is less than 1 [' +
        IntToStr(lPlanes) + '/' + IntToStr(lFrames) + '/' + IntToStr(lGates) +
        ']. Is this file really ECAT 6 format? Press abort to cancel conversion. ',
        mterror, [mbOK, mbAbort], 0) Of
        mrAbort:
          Goto 539;
      End; // case
    End
    Else If (lYear < 1940) Or (lYear > 3000) Then
    Begin
      Case MessageDlg('Warning: the year value appears invalid [' +
        IntToStr(lYear) +
        ']. Is this file really ECAT 6 format? Press abort to cancel conversion. ',
        mterror, [mbOK, mbAbort], 0) Of
        mrAbort:
          Goto 539;
      End; // case
    End;
    If lVerboseRead Then
    Begin
      lDynStr := 'ECAT6 data';
      lDynStr := lDynStr + kCR + ('Patient Name:' + StrRead(190, 32));
      lDynStr := lDynStr + kCR + ('Patient ID:' + StrRead(174, 16));
      lDynStr := lDynStr + kCR + ('Study Desc:' + StrRead(318, 32));
      lDynStr := lDynStr + kCR + ('Facility: ' + StrRead(356, 20));
      lDynStr := lDynStr + kCR + ('Planes: ' + IntToStr(lPlanes));
      lDynStr := lDynStr + kCR + ('Frames: ' + IntToStr(lFrames));
      lDynStr := lDynStr + kCR + ('Gates: ' + IntToStr(lGates));
      lDynStr := lDynStr + kCR + ('Date DD/MM/YY: ' + IntToStr(xWord(66)) + '/'
        + IntToStr(xWord(68)) + '/' + IntToStr(lYear));
    End; { show summary }
  End
  Else
  Begin // NOT ECAT6
    lSwapBytes := true;
    lFileType := xWord(50);
    If lFileType > 255 Then
      lSwapBytes := Not lSwapBytes;
    lFileType := xWord(50);
    lAqcType := xWord(328);
    lPlanes := xWord(352);
    lFrames := xWord(354);
    lGates := xWord(356);
    lCalibrationFactor := fswap4r(144);
    If { (true) or } (lPlanes < 1) Or (lFrames < 1) Or (lGates < 1) Then
    Begin
      Case MessageDlg
        ('Warning: on of the planes/frames/gates values is less than 1 [' +
        IntToStr(lPlanes) + '/' + IntToStr(lFrames) + '/' + IntToStr(lGates) +
        ']. Is this file really ECAT 7 format? Press abort to cancel conversion. ',
        mterror, [mbOK, mbAbort], 0) Of
        mrAbort:
          Goto 539;
      End; // case
    End; // error
    If lVerboseRead Then
    Begin
      lDynStr := 'ECAT 7 format';
      lDynStr := lDynStr + kCR + ('Serial Number:' + StrRead(52, 10));
      lDynStr := lDynStr + kCR + ('Patient Name:' + StrRead(182, 32));
      lDynStr := lDynStr + kCR + ('Patient ID:' + StrRead(166, 16));
      lDynStr := lDynStr + kCR + ('Study Desc:' + StrRead(296, 32));
      lDynStr := lDynStr + kCR + ('Facility: ' + StrRead(332, 20));
      lDynStr := lDynStr + kCR + ('Scanner: ' + IntToStr(xWord(48)));
      lDynStr := lDynStr + kCR + ('Planes: ' + IntToStr(lPlanes));
      lDynStr := lDynStr + kCR + ('Frames: ' + IntToStr(lFrames));
      lDynStr := lDynStr + kCR + ('Gates: ' + IntToStr(lGates));
      lDynStr := lDynStr + kCR + 'Calibration: ' +
        floattostr(lCalibrationFactor);
    End; { lShow Summary }
  End; // lECAT7
  If lFileType = 9 Then
    lFileType := 7; // 1364: treat projections as Volume16's
  If Not(lFileType In [1, 2, 3, 4, 7]) Then
  Begin
    showmessage
      ('This software does not recognize the ECAT file type. Selected filetype: '
      + IntToStr(lFileType));
    Goto 539;
  End;
  lVoxelType := 2;
  If lFileType = 3 Then
    lVoxelType := 4;
  If lVerboseRead Then
  Begin
    Case lFileType Of
      1:
        lDynStr := lDynStr + kCR + ('File type: Scan File');
      2:
        lDynStr := lDynStr + kCR + ('File type: Image File'); // x
      3:
        lDynStr := lDynStr + kCR + ('File type: Attn File');
      4:
        lDynStr := lDynStr + kCR + ('File type: Norm File');
      7:
        lDynStr := lDynStr + kCR + ('File type: Volume 16'); // x
    End; // lfiletye case
    Case lAqcType Of
      1:
        lDynStr := lDynStr + kCR + ('Acquisition type: Blank');
      2:
        lDynStr := lDynStr + kCR + ('Acquisition type: Transmission');
      3:
        lDynStr := lDynStr + kCR + ('Acquisition type: Static Emission');
      4:
        lDynStr := lDynStr + kCR + ('Acquisition type: Dynamic Emission');
      5:
        lDynStr := lDynStr + kCR + ('Acquisition type: Gated Emission');
      6:
        lDynStr := lDynStr + kCR + ('Acquisition type: Transmission Rect');
      7:
        lDynStr := lDynStr + kCR + ('Acquisition type: Emission Rect');
      8:
        lDynStr := lDynStr + kCR + ('Acquisition type: Whole Body Transm');
      9:
        lDynStr := lDynStr + kCR + ('Acquisition type: Whole Body Static');
    Else
      lDynStr := lDynStr + kCR + ('Acquisition type: Undefined');
    End; // case AqcType
  End; // verbose read
  If ((lECAT6) And (lFileType = 2)) Or ( { (not lECAT6) and } (lFileType = 7))
  Then // Kludge
  Else
  Begin
    showmessage('Unusual ECAT filetype. Please contact the author.');
    Goto 539;
  End;
  lHdrOk := true;
  lImageFormatOK := true;
  lLongRAsz := kMaxnSLices * SizeOf(LongInt);
  getmem(lLongRA, lLongRAsz);
  lPos := 512;
  // lSingleRASz := kMaxnSlices * sizeof(single);
  // getmem(lSingleRA,lSingleRAsz);
  // lMatri := 0;
  lVolume := 1;
  lPass := 0;
121:
  lEntry := 1;
  lInt := swap32i(lPos);
  lInt2 := swap32i(lPos + 4);
  lNextDirectory := lInt2;
  While true Do
  Begin
    inc(lEntry);
    lPos := lPos + 16;
    lInt := swap32i(lPos);
    lInt2 := swap32i(lPos + 4);
    lInt3 := swap32i(lPos + 8);
    lINt4 := swap32i(lPos + 12);
    lInt2 := lInt2 - 1;
    lSubHeadStart := lInt2 * 512;
    lMatrixStart := ((lInt2) * 512) + 512 { add subhead sz };
    lMatrixEnd := lInt3 * 512;
    If (lINt4 = 1) And (lMatrixStart < filesz) And (lMatrixEnd <= filesz) Then
    Begin
      If (lFileType = 7) { or (lFileType = 4) } Or (lFileType = 2) Then
      Begin // Volume of 16-bit integers
        If lECAT6 Then
        Begin
          lX := xWord(lSubHeadStart + (66 * 2));
          lY := xWord(lSubHeadStart + (67 * 2));
          lZ := 1; // uxWord(lSubHeadStart+8);
          lXmm := 10 * fvax4r(lSubHeadStart + (92 * 2));
          // fswap4r(lSubHeadStart+(92*2));
          lYmm := lXmm; // read32r(lSubHeadStart+(94*2));
          lZmm := 10 * fvax4r(lSubHeadStart + (94 * 2));
          lCalibrationFactor := fvax4r(lSubHeadStart + (194 * 2));
          lQuantScale := fvax4r(lSubHeadStart + (86 * 2));
          If lVerboseRead Then
            lDynStr := lDynStr + kCR + 'Plane ' + IntToStr(lPass + 1) +
              ' Calibration/Scale Factor: ' + floattostr(lCalibrationFactor) +
              '/' + floattostr(lQuantScale);
        End
        Else
        Begin
          // 02 or 07
          lX := xWord(lSubHeadStart + 4);
          lY := xWord(lSubHeadStart + 6);
          lZ := xWord(lSubHeadStart + 8);
          // if lFileType <> 4 then begin
          lXmm := 10 * fswap4r(lSubHeadStart + 34);
          lYmm := 10 * fswap4r(lSubHeadStart + 38);
          lZmm := 10 * fswap4r(lSubHeadStart + 42);
          lQuantScale := fswap4r(lSubHeadStart + 26);
          If lVerboseRead Then
            lDynStr := lDynStr + kCR + 'Volume: ' + IntToStr(lPass + 1) +
              ' Scale Factor: ' + floattostr(lQuantScale);
          // end; //filetype <> 4
        End; // ecat7
        If true Then
        Begin
          // FileMode := 2; //set to read/write
          inc(lPass);
          lImgSz := lX * lY * lZ * lVoxelType; { 2 bytes per voxel }
          lSliceSz := lX * lY * lVoxelType;
          If lZ < 1 Then
          Begin
            lHdrOk := false;
            Goto 539;
          End;
          lSlicePos := lMatrixStart;
          If ((lECAT6) And (lPass = 1)) Or ((Not lECAT6)) Then
          Begin
            data.XYZdim[1] := lX;
            data.XYZdim[2] := lY;
            data.XYZdim[3] := lZ;
            data.XYZmm[1] := lXmm;
            data.XYZmm[2] := lYmm;
            data.XYZmm[3] := lZmm;
            Case lVoxelType Of
              1:
                Begin
                  showmessage
                    ('Error: 8-bit data not supported [yet]. Please contact the author.');
                  data.Allocbits_per_pixel := 8;
                  lHdrOk := false;
                  Goto 539;
                End;
              4:
                Begin
                  showmessage
                    ('Error: 32-bit data not supported [yet]. Please contact the author.');
                  lHdrOk := false;
                  Goto 539;
                End;
            Else
              Begin // 16-bit integers
                data.Allocbits_per_pixel := 16;
              End;
            End; { case lVoxelType }
          End
          Else
          Begin // if lECAT6
            If (data.XYZdim[1] <> lX) Or (data.XYZdim[2] <> lY) Or
              (data.XYZdim[3] <> lZ) Then
            Begin
              showmessage
                ('Error: different slices in this volume have different slice sizes. Please contact the author.');
              lHdrOk := false;
              Goto 539;
            End; // dimensions have changed
            // lSlicePos :=((lMatri-1)*lImgSz);
          End; // ECAT6
          lVox := lSliceSz Div 2;
          lHlfVox := lSliceSz Div 4;
          For lSlice := 1 To lZ Do
          Begin
            If (Not lECAT6) Then
              lSlicePos := ((lSlice - 1) * lSliceSz) + lMatrixStart;
            If lLongRApos >= kMaxnSLices Then
            Begin
              lHdrOk := false;
              Goto 539;
            End;
            inc(lLongRApos);
            lLongRA[lLongRApos] := lSlicePos;
            { inc(lSingleRAPos);
              if lCalibTableType = 1 then
              lSingleRA[lSingleRAPos] := lQuantScale
              else
              lSingleRA[lSingleRAPos] := lCalibrationFactor *lQuantScale; }

          End; // slice 1..lZ
          If Not lECAT6 Then
            inc(lVolume);
        End; // fileexistsex
      End; // correct filetype
    End; // matrix start/end within filesz
    If (lMatrixStart > filesz) Or (lMatrixEnd >= filesz) Then
      Goto 539;
    If ((lEntry Mod 32) = 0) Then
    Begin
      If ((lNextDirectory - 1) * 512) <= lPos Then
        Goto 539; // no more directories
      lPos := (lNextDirectory - 1) * 512;
      Goto 121;
    End; // entry 32
  End; // while true
539:
  closefile(FP);
  FileMode := 2; // set to read/write
  data.XYZdim[3] := lLongRApos;
  If Not lECAT6 Then
    dec(lVolume);
  // ECAT7 increments immediately before exiting loop - once too often
  data.XYZdim[4] := (lVolume);
  If lSwapBytes Then
    data.little_endian := 0
  Else
    data.little_endian := 1;
  If (lLongRApos > 0) And (lHdrOk) Then
  Begin
    data.ImageStart := lLongRA[1];
    lCreateTable := false;
    If (lLongRApos > 1) Then
    Begin
      lFPos := data.ImageStart;
      For lS := 2 To lLongRApos Do
      Begin
        lFPos := lFPos + lSliceSz;
        If lFPos <> lLongRA[lS] Then
          lCreateTable := true;
      End;
      If (lCreateTable) And (lReadECAToffsetTables) Then
      Begin
        gECATJPEG_table_entries := lLongRApos;
        getmem(gECATJPEG_pos_table, gECATJPEG_table_entries * SizeOf(LongInt));
        getmem(gECATJPEG_size_table, gECATJPEG_table_entries * SizeOf(LongInt));
        For lS := 1 To gECATJPEG_table_entries Do
          gECATJPEG_pos_table[lS] := lLongRA[lS]
      End
      Else If (lCreateTable) Then
        lImageFormatOK := false; // slices are offset within this file
    End;
    If (lVerboseRead) And (lHdrOk) Then
    Begin
      lDynStr := lDynStr + kCR + ('XYZdim:' + IntToStr(lX) + '/' + IntToStr(lY)
        + '/' + IntToStr(gECATJPEG_table_entries));
      lDynStr := lDynStr + kCR + ('XYZmm: ' + floattostrf(data.XYZmm[1],
        ffFixed, 7, 7) + '/' + floattostrf(data.XYZmm[2], ffFixed, 7, 7) + '/' +
        floattostrf(data.XYZmm[3], ffFixed, 7, 7));
      lDynStr := lDynStr + kCR +
        ('Bits per voxel: ' + IntToStr(data.Storedbits_per_pixel));
      lDynStr := lDynStr + kCR + ('Image Start: ' + IntToStr(data.ImageStart));
      If lCreateTable Then
        lDynStr := lDynStr + kCR + ('Note: staggered slice offsets');
    End
  End;
  data.Storedbits_per_pixel := data.Allocbits_per_pixel;
  If lLongRAsz > 0 Then
    freemem(lLongRA);
  (* if (lSingleRApos > 0) and (lHdrOK) and (lCalibTableType <> 0) then begin
    gECAT_scalefactor_entries := lSingleRApos;
    getmem (gECAT_scalefactor_table, gECAT_scalefactor_entries*sizeof(single));
    for lS := 1 to gECAT_scalefactor_entries do
    gECAT_scalefactor_table[lS] := lSingleRA[lS];
    end;
    if lSingleRASz > 0 then
    freemem(lSingleRA); *)
End;

// end ECAT
// start picker
Procedure TDICOM.read_picker_data(lVerboseRead: boolean);
Label 423;
Const
  kPickerHeader = 8192;
  kRecStart = 280; // is this a constant?
Var
  lDataStart, lVal, lDBPos, lPos, lRecSz, lNumRecs, lRec, filesz, N: LongInt;
  lThkM, lThkN, lSiz: double;
  tx: Array [0 .. 6] Of AnsiChar;
  FP: File;
  lDiskCacheRA: PAnsiChar;
  Function ReadRec(lRecNum: integer): boolean;
  Var
    lNameStr, lValStr: String;
    lOffset, lLen, lFPos, lFEnd: integer;
    Function ValStrToFloat: double;
    Var
      lConvStr: String;
      lI: integer;
    Begin
      result := 0.0;
      lLen := Length(lValStr);
      If lLen < 1 Then
        exit;
      lConvStr := '';
      For lI := 1 To lLen Do
        If charinset(lValStr[lI], ['0' .. '9']) Then
          lConvStr := lConvStr + lValStr[lI];
      If Length(lConvStr) < 1 Then
        exit;
      result := str2float(lConvStr);
    End;

  Begin
    result := false;
    lFPos := ((lRecNum - 1) * lRecSz) + kRecStart;
    lFEnd := lFPos + 6;
    lNameStr := '';
    For lFPos := lFPos To lFEnd Do
      If ord(lDiskCacheRA[lFPos]) <> 0 Then
        lNameStr := lNameStr + lDiskCacheRA[lFPos];
    If (lVerboseRead) Or (lNameStr = 'RCNFSIZ') Or (lNameStr = 'SCNTHKM') Or
      (lNameStr = 'SCNTHKN') Then
    Begin
      lFPos := ((lRecNum - 1) * lRecSz) + kRecStart + 8;
      lFEnd := lFPos + 1;
      lOffset := 0;
      For lFPos := lFPos To lFEnd Do
        lOffset := ((lOffset) Shl 8) + (ord(lDiskCacheRA[lFPos]));
      lFPos := ((lRecNum - 1) * lRecSz) + kRecStart + 10;
      lFEnd := lFPos + 1;
      lLen := 0;
      For lFPos := lFPos To lFEnd Do
        lLen := ((lLen) Shl 8) + (ord(lDiskCacheRA[lFPos]));
      lOffset := lDataStart + lOffset + 1;
      lFEnd := lOffset + lLen - 1;
      If (lLen < 1) Or (lFEnd > kPickerHeader) Then
        exit;
      lValStr := '';
      For lFPos := (lOffset) To lFEnd Do
      Begin
        lValStr := lValStr + lDiskCacheRA[lFPos];
      End;
      If lVerboseRead Then
        lDynStr := lDynStr + kCR + lNameStr + ': ' + lValStr;
      If (lNameStr = 'RCNFSIZ') Then
        lSiz := ValStrToFloat;
      If (lNameStr = 'SCNTHKM') Then
        lThkM := ValStrToFloat;
      If (lNameStr = 'SCNTHKN') Then
        lThkN := ValStrToFloat;
    End; // verboseread, or vital value
    result := true;
  End;
  Function FindStr(l1, l2, l3, l4, l5: AnsiChar; lReadNum: boolean;
    Var lNum: integer): boolean;
  Var // lMarker: integer;
    lNumStr: String;
  Begin
    result := false;
    Repeat
      If (lDiskCacheRA[lPos - 4] = l1) And (lDiskCacheRA[lPos - 3] = l2) And
        (lDiskCacheRA[lPos - 2] = l3) And (lDiskCacheRA[lPos - 1] = l4) And
        (lDiskCacheRA[lPos] = l5) Then
        result := true;
      inc(lPos);
    Until (result) Or (lPos >= kPickerHeader);
    If Not result Then
      exit;
    If Not lReadNum Then
      exit;
    result := false;
    lNumStr := '';
    Repeat
      If charinset(lDiskCacheRA[lPos], ['0' .. '9']) Then
        lNumStr := lNumStr + lDiskCacheRA[lPos]
      Else If lNumStr <> '' Then
        result := true;
      inc(lPos);
    Until (result) Or (lPos = kPickerHeader);
    lNum := strtoint(lNumStr);
  End;

Begin
  lSiz := 0.0;
  lThkM := 0.0;
  lThkN := 0.0;
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  clear;
  If filesz < (kPickerHeader) Then
  Begin
    showmessage('This file is to small to be a Picker image.');
    closefile(FP);
    FileMode := 2; // set to read/write
    exit;
  End;
  seek(FP, 0);
  BlockRead(FP, tx, 4 * AnsiCharSz, N);
  If (tx[0] <> '*') OR (tx[1] <> '*') OR (tx[2] <> '*') OR (tx[3] <> ' ') Then
  Begin { manufacturer is not SIEMENS }
    showmessage
      ('Is this a Picker image? Expected ''*** '' at the start of the file.');
    closefile(FP);
    FileMode := 2; // set to read/write
    exit;
  End; { not picker }
  If filesz = (kPickerHeader + (1024 * 1024 * 2)) Then
  Begin
    data.XYZdim[1] := 1024;
    data.XYZdim[2] := 1024;
    data.XYZdim[3] := 1;
    data.ImageStart := 8192;
  End
  Else If filesz = (kPickerHeader + (512 * 512 * 2)) Then
  Begin
    data.XYZdim[1] := 512;
    data.XYZdim[2] := 512;
    data.XYZdim[3] := 1;
    data.ImageStart := 8192;
  End
  Else If filesz = (8192 + (256 * 256 * 2)) Then
  Begin
    data.XYZdim[1] := 256;
    data.XYZdim[2] := 256;
    data.XYZdim[3] := 1;
    data.ImageStart := 8192;
  End
  Else
  Begin
    showmessage('This file is the incorrect size to be a Picker image.');
    closefile(FP);
    FileMode := 2; // set to read/write
    exit;
  End;
  getmem(lDiskCacheRA, kPickerHeader * AnsiCharSz);
  seek(FP, 0);
  BlockRead(FP, lDiskCacheRA^, kPickerHeader, N);
  lRecSz := 0;
  lNumRecs := 0;
  lPos := 5;
  If Not FindStr('d', 'b', 'r', 'e', 'c', false, lVal) Then
    Goto 423;
  lDBPos := lPos;
  If Not FindStr('r', 'e', 'c', 's', 'z', true, lRecSz) Then
    Goto 423;
  lPos := lDBPos;
  If Not FindStr('n', 'r', 'e', 'c', 's', true, lNumRecs) Then
    Goto 423;
  lPos := kRecStart; // IS THIS A CONSTANT???
  lDataStart := kRecStart + (lRecSz * lNumRecs) - 1;
  // file starts at 0, so -1
  If (lNumRecs = 0) Or (lDataStart > kPickerHeader) Then
    Goto 423;
  lRec := 0;
  lDynStr := 'Picker Format';
  Repeat
    inc(lRec);
  Until (Not(ReadRec(lRec))) Or (lRec >= lNumRecs);
  If lSiz <> 0 Then
  Begin
    data.XYZmm[1] := lSiz / data.XYZdim[1];
    data.XYZmm[2] := lSiz / data.XYZdim[2];
    If lVerboseRead Then
      lDynStr := lDynStr + kCR + 'Voxel Size: ' + floattostrf(data.XYZmm[1],
        ffFixed, 8, 2) + 'x' + floattostrf(data.XYZmm[2], ffFixed, 8, 2);
  End;
  If (lThkM <> 0) And (lThkN <> 0) Then
  Begin
    data.XYZmm[3] := lThkN / lThkM;
    If lVerboseRead Then
      lDynStr := lDynStr + kCR + 'Slice Thickness: ' +
        floattostrf(data.XYZmm[3], ffFixed, 8, 2);
  End;
423:
  freemem(lDiskCacheRA);
  lHdrOk := true;
  closefile(FP);
  FileMode := 2; // set to read/write
End;
// end picker

Procedure TDICOM.Read_DICOM_HDR(FileName: TFileName; lVerboseRead: boolean);
Label 666, 777;
Const
  kMaxTextBuf = 50000; // maximum for screen output
  kDiskCache = 16384; // size of disk buffer
Type
  dicom_types = (unknown, i8, i16, i32, ui8, ui16, ui32, _string { ,_float } );
Var
  // lCh: AnsiChar;
  // lSpaces,lNoteType,lNotes: longint;//biorad
  // lbyte: byte;//biorad
  DataBackUp: TMedicalImageData;
  lWord, lWord2, lWord3: word;
  lWordRA: wordp;
  lDiskCacheRA: PAnsiChar { ByteP };
  lRot1, lRot2, lRot3: integer; // rotation dummies for AFNI
  FP: File;
  lT0, lT1, lT2, lT3: byte;
  lMediface0002_0013, lSiemensMosaic0008_0008, lDICM_at_128, lTextOverFlow,
    lGenesis, lFirstPass, lrOK, lBig, lBigSet, lGrp, explicitVR,
    first_one: boolean;
  lTestError, lByteSwap, lGELX, time_to_quit, lProprietaryImageThumbnail,
    lFirstFragment, lOldSiemens_IncorrectMosaicMM: boolean;
  group, element, dummy, e_len, remaining, tmp: uint32;
  lgrpstr, tmpstr, lStr, info: String;
  t: dicom_types;
  lFloat1, lFloat2: double;
  lJPEGentries, lErr, liPos, lCacheStart, lCachePos, lDiskCacheSz, N, i, j,
    value, Ht, Width, max16, min16, slicesz, filesz, where, lStart, lEnd,
    lMatrixSz, lPhaseEncodingSteps, lJunk: uint32;
  lJunk1, lJunk2, lJunk3: LongInt;
  tx: Array [0 .. 96] Of AnsiChar;
  txstr: String;
  buff: PAnsiChar;
  lColorRA: ByteP;
  lLongRA: LongIntp;
  lSingleRA, lInterceptRA: Singlep;
  lAutoDetectGenesis: boolean;
  lAutoDetectInterfile: boolean;
  lReadECAToffsetTables: boolean;
  lAutoDECAT7: boolean;
  lReadJPEGtables: boolean;
  lReadColorTables: boolean;
  lInc: integer;
  // lPapyrusnSlices,lPapyrusSlice : integer;
  // lPapyrusZero,lPapyrus : boolean;
  Procedure ByteSwap(Var lInOut: integer); Overload;
  Var
    lWord: word;
  Begin
    lWord := lInOut;
    lWord := system.swap(lWord);
    lInOut := lWord;
  End;
  Procedure ByteSwap(Var lInOut: uint32); Overload;
  Var
    lWord: word;
  Begin
    lWord := lInOut;
    lWord := system.swap(lWord);
    lInOut := lWord;
  End;
  Procedure dReadCache(lFileStart: integer);
  Begin
    lCacheStart := lFileStart { lCacheStart + lDiskCacheSz };
    // eliminate old start
    // if lCacheStart < 0 then  // never
    // lCacheStart := 0;
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    If (filesz - (lCacheStart)) < kDiskCache Then
      lDiskCacheSz := filesz - (lCacheStart)
    Else
      lDiskCacheSz := kDiskCache;
    lCachePos := 0;
    If (lDiskCacheSz < 1) Then
      exit { goto 666 };
    If (lDiskCacheSz + lCacheStart) > filesz Then
      exit;
    // showmessage(IntToStr(FileSz)+' / '+IntToStr(lDiskCacheSz)+ ' / '+IntToStr(lCacheStart));
    seek(FP, lCacheStart);
    getmem(lDiskCacheRA, lDiskCacheSz { bytes } );
    BlockRead(FP, lDiskCacheRA^, lDiskCacheSz, N);
  End;

  Function dFilePos(Var lInFP: File): integer;
  Begin
    result := lCacheStart + lCachePos;
  End;
  Procedure dSeek(Var lInFP: File; lPos: uint32);
  Begin
    If (lPos >= lCacheStart) And (lPos < (lDiskCacheSz + lCacheStart)) Then
    Begin
      lCachePos := lPos - lCacheStart;
      exit;
    End;
    dReadCache(lPos);
  End;

  Procedure dBlockRead(Var lInFP: File; lInbuff: PAnsiChar; e_len: uint32;
    Out N: uint32);
  Var
    ln: uint32;
  Begin
    N := 0;
    If e_len <= 0 Then
      exit;
    For ln := 0 To (e_len - 1) Do
    Begin
      If lCachePos >= lDiskCacheSz Then
      Begin
        dReadCache(lCacheStart + lDiskCacheSz);
        If lDiskCacheSz < 1 Then
          exit;
        lCachePos := 0;
      End;
      N := ln;
      lInbuff[N] := lDiskCacheRA[lCachePos];
      inc(lCachePos);
    End;
  End;
  Procedure readfloats(Var FP: File; remaining: integer; Var lOutStr: String;
    Var lF1, lF2: double; Var lReadOK: boolean);
  Var
    lDigit: boolean;
    lI, lLen, N: uint32;
    lfStr: String;
  Begin
    lF1 := 1;
    lF2 := 2;
    If e_len = 0 Then
    Begin
      lReadOK := true;
      exit;
    End;
    If (dFilePos(FP) > (filesz - remaining)) Or (remaining < 1) Then
    Begin
      lOutStr := '';
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;

    lOutStr := '';
    getmem(buff, e_len);
    dBlockRead(FP, buff { ^ } , e_len, N);
    For lI := 0 To e_len - 1 Do
      If charinset(buff[lI], [ { '/','\', delete: rev18 } 'e', 'E', '+', '-',
        '.', '0' .. '9']) Then
        lOutStr := lOutStr + buff[lI]
      Else
        lOutStr := lOutStr + ' ';
    freemem(buff);
    lfStr := '';
    lLen := Length(lOutStr);
    lI := 1;
    lDigit := false;
    Repeat
      If charinset(lOutStr[lI], ['+', '-', 'e', 'E', '.', '0' .. '9']) Then
        lfStr := lfStr + lOutStr[lI];
      If charinset(lOutStr[lI], ['0' .. '9']) Then
        lDigit := true;
      inc(lI);
    Until (lI > lLen) Or (lDigit);
    If Not lDigit Then
      exit;
    If lI <= lI Then
    Begin
      Repeat
        If Not charinset(lOutStr[lI], ['+', '-', 'e', 'E', '.',
          '0' .. '9']) Then
          lDigit := false
        Else
        Begin
          If lOutStr[lI] = 'E' Then
            lfStr := lfStr + 'e'
          Else
            lfStr := lfStr + lOutStr[lI];
        End;
        inc(lI);
      Until (lI > lLen) Or (Not lDigit);
    End;
    // QStr(lfStr);
    Try
      lF1 := str2float(lfStr);
    Except
      On EConvertError Do
      Begin
        showmessage('Unable to convert the string ' + lfStr +
          ' to a real number');
        lF1 := 1;
        exit;
      End;
    End; { except }
    lfStr := '';
    If lI > lLen Then
      exit;
    Repeat
      If charinset(lOutStr[lI], ['+', 'E', 'e', '.', '-', '0' .. '9']) Then
      Begin
        If lOutStr[lI] = 'E' Then
          lfStr := lfStr + 'e'
        Else
          lfStr := lfStr + lOutStr[lI];
      End;
      If charinset(lOutStr[lI], ['0' .. '9']) Then
        lDigit := true;
      inc(lI);
    Until (lI > lLen) Or ((lDigit) And (lOutStr[lI] = ' '));
    // second half: rev18
    If Not lDigit Then
      exit;
    // QStr(lfStr);
    Try
      lF2 := str2float(lfStr);
    Except
      On EConvertError Do
      Begin
        showmessage('Unable to convert the string ' + lfStr +
          ' to a real number');
        exit;
      End;
    End;

  End;
  Function read16(Var FP: File; Var lReadOK: boolean): uint16;
  Var
    t1, t2: uint8;
    N: uint32;
  Begin
    If dFilePos(FP) > (filesz - 2) Then
    Begin
      read16 := 0;
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;
    getmem(buff, 2);
    dBlockRead(FP, buff { ^ } , 2, N);
    t1 := ord(buff[0]);
    t2 := ord(buff[1]);
    freemem(buff);
    If data.little_endian <> 0 Then
      result := (t1 + t2 * 256) AND $FFFF
    Else
      result := (t1 * 256 + t2) AND $FFFF;
  End;

  Function readStr(Var FP: File; remaining: uint32; Var lReadOK: boolean;
    VAR lmaxval: uint32): String;
  Var
    lInc, ln, Val, N: uint32;
    t1, t2: uint8;
    lStr: String;
  Begin
    lmaxval := 0;
    If dFilePos(FP) > (filesz - remaining) Then
    Begin
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;
    result := '';
    ln := remaining Div 2;
    If ln < 1 Then
      exit;
    lStr := '';
    For lInc := 1 To ln Do
    Begin
      getmem(buff, 2);
      dBlockRead(FP, buff { ^ } , 2, N);
      t1 := ord(buff[0]);
      t2 := ord(buff[1]);
      freemem(buff);
      If data.little_endian <> 0 Then
        Val := (t1 + t2 * 256) AND $FFFF
      Else
        Val := (t1 * 256 + t2) AND $FFFF;
      If lInc < ln Then
        lStr := lStr + IntToStr(Val) + ', '
      Else
        lStr := lStr + IntToStr(Val);
      If Val > lmaxval Then
        lmaxval := Val;
    End;
    result := lStr;
    If odd(remaining) Then
    Begin
      getmem(buff, 1);
      dBlockRead(FP, buff { t1 } , SizeOf(uint8), N);
      freemem(buff);
    End;
  End;
  Function ReadStrHex(Var FP: File; remaining: integer;
    Var lReadOK: boolean): String;
  Var
    lInc, ln, Val, N: uint32;
    t1, t2: uint8;
    lStr: String;
  Begin
    If dFilePos(FP) > (filesz - remaining) Then
    Begin
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;
    result := '';
    ln := remaining Div 2;
    If ln < 1 Then
      exit;
    lStr := '';
    For lInc := 1 To ln Do
    Begin
      getmem(buff, 2);
      dBlockRead(FP, buff, 2, N);
      t1 := ord(buff[0]);
      t2 := ord(buff[1]);
      freemem(buff);
      If data.little_endian <> 0 Then
        Val := (t1 + t2 * 256) AND $FFFF
      Else
        Val := (t1 * 256 + t2) AND $FFFF;
      If lInc < ln Then
        lStr := lStr + 'x' + inttohex(Val, 4) + ', '
      Else
        lStr := lStr + 'x' + inttohex(Val, 4);
    End;
    result := lStr;
    If odd(remaining) Then
    Begin
      getmem(buff, 1);
      dBlockRead(FP, { t1 } buff, SizeOf(uint8), N);
      freemem(buff);
    End;
  End;
  Function SomaTomFloat: double;
  Var
    lSomaStr: String;
  Begin
    // dSeek(fp,5992); //Slice Thickness from 5790 "SL   3.0"
    // dSeek(fp,5841); //Field of View from 5838 "FoV   281"
    // dSeek(fp,lPos);
    lSomaStr := '';
    tx[0] := 'x';
    While (Length(lSomaStr) < 64) And (tx[0] <> chr(0)) And (tx[0] <> '/') Do
    Begin
      dBlockRead(FP, tx, 1, N);
      If charinset(tx[0], ['+', '-', '.', '0' .. '9', 'e', 'E']) Then
        lSomaStr := lSomaStr + tx[0];
    End;
    // showmessage(lSomaStr+':'+IntToStr(length(lSOmaStr)));
    // showmessage(IntToStr(length(lSOmaStr)));

    If Length(lSomaStr) > 0 Then
      result := str2float(lSomaStr)
    Else
      result := 0;
  End;

  Function PGMreadInt: integer;
  // reads integer from PGM header, disregards comment lines (which start with '#' symbol);
  Var
    lStr: String;
    lDigit: boolean;

  Begin
    result := 1;
    lStr := '';
    Repeat
      dBlockRead(FP, tx, 1, N);
      If tx[0] = '#' Then
      Begin // comment
        Repeat
          dBlockRead(FP, tx, 1, N);
        Until (ord(tx[0]) = $0A) Or (dFilePos(FP) > (filesz - 4));
        // eoln indicates end of comment
      End; // finished reading comment
      If charinset(tx[0], ['0' .. '9']) Then
      Begin
        lStr := lStr + tx[0];
        lDigit := true;
      End
      Else
        lDigit := false;
    Until ((lStr <> '') And (Not lDigit)) Or (dFilePos(FP) > (filesz - 4));
    // read digits until you hit whitespace
    If lStr <> '' Then
      result := strtoint(lStr);

    { lStr := '';
      tx[0] := 'x';
      while (length(lStr) < 64) and (ord(tx[0]) <> $0A) do begin
      dBlockRead(fp, tx, 1, n);
      if tx[0] in ['#','+','-','.','0'..'9','e','E',' ','a'..'z','A'..'Z'] then
      lStr := lStr + tx[0];
      end;
      result := lStr; }
  End;

(* procedure PGMreadStr (var lXwid,lYht: integer);
  //reads the entire PGM header, reports
  var lStr: string;
  begin
  lXwid := -1;
  lYht := -1;
  dBlockRead(fp, tx, 1, n);
  if tx[0] = '#' then exit; //comment
  while (ord(tx[0]) <> $0A) do begin
  if tx[0] in ['0'..'9'] then
  lStr := lStr + tx[0];
  if (tx[0] = ' ') and (length(lStr) > 0) then begin
  lXwid := strtoint(lStr);
  lStr := '';
  end;
  dBlockRead(fp, tx, 1, n);
  end;
  if (lXwid>0) and (length(lStr) > 0) then begin
  lYht := strtoint(lStr);
  repeat
  dBlockRead(fp, tx, 1, n);
  until (ord(tx[0]) = $0A);
  end;

  {lStr := '';
  tx[0] := 'x';
  while (length(lStr) < 64) and (ord(tx[0]) <> $0A) do begin
  dBlockRead(fp, tx, 1, n);
  if tx[0] in ['#','+','-','.','0'..'9','e','E',' ','a'..'z','A'..'Z'] then
  lStr := lStr + tx[0];
  end;
  result := lStr;    }
  end; *)
{ function PGMreadStr: string;
  var lStr: string;
  begin
  {lStr := '';
  tx[0] := 'x';
  while (length(lStr) < 64) and (ord(tx[0]) <> $0A) do begin
  dBlockRead(fp, tx, 1, n);
  if tx[0] in ['#','+','-','.','0'..'9','e','E',' ','a'..'z','A'..'Z'] then
  lStr := lStr + tx[0];
  end;
  result := lStr;
  end; }
  Function read32(Var FP: File; Var lReadOK: boolean): uint32;
  Var
    t1, t2, t3, t4: byte;
    N: uint32;
  Begin
    If dFilePos(FP) > (filesz - 4) Then
    Begin
      read32 := 0;
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;
    getmem(buff, 4);
    dBlockRead(FP, buff { ^ } , 4, N);
    t1 := ord(buff[0]);
    t2 := ord(buff[1]);
    t3 := ord(buff[2]);
    t4 := ord(buff[3]);
    freemem(buff);
    If data.little_endian <> 0 Then
      result := t1 + (t2 Shl 8) + (t3 Shl 16) + (t4 Shl 24)
    Else
      result := t4 + (t3 Shl 8) + (t2 Shl 16) + (t1 Shl 24)
      // if Data.little_endian <> 0
      // then Result := (t1 + t2*256 + t3*256*256 + t4*256*256*256) AND $FFFFFFFF
      // else Result := (t1*256*256*256 + t2*256*256 + t3*256 + t4) AND $FFFFFFFF;
  End;

  Function read32r(Var FP: File; Var lReadOK: boolean): single; // 1382
  Var
    s: single;
  Begin
    If dFilePos(FP) > (filesz - 4) Then
    Begin
      read32r := 0;
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;
    // GetMem( buff, 8);
    dBlockRead(FP, @s, 4, N);
    read32r := ToLittleEndian(s, data.little_endian);
  End;

  Function read64(Var FP: File; Var lReadOK: boolean): double;
  Var
    s: double;
  Begin
    If dFilePos(FP) > (filesz - 8) Then
    Begin
      read64 := 0;
      lReadOK := false;
      exit;
    End
    Else
      lReadOK := true;
    // GetMem( buff, 8);
    dBlockRead(FP, @s, 8, N);
    read64 := ToLittleEndian(s, data.little_endian);
  End;

// magma
  Function SafeStrToInt(Var lInput: String): integer;
  Var
    lI, lLen: integer;
  Begin
    result := 0;
    lLen := Length(lInput);
    lStr := '';
    If lLen < 1 Then
      exit;
    For lI := 1 To lLen Do
      If charinset(lInput[lI], ['+', '-', '0' .. '9']) Then
        lStr := lStr + lInput[lI];
    Val(lStr, lI, lErr);
    If lErr = 0 Then
      result := lI; // strtoint(lStr);
  End;

  Procedure DICOMHeaderStringToInt(Var lInput: integer);
  Var
    lI: integer;
  Begin
    t := _string;
    lStr := '';
    If dFilePos(FP) > (filesz - e_len) Then
      exit; // goto 666;
    getmem(buff, e_len);
    dBlockRead(FP, buff { ^ } , e_len, N);
    For lI := 0 To e_len - 1 Do
      If charinset(buff[lI], ['+', '-', '0' .. '9']) Then
        lStr := lStr + buff[lI];
    freemem(buff);
    Val(lStr, lI, lErr);
    If lErr = 0 Then
      lInput := lI; // strtoint(lStr);
    remaining := 0;
    tmp := lInput;
  End;

  Procedure DICOMHeaderString(Var lInput: String);
  Var
    lI, lStartPos: integer;
  Begin
    t := _string;
    lStartPos := dFilePos(FP);
    lInput := '';
    If e_len < 1 Then
      exit; // DICOM: should always be even
    getmem(buff, e_len);
    dBlockRead(FP, buff { ^ } , e_len, N);
    For lI := 0 To e_len - 1 Do
      If charinset(buff[lI], ['+', '-', '/', '\', ' ', '0' .. '9', 'a' .. 'z',
        'A' .. 'Z']) Then
        lInput := lInput + buff[lI]
      Else { if (buff[i] = 0) then }
        lInput := lInput + ' ';

    freemem(buff);
    dSeek(FP, lStartPos);
  End;
  Procedure DICOMHeaderStringTime(Var lInput: String);
  Var
    lI, lStartPos: integer;
  Begin
    t := _string;
    lStartPos := dFilePos(FP);
    lInput := '';
    If e_len < 1 Then
      exit; // DICOM: should always be even
    getmem(buff, e_len);
    dBlockRead(FP, buff { ^ } , e_len, N);
    For lI := 0 To e_len - 1 Do
      If charinset(buff[lI], ['+', '-', '/', '\', ' ', '0' .. '9', 'a' .. 'z',
        'A' .. 'Z']) Then
        lInput := lInput + buff[lI]
      Else If lI <> (e_len - 1) Then
        lInput := lInput + ':'
      Else
        lInput := lInput + ' ';

    freemem(buff);
    dSeek(FP, lStartPos);
  End;

Begin
  clear;
  lReadColorTables := true;
  lAutoDetectGenesis := true;
  lAutoDetectInterfile := false;
  lReadECAToffsetTables := true;
  lReadJPEGtables := true;
  lAutoDECAT7 := true;
  lTestError := false;
  lMatrixSz := 0;
  lPhaseEncodingSteps := 0;
  lSiemensMosaic0008_0008 := false;
  lMediface0002_0013 := false; // false wblate
  lOldSiemens_IncorrectMosaicMM := false;
  lCacheStart := 0;
  lDiskCacheSz := 0;
  gECATJPEG_table_entries := 0;
  red_table_size := 0;
  green_table_size := 0;
  blue_table_size := 0;
  lFileName := FileName;
  lFirstFragment := true;
  lTextOverFlow := false;
  lImageFormatOK := true;
  lHdrOk := false;
  If Not fileexists(lFileName) Then
  Begin
    lImageFormatOK := false;
    // showmessage('ERROR image not found: '+lFileName);
    exit;
  End;
  tmpstr := UpperCase(ExtractFileExt(lFileName));
  // string(StrUpper(PAnsiChar(ExtractFileExt(lFileName))));//deprecated
  lStr := '';
  If (tmpstr = '.REC') Then
  Begin // 1417z: check in Unix: character upper/lower case may matter
    lStr := ChangeFileExt(lFileName, '.par');
    If fileexists(lStr) Then
      lFileName := lStr
    Else
    Begin // Linux is case sensitive 1382...
      lStr := ChangeFileExt(lFileName, '.PAR');
      If fileexists(lStr) Then
        lFileName := lStr
    End;

  End;
  If (tmpstr = '.BRIK') Then
  Begin // 1417z: check in Unix: character upper/lower case may matter
    lStr := ChangeFileExt(lFileName, '.HEAD');
    If fileexists(lStr) Then
      lFileName := lStr;
  End;

  lGELX := false;
  lByteSwap := false;
  clear;
  TMedicalImage(self).clear(DataBackUp);
  FileMode := 0; // set to readonly
  assignfile(FP, lFileName);
  Reset(FP, 1);
  filesz := FileSize(FP);
  If filesz < 1 Then
  Begin
    lImageFormatOK := false;
    exit;
  End;
  data.little_endian := 1;
  lDynStr := '';
  lJPEGentries := 0;
  first_one := true;
  info := '';
  lGrp := false;
  lBigSet := false;
  lDICM_at_128 := false; // no DICOM signature
  If filesz > 200 Then
  Begin
    dSeek(FP, { 0 } 128);
    dBlockRead(FP, tx, 4 * AnsiCharSz, N);
    If (tx[0] = 'D') And (tx[1] = 'I') And (tx[2] = 'C') And (tx[3] = 'M') Then
      lDICM_at_128 := true;
  End; // filesize > 200: check for 'DICM' at byte 128 - DICOM signature

  If (lAutoDetectGenesis) And (filesz > (5820 { 114+35+4 } )) Then
  Begin
    dSeek(FP, 0);
    If (ord(tx[0]) = 206) And (ord(tx[1]) = 250) Then
    Begin
      // Elscint format signature: check height and width to make sure

      dSeek(FP, 370);
      group := read16(FP, lrOK); // Width
      dSeek(FP, 372);
      element := read16(FP, lrOK); // Ht
      // showmessage(tx[0]+tx[1]+'@'+IntToStr(Group)+'x'+IntToStr(Element));
      If ((group = 160) Or (group = 256) Or (group = 340) Or (group = 512) Or
        (group = 640)) And ((element = 160) Or (element = 256) Or
        (element = 340) Or (element = 512)) Then
      Begin
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        read_elscint_data;
        exit;
      End; // confirmed: Elscint
    End;
    lGenesis := false;
    If ((tx[0] <> 'I') OR (tx[1] <> 'M') OR (tx[2] <> 'G') OR
      (tx[3] <> 'F')) Then
    Begin { DAT format }
      { if (FileSz > 114+305+4) then begin
        dseek(fp, 114+305);
        dBlockRead(fp, tx, 3*AnsiCharSz, n);
        if ((tx[0]='M') and (tx[1] = 'R')) or ((tx[0] = 'C') and(tx[1] = 'T')) then
        lGenesis := true;
        end; }
    End
    Else
      lGenesis := true;
    If (Not lGenesis) And (filesz > 3252) Then
    Begin
      dSeek(FP, 3240);
      dBlockRead(FP, tx, 4 * AnsiCharSz, N);
      If ((tx[0] = 'I') AND (tx[1] = 'M') AND (tx[2] = 'G') AND
        (tx[3] = 'F')) Then
        lGenesis := true;
      If (Not lGenesis) Then
      Begin
        dSeek(FP, 3178);
        dBlockRead(FP, tx, 4 * AnsiCharSz, N);
        If ((tx[0] = 'I') AND (tx[1] = 'M') AND (tx[2] = 'G') AND
          (tx[3] = 'F')) Then
          lGenesis := true;
      End;
      If (Not lGenesis) Then
      Begin
        dSeek(FP, 3180);
        dBlockRead(FP, tx, 4 * AnsiCharSz, N);
        If ((tx[0] = 'I') AND (tx[1] = 'M') AND (tx[2] = 'G') AND
          (tx[3] = 'F')) Then
          lGenesis := true;
      End;
      If (Not lGenesis) Then
      Begin // 1499K
        dSeek(FP, 0);
        dBlockRead(FP, tx, 4 * AnsiCharSz, N);
        If ((tx[0] = 'I') AND (tx[1] = 'M') AND (tx[2] = 'G') AND
          (tx[3] = 'F')) Then
          lGenesis := true;
      End;

    End;
    If (Not lGenesis) And (filesz > 3252) Then
    Begin
      dSeek(FP, 3228);
      dBlockRead(FP, tx, 4 * AnsiCharSz, N);
      If (tx[0] = 'I') AND (tx[1] = 'M') AND (tx[2] = 'G') AND
        (tx[3] = 'F') Then
        lGenesis := true;
    End;
    If lGenesis Then
    Begin
      closefile(FP);
      If lDiskCacheSz > 0 Then
        freemem(lDiskCacheRA);
      FileMode := 2; // set to read/write
      read_ge_data;
      exit;
    End;
  End; // AutodetectGenesis                        xxDCIM

  If (lAutoDetectInterfile) And (filesz > 256) And (Not lDICM_at_128) Then
  Begin
    If Copy(extractfilename(lFileName), 1, 4) = 'COR-' Then
    Begin
      lStr := extractfiledir(lFileName) + '\COR-.info';
      tmpstr := extractfiledir(lFileName) + '\COR-128';
      If fileexists(lStr) And fileexists(tmpstr) Then
      Begin
        lFileName := tmpstr;
        lDynStr := 'FreeSurfer COR format' + kCR + 'Only displaying image 128' +
          kCR + 'Use MRIcro''s Import menu to convert this image' + kCR;
        With data Do
        Begin
          little_endian := 0; // don't care
          ImageStart := 0;
          Allocbits_per_pixel := 8;
          XYZdim[1] := 256;
          XYZdim[2] := 256;
          XYZdim[3] := 1;
          XYZmm[1] := 1;
          XYZmm[2] := 1;
          XYZmm[3] := 1;
          Storedbits_per_pixel := Allocbits_per_pixel;
        END; // WITH
        lHdrOk := true;
        lImageFormatOK := true;
        exit;
      End; // COR-.info file exists
    End; // if filename is COR-
    // start TIF
    // TIF IMAGES DO NOT ALWAYS HAVE EXTENSION if (TmpStr = '.TIF') or (TmpStr = '.TIFF') then begin
    dSeek(FP, 0);
    lWord := read16(FP, lrOK);
    If lWord = $4D4D Then
      data.little_endian := 0
    Else If lWord = $4949 Then
      data.little_endian := 1;
    // dseek(fp, 2);
    lWord2 := read16(FP, lrOK); // bits per pixel
    If ((lWord = $4D4D) Or (lWord = $4949)) And (lWord2 = $002A) Then
    Begin
      closefile(FP);
      If lDiskCacheSz > 0 Then
        freemem(lDiskCacheRA);
      FileMode := 2; // set to read/write
      read_tiff_data(lReadECAToffsetTables);
      // if lHdrOk then exit;
      exit;
    End; // TIF signature
    // end; //.TIF extension
    // end TIF
    // start BMP 1667
    tmpstr := UpperCase(ExtractFileExt(lFileName));
    // string(StrUpper(PAnsiChar(ExtractFileExt(lFileName)))); //deprecated
    If tmpstr = '.BMP' Then
    Begin
      dSeek(FP, 0);
      lWord := read16(FP, lrOK);
      dSeek(FP, 28);
      lWord2 := read16(FP, lrOK); // bits per pixel
      If (lWord = 19778) And (lWord2 = 8) Then
      Begin // bitmap signature
        dSeek(FP, 10);
        data.ImageStart := read32(FP, lrOK); // 1078;
        dSeek(FP, 18);
        data.XYZdim[1] := read32(FP, lrOK);
        // dseek(fp, 22);
        data.XYZdim[2] := read32(FP, lrOK);
        data.XYZdim[3] := 1; // read16(fp,lrOK);
        data.Allocbits_per_pixel := 8; // bits
        data.Storedbits_per_pixel := data.Allocbits_per_pixel;
        lDynStr := 'BMP format';
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        lHdrOk := true;
        lImageFormatOK := true;
        exit;
      End; // bmp signature
    End; // .BMP extension
    // end BMP
    If tmpstr = '.VOL' Then
    Begin // start SPACE vol format 1382
      dSeek(FP, 0);
      dBlockRead(FP, tx, 6 * AnsiCharSz, N);
      If (tx[0] = 'm') And (tx[1] = 'd') And (tx[2] = 'v') And (tx[3] = 'o') And
        (tx[4] = 'l') And (tx[5] = '1') Then
      Begin
        data.ImageStart := read32(FP, lrOK); // 1078;
        data.little_endian := 1;
        data.XYZdim[1] := read32(FP, lrOK);
        data.XYZdim[2] := read32(FP, lrOK);
        data.XYZdim[3] := read32(FP, lrOK);
        data.XYZmm[1] := read32r(FP, lrOK);
        data.XYZmm[2] := read32r(FP, lrOK);
        data.XYZmm[3] := read32r(FP, lrOK);
        data.Allocbits_per_pixel := 8; // bits
        data.Storedbits_per_pixel := data.Allocbits_per_pixel;
        lDynStr := 'Space VOL format';
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        lHdrOk := true;
        lImageFormatOK := true;
        exit;
      End; // vol signature
    End; // .VOL extension
    // end space .VOL format
    // start DF3 PovRay DF3 density files
    If (tmpstr = '.DF3') Then
    Begin
      dSeek(FP, 0);
      lWord := system.swap(read16(FP, lrOK));
      lWord2 := system.swap(read16(FP, lrOK));
      lWord3 := system.swap(read16(FP, lrOK));
      // note: I assume all df3 headers are little endian. is this always true? if not, unswapped values could be tested for filesize
      lMatrixSz := (lWord * lWord2 * lWord3) + 6;
      If (lMatrixSz = filesz) Then
      Begin // df3 signature
        data.ImageStart := 6; // 1078;
        data.XYZdim[1] := lWord;
        // dseek(fp, 22);
        data.XYZdim[2] := lWord2;
        data.XYZdim[3] := lWord3;
        data.Allocbits_per_pixel := 8; // bits
        data.Storedbits_per_pixel := data.Allocbits_per_pixel;
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        lDynStr := 'PovRay DF3 density format';
        lHdrOk := true;
        lImageFormatOK := true;
        exit;
      End; // df3 signature
    End;
    // end df3

    // start .PGM
    If (tmpstr = '.PGM') Or (tmpstr = '.PPM') Then
    Begin
      dSeek(FP, 0);
      lWord := read16(FP, lrOK);
      If (lWord = 13648) { 'P5'=1x8BIT GRAYSCALE } Or (lWord = 13904)
      { 'P6'=3x8bit RGB } Then
      Begin // bitmap signature
        { repeat
          PGMreadStr(Data.XYZdim[1],Data.XYZdim[2]);
          until (Data.XYZdim[2] > 0) ; }
        data.XYZdim[1] := PGMreadInt;
        data.XYZdim[2] := PGMreadInt;
        PGMreadInt; // read maximum value

        data.XYZdim[3] := 1; // read16(fp,lrOK);
        data.Allocbits_per_pixel := 8; // bits
        data.Storedbits_per_pixel := data.Allocbits_per_pixel;
        data.ImageStart := dFilePos(FP);
        If lWord = 13904 Then
        Begin // RGB
          data.SamplesPerPixel := 3;
          data.PlanarConfig := 0;
          // RGBRGBRGB..., not RRR..RGGG..GBBB...B
        End;
        lDynStr :=
          'PGM/PPM format 8-bit grayscale image [data saved in binary, not ASCII format]';
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        lHdrOk := true;
        lImageFormatOK := true;
        exit;
      End
      Else If (lWord = 12880) { 'P2'=1x8BIT ASCII } Or (lWord = 13136)
      { 'P3'=3x8bit ASCI } Then
      Begin
        showmessage
          ('Warning: this image appears to be an ASCII ppm/pgm image. This software can only read binary ppm/pgm images');
      End; // pgm/ppm binary signature signature
    End; // .PPM/PGM extension

    // end .pgm

    // start BioRadPIC 1667
    If tmpstr = '.PIC' Then
    Begin
      dSeek(FP, 54);
      lWord := read16(FP, lrOK);
      If (lWord = 12345) Then
      Begin
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        read_biorad_data;
        exit;
      End; // biorad signature
    End; // .PIC extension biorad?
    // end BIORAD PIC
    If tmpstr = '.HEAD' Then
    Begin
      read_afni_data(lRot1, lRot2, lRot3);
      If (lHdrOk) And (lImageFormatOK) Then
      Begin
        closefile(FP);
        If lDiskCacheSz > 0 Then
          freemem(lDiskCacheRA);
        FileMode := 2; // set to read/write
        exit;
      End;
    End;
    dSeek(FP, 0);
    dBlockRead(FP, tx, 20 * AnsiCharSz, N);
    If (tx[0] = 'n') And (tx[1] = 'c') And (tx[2] = 'a') And (tx[3] = 'a') Then
    Begin
      // SUN Vision File Format = .vff
      // showmessage('vff');
      closefile(FP);
      If lDiskCacheSz > 0 Then
        freemem(lDiskCacheRA);
      FileMode := 2; // set to read/write
      read_VFF_data;
      exit;
    End;
    // liPos := 1;
    // lStr := '';
    // Reset(fp,AnsiCharSz);
    // BlockRead(fp,tx,20);
    { While (liPos <= 20) and (lStr <> 'INTERFILE') do   //interfile is handled elsewhere
      begin
      if charinset(tx[liPos], ['i', 'n', 't', 'e', 'r', 'f', 'i', 'l', 'e', 'I',
      'N', 'T', 'E', 'R', 'F', 'I', 'L', 'E']) then
      lStr := lStr + upcase(tx[liPos]);
      inc(liPos);
      end;
      if lStr = 'INTERFILE' then
      begin
      closefile(FP);
      if lDiskCacheSz > 0 then
      freemem(lDiskCacheRA);
      FileMode := 2; // set to read/write
      read_interfile_data(Data, lHdrOk, lImageFormatOK, lDynStr, lFileName);
      if lHdrOk then
      exit;
      exit;
      end; // 'INTERFILE' in first 20 AnsiChar }
    // begin parfile
    liPos := 1;
    lStr := '';
    While (liPos <= 20) And (lStr <> 'DATADESC') And (lStr <> 'EXPERIME') Do
    Begin
      If charinset(tx[liPos], ['A' .. 'Z', 'a' .. 'z']) Then
        lStr := lStr + upcase(tx[liPos]);
      inc(liPos);
    End;
    // showmessage(lStr);
    If (lStr = 'DATADESC') Or (lStr = 'EXPERIME') Then
    Begin
      closefile(FP);
      If lDiskCacheSz > 0 Then
        freemem(lDiskCacheRA);
      FileMode := 2; // set to read/write
      read_PAR_data(false, lLongRA, lJunk1, false, lSingleRA, lInterceptRA,
        lJunk2, lJunk3);
      lJunk := lJunk1;
      If lHdrOk Then
        exit;
      exit;
    End; // 'DATADESC' in first 20 AnsiChar ->parfile
    // end parfile
  End; // detectint
  // try DICOM part 10 i.e. a 128 byte file preamble followed by "DICM"
  If filesz <= 300 Then
    Goto 666;
  { begin siemens somatom: DO THIS BEFORE MAGNETOM: BOTH HAVE 'SIEMENS' SIGNATURE, SO CHECK FOR 'SOMATOM' }
  If filesz = 530432 Then
  Begin
    dSeek(FP, 281);
    dBlockRead(FP, tx, 8 * AnsiCharSz, N);
    If (tx[0] = 'S') And (tx[1] = 'O') And (tx[2] = 'M') And (tx[3] = 'A') And
      (tx[4] = 'T') And (tx[5] = 'O') And (tx[6] = 'M') Then
    Begin
      // Showmessage('somatom');
      data.ImageStart := 6144;
      data.Allocbits_per_pixel := 16;
      data.Storedbits_per_pixel := 16;
      data.little_endian := 0;
      data.XYZdim[1] := 512;
      data.XYZdim[2] := 512;
      data.XYZdim[3] := 1;
      dSeek(FP, 5999); // Study/Image from 5292 "STU/IMA   1070/16"
      data.AcquNum := trunc(SomaTomFloat);
      // Slice Thickness from 5790 "SL   3.0"
      data.ImageNum := trunc(SomaTomFloat);
      // Slice Thickness from 5790 "SL   3.0"
      dSeek(FP, 5792); // Slice Thickness from 5790 "SL   3.0"
      data.XYZmm[3] := SomaTomFloat;
      // Slice Thickness from 5790 "SL   3.0"
      dSeek(FP, 5841); // Field of View from 5838 "FoV   281"
      data.XYZmm[1] := SomaTomFloat;
      // Field of View from 5838 "FoV   281"
      data.XYZmm[2] := data.XYZmm[1] / data.XYZdim[2];
      // do mm[2] first before FOV is overwritten
      data.XYZmm[1] := data.XYZmm[1] / data.XYZdim[1];
      If lVerboseRead Then
        lDynStr := 'Siemens Somatom Format' + kCR + 'Image Series/Number: ' +
          IntToStr(data.AcquNum) + '/' + IntToStr(data.ImageNum) + kCR +
          'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/' + IntToStr(data.XYZdim[2])
          + '/' + IntToStr(data.XYZdim[3]) + kCR + 'XYZ mm:' +
          floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/' +
          floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
          floattostrf(data.XYZmm[3], ffFixed, 8, 2);
      closefile(FP);
      If lDiskCacheSz > 0 Then
        freemem(lDiskCacheRA);
      FileMode := 2; // set to read/write
      lImageFormatOK := true;
      lHdrOk := true;
      exit;
    End; // signature found
  End; // correctsize for somatom
  { end siemens somatom }

  { siemens magnetom }
  dSeek(FP, 96);
  dBlockRead(FP, tx, 7 * AnsiCharSz, N);
  If (tx[0] = 'S') And (tx[1] = 'I') And (tx[2] = 'E') And (tx[3] = 'M') And
    (tx[4] = 'E') And (tx[5] = 'N') And (tx[6] = 'S') Then
  Begin
    closefile(FP);
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    read_siemens_data;
    exit;
  End;
  { end siemens magnetom vision }
  { siemens somatom plus }
  dSeek(FP, 0);
  dBlockRead(FP, tx, 8 * AnsiCharSz, N);
  If (tx[0] = 'S') And (tx[1] = 'I') And (tx[2] = 'E') And (tx[3] = 'M') And
    (tx[4] = 'E') And (tx[5] = 'N') And (tx[6] = 'S') Then
  Begin
    data.ImageStart := 8192;
    data.Allocbits_per_pixel := 16;
    data.Storedbits_per_pixel := 16;
    data.little_endian := 0;
    dSeek(FP, 1800); // slice thickness
    data.XYZmm[3] := read64(FP, lrOK);
    dSeek(FP, 4100);
    data.AcquNum := read32(FP, lrOK);
    dSeek(FP, 4108);
    data.ImageNum := read32(FP, lrOK);
    dSeek(FP, 4992); // X FOV
    data.XYZmm[1] := read64(FP, lrOK);
    dSeek(FP, 5000); // Y FOV
    data.XYZmm[2] := read64(FP, lrOK);
    dSeek(FP, 5340);
    data.XYZdim[1] := read32(FP, lrOK);
    dSeek(FP, 5344);
    data.XYZdim[2] := read32(FP, lrOK);
    data.XYZdim[3] := 1;
    If data.XYZdim[1] > 0 Then
      data.XYZmm[1] := data.XYZmm[1] / data.XYZdim[1];
    If data.XYZdim[2] > 0 Then
      data.XYZmm[2] := data.XYZmm[2] / data.XYZdim[2];
    If lVerboseRead Then
      lDynStr := 'Siemens Somatom Plus Format' + kCR + 'Image Series/Number: ' +
        IntToStr(data.AcquNum) + '/' + IntToStr(data.ImageNum) + kCR +
        'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/' + IntToStr(data.XYZdim[2]) +
        '/' + IntToStr(data.XYZdim[3]) + kCR + 'XYZ mm:' +
        floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/' +
        floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
        floattostrf(data.XYZmm[3], ffFixed, 8, 2);

    closefile(FP);
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    lImageFormatOK := true;
    lHdrOk := true;
    exit;
  End;
  { end siemens somatom plus }
  { begin vista }
  { dSeek(FP, 0);  vista will be treated as analyze
    dBlockRead(FP, tx, 8 * AnsiCharSz, n);
    if (tx[0] = 'V') and (tx[1] = '-') and (tx[2] = 'd') and (tx[3] = 'a') and
    (tx[4] = 't') and (tx[5] = 'a') then
    begin
    closefile(FP);
    if lDiskCacheSz > 0 then
    freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    read_vista_data(false, false, Data, lHdrOk, lImageFormatOK, lDynStr,
    FileName);
    if lHdrOk then
    exit;
    exit;
    end; }
  { end vista }
  { picker }
  dSeek(FP, 0);
  dBlockRead(FP, tx, 8 * AnsiCharSz, N);
  If (tx[0] = 'C') And (tx[1] = 'D') And (tx[2] = 'F') And (ord(tx[3]) = 1) Then
  Begin
    closefile(FP);
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    read_minc_data;
    exit;
  End;
  If (lAutoDECAT7) And (tx[0] = 'M') And (tx[1] = 'A') And (tx[2] = 'T') And
    (tx[3] = 'R') And (tx[4] = 'I') And (tx[5] = 'X') Then
  Begin
    closefile(FP);
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    read_ecat_data(lVerboseRead, lReadECAToffsetTables);
    exit;
  End;
  If (tx[0] = '*') AND (tx[1] = '*') AND (tx[2] = '*') AND (tx[3] = ' ') Then
  Begin { picker Standard }
    closefile(FP);
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    read_picker_data(lVerboseRead);
    exit;
  End; { not picker standard }
  // Start Picker Prism
  lJunk := filesz - 2048;
  data.little_endian := 0;
  // start: read x
  dSeek(FP, 322);
  Width := read16(FP, lrOK);

  // start: read y
  dSeek(FP, 326);
  Ht := read16(FP, lrOK);
  lMatrixSz := Width * Ht;

  // check if correct filesize for picker prism
  If (ord(tx[0]) = 1) And (ord(tx[1]) = 2) And ((lJunk Mod lMatrixSz) = 0)
  { 128*128*2bytes = 32768 } Then
  Begin // Picker PRISM
    data.little_endian := 0;
    data.XYZdim[1] := Width;
    data.XYZdim[2] := Ht;
    data.XYZdim[3] := (lJunk Div 32768); { 128*128*2bytes = 32768 }
    data.Allocbits_per_pixel := 16;
    data.Storedbits_per_pixel := 16;
    data.ImageStart := 2048;
    // start: read slice thicness
    dSeek(FP, 462);
    dBlockRead(FP, tx, 12 * AnsiCharSz, N);
    lStr := '';
    For lJunk := 0 To 11 Do
      If charinset(tx[lJunk], ['0' .. '9', '.']) Then
        lStr := lStr + tx[lJunk];
    If lStr <> '' Then
      data.XYZmm[3] := str2float(lStr);
    // start: voxel size
    dSeek(FP, 594);
    dBlockRead(FP, tx, 12 * AnsiCharSz, N);
    lStr := '';
    For lJunk := 0 To 11 Do
      If charinset(tx[lJunk], ['0' .. '9', '.']) Then
        lStr := lStr + tx[lJunk];
    If lStr <> '' Then
      data.XYZmm[1] := str2float(lStr);
    data.XYZmm[2] := data.XYZmm[1];
    // end: read voxel sizes
    // start: patient name
    dSeek(FP, 26);
    dBlockRead(FP, tx, 22 * AnsiCharSz, N);
    lStr := '';
    lJunk := 0;
    While (lJunk < 22) And (ord(tx[lJunk]) <> 0) Do
    Begin
      lStr := lStr + tx[lJunk];
      inc(lJunk);
    End;
    data.PatientName := lStr;
    // start: patient ID
    dSeek(FP, 48);
    dBlockRead(FP, tx, 15 * AnsiCharSz, N);
    lStr := '';
    lJunk := 0;
    While (lJunk < 15) And (ord(tx[lJunk]) <> 0) Do
    Begin
      lStr := lStr + tx[lJunk];
      inc(lJunk);
    End;
    data.PatientID := lStr;
    // start: scan time
    dSeek(FP, 186);
    dBlockRead(FP, tx, 25 * AnsiCharSz, N);
    lStr := '';
    lJunk := 0;
    While (lJunk < 25) And (ord(tx[lJunk]) <> 0) Do
    Begin
      lStr := lStr + tx[lJunk];
      inc(lJunk);
    End;
    // start: scanner type
    dSeek(FP, 2);
    dBlockRead(FP, tx, 25 * AnsiCharSz, N);
    lgrpstr := '';
    lJunk := 0;
    While (lJunk < 25) And (ord(tx[lJunk]) <> 0) Do
    Begin
      lgrpstr := lgrpstr + tx[lJunk];
      inc(lJunk);
    End;
    // report results
    If lVerboseRead Then
      lDynStr := 'Picker Format ' + lgrpstr + kCR + 'Patient Name: ' +
        data.PatientName + kCR + 'Patient ID: ' + data.PatientID + kCR +
        'Scan Time: ' + lStr + kCR + 'XYZ dim:' + IntToStr(data.XYZdim[1]) + '/'
        + IntToStr(data.XYZdim[2]) + '/' + IntToStr(data.XYZdim[3]) + kCR +
        'XYZ mm:' + floattostrf(data.XYZmm[1], ffFixed, 8, 2) + '/' +
        floattostrf(data.XYZmm[2], ffFixed, 8, 2) + '/' +
        floattostrf(data.XYZmm[3], ffFixed, 8, 2);
    closefile(FP);
    If lDiskCacheSz > 0 Then
      freemem(lDiskCacheRA);
    FileMode := 2; // set to read/write
    lImageFormatOK := true;
    lHdrOk := true;
    exit;
    exit;
  End; // end Picker PRISM
  lMatrixSz := 0;

  data.little_endian := 1;
  lBig := false;
  dSeek(FP, { 0 } 128);
  // where := FilePos(fp);
  dBlockRead(FP, tx, 4 * AnsiCharSz, N);
  If (tx[0] <> 'D') OR (tx[1] <> 'I') OR (tx[2] <> 'C') OR (tx[3] <> 'M') Then
  Begin
    // if filesz > 132 then begin
    dSeek(FP, 0 { 128 } );
    // skip the preamble - next 4 bytes should be 'DICM'
    // where := FilePos(fp);
    dBlockRead(FP, tx, 4 * AnsiCharSz, N);
    // end;
    If (tx[0] <> 'D') OR (tx[1] <> 'I') OR (tx[2] <> 'C') OR (tx[3] <> 'M') Then
    Begin
      // showmessage('DICM not at 0 or 128');
      dSeek(FP, 0);
      group := read16(FP, lrOK);
      If Not lrOK Then
        Goto 666;
      If group > $0008 Then
      Begin
        group := system.swap(group);
        lBig := true;
      End;
      If NOT(group In [$0000, $0001, $0002, $0003, $0004, $0008]) Then
      // one more group added
      Begin
        Goto 666;
      End;
      dSeek(FP, 0);
    End;
  End; // else showmessage('DICM at 128{0}');;
  // Read DICOM Tags
  { lPapyrus := false;
    lPapyrusZero := false;
    lPapyrusnSlices := 0; //NOT papyrus multislice image
    lPapyrusSlice := 0;{ }
  time_to_quit := false;
  lProprietaryImageThumbnail := false;
  explicitVR := false;
  tmpstr := '';

  tmp := 0;
  While NOT time_to_quit Do
  Begin
    t := unknown;
    where := dFilePos(FP);
    lFirstPass := true;
  777:
    group := read16(FP, lrOK);
    If Not lrOK Then
      Goto 666;

    If (lFirstPass) And (group = 2048) Then
    Begin
      If data.little_endian = 1 Then
        data.little_endian := 0
      Else
        data.little_endian := 1;
      dSeek(FP, where);
      lFirstPass := false;
      Goto 777;
    End;
    element := read16(FP, lrOK);
    If Not lrOK Then
      Goto 666;
    e_len := read32(FP, lrOK);
    If Not lrOK Then
      Goto 666;
    lgrpstr := '';
    lT0 := e_len And 255;
    lT1 := (e_len Shr 8) And 255;
    lT2 := (e_len Shr 16) And 255;
    lT3 := (e_len Shr 24) And 255;
    If (explicitVR) And (lT0 = 13) And (lT1 = 0) And (lT2 = 0) And
      (lT3 = 0) Then
      e_len := 10; // hack for some GE Dicom images

    If explicitVR Or first_one Then
    Begin
      If group = $FFFE Then
      Else // 1384  - ACUSON images switch off ExplicitVR for file image fragments
        If ((lT0 = kO) And (lT1 = kB)) Or ((lT0 = kU) And (lT1 = kN))
        { <-UN added } Or ((lT0 = kO) And (lT1 = kW)) Or
          ((lT0 = kS) And (lT1 = kQ)) Then
        Begin
          lgrpstr := chr(lT0) + chr(lT1);
          e_len := read32(FP, lrOK);
          If Not lrOK Then
            Goto 666;
          If first_one Then
            explicitVR := true;
        End
        Else If ((lT3 = kO) And (lT2 = kB)) Or ((lT3 = kU) And (lT2 = kN))
        { <-UN added } Or ((lT3 = kO) And (lT2 = kW)) Or
          ((lT3 = kS) And (lT2 = kQ)) Then
        Begin
          e_len := read32(FP, lrOK);
          If Not lrOK Then
            Goto 666;
          If first_one Then
            explicitVR := true;
        End
        Else If (((lT0 = kA) And (lT1 = kE)) Or ((lT0 = kA) And (lT1 = kS)) Or
          ((lT0 = kA) And (lT1 = kT)) Or ((lT0 = kC) And (lT1 = kS)) Or
          ((lT0 = kD) And (lT1 = kA)) Or ((lT0 = kD) And (lT1 = kS)) Or
          ((lT0 = kD) And (lT1 = kT)) Or ((lT0 = kF) And (lT1 = kL)) Or
          ((lT0 = kF) And (lT1 = kD)) Or ((lT0 = kI) And (lT1 = kS)) Or
          ((lT0 = kL) And (lT1 = kO)) Or ((lT0 = kL) And (lT1 = kT)) Or
          ((lT0 = kP) And (lT1 = kN)) Or ((lT0 = kS) And (lT1 = kH)) Or
          ((lT0 = kS) And (lT1 = kL)) Or ((lT0 = kS) And (lT1 = kS)) Or
          ((lT0 = kS) And (lT1 = kT)) Or ((lT0 = kT) And (lT1 = kM)) Or
          ((lT0 = kU) And (lT1 = kI)) Or ((lT0 = kU) And (lT1 = kL)) Or
          ((lT0 = kU) And (lT1 = kS)) Or ((lT0 = kA) And (lT1 = kE)) Or
          ((lT0 = kA) And (lT1 = kS))) Then
        Begin
          lgrpstr := chr(lT0) + chr(lT1);
          If data.little_endian = 1 Then
            e_len := (e_len And $FFFF0000) Shr 16
          Else
            e_len := system.swap((e_len And $FFFF0000) Shr 16);
          If first_one Then
          Begin
            explicitVR := true;
          End;
        End
        Else If (((lT3 = kA) And (lT2 = kT)) Or ((lT3 = kC) And (lT2 = kS)) Or
          ((lT3 = kD) And (lT2 = kA)) Or ((lT3 = kD) And (lT2 = kS)) Or
          ((lT3 = kD) And (lT2 = kT)) Or ((lT3 = kF) And (lT2 = kL)) Or
          ((lT3 = kF) And (lT2 = kD)) Or ((lT3 = kI) And (lT2 = kS)) Or
          ((lT3 = kL) And (lT2 = kO)) Or ((lT3 = kL) And (lT2 = kT)) Or
          ((lT3 = kP) And (lT2 = kN)) Or ((lT3 = kS) And (lT2 = kH)) Or
          ((lT3 = kS) And (lT2 = kL)) Or ((lT3 = kS) And (lT2 = kS)) Or
          ((lT3 = kS) And (lT2 = kT)) Or ((lT3 = kT) And (lT2 = kM)) Or
          ((lT3 = kU) And (lT2 = kI)) Or ((lT3 = kU) And (lT2 = kL)) Or
          ((lT3 = kU) And (lT2 = kS))) Then
        Begin
          If data.little_endian = 1 Then
            e_len := (256 * lT0) + lT1
          Else
            e_len := (lT0) + (256 * lT1);
          If first_one Then
          Begin
            explicitVR := true;
          End;
        End;
    End; // not first_one or explicit

    If (first_one) And (data.little_endian = 0) And (e_len = $04000000) Then
    Begin
      showmessage('Switching to little endian');
      data.little_endian := 1;
      dSeek(FP, where);
      first_one := false;
      Goto 777;
    End
    Else If (first_one) And (data.little_endian = 1) And
      (e_len = $04000000) Then
    Begin
      showmessage('Switching to big endian');
      data.little_endian := 0;
      dSeek(FP, where);
      first_one := false;
      Goto 777;
    End;

    If e_len = ($FFFFFFFF) Then
    Begin
      e_len := 0;
    End;
    If lGELX Then
    Begin
      e_len := e_len And $FFFF;
    End;
    first_one := false;
    remaining := e_len;
    info := '?';
    tmpstr := '';
    Case group Of
      $0001: // group for normal reading elscint DICOM
        Case element Of
          $0010:
            info := 'Name';
          $1001:
            info := 'Elscint info';
        End;
      $0002:
        Case element Of
          $00:
            info := 'File Meta Elements Group Len';
          $01:
            info := 'File Meta Info Version';
          $02:
            info := 'Media Storage SOP Class UID';
          $03:
            info := 'Media Storage SOP Inst UID';
          $10:
            Begin
              // lTransferSyntaxReported := true;
              info := 'Transfer Syntax UID';
              tmpstr := '';
              If dFilePos(FP) > (filesz - e_len) Then
                Goto 666;
              getmem(buff, e_len);
              dBlockRead(FP, buff { ^ } , e_len, N);
              For i := 0 To e_len - 1 Do
                If charinset(buff[i], ['+', '-', ' ', '0' .. '9', 'a' .. 'z',
                  'A' .. 'Z']) Then
                  tmpstr := tmpstr + buff[i]
                Else
                  tmpstr := tmpstr + ('.');
              freemem(buff);
              lStr := '';
              If tmpstr = '1.2.840.113619.5.2' Then
              Begin
                lGELX := true;
                lBigSet := true;
                lBig := true;
              End;
              If Length(tmpstr) >= 19 Then
              Begin
                If tmpstr[19] = '1' Then
                Begin
                  lBigSet := true;
                  explicitVR := true; // duran
                  lBig := false;
                End
                Else If tmpstr[19] = '2' Then
                Begin
                  lBigSet := true;
                  explicitVR := true; // duran
                  lBig := true;
                End
                Else If tmpstr[19] = '4' Then
                Begin
                  If Length(tmpstr) >= 21 Then
                  Begin
                    // ShowMessage('Unable to extract JPEG: '+TmpStr[21]+TmpStr[22])
                    // Data.JPEGCpt := true;
                    If Not lReadJPEGtables Then
                    Begin
                      lImageFormatOK := false;
                      // showmessage('Unable to extract JPEG compressed DICOM files. Use MRIcro to convert this file.');
                    End
                    Else
                    Begin
                      i := strtoint(tmpstr[21] + tmpstr[22]);
                      // showmessage(IntToStr(i));
                      // if (TmpStr[22] <> '0') or ((TmpStr[21] <> '7') or (TmpStr[21] <> '0'))
                      If (i <> 57) And (i <> 70) Then
                        data.JPEGlossycpt := true
                      Else
                        data.JPEGlosslesscpt := true;
                    End;
                  End
                  Else
                  Begin
                    showmessage('Unknown Transfer Syntax: JPEG?');
                    lImageFormatOK := false;
                  End;
                End
                Else If tmpstr[19] = '5' Then
                Begin
                  data.runlengthencoding := true;
                  // ShowMessage('Note: Unable to extract lossless run length encoding: '+TmpStr[17]);
                  // lImageFormatOK := false;
                End
                Else
                Begin
                  showmessage('Unable to extract unknown data type: ' +
                    tmpstr[17]);
                  lImageFormatOK := false;
                End;
              End; { length }
              remaining := 0;
              e_len := 0; { use tempstr }
            End;
          $12:
            Begin
              info := 'Implementation Class UID';
            End;
          $13:
            Begin
              info := 'Implementation Version Name';
              If e_len > 4 Then
              Begin
                tmpstr := '';
                DICOMHeaderString(tmpstr);
                // if (Length(TmpStr)>4) and (TmpStr[1]='M') and (TmpStr[2]='E') and (TmpStr[3]='D') and (TmpStr[4]='I') then
                // showmessage('xx'+TMpStr+'xx');
                If tmpstr = 'MEDIFACE 1 5' Then
                  lMediface0002_0013 := true;
                // detect MEDIFACE 1.5 error: error in length of two elements 0008:1111 and 0008:1140
              End; // length > 4
            End; // element 13
          $16:
            info := 'Source App Entity Title';
          $100:
            info := 'Private Info Creator UID';
          $102:
            info := 'Private Info';
        End;
      $0008:
        Case element Of
          $00:
            Begin
              info := 'Identifying Group Length';
            End;
          $01:
            info := 'Length to End';
          $05:
            info := 'Specific Character Set';
          $08:
            Begin
              info := 'Image Type';
              // Only read last word, e.g. 'TYPE\MOSAIC' will be read as 'MOSAIC'
              tmpstr := '';
              If dFilePos(FP) > (filesz - e_len) Then
                Goto 666;
              getmem(buff, e_len);
              dBlockRead(FP, buff { ^ } , e_len, N);
              i := e_len;
              While (i > 0) And charinset(buff[i - 1],
                ['a' .. 'z', 'A' .. 'Z', ' ']) Do
              Begin
                If (buff[i - 1] <> ' ') Then
                  // strip filler characters: DICOM elements must be padded for even length
                  tmpstr := upcase(buff[i - 1]) + tmpstr;
                dec(i);
              End;
              freemem(buff);
              remaining := 0;
              e_len := 0; { use tempstr }
              If tmpstr = 'MOSAIC' Then
                lSiemensMosaic0008_0008 := true;

              // showmessage(TmpStr);
            End;
          $10:
            info := 'Recognition Code';
          $12:
            info := 'Instance Creation Date';
          $13:
            info := 'Instance Creation Time';
          $14:
            info := 'Instance Creator UID';
          $16:
            info := 'SOP Class UID';
          $18:
            info := 'SOP Instance UID';
          $20:
            Begin
              info := 'Study Date';
              data.StudyDatePos := dFilePos(FP);
              DICOMHeaderString(data.StudyDate);
            End;
          $21:
            info := 'Series Date';
          $22:
            info := 'Acquisition Date';
          $23:
            info := 'Image Date';
          $30:
            info := 'Study Time';
          $31:
            info := 'Series Time';
          $32:
            Begin
              info := 'Acquisition Time';
              DICOMHeaderStringTime(data.AcqTime);
            End;
          $33:
            Begin
              info := 'Image Time';
              DICOMHeaderStringTime(data.ImgTime);
            End;
          $40:
            info := 'Data Set Type';
          $41:
            info := 'Data Set Subtype';
          $50:
            Begin
              DICOMHeaderStringToInt(data.Accession);
              info := 'Accession Number';
            End;

          $60:
            Begin
              info := 'Modality';
              t := _string;
            End;
          $64:
            Begin
              info := 'Conversion Type';
              t := _string;
            End;
          $70:
            info := 'Manufacturer';
          $80:
            info := 'Institution Name';
          $81:
            info := 'City Name';
          $90:
            info := 'Referring Physician''s Name';
          $100:
            info := 'Code Value';
          $102:
            Begin
              info := 'Coding Schema Designator';
              t := _string;
            End;
          $104:
            info := 'Code Meaning';
          $1010:
            info := 'Station Name';
          $1030:
            Begin
              info := 'Study Description';
              t := _string;
            End;
          $103E:
            Begin
              info := 'Series Description';
              t := _string;
            End;
          $1040:
            info := 'Institutional Dept. Name';
          $1050:
            info := 'Performing Physician''s Name';
          $1060:
            info := 'Name Phys(s) Read Study';
          $1070:
            Begin
              info := 'Operator''s Name';
              t := _string;
            End;
          $1080:
            info := 'Admitting Diagnosis Description';
          $1090:
            Begin
              info := 'Manufacturer''s Model Name';
              t := _string;
            End;
          $1111:
            Begin
              // showmessage(IntToStr(dFilePos(fp)));
              If lMediface0002_0013 Then
                e_len := 8; // +e_len;
            End; // ABBA: patches error in DICOM images seen from Sheffield 0002,0013=MEDIFACE.1.5; 0002,0016=PICKER.MR.SCU
          $1140:
            Begin
              If (lMediface0002_0013) And (e_len > 255) Then
                e_len := 8;
            End; // ABBA: patches error in DICOM images seen from Sheffield 0002,0013=MEDIFACE.1.5; 0002,0016=PICKER.MR.SCU
          $2111:
            info := 'Derivation Description';
          $2120:
            info := 'Stage Name';
          $2122:
            Begin
              info := 'Stage Number';
              t := _string;
            End;
          $2124:
            Begin
              info := 'Number of Stages';
              t := _string;
            End;
          $2128:
            Begin
              info := 'View Number';
              t := _string;
            End;
          $212A:
            Begin
              info := 'Number of Views in stage';
              t := _string;
            End;
          $2204:
            info := 'Transducer Orientation';

        End;
      $0009:
        If element = $0010 Then
        Begin

          If e_len > 4 Then
          Begin
            tmpstr := '';
            If dFilePos(FP) > (filesz - e_len) Then
              Goto 666;
            getmem(buff, e_len);
            dBlockRead(FP, buff { ^ } , e_len, N);
            i := e_len;
            Repeat
              If charinset(buff[i - 1], ['a' .. 'z', 'A' .. 'Z']) Then
                // strip filler characters: DICOM elements must be padded for even length
                tmpstr := upcase(buff[i - 1]) + tmpstr;
              dec(i);
            Until i = 0;
            freemem(buff);
            remaining := 0;
            If (Length(tmpstr) > 4) And (tmpstr[1] = 'M') And (tmpstr[2] = 'E')
              And (tmpstr[3] = 'R') And (tmpstr[4] = 'G') Then
              lOldSiemens_IncorrectMosaicMM := true;
            // detect MERGE technologies mosaics
            e_len := 0; { use tempstr }
            // if (TmpStr[1] = 'M') then
          End;

        End;
      $0010:
        Case element Of
          $00:
            info := 'Patient Group Length';
          $10:
            Begin
              info := 'Patient''s Name';
              t := _string;
              data.NamePos := dFilePos(FP);
              DICOMHeaderString(data.PatientName);
            End;
          $20:
            Begin
              info := 'Patient ID';
              DICOMHeaderString(data.PatientID);
              data.PatientIDint := SafeStrToInt(data.PatientID);
              // showmessage(Data.PatientID+'@'+IntToStr(Data.PatientIDInt));
            End;
          $30:
            info := 'Patient Date of Birth';
          $32:
            info := 'Patient Birth Time';
          $40:
            Begin
              info := 'Patient Sex';
              t := _string;
            End;
          $1000:
            info := 'Other Patient IDs';
          $1001:
            info := 'Other Patient Names';
          $1005:
            info := 'Patient''s Birth Name';
          $1010:
            Begin
              info := 'Patient Age';
              t := _string;
            End;
          $1030:
            info := 'Patient Weight';
          $21B0:
            info := 'Additional Patient History';
          $4000:
            info := 'Patient Comments';

        End;
      $0018:
        Case element Of
          $00:
            info := 'Acquisition Group Length';
          $10:
            Begin
              info := 'Contrast/Bolus Agent';
              t := _string;
            End;
          $15:
            info := 'Body Part Examined';
          $20:
            Begin
              info := 'Scanning Sequence';
              t := _string;
            End;
          $21:
            Begin
              info := 'Sequence Variant';
              t := _string;
            End;
          $22:
            info := 'Scan Options';
          $23:
            Begin
              info := 'MR Acquisition Type';
              t := _string;
            End;
          $24:
            info := 'Sequence Name';
          $25:
            Begin
              info := 'Angio Flag';
              t := _string;
            End;
          $30:
            info := 'Radionuclide';
          $50:
            Begin
              info := 'Slice Thickness';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              data.XYZmm[3] := lFloat1;
            End;
          // $60: begin info := 'KVP [Peak Output, KV]';  t := _string; end; //aqw
          $60:
            Begin
              info := 'KVP [Peak KV]';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              data.kV := lFloat1;
            End;

          $70:
            Begin
              t := _string;
              info := 'Counts Accumulated';
            End;
          $71:
            Begin
              t := _string;
              info := 'Acquisition Condition';
            End;
          // $80 :  begin info := 'Repetition Time';  t := _string; end; //aqw
          // $81 :  begin info := 'Echo Time'; t := _string; end;  //aqw
          $80:
            Begin
              info := 'Repetition Time [TR, ms]';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              data.TR := lFloat1;
            End;

          $81:
            Begin
              info := 'Echo Time [TE, ms]';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              data.TE := lFloat1;
            End;
          $82:
            Begin
              t := _string;
              info := 'Inversion Time';
            End;
          $83:
            Begin
              t := _string;
              info := 'Number of Averages';
            End;
          $84:
            info := 'Imaging Frequency';
          $85:
            Begin
              info := 'Imaged Nucleus';
              t := _string;
            End;
          $86:
            Begin
              info := 'Echo Number';
              t := _string;
              DICOMHeaderStringToInt(data.VolumeNumber);
              { xx           DICOMHeaderString(TmpStr);
                //showmessage(TmpStr);
                Data.VolumeNumber := strtoint(TmpStr);

                {magma
                TmpStr := ReadStr(fp, remaining,lrOK,lMatrixSz);//1362
                if not lrOK then goto 666;
                e_len := 0; remaining := 0;
                xx
                showmessage(IntToStr(lMatrixSz));
              }
            End;
          $87:
            info := 'Magnetic Field Strength';
          $88:
            Begin
              info := 'Spacing Between Slices';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              // 1362 some use this for gap size, others for sum of gap and slicethickness!
              // 3333 if (lfloat1 > Data.XYZmm[3]) or (Data.XYZmm[3]=1) then
              // data.XYZmm[3] := lFloat1;
              data.Spacing := lFloat1;
            End;
          $89:
            Begin
              // t := _string;
              info := 'Number of Phase Encoding Steps';
              // 1499c This is a indirect method for detecting SIemens Mosaics: check if image height is evenly divisible by encoding steps
              // A real kludge due to Siemens not documenting mosaics explicitly: this workaround may incorrectly think rescaled images are mosaics!
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              lPhaseEncodingSteps := round(lFloat1);
              // xxxshowmessage(floattostr(lFloat1));
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              // 1362 some use this for gap size, others for sum of gap and slicethickness!
              // if (lfloat1 > Data.XYZmm[3]) or (Data.XYZmm[3]=1) then
              // Data.XYZmm[3] := lfloat1;
              // Data.spacing:=lfloat1;

            End;
          $90:
            info := 'Data collection diameter';
          $91:
            Begin
              info := 'Echo Train Length';
              t := _string;
            End;
          $93:
            Begin
              info := 'Percent Sampling';
              t := _string;
            End;
          $94:
            Begin
              info := 'Percent Phase Field View';
              t := _string;
            End;
          $95:
            Begin
              info := 'Pixel Bandwidth';
              t := _string;
            End;
          $1000:
            Begin
              t := _string;
              info := 'Device Serial Number';
            End;
          $1004:
            info := 'Plate ID';
          $1020:
            Begin
              info := 'Software Version';
              t := _string;
            End;
          $1030:
            Begin
              info := 'Protocol Name';
              t := _string;
            End;
          $1040:
            info := 'Contrast/Bolus Route';
          $1050:
            Begin
              t := _string;
              info := 'Spatial Resolution';
            End;
          $1060:
            info := 'Trigger Time';
          $1062:
            info := 'Nominal Interval';
          $1063:
            info := 'Frame Time';
          $1081:
            info := 'Low R-R Value';
          $1082:
            info := 'High R-R Value';
          $1083:
            info := 'Intervals Acquired';
          $1084:
            info := 'Intervals Rejected';
          $1088:
            Begin
              info := 'Heart Rate';
              t := _string;
            End;
          $1090:
            Begin
              info := 'Cardiac Number of Images';
              t := _string;
            End;
          $1094:
            Begin
              info := 'Trigger Window';
              t := _string;
            End;
          $1100:
            info := 'Reconstruction Diameter';
          $1110:
            info := 'Distance Source to Detector [mm]';
          $1111:
            info := 'Distance Source to Patient [mm]';
          $1120:
            info := 'Gantry/Detector Tilt';
          $1130:
            info := 'Table Height';
          $1140:
            info := 'Rotation Direction';
          $1147:
            info := 'Field of View Shape';
          $1149:
            Begin
              t := _string;
              info := 'Field of View Dimension[s]';
            End;
          $1150:
            Begin
              info := 'Exposure Time [ms]';
              t := _string;
            End;
          $1151:
            Begin
              info := 'X-ray Tube Current [mA]';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              data.mA := lFloat1;
            End;

          $1152:
            info := 'Acquisition Device Processing Description';
          $1155:
            info := 'Radiation Setting';
          $1160:
            info := 'Filter Type';
          $1164:
            info := 'Imager Pixel Spacing';
          $1166:
            info := 'Grid';
          $1170:
            info := 'Generator Power';
          $1180:
            info := 'Collimator/grid Name';
          $1190:
            Begin
              info := 'Focal Spot[s]';
              t := _string;
            End;
          $11A0:
            Begin
              info := 'Body Part Thickness';
              t := _string;
            End;
          $11A2:
            info := 'Compression Force';
          $1200:
            info := 'Date of Last Calibration';
          $1201:
            info := 'Time of Last Calibration';
          $1210:
            info := 'Convolution Kernel';
          $1250:
            Begin
              t := _string;
              info := 'Receiving Coil';
            End;
          $1251:
            Begin
              t := _string;
              info := 'Transmitting Coil';
            End;
          $1260:
            Begin
              t := _string;
              info := 'Plate Type';
            End;
          $1261:
            Begin
              t := _string;
              info := 'Phosphor Type';
            End;
          { } $1310:
            Begin
              info := 'Acquisition Matrix';
              If lOldSiemens_IncorrectMosaicMM Then
                tmpstr := readStr(FP, remaining, lrOK, lMatrixSz) // 1362
              Else
                tmpstr := readStr(FP, remaining, lrOK, lJunk); // 1362

              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
            End; { }
          $1312:
            Begin
              t := _string;
              info := 'Phase Encoding Direction';
            End;
          $1314:
            Begin
              t := _string;
              info := 'Flip Angle';
            End;
          $1315:
            Begin
              t := _string;
              info := 'Variable Flip Angle Flag';
            End;
          $1316:
            Begin
              t := _string;
              info := 'SAR';
            End;
          $1400:
            info := 'Acquisition Device Processing Description';
          $1401:
            Begin
              info := 'Acquisition Device Processing Code';
              t := _string;
            End;
          $1402:
            info := 'Cassette Orientation';
          $1403:
            info := 'Cassette Size';
          $1404:
            info := 'Exposures on Plate';
          $1405:
            Begin
              info := 'Relative X-Ray Exposure';
              t := _string;
            End;
          $1500:
            info := 'Positioner Motion';
          $1508:
            info := 'Positioner Type';
          $1510:
            Begin
              info := 'Positioner Primary Angle';
              t := _string;
            End;
          $1511:
            info := 'Positioner Secondary Angle';
          $5020:
            info := 'Processing Function';
          $5100:
            Begin
              t := _string;
              info := 'Patient Position';
            End;
          $5101:
            Begin
              info := 'View Position';
              t := _string;
            End;
          $6000:
            Begin
              info := 'Sensitivity';
              t := _string;
            End;
          $7004:
            info := 'Detector Type';
          $7005:
            Begin
              info := 'Detector Configuration';
              t := _string;
            End;
          $7006:
            info := 'Detector Description';
          $700A:
            info := 'Detector ID';
          $700C:
            info := 'Date of Last Detector Calibration';
          $700E:
            info := 'Date of Last Detector Calibration';
          $7048:
            info := 'Grid Period';
          $7050:
            info := 'Filter Material LT';
          $7060:
            info := 'Exposure Control Mode';
        End;
      $0019:
        Case element Of // 1362
          $1220:
            Begin
              info := 'Matrix';
              t := _string;
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              If lFloat2 > lFloat1 Then
                lFloat1 := lFloat2;
              lMatrixSz := round(lFloat1);
              // if >32767 then there will be wrap around if read as signed value!
              remaining := 0;
            End;
          $14D4:
            Begin
              info := 'Matrix';
              t := _string;
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              If lFloat2 > lFloat1 Then
                lFloat1 := lFloat2;
              lMatrixSz := round(lFloat1);
              // if >32767 then there will be wrap around if read as signed value!
              remaining := 0;
            End;
        End; // case element

      $0020:
        Case element Of
          $00:
            info := 'Relationship Group Length';
          $0D:
            info := 'Study Instance UID';
          $0E:
            info := 'Series Instance UID';
          $10:
            Begin
              info := 'Study ID';
              t := _string;
            End;
          $11:
            Begin
              info := 'Series Number';
              DICOMHeaderStringToInt(data.SeriesNum);
            End;
          $12: // begin info := 'Acquisition Number';  t := _string; end;
            Begin
              info := 'Acquisition Number';
              DICOMHeaderStringToInt(data.AcquNum);
            End;

          $13:
            Begin
              info := 'Image Number';
              DICOMHeaderStringToInt(data.ImageNum);
            End;
          $20:
            Begin
              info := 'Patient Orientation';
              t := _string;
            End;
          $30:
            info := 'Image Position';
          $32:
            info := 'Image Position Patient';
          $35:
            info := 'Image Orientation';
          $37:
            info := 'Image Orientation (Patient)';
          $50:
            info := 'Location';
          $52:
            info := 'Frame of Reference UID';
          $91:
            info := 'Echo Train Length';
          $70:
            info := 'Image Geometry Type';
          $60:
            info := 'Laterality';
          $1001:
            info := 'Acquisitions in Series';
          $1002:
            info := 'Images in Acquisition';
          $1020:
            info := 'Reference';
          $1040:
            Begin
              info := 'Position Reference';
              t := _string;
            End;
          $1041:
            Begin
              info := 'Slice Location';
              readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
              data.Location := lFloat1;
            End;
          $1070:
            Begin
              info := 'Other Study Numbers';
              t := _string;
            End;
          $3401:
            info := 'Modifying Device ID';
          $3402:
            info := 'Modified Image ID';
          $3403:
            info := 'Modified Image Date';
          $3404:
            info := 'Modifying Device Mfg.';
          $3405:
            info := 'Modified Image Time';
          $3406:
            info := 'Modified Image Desc.';
          $4000:
            info := 'Image Comments';
          $5000:
            info := 'Original Image ID';
          $5002:
            info := 'Original Image... Nomenclature';
        End;
      $0021:
        Case element Of

          $1341:
            Begin
              info := 'Siemens Mosaic Slice Count';
              DICOMHeaderStringToInt(data.SiemensSlices);
            End;
          $134F:
            Begin // 1366
              info := 'Siemens Order of Slices';
              t := _string;
              data.SiemensInterleaved := 0; // 0=no,1=yes,2=undefined
              // look for "INTERLEAVED"
              lStr := '';
              If dFilePos(FP) > (filesz - e_len) Then
                Goto 666;
              getmem(buff, e_len);
              dBlockRead(FP, buff { ^ } , e_len, N);
              For i := 0 To e_len - 1 Do
                If charinset(buff[i], ['?', 'A' .. 'Z', 'a' .. 'z']) Then
                  lStr := lStr + upcase(buff[i]);
              freemem(buff);
              If (lStr[1] = 'I') Then
                data.SiemensInterleaved := 1; // 0=no,1=yes,2=undefined
              e_len := 0;
            End;
        End;
      $0028:
        Begin
          Case element Of
            $00:
              info := 'Image Presentation Group Length';
            $02:
              Begin
                info := 'Samples Per Pixel';
                tmp := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                data.SamplesPerPixel := tmp;
                If e_len > 255 Then
                Begin
                  explicitVR := true;
                  // kludge: switch between implicit and explicitVR
                End;
                tmpstr := IntToStr(tmp);
                e_len := 0;
                remaining := 0;
              End;
            $04:
              Begin
                info := 'Photometric Interpretation';
                tmpstr := '';
                If dFilePos(FP) > (filesz - e_len) Then
                  Goto 666;
                getmem(buff, e_len);
                dBlockRead(FP, buff { ^ } , e_len, N);
                For i := 0 To e_len - 1 Do
                  If charinset(buff[i], [ { '+','-',' ', } '0' .. '9',
                    'a' .. 'z', 'A' .. 'Z']) Then
                    tmpstr := tmpstr + buff[i];
                freemem(buff);
                If tmpstr = 'MONOCHROME1' Then
                  data.monochrome := 1
                Else If tmpstr = 'MONOCHROME2' Then
                  data.monochrome := 2
                Else If (Length(tmpstr) > 0) And (tmpstr[1] = 'Y') Then
                  data.monochrome := 4
                Else
                  data.monochrome := 3;
                remaining := 0;
                e_len := 0; { use tempstr }

              End;
            $05:
              info := 'Image Dimensions (ret)';
            $06:
              Begin
                info := 'Planar Configuration';
                tmp := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                data.PlanarConfig := tmp;
                remaining := 0;
              End;

            $08:
              Begin
                // if lPapyrusnSlices < 1 then
                // showmessage(IntToStr(remaining));
                // if remaining = 2 then begin
                // tmp := read16(fp,lrOK);
                //
                // end else               xx
                DICOMHeaderStringToInt(data.XYZdim[3]);
                If data.XYZdim[3] < 1 Then
                  data.XYZdim[3] := 1;
                info := 'Number of Frames';
                // showmessage(IntToStr(Data.XYZdim[3]));
              End;
            $09:
              Begin
                info := 'Frame Increment Pointer';
                tmpstr := ReadStrHex(FP, remaining, lrOK);
                If Not lrOK Then
                  Goto 666;
                e_len := 0;
                remaining := 0;
              End;
            $10:
              Begin
                info := 'Rows';
                data.XYZdim[2] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZdim[2];
                remaining := 0;
              End;
            $11:
              Begin
                info := 'Columns';
                data.XYZdim[1] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZdim[1];
                remaining := 0;
              End;
            $30:
              Begin
                info := 'Pixel Spacing';
                readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
                If Not lrOK Then
                  Goto 666;
                // row spacing [y], then column spacing [x]: see part 3 of DICOM
                e_len := 0;
                remaining := 0;
                data.XYZmm[2] := lFloat1;
                data.XYZmm[1] := lFloat2;
              End;
            $31:
              info := 'Zoom Factor';
            $32:
              info := 'Zoom Center';
            $34:
              Begin
                info := 'Pixel Aspect Ratio';
                t := _string;
              End;
            $40:
              info := 'Image Format [ret]';
            $50:
              info := 'Manipulated Image [ret]';
            $51:
              info := 'Corrected Image';
            $60:
              Begin
                info := 'Compression Code [ret]';
                t := _string;
              End;
            $100:
              Begin
                info := 'Bits Allocated';
                // showmessage(IntToStr(Remaining));
                If remaining = 4 Then
                  tmp := read32(FP, lrOK)
                Else
                  tmp := read16(FP, lrOK);
                // lWord := read16(fp,lrOK);
                // lWord := read16(fp,lrOK);

                If Not lrOK Then
                  Goto 666;
                If tmp In [8, 12, 16, 32] Then
                  data.Allocbits_per_pixel := tmp
                Else If tmp = 24 Then
                Begin
                  data.SamplesPerPixel := 3;
                  data.Allocbits_per_pixel := 8
                End
                Else
                Begin
                  lWord := tmp;
                  lWord := system.swap(lWord);
                  If lWord In [8, 12, 16, 24, 32] Then
                  Begin
                    data.Allocbits_per_pixel := tmp;
                    lByteSwap := true;
                  End
                  Else
                  Begin
                    If lImageFormatOK Then
                      showmessage
                        ('This software only reads 8, 12, 16 and 32 bit DICOM files. This file allocates '
                        + IntToStr(tmp) + ' bits per voxel.');
                    lImageFormatOK := false; { }
                  End;
                End;
                // remaining := 2;//remaining; //1371->
                remaining := 0
              End;
            $0101:
              Begin
                info := 'Bits Stored';
                If remaining = 4 Then
                  tmp := read32(FP, lrOK)
                Else
                  tmp := read16(FP, lrOK);

                If Not lrOK Then
                  Goto 666;

                If tmp <= 8 Then
                  data.Storedbits_per_pixel := 8
                Else If tmp <= 16 Then
                  data.Storedbits_per_pixel := 16
                Else If tmp <= 32 Then
                  data.Storedbits_per_pixel := 32
                Else If tmp <= 24 Then
                Begin
                  data.Storedbits_per_pixel := 24;
                  data.SamplesPerPixel := 3;
                End
                Else
                Begin
                  lWord := tmp;
                  lWord := system.swap(lWord);
                  If lWord In [8, 12, 16, 32] Then
                  Begin
                    data.Storedbits_per_pixel := tmp;
                    lByteSwap := true;
                  End
                  Else
                  Begin
                    If lImageFormatOK Then
                      showmessage
                        ('This software can only read 8, 12, 16 and 32 bit DICOM files. This file stores '
                        + IntToStr(tmp) + ' bits per voxel.');
                    data.Storedbits_per_pixel := tmp;
                    lImageFormatOK := false; { }
                  End;
                End;
                remaining := 0;
              End;
            $0102:
              Begin
                info := 'High Bit';
                If remaining = 4 Then
                  tmp := read32(FP, lrOK)
                Else
                  tmp := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                (*
                  could be 11 for 12 bit cr images so just
                  skip checking it
                  assert(tmp == 7 || tmp == 15);
                *)
                remaining := 0;
              End;
            $0103:
              Begin
                info := 'Pixel Representation';
                // showmessage('asdf'+IntToStr(dFilePos(fp))+'/'+IntToStr(e_len));
              End;
            $0104:
              info := 'Smallest Valid Pixel Value';
            $0105:
              info := 'Largest Valid Pixel Value';
            $0106:
              Begin
                data.MinIntensitySet := true;
                info := 'Smallest Image Pixel Value';
                tmp := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                data.MinIntensity := tmp;
                // if >32767 then there will be wrap around if read as signed value!
                remaining := 0;
              End;
            $0107:
              Begin
                info := 'Largest Image Pixel Value';
                If remaining = 4 Then
                  tmp := read32(FP, lrOK)
                Else
                  tmp := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                data.MaxIntensity := tmp;
                // if >32767 then there will be wrap around if read as signed value!
                remaining := 0;
              End;
            $120:
              info := 'Pixel Padding Value';
            $200:
              info := 'Image Location [ret]';
            $1040:
              Begin
                t := _string;
                info := 'Pixel Intensity Relationship';
              End;
            $1050:
              Begin
                info := 'Window Center';
                If e_len > 0 Then
                Begin
                  readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
                  If Not lrOK Then
                    Goto 666;
                  e_len := 0;
                  remaining := 0;
                  data.WindowCenter := round(lFloat1);
                End;
              End; { float }
            $1051:
              Begin
                info := 'Window Width';
                If e_len > 0 Then
                Begin
                  readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
                  If Not lrOK Then
                    Goto 666;
                  e_len := 0;
                  remaining := 0;
                  data.WindowWidth := round(lFloat1);
                End; // ignore empty elements, e.g. LeadTech's image6.dic
              End;
            $1052:
              Begin
                t := _string;
                info := 'Rescale Intercept';
                readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
                If Not lrOK Then
                  Goto 666;
                e_len := 0;
                remaining := 0;
                data.IntenIntercept := lFloat1;
              End; { float }
            $1053:
              Begin
                t := _string;
                info := 'Rescale Slope';
                readfloats(FP, remaining, tmpstr, lFloat1, lFloat2, lrOK);
                If Not lrOK Then
                  Goto 666;
                e_len := 0;
                remaining := 0;
                If lFloat1 < 0.000000001 Then
                Begin
                  // showmessage('taco'+floattostr(lFloat1));
                  lFloat1 := 1; // misused in some images, see IMG000025
                End;
                data.IntenScale := lFloat1;
              End; { float }
            $1054:
              Begin
                t := _string;
                info := 'Rescale Type';
              End;
            $1100:
              info := 'Gray Lookup Table [ret]';
            $1101:
              Begin
                info := 'Red Palette Descriptor';
                tmpstr := readStr(FP, remaining, lrOK, lJunk);
                If Not lrOK Then
                  Goto 666;
                e_len := 0;
                remaining := 0;
              End;
            $1102:
              Begin
                info := 'Green Palette Descriptor';
                tmpstr := readStr(FP, remaining, lrOK, lJunk);
                If Not lrOK Then
                  Goto 666;
                e_len := 0;
                remaining := 0;
              End;
            $1103:
              Begin
                info := 'Blue Palette Descriptor';
                tmpstr := readStr(FP, remaining, lrOK, lJunk);
                If Not lrOK Then
                  Goto 666;
                e_len := 0;
                remaining := 0;
              End;
            $1199:
              Begin
                info := 'Palette Color Lookup Table UID';
              End;
            $1200:
              info := 'Gray Lookup Data [ret]';
            $1201, $1202, $1203:
              Begin
                Case element Of
                  $1201:
                    info := 'Red Table'; { future }
                  $1202:
                    info := 'Green Table'; { future }
                  $1203:
                    info := 'Blue Table'; { future }
                End;

                If dFilePos(FP) > (filesz - remaining) Then
                  Goto 666;
                If Not lReadColorTables Then
                Begin
                  dSeek(FP, dFilePos(FP) + remaining);
                End
                Else
                Begin { load color }
                  Width := remaining Div 2;

                  If Width > 0 Then
                  Begin
                    getmem(lWordRA, Width * 2);
                    For i := (Width) Downto 1 Do
                      lWordRA[i] := read16(FP, lrOK);
                    // value := 159;
                    value := lWordRA[1];
                    max16 := value;
                    min16 := value;
                    For i := (Width) Downto 1 Do
                    Begin
                      value := lWordRA[i];
                      If value < min16 Then
                        min16 := value;
                      If value > max16 Then
                        max16 := value;
                    End; // width..1
                    If max16 - min16 = 0 Then
                      max16 := min16 + 1; { avoid divide by 0 }
                    If (data.Allocbits_per_pixel <= 8) And (Width > 256) Then
                      Width := 256;
                    // currently only accepts palettes up to 8-bits
                    getmem(lColorRA, Width); (* *)
                    For i := Width Downto 1 Do
                      lColorRA[i] := (lWordRA[i] Shr 8) { and 255 };
                    freemem(lWordRA);
                    Case element Of
                      $1201:
                        Begin
                          red_table_size := Width;
                          red_table := lColorRA;;
                        End;
                      $1202:
                        Begin
                          green_table_size := Width;
                          green_table := lColorRA;;
                        End;
                    Else { x$1203: }
                      Begin
                        blue_table_size := Width;
                        blue_table := lColorRA;;
                      End; { else }
                    End; { case }
                  End; // width > 0;
                  If odd(remaining) Then
                    dSeek(FP, dFilePos(FP) + 1 { remaining } );
                End; { load color }
                tmpstr := 'Custom';
                remaining := 0;
                e_len := 0; { show tempstr }
              End;
            $1221, $1222, $1223:
              Begin
                info := 'Color Palette [' + IntToStr(dFilePos(FP)) + ']';
                Case element Of
                  $1221:
                    Begin
                      data.RLEredOffset := dFilePos(FP);
                      data.RLEredSz := e_len;
                    End;
                  $1222:
                    Begin
                      data.RLEgreenOffset := dFilePos(FP);
                      data.RLEgreenSz := e_len;
                    End;
                  $1223:
                    Begin
                      data.RLEblueOffset := dFilePos(FP);
                      data.RLEblueSz := e_len;
                    End;
                End; // Case set offset and length

                tmpstr := IntToStr(e_len);
                dSeek(FP, dFilePos(FP) + e_len);
                e_len := 0;
              End;

            $3002:
              info := 'LUT Descriptor';
            $3003:
              info := 'LUT Explanation';
            $3006:
              info := 'LUT Data';
            $3010:
              Begin
                info := 'VOI LUT Sequence';
                If (explicitVR) And (lT0 = kS) And (lT1 = kQ) Then
                  e_len := 8;
                // UPDATEx showmessage(IntToStr(dFilePos(fp))+';@'+IntToStr(e_len));
              End;
          End; // case
        End; // $0028

      (* /inicio Elementos introducidos para tratamiento de ROIs *)
      $0030:
        Begin
          Case element Of
            $00:
              info := 'ROI Data Group Length';
            $10:
              Begin
                info := 'Original Matrix Number of Frames';
                data.XYZori[3] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZori[3];
                remaining := 0;
              End;
            $11:
              Begin
                info := 'Original Matrix Columns';
                data.XYZori[2] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZori[2];
                remaining := 0;
              End;
            $12:
              Begin
                info := 'Original Matrix Rows';
                data.XYZori[1] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZori[1];
                remaining := 0;
              End;
            $20:
              Begin
                info := 'Relative position to Original Z';
                data.XYZstart[3] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZstart[3];
                remaining := 0;
              End;
            $21:
              Begin
                info := 'Relative position to Original Y';
                data.XYZstart[2] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZstart[2];
                remaining := 0;
              End;
            $22:
              Begin
                info := 'Relative position to Original X';
                data.XYZstart[1] := read16(FP, lrOK);
                If Not lrOK Then
                  Goto 666;
                tmp := data.XYZstart[1];
                remaining := 0;
              End;
          End;
        End;
      (* /fin Elementos introducidos para tratamiento de ROIs *)
      $41:
        Case element Of // Papyrus Private Group
          $1010:
            Begin
              info := 'Papyrus Icon [bytes skipped]';
              dSeek(FP, dFilePos(FP) + e_len);
              tmpstr := IntToStr(e_len);
              remaining := 0;
              e_len := 0;
            End; // element $0041:$1010
          $1015:
            Begin

              info := 'Papyrus Slices';
              (* Papyrus format is buggy - see lsjpeg.pas for details, therefore, I have removed extensive support
                if e_len = 2 then begin
                Data.XYZdim[3]   := read16(fp,lrOK);
                if not lrOK then goto 666;
                end;
                if Data.XYZdim[3] < 1 then Data.XYZdim[3] := 1;
                if {(false) and }(Data.XYZdim[3] > 1) and (lReadJPEGtables) and (gECATJPEG_table_entries = 0) then begin
                //Papyrus multislice files keep separate DICOM headers for each slice within a DICOM file
                lPapyrusnSlices := Data.XYZdim[3];
                lPapyrusSlice := 0;
                //lPapyrusData := Data;
                gECATJPEG_table_entries := Data.XYZDim[3];
                getmem (gECATJPEG_pos_table, gECATJPEG_table_entries*sizeof(longint));
                getmem (gECATJPEG_size_table, gECATJPEG_table_entries*sizeof(longint));
                end else
                Data.XYZdim[3] := 1;
                tmpstr := IntToStr(Data.XYZdim[3]);
                remaining := 0;
                e_len := 0; *)
            End; // element $0041:$1015
          $1050:
            Begin
              info := 'Papyrus Bizarre Element'; // bizarre osiris problem
              If (dFilePos(FP) + e_len) = (filesz) Then
                e_len := 8;
            End; // element $0041:$1050
        End; // group $0041: Papyrus
      $54:
        Case element Of
          $0:
            info := 'Nuclear Acquisition Group Length';
          $11:
            info := 'Number of Energy Windows';
          $21:
            info := 'Number of Detectors';
          $51:
            info := 'Number of Rotations';
          $80:
            Begin
              info := 'Slice Vector';
              tmpstr := readStr(FP, remaining, lrOK, lJunk);
              If Not lrOK Then
                Goto 666;
              e_len := 0;
              remaining := 0;
            End;
          $81:
            info := 'Number of Slices';
          $202:
            info := 'Type of Detector Motion';
          $400:
            info := 'Image ID';

        End;
      $2010:
        Case element Of
          $0:
            info := 'Film Box Group Length';
          $100:
            info := 'Border Density';
        End;
      $4000:
        info := 'Text';
      $0029:
        Begin
          Case element Of
            $1010:
              Begin
                // lSiemensMosaic0029_1010:= true;
                info := 'Private Sequence Delimiter [' +
                  IntToStr(dFilePos(FP)) + ']';
                If (data.runlengthencoding) Or
                  (((data.JPEGlossycpt) Or (data.JPEGlosslesscpt)) And
                  (gECATJPEG_table_entries >= data.XYZdim[3])) Then
                  time_to_quit := true;
                dSeek(FP, dFilePos(FP) + e_len);
                tmpstr := IntToStr(e_len);
                remaining := 0;
                e_len := 0; { show tempstr }
              End;

          Else
            Begin
            End;
          END;
        END; // gROUP 0029

      $0089:
        Begin
          Case element Of
            $1010:
              Begin
                // showmessage('22asdf'+IntToStr(e_len));
                e_len := 0;
                lProprietaryImageThumbnail := true;
                // lImageFormatOK := false;
              End; // element $1010
            $1020:
              Begin
                // showmessage('22asdf'+IntToStr(e_len));
                // thoravision files

                If e_len > 12 Then
                  e_len := 0;
                // lProprietaryImageThumbnail := true;
                // lImageFormatOK := false;
              End; // element $1010

          End; // CASE...element
        End; // group 0089

      $DDFF:
        Begin
          Case element Of
            $00E0:
              Begin
                // For papyrus multislice format: if (lPapyrusSlice >=  lPapyrusnSlices) then
                time_to_quit := true;
              End;
          End;
        End;
      (* Used by Papyrus, however Papyrus compression is incompatible withDICOM, see lsjpeg.pas
        $FE00 : begin
        case element of
        $00FF : begin
        //if (lPapyrusnSlices > 1) and (lPapyrusSlice <  lPapyrusnSlices) then begin
        //e_len := 2;

        //showmessage(IntToStr(e_len));
        //e_len := 0;
        end; //element 00FF
        end; //case of elenment
        end; //GROUP FE00 *)
      $FFFE:
        Begin
          Case element Of
            $E000:
              Begin
                If lJPEGentries > 17 Then
                  lTestError := true;

                // if lJPEGEntries > 18 then
                // showmessage('abba'+IntToStr(lJPEGEntries)+'xxx'+IntToStr(dFilePos(fp))+' '+IntToStr(e_len)+' FileSz'+IntToStr(FileSz));

                If Not lProprietaryImageThumbnail Then
                Begin
                  If (lReadJPEGtables) And
                    ((data.runlengthencoding) Or (data.JPEGlossycpt) Or
                    (data.JPEGlosslesscpt)) And (Not lFirstFragment) And
                    (e_len > 1024) { 1384 } And
                    ((e_len + dFilePos(FP)) <= filesz) Then
                  Begin
                    // showmessage('abba'+IntToStr(lJPEGEntries)+'xxx'+IntToStr(dFilePos(fp)));
                    // first fragment is the index table, so the previous line skips the first fragment
                    If (gECATJPEG_table_entries = 0) Then
                    Begin
                      gECATJPEG_table_entries := data.XYZdim[3];
                      getmem(gECATJPEG_pos_table, gECATJPEG_table_entries *
                        SizeOf(LongInt));
                      getmem(gECATJPEG_size_table, gECATJPEG_table_entries *
                        SizeOf(LongInt));
                    End;
                    If lJPEGentries < gECATJPEG_table_entries Then
                    Begin
                      inc(lJPEGentries);
                      // showmessage('abba'+IntToStr(lJPEGEntries)+'xxx'+IntToStr(dFilePos(fp)));
                      gECATJPEG_pos_table[lJPEGentries] := dFilePos(FP);
                      gECATJPEG_size_table[lJPEGentries] := e_len;
                    End;
                  End;

                  If (data.CompressOffset = 0) And
                    ((e_len + dFilePos(FP)) <= filesz) And (e_len > 1024)
                  { ALOKA } Then
                  Begin
                    data.CompressOffset := dFilePos(FP);
                    data.CompressSz := e_len;
                  End;
                  // if e_len > Data.CompressSz then Data.CompressSz := e_len;
                  // showmessage(InttoStr(e_len));
                  If (e_len > 1024) And (data.CompressSz = 0) Then
                  Begin // ABBA RLE ALOKA
                    // Time_To_Quit := true;//ABBA
                    data.CompressSz := e_len;
                    data.CompressOffset := dFilePos(FP);
                  End;
                  If (lFirstFragment) Or
                    ((e_len > data.CompressSz) And
                    Not(data.runlengthencoding)) Then
                    data.CompressOffset := dFilePos(FP);
                  If (e_len > data.CompressSz) And (e_len > 1024)
                  { ALOKA } Then
                    data.CompressSz := e_len;
                  lFirstFragment := false;
                  DataBackUp := data;

                  If (gECATJPEG_table_entries = 1) Then
                  Begin // updatex
                    gECATJPEG_size_table[1] := data.CompressSz;
                    gECATJPEG_pos_table[1] := data.CompressOffset;
                  End; // updatex

                End; // not proprietaryThumbnail
                lProprietaryImageThumbnail := false; // 1496
                info := 'Image Fragment [' + IntToStr(dFilePos(FP)) + ']';
                If (dFilePos(FP) + e_len) >= filesz Then
                  time_to_quit := true;
                dSeek(FP, dFilePos(FP) + e_len);
                tmpstr := IntToStr(e_len);
                remaining := 0;
                e_len := 0;
              End;
            $E00D:
              info := 'Item Delimitation Item';
            $E0DD:
              Begin
                info := 'Sequence Delimiter';
                { support for buggy papyrus format removed
                  if (lPapyrusnSlices > 1) then
                  else }
                If (data.XYZdim[1] < DataBackUp.XYZdim[1]) Then
                Begin
                  data := DataBackUp;
                  dSeek(FP, dFilePos(FP) + e_len);
                  // Data := DataBackUp;
                End
                Else If (data.runlengthencoding) Or
                  (((data.JPEGlossycpt) Or (data.JPEGlosslesscpt)) And
                  (gECATJPEG_table_entries >= data.XYZdim[3])) Then
                  time_to_quit := true;
                // RLE ABBA
                If (e_len = 0) And (data.CompressSz = 0) And
                  (data.runlengthencoding) Then
                Begin // ALOKA
                  explicitVR := true;
                  time_to_quit := false; // RLE16=false
                End;
                // END   {}

                dSeek(FP, dFilePos(FP) + e_len);
                tmpstr := IntToStr(e_len);
                remaining := 0;
                e_len := 0; { show tempstr }
              End;
          End;
        End;
      $FFFC:
        Begin
          dSeek(FP, dFilePos(FP) + e_len);
          tmpstr := IntToStr(e_len);
          remaining := 0;
          e_len := 0; { show tempstr }
        End;

      $7FE0:
        Case element Of
          $00:
            Begin
              info := 'Pixel Data Group Length';
              If Not lImageFormatOK Then
                time_to_quit := true;
            End;
          $10:
            Begin
              info := 'Pixel Data';
              tmpstr := IntToStr(e_len);

              { support for buggy papyrus removed
                if (not Data.JPEGLosslesscpt) and (lPapyrusnSlices > 1) and (lPapyrusSlice <  lPapyrusnSlices) then begin
                inc(lPapyrusSlice);
                if (lJPEGentries < gECATJPEG_table_entries) then begin
                inc(lJPEGentries);
                gECATJPEG_pos_table[lJPEGEntries] := dFilePos(fp);
                gECATJPEG_size_table[lJPEGEntries] := e_len;
                end;
                if lPapyrusSlice = lPapyrusnSlices then begin
                time_to_quit := TRUE;
                end;
                dSeek(fp, dFilePos(fp) + e_len);
                end else }
              If (data.XYZdim[1] < DataBackUp.XYZdim[1]) Then
              Begin
                data := DataBackUp;
                dSeek(FP, dFilePos(FP) + e_len);
                // Data := DataBackUp;
              End
              Else If (Not data.runlengthencoding) And (Not data.JPEGlossycpt)
                And (Not data.JPEGlosslesscpt) Then
              Begin
                time_to_quit := true;
                data.ImageSz := e_len;

              End;
              e_len := 0;

            End;
        End;
    Else
      Begin
        If (group >= $6000) AND (group <= $601E) AND ((group AND 1) = 0) Then
        Begin
          info := 'Overlay' + IntToStr(dFilePos(FP)) + 'x' + IntToStr(e_len);
        End;
        If element = $0000 Then
          info := 'Group Length';
        If element = $4000 Then
          info := 'Comments';
      End;
    End;
    lStr := '';

    If (time_to_quit) And (Not lImageFormatOK) Then
    Begin
      lHdrOk := true;
      { header was OK }
      Goto 666;
    End;

    If (e_len + dFilePos(FP)) > filesz Then
    Begin
      // patch for GE files that only fill top 16-bytes w Random data
      e_len := e_len And $FFFF;
    End;
    If (e_len > { x$FFFF } 131072) { and (dfilepos(fp) > FileSz) }
    Then
    Begin
      // showmessage('Very large DICOM header: is this really a DICOM file? '+InttoStr(dfilepos(fp)));
      // showmessage('@');
      // goto 666;
    End; // zebra
    If (NOT time_to_quit) AND (e_len > 0) And (remaining > 0) Then
    Begin
      If (e_len + dFilePos(FP)) > filesz Then
      Begin
        If (data.GenesisCpt) Or (data.JPEGlosslesscpt) Or
          (data.JPEGlossycpt) Then
          lHdrOk := true
        Else
          showmessage('Error: Dicom header exceeds file size.' + kCR +
            lFileName);
        Goto 666;
      End;
      { if (t = _float) and (lVerboseRead) then  begin  //aqw
        readfloats (fp, remaining, TmpStr, lfloat1, lfloat2, lROK);
        lStr := TmpStr;
        //lStr :=floattostrf(lfloat1,ffFixed,7,7);
        e_len := 0;
        end;{ }
      If e_len > 0 Then
      Begin
        getmem(buff, e_len);
        dBlockRead(FP, buff { ^ } , e_len, N);
        If lVerboseRead Then
          Case t Of
            unknown:
              Case e_len Of
                1:
                  lStr := (IntToStr(integer(buff[0])));
                2:
                  Begin
                    If data.little_endian <> 0 Then
                      i := integer(buff[0]) + 256 * integer(buff[1])
                    Else
                      i := integer(buff[0]) * 256 + integer(buff[1]);
                    lStr := (IntToStr(i));
                  End;
                4:
                  Begin
                    If data.little_endian <> 0 Then
                      i := integer(buff[0]) + 256 * integer(buff[1]) + 256 * 256
                        * integer(buff[2]) + 256 * 256 * 256 * integer(buff[3])
                    Else
                      i := integer(buff[0]) * 256 * 256 * 256 + integer(buff[1])
                        * 256 * 256 + integer(buff[2]) * 256 + integer(buff[3]);
                    lStr := (IntToStr(i));
                  End;
              Else
                Begin
                  If e_len > 0 Then
                  Begin
                    For i := 0 To e_len - 1 Do
                    Begin
                      If charinset(Char(buff[i]), ['+', '-', '/', '\', ' ',
                        '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
                        lStr := lStr + (Char(buff[i]))
                      Else
                        lStr := lStr + ('.');
                    End; { for i..e_len }
                  End
                  Else
                    lStr := '*NO DATA*';
                End;
              End;

            i8, i16, i32, ui8, ui16, ui32, _string:
              For i := 0 To e_len - 1 Do
                If charinset(Char(buff[i]), ['+', '-', '/', '\', ' ',
                  '0' .. '9', 'a' .. 'z', 'A' .. 'Z']) Then
                  lStr := lStr + (Char(buff[i]))
                Else
                  lStr := lStr + ('.');
          End;
        freemem(buff);

      End; { e_len > 0... get mem }
    End
    Else If e_len > 0 Then
      lStr := (IntToStr(tmp))
    Else { if e_len = 0 then }
    Begin
      // TmpStr := '?';

      lStr := tmpstr;
    End;
    { add this to show length size -> }// lStr := lStr +'/'+InttoStr(e_len);
    If (lGrp { info = 'identifying group'{ } ) Then
      If MessageDlg(lStr + '= ' + info + ' ' + inttohex(where, 4) + ': (' +
        inttohex(group, 4) + ',' + inttohex(element, 4) + ')' + IntToStr(e_len)
        + '. Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrNo Then
        GOTO 666;
    // if info = 'UNKNOWN' then showmessage(IntToHex(group,4)+','+IntToHex(element,4));

    If lVerboseRead Then
    Begin
      If Length(lDynStr) > kMaxTextBuf Then
      Begin
        If Not lTextOverFlow Then
        Begin
          lDynStr := lDynStr + 'Only showing the first ' + IntToStr(kMaxTextBuf)
            + ' characters of this LARGE header';
          lTextOverFlow := true;
        End;
        // showmessage('Unable to display the entire header.');
        // goto 666;
      End
      Else
        lDynStr :=
          lDynStr { +chr(lT0)+chr(lT1)+' '{+InttoStr(dfilepos(fp))+'abba'{ } +
          inttohex(group, 4) + ',' + inttohex(element, 4) +
          ',' { +IntToStr(where)+': '+lGrpStr } + info + '=' + lStr + kCR;
    End; // not verbose read
  End; // end for                             x
  data.ImageStart := dFilePos(FP);

  If lBigSet Then
  Begin
    If lBig Then
      data.little_endian := 0
    Else
      data.little_endian := 1;
  End;
  lHdrOk := true;
  If lByteSwap Then
  Begin
    ByteSwap(data.XYZdim[1]);
    ByteSwap(data.XYZdim[2]);
    If data.XYZdim[3] <> 1 Then
      ByteSwap(data.XYZdim[3]);
    ByteSwap(data.SamplesPerPixel);
    ByteSwap(data.Allocbits_per_pixel);
    ByteSwap(data.Storedbits_per_pixel);
  End;

  If (lMatrixSz > 1) And ((data.XYZdim[1] Mod lMatrixSz) = 0) And
    ((data.XYZdim[2] Mod lMatrixSz) = 0) Then
  Begin
    // showmessage('abba'+InttoStr(lMatrixSz));
    // showmessage('x');

    If ((data.XYZdim[1] Mod lMatrixSz) = 0) Then
      data.SiemensMosaicX := data.XYZdim[1] Div lMatrixSz;
    If ((data.XYZdim[2] Mod lMatrixSz) = 0) Then
      data.SiemensMosaicY := data.XYZdim[2] Div lMatrixSz;
    If data.SiemensMosaicX < 1 Then
      data.SiemensMosaicX := 1; // 1366
    If data.SiemensMosaicY < 1 Then
      data.SiemensMosaicY := 1; // 1366
    // showmessage('OLD abba'+ InttoStr(Data.SiemensMosaicY));

    If { not } lOldSiemens_IncorrectMosaicMM Then
    Begin
      // old formats convert size in mm incorrectly - modern versions are correct and include transfer syntax
      // showmessage('abba'+InttoStr(lMatrixSz));
      data.XYZmm[1] := data.XYZmm[1] * (data.XYZdim[1] Div lMatrixSz);
      data.XYZmm[2] := data.XYZmm[2] * (data.XYZdim[2] Div lMatrixSz);
    End;
  End
  Else If (lSiemensMosaic0008_0008) And (lPhaseEncodingSteps > 0) And
    (lPhaseEncodingSteps < data.XYZdim[2]) And
    ((data.XYZdim[2] Mod lPhaseEncodingSteps) = 0) And
    ((data.XYZdim[2] Mod (data.XYZdim[2] Div lPhaseEncodingSteps)) = 0) Then
  Begin
    // 1499c kludge for detecting new Siemens mosaics: WARNING may cause false positives - Siemens fault not mine!
    data.SiemensMosaicY := data.XYZdim[2] Div lPhaseEncodingSteps;
    data.SiemensMosaicX := data.SiemensMosaicY;
    // We also need to assume as many mosaic rows as columns, as Siemens does not save the phase encoding lines in the header...
  End;
  // showmessage(floattostr(Data.IntenScale));
  data.XYZmm[1] := abs(data.XYZmm[1]);
  data.XYZmm[2] := abs(data.XYZmm[2]);
  data.XYZmm[3] := abs(data.XYZmm[3]);
  If data.IntenScale = 0 Then
    data.IntenScale := 1;
666:
  If lDiskCacheSz > 0 Then
    freemem(lDiskCacheRA);
  If Not lHdrOk Then
    lImageFormatOK := false
  Else If (data.XYZori[1] * data.XYZori[2] * data.XYZori[3] <= 1) Then
  Begin
    data.XYZori[1] := data.XYZdim[1];
    data.XYZori[2] := data.XYZdim[2];
    data.XYZori[3] := data.XYZdim[3];
  End;

  closefile(FP);
  FileMode := 2; // set to read/write
End;

Function TDICOM.Read_Image: TMatrix;
{ type
  swaptypes = packed record
  case byte of
  0:
  (Word1, Word2: word); // word is 16 bit
  1:
  (sing: single);
  end;

  swaptyped = packed record
  case byte of
  0:
  (Word1, Word2, Word3, Word4: word); // word is 16 bit
  1:
  (doub: double);
  end; }
Var
  FP: File;
  buff: PAnsiChar;
  i, j, lInc, N: integer;
  tempsingle: single;
  OverlaySingle: Array [1 .. 2] Of word Absolute tempsingle;
  tempdouble: double;
  OverlayDouble: Array [1 .. 4] Of word Absolute tempdouble;
  TempExtended: extended;
  OverlayExtended: Array [1 .. 5] Of word Absolute TempExtended;
  tSMI: SmallInt;
  tword: word;
  tinteger: integer;
  tcardinal: cardinal;
Begin
  If lImageFormatOK And (data.XYZdim[3] = 1) Then
  Begin // Devolver la matriz Aquí
    DimMatrix(result, data.XYZdim[1], data.XYZdim[2]);
    assignfile(FP, lFileName);
    FileMode := 0;
    Reset(FP, 1);
    seek(FP, data.ImageStart);
    getmem(buff, data.ImageSz);
    BlockRead(FP, buff^, data.ImageSz, N);
    lInc := 0;
    Case data.Storedbits_per_pixel Of
      8:
        Begin
          For j := 1 To data.XYZdim[2] Do
            For i := 1 To data.XYZdim[1] Do
            Begin
              result[i, j] := word(buff[lInc]) And $FF;
              result[i, j] := data.IntenIntercept + data.IntenScale *
                result[i, j];
            End;
        End;
      16:
        Begin
          If data.signed Then
          Begin
            For j := 1 To data.XYZdim[2] Do
              For i := 1 To data.XYZdim[1] Do
              Begin
                tSMI := (SmallInt(buff[lInc]) And $FF) Or
                  ((SmallInt(buff[lInc + 1]) And $FF) Shl 8);
                If data.little_endian = 0 Then
                  swap2(tSMI);
                lInc := lInc + 2;
                result[i, j] := data.IntenIntercept + data.IntenScale * tSMI;
              End;
          End
          Else
          Begin
            For j := 1 To data.XYZdim[2] Do
              For i := 1 To data.XYZdim[1] Do
              Begin
                tword := (word(buff[lInc]) And $FF) Or
                  ((word(buff[lInc + 1]) And $FF) Shl 8);
                If data.little_endian = 0 Then
                  swap2u(tword);
                lInc := lInc + 2;
                result[i, j] := data.IntenIntercept + data.IntenScale * tword;
              End;
          End;
        End;
      32:
        Begin
          If Not data.float Then
          Begin
            If data.signed Then
            Begin
              For j := 1 To data.XYZdim[2] Do
                For i := 1 To data.XYZdim[1] Do
                Begin
                  tinteger := ((integer(buff[lInc + 3]) And $FF) Shl 24) Or
                    ((integer(buff[lInc + 2]) And $FF) Shl 16) Or
                    ((integer(buff[lInc + 1]) And $FF) Shl 8) Or
                    (integer(buff[lInc]) And $FF);
                  If data.little_endian = 0 Then
                    swap4(tinteger);
                  lInc := lInc + 4;
                  result[i, j] := data.IntenIntercept + data.IntenScale
                    * tinteger;
                End;
            End
            Else
            Begin
              For j := 1 To data.XYZdim[2] Do
                For i := 1 To data.XYZdim[1] Do
                Begin
                  tcardinal := ((LongWord(buff[lInc + 3]) And $FF) Shl 24) Or
                    ((LongWord(buff[lInc + 2]) And $FF) Shl 16) Or
                    ((LongWord(buff[lInc + 1]) And $FF) Shl 8) Or
                    (LongWord(buff[lInc]) And $FF);
                  If data.little_endian = 0 Then
                    swap4u(tcardinal);
                  lInc := lInc + 4;
                  result[i, j] := data.IntenIntercept + data.IntenScale *
                    tcardinal;
                End;
            End;
          End
          Else
          Begin
            For j := 1 To data.XYZdim[2] Do
              For i := 1 To data.XYZdim[1] Do
              Begin
                OverlaySingle[1] := ((integer(buff[lInc + 3]) And $FF) Shl 8) Or
                  (integer(buff[lInc + 2]) And $FF);
                OverlaySingle[2] := ((integer(buff[lInc + 1]) And $FF) Shl 8) Or
                  (integer(buff[lInc]) And $FF);
                If data.little_endian = 0 Then
                  result[i, j] := data.IntenIntercept + data.IntenScale *
                    fswap4r(tempsingle)
                Else
                  result[i, j] := data.IntenIntercept + data.IntenScale *
                    tempsingle;
                lInc := lInc + 4;
              End;
          End;
        End;
      64:
        Begin
          For j := 1 To data.XYZdim[2] Do
            For i := 1 To data.XYZdim[1] Do
            Begin
              OverlayDouble[1] := ((integer(buff[lInc + 7]) And $FF) Shl 8) Or
                (integer(buff[lInc + 6]) And $FF);
              OverlayDouble[2] := ((integer(buff[lInc + 5]) And $FF) Shl 8) Or
                (integer(buff[lInc + 4]) And $FF);
              OverlayDouble[3] := ((integer(buff[lInc + 3]) And $FF) Shl 8) Or
                (integer(buff[lInc + 2]) And $FF);
              OverlayDouble[4] := ((integer(buff[lInc + 1]) And $FF) Shl 8) Or
                (integer(buff[lInc]) And $FF);
              If data.little_endian = 0 Then
                result[i, j] := data.IntenIntercept + data.IntenScale *
                  fswap8r(tempdouble)
              Else
                result[i, j] := data.IntenIntercept + data.IntenScale *
                  tempdouble;
              lInc := lInc + 8;
            End;
        End;
      80:
        Begin
          For j := 1 To data.XYZdim[2] Do
            For i := 1 To data.XYZdim[1] Do
            Begin
              OverlayExtended[1] := ((integer(buff[lInc + 9]) And $FF) Shl 8) Or
                (integer(buff[lInc + 8]) And $FF);
              OverlayExtended[2] := ((integer(buff[lInc + 7]) And $FF) Shl 8) Or
                (integer(buff[lInc + 6]) And $FF);
              OverlayExtended[3] := ((integer(buff[lInc + 5]) And $FF) Shl 8) Or
                (integer(buff[lInc + 4]) And $FF);
              OverlayExtended[4] := ((integer(buff[lInc + 3]) And $FF) Shl 8) Or
                (integer(buff[lInc + 2]) And $FF);
              OverlayExtended[5] := ((integer(buff[lInc + 1]) And $FF) Shl 8) Or
                (integer(buff[lInc]) And $FF);
              If data.little_endian = 0 Then
                result[i, j] := data.IntenIntercept + data.IntenScale *
                  fswap10r(TempExtended)
              Else
                result[i, j] := data.IntenIntercept + data.IntenScale *
                  TempExtended;
              lInc := lInc + 8;
            End;
        End;
    End;
    freemem(buff);
  End
  Else
  Begin
    result := Nil;
    lImageFormatOK := false;
  End;
End;

Function TDICOM.Read_Image3D: T3DMatrix;
{ type
  swaptypes = record
  case byte of
  0:
  (Word1, Word2: word); // word is 16 bit
  1:
  (sing: single);
  end;

  swaptyped = record
  case byte of
  0:
  (Word1, Word2, Word3, Word4: word); // word is 16 bit
  1:
  (doub: double);
  end; }
Var
  FP: File;
  buff: PAnsiChar;
  i, j, k, lInc, N: integer;
  tempsingle: single;
  OverlaySingle: Array [1 .. 2] Of word Absolute tempsingle;
  tempdouble: double;
  OverlayDouble: Array [1 .. 4] Of word Absolute tempdouble;
  TempExtended: extended;
  OverlayExtended: Array [1 .. 5] Of word Absolute TempExtended;
  tSMI: SmallInt;
  tword: word;
  tinteger: integer;
  tcardinal: cardinal;
Begin
  If lImageFormatOK And (data.XYZdim[3] > 1) Then
  Begin // Devolver la matriz Aquí
    DimMatrix(result, data.XYZdim[1], data.XYZdim[2], data.XYZdim[3]);
    assignfile(FP, lFileName);
    Reset(FP, 1);
    seek(FP, data.ImageStart);
    getmem(buff, data.ImageSz);
    BlockRead(FP, buff^, data.ImageSz, N);
    lInc := 0;
    Case data.Storedbits_per_pixel Of
      8:
        Begin
          For k := 1 To data.XYZdim[3] Do
            For j := 1 To data.XYZdim[2] Do
              For i := 1 To data.XYZdim[1] Do
              Begin
                result[i, j, k] := word(buff[lInc]) And $FF;
                result[i, j, k] := data.IntenIntercept + data.IntenScale *
                  result[i, j, k];
              End;
        End;
      16:
        Begin
          If data.signed Then
          Begin
            For k := 1 To data.XYZdim[3] Do
              For j := 1 To data.XYZdim[2] Do
                For i := 1 To data.XYZdim[1] Do
                Begin
                  tSMI := (SmallInt(buff[lInc]) And $FF) Or
                    ((SmallInt(buff[lInc + 1]) And $FF) Shl 8);
                  lInc := lInc + 2;
                  If data.little_endian = 0 Then
                    swap2(tSMI);
                  result[i, j, k] := data.IntenIntercept +
                    data.IntenScale * tSMI;
                End;
          End
          Else
          Begin
            For k := 1 To data.XYZdim[3] Do
              For j := 1 To data.XYZdim[2] Do
                For i := 1 To data.XYZdim[1] Do
                Begin
                  tword := (word(buff[lInc]) And $FF) Or
                    ((word(buff[lInc + 1]) And $FF) Shl 8);
                  lInc := lInc + 2;
                  If data.little_endian = 0 Then
                    swap2u(tword);
                  result[i, j, k] := data.IntenIntercept +
                    data.IntenScale * tword;
                End;
          End;
        End;
      32:
        Begin
          If Not data.float Then
          Begin
            If data.signed Then
            Begin
              For k := 1 To data.XYZdim[3] Do
                For j := 1 To data.XYZdim[2] Do
                  For i := 1 To data.XYZdim[1] Do
                  Begin
                    tinteger := ((integer(buff[lInc + 3]) And $FF) Shl 24) Or
                      ((integer(buff[lInc + 2]) And $FF) Shl 16) Or
                      ((integer(buff[lInc + 1]) And $FF) Shl 8) Or
                      (integer(buff[lInc]) And $FF);
                    lInc := lInc + 4;
                    If data.little_endian = 0 Then
                      swap4(tinteger);
                    result[i, j, k] := data.IntenIntercept + data.IntenScale
                      * tinteger;
                  End;
            End
            Else
            Begin
              For k := 1 To data.XYZdim[3] Do
                For j := 1 To data.XYZdim[2] Do
                  For i := 1 To data.XYZdim[1] Do
                  Begin
                    tcardinal := ((LongWord(buff[lInc + 3]) And $FF) Shl 24) Or
                      ((LongWord(buff[lInc + 2]) And $FF) Shl 16) Or
                      ((LongWord(buff[lInc + 1]) And $FF) Shl 8) Or
                      (LongWord(buff[lInc]) And $FF);
                    lInc := lInc + 4;
                    If data.little_endian = 0 Then
                      swap4u(tcardinal);
                    result[i, j, k] := data.IntenIntercept + data.IntenScale *
                      tcardinal;
                  End;
            End;
          End
          Else
          Begin
            For k := 1 To data.XYZdim[3] Do
              For j := 1 To data.XYZdim[2] Do
                For i := 1 To data.XYZdim[1] Do
                Begin
                  OverlaySingle[1] := ((integer(buff[lInc + 3]) And $FF) Shl 8)
                    Or (integer(buff[lInc + 2]) And $FF);
                  OverlaySingle[2] := ((integer(buff[lInc + 1]) And $FF) Shl 8)
                    Or (integer(buff[lInc]) And $FF);
                  If data.little_endian = 0 Then
                    result[i, j, k] := data.IntenIntercept + data.IntenScale *
                      fswap4r(tempsingle)
                  Else
                    result[i, j, k] := data.IntenIntercept + data.IntenScale *
                      tempsingle;
                  lInc := lInc + 4;
                End;
          End;
        End;
      64:
        Begin
          For k := 1 To data.XYZdim[3] Do
            For j := 1 To data.XYZdim[2] Do
              For i := 1 To data.XYZdim[1] Do
              Begin
                OverlayDouble[1] := ((integer(buff[lInc + 7]) And $FF) Shl 8) Or
                  (integer(buff[lInc + 6]) And $FF);
                OverlayDouble[2] := ((integer(buff[lInc + 5]) And $FF) Shl 8) Or
                  (integer(buff[lInc + 4]) And $FF);
                OverlayDouble[3] := ((integer(buff[lInc + 3]) And $FF) Shl 8) Or
                  (integer(buff[lInc + 2]) And $FF);
                OverlayDouble[4] := ((integer(buff[lInc + 1]) And $FF) Shl 8) Or
                  (integer(buff[lInc]) And $FF);
                If data.little_endian = 0 Then
                  result[i, j, k] := data.IntenIntercept + data.IntenScale *
                    fswap8r(tempdouble)
                Else
                  result[i, j, k] := data.IntenIntercept + data.IntenScale *
                    tempdouble;
                lInc := lInc + 4;
              End;
        End;
      80:
        Begin
          For k := 1 To data.XYZdim[3] Do
            For j := 1 To data.XYZdim[2] Do
              For i := 1 To data.XYZdim[1] Do
              Begin
                OverlayExtended[1] := ((integer(buff[lInc + 9]) And $FF) Shl 8)
                  Or (integer(buff[lInc + 8]) And $FF);
                OverlayExtended[2] := ((integer(buff[lInc + 7]) And $FF) Shl 8)
                  Or (integer(buff[lInc + 6]) And $FF);
                OverlayExtended[3] := ((integer(buff[lInc + 5]) And $FF) Shl 8)
                  Or (integer(buff[lInc + 4]) And $FF);
                OverlayExtended[4] := ((integer(buff[lInc + 3]) And $FF) Shl 8)
                  Or (integer(buff[lInc + 2]) And $FF);
                OverlayExtended[5] := ((integer(buff[lInc + 1]) And $FF) Shl 8)
                  Or (integer(buff[lInc]) And $FF);
                If data.little_endian = 0 Then
                  result[i, j, k] := data.IntenIntercept + data.IntenScale *
                    fswap10r(TempExtended)
                Else
                  result[i, j, k] := data.IntenIntercept + data.IntenScale *
                    TempExtended;
                lInc := lInc + 4;
              End;
        End;
    End;
    freemem(buff);
  End
  Else
  Begin
    result := Nil;
    lImageFormatOK := false;
  End;
End;

Procedure TDICOM.Write_DICOM(FileName: TFileName; Progreso: TGaugeFloat;
  lUnit: float; Out lSz: integer; lDICOM3: boolean);
Var
  FP: File;
  lData: TMedicalImageData;
  lShit, lHiBit, lGrpError, lStart, lEnd, lInc, lPos: integer;
  lP: ByteP;
Const
  Hdrsz = 4096;
  // WriteGroupElement(lDICOM3,-1,lPos,$0002,$0010,'U','I','1.2.840.10008.1.2')//implicit xfer syntax
  Procedure WriteGroupElement(lExplicit: boolean; lInt2, lINt4: integer;
    Var lPos: integer; lGrp, lEle: integer; lChar1, lChar2: AnsiChar;
    lInStr: String);
  Var
    lStr: String;
    lPad: boolean;
    N, lStrLen: integer;
    lT0, lT1: byte;
  Begin
    lStr := lInStr;
    If (lChar1 = 'U') And (lChar2 = 'I') Then

    Else If (odd(Length(lStr))) Then
      lStr := lStr + ' ';
    // for some reason efilm can get confused when strings are padded with anything other than a space - this patch allows efilm to read these files
    lPad := false;
    lT0 := ord(lChar1);
    lT1 := ord(lChar2);
    // if (lGrp = $18) and (lEle = $50) then
    // lStr := lStr+'0';
    If (lInt2 >= 0) Then
      lStrLen := 2
    Else If (lINt4 >= 0) Then
      lStrLen := 4
    Else
    Begin
      lStrLen := Length(lStr);
      If odd(lStrLen) Then
      Begin
        inc(lStrLen);
        lPad := true;
        // lStr := lStr + ' ';
      End;
    End;
    lP[lPos + 1] := lGrp And $00FF;
    lP[lPos + 2] := (lGrp And $FF00) Shr 8;
    lP[lPos + 3] := lEle And $00FF;
    lP[lPos + 4] := (lEle And $FF00) Shr 8;
    lInc := 4; // how many bytes have we added;

    If (lExplicit) And (((lT0 = kO) And (lT1 = kB)) Or
      ((lT0 = kO) And (lT1 = kW)) Or ((lT0 = kS) And (lT1 = kQ))) Then
    Begin
      lP[lPos + 5] := lT0;
      lP[lPos + 6] := lT1;
      lP[lPos + 7] := 0;
      lP[lPos + 8] := 0;
      lInc := lInc + 4;
      If lGrp <> $7FE0 Then
      Begin
        lP[lPos + 9] := lStrLen And $000000FF;
        lP[lPos + 10] := lStrLen And $0000FF00;
        lP[lPos + 11] := lStrLen And $00FF0000;
        lP[lPos + 12] := lStrLen And $FF000000;
        lInc := lInc + 4;
      End;
    End
    Else If (lExplicit) And (((lT0 = kA) And (lT1 = kE)) Or
      ((lT0 = kA) And (lT1 = kS)) Or ((lT0 = kA) And (lT1 = kT)) Or
      ((lT0 = kC) And (lT1 = kS)) Or ((lT0 = kD) And (lT1 = kA)) Or
      ((lT0 = kD) And (lT1 = kS)) Or ((lT0 = kD) And (lT1 = kT)) Or
      ((lT0 = kF) And (lT1 = kL)) Or ((lT0 = kF) And (lT1 = kD)) Or
      ((lT0 = kI) And (lT1 = kS)) Or ((lT0 = kL) And (lT1 = kO)) Or
      ((lT0 = kL) And (lT1 = kT)) Or ((lT0 = kP) And (lT1 = kN)) Or
      ((lT0 = kS) And (lT1 = kH)) Or ((lT0 = kS) And (lT1 = kL)) Or
      ((lT0 = kS) And (lT1 = kS)) Or ((lT0 = kS) And (lT1 = kT)) Or
      ((lT0 = kT) And (lT1 = kM)) Or ((lT0 = kU) And (lT1 = kI)) Or
      ((lT0 = kU) And (lT1 = kL)) Or ((lT0 = kU) And (lT1 = kS)) Or
      ((lT0 = kA) And (lT1 = kE)) Or ((lT0 = kA) And (lT1 = kS))) Then
    Begin
      lP[lPos + 5] := lT0;
      lP[lPos + 6] := lT1;
      lP[lPos + 7] := lStrLen And $000000FF;
      lP[lPos + 8] := lStrLen And $0000FF00;
      lInc := lInc + 4;
      // if (lGrp = $18) and (lEle = $50) then
      // if lPad then showmessage('bPad'+lStr);
    End
    Else If (Not(((lT0 = kO) And (lT1 = kB)) Or ((lT0 = kO) And (lT1 = kW)) Or
      ((lT0 = kS) And (lT1 = kQ)))) Then
    Begin { Not explicit }
      lP[lPos + 5] := lStrLen And $000000FF;
      lP[lPos + 6] := lStrLen And $0000FF00;
      lP[lPos + 7] := lStrLen And $00FF0000;
      lP[lPos + 8] := lStrLen And $FF000000;
      lInc := lInc + 4;
    End;
    If lStrLen = 0 Then
      exit;
    lPos := lPos + lInc;
    If lInt2 >= 0 Then
    Begin
      inc(lPos);
      lP[lPos] := lInt2 And $00FF;
      inc(lPos);
      lP[lPos] := (lInt2 And $FF00) Shr 8;
      exit;
    End;
    If lINt4 >= 0 Then
    Begin
      inc(lPos);
      lP[lPos] := lINt4 And $000000FF;
      inc(lPos);
      lP[lPos] := (lINt4 And $0000FF00) Shr 8;
      inc(lPos);
      lP[lPos] := (lINt4 And $00FF0000) Shr 16;
      inc(lPos);
      lP[lPos] := (lINt4 And $FF000000) Shr 24;
      exit;
    End;
    If lPad Then
    Begin
      // if (lGrp = $18) and (lEle = $50) then
      // if lPad then showmessage('A Pad'+lStr);

      For N := 1 To (lStrLen - 1) Do
      Begin
        lPos := lPos + 1;
        lP[lPos] := ord(lStr[N]);
      End;
      lPos := lPos + 1;
      lP[lPos] := 0;
    End
    Else
    Begin
      For N := 1 To lStrLen Do
      Begin
        lPos := lPos + 1;
        lP[lPos] := ord(lStr[N]);
      End;
    End;
  End;

  Procedure WriteImage(Var lPos: integer);
  Var
    tempsingle: single;
    OverlaySingle: Array [1 .. 2] Of word Absolute tempsingle;
    tempdouble: double;
    OverlayDouble: Array [1 .. 4] Of word Absolute tempdouble;
    TempExtended: extended;
    OverlayExtended: Array [1 .. 5] Of word Absolute TempExtended;
    i, j, k, m, tempint, tiempo0: integer;
    progress: float;
    display: boolean;
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
    // lPos := Hdrsz;
    display := (Progreso <> Nil);
    If display Then
      InitializeGauge;
    For k := 1 To lData.XYZdim[3] Do
    Begin
      For j := 1 To lData.XYZdim[2] Do
        For i := 1 To lData.XYZdim[1] Do
          Case lData.Allocbits_per_pixel Of
            8:
              Begin
                inc(lPos);
                lP[lPos] := round((Image[i, j, k] - lData.MinIntensity) /
                  lUnit) And $FF;
              End;
            16:
              Begin
                tempint := round((Image[i, j, k] - lData.MinIntensity) / lUnit);
                inc(lPos);
                lP[lPos] := tempint And $00FF;
                inc(lPos);
                lP[lPos] := (tempint And $FF00) Shr 8;
              End;
            32:
              If data.float Then
              Begin
                tempsingle := ((Image[i, j, k] - lData.MinIntensity) / lUnit);
                For m := 2 Downto 1 Do
                Begin
                  inc(lPos);
                  lP[lPos] := OverlaySingle[m] And $00FF;
                  inc(lPos);
                  lP[lPos] := (OverlaySingle[m] And $FF00) Shr 8;
                End;
              End
              Else
              Begin
                tempint := round((Image[i, j, k] - lData.MinIntensity) / lUnit);
                inc(lPos);
                lP[lPos] := tempint And $000000FF;
                inc(lPos);
                lP[lPos] := (tempint And $0000FF00) Shr 8;
                inc(lPos);
                lP[lPos] := (tempint And $00FF0000) Shr 16;
                inc(lPos);
                lP[lPos] := (tempint And $FF000000) Shr 24;
              End;
            64:
              Begin
                tempdouble := ((Image[i, j, k] - lData.MinIntensity) / lUnit);
                For m := 4 Downto 1 Do
                Begin
                  inc(lPos);
                  lP[lPos] := OverlayDouble[m] And $00FF;
                  inc(lPos);
                  lP[lPos] := (OverlayDouble[m] And $FF00) Shr 8;
                End;
              End;
            80:
              Begin
                TempExtended := ((Image[i, j, k] - lData.MinIntensity) / lUnit);
                For m := 5 Downto 1 Do
                Begin
                  inc(lPos);
                  lP[lPos] := OverlayExtended[m] And $00FF;
                  inc(lPos);
                  lP[lPos] := (OverlayExtended[m] And $FF00) Shr 8;
                End;
              End;
          End;
      If display Then
      Begin
        progress := LinealInterpolation(1, Progreso.MinValue, lData.XYZdim[3],
          Progreso.MaxValue, k);
        Progreso.updateTime(tiempo0, progress, 'Escribiendo Imagen...');
      End;
    End;
    If display Then
      FinalizeGauge;
  End;

Begin
  lSz := 0;
  lData := data;
  lData.little_endian := 1; // Currently only saves littleEndian
  If lData.PatientName = '' Then
    // eFilm 1.5 requires something to be saved as the Name
    lData.PatientName := 'NO NAME';
  If lData.PatientID = '' Then
    // eFilm 1.5 requires something to be saved as the ID
    lData.PatientID := 'NO ID';
  If lData.StudyDate = '' Then
    // eFilm 1.5 requires something to be saved as the ID
    lData.StudyDate := '20020202';
  If lData.AcqTime = '' Then
    // eFilm 1.5 requires something to be saved as the ID
    lData.AcqTime := '124567.000000';
  If lData.ImgTime = '' Then
    // eFilm 1.5 requires something to be saved as the ID
    lData.ImgTime := '124567.000000';
  getmem(lP, Hdrsz + lData.ImageSz);
  If lDICOM3 Then
  Begin
    For lInc := 1 To 127 Do
      lP[lInc] := 0;
    lP[lInc + 1] := ord('D');
    lP[lInc + 2] := ord('I');
    lP[lInc + 3] := ord('C');
    lP[lInc + 4] := ord('M');
    lPos := 128 + 4;
    lGrpError := 12;
  End
  Else
  Begin
    lPos := 0;
    lGrpError := 12;
  End;
  lShit := 128;
  lP[lShit] := 0;
  If lDICOM3 Then
  Begin
    lStart := lPos;
    WriteGroupElement(lDICOM3, -1, 2, lPos, $0002, $0000, 'U', 'L', '');
    // length
    WriteGroupElement(lDICOM3, 1, -1, lPos, $0002, $0001, 'O', 'B', '');
    // meta info
    If Not lDICOM3 Then
      WriteGroupElement(lDICOM3, -1, -1, lPos, $0002, $0010, 'U', 'I',
        '1.2.840.10008.1.2') // implicit xfer syntax
    Else If lData.little_endian = 1 Then
      WriteGroupElement(lDICOM3, -1, -1, lPos, $0002, $0010, 'U', 'I',
        '1.2.840.10008.1.2.1') // little xfer syntax
    Else
      WriteGroupElement(lDICOM3, -1, -1, lPos, $0002, $0010, 'U', 'I',
        '1.2.840.10008.1.2.2'); // furezx should be 2//big xfer syntax
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0002, $0012, 'U', 'I',
      '2.16.840.1.113662.5'); // implicit xfer syntax
    lEnd := lPos;
    lPos := lStart;
    WriteGroupElement(lDICOM3, -1, lEnd - lStart - lGrpError, lPos, $0002,
      $0000, 'U', 'L', ''); // length
    lPos := lEnd;
  End;
  lStart := lPos;
  WriteGroupElement(lDICOM3, -1, 18, lPos, $0008, $0000, 'U', 'L', '');
  // length
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0008, 'C', 'S',
    'ORIGINAL\PRIMARY\OTHER'); //
  If Not lDICOM3 Then
    WriteGroupElement(lDICOM3, -1, 2, lPos, $0008, $0010, 'L', 'O',
      'ACR-NEMA 2.0'); // length
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0016, 'U', 'I',
    '1.2.840.10008.5.1.4.1.1.4'); // MR
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0008,$0016,'U','I','1.2.840.10008.5.1.4.1.1.20');//NM

  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0018, 'U', 'I',
    '2.16.840.1.113662' + IntToStr(lData.ImageNum));

  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0020, 'D', 'A',
    lData.StudyDate);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0021, 'D', 'A',
    lData.StudyDate);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0030, 'T', 'M',
    lData.AcqTime);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0031, 'T', 'M',
    lData.AcqTime);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0032, 'T', 'M',
    lData.AcqTime);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0033, 'T', 'M',
    lData.ImgTime);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0050, 'S', 'H',
    IntToStr(lData.Accession));
  // modality OT=other, better general. However I use NM as eFilm 1.8.3 will not recognize multislice OT files
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0008,$0060,'C','S','MR');//modality OT=other, better general. However I use NM as eFilm 1.8.3 will not recognize multislice OT files
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0060, 'C', 'S',
    lData.Modality);
  // modality OT=other, better general. However I use NM as eFilm 1.8.3 will not recognize multislice OT files
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0070, 'L', 'O', 'MCID');
  // manufacturer
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0080, 'L', 'O',
    'ANONYMIZED'); // institution
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $0081, 'S', 'T',
    'ANONYMIZED'); // city
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0008, $1030, 'L', 'O',
    'FUNCTIONAL'); // city
  lEnd := lPos;
  lPos := lStart;
  WriteGroupElement(lDICOM3, -1, lEnd - lStart - lGrpError, lPos, $0008, $0000,
    'U', 'L', ''); // length
  lPos := lEnd;
  lStart := lPos;
  WriteGroupElement(lDICOM3, -1, 18, lPos, $0010, $0000, 'U', 'L', '');
  // length
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0010,$0010,'P','N','Anonymized');//name

  WriteGroupElement(lDICOM3, -1, -1, lPos, $0010, $0010, 'P', 'N',
    lData.PatientName); // name
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0010, $0020, 'L', 'O',
    lData.PatientID); // name
  lEnd := lPos;
  lPos := lStart;
  WriteGroupElement(lDICOM3, -1, lEnd - lStart - lGrpError, lPos, $0010, $0000,
    'U', 'L', ''); // length
  lPos := lEnd;
  lStart := lPos;
  WriteGroupElement(lDICOM3, -1, 18, lPos, $0018, $0000, 'U', 'L', '');
  // length
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $0023, 'C', 'S', '2D');
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0018,$0015,'C','S','HEART ');//slice thickness
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $0050, 'D', 'S',
    floattostrf(lData.XYZmm[3], ffFixed, 8, 6)); // slice thickness
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0018,$0070,'I','S','0 ');//
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0018,$0071,'C','S','TIME');//
  If round(lData.kV) <> 0 Then
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $0060, 'D', 'S',
      floattostrf(lData.kV, ffFixed, 8, 6)); // repeat time
  If round(lData.TR) <> 0 Then
  Begin
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $0080, 'D', 'S',
      floattostrf(lData.TR, ffFixed, 8, 6)); // repeat time
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $0081, 'D', 'S',
      floattostrf(lData.TE, ffFixed, 8, 6)); // echo time
  End;
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $0088, 'D', 'S',
    floattostrf(lData.Spacing, ffFixed, 8, 6)); // slice thickness
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0018,$1063,'D','S','1.000000');//time vector, see 0028:0009
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0018,$1050,'D','S',floattostrf(2*lData.xyzmm[1],ffFixed,8,6));//slice thickness
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $1100, 'D', 'S',
    floattostrf(lData.XYZmm[1] * lData.XYZdim[1], ffFixed, 8, 6));
  // slice thickness
  If round(lData.mA) <> 0 Then
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $1151, 'I', 'S',
      floattostrf(lData.mA, ffFixed, 8, 0));
  // XRayTubeCurrent - VR is IS - integer string?
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0018, $5100, 'C', 'S', 'HFS');
  lEnd := lPos;
  lPos := lStart;
  WriteGroupElement(lDICOM3, -1, lEnd - lStart - lGrpError, lPos, $0018, $0000,
    'U', 'L', ''); // length
  lPos := lEnd;
  lStart := lPos;
  WriteGroupElement(lDICOM3, -1, 18, lPos, $0020, $0000, 'U', 'L', '');
  // length
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $000D, 'U', 'I',
    '1.1' + lData.serietag); // Study Instantce
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $000E, 'U', 'I',
    '1.1' + lData.serietag); // Series Instance
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $0010, 'S', 'H',
    IntToStr(lData.Accession)); // pDicomData.SeriesNum
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $0011, 'I', 'S', '1');
  // pDicomData.SeriesNum
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $0013, 'I', 'S',
    IntToStr(lData.ImageNum)); // pDicomData.ImageNum "InstanceNumber"
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $0032, 'D', 'S',
    floattostrf(-lData.XYZmm[1] * lData.XYZdim[1] / 2, ffFixed, 8, 6) + '\' +
    floattostrf(-lData.XYZmm[2] * lData.XYZdim[2] / 2, ffFixed, 8, 6) + '\' +
    floattostrf(-lData.Location, ffFixed, 8, 6));
  // pDicomData.ImageNum "InstanceNumber"

  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $0037, 'D', 'S',
    '1.000000\0.000000\0.000000\0.000000\1.000000\0.000000');
  // pDicomData.ImageNum "InstanceNumber"
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$0052,'U','I','1.2.840.113619.2.5'); Framce reference

  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$1000,'I','S','1');
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$1001,'I','S','1');
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$1002,'I','S',IntToStr(lData.xyzdim[3]));//pdicomdata.location
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$1003,'I','S',IntToStr(lData.xyzdim[3]));//pdicomdata.location
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$1004,'I','S','1');//pdicomdata.location
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$1005,'I','S',IntToStr(lData.xyzdim[3]));//pdicomdata.location

  WriteGroupElement(lDICOM3, -1, -1, lPos, $0020, $1041, 'D', 'S',
    floattostrf(lData.Location, ffFixed, 8, 6)); // pdicomdata.location
  { eFilm has problems with 3D images if you specify the values below
    WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$0011,'I','S',floattostrf(pDicomData.SeriesNum,ffFixed,8,0));//pDicomData.SeriesNum
    //WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$0012,'I','S',floattostrf(pDicomData.AcquNum,ffFixed,8,0));//pDicomData.AcquNum
    WriteGroupElement(lDICOM3,-1,-1,lPos,$0020,$0013,'I','S',floattostrf(pDicomData.ImageNum,ffFixed,8,0));//pDicomData.ImageNum "InstanceNumber"
  }
  lEnd := lPos;
  lPos := lStart;
  WriteGroupElement(lDICOM3, -1, lEnd - lStart - lGrpError, lPos, $0020, $0000,
    'U', 'L', ''); // length
  lPos := lEnd;

  lStart := lPos;
  WriteGroupElement(lDICOM3, -1, 28, lPos, $0028, $0000, 'U', 'L', '');
  // length
  // 0028,0002: set value to 1 [plane]: greyscale, required by DICOM part 3 for MR
  // WriteGroupElement(lDICOM3,1,-1,lPos,$0028,$0002,'U','S','');
  // MONOCHROME1: low values = white, MONOCHROME2: low values = dark, 0028,0004 required for MR
  // WriteGroupElement(lDICOM3,-1,-1,lPos,$0028,$0004,'C','S','MONOCHROME2 ');
  WriteGroupElement(lDICOM3, lData.SamplesPerPixel, -1, lPos, $0028, $0002,
    'U', 'S', '');
  // MONOCHROME1: low values = white, MONOCHROME2: low values = dark, 0028,0004 required for MR
  If lData.SamplesPerPixel = 3 Then
  Begin
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0028, $0004, 'C', 'S', 'RGB');
    WriteGroupElement(lDICOM3, lData.PlanarConfig, -1, lPos, $0028, $0006,
      'U', 'S', '');
  End
  Else
    WriteGroupElement(lDICOM3, -1, -1, lPos, $0028, $0004, 'C', 'S',
      'MONOCHROME2');
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0028, $0008, 'I', 'S',
    IntToStr(lData.XYZdim[3])); // num frames
  // Part 3 of DICOM standard: 0028,0009 is REQUIRED for Multiframe images:
  // 0018:1063 for time, 0018:1065 for time vector and 0020:0013/ for image number [space]
  // WriteGroupElement(lDICOM3,-1,($1063 shl 16)+($0018 ),lPos,$0028,$0009,'A','T','');//3rd dimension is TIME
  WriteGroupElement(lDICOM3, -1, ($0013 Shl 16) + ($0020), lPos, $0028, $0009,
    'A', 'T', ''); // 3rd Dimensoion is SPACE frame ptr
  WriteGroupElement(lDICOM3, lData.XYZdim[2], -1, lPos, $0028, $0010, 'U', 'S',
    ' '); // IntToStr(lData.XYZdim[2]));//row
  WriteGroupElement(lDICOM3, lData.XYZdim[1], -1, lPos, $0028, $0011, 'U', 'S',
    ' '); // IntToStr(lData.XYZdim[1]));//col
  // 0030 order: row spacing[y], column spacing[x]: see DICOM part 3

  WriteGroupElement(lDICOM3, -1, -1, lPos, $0028, $0030, 'D', 'S',
    floattostrf(lData.XYZmm[2], ffFixed, 8, 2) + '\' +
    floattostrf(lData.XYZmm[1], ffFixed, 8, 2)); // pixel spacing
  // DICOM part 3: 0028,0100 required for MR
  WriteGroupElement(lDICOM3, lData.Allocbits_per_pixel, -1, lPos, $0028, $0100,
    'U', 'S', ' ');
  // IntToStr(lData.Allocbits_per_pixel));//bitds alloc
  WriteGroupElement(lDICOM3, lData.Storedbits_per_pixel, -1, lPos, $0028, $0101,
    'U', 'S', ' ');
  // IntToStr(lData.Storedbits_per_pixel));//bits stored
  If lData.little_endian <> 1 Then
    lHiBit := 0
  Else
    lHiBit := lData.Storedbits_per_pixel - 1;
  WriteGroupElement(lDICOM3, lHiBit, -1, lPos, $0028, $0102, 'U', 'S', ' ');
  // IntToStr(lData.Storedbits_per_pixel -1));//high bit
  WriteGroupElement(lDICOM3, 0, -1, lPos, $0028, $0103, 'U', 'S', ' ');
  // pixel representation//IntToStr(lData.Storedbits_per_pixel -1));//high bit
  MinMax(Image, 1, lData.XYZdim[1], 1, lData.XYZdim[2], 1, lData.XYZdim[3],
    lData.MinIntensity, lData.MaxIntensity);
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0028, $1052, 'D', 'S',
    floattostrf(lData.IntenIntercept + lData.MinIntensity, ffFixed, 8, 2));
  // rescale intercept
  WriteGroupElement(lDICOM3, -1, -1, lPos, $0028, $1053, 'D', 'S',
    floattostrf(lData.IntenScale, ffGeneral, 8, 2)); // rescale slope

  (* /inicio Elementos introducidos para tratamiento de ROIs *)

  WriteGroupElement(lDICOM3, -1, 12, lPos, $0030, $0000, 'U', 'L', '');
  // length 12 bytes
  WriteGroupElement(lDICOM3, lData.XYZori[3], -1, lPos, $0030, $0010, 'U',
    'S', ' ');
  WriteGroupElement(lDICOM3, lData.XYZori[2], -1, lPos, $0030, $0011, 'U',
    'S', ' ');
  WriteGroupElement(lDICOM3, lData.XYZori[1], -1, lPos, $0030, $0012, 'U',
    'S', ' ');
  WriteGroupElement(lDICOM3, lData.XYZstart[3], -1, lPos, $0030, $0020, 'U',
    'S', ' ');
  WriteGroupElement(lDICOM3, lData.XYZstart[2], -1, lPos, $0030, $0021, 'U',
    'S', ' ');
  WriteGroupElement(lDICOM3, lData.XYZstart[1], -1, lPos, $0030, $0022, 'U',
    'S', ' ');

  (* /fin Elementos introducidos para tratamiento de ROIs *)

  lEnd := lPos;
  lPos := lStart;
  WriteGroupElement(lDICOM3, -1, lEnd - lStart - lGrpError, lPos, $0028, $0000,
    'U', 'L', ''); // length
  lPos := lEnd;
  // WriteGroupElement(lDICOM3,-1,pDicomData.ImageSz+12,lPos,$7FE0,$0000,'U','L','');//length
  WriteGroupElement(lDICOM3, -1, lData.ImageSz + 12, lPos, ($7FE0), $0000, 'U',
    'L', ''); // data size
  If lData.Storedbits_per_pixel = 16 Then
    WriteGroupElement(lDICOM3, -1, lData.ImageSz, lPos, ($7FE0), $0010, 'O',
      'W', '') // data size
  Else
    WriteGroupElement(lDICOM3, -1, lData.ImageSz, lPos, ($7FE0), $0010, 'O',
      'B', ''); // data size

  // Incorporar la escritura de la imagen -> Hecho!!
  WriteImage(lPos);
  lFileName := FileName;
  If lFileName <> '' Then
  Begin
    assignfile(FP, lFileName);
    rewrite(FP, 1);
    BlockWrite(FP, lP^, lPos);
    close(FP);
    showmessage('Estudio Guardado en ' + lFileName);
  End;
  freemem(lP);
  lSz := lPos;
End;

Function LeeDICOM(lFileName: TFileName; lData: TMedicalImageData;
  Var Progreso: TGaugeFloat; signed, UseData: boolean): TInterfile;
Var
  tempDICOM: TDICOM;
  tiempo0, i, j, k: integer;

  Function InitializeGauge: integer;
  Begin
    result := tiempo_en_milisegundos;
    Progreso.progress := Progreso.MinValue;
    Progreso.Visible := true;
  End;

  Procedure FinalizeGauge;
  Begin
    Progreso.progress := Progreso.MinValue;
    Progreso.Visible := false;
  End;

Begin
  tempDICOM := TDICOM.Create(lFileName, Progreso, signed);
  result := tempDICOM.ToInterfile;
  tempDICOM.Free;
  If useData Then
  Begin
    result.data.IntenScale := lData.IntenScale;
    result.data.IntenIntercept := lData.IntenIntercept;
  End;
  If (Progreso <> Nil) Then
  Begin
    tiempo0 := InitializeGauge;
    For i := 1 To result.data.XYZdim[1] Do
    Begin
      For j := 1 To result.data.XYZdim[2] Do
        For k := 1 To result.data.XYZdim[3] Do
          result[i, j, k] := result.data.IntenIntercept +
            (result.data.IntenScale * result[i, j, k]);
      Progreso.updateTime(tiempo0, LinealInterpolation(1, Progreso.MinValue,
        result.data.XYZdim[1], Progreso.MaxValue, i), 'Escalando...');
    End;
    FinalizeGauge;
  End
  Else
  Begin
    For i := 1 To result.data.XYZdim[1] Do
      For j := 1 To result.data.XYZdim[2] Do
        For k := 1 To result.data.XYZdim[3] Do
          result[i, j, k] := result.data.IntenIntercept +
            (result.data.IntenScale * result[i, j, k]);
  End;
  result.data.MinIntensity := result.data.IntenIntercept +
    (result.data.IntenScale * result.data.MinIntensity);
  result.data.MaxIntensity := result.data.IntenIntercept +
    (result.data.IntenScale * result.data.MaxIntensity);
  result.data.IntenIntercept := 0;
  result.data.IntenScale := 1;
End;

End.
