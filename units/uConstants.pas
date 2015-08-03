Unit uConstants;

Interface

{$I Compiler.inc}
// Speed  , precision
// Default all float are Double (8 bytes  = 64 bits) Good   , aceptable
{ .$DEFINE EXTENDEDREAL }
// all float are Extended       (12 bytes = 96 bits) Slowest, Best
{$DEFINE SINGLEREAL }
// all float are Single         (4 bytes  = 32 bits) Fastest, Bad

{ ------------------------------------------------------------------
  Floating point type (Default = Double)
  ------------------------------------------------------------------ }

{$IFDEF SINGLEREAL}

Type
  Float = Single;
{$ELSE}
{$IFDEF EXTENDEDREAL}

Type
  Float = Extended;
{$ELSE}
{$DEFINE DOUBLEREAL}

Type
  Float = Real; // Real in Delphi maps to Double in Windows
  {$ENDIF}
  {$ENDIF}
  { ------------------------------------------------------------------
    Integer type (Default = integer=longint=int32)
    ------------------------------------------------------------------ }
  {$IFDEF WIN64}
  // type   Integer = int64;
  {$ENDIF}
  { ------------------------------------------------------------------
    Some useful system const
    ------------------------------------------------------------------ }

Const
  kTab       = ansichar(9);
  kEsc       = ansichar(27);
  kCR        = ansichar(13);
  kLF        = ansichar(10);
  endUnix    = kCR;
  endWindows = kCR + kLF;
  endMac     = kLF;
  {$IFDEF LINUX}
  PathDelim = '/';
  {$ELSE}
  PathDelim = '\';
  {$ENDIF}
  { ------------------------------------------------------------------
    Mathematical constants
    ------------------------------------------------------------------ }

Const
  Pi         = 3.14159265358979323846; { Pi }
  Ln2        = 0.69314718055994530942; { Ln(2) }
  Ln10       = 2.30258509299404568402; { Ln(10) }
  LnPi       = 1.14472988584940017414; { Ln(Pi) }
  InvLn2     = 1.44269504088896340736; { 1/Ln(2) }
  InvLn10    = 0.43429448190325182765; { 1/Ln(10) }
  TwoPi      = 6.28318530717958647693; { 2*Pi }
  PiDiv2     = 1.57079632679489661923; { Pi/2 }
  SqrtPi     = 1.77245385090551602730; { Sqrt(Pi) }
  Sqrt2Pi    = 2.50662827463100050242; { Sqrt(2*Pi) }
  InvSqrt2Pi = 0.39894228040143267794; { 1/Sqrt(2*Pi) }
  LnSqrt2Pi  = 0.91893853320467274178; { Ln(Sqrt(2*Pi)) }
  Ln2PiDiv2  = 0.91893853320467274178; { Ln(2*Pi)/2 }
  Sqrt2      = 1.41421356237309504880; { Sqrt(2) }
  Sqrt2Div2  = 0.70710678118654752440; { Sqrt(2)/2 }
  Gold       = 1.61803398874989484821; { Golden Mean = (1 + Sqrt(5))/2 }
  CGold      = 0.38196601125010515179; { 2 - GOLD }

  { ------------------------------------------------------------------
    Physical Units

    Nota Importante:
    Al usar unidades todos los coeficientes y valores se expresaran siempre
    en la unidad base, si se quiere pasar a la unidad original se debe dividir
    por esta. ejemplo:
    v:=1*metro
    inttostr(v)    =>  '1'     (m)
    inttostr(v/mm) =>  '1000'  (mm)
    ------------------------------------------------------------------ }

