{ ******************************************************************
  Solution of a system of linear equations by Gauss-Jordan method
  ****************************************************************** }

unit ugausjor;

interface

uses
  utypes, ulu, uConstants;

type
  TGaussJordan = class(TBaseDecomp)
  private
    A, Ainv: Tmatrix;
    Lb, Ub1, Ub2: Integer;
    Det: Float;
    FSolved: boolean;
    procedure SetSolved(const Value: boolean);
  protected
    procedure _Decomp; reintroduce;
    function _Solve(const B: Tmatrix): Tmatrix; reintroduce;
  public
    property Solved: boolean read FSolved write SetSolved;
    constructor Create(const Matrix: Tmatrix; const lLb, lUb: Integer);
      overload;
    constructor Create(const Matrix: TIntMatrix;
      const lLb, lUb: Integer); overload;
    destructor Destroy; override;
    function Solve(const B: Tmatrix; const lUb: Integer): Tmatrix;
      reintroduce; overload;
    function InverseMatrix: Tmatrix;
    function Determinante: Float;
  end;

implementation

uses uoperations, Math, uminmax;

constructor TGaussJordan.Create(const Matrix: TIntMatrix;
  const lLb, lUb: Integer);
begin
  inherited Create;
  Solved := false;
end;

constructor TGaussJordan.Create(const Matrix: Tmatrix; const lLb, lUb: Integer);
begin
  inherited Create;
  Solved := false;
  Lb := lLb;
  Ub1 := lUb;
  A := Clone(Matrix, Ub1, Ub1);
end;

destructor TGaussJordan.Destroy;
begin
  DelMatrix(A);
  if Solved then
    DelMatrix(Ainv);
  inherited Destroy;
end;

function TGaussJordan.Determinante: Float;
begin
  result := Det;
end;

function TGaussJordan.InverseMatrix: Tmatrix;
var
  tempb: Tmatrix;
begin
  if Solved then
    result := Ainv
  else
  begin
    DimMatrix(tempb, Ub1, 1);
    tempb[1, 1] := 1;
    Solve(tempb, 1);
  end;
end;

procedure TGaussJordan.SetSolved(const Value: boolean);
begin
  FSolved := Value;
end;

function TGaussJordan.Solve(const B: Tmatrix; const lUb: Integer): Tmatrix;
begin
  Ub2 := lUb;
  if not Solved then
    Ainv := Clone(A, Ub1, Ub1);
  result := _Solve(B);
  Solved := true;
end;

procedure TGaussJordan._Decomp;
{ ------------------------------------------------------------------
  Transforms a matrix according to the Gauss-Jordan method
  ------------------------------------------------------------------
  Input parameters : A        = system matrix
  Lb       = lower matrix bound in both dim.
  Ub1, Ub2 = upper matrix bounds
  ------------------------------------------------------------------
  Output parameters: A   = transformed matrix
  Det = determinant of A
  ------------------------------------------------------------------
  Possible results : MatOk     : No error
  MatErrDim : Non-compatible dimensions
  MatSing   : Singular matrix
  ------------------------------------------------------------------ }
