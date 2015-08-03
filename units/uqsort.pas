{ ******************************************************************
  Quick sort
  ****************************************************************** }

unit uqsort;

interface

uses
  utypes;

procedure QSort(var X: TVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSort(var X: TVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

// all the following procedures are added by Alex Vergara Gil
procedure QSort(var X: TIntVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of integer vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSort(var X: TIntVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of integer vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSort(var X: TStrVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of string vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSort(var X: TStrVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of string vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortBy(var X, Data: TVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of vector X by the specified order of Vector Data
  and sorts the vector Data in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortBy(var X, Data: TVector; Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of vector X by the specified order of Vector Data
  and sorts the vector Data in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortBy(var X: TVector; var Data: TStrVector;
  Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of vector X by the specified order of string Vector Data
  and sorts the string vector Data in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortBy(var X: TVector; var Data: TStrVector;
  Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the elements of vector X by the specified order of string Vector Data
  and sorts the string vector Data in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixColumnsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a matrix M by the specified order of Vector X
  and sorts the vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixColumnsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a matrix M by the specified order of Vector X
  and sorts the vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixRowsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a matrix M by the specified order of Vector X
  and sorts the vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixRowsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a matrix M by the specified order of Vector X
  and sorts the vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixColumnsByIndex(var M: TMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a matrix M by the specified order of
  column Index in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixColumnsByIndex(var M: TMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a matrix M by the specified order of
  column Index in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixRowsByIndex(var M: TMatrix; Index, NumRows, NumCols, Lb,
  Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a matrix M by the specified order of
  row Index in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixRowsByIndex(var M: TMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a matrix M by the specified order of
  row Index in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixColumnsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a string matrix M by the specified order of string Vector X
  and sorts the string vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixColumnsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a string matrix M by the specified order of string Vector X
  and sorts the string vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixRowsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a string matrix M by the specified order of string Vector X
  and sorts the string vector X in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixRowsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a string matrix M by the specified order of string Vector X
  and sorts the string vector X in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixColumnsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a string matrix M by the specified order of
  column Index in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixColumnsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Columns of a string matrix M by the specified order of
  column Index in decreasing order (quick sort)
  ------------------------------------------------------------------ }

procedure QSortMatrixRowsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a string matrix M by the specified order of
  row Index in increasing order (quick sort)
  ------------------------------------------------------------------ }

procedure DQSortMatrixRowsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer); overload;
{ ------------------------------------------------------------------
  Sorts the Rows of a string matrix M by the specified order of
  row Index in decreasing order (quick sort)
  ------------------------------------------------------------------ }

implementation

uses uoperations, UMINMAX, urandom, uConstants;

procedure QSort(var X: TVector; Lb, Ub: Integer);
{ Quick sort in ascending order - Adapted from Borland's BP7 demo }
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Float;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] < U do
        I := I + 1;
      while U < X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure DQSort(var X: TVector; Lb, Ub: Integer);
{ Quick sort in descending order - Adapted from Borland's BP7 demo }
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Float;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] > U do
        I := I + 1;
      while U > X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure QSort(var X: TIntVector; Lb, Ub: Integer);
{ Quick sort in ascending order - Adapted from Borland's BP7 demo }
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Integer;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] < U do
        I := I + 1;
      while U < X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure DQSort(var X: TIntVector; Lb, Ub: Integer);
{ Quick sort in descending order - Adapted from Borland's BP7 demo }
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Integer;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] > U do
        I := I + 1;
      while U > X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure QSort(var X: TStrVector; Lb, Ub: Integer);
{ Quick sort in ascending order - Adapted from Borland's BP7 demo }
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: String;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] < U do
        I := I + 1;
      while U < X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure DQSort(var X: TStrVector; Lb, Ub: Integer);
{ Quick sort in descending order - Adapted from Borland's BP7 demo }
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: string;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] > U do
        I := I + 1;
      while U > X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure QSortBy(var X, Data: TVector; Lb, Ub: Integer);
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Float;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] < U do
        I := I + 1;
      while U < X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        V := Data[I];
        Data[I] := Data[J];
        Data[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure DQSortBy(var X, Data: TVector; Lb, Ub: Integer);
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Float;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] > U do
        I := I + 1;
      while U > X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        V := Data[I];
        Data[I] := Data[J];
        Data[J] := V;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure QSortBy(var X: TVector; var Data: TStrVector; Lb, Ub: Integer);
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Float;
    W: string;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] < U do
        I := I + 1;
      while U < X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        W := Data[I];
        Data[I] := Data[J];
        Data[J] := W;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure DQSortBy(var X: TVector; var Data: TStrVector; Lb, Ub: Integer);
var
  lRNG: TRandomGen;
  procedure Sort(L, R: Integer);
  var
    I, J: Integer;
    U, V: Float;
    W: string;
  begin
    I := L;
    J := R;
    // U := X[(L + R) div 2];
    U := X[lRNG.RandomMN(L, R)]; // Independent from input
    repeat
      while X[I] > U do
        I := I + 1;
      while U > X[J] do
        J := J - 1;
      if I <= J then
      begin
        V := X[I];
        X[I] := X[J];
        X[J] := V;
        W := Data[I];
        Data[I] := Data[J];
        Data[J] := W;
        I := I + 1;
        J := J - 1;
      end;
    until I > J;
    if L < J then
      Sort(L, J);
    if I < R then
      Sort(I, R);
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Sort(Lb, Ub);
  lRNG.Free;
end;

procedure QSortMatrixColumnsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TVector;
  I, J: Cardinal;
begin
  DimVector(index, NumCols);
  for I := 1 to NumCols do
    index[I] := I;
  QSortBy(index, X, Lb, Ub);
  for I := 1 to NumCols do
  begin
    DimVector(temp1, NumRows);
    for J := 1 to NumRows do
      temp1[J] := M[trunc(index[J]), I];
    CopyVectorToColumn(M, temp1, NumRows, I);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure DQSortMatrixColumnsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TVector;
  I, J: Cardinal;
begin
  DimVector(index, NumCols);
  for I := 1 to NumCols do
    index[I] := I;
  DQSortBy(index, X, Lb, Ub);
  for I := 1 to NumCols do
  begin
    DimVector(temp1, NumRows);
    for J := 1 to NumRows do
      temp1[J] := M[trunc(index[J]), I];
    CopyVectorToRow(M, temp1, NumRows, I);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure QSortMatrixRowsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TVector;
  I, J: Cardinal;
begin
  DimVector(index, NumRows);
  for I := 1 to NumRows do
    index[I] := I;
  QSortBy(index, X, Lb, Ub);
  for I := 1 to NumRows do
  begin
    DimVector(temp1, NumCols);
    for J := 1 to NumCols do
      temp1[J] := M[I, trunc(index[J])];
    CopyVectorToRow(M, temp1, I, NumCols);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure DQSortMatrixRowsByVector(var M: TMatrix; var X: TVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TVector;
  I, J: Cardinal;
begin
  DimVector(index, NumRows);
  for I := 1 to NumRows do
    index[I] := I;
  DQSortBy(index, X, Lb, Ub);
  for I := 1 to NumRows do
  begin
    DimVector(temp1, NumCols);
    for J := 1 to NumCols do
      temp1[J] := M[I, trunc(index[J])];
    CopyVectorToRow(M, temp1, I, NumCols);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure QSortMatrixColumnsByIndex(var M: TMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TVector;
begin
  indexs := ColumnToVector(M, NumRows, Index);
  QSortMatrixColumnsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure DQSortMatrixColumnsByIndex(var M: TMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TVector;
begin
  indexs := ColumnToVector(M, NumRows, Index);
  DQSortMatrixColumnsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure QSortMatrixRowsByIndex(var M: TMatrix; Index, NumRows, NumCols, Lb,
  Ub: Integer);
var
  indexs: TVector;
begin
  indexs := RowToVector(M, Index, NumCols);
  QSortMatrixRowsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure DQSortMatrixRowsByIndex(var M: TMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TVector;
begin
  indexs := RowToVector(M, Index, NumCols);
  DQSortMatrixRowsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure QSortMatrixColumnsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TStrVector;
  I, J: Cardinal;
begin
  DimVector(index, NumCols);
  for I := 1 to NumCols do
    index[I] := I;
  QSortBy(index, X, Lb, Ub);
  for I := 1 to NumCols do
  begin
    DimVector(temp1, NumRows);
    for J := 1 to NumRows do
      temp1[J] := M[trunc(index[J]), I];
    CopyVectorToColumn(M, temp1, NumRows, I);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure DQSortMatrixColumnsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TStrVector;
  I, J: Cardinal;
begin
  DimVector(index, NumCols);
  for I := 1 to NumCols do
    index[I] := I;
  DQSortBy(index, X, Lb, Ub);
  for I := 1 to NumCols do
  begin
    DimVector(temp1, NumRows);
    for J := 1 to NumRows do
      temp1[J] := M[trunc(index[J]), I];
    CopyVectorToColumn(M, temp1, NumRows, I);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure QSortMatrixRowsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TStrVector;
  I, J: Cardinal;
begin
  DimVector(index, NumRows);
  for I := 1 to NumRows do
    index[I] := I;
  QSortBy(index, X, Lb, Ub);
  for I := 1 to NumRows do
  begin
    DimVector(temp1, NumCols);
    for J := 1 to NumCols do
      temp1[J] := M[I, trunc(index[J])];
    CopyVectorToRow(M, temp1, I, NumCols);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure DQSortMatrixRowsByVector(var M: TStrMatrix; var X: TStrVector;
  NumRows, NumCols, Lb, Ub: Integer);
var
  Index: TVector;
  temp1: TStrVector;
  I, J: Cardinal;
begin
  DimVector(index, NumRows);
  for I := 1 to NumRows do
    index[I] := I;
  DQSortBy(index, X, Lb, Ub);
  for I := 1 to NumRows do
  begin
    DimVector(temp1, NumCols);
    for J := 1 to NumCols do
      temp1[J] := M[I, trunc(index[J])];
    CopyVectorToRow(M, temp1, I, NumCols);
    DelVector(temp1);
  end;
  DelVector(index);
end;

procedure QSortMatrixColumnsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TStrVector;
begin
  indexs := ColumnToVector(M, NumRows, Index);
  QSortMatrixColumnsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure DQSortMatrixColumnsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TStrVector;
begin
  indexs := ColumnToVector(M, NumRows, Index);
  DQSortMatrixColumnsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure QSortMatrixRowsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TStrVector;
begin
  indexs := RowToVector(M, Index, NumCols);
  QSortMatrixRowsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

procedure DQSortMatrixRowsByIndex(var M: TStrMatrix;
  Index, NumRows, NumCols, Lb, Ub: Integer);
var
  indexs: TStrVector;
begin
  indexs := RowToVector(M, Index, NumCols);
  DQSortMatrixRowsByVector(M, indexs, NumRows, NumCols, Lb, Ub);
  DelVector(indexs);
end;

end.