Const
  (* Longitud *)
  Metro    = 1; // base = 1 (SI)
  m2       = Metro * Metro;
  m3       = m2 * Metro;
  km       = 1E3 * Metro;
  dm       = 1E-1 * Metro;
  dm3      = dm * dm * dm;
  cm       = 1E-2 * Metro;
  cm3      = cm * cm * cm;
  mm       = 1E-3 * Metro;
  mm3      = mm * mm * mm;
  Angstrom = 1.00001498E-10 * Metro;
  nm       = 1E-9 * Metro;
  // American units
  inch  = 2.54 * cm;
  feet  = 12 * inch;
  yard  = 3 * feet;
  litre = dm3;
  (* Masa *)
  kg    = 1; // base = 1 (SI)
  Gramo = 1E-3 * kg;
  mg    = 1E-3 * Gramo;
  // American
  Pound = kg / 2.2;
  ounce = Pound / 16;
  (* Tiempo *)
  Segundo = 1; // base = 1 (SI)
  Sec2    = Segundo * Segundo;
  Minuto  = 60 * Segundo;
  Hora    = 60 * Minuto;
  Dia     = 24 * Hora;
  Semana  = 7 * Dia;
  (* Fuerza y Trabajo *)
  Newton  = kg * Metro / Sec2;
  Joule   = Newton * Metro;
  Watt    = Joule / Segundo;
  _Pascal = Newton / m2;
  (* Electricidad y Magnetismo *)
  Ampere           = 1; // base = 1 (SI)
  Coulomb          = Ampere * Segundo;
  ElementaryCharge = 1.602176487E-19 * Coulomb; { C }
  Amp2             = Ampere * Ampere;
  mA               = 1E-3 * Ampere;
  Volt             = Watt / Ampere;
  mV               = 1E-3 * Volt;
  Weber            = Volt * Segundo;
  Tesla            = Weber / m2;
  Henry            = Weber / Ampere;
  Ohm              = Volt / Ampere;
  nC               = 1E-9 * Coulomb;
  pC               = 1E-12 * Coulomb;
  Farad            = Coulomb / Volt;
  eV               = ElementaryCharge * Volt; { electronVolt }           { J }
  keV              = 1E3 * eV;
  MeV              = 1E3 * keV;
  GeV              = 1E3 * MeV;
  (* Cantidad de Sustancia *)
  mol = 1; // base = 1 (SI)
  (* Temperatura *)
  Kelvin  = 1;      // base = 1 (SI)
  Celsius = 273.15; // En este caso hay que sumar !!!!!
  (* Otras *)
  Hz    = 1 / Segundo;
  MHz   = 1E6 * Hz;
  GHz   = 1E9 * Hz;
  bit   = 1;
  _byte = 8 * bit;
  kB    = 1024.0 * _byte;
  MB    = 1024.0 * kB;
  GB    = 1024.0 * MB;
  TB    = 1024.0 * GB;
  PB    = 1024.0 * TB;
  (* Actividad *)
  Bq   = 1 / Segundo;
  MBq  = 1E6 * Bq;
  GBq  = 1E9 * Bq;
  Gy   = Joule / kg;
  mGy  = 1E-3 * Gy;
  uGy  = 1E-6 * Gy;
  MBqs = MBq * Segundo;
  GBqs = GBq * Segundo;
  MBqh = MBq * Hora;
  (* angulos *)
  rad    = 1; // base = 1
  degree = (Pi / 180) * rad;
  (* densidad *)
  g_cm3 = Gramo / cm3;
  kg_m3 = kg / m3;

  { ------------------------------------------------------------------
    Physical constants
    ------------------------------------------------------------------ }