var
  Pvt: Float; { Pivot }
  Ik, Jk: Integer; { Pivot's row and column }
  I, J, K: Integer; { Loop variables }
  T: Float; { Temporary variable }
  PRow, PCol: TIntVector; { Stores pivot's row and column }
  MCol: TVector; { Stores a column of matrix A }

  procedure Terminate(ErrCode: Integer);
  { Set error code and deallocate arrays }
  begin
    DelVector(PRow);
    DelVector(PCol);
    DelVector(MCol);
    SetErrCode(ErrCode);
  end;

begin
  { if Ub1 > Ub2 then      // this is for non sqare matrixes
    begin
    SetErrCode(MatErrDim);
    Exit
    end; }

  DimVector(PRow, Ub1);
  DimVector(PCol, Ub1);
  DimVector(MCol, Ub1);

  Det := 1.0;

  K := Lb;
  while K <= Ub1 do
  begin
    { Search for largest pivot in submatrix A[K..Ub1, K..Ub1] }
    Pvt := A[K, K];
    Ik := K;
    Jk := K;
    for I := K to Ub1 do
      for J := K to Ub1 do
        if Abs(A[I, J]) > Abs(Pvt) then
        begin
          Pvt := A[I, J];
          Ik := I;
          Jk := J;
        end;

    { Store pivot's position }
    PRow[K] := Ik;
    PCol[K] := Jk;

    { Update determinant }
    Det := Det * Pvt;
    if Ik <> K then
      Det := -Det;
    if Jk <> K then
      Det := -Det;

    { Too weak pivot ==> quasi-singular matrix }
    if Abs(Pvt) < MachEp then
    begin
      Terminate(MatSing);
      Exit
    end;

    { Exchange current row (K) with pivot row (Ik) }
    if Ik <> K then
      for J := Lb to Ub1 do
        Swap(A[Ik, J], A[K, J]);

    { Exchange current column (K) with pivot column (Jk) }
    if Jk <> K then
      for I := Lb to Ub1 do
        Swap(A[I, Jk], A[I, K]);

    { Store column K of matrix A into MCol
      and set this column to zero }
    for I := Lb to Ub1 do
      if I <> K then
      begin
        MCol[I] := A[I, K];
        A[I, K] := 0.0;
      end
      else
      begin
        MCol[I] := 0.0;
        A[I, K] := 1.0;
      end;

    { Transform pivot row }
    T := 1.0 / Pvt;
    for J := Lb to Ub1 do
      A[K, J] := T * A[K, J];

    { Transform other rows }
    for I := Lb to Ub1 do
      if I <> K then
      begin
        T := MCol[I];
        for J := Lb to Ub1 do
          A[I, J] := A[I, J] - T * A[K, J];
      end;

    Inc(K);
  end;

  { Exchange lines of inverse matrix }
  for I := Ub1 downto Lb do
  begin
    Ik := PCol[I];
    if Ik <> I then
      for J := Lb to Ub1 do
        Swap(A[I, J], A[Ik, J]);
  end;

  { Exchange columns of inverse matrix }
  for J := Ub1 downto Lb do
  begin
    Jk := PRow[J];
    if Jk <> J then
      for I := Lb to Ub1 do
        Swap(A[I, J], A[I, Jk]);
  end;

  Terminate(MatOk);
end;

function TGaussJordan._Solve(const B: Tmatrix): Tmatrix;
{ Linear equation solution by Gauss-Jordan elimination, equation (2.1.1) above. a[1..Ub1][1..Ub1]
  is the input matrix. b[1..Ub1][1..Ub2] is input containing the m right-hand side vectors. On
  output, a is replaced by its matrix inverse, and b is replaced by the corresponding set of solution
  vectors. }
var
  indxc, indxr, ipiv: TIntVector;
  I, icol, irow, J, K, l, ll: Integer;
  big, dum, pivinv: Float;
  res: Tmatrix;
begin
  icol := 0;
  irow := 0;

  DimVector(indxc, Ub1);
  // The integer arrays ipiv, indxr, and indxc are used for bookkeeping on the pivoting.
  DimVector(indxr, Ub1);
  DimVector(ipiv, Ub1);
  res := Clone(B, Ub1, Ub2);
  for J := 1 to Ub1 do
    ipiv[J] := 0; // esto se hace al crear
  for I := 1 to Ub1 do
  begin // This is the main loop over the columns to be reduced.
    big := 0.0;
    for J := 1 to Ub1 do
      // This is the outer loop of the search for a pivot element.
      if (ipiv[J] <> 1) then
        for K := 1 to Ub1 do
        begin
          if (ipiv[K] = 0) then
          begin
            if (Abs(Ainv[J, K]) >= big) then
            begin
              big := Abs(Ainv[J, K]);
              irow := J;
              icol := K;
            end;
          end;
        end;
    Inc(ipiv[icol]);
    { We now have the pivot element, so we interchange rows, if needed, to put the pivot
      element on the diagonal. The columns are not physically interchanged, only relabeled:
      indxc[i], the column of the ith pivot element, is the ith column that is reduced, while
      indxr[i] is the row in which that pivot element was originally located. If indxr[i] =
      indxc[i] there is an implied column interchange. With this form of bookkeeping, the
      solution b’s will end up in the correct order, and the inverse matrix will be scrambled
      by columns. }
    if (irow <> icol) then
    begin
      TraspondRows(Ainv, irow, icol, Ub1);
      TraspondRows(res, irow, icol, Ub2);
    end;
    indxr[I] := irow;
    // We are now ready to divide the pivot row by the pivot element, located at irow and icol.
    indxc[I] := icol;
    if (Ainv[icol, icol] <= MinExtended) then
    begin
      SetErrCode(MatSing);
      Exit;
    end; // nrerror("gaussj: Singular Matrix");
    pivinv := 1.0 / A[icol, icol];
    Ainv[icol, icol] := 1;
    for l := 1 to Ub1 do
      Ainv[icol, l] := Ainv[icol, l] * pivinv;
    for l := 1 to Ub2 do
      res[icol, l] := res[icol, l] * pivinv;
    for ll := 1 to Ub1 do // Next, we reduce the rows...
      if (ll <> icol) then
      begin // ...except for the pivot one, of course.
        dum := Ainv[ll, icol];
        Ainv[ll, icol] := 0;
        for l := 1 to Ub1 do
          Ainv[ll, l] := Ainv[ll, l] - Ainv[icol, l] * dum;
        for l := 1 to Ub2 do
          res[ll, l] := res[ll, l] - res[icol, l] * dum;
      end;
  end;
  { This is the end of the main loop over columns of the reduction. It only remains to unscramble
    the solution in view of the column interchanges. We do this by interchanging pairs of
    columns in the reverse order that the permutation was built up. }
  for l := Ub1 downto 1 do
  begin
    if (indxr[l] <> indxc[l]) then
      TraspondColumns(Ainv, indxr[l], indxc[l], Ub1);
  end; // And we are done.
  result := res;
  DelVector(ipiv);
  DelVector(indxc);
  DelVector(indxr);
end;

end.
