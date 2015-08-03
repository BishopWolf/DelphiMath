{ ******************************************************************
  Distributed random numbers
  CopyRigth 2008 Alex Vergara Gil
  alex@cphr.edu.cu
  ****************************************************************** }

unit urandist;

interface

uses
  uConstants, parser10, urandom, utypes;

type
  TRanGauss = class(TRandomGen)
  private
    GaussSave: Float; { Saves a Gaussian number }
    GaussNew: Boolean; { Flags a new calculation }
    Mu: Float;
    Sigma: Float;
  protected
    function RanStd: Float;
    { ------------------------------------------------------------------
      Computes 2 random numbers from the standard normal distribution,
      returns one and saves the other for the next call
      ------------------------------------------------------------------ }
  public
    constructor Create(Seed: integer; lMu: Float = 0; lSigma: Float = 1;
      gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Returns a random number from a Gaussian distribution
      with mean Mu and standard deviation Sigma
      ------------------------------------------------------------------ }
  end;

  TRanLandau = class(TRandomGen)
  private
    FWidth: Float;
    FPeak: Float;
    procedure SetPeak(const Value: Float);
    procedure SetWidth(const Value: Float);
    property Peak: Float read FPeak write SetPeak;
    property Width: Float read FWidth write SetWidth;
  public
    constructor Create(Seed: integer; lPeak, lWidth: Float;
      gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Returns a random number from a Landau distribution
      with peak Peak and width Width
      ------------------------------------------------------------------ }
  end;

  TRanExp = class(TRandomGen)
  private
    FB: Float;
    FA: Float;
    procedure SetA(const Value: Float);
    procedure SetB(const Value: Float);
    property A: Float read FA write SetA;
    property B: Float read FB write SetB;
  public
    constructor Create(Seed: integer; lA, lB: Float; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the exponential distribution
      with coeficients:  y = A * exp( B * x )
      ------------------------------------------------------------------ }
  end;

  TRanGamma = class(TRandomGen)
  private
    FA: integer;
    procedure SetA(const Value: integer);
    property A: integer read FA write SetA;
  public
    constructor Create(Seed: integer; lA: integer; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the A-order gamma distribution
      x^(A-1) * exp( -x )
      y = ---------------------
      Gamma (A)
      ------------------------------------------------------------------ }
  end;

  TRanPoisson = class(TRandomGen)
  private
    Falxm: Float;
    Fg: Float;
    Fsq: Float;
    Foldm: Float;
    FXm: Float;
    procedure Setalxm(const Value: Float);
    procedure Setg(const Value: Float);
    procedure Setsq(const Value: Float);
    procedure Setoldm(const Value: Float);
    procedure SetXm(const Value: Float);
    property sq: Float read Fsq write Setsq;
    property alxm: Float read Falxm write Setalxm;
    property g: Float read Fg write Setg;
    property Xm: Float read FXm write SetXm;
    property oldm: Float read Foldm write Setoldm;
    // oldm is a flag for whether xm has changed since last call.
  public
    constructor Create(Seed: integer; lXm: Float; gRNG: RNG_Type = RNG_MT);
    function random: integer;
    { ------------------------------------------------------------------
      Computes a random number from the Poisson distribution of mean Xm
      x^|Xm| * exp( -x )
      y = --------------------- ,   where |Xm|=trunc(Xm)
      |Xm|!
      ------------------------------------------------------------------ }
  end;

  TRanBinom = class(TRandomGen)
  private
    Fpc: Float;
    Foldg: Float;
    Fplog: Float;
    Fpold: Float;
    Fen: Float;
    Fpclog: Float;
    Fnold: integer;
    Fn: integer;
    Fpp: Float;
    procedure Seten(const Value: Float);
    procedure Setnold(const Value: integer);
    procedure Setoldg(const Value: Float);
    procedure Setpc(const Value: Float);
    procedure Setpclog(const Value: Float);
    procedure Setplog(const Value: Float);
    procedure Setpold(const Value: Float);
    procedure Setn(const Value: integer);
    procedure Setpp(const Value: Float);
    property nold: integer read Fnold write Setnold;
    property pold: Float read Fpold write Setpold;
    property pc: Float read Fpc write Setpc;
    property plog: Float read Fplog write Setplog;
    property pclog: Float read Fpclog write Setpclog;
    property en: Float read Fen write Seten;
    property oldg: Float read Foldg write Setoldg;
    property n: integer read Fn write Setn;
    property pp: Float read Fpp write Setpp;
  public
    constructor Create(Seed: integer; ln: integer; lpp: Float;
      gRNG: RNG_Type = RNG_MT);
    function random: integer;
    { ------------------------------------------------------------------
      Computes a random number from the Binomial distribution
      / n \    j         n-j
      y(j) = |     | pp  (1 - pp)    , 0<=pp<=1
      \ j /
      where n is the number of trials > 0 and pp is the probability of each one
      ------------------------------------------------------------------ }
  end;

  TRanBeta = class(TRandomGen)
  private
    FB: Float;
    FA: Float;
    procedure SetA(const Value: Float);
    procedure SetB(const Value: Float);
    property A: Float read FA write SetA;
    property B: Float read FB write SetB;
  public
    constructor Create(Seed: integer; lA, lB: Float; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the (A, B) beta distribution
      IBeta (A, B, X)
      y = ---------------------
      Beta (A, B)
      ------------------------------------------------------------------ }
  end;

  TRanStudent = class(TRandomGen)
  private
    FNu: integer;
    procedure SetNu(const Value: integer);
    property Nu: integer read FNu write SetNu;
  public
    constructor Create(Seed: integer; lNu: integer; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Nu-DOF Student distribution
      ------------------------------------------------------------------ }
  end;

  TRanSnedecor = class(TRandomGen)
  private
    FNu2: integer;
    FNu1: integer;
    procedure SetNu1(const Value: integer);
    procedure SetNu2(const Value: integer);
    property Nu1: integer read FNu1 write SetNu1;
    property Nu2: integer read FNu2 write SetNu2;
  public
    constructor Create(Seed: integer; lNu1, lNu2: integer;
      gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Nu1, Nu2-DOF Snedecor distribution
      ------------------------------------------------------------------ }
  end;

  TRanChiSqr = class(TRandomGen)
  private
    FNu: integer;
    procedure SetNu(const Value: integer);
    property Nu: integer read FNu write SetNu;
  public
    constructor Create(Seed: integer; lNu: integer; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Nu-DOF Chi-Square distribution
      ------------------------------------------------------------------ }
  end;

  TRanCauchy = class(TRandomGen)
  private
    FFWHM: Float;
    FXm: Float;
    procedure SetFWHM(const Value: Float);
    procedure SetXm(const Value: Float);
    property Xm: Float read FXm write SetXm;
    property FWHM: Float read FFWHM write SetFWHM;
  public
    constructor Create(Seed: integer; lXm, lFWHM: Float;
      gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Cauchy distribution with
      Mean = Xm and HalfWidth = FWHM
      ------------------------------------------------------------------ }
  end;

  TRanRayleigh = class(TRandomGen)
  private
    FSig: Float;
    procedure SetSig(const Value: Float);
    property Sig: Float read FSig write SetSig;
  public
    constructor Create(Seed: integer; lSig: Float; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Rayleigh distribution with
      Sigma = sig
      ------------------------------------------------------------------ }
  end;

  TRanTriangular = class(TRandomGen)
  private
    FA: Float;
    FXm: Float;
    procedure SetA(const Value: Float);
    procedure SetXm(const Value: Float);
    property Xm: Float read FXm write SetXm;
    property A: Float read FA write SetA;
  public
    constructor Create(Seed: integer; lXm, lA: Float; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Triangular distribution with
      Mean = Xm and A = A
      ------------------------------------------------------------------ }
  end;

  TRanPareto = class(TRandomGen)
  private
    FB: Float;
    FA: Float;
    procedure SetA(const Value: Float);
    procedure SetB(const Value: Float);
    property A: Float read FA write SetA;
    property B: Float read FB write SetB;
  public
    constructor Create(Seed: integer; lA, lB: Float; gRNG: RNG_Type = RNG_MT);
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from the Triangular distribution with
      parameters A and B
      ------------------------------------------------------------------ }
  end;

  TRanInversionKind = (TRIKString, TRIKVector);

  TRanInversion = class(TRandomGen)
  private
    Fevaluador: TParser;
    Ftotal: Float;
    Fofunc: string;
    FMax: Float;
    FB: Float;
    FA: Float;
    FPuntos: TVector;
    Cumul: TVector;
    FRanInversionKind: TRanInversionKind;
    FDim: integer;
    procedure Setevaluador(const Value: TParser);
    procedure Setofunc(const Value: string);
    procedure Settotal(const Value: Float);
    procedure SetA(const Value: Float);
    procedure SetB(const Value: Float);
    procedure SetMax(const Value: Float);
    procedure SetPuntos(const Value: TVector);
    procedure SetRanInversionKind(const Value: TRanInversionKind);
    procedure SetDim(const Value: integer);
    property evaluador: TParser read Fevaluador write Setevaluador;
    property ofunc: string read Fofunc write Setofunc;
    property total: Float read Ftotal write Settotal;
    property RanInversionKind: TRanInversionKind read FRanInversionKind
      write SetRanInversionKind;
    property A: Float read FA write SetA;
    property B: Float read FB write SetB;
    property Max: Float read FMax write SetMax;
    property Puntos: TVector read FPuntos write SetPuntos;
    property Dim: integer read FDim write SetDim;
  public
    constructor Create(Seed: integer; funcion: String; lA, lB, lMax: Float;
      gRNG: RNG_Type = RNG_MT); overload;
    constructor Create(Seed: integer; lPuntos: TVector; lDim: integer;
      gRNG: RNG_Type = RNG_MT); overload;
    destructor Destroy; override;
    function random: Float;
    function RanI: integer;
    { ------------------------------------------------------------------
      Computes a random number from a user specified distribution with
      inversion method, the function doesn't need to be normalized, the
      algorithm actually do it, the comparison function is y = Max.
      There are to ways to enter the function:
      by string and the domain, the function must be less or equal to Max
      or
      by points and the results are the sorted abscisas, the invnew flag
      must be set to true in the first call or each time you change the
      distribution and then you can omit it in next calls
      ------------------------------------------------------------------ }
  end;

  TRanBisect = class(TRandomGen)
  private
    evaluador: TParser;
    FB: Float;
    FA: Float;
    FEPS: Float;
    procedure SetA(const Value: Float);
    procedure SetB(const Value: Float);
    procedure SetEPS(const Value: Float);
    property A: Float read FA write SetA;
    property B: Float read FB write SetB;
    property EPS: Float read FEPS write SetEPS;
  public
    constructor Create(Seed: integer; lfuncion: String; lA, lB: Float;
      lEPS: Float = 1E-7; gRNG: RNG_Type = RNG_MT);
    destructor Destroy; override;
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from a user specified distribution with
      Bisection method of inversion algorithm
      ------------------------------------------------------------------ }
  end;

  TRanSecant = class(TRandomGen)
  public
    function random(funcion: String; A, B: Float; EPS: Float = 1E-7): Float;
    { ------------------------------------------------------------------
      Computes a random number from a user specified distribution with
      Secant method of inversion algorithm. The Cumulative distribution
      F(x) = U must have a unique solution X for each U
      ------------------------------------------------------------------ }
  end;

  TRanNewtonRhapson = class(TRandomGen)
  private
    evaluador: TParser;
    FB: Float;
    procedure SetB(const Value: Float);
    property B: Float read FB write SetB;
  public
    constructor Create(Seed: integer; funcion: String; lX0: Float;
      gRNG: RNG_Type = RNG_MT);
    destructor Destroy; override;
    function random: Float;
    { ------------------------------------------------------------------
      Computes a random number from a user specified distribution with
      Newton-Rhapson method of inversion algorithm. The Cumulative
      distribution F(x) = U must have a unique solution X for each U
      ------------------------------------------------------------------ }
  end;