Const                                              { Units }
  ProtonMass               = 1.672621637E-27 * kg; { kg }
  ProtonCharge             = ElementaryCharge;     { C }
  NeutronMass              = 1.674927211E-27 * kg; { kg }
  NeutronCharge            = 0.0 * Coulomb;        { C }
  ElectronMass             = 9.10938215E-31 * kg;  { kg }
  ElectronCharge           = -ElementaryCharge;    { C }
  AtomicMassUnit           = 1.660538782E-27 * kg; { kg }
  Avogadro                 = 6.02214179E23 / mol;  { mol^-1 }
  BohrMagneton             = 927.400915E-26 * Joule / Tesla; { J/T }
  BohrRadius               = 0.52917720859E-10 * Metro; { m }
  Boltzmann                = 1.3806504E-23 * Joule / Kelvin; { J/K }
  ClassicalElectronRadius  = 2.8179402894E-15 * Metro; { m }
  ComptonWaveLength        = 2.4263102175E-12 * Metro; { m }
  FineStructureConstant    = 7.2973525376E-3;          { }
  InvFineStructureConstant = 137.035999679;            { }
  Planck                   = 6.62606896E-34 * Joule * Segundo; { Js }
  PlanckOver2pi            = 1.054571628E-34 * Joule * Segundo; { Js }
  SpeedOfLigth             = 299792458 * Metro / Segundo; { m/s }// exact
  // SpeedOfLigth=1/sqrt(ElectricConstant*MagneticConstant);
  ElectricConstant          = 8.854187817E-12 * Farad / Metro; { F/m }
  ElectricPotentialConstant = 1 / (4 * Pi * ElectricConstant); { m/F }
  MagneticConstant          = 12.566370614E-7 * Newton / Amp2; { N/A^2 }
  MagneticPotentialConstant = MagneticConstant / (4 * Pi); { N/A^2 }
  SpeedOfLight2             = SpeedOfLigth * SpeedOfLigth; { m2/s2 }

  { ------------------------------------------------------------------
    Error codes for mathematical functions
    ------------------------------------------------------------------ }

Const
  FOk          = 0;   { No error }
  FDomain      = -1;  { Argument domain error }
  FSing        = -2;  { Function singularity }
  FOverflow    = -3;  { Overflow range error }
  FUnderflow   = -4;  { Underflow range error }
  FTLoss       = -5;  { Total loss of precision }
  FPLoss       = -6;  { Partial loss of precision }
  FNAN         = -7;  { Non Alpha numeric expression }
  FInfinity    = -8;  { Infinity expression or division by zero }
  FNegInfinity = -9;  { Negative Infinity expression or division by zero }
  FMemOverflow = -10; { Memory Overflow, not enough memory available }
  { ------------------------------------------------------------------
    Machine-dependent constants
    ------------------------------------------------------------------ }
  {$IFDEF _16BIT}
  { Sizes for a 16-bit compiler (Turbo Pascal / Delphi 1) }

  {$IFDEF SINGLEREAL}

Const
  MAX_FLT  = 16382; { Max size of real vector }
  MAX_COMP = 7280;  { Max size of complex vector }
  {$ENDIF}
  {$IFDEF DOUBLEREAL}

Const
  MAX_FLT  = 8190; // 2^13-2
  MAX_COMP = 3854;
  {$ENDIF}
  {$IFDEF EXTENDEDREAL}

Const
  MAX_FLT  = 6552;
  MAX_COMP = 3119;
  {$ENDIF}

Const
  MAX_INT  = 16382; { Max size of integer vector }  // 2^14
  MAX_BOOL = 32766; { Max size of boolean vector }  // 2^15
  MAX_STR  = 254; { Max size of string vector }     // 2^8-2
  MAX_VEC  = 16382; { Max number of vectors in a matrix }
  MAX_MAT  = 8192; { Max number of matrixes in a 3Dmatrix }

  {$ELSE}
  { Sizes for a 32-bit compiler (Delphi > 1, FPC, GPC) }

