(* Symbol USEINLINING :
   --------------------

      Defines whether to use function inlining.

   NOTE: Enabling this symbol increases executable size but will probably
   result in better performance in most cases. *)

  {$IFDEF INLININGSUPPORTED}
    {$DEFINE USEINLINING}
  {$ENDIF}
  
{ ------------------------------------------------------------------
  Error codes for matrix computations
  ------------------------------------------------------------------ }

const
  MatOk = 0; { No error }
  MatNonConv = -1; { Non-convergence }
  MatSing = -2; { Quasi-singular matrix }
  MatErrDim = -3; { Non-compatible dimensions }
  MatNotPD = -4; { Matrix not positive definite }

  { ------------------------------------------------------------------
    Error codes for optimization and nonlinear equations
    ------------------------------------------------------------------ }

const
  OptOk = 0; { No error }
  OptNonConv = -1; { Non-convergence }
  OptSing = -2; { Quasi-singular hessian matrix }
  OptBigLambda = -5; { Too high Marquardt parameter }

  { ------------------------------------------------------------------
    Error codes for nonlinear regression
    ------------------------------------------------------------------ }

const
  NLMaxPar = -6; { Max. number of parameters exceeded }
  NLNullPar = -7; { Initial parameter equal to zero }

  { ------------------------------------------------------------------
    Comparison type
    ------------------------------------------------------------------ }

type
  TComparison = (Eq, NE, LT, MT, LTOE, MTOE);

  { ------------------------------------------------------------------
    Vectors and matrices.
    ------------------------------------------------------------------ }

type
  TVector = array of Float; // array[0..MAX_FLT ]  of Float;       32 bits
  TIntVector = array of Integer; // array[0..MAX_INT ]  of Integer;   32 bits
  TInt64Vector = array of Int64; // array[0..MAX_INT ]  of Int64;   64 bits
  TWordVector = array of Word; // array[0..MAXWORD ]  of Word;         16 bits
  TCompVector = array of Complex;
  // array[0..MAX_COMP]  of Complex;   32+32 bits
  TBoolVector = array of Boolean; // array[0..MAX_BOOL]  of Boolean;   1 bit
  TStrVector = array of String; // array[0..MAX_STR ]  of String;     256 bytes

  // PVector     = ^TVector;
  // PIntVector  = ^TIntVector;
  // PBoolVector = ^TBoolVector;
  // PCompVector = ^TCompVector;
  // PStrVector  = ^TStrVector;

  TMatrix = array of TVector; // array[0..MAX_VEC] of PVector;
  TIntMatrix = array of TIntVector; // array[0..MAX_VEC] of PIntVector;
  TWordMatrix = array of TWordVector;
  TBoolMatrix = array of TBoolVector; // array[0..MAX_VEC] of PBoolVector;
  TCompMatrix = array of TCompVector; // array[0..MAX_VEC] of PCompVector;
  TStrMatrix = array of TStrVector; // array[0..MAX_VEC] of PStrVector;

  // PMatrix     = ^TMatrix;
  // PIntMatrix  = ^TIntMatrix;
  // PBoolMatrix = ^TBoolMatrix;
  // PCompMatrix = ^TCompMatrix;
  // PStrMatrix  = ^TStrMatrix;

  T3DMatrix = array of TMatrix; // array[0..MAX_MAT] of PMatrix;
  T3DIntMatrix = array of TIntMatrix; // array[0..MAX_MAT] of PIntMatrix;
  T3DWordMatrix = array of TWordMatrix;
  T3DBoolMatrix = array of TBoolMatrix; // array[0..MAX_MAT] of PBoolMatrix;
  T3DCompMatrix = array of TCompMatrix; // array[0..MAX_MAT] of PCompMatrix;
  T3DStrMatrix = array of TStrMatrix; // array[0..MAX_MAT] of PStrMatrix;

  // P3DMatrix     = ^T3DMatrix;
  // P3DIntMatrix  = ^T3DIntMatrix;
  // P3DBoolMatrix = ^T3DBoolMatrix;
  // P3DCompMatrix = ^T3DCompMatrix;
  // P3DStrMatrix  = ^T3DStrMatrix;

  { ------------------------------------------------------------------
    Functional types
    ------------------------------------------------------------------ }

  { Function of one variable }
type
  TFunc = function(X: Float): Float;

type
  TFuncs = function(X: Float; mA: Integer): TVector;

type
  TabCoef = array [0 .. 9] of Float;

  { Function of one variable with several coeficients }
