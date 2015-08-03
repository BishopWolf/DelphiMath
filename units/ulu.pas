{ ******************************************************************
  LU decomposition
  ****************************************************************** }

unit ulu;

interface

uses
  utypes, uminmax, uComplex, uConstants;

type
  TBaseDecomp = class
  protected
    procedure _Decomp; virtual; abstract;
    function _Solve(const B: TVector): TVector; virtual; abstract;
  public
    function Solve(const B: TVector): TVector; virtual; abstract;
  end;

  TLU = class(TBaseDecomp)
  private
    InitDim: Integer; { Initial vector size }
    Index: TIntVector; { Records the row permutations }
    Parity: Boolean; { Parity of the permutations }
    Lb, Ub: Integer;
    A: TMatrix;
  protected
    procedure _Decomp; override;
    function _Solve(const B: TVector): TVector; override;
  public
    constructor Create(const Matrix: TMatrix; const lLb, lUb: Integer);
      overload;
    constructor Create(const Matrix: TIntMatrix;
      const lLb, lUb: Integer); overload;
    destructor Destroy; override;
    function Solve(const B: TVector): TVector; override;
    function InverseMatrix: TMatrix;
    function Determinante: Float;
  end;

  TLU_Comp = class(TLU)
  private
    A: TCompMatrix;
  protected
    procedure _Decomp; reintroduce; overload;
    function _Solve(const B: TCompVector): TCompVector; reintroduce; overload;
  public
    constructor Create(const Matrix: TCompMatrix; const lLb, lUb: Integer);
    destructor Destroy; override;
    function Solve(const B: TCompVector): TCompVector; reintroduce; overload;
    function InverseMatrix: TCompMatrix;
    function Determinante: Complex;
  end;

implementation

uses uoperations, utypecasts;

{ ----------------------------------------------------------------------
  LU decomposition. Factors the square matrix A as a product L * U,
  where L is a lower triangular matrix (with unit diagonal terms) and U
  is an upper triangular matrix. This routine is used in conjunction
  with LU_Solve to solve a system of equations.
  ----------------------------------------------------------------------
  Input parameters : A  = matrix
  Lb = index of first matrix element
  Ub = index of last matrix element
  ----------------------------------------------------------------------
  Output parameter : A  = contains the elements of L and U
  ----------------------------------------------------------------------
  Possible results : MatOk
  MatSing
  ----------------------------------------------------------------------
  NB : This procedure destroys the original matrix A
  ---------------------------------------------------------------------- }

procedure TLU._Decomp;
var
  I, Imax, J, K: Integer;
  Pvt, T, Sum: Float;
  V: TVector;
begin
  { Reallocate Index if necessary }
  if Ub > InitDim then
  begin
    DelVector(Index);
    DimVector(Index, Ub);
    InitDim := Ub;
  end;

  Parity := true;
  DimVector(V, Ub);

  for I := Lb to Ub do
  begin
    Pvt := 0.0;
    for J := Lb to Ub do
      if Abs(A[I, J]) > Pvt then
        Pvt := Abs(A[I, J]);
    if Pvt < MachEp then
    begin
      DelVector(V);
      SetErrCode(MatSing);
      Exit;
    end;
    V[I] := 1.0 / Pvt;
  end;

  for J := Lb to Ub do
  begin
    for I := Lb to Pred(J) do
    begin
      Sum := A[I, J];
      for K := Lb to Pred(I) do
        Sum := Sum - A[I, K] * A[K, J];
      A[I, J] := Sum;
    end;
    Imax := 0;
    Pvt := 0.0;
    for I := J to Ub do
    begin
      Sum := A[I, J];
      for K := Lb to Pred(J) do
        Sum := Sum - A[I, K] * A[K, J];
      A[I, J] := Sum;
      T := V[I] * Abs(Sum);
      if T > Pvt then
      begin
        Pvt := T;
        Imax := I;
      end;
    end;
    if J <> Imax then
    begin
      for K := Lb to Ub do
        Swap(A[Imax, K], A[J, K]);
      Parity := not(Parity);
      V[Imax] := V[J];
    end;
    Index[J] := Imax;
    if A[J, J] = 0.0 then
      A[J, J] := MachEp;
    if J <> Ub then
    begin
      T := 1.0 / A[J, J];
      for I := Succ(J) to Ub do
        A[I, J] := A[I, J] * T;
    end;
  end;

  DelVector(V);
  SetErrCode(MatOk);