Const
  {$IFDEF SINGLEREAL}  // Max capacity 2GB
  MAX_FLT = 536870912; // 2^29 for float = 4 bytes
  {$ENDIF}
  {$IFDEF DOUBLEREAL}  // Max capacity 2GB
  MAX_FLT = 268435456; // 2^28 for float = 8 bytes
  {$ENDIF}
  {$IFDEF EXTENDEDREAL}// Max capacity 2GB
  MAX_FLT = 134217728; // 2^27 for float = 12 bytes
  {$ENDIF}
  MAX_COMP = MAX_FLT; // Max capacity 2GB
  MAX_INT  = 268435456;
  // 2^28  integer = 4 bytes  //Max capacity 1GB
  MAX_BOOL = 1073741824;
  // 2^30  boolean = 1 byte   //Max capacity 1GB
  MAX_STR = 67108864;
  // 2^26  string = 32 bytes  //Max capacity 2GB
  MAX_VEC = MAX_FLT;
  MAX_MAT = MAX_FLT;
  // cuidado, en Delphi los arreglos de punteros estaticos tienen este limite=> 32768 elementos
  {$ENDIF}
  {$IFDEF SINGLEREAL}

Const
  MachEp = 1.192092895507813E-7;  { Floating point precision: 2^(-23) }
  MaxNum = 3.402823669209384E+38; { Max. floating point number: 2^128 }
  MinNum = 1.175494350822288E-38; { Min. floating point number: 2^(-126) }
  MaxLog = 88.72283911167299;     { Max. argument for Exp = Ln(MaxNum) }
  MinLog = -87.33654475055310;    { Min. argument for Exp = Ln(MinNum) }
  MaxGam = 34.648;                { Max. argument for Gamma }
  MaxLgm = 1.0383E+36;            { Max. argument for LnGamma }
  {$ENDIF}
  {$IFDEF DOUBLEREAL}

Const
  MachEp = 2.220446049250313E-16;  { 2^(-52) }
  MaxNum = 1.797693134862315E+308; { 2^1024 }
  MinNum = 2.225073858507202E-308; { 2^(-1022) }
  MaxLog = 709.7827128933840;
  MinLog = -708.3964185322641;
  MaxGam = 171.624376956302;
  MaxLgm = 2.556348E+305;
  {$ENDIF}
  {$IFDEF EXTENDEDREAL}

Const
  MachEp = 1.08420217248550444E-19;   { 2^(-63) }
  MaxNum = 1.18973149535723103E+4932; { 2^16384 }
  MinNum = 3.36210314311209558E-4932; { 2^(-16382) }
  MaxLog = 11356.5234062941439;
  MinLog = -11355.137111933024;
  MaxGam = 1755.455;
  MaxLgm = 1.04848146839019521E+4928;
  {$ENDIF}

Const
  Bytes_FLT      = SizeOf(Float); { Size in bytes of float }
  Bytes_Integer  = SizeOf(Integer);
  Bytes_Word     = SizeOf(Word);
  Bytes_ShortInt = SizeOf(ShortInt);
  tiny           = 1E-9;

  // Max_FLT = MaxNum;
Var
  MaxPower: Integer; { Max power of two }

  { ------------------------------------------------------------------
    Error handling
    ------------------------------------------------------------------ }

Procedure SetErrCode(ErrCode: Integer);
{ Sets the error code }

Function DefaultVal(ErrCode: Integer; DefVal: Float): Float;
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
Function DefaultIntVal(ErrCode: Integer; DefVal: Integer): Integer;
{$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
{ Sets error code and default function value }

Function MathErr: Integer;
{ Returns the error code }

Implementation

Var
  gErrCode: Integer;

Procedure SetErrCode(ErrCode: Integer);
Begin
  gErrCode := ErrCode;
End;

Function DefaultVal(ErrCode: Integer; DefVal: Float): Float;
Begin
  SetErrCode(ErrCode);
  DefaultVal := DefVal;
End;

Function DefaultIntVal(ErrCode: Integer; DefVal: Integer): Integer;
Begin
  SetErrCode(ErrCode);
  DefaultIntVal := DefVal;
End;

Function MathErr: Integer;
Begin
  MathErr := gErrCode;
End;

Initialization

MaxPower := Trunc(ln(MAX_COMP + 1) * InvLn2);

End.