implementation

uses ugamma, math, uinvbeta, uinvgam, uinterpolation, uoperations,
  uromberg, ugamdist, uround, umath, utests, ubinom;

function TRanGauss.RanStd: Float;
var
  R, Theta: Float;
  S, C: extended;
begin
  if GaussNew then
  begin
    R := Sqrt(-2.0 * ln(Random3));
    Theta := TwoPi * Random3;
    SinCos(Theta, S, C); // faster
    RanStd := R * C; { Return 1st number }
    GaussSave := R * S; { Save 2nd number }
  end
  else
    RanStd := GaussSave; { Return saved number }
  GaussNew := not GaussNew;
end;

constructor TRanGauss.Create(Seed: integer; lMu, lSigma: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Mu := lMu;
  Sigma := lSigma;
  GaussNew := true;
end;

function TRanGauss.random: Float;
begin
  Result := Mu + Sigma * RanStd;
end;

constructor TRanLandau.Create(Seed: integer; lPeak, lWidth: Float;
  gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Peak := lPeak;
  Width := lWidth;
end;

function TRanLandau.random: Float;
{$I Landau.inc}
var
  t: Float;
begin
  t := Peak + 0.222782 * Width;
  Result := t + Width * transform(Random3)
  // result:=DLandau((x-t)/width)/width;
end;

constructor TRanExp.Create(Seed: integer; lA, lB: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  A := lA;
  B := lB;
end;

function TRanExp.random: Float;
const
  tiny = 1E-30;
begin
  if (B = 0) or (A = 0) then
    Result := Infinity
  else
    Result := -ln(Random1 / A + tiny) / B;
end;

constructor TRanGamma.Create(Seed, lA: integer; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  A := lA;
end;

function TRanGamma.random: Float;
var
  j: integer;
  am, e, S, x, y: Float;
begin
  if A >= 1 then
  begin
    if A < 6 then
    begin // if a<6 use direct method
      x := 1.0;
      for j := 1 to A do
        x := x * Random3;
      x := -ln(x);
    end
    else
    begin
      repeat
        repeat
          y := tan(PI * Random1);
          // [0,1] y is a deviate from a Lorentzian comparison function.
          am := A - 1;
          S := Sqrt(2.0 * am + 1.0);
          x := S * y + am; // We decide whether to reject x:
        until (x > 0.0); // Reject if in regime of zero probability.
        e := (1.0 + y * y) * exp(am * ln(x / am) - S * y);
        // Ratio of prob. fn. to comparison fn.
      until (e >= Random1);
    end;
    Result := x;
  end
  else
  begin
    Result := DefaultVal(FDomain, 0);
  end;
end;

constructor TRanPoisson.Create(Seed: integer; lXm: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  oldm := -1;
  Xm := lXm;
end;

function TRanPoisson.random: integer;
var
  em: integer;
  ef, t, y: Float;
begin
  if (Xm < 12.0) then
  begin // Use direct method.
    if (Xm <> oldm) then
    begin
      oldm := Xm;
      g := exp(-Xm); // If xm is new, compute the exponential.
    end;
    em := -1;
    t := 1.0;
    repeat
      // Instead of adding exponential deviates it is equivalent to multiply uniform deviates. We never actually have to take the log, merely compare to the pre-computed exponential.
      inc(em);
      t := t * Random3; // (0,1)
    until (t <= g);
  end
  else
  begin // Use rejection method.
    if (Xm <> oldm) then
    begin // If xm has changed since the last call, then precompute some functions that occur below.
      oldm := Xm;
      sq := Sqrt(2.0 * Xm);
      alxm := ln(Xm);
      g := Xm * alxm - LnGamma(Xm + 1.0);
      // The function LnGamma is the natural log of the gamma function.
    end;
    repeat
      repeat
        y := tan(PI * Random1);
        // [0,1] y is a deviate from a Lorentzian comparison function.
        ef := sq * y + Xm; // ef is y, shifted and scaled.
      until (ef >= 0.0); // Reject if in regime of zero probability.
      em := Floor(ef); // The trick for integer-valued distributions.
      t := 0.9 * (1.0 + y * y) * exp(em * alxm - LnGamma(em + 1.0) - g);
      { The ratio of the desired distribution to the comparison function; we accept or
        reject by comparing it to another uniform deviate. The factor 0.9 is chosen so
        that t never exceeds 1. }
    until (Random1 <= t);
  end;
  Result := em;
end;

constructor TRanBinom.Create(Seed: integer; ln: integer; lpp: Float;
  gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  nold := -1;
  pold := -1;
  n := ln;
  pp := lpp;
end;

function TRanBinom.random: integer;
var
  j, bnl, em: integer;
  am, ef, g, angle, p, sq, t, y: Float;
begin
  if pp <= 0.5 then
    p := pp
  else
    p := 1 - pp;
  // The binomial distribution is invariant under changing pp to 1-pp, if we also change the
  // answer to n minus itself; we’ll remember to do this below.
  am := n * p; // This is the mean of the deviate to be produced.
  if (n < 25) then
  begin // Use the direct method while n is not too large. This can require up to 25 calls to ran1.
    bnl := 0;
    for j := 1 to n do
      if (Random1 < p) then
        inc(bnl);
  end
  else if (am < 1.0) then
  begin // If fewer than one event is expected out of 25 or more trials, then the distribution is quite accurately Poisson. Use direct Poisson method.
    g := exp(-am);
    t := 1.0;
    j := 0;
    repeat
      t := t * Random3; // (0,1) avoiding 0
      inc(j);
    until (t < g) or (j = n);
    if j <= n then
      bnl := j
    else
      bnl := n;
  end
  else
  begin // Use the rejection method.
    if (n <> nold) then
    begin // If n has changed, then compute useful quantities.
      en := n;
      oldg := LnGamma(en + 1.0);
      nold := n;
    end;
    if (p <> pold) then
    begin // If p has changed, then compute useful quantities.
      pc := 1.0 - p;
      plog := ln(p);
      pclog := ln(pc);
      pold := p;
    end;
    sq := Sqrt(2.0 * am * pc);
    // The following code should by now seem familiar: rejection method with a Lorentzian comparison function.
    repeat
      repeat
        angle := PI * Random1;
        y := tan(angle);
        ef := sq * y + am;
      until (ef >= 0.0) and (ef < (en + 1.0)); // Reject.
      em := Floor(ef); // Trick for integer-valued distribution.
      t := 1.2 * sq * (1.0 + y * y) *
        exp(oldg - LnGamma(em + 1.0) - LnGamma(en - em + 1.0) + em * plog +
        (en - em) * pclog);
    until not(Random1 > t);
    // Reject. This happens about 1.5 times per deviate, on average.
    bnl := em;
  end;
  if (p <> pp) then
    bnl := n - bnl; // Remember to undo the symmetry transformation.
  Result := bnl;
end;

constructor TRanBeta.Create(Seed: integer; lA, lB: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  A := lA;
  B := lB;
end;

function TRanBeta.random: Float;
begin
  Result := InvBeta(A, B, Random1);
end;

constructor TRanStudent.Create(Seed, lNu: integer; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Nu := lNu;
end;

function TRanStudent.random: Float;
begin
  Result := InvStudent(Nu, Random1);
end;

constructor TRanSnedecor.Create(Seed, lNu1, lNu2: integer; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Nu1 := lNu1;
  Nu2 := lNu2;
end;

function TRanSnedecor.random: Float;
begin
  Result := InvSnedecor(Nu1, Nu2, Random1);
end;

constructor TRanChiSqr.Create(Seed, lNu: integer; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Nu := lNu;
end;

function TRanChiSqr.random: Float;
begin
  Result := InvKhi2(Nu, Random1);
end;

constructor TRanCauchy.Create(Seed: integer; lXm, lFWHM: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Xm := lXm;
  FWHM := lFWHM;
end;

function TRanCauchy.random: Float;
begin
  Result := Inv_Cauchy_CumDist(Random1, Xm, FWHM);
  // result:=Xm+FWHM*tan(Pi*Random1);
end;

constructor TRanRayleigh.Create(Seed: integer; lSig: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Sig := lSig;
end;

function TRanRayleigh.random: Float;
begin
  Result := Sig * Sqrt(-ln(Random3));
end;

constructor TRanTriangular.Create(Seed: integer; lXm, lA: Float;
  gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  Xm := lXm;
  A := lA;
end;

function TRanTriangular.random: Float;
begin
  Result := Xm + A * (1 - Sqrt(Random1));
end;

constructor TRanPareto.Create(Seed: integer; lA, lB: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  A := lA;
  B := lB;
end;

function TRanPareto.random: Float;
begin
  Result := B / Power(Random3, 1 / A);
end;

function TRanInversion.random: Float;
var
  t: Float;
begin
  repeat
    evaluador.x := LinealInterpolation(0, A, 1, B, Random1);
    t := evaluador.Value / Max;
    { The ratio of the desired distribution to the comparison function; we accept or
      reject by comparing it to another uniform deviate. t must never exceeds 1. }
  until not(Random1 > t);
  Result := evaluador.x;
end;

constructor TRanInversion.Create(Seed: integer; funcion: String;
  lA, lB, lMax: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  ofunc := funcion;
  evaluador := TParser.Create(nil);
  evaluador.Expression := funcion;
  A := lA;
  B := lB;
  Max := lMax;
  RanInversionKind := TRIKString;
end;

constructor TRanInversion.Create(Seed: integer; lPuntos: TVector; lDim: integer;
  gRNG: RNG_Type);
var
  i: integer;
begin
  inherited Create(Seed, gRNG);
  Dim := lDim;
  FPuntos := Clone(lPuntos, Dim);
  RanInversionKind := TRIKVector;
  total := 0;
  DimVector(Cumul, Dim + 1);
  for i := 1 to Dim do
  begin
    total := total + Puntos[i];
    Cumul[i + 1] := total; // cumulative probability
  end;
  for i := 1 to Dim + 1 do
    Cumul[i] := Cumul[i] / total; // normalization
end;

destructor TRanInversion.Destroy;
begin
  case RanInversionKind of
    TRIKString:
      begin
        evaluador.Free;
      end;
    TRIKVector:
      begin
        DelVector(FPuntos);
        DelVector(Cumul);
      end;
  end;
  inherited Destroy;
end;

function TRanInversion.RanI: integer;
var
  i, j: integer;
  t: Float;
begin
  i := Dim shr 1;
  t := Random1;
  j := i;
  while not((t >= Cumul[i]) and (t < Cumul[i + 1])) do
  begin
    j := (j shr 1);
    if j = 0 then
      j := 1;
    if (t < Cumul[i]) then
      i := i - j
    else
      i := i + j;
  end;
  Result := i;
end;

procedure TRanInversion.SetA(const Value: Float);
begin
  FA := Value;
end;

procedure TRanInversion.SetB(const Value: Float);
begin
  FB := Value;
end;

procedure TRanInversion.SetDim(const Value: integer);
begin
  FDim := Value;
end;

procedure TRanInversion.Setevaluador(const Value: TParser);
begin
  Fevaluador := Value;
end;

procedure TRanInversion.SetMax(const Value: Float);
begin
  FMax := Value;
end;

procedure TRanInversion.Setofunc(const Value: string);
begin
  Fofunc := Value;
end;

procedure TRanInversion.SetPuntos(const Value: TVector);
begin
  FPuntos := Value;
end;

procedure TRanInversion.SetRanInversionKind(const Value: TRanInversionKind);
begin
  FRanInversionKind := Value;
end;

procedure TRanInversion.Settotal(const Value: Float);
begin
  Ftotal := Value;
end;

constructor TRanBisect.Create(Seed: integer; lfuncion: String;
  lA, lB, lEPS: Float; gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  A := lA;
  B := lB;
  evaluador := TParser.Create(nil);
  evaluador.Expression := lfuncion;
end;

destructor TRanBisect.Destroy;
begin
  evaluador.Free;
  inherited Destroy;
end;

function TRanBisect.random: Float;
var
  x, xa, xb, F, U, t: Float;
begin
  xa := A;
  xb := B;
  U := Random1;
  t := RombergIntT(evaluador.Expression, A, B); // normalization
  repeat
    x := (xb + xa) / 2;
    F := RombergIntT(evaluador.Expression, A, x);
    if F <= U * t then
      xa := x
    else
      xb := x;
  until xb - xa < 2 * EPS;
  Result := x;
end;

function TRanSecant.random(funcion: String; A, B, EPS: Float): Float;
var
  x, xa, xb, F, U, t, FA, FB: Float;
begin
  xa := A;
  xb := B;
  U := Random1;
  t := RombergIntT(funcion, A, B); // normalization
  repeat
    FA := RombergIntT(funcion, A, xa);
    FB := RombergIntT(funcion, A, xb);
    if U * t = FA then
    begin
      Result := xa;
      exit;
    end;
    x := xa + (xb - xa) * (U * t - FA) / (FB - FA);
    F := RombergIntT(funcion, A, x);
    if F <= U * t then
      xa := x
    else
      xb := x;
  until xb - xa < EPS;
  Result := x;
end;

constructor TRanNewtonRhapson.Create(Seed: integer; funcion: String; lX0: Float;
  gRNG: RNG_Type);
begin
  inherited Create(Seed, gRNG);
  evaluador := TParser.Create(nil);
  evaluador.Expression := funcion;
  B := lX0;
end;

destructor TRanNewtonRhapson.Destroy;
begin
  evaluador.Free;
  inherited;
end;

function TRanNewtonRhapson.random: Float;
var
  x, F, U, newx: Float;
begin
  x := B;
  U := Random1;
  repeat
    F := RombergIntT(evaluador.Expression, 0, x);
    evaluador.x := x;
    newx := x - (F - U) / evaluador.Value;
    if newx = x then
      break
    else
      x := newx;
  until false;
  Result := x;
end;

procedure TRanPoisson.Setalxm(const Value: Float);
begin
  Falxm := Value;
end;

procedure TRanPoisson.Setg(const Value: Float);
begin
  Fg := Value;
end;

procedure TRanPoisson.Setoldm(const Value: Float);
begin
  Foldm := Value;
end;

procedure TRanPoisson.Setsq(const Value: Float);
begin
  Fsq := Value;
end;

procedure TRanPoisson.SetXm(const Value: Float);
begin
  FXm := Value;
end;

procedure TRanBinom.Seten(const Value: Float);
begin
  Fen := Value;
end;

procedure TRanBinom.Setn(const Value: integer);
begin
  Fn := Value;
end;

procedure TRanBinom.Setnold(const Value: integer);
begin
  Fnold := Value;
end;

procedure TRanBinom.Setoldg(const Value: Float);
begin
  Foldg := Value;
end;

procedure TRanBinom.Setpc(const Value: Float);
begin
  Fpc := Value;
end;

procedure TRanBinom.Setpclog(const Value: Float);
begin
  Fpclog := Value;
end;

procedure TRanBinom.Setplog(const Value: Float);
begin
  Fplog := Value;
end;

procedure TRanBinom.Setpold(const Value: Float);
begin
  Fpold := Value;
end;

procedure TRanBinom.Setpp(const Value: Float);
begin
  Fpp := Value;
end;

procedure TRanLandau.SetPeak(const Value: Float);
begin
  FPeak := Value;
end;

procedure TRanLandau.SetWidth(const Value: Float);
begin
  FWidth := Value;
end;

procedure TRanExp.SetA(const Value: Float);
begin
  FA := Value;
end;

procedure TRanExp.SetB(const Value: Float);
begin
  FB := Value;
end;

procedure TRanGamma.SetA(const Value: integer);
begin
  FA := Value;
end;

procedure TRanBeta.SetA(const Value: Float);
begin
  FA := Value;
end;

procedure TRanBeta.SetB(const Value: Float);
begin
  FB := Value;
end;

procedure TRanStudent.SetNu(const Value: integer);
begin
  FNu := Value;
end;

procedure TRanSnedecor.SetNu1(const Value: integer);
begin
  FNu1 := Value;
end;

procedure TRanSnedecor.SetNu2(const Value: integer);
begin
  FNu2 := Value;
end;

procedure TRanChiSqr.SetNu(const Value: integer);
begin
  FNu := Value;
end;

procedure TRanCauchy.SetFWHM(const Value: Float);
begin
  FFWHM := Value;
end;

procedure TRanCauchy.SetXm(const Value: Float);
begin
  FXm := Value;
end;

procedure TRanRayleigh.SetSig(const Value: Float);
begin
  FSig := Value;
end;

procedure TRanTriangular.SetA(const Value: Float);
begin
  FA := Value;
end;

procedure TRanTriangular.SetXm(const Value: Float);
begin
  FXm := Value;
end;

procedure TRanPareto.SetA(const Value: Float);
begin
  FA := Value;
end;

procedure TRanPareto.SetB(const Value: Float);
begin
  FB := Value;
end;

procedure TRanBisect.SetA(const Value: Float);
begin
  FA := Value;
end;

procedure TRanBisect.SetB(const Value: Float);
begin
  FB := Value;
end;

procedure TRanBisect.SetEPS(const Value: Float);
begin
  FEPS := Value;
end;

procedure TRanNewtonRhapson.SetB(const Value: Float);
begin
  FB := Value;
end;

end.