end;

procedure TLU_Comp._Decomp;
var
  I, Imax, J, K: Integer;
  Pvt, T: Float;
  Sum, Tc: Complex;
  V: TVector;
begin
  { Reallocate Index if necessary }
  if Ub > InitDim then
  begin
    DelVector(Index);
    DimVector(Index, Ub);
    InitDim := Ub;
  end;
  Parity := true;
  DimVector(V, Ub);
  { Loop over rows to get the implicit scaling information. }
  for I := Lb to Ub do
  begin
    Pvt := 0.0;
    for J := Lb to Ub do
      if A[I, J] = Pvt then
        Pvt := Abs(A[I, J]); // abs
    if Pvt < MachEp then
    begin
      DelVector(V);
      SetErrCode(MatSing);
      Exit; // No nonzero largest element.
    end;
    V[I] := 1 / Pvt;
  end;

  for J := Lb to Ub do
  begin
    for I := Lb to Pred(J) do
    begin
      Sum := A[I, J];
      for K := Lb to Pred(I) do
        Sum := (Sum - (A[I, K] * A[K, J]));
      A[I, J] := Sum;
    end;
    Imax := 0;
    Pvt := 0.0;
    for I := J to Ub do
    begin
      Sum := A[I, J];
      for K := Lb to Pred(J) do
        Sum := (Sum - (A[I, K] * A[K, J]));
      A[I, J] := Sum;
      T := V[I] * Abs(Sum);
      if T > Pvt then
      begin
        Pvt := T;
        Imax := I;
      end;
    end;
    if J <> Imax then
    begin
      for K := Lb to Ub do
        Swap(A[Imax, K], A[J, K]);
      Parity := not(Parity);
      V[Imax] := V[J];
    end;
    Index[J] := Imax;
    if A[J, J] = 0 then
      A[J, J] := MachEp;
    if J <> Ub then
    begin
      Tc := 1 / (A[J, J]);
      for I := Succ(J) to Ub do
        A[I, J] := (A[I, J] * Tc);
    end;
  end;

  DelVector(V);
  SetErrCode(MatOk);
end;

{ ------------------ LU_Solve ------------------------------------------
  Solves a system of equations whose matrix has been transformed by
  LU_Decomp
  ----------------------------------------------------------------------
  Input parameters : A      = result from LU_Decomp
  B      = results vector
  Lb, Ub = as in LU_Decomp
  ----------------------------------------------------------------------
  Output parameter : B      = solution vector
  ---------------------------------------------------------------------- }

function TLU._Solve(const B: TVector): TVector;
var
  I, Ip, J, K: Integer;
  Sum: Float;
begin
  K := Pred(Lb);
  for I := Lb to Ub do
  begin
    Ip := Index[I];
    Sum := B[Ip];
    B[Ip] := B[I];
    if K >= Lb then
      for J := K to Pred(I) do
        Sum := Sum - A[I, J] * B[J]
    else if Sum <> 0.0 then
      K := I;
    B[I] := Sum;
  end;

  for I := Ub downto Lb do
  begin
    Sum := B[I];
    if I < Ub then
      for J := Succ(I) to Ub do
        Sum := Sum - A[I, J] * B[J];
    B[I] := Sum / A[I, I];
  end;
end;

function TLU_Comp._Solve(const B: TCompVector): TCompVector;
var
  I, Ip, J, K: Integer;
  Sum: Complex;