type
  TFuncNCoef = function(X: Float; A: TVector; var dyda: TVector;
    na: Integer): Float;

  { Nonlinear equation system }
type
  TEquations = procedure(X: TVector; out F: TVector);

  { Differential equation system }
type
  TDiffEqs = procedure(X: Float; Y: TVector; out Yp: TVector);
  TDerivs = function(X: Float; Y: TVector; Dim: Integer): TVector;

  { Jacobian }
type
  TJacobian = function(X: TVector): TMatrix;

  { Gradient }
type
  TGradient = function(X: TVector): TVector;

  { Hessian and Gradient }
type
  THessGrad = procedure(X: TVector; out G: TVector; out H: TMatrix);

  { cursor constants }

const
  crHourGlassAni = 1;
  crAppStartAni = 2;
  crGlobe = 3;

type

  TAxis = (AxisX, AxisY, AxisZ);

  TRenderProcedures = (TRPNearestNeighbor, TRPTrilinear, TRPTriCubic,
    TRPPolinomial3D, TRPRational3D);

  TPriority = (TPLowest, TPLow, TPNormal, TPHigh, TPHighest);

  { ------------------------------------------------------------------
    Statistics
    ------------------------------------------------------------------ }

type
  THistogramType = (THTDifferential, THTAcumulative);

  { ------------------------------------------------------------------
    Curve fit
    ------------------------------------------------------------------ }

type
  TRegMode = (OLS, WLS); { Regression mode }

type
  TRegTest = record { Test of regression }
    Vr: Float; { Residual variance }
    R2: Float; { Coefficient of determination }
    R2a: Float; { Adjusted coeff. of determination }
    F: Float; { Variance ratio (explained/residual) }
    Nu1, Nu2: Integer; { Degrees of freedom }
  end;

  { Regression function }
type
  TRegFunc = function(X: Float; B: TVector): Float;

  { Procedure to compute the derivatives of the regression function
    with respect to the regression parameters }
type
  TDerivProc = procedure(X, Y: Float; B: TVector; out D: TVector);

  { ------------------------------------------------------------------
    Random
    ------------------------------------------------------------------ }

type
  MiBool = 0 .. 1;

  { ------------------------------------------------------------------
    Integer types
    ------------------------------------------------------------------ }

type
  int32 = LongInt;
  uint32 = LongWord;
  int16 = SmallInt;
  uint16 = Word;
  int8 = ShortInt;
  uint8 = Byte;

  { ------------------------------------------------------------------
    Medical Images types
    ------------------------------------------------------------------ }

type
  SingleRA0 = array [0 .. 0] of single;
  Singlep0 = ^SingleRA0;
  DoubleRA0 = array [0 .. 0] of double;
  Doublep0 = ^DoubleRA0;
  ExtendedRA0 = array [0 .. 0] of Extended;
  Extendedp0 = ^ExtendedRA0;
  ByteRA0 = array [0 .. 0] of Byte;
  Bytep0 = ^ByteRA0;
  ShortIntRA0 = array [0 .. 0] of Short;
  ShortIntp0 = ^ShortIntRA0;
  WordRA0 = array [0 .. 0] of Word;
  Wordp0 = ^WordRA0;
  SmallIntRA0 = array [0 .. 0] of SmallInt;
  SMallIntp0 = ^SmallIntRA0;
  LongIntRA0 = array [0 .. 0] of LongInt;
  LongIntp0 = ^LongIntRA0;
  LongWordRA0 = array [0 .. 0] of LongWord;
  LongWordp0 = ^LongWordRA0;

  ByteRA = array [1 .. 1] of Byte;
  Bytep = ^ByteRA;
  WordRA = array [1 .. 1] of Word;
  Wordp = ^WordRA;
  DWordRA = array [1 .. 1] of DWord;
  DWordp = ^DWordRA;
  SmallIntRA = array [1 .. 1] of SmallInt;
  SMallIntp = ^SmallIntRA;
  LongIntRA = array [1 .. 1] of LongInt;
  LongIntp = ^LongIntRA;
  SingleRA = array [1 .. 1] of single;
  Singlep = ^SingleRA;
  DoubleRA = array [1 .. 1] of double;
  Doublep = ^DoubleRA;

const
  PixelCountMax = 32768;

type
  HistoRA = array [0 .. 256] of LongInt;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = ARRAY [0 .. PixelCountMax - 1] OF TRGBTriple;
