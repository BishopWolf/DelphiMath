{ ******************************************************************
  QR decomposition

  Ref.: 'Matrix Computations' by Golub & Van Loan
  Pascal implementation contributed by Mark Vaughan
  ****************************************************************** }

unit uqr;

interface

uses
  utypes, ulu;

type
  TQR = class(TBaseDecomp)
  private
    Q, R: TMatrix;
    Lb, Ub1, Ub2: integer;
    procedure _Decomp; override;
    function _Solve(const B: TVector): TVector; override;
  public
    constructor Create(const Matrix: TMatrix;
      const lLb, lUb1, lUb2: integer); overload;
    constructor Create(const Matrix: TIntMatrix;
      const lLb, lUb1, lUb2: integer); overload;
    destructor Destroy; override;
    function Solve(const B: TVector): TVector; override;
  end;

implementation

uses uoperations, utypecasts, umachar, uConstants;

{ ------------------------------------------------------------------
  QR decomposition. Factors the matrix A (n x m, with n >= m) as a
  product Q * R where Q is a (n x m) column-orthogonal matrix, and R
  a (m x m) upper triangular matrix. This routine is used in
  conjunction with QR_Solve to solve a system of equations.
  ------------------------------------------------------------------
  Input parameters : A   = matrix
  Lb  = index of first matrix element
  Ub1 = index of last matrix element in 1st dim.
  Ub2 = index of last matrix element in 2nd dim.
  ------------------------------------------------------------------
  Output parameter : A   = contains the elements of Q
  R   = upper triangular matrix
  ------------------------------------------------------------------
  Possible results : MatOk
  MatErrDim
  MatSing
  ------------------------------------------------------------------
  NB : This procedure destroys the original matrix A
  ------------------------------------------------------------------ }

procedure TQR._Decomp;
var
  I, J, K: integer;
  Sum: Float;
begin
  if Ub2 > Ub1 then
  begin
    SetErrCode(MatErrDim);
    Exit
  end;

  DimMatrix(R, Ub2, Ub2);
  for K := Lb to Ub2 do
  begin
    { Compute the "k"th diagonal entry in R }
    Sum := 0.0;
    for I := Lb to Ub1 do
      Sum := Sum + Sqr(Q[I, K]);

    if Sum = 0.0 then
    begin
      SetErrCode(MatSing);
      Exit;
    end;

    R[K, K] := Sqrt(Sum);

    { Divide the entries in the "k"th column of A by the computed "k"th }
    { diagonal element of R.  this begins the process of overwriting A }
    { with Q . . . }
    for I := Lb to Ub1 do
      Q[I, K] := Q[I, K] / R[K, K];

    for J := (K + 1) to Ub2 do
    begin
      { Complete the remainder of the row entries in R }
      Sum := 0.0;
      for I := Lb to Ub1 do
        Sum := Sum + Q[I, K] * Q[I, J];
      R[K, J] := Sum;

      { Update the column entries of the Q/A matrix }
      for I := Lb to Ub1 do
        Q[I, J] := Q[I, J] - Q[I, K] * R[K, J];
    end;
  end;

  SetErrCode(MatOk);
end;

{ ------------------------------------------------------------------
  Solves a system of equations by the QR decomposition,
  after the matrix has been transformed by QR_Decomp.
  ------------------------------------------------------------------
  Input parameters : Q, R         = matrices from QR_Decomp
  B            = constant vector
  Lb, Ub1, Ub2 = as in QR_Decomp
  ------------------------------------------------------------------
  Output parameter : X            = solution vector
  ------------------------------------------------------------------ }

function TQR._Solve(const B: TVector): TVector;
var
  I, J: integer;
  Sum: Float;
  X: TVector;
begin
  { Form Q'B and store the result in X }
  DimVector(X, Ub2);
  for J := Lb to Ub2 do
  begin
    X[J] := 0.0;
    for I := Lb to Ub1 do
      X[J] := X[J] + Q[I, J] * B[I];
  end;

  { Update X with the solution vector }
  X[Ub2] := X[Ub2] / R[Ub2, Ub2];
  for I := (Ub2 - 1) downto Lb do
  begin
    Sum := 0.0;
    for J := (I + 1) to Ub2 do
      Sum := Sum + R[I, J] * X[J];
    X[I] := (X[I] - Sum) / R[I, I];
  end;

  Result := X;
end;

{ TQR }

constructor TQR.Create(const Matrix: TMatrix; const lLb, lUb1, lUb2: integer);
begin
  inherited Create;
  Q := Clone(Matrix, Ub1, Ub2);
  Lb := Lb;
  Ub1 := lUb1;
  Ub2 := lUb2;
  _Decomp;
end;

constructor TQR.Create(const Matrix: TIntMatrix;
  const lLb, lUb1, lUb2: integer);
begin
  inherited Create;
  InttoFloat(Matrix, Q, Ub1, Ub2);
  Lb := Lb;
  Ub1 := lUb1;
  Ub2 := lUb2;
  _Decomp;
end;

destructor TQR.Destroy;
begin
  DelMatrix(Q);
  DelMatrix(R);
  inherited Destroy;
end;

function TQR.Solve(const B: TVector): TVector;
begin
  Result := _Solve(B);
end;

end.