begin
  K := Pred(Lb);
  for I := Lb to Ub do
  begin
    Ip := Index[I];
    Sum := B[Ip];
    B[Ip] := B[I];
    if K >= Lb then
    begin
      for J := K to Pred(I) do
        Sum := (Sum - (A[I, J] * B[J]));
    end
    else if not(Sum = 0) then
      K := I;
    B[I] := Sum;
  end;

  for I := Ub downto Lb do
  begin
    Sum := B[I];
    if I < Ub then
      for J := Succ(I) to Ub do
        Sum := (Sum - (A[I, J] * B[J]));
    B[I] := (Sum / A[I, I]);
  end;
end;

{ ----------------------------------------------------------------------
  Find the inverse of a Matrix using LU_Decomp
  ----------------------------------------------------------------------
  Input parameters : A      = Matrix M x M
  M      = Dimension
  ----------------------------------------------------------------------
  Output parameter : Result = Matrix Inverse
  ---------------------------------------------------------------------- }

function TLU.InverseMatrix: TMatrix;
var
  col: TVector;
  I, J: Integer;
begin
  DimMatrix(result, Ub, Ub);
  for J := Lb to Ub do
  begin // Find inverse by columns.
    DimVector(col, Ub);
    col[J] := 1;
    _Solve(col);
    for I := Lb to Ub do
      result[I, J] := col[I];
    DelVector(col);
  end;
  SetErrCode(MatOk);
end;

function TLU_Comp.InverseMatrix: TCompMatrix;
var
  col: TCompVector;
  I, J: Integer;
begin
  DimMatrix(result, Ub, Ub, 0);
  // LU_Decomp(A,1,M); //Decompose the matrix just once.
  for J := Lb to Ub do
  begin // Find inverse by columns.
    DimVector(col, Ub, 0);
    col[J] := 1;
    _Solve(col);
    for I := Lb to Ub do
      result[I, J] := col[I];
    DelVector(col);
  end;
  SetErrCode(MatOk);
end;

function TLU.Determinante: Float;
var
  J: Cardinal;
  d: Float;
begin
  // LU_Decomp(A,1,N);
  if Parity then
    d := 1
  else
    d := -1;
  for J := Lb to Ub do
    d := d * A[J, J];
  result := d;
end;

function TLU_Comp.Determinante: Complex;
var
  J: Cardinal;
  d: Complex;
begin
  // LU_Decomp(A,1,N);
  if Parity then
    d := 1
  else
    d := -1;
  for J := Lb to Ub do
    d := (d * A[J, J]);
  result := d;
end;

{ TLU }

constructor TLU.Create(const Matrix: TMatrix; const lLb, lUb: Integer);
begin
  inherited Create;
  InitDim := 10;
  Lb := lLb;
  Ub := lUb;
  DimVector(Index, InitDim);
  A := Clone(Matrix, Lb, Ub);
  _Decomp;
end;

constructor TLU.Create(const Matrix: TIntMatrix; const lLb, lUb: Integer);
begin
  inherited Create;
  InitDim := 10;
  Lb := lLb;
  Ub := lUb;
  DimVector(Index, InitDim);
  InttoFloat(Matrix, A, Lb, Ub);
  _Decomp;
end;

destructor TLU.Destroy;
begin
  DelMatrix(A);
  inherited Destroy;
end;

function TLU.Solve(const B: TVector): TVector;
begin
  _Solve(B);
end;

{ TLU_Comp }

constructor TLU_Comp.Create(const Matrix: TCompMatrix; const lLb, lUb: Integer);
begin
  inherited Create;
  InitDim := 10;
  Lb := lLb;
  Ub := lUb;
  DimVector(Index, InitDim);
  A := Clone(Matrix, Lb, Ub);
  _Decomp;
end;

destructor TLU_Comp.Destroy;
begin
  DelMatrix(A);
  inherited Destroy;
end;

function TLU_Comp.Solve(const B: TCompVector): TCompVector;
begin
  _Solve(B);
end;

end.
