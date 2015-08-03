Unit uoperations;

{ Unit uoperations : array operations Unit

  Created by : Alex Vergara Gil

  Contains the routines for handling arrays.

}

Interface

Uses utypes, uComplex, urandom, uConstants;

{ ------------------------------------------------------------------
  Clone arrays
  ------------------------------------------------------------------ }
Function Clone(inVector: tVector; Ub: Integer): tVector; Overload;
Function Clone(inVector: TIntVector; Ub: Integer): TIntVector; Overload;
Function Clone(inVector: TWordVector; Ub: Integer): TWordVector; Overload;
Function Clone(inVector: TBoolVector; Ub: Integer): TBoolVector; Overload;
Function Clone(inVector: TCompVector; Ub: Integer): TCompVector; Overload;
Function Clone(inVector: TStrVector; Ub: Integer): TStrVector; Overload;
Function Clone(inMatrix: TMatrix; Ub1, Ub2: Integer): TMatrix; Overload;
Function Clone(inMatrix: TIntMatrix; Ub1, Ub2: Integer): TIntMatrix; Overload;
Function Clone(inMatrix: TBoolMatrix; Ub1, Ub2: Integer): TBoolMatrix; Overload;
Function Clone(inMatrix: TCompMatrix; Ub1, Ub2: Integer): TCompMatrix; Overload;
Function Clone(inMatrix: TStrMatrix; Ub1, Ub2: Integer): TStrMatrix; Overload;
Function Clone(in3DMatrix: T3DMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DMatrix; Overload;
Function Clone(in3DMatrix: T3DIntMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix; Overload;
Function Clone(in3DMatrix: T3DBoolMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DBoolMatrix; Overload;
Function Clone(in3DMatrix: T3DCompMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DCompMatrix; Overload;
Function Clone(in3DMatrix: T3DStrMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DStrMatrix; Overload;

{ ------------------------------------------------------------------
  Basic operations with arrays
  ------------------------------------------------------------------ }

Function Traspose(Const A: TMatrix; Ub1, Ub2: Integer): TMatrix; Overload;
Function Traspose(Const A: TIntMatrix; Ub1, Ub2: Integer): TIntMatrix; Overload;
Function Traspose(Const A: TBoolMatrix; Ub1, Ub2: Integer)
  : TBoolMatrix; Overload;
Function Traspose(Const A: TCompMatrix; Ub1, Ub2: Integer)
  : TCompMatrix; Overload;
Function Traspose(Const A: TStrMatrix; Ub1, Ub2: Integer): TStrMatrix; Overload;

Procedure TraspondRows(A: TMatrix; row1, row2, RowSize: Integer);
Procedure TraspondColumns(A: TMatrix; col1, col2, ColSize: Integer);

Function XYZtoZYX(A: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;
Function XYZtoZXY(A: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;
Function XYZtoYZX(A: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;

Function Contar(A: TMatrix; Ub1, Ub2: Integer; distinto: float): Integer;
Function Reform(A: TMatrix; Ub1, Ub2: Integer; Filas, Columnas: Integer;
  missing: float; Out nummissing: Integer): TMatrix;

{ ------------------------------------------------------------------
  Sum and rest operations with arrays
  ------------------------------------------------------------------ }

Procedure Suma(Var Vector1: tVector; Vector2: tVector; Ub: Integer); Overload;
Procedure Suma(Var Vector1: TIntVector; Vector2: TIntVector;
  Ub: Integer); Overload;
Procedure Suma(Var Vector1: TBoolVector; Vector2: TBoolVector;
  Ub: Integer); Overload;
Procedure Suma(Var Vector1: TCompVector; Vector2: TCompVector;
  Ub: Integer); Overload;
Procedure Suma(Var Vector1: TStrVector; Vector2: TStrVector;
  Ub: Integer); Overload;

Procedure Resta(Var Vector1: tVector; Vector2: tVector; Ub: Integer); Overload;
Procedure Resta(Var Vector1: TIntVector; Vector2: TIntVector;
  Ub: Integer); Overload;
Procedure Resta(Var Vector1: TBoolVector; Vector2: TBoolVector;
  Ub: Integer); Overload;
Procedure Resta(Var Vector1: TCompVector; Vector2: TCompVector;
  Ub: Integer); Overload;
Procedure Resta(Var Vector1: TStrVector; Vector2: TStrVector;
  Ub: Integer); Overload;

Procedure Suma(Var MATRIZ1: TMatrix; MATRIZ2: TMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Suma(Var MATRIZ1: TIntMatrix; MATRIZ2: TIntMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Suma(Var MATRIZ1: TBoolMatrix; MATRIZ2: TBoolMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Suma(Var MATRIZ1: TCompMatrix; MATRIZ2: TCompMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Suma(Var MATRIZ1: TStrMatrix; MATRIZ2: TStrMatrix;
  Ub1, Ub2: Integer); Overload;

Procedure Resta(Var MATRIZ1: TMatrix; MATRIZ2: TMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Resta(Var MATRIZ1: TIntMatrix; MATRIZ2: TIntMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Resta(Var MATRIZ1: TBoolMatrix; MATRIZ2: TBoolMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Resta(Var MATRIZ1: TCompMatrix; MATRIZ2: TCompMatrix;
  Ub1, Ub2: Integer); Overload;
Procedure Resta(Var MATRIZ1: TStrMatrix; MATRIZ2: TStrMatrix;
  Ub1, Ub2: Integer); Overload;

Procedure Suma(Var MATRIZ1: T3DMatrix; MATRIZ2: T3DMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Suma(Var MATRIZ1: T3DIntMatrix; MATRIZ2: T3DIntMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Suma(Var MATRIZ1: T3DBoolMatrix; MATRIZ2: T3DBoolMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Suma(Var MATRIZ1: T3DCompMatrix; MATRIZ2: T3DCompMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Suma(Var MATRIZ1: T3DStrMatrix; MATRIZ2: T3DStrMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;

Procedure Resta(Var MATRIZ1: T3DMatrix; MATRIZ2: T3DMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Resta(Var MATRIZ1: T3DIntMatrix; MATRIZ2: T3DIntMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Resta(Var MATRIZ1: T3DBoolMatrix; MATRIZ2: T3DBoolMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Resta(Var MATRIZ1: T3DCompMatrix; MATRIZ2: T3DCompMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;
Procedure Resta(Var MATRIZ1: T3DStrMatrix; MATRIZ2: T3DStrMatrix;
  Ub1, Ub2, Ub3: Integer); Overload;

Function FSuma(Vector1, Vector2: tVector; Ub: Integer): tVector; Overload;
Function FSuma(Vector1, Vector2: TIntVector; Ub: Integer): TIntVector; Overload;
Function FSuma(Vector1, Vector2: TBoolVector; Ub: Integer)
  : TBoolVector; Overload;
Function FSuma(Vector1, Vector2: TCompVector; Ub: Integer)
  : TCompVector; Overload;
Function FSuma(Vector1, Vector2: TStrVector; Ub: Integer): TStrVector; Overload;

Function FResta(Vector1, Vector2: tVector; Ub: Integer): tVector; Overload;
Function FResta(Vector1, Vector2: TIntVector; Ub: Integer): TIntVector;
  Overload;
Function FResta(Vector1, Vector2: TBoolVector; Ub: Integer)
  : TBoolVector; Overload;
Function FResta(Vector1, Vector2: TCompVector; Ub: Integer)
  : TCompVector; Overload;
Function FResta(Vector1, Vector2: TStrVector; Ub: Integer): TStrVector;
  Overload;

Function FSuma(MATRIZ1, MATRIZ2: TMatrix; Ub1, Ub2: Integer): TMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: TIntMatrix; Ub1, Ub2: Integer)
  : TIntMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: TBoolMatrix; Ub1, Ub2: Integer)
  : TBoolMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: TCompMatrix; Ub1, Ub2: Integer)
  : TCompMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: TStrMatrix; Ub1, Ub2: Integer)
  : TStrMatrix; Overload;

Function FResta(MATRIZ1, MATRIZ2: TMatrix; Ub1, Ub2: Integer): TMatrix;
  Overload;
Function FResta(MATRIZ1, MATRIZ2: TIntMatrix; Ub1, Ub2: Integer)
  : TIntMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: TBoolMatrix; Ub1, Ub2: Integer)
  : TBoolMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: TCompMatrix; Ub1, Ub2: Integer)
  : TCompMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: TStrMatrix; Ub1, Ub2: Integer)
  : TStrMatrix; Overload;

Function FSuma(MATRIZ1, MATRIZ2: T3DMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: T3DIntMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: T3DBoolMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DBoolMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: T3DCompMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DCompMatrix; Overload;
Function FSuma(MATRIZ1, MATRIZ2: T3DStrMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DStrMatrix; Overload;

Function FResta(MATRIZ1, MATRIZ2: T3DMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: T3DIntMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: T3DBoolMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DBoolMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: T3DCompMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DCompMatrix; Overload;
Function FResta(MATRIZ1, MATRIZ2: T3DStrMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DStrMatrix; Overload;

{ ------------------------------------------------------------------
  Fast Multiplication operations with arrays
  ------------------------------------------------------------------ }

Function DotProduct(Const Vector1, Vector2: tVector; Ub: Integer)
  : float; Overload;
Function DotProduct(Const Vector1, Vector2: TIntVector; Ub: Integer)
  : Integer; Overload;
Function DotProduct(Const Vector1, Vector2: TCompVector; Ub: Integer)
  : Complex; Overload;
Function DotProduct(Const Vector1, Vector2: TBoolVector; Ub: Integer)
  : Boolean; Overload;
Function FVSquare(Const Vector: tVector; Ub: Integer): float;
Procedure MultiplyByNumber(Var Vector: tVector; Ub: Integer;
  Number: float); Overload;
Procedure MultiplyByNumber(Var Matrix: TMatrix; Ub1, Ub2: Integer;
  Number: float); Overload;
Procedure MultiplyByNumber(Var Matrix: T3DMatrix; Ub1, Ub2, Ub3: Integer;
  Number: float); Overload;
Function Multiply(Const MATRIZ1, MATRIZ2: TMatrix; Ub1, Ub2, Ub3: Integer)
  : TMatrix; Overload;
Function Multiply(Const MATRIZ1, MATRIZ2: TIntMatrix; Ub1, Ub2, Ub3: Integer)
  : TIntMatrix; Overload;
Function Multiply(Const MATRIZ1, MATRIZ2: TBoolMatrix; Ub1, Ub2, Ub3: Integer)
  : TBoolMatrix; Overload;
Function Multiply(Const MATRIZ1, MATRIZ2: TCompMatrix; Ub1, Ub2, Ub3: Integer)
  : TCompMatrix; Overload;

{ ------------------------------------------------------------------
  Fast column/row insertion/extraction to/from matrixes
  ------------------------------------------------------------------ }

Function ColumnToVector(Const Matrix: TMatrix; Rows, index: Integer)
  : tVector; Overload;
Function RowToVector(Const Matrix: TMatrix; index, Columns: Integer)
  : tVector; Overload;
Function ColumnToVector(Const Matrix: TStrMatrix; Rows, index: Integer)
  : TStrVector; Overload;
Function RowToVector(Const Matrix: TStrMatrix; index, Columns: Integer)
  : TStrVector; Overload;
Procedure CopyVectorToColumn(Var Matrix: TMatrix; Const V: tVector;
  Rows, index: Integer); Overload;
Procedure CopyVectorToRow(Var Matrix: TMatrix; Const V: tVector;
  index, Columns: Integer); Overload;
Procedure CopyVectorToColumn(Var Matrix: TStrMatrix; Const V: TStrVector;
  Rows, index: Integer); Overload;
Procedure CopyVectorToRow(Var Matrix: TStrMatrix; Const V: TStrVector;
  index, Columns: Integer); Overload;

{ ------------------------------------------------------------------
  Append Procedures
  ------------------------------------------------------------------ }

Procedure Append(Var Vector: tVector; Var Ub: Integer; Value: float); Overload;
Procedure Append(Var Vector: TIntVector; Var Ub: Integer;
  Value: Integer); Overload;
Procedure Append(Var Vector: TBoolVector; Var Ub: Integer;
  Value: Boolean); Overload;
Procedure Append(Var Vector: TStrVector; Var Ub: Integer;
  Value: String); Overload;
Procedure Append(Var Vector: TCompVector; Var Ub: Integer;
  Value: Complex); Overload;

{ ------------------------------------------------------------------
  Percolation Procedures
  ------------------------------------------------------------------ }

Procedure Percolar(Matriz: TMatrix; Ub1, Ub2, I, J: Integer; RNG: TRandomGen;
  EPS, Oracle: float; Out trial_row, trial_col: TIntVector;
  Out Dim: Integer); Overload;
Procedure Percolar(Matriz: TIntMatrix; Ub1, Ub2, I, J: Integer; RNG: TRandomGen;
  EPS, Oracle: float; Out trial_row, trial_col: TIntVector;
  Out Dim: Integer); Overload;
Procedure Percolar(Matriz: T3DMatrix; Ub1, Ub2, Ub3, I, J, K: Integer;
  RNG: TRandomGen; EPS, Oracle: float; Out trial_row, trial_col,
  trial_order: TIntVector; Out Dim: Integer); Overload;
Procedure Percolar(Matriz: T3DIntMatrix; Ub1, Ub2, Ub3, I, J, K: Integer;
  RNG: TRandomGen; EPS, Oracle: float; Out trial_row, trial_col,
  trial_order: TIntVector; Out Dim: Integer); Overload;

{ ------------------------------------------------------------------
  Redimension Procedures
  ------------------------------------------------------------------ }

Function ResizeV(Vector: tVector; m, Ub: Integer): tVector; Overload;
Function ResizeM(Matriz: TMatrix; m, n, Ub1, Ub2: Integer): TMatrix; Overload;
Function Resize3DM(Matriz: T3DMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DMatrix; Overload;

Function ResizeV_Lineal(Vector: tVector; m, Ub: Integer): tVector; Overload;
Function ResizeM_Lineal(Matriz: TMatrix; m, n, Ub1, Ub2: Integer)
  : TMatrix; Overload;
Function Resize3DM_Lineal(Matriz: T3DMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DMatrix; Overload;

Function ResizeV(Vector: TIntVector; m, Ub: Integer): TIntVector; Overload;
Function ResizeM(Matriz: TIntMatrix; m, n, Ub1, Ub2: Integer)
  : TIntMatrix; Overload;
Function Resize3DM(Matriz: T3DIntMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix; Overload;

Function ResizeV_Lineal(Vector: TIntVector; m, Ub: Integer)
  : TIntVector; Overload;
Function ResizeM_Lineal(Matriz: TIntMatrix; m, n, Ub1, Ub2: Integer)
  : TIntMatrix; Overload;
Function Resize3DM_Lineal(Matriz: T3DIntMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix; Overload;

Implementation

Uses uminmax, sysutils, rtlConsts, umemory, ustrings, uinterpolation, Math,
  uspline, utypecasts, uround;

Function Clone(inVector: tVector; Ub: Integer): tVector;
Var
  I: Integer;
Begin
  { Allocate vector }
  setlength(Result, Ub + 1);
  If Result = Nil Then
    Exit;

  { Initialize vector }
  For I := 0 To Ub Do
    Result[I] := inVector[I];
End;

Function Clone(inVector: TIntVector; Ub: Integer): TIntVector;
Var
  I: Integer;
Begin
  { Allocate vector }
  setlength(Result, Ub + 1);
  If Result = Nil Then
    Exit;

  { Initialize vector }
  For I := 0 To Ub Do
    Result[I] := inVector[I];
End;

Function Clone(inVector: TWordVector; Ub: Integer): TWordVector;
Var
  I: Integer;
Begin
  { Allocate vector }
  setlength(Result, Ub + 1);
  If Result = Nil Then
    Exit;

  { Initialize vector }
  For I := 0 To Ub Do
    Result[I] := inVector[I];
End;

Function Clone(inVector: TBoolVector; Ub: Integer): TBoolVector;
Var
  I: Integer;
Begin
  { Allocate vector }
  setlength(Result, Ub + 1);
  If Result = Nil Then
    Exit;

  { Initialize vector }
  For I := 0 To Ub Do
    Result[I] := inVector[I];
End;

Function Clone(inVector: TCompVector; Ub: Integer): TCompVector;
Var
  I: Integer;
Begin
  { Allocate vector }
  setlength(Result, Ub + 1);
  If Result = Nil Then
    Exit;

  { Initialize vector }
  For I := 0 To Ub Do
  Begin
    Result[I] := CloneComplex(inVector[I]);
  End;
End;

Function Clone(inVector: TStrVector; Ub: Integer): TStrVector;
Var
  I: Integer;
Begin
  { Allocate vector }
  setlength(Result, Ub + 1);
  If Result = Nil Then
    Exit;

  { Initialize vector }
  For I := 0 To Ub Do
    Result[I] := inVector[I];
End;

Function Clone(inMatrix: TMatrix; Ub1, Ub2: Integer): TMatrix;
Var
  I: Integer;
Begin
  { Allocate matrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(inMatrix[I], Ub2); // here each row is already allocated
End;

Function Clone(inMatrix: TIntMatrix; Ub1, Ub2: Integer): TIntMatrix;
Var
  I: Integer;
Begin
  { Allocate matrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(inMatrix[I], Ub2);
End;

Function Clone(inMatrix: TBoolMatrix; Ub1, Ub2: Integer): TBoolMatrix;
Var
  I: Integer;
Begin
  { Allocate matrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(inMatrix[I], Ub2);
End;

Function Clone(inMatrix: TCompMatrix; Ub1, Ub2: Integer): TCompMatrix;
Var
  I: Integer;
Begin
  { Allocate matrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(inMatrix[I], Ub2);
End;

Function Clone(inMatrix: TStrMatrix; Ub1, Ub2: Integer): TStrMatrix;
Var
  I: Integer;
Begin
  { Allocate matrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(inMatrix[I], Ub2);
End;

Function Clone(in3DMatrix: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;
Var
  I: Integer;
Begin
  { Allocate 3Dmatrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(in3DMatrix[I], Ub2, Ub3);
End;

Function Clone(in3DMatrix: T3DIntMatrix; Ub1, Ub2, Ub3: Integer): T3DIntMatrix;
Var
  I: Integer;
Begin
  { Allocate 3Dmatrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(in3DMatrix[I], Ub2, Ub3);
End;

Function Clone(in3DMatrix: T3DBoolMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DBoolMatrix;
Var
  I: Integer;
Begin
  { Allocate 3Dmatrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(in3DMatrix[I], Ub2, Ub3);
End;

Function Clone(in3DMatrix: T3DCompMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DCompMatrix;
Var
  I: Integer;
Begin
  { Allocate 3Dmatrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(in3DMatrix[I], Ub2, Ub3);
End;

Function Clone(in3DMatrix: T3DStrMatrix; Ub1, Ub2, Ub3: Integer): T3DStrMatrix;
Var
  I: Integer;
Begin
  { Allocate 3Dmatrix }
  setlength(Result, Ub1 + 1);
  If Result = Nil Then
    Exit;

  { Initialize matrix }
  For I := 0 To Ub1 Do
    Result[I] := Clone(in3DMatrix[I], Ub2, Ub3);
End;

Function Traspose(Const A: TMatrix; Ub1, Ub2: Integer): TMatrix;
Var
  I, J: Integer;
Begin
  DimMatrix(Result, Ub2, Ub1);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      Result[J, I] := A[I, J];
End;

Function Traspose(Const A: TIntMatrix; Ub1, Ub2: Integer): TIntMatrix;
Var
  I, J: Integer;
Begin
  DimMatrix(Result, Ub2, Ub1);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      Result[J, I] := A[I, J];
End;

Function Traspose(Const A: TBoolMatrix; Ub1, Ub2: Integer): TBoolMatrix;
Var
  I, J: Integer;
Begin
  DimMatrix(Result, Ub2, Ub1);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      Result[J, I] := A[I, J];
End;

Function Traspose(Const A: TCompMatrix; Ub1, Ub2: Integer): TCompMatrix;
Var
  I, J: Integer;
Begin
  DimMatrix(Result, Ub2, Ub1, 0);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
    Begin
      Result[J, I] := Conjugate(A[I, J]);
    End;
End;

Function Traspose(Const A: TStrMatrix; Ub1, Ub2: Integer): TStrMatrix;
Var
  I, J: Integer;
Begin
  DimMatrix(Result, Ub2, Ub1);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      Result[J, I] := A[I, J];
End;

Function Contar(A: TMatrix; Ub1, Ub2: Integer; distinto: float): Integer;
Var
  I, J, cont: Integer;
Begin
  cont := 0;
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      If A[I, J] <> distinto Then
        inc(cont);
  Result := cont;
End;

Function Reform(A: TMatrix; Ub1, Ub2: Integer; Filas, Columnas: Integer;
  missing: float; Out nummissing: Integer): TMatrix;
Var
  res: TMatrix;
  I, J, cont1, cont2: Integer;
Begin
  DimMatrix(res, Filas, Columnas);
  cont1 := 0;
  cont2 := 0;
  nummissing := 0;
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      If A[I, J] <> missing Then
      Begin
        If cont1 < Filas Then
        Begin
          inc(cont1);
          If cont2 <= Columnas Then
          Begin
            res[cont1, cont2] := A[I, J];
          End;
        End
        Else
        Begin
          inc(cont2);
          cont1 := 1;
          If cont2 <= Columnas Then
          Begin
            res[cont1, cont2] := A[I, J];
          End;
          If (cont1 = Filas) And (cont2 = Columnas) Then
            break;
        End;
      End
      Else
      Begin
        inc(nummissing);
      End;
  If Ub1 * Ub2 < Filas * Columnas Then
  Begin
    cont1 := Filas;
    cont2 := Columnas;
    For I := 1 To nummissing Do
    Begin
      res[cont1, cont2] := missing;
      dec(cont2);
      If cont2 = 0 Then
      Begin
        cont2 := Columnas;
        dec(cont1);
      End;
    End;
  End;
  Result := res;
End;

Procedure Suma(Var Vector1: tVector; Vector2: tVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] + Vector2[I];
End;

Procedure Suma(Var Vector1: TIntVector; Vector2: TIntVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] + Vector2[I];
End;

Procedure Suma(Var Vector1: TBoolVector; Vector2: TBoolVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] Or Vector2[I];
End;

Procedure Suma(Var Vector1: TCompVector; Vector2: TCompVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
  Begin
    Vector1[I] := Vector1[I] + Vector2[I];
  End;
End;

Procedure Suma(Var Vector1: TStrVector; Vector2: TStrVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] + Vector2[I];
End;

Procedure Resta(Var Vector1: tVector; Vector2: tVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] - Vector2[I];
End;

Procedure Resta(Var Vector1: TIntVector; Vector2: TIntVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] - Vector2[I];
End;

Procedure Resta(Var Vector1: TBoolVector; Vector2: TBoolVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector1[I] := Vector1[I] Or Not Vector2[I];
End;

Procedure Resta(Var Vector1: TCompVector; Vector2: TCompVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
  Begin
    Vector1[I] := Vector1[I] - Vector2[I];
  End;
End;

Procedure Resta(Var Vector1: TStrVector; Vector2: TStrVector; Ub: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    strippedword(Vector2[I], Vector1[I]);
End;

Procedure Suma(Var MATRIZ1: TMatrix; MATRIZ2: TMatrix; Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Suma(Var MATRIZ1: TIntMatrix; MATRIZ2: TIntMatrix; Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Suma(Var MATRIZ1: TBoolMatrix; MATRIZ2: TBoolMatrix;
  Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Suma(Var MATRIZ1: TCompMatrix; MATRIZ2: TCompMatrix;
  Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Suma(Var MATRIZ1: TStrMatrix; MATRIZ2: TStrMatrix; Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Resta(Var MATRIZ1: TMatrix; MATRIZ2: TMatrix; Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Resta(Var MATRIZ1: TIntMatrix; MATRIZ2: TIntMatrix;
  Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Resta(Var MATRIZ1: TBoolMatrix; MATRIZ2: TBoolMatrix;
  Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Resta(Var MATRIZ1: TCompMatrix; MATRIZ2: TCompMatrix;
  Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Resta(Var MATRIZ1: TStrMatrix; MATRIZ2: TStrMatrix;
  Ub1, Ub2: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2);
End;

Procedure Suma(Var MATRIZ1: T3DMatrix; MATRIZ2: T3DMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Suma(Var MATRIZ1: T3DIntMatrix; MATRIZ2: T3DIntMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Suma(Var MATRIZ1: T3DBoolMatrix; MATRIZ2: T3DBoolMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Suma(Var MATRIZ1: T3DCompMatrix; MATRIZ2: T3DCompMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Suma(Var MATRIZ1: T3DStrMatrix; MATRIZ2: T3DStrMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Suma(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Resta(Var MATRIZ1: T3DMatrix; MATRIZ2: T3DMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Resta(Var MATRIZ1: T3DIntMatrix; MATRIZ2: T3DIntMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Resta(Var MATRIZ1: T3DBoolMatrix; MATRIZ2: T3DBoolMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Resta(Var MATRIZ1: T3DCompMatrix; MATRIZ2: T3DCompMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Procedure Resta(Var MATRIZ1: T3DStrMatrix; MATRIZ2: T3DStrMatrix;
  Ub1, Ub2, Ub3: Integer);
VAR
  I: Integer;
Begin
  For I := 1 To Ub1 Do
    Resta(MATRIZ1[I], MATRIZ2[I], Ub2, Ub3);
End;

Function FSuma(Vector1: tVector; Vector2: tVector; Ub: Integer): tVector;
Begin
  Result := Clone(Vector1, Ub);
  Suma(Result, Vector2, Ub);
End;

Function FSuma(Vector1: TIntVector; Vector2: TIntVector; Ub: Integer)
  : TIntVector;
Begin
  Result := Clone(Vector1, Ub);
  Suma(Result, Vector2, Ub);
End;

Function FSuma(Vector1: TBoolVector; Vector2: TBoolVector; Ub: Integer)
  : TBoolVector;
Begin
  Result := Clone(Vector1, Ub);
  Suma(Result, Vector2, Ub);
End;

Function FSuma(Vector1: TCompVector; Vector2: TCompVector; Ub: Integer)
  : TCompVector;
Begin
  Result := Clone(Vector1, Ub);
  Suma(Result, Vector2, Ub);
End;

Function FSuma(Vector1: TStrVector; Vector2: TStrVector; Ub: Integer)
  : TStrVector;
Begin
  Result := Clone(Vector1, Ub);
  Suma(Result, Vector2, Ub);
End;

Function FResta(Vector1: tVector; Vector2: tVector; Ub: Integer): tVector;
Begin
  Result := Clone(Vector1, Ub);
  Resta(Result, Vector2, Ub);
End;

Function FResta(Vector1: TIntVector; Vector2: TIntVector; Ub: Integer)
  : TIntVector;
Begin
  Result := Clone(Vector1, Ub);
  Resta(Result, Vector2, Ub);
End;

Function FResta(Vector1: TBoolVector; Vector2: TBoolVector; Ub: Integer)
  : TBoolVector;
Begin
  Result := Clone(Vector1, Ub);
  Resta(Result, Vector2, Ub);
End;

Function FResta(Vector1: TCompVector; Vector2: TCompVector; Ub: Integer)
  : TCompVector;
Begin
  Result := Clone(Vector1, Ub);
  Resta(Result, Vector2, Ub);
End;

Function FResta(Vector1: TStrVector; Vector2: TStrVector; Ub: Integer)
  : TStrVector;
Begin
  Result := Clone(Vector1, Ub);
  Resta(Result, Vector2, Ub);
End;

Function FSuma(MATRIZ1: TMatrix; MATRIZ2: TMatrix; Ub1, Ub2: Integer): TMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Suma(Result, MATRIZ2, Ub1, Ub2);
End;

Function FSuma(MATRIZ1: TIntMatrix; MATRIZ2: TIntMatrix; Ub1, Ub2: Integer)
  : TIntMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Suma(Result, MATRIZ2, Ub1, Ub2);
End;

Function FSuma(MATRIZ1: TBoolMatrix; MATRIZ2: TBoolMatrix; Ub1, Ub2: Integer)
  : TBoolMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Suma(Result, MATRIZ2, Ub1, Ub2);
End;

Function FSuma(MATRIZ1: TCompMatrix; MATRIZ2: TCompMatrix; Ub1, Ub2: Integer)
  : TCompMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Suma(Result, MATRIZ2, Ub1, Ub2);
End;

Function FSuma(MATRIZ1: TStrMatrix; MATRIZ2: TStrMatrix; Ub1, Ub2: Integer)
  : TStrMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Suma(Result, MATRIZ2, Ub1, Ub2);
End;

Function FResta(MATRIZ1: TMatrix; MATRIZ2: TMatrix; Ub1, Ub2: Integer): TMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Resta(Result, MATRIZ2, Ub1, Ub2);
End;

Function FResta(MATRIZ1: TIntMatrix; MATRIZ2: TIntMatrix; Ub1, Ub2: Integer)
  : TIntMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Resta(Result, MATRIZ2, Ub1, Ub2);
End;

Function FResta(MATRIZ1: TBoolMatrix; MATRIZ2: TBoolMatrix; Ub1, Ub2: Integer)
  : TBoolMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Resta(Result, MATRIZ2, Ub1, Ub2);
End;

Function FResta(MATRIZ1: TCompMatrix; MATRIZ2: TCompMatrix; Ub1, Ub2: Integer)
  : TCompMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Resta(Result, MATRIZ2, Ub1, Ub2);
End;

Function FResta(MATRIZ1: TStrMatrix; MATRIZ2: TStrMatrix; Ub1, Ub2: Integer)
  : TStrMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2);
  Resta(Result, MATRIZ2, Ub1, Ub2);
End;

Function FSuma(MATRIZ1: T3DMatrix; MATRIZ2: T3DMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Suma(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FSuma(MATRIZ1: T3DIntMatrix; MATRIZ2: T3DIntMatrix;
  Ub1, Ub2, Ub3: Integer): T3DIntMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Suma(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FSuma(MATRIZ1: T3DBoolMatrix; MATRIZ2: T3DBoolMatrix;
  Ub1, Ub2, Ub3: Integer): T3DBoolMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Suma(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FSuma(MATRIZ1: T3DCompMatrix; MATRIZ2: T3DCompMatrix;
  Ub1, Ub2, Ub3: Integer): T3DCompMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Suma(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FSuma(MATRIZ1: T3DStrMatrix; MATRIZ2: T3DStrMatrix;
  Ub1, Ub2, Ub3: Integer): T3DStrMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Suma(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FResta(MATRIZ1: T3DMatrix; MATRIZ2: T3DMatrix; Ub1, Ub2, Ub3: Integer)
  : T3DMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Resta(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FResta(MATRIZ1: T3DIntMatrix; MATRIZ2: T3DIntMatrix;
  Ub1, Ub2, Ub3: Integer): T3DIntMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Resta(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FResta(MATRIZ1: T3DBoolMatrix; MATRIZ2: T3DBoolMatrix;
  Ub1, Ub2, Ub3: Integer): T3DBoolMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Resta(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FResta(MATRIZ1: T3DCompMatrix; MATRIZ2: T3DCompMatrix;
  Ub1, Ub2, Ub3: Integer): T3DCompMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Resta(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function FResta(MATRIZ1: T3DStrMatrix; MATRIZ2: T3DStrMatrix;
  Ub1, Ub2, Ub3: Integer): T3DStrMatrix;
Begin
  Result := Clone(MATRIZ1, Ub1, Ub2, Ub3);
  Resta(Result, MATRIZ2, Ub1, Ub2, Ub3);
End;

Function DotProduct(Const Vector1, Vector2: tVector; Ub: Integer): float;
Var
  I: Integer;
  cont: float;
Begin
  cont := 0;
  For I := 1 To Ub Do
    cont := cont + (Vector1[I] * Vector2[I]);
  Result := cont;
End;

Function FVSquare(Const Vector: tVector; Ub: Integer): float;
Begin
  Result := DotProduct(Vector, Vector, Ub);
End;

Function DotProduct(Const Vector1, Vector2: TIntVector; Ub: Integer): Integer;
Var
  I: Integer;
  cont: Integer;
Begin
  cont := 0;
  For I := 1 To Ub Do
    cont := cont + (Vector1[I] * Vector2[I]);
  Result := cont;
End;

Function DotProduct(Const Vector1, Vector2: TCompVector; Ub: Integer): Complex;
Var
  I: Integer;
  cont: Complex;
Begin
  cont := TComplex(0, 0);
  For I := 1 To Ub Do
  Begin
    cont := cont + (Vector1[I] * Vector2[I]);
  End;
  Result := cont;
End;

Function DotProduct(Const Vector1, Vector2: TBoolVector; Ub: Integer): Boolean;
Var
  I: Integer;
  cont: Boolean;
Begin
  cont := false;
  For I := 1 To Ub Do
    cont := cont Or (Vector1[I] And Vector2[I]);
  Result := cont;
End;

Procedure MultiplyByNumber(Var Vector: tVector; Ub: Integer; Number: float);
Var
  I: Integer;
Begin
  For I := 1 To Ub Do
    Vector[I] := Vector[I] * Number;
End;

Procedure MultiplyByNumber(Var Matrix: TMatrix; Ub1, Ub2: Integer;
  Number: float);
Var
  I, J: Integer;
Begin
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      Matrix[I, J] := Matrix[I, J] * Number;
End;

Procedure MultiplyByNumber(Var Matrix: T3DMatrix; Ub1, Ub2, Ub3: Integer;
  Number: float);
Var
  I, J, K: Integer;
Begin
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      For K := 1 To Ub3 Do
        Matrix[I, J, K] := Matrix[I, J, K] * Number;
End;

Function Multiply(Const MATRIZ1, MATRIZ2: TMatrix;
  Ub1, Ub2, Ub3: Integer): TMatrix;
Var
  I, J, K: Integer;
  cont: float;
Begin
  DimMatrix(Result, Ub1, Ub3);
  For I := 1 To Ub1 Do
    For J := 1 To Ub3 Do
    Begin
      cont := 0;
      For K := 1 To Ub2 Do
        cont := cont + MATRIZ1[I, K] * MATRIZ2[K, J];
      Result[I, J] := cont;
    End;
End;

Function Multiply(Const MATRIZ1, MATRIZ2: TIntMatrix; Ub1, Ub2, Ub3: Integer)
  : TIntMatrix;
Var
  I, J, K, cont: Integer;
Begin
  DimMatrix(Result, Ub1, Ub3);
  For I := 1 To Ub1 Do
    For J := 1 To Ub3 Do
    Begin
      cont := 0;
      For K := 1 To Ub2 Do
        cont := cont + MATRIZ1[I, K] * MATRIZ2[K, J];
      Result[I, J] := cont;
    End;
End;

Function Multiply(Const MATRIZ1, MATRIZ2: TBoolMatrix; Ub1, Ub2, Ub3: Integer)
  : TBoolMatrix;
Var
  I, J, K: Integer;
  cont: Boolean;
Begin
  DimMatrix(Result, Ub1, Ub3);
  For I := 1 To Ub1 Do
    For J := 1 To Ub3 Do
    Begin
      cont := false;
      For K := 1 To Ub2 Do
        cont := cont Or (MATRIZ1[I, K] And MATRIZ2[K, J]);
      Result[I, J] := cont;
    End;
End;

Function Multiply(Const MATRIZ1, MATRIZ2: TCompMatrix; Ub1, Ub2, Ub3: Integer)
  : TCompMatrix;
Var
  I, J, K: Integer;
  cont: Complex;
Begin
  DimMatrix(Result, Ub1, Ub3, 0);
  For I := 1 To Ub1 Do
    For J := 1 To Ub3 Do
    Begin
      cont := TComplex(0, 0);
      For K := 1 To Ub2 Do
        cont := cont + (MATRIZ1[I, K] * MATRIZ2[K, J]);
      Result[I, J] := cont;
    End;
End;

Procedure TraspondRows(A: TMatrix; row1, row2, RowSize: Integer);
Var
  I: Integer;
Begin
  For I := 1 To RowSize Do
    Swap(A[row1, I], A[row2, I]);
End;

Procedure TraspondColumns(A: TMatrix; col1, col2, ColSize: Integer);
Var
  I: Integer;
Begin
  For I := 1 To ColSize Do
    Swap(A[I, col1], A[I, col2]);
End;

Function XYZtoZYX(A: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;
Var
  I, J, K: Integer;
Begin
  DimMatrix(Result, Ub3, Ub2, Ub1);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      For K := 1 To Ub3 Do
        Result[K, J, I] := A[I, J, K];
End;

Function XYZtoZXY(A: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;
Var
  I, J, K: Integer;
Begin
  DimMatrix(Result, Ub3, Ub1, Ub2);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      For K := 1 To Ub3 Do
        Result[K, I, J] := A[I, J, K];
End;

Function XYZtoYZX(A: T3DMatrix; Ub1, Ub2, Ub3: Integer): T3DMatrix;
Var
  I, J, K: Integer;
Begin
  DimMatrix(Result, Ub2, Ub3, Ub1);
  For I := 1 To Ub1 Do
    For J := 1 To Ub2 Do
      For K := 1 To Ub3 Do
        Result[J, K, I] := A[I, J, K];
End;

Function ColumnToVector(Const Matrix: TMatrix; Rows, index: Integer): tVector;
Var
  I: Integer;
Begin
  DimVector(Result, Rows);
  For I := 1 To Rows Do
    Result[I] := Matrix[I, Index];
End;

Function RowToVector(Const Matrix: TMatrix; index, Columns: Integer): tVector;
Var
  I: Integer;
Begin
  DimVector(Result, Columns);
  For I := 1 To Columns Do
    Result[I] := Matrix[Index, I];
End;

Function ColumnToVector(Const Matrix: TStrMatrix; Rows, index: Integer)
  : TStrVector;
Var
  I: Integer;
Begin
  DimVector(Result, Rows);
  For I := 1 To Rows Do
    Result[I] := Matrix[I, Index];
End;

Function RowToVector(Const Matrix: TStrMatrix; index, Columns: Integer)
  : TStrVector;
Var
  I: Integer;
Begin
  DimVector(Result, Columns);
  For I := 1 To Columns Do
    Result[I] := Matrix[Index, I];
End;

Procedure CopyVectorToColumn(Var Matrix: TMatrix; Const V: tVector;
  Rows, index: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Rows Do
    Matrix[I, Index] := V[I];
End;

Procedure CopyVectorToRow(Var Matrix: TMatrix; Const V: tVector;
  index, Columns: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Columns Do
    Matrix[Index, I] := V[I];
End;

Procedure CopyVectorToColumn(Var Matrix: TStrMatrix; Const V: TStrVector;
  Rows, index: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Rows Do
    Matrix[I, Index] := V[I];
End;

Procedure CopyVectorToRow(Var Matrix: TStrMatrix; Const V: TStrVector;
  index, Columns: Integer);
Var
  I: Integer;
Begin
  For I := 1 To Columns Do
    Matrix[Index, I] := V[I];
End;

Procedure Append(Var Vector: tVector; Var Ub: Integer; Value: float);
Begin
  Ub := Ub + 1;
  setlength(Vector, Ub + 1);
  Vector[0] := Ub;
  Vector[Ub] := Value;
End;

Procedure Append(Var Vector: TIntVector; Var Ub: Integer; Value: Integer);
Begin
  Ub := Ub + 1;
  setlength(Vector, Ub + 1);
  Vector[0] := Ub;
  Vector[Ub] := Value;
End;

Procedure Append(Var Vector: TBoolVector; Var Ub: Integer; Value: Boolean);
Begin
  Ub := Ub + 1;
  setlength(Vector, Ub + 1);
  Vector[Ub] := Value;
End;

Procedure Append(Var Vector: TStrVector; Var Ub: Integer; Value: String);
Begin
  Ub := Ub + 1;
  setlength(Vector, Ub + 1);
  Vector[Ub] := Value;
End;

Procedure Append(Var Vector: TCompVector; Var Ub: Integer; Value: Complex);
Begin
  Ub := Ub + 1;
  setlength(Vector, Ub + 1);
  Vector[0] := TComplex(Ub, 0);
  Vector[Ub] := Value;
End;

Procedure Percolar(Matriz: TMatrix; Ub1, Ub2, I, J: Integer; RNG: TRandomGen;
  EPS, Oracle: float; Out trial_row, trial_col: TIntVector; Out Dim: Integer);
Var
  visitados: TBoolMatrix;
  i1, j1: Integer;
  Procedure Percola(m, n: Cardinal; Var dim1, dim2: Integer);
  Var
    p: float;
    m1, m2, n1, n2: Integer;
  Begin
    m := GoToRangeI(m, 1, Ub1);
    n := GoToRangeI(n, 1, Ub2);
    If Not(visitados[m, n]) Then
    Begin
      visitados[m, n] := true;
      m1 := m - 1;
      m2 := m + 1;
      n1 := n - 1;
      n2 := n + 1;
      m1 := GoToRangeI(m1, 1, Ub1);
      n1 := GoToRangeI(n1, 1, Ub2);
      m2 := GoToRangeI(m2, 1, Ub1);
      n2 := GoToRangeI(n2, 1, Ub2);
      Append(trial_row, dim1, m);
      Append(trial_col, dim2, n);
      If abs(Matriz[m, n] - Matriz[m1, n]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m1, n, dim1, dim2);
        End;
      End;
      If abs(Matriz[m, n] - Matriz[m2, n]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m2, n, dim1, dim2);
        End;
      End;
      If abs(Matriz[m, n] - Matriz[m, n1]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n1, dim1, dim2);
        End;
      End;
      If abs(Matriz[m, n] - Matriz[m, n2]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n2, dim1, dim2);
        End;
      End;
    End;
  End;

Begin
  Try
    DimMatrix(visitados, Ub1, Ub2, false);
    i1 := 0;
    j1 := 0;
    DimVector(trial_row, i1);
    DimVector(trial_col, j1);
    Percola(I, J, i1, j1);
    If i1 = j1 Then
      Dim := i1
    Else
      Dim := Min(i1, j1);
  Finally
    DelMatrix(visitados);
  End;
End;

Procedure Percolar(Matriz: TIntMatrix; Ub1, Ub2, I, J: Integer; RNG: TRandomGen;
  EPS, Oracle: float; Out trial_row, trial_col: TIntVector; Out Dim: Integer);
Var
  visitados: TBoolMatrix;
  i1, j1: Integer;
  Procedure Percola(m, n: Cardinal; Var dim1, dim2: Integer);
  Var
    p: float;
    m1, m2, n1, n2: Integer;
  Begin
    m := GoToRangeI(m, 1, Ub1);
    n := GoToRangeI(n, 1, Ub2);
    If Not(visitados[m, n]) Then
    Begin
      visitados[m, n] := true;
      m1 := m - 1;
      m2 := m + 1;
      n1 := n - 1;
      n2 := n + 1;
      m1 := GoToRangeI(m1, 1, Ub1);
      n1 := GoToRangeI(n1, 1, Ub2);
      m2 := GoToRangeI(m2, 1, Ub1);
      n2 := GoToRangeI(n2, 1, Ub2);
      Append(trial_row, dim1, m);
      Append(trial_col, dim2, n);
      If abs(Matriz[m, n] - Matriz[m1, n]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m1, n, dim1, dim2);
        End;
      End;
      If abs(Matriz[m, n] - Matriz[m2, n]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m2, n, dim1, dim2);
        End;
      End;
      If abs(Matriz[m, n] - Matriz[m, n1]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n1, dim1, dim2);
        End;
      End;
      If abs(Matriz[m, n] - Matriz[m, n2]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n2, dim1, dim2);
        End;
      End;
    End;
  End;

Begin
  Try
    DimMatrix(visitados, Ub1, Ub2, false);
    i1 := 0;
    j1 := 0;
    DimVector(trial_row, i1);
    DimVector(trial_col, j1);
    Percola(I, J, i1, j1);
    If i1 = j1 Then
      Dim := i1
    Else
      Dim := Min(i1, j1);
  Finally
    DelMatrix(visitados);
  End;
End;

Procedure Percolar(Matriz: T3DMatrix; Ub1, Ub2, Ub3, I, J, K: Integer;
  RNG: TRandomGen; EPS, Oracle: float; Out trial_row, trial_col,
  trial_order: TIntVector; Out Dim: Integer);
Var
  visitados: T3DBoolMatrix;
  i1, j1, k1: Integer;
  Procedure Percola(m, n, o: Cardinal; Var dim1, dim2, dim3: Integer);
  Var
    p: float;
    m1, m2, n1, n2, o1, o2: Integer;
  Begin
    m := GoToRangeI(m, 1, Ub1);
    n := GoToRangeI(n, 1, Ub2);
    o := GoToRangeI(o, 1, Ub3);
    If Not(visitados[m, n, o]) Then
    Begin
      visitados[m, n, o] := true;
      m1 := m - 1;
      m2 := m + 1;
      n1 := n - 1;
      n2 := n + 1;
      o1 := o - 1;
      o2 := o + 1;
      m1 := GoToRangeI(m1, 1, Ub1);
      n1 := GoToRangeI(n1, 1, Ub2);
      o1 := GoToRangeI(o1, 1, Ub3);
      m2 := GoToRangeI(m2, 1, Ub1);
      n2 := GoToRangeI(n2, 1, Ub2);
      o2 := GoToRangeI(o2, 1, Ub3);
      Append(trial_row, dim1, m);
      Append(trial_col, dim2, n);
      Append(trial_order, dim3, o);
      If abs(Matriz[m, n, o] - Matriz[m1, n, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m1, n, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m2, n, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m2, n, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n1, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n1, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n2, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n2, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n, o1]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n, o1, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n, o2]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n, o2, dim1, dim2, dim3);
        End;
      End;
    End;
  End;

Begin
  Try
    DimMatrix(visitados, Ub1, Ub2, Ub3, false);
    i1 := 0;
    j1 := 0;
    k1 := 0;
    DimVector(trial_row, i1);
    DimVector(trial_col, j1);
    DimVector(trial_order, k1);
    Percola(I, J, K, i1, j1, k1);
    If (i1 = j1) And (j1 = k1) Then
      Dim := i1
    Else
      Dim := min3(i1, j1, k1);
  Finally
    DelMatrix(visitados);
  End;
End;

Procedure Percolar(Matriz: T3DIntMatrix; Ub1, Ub2, Ub3, I, J, K: Integer;
  RNG: TRandomGen; EPS, Oracle: float; Out trial_row, trial_col,
  trial_order: TIntVector; Out Dim: Integer);
Var
  visitados: T3DBoolMatrix;
  i1, j1, k1: Integer;
  Procedure Percola(m, n, o: Cardinal; Var dim1, dim2, dim3: Integer);
  Var
    p: float;
    m1, m2, n1, n2, o1, o2: Integer;
  Begin
    m := GoToRangeI(m, 1, Ub1);
    n := GoToRangeI(n, 1, Ub2);
    o := GoToRangeI(o, 1, Ub3);
    If Not(visitados[m, n, o]) Then
    Begin
      visitados[m, n, o] := true;
      m1 := m - 1;
      m2 := m + 1;
      n1 := n - 1;
      n2 := n + 1;
      o1 := o - 1;
      o2 := o + 1;
      m1 := GoToRangeI(m1, 1, Ub1);
      n1 := GoToRangeI(n1, 1, Ub2);
      o1 := GoToRangeI(o1, 1, Ub3);
      m2 := GoToRangeI(m2, 1, Ub1);
      n2 := GoToRangeI(n2, 1, Ub2);
      o2 := GoToRangeI(o2, 1, Ub3);
      Append(trial_row, dim1, m);
      Append(trial_col, dim2, n);
      Append(trial_order, dim3, o);
      If abs(Matriz[m, n, o] - Matriz[m1, n, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m1, n, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m2, n, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m2, n, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n1, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n1, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n2, o]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n2, o, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n, o1]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n, o1, dim1, dim2, dim3);
        End;
      End;
      If abs(Matriz[m, n, o] - Matriz[m, n, o2]) <= EPS Then
      Begin
        p := RNG.Random2;
        If p < Oracle Then
        Begin
          Percola(m, n, o2, dim1, dim2, dim3);
        End;
      End;
    End;
  End;

Begin
  Try
    DimMatrix(visitados, Ub1, Ub2, Ub3, false);
    i1 := 0;
    j1 := 0;
    k1 := 0;
    DimVector(trial_row, i1);
    DimVector(trial_col, j1);
    DimVector(trial_order, k1);
    Percola(I, J, K, i1, j1, k1);
    If (i1 = j1) And (j1 = k1) Then
      Dim := i1
    Else
      Dim := min3(i1, j1, k1);
  Finally
    DelMatrix(visitados);
  End;
End;

Function ResizeV(Vector: tVector; m, Ub: Integer): tVector;
Var
  I: Integer;
Begin
  If m = Ub Then
  Begin
    Result := Clone(Vector, m);
    Exit;
  End;
  With TSpline.Create(Vector, m) Do
    Try
      Result := Cubic1DSpline(Ub);
    Finally
      Free;
    End;
End;

Function ResizeM(Matriz: TMatrix; m, n, Ub1, Ub2: Integer): TMatrix;
Var
  I, J: Integer;
Begin
  If ((m = Ub1) And (n = Ub2)) Then
  Begin
    Result := Clone(Matriz, m, n);
    Exit;
  End;
  With TSpline2D.Create(Matriz, m, n) Do
    Try
      Result := Cubic2DSpline(Ub1, Ub2);
    Finally
      Free;
    End;
End;

Function Resize3DM(Matriz: T3DMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DMatrix;
Var
  I, J, K: Integer;
Begin
  If ((m = Ub1) And (n = Ub2) And (o = Ub3)) Then
  Begin
    Result := Clone(Matriz, m, n, o);
    Exit;
  End;
  With TSpline3D.Create(Matriz, m, n, o) Do
    Try
      Result := Cubic3DSpline(Ub1, Ub2, Ub3);
    Finally
      Free;
    End;
End;

Function ResizeV_Lineal(Vector: tVector; m, Ub: Integer): tVector;
Begin
  If m = Ub Then
  Begin
    Result := Clone(Vector, m);
    Exit;
  End;
  With TLinealInterpolation.Create(Vector, m) Do
    Try
      Result := Interpolate1D(Ub);
    Finally
      Free;
    End;
End;

Function ResizeM_Lineal(Matriz: TMatrix; m, n, Ub1, Ub2: Integer): TMatrix;
Begin
  If ((m = Ub1) And (n = Ub2)) Then
  Begin
    Result := Clone(Matriz, m, n);
    Exit;
  End;
  With TLineal2DInterpolation.Create(Matriz, m, n) Do
    Try
      Result := Interpolate2D(Ub1, Ub2);
    Finally
      Free;
    End;
End;

Function Resize3DM_Lineal(Matriz: T3DMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DMatrix;
Begin
  If ((m = Ub1) And (n = Ub2) And (o = Ub3)) Then
  Begin
    Result := Clone(Matriz, m, n, o);
    Exit;
  End;
  With TLineal3DInterpolation.Create(Matriz, m, n, o) Do
    Try
      Result := Interpolate3D(Ub1, Ub2, Ub3);
    Finally
      Free;
    End;
End;

// All the following functions round the interpolation to acomplish array type

Function ResizeV(Vector: TIntVector; m, Ub: Integer): TIntVector;
Var
  I: Integer;
  temp: tVector;
Begin
  If m = Ub Then
  Begin
    Result := Clone(Vector, m);
    Exit;
  End;
  With TSpline.Create(Vector, m) Do
    Try
      temp := Cubic1DSpline(Ub);
      Result := round(temp, Ub);
      DelVector(temp);
    Finally
      Free;
    End;
End;

Function ResizeM(Matriz: TIntMatrix; m, n, Ub1, Ub2: Integer): TIntMatrix;
Var
  I, J: Integer;
  temp: TMatrix;
Begin
  If ((m = Ub1) And (n = Ub2)) Then
  Begin
    Result := Clone(Matriz, m, n);
    Exit;
  End;
  With TSpline2D.Create(Matriz, m, n) Do
    Try
      temp := Cubic2DSpline(Ub1, Ub2);
      Result := round(temp, Ub1, Ub2);
      DelMatrix(temp);
    Finally
      Free;
    End;
End;

Function Resize3DM(Matriz: T3DIntMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix;
Var
  I, J, K: Integer;
  temp: T3DMatrix;
Begin
  If ((m = Ub1) And (n = Ub2) And (o = Ub3)) Then
  Begin
    Result := Clone(Matriz, m, n, o);
    Exit;
  End;
  With TSpline3D.Create(Matriz, m, n, o) Do
    Try
      temp := Cubic3DSpline(Ub1, Ub2, Ub3);
      Result := round(temp, Ub1, Ub2, Ub3);
      DelMatrix(temp);
    Finally
      Free;
    End;
End;

Function ResizeV_Lineal(Vector: TIntVector; m, Ub: Integer): TIntVector;
Var
  temp: tVector;
Begin
  If m = Ub Then
  Begin
    Result := Clone(Vector, m);
    Exit;
  End;
  With TLinealInterpolation.Create(Vector, m) do
  try
    temp:=Interpolate1D(Ub);
    result:=round(temp, Ub);
    DelVector(temp);
  finally
    Free;
  end;
End;

Function ResizeM_Lineal(Matriz: TIntMatrix; m, n, Ub1, Ub2: Integer)
  : TIntMatrix;
Var
  temp:TMatrix;
Begin
  If ((m = Ub1) And (n = Ub2)) Then
  Begin
    Result := Clone(Matriz, m, n);
    Exit;
  End;
  with TLineal2DInterpolation.Create(Matriz, m, n) do
  try
    temp:=Interpolate2D(Ub1, Ub2);
    result:=round(temp, Ub1, Ub2);
    DelMatrix(temp);
  finally
    Free;
  end;
End;

Function Resize3DM_Lineal(Matriz: T3DIntMatrix; m, n, o, Ub1, Ub2, Ub3: Integer)
  : T3DIntMatrix;
Var
  temp:T3DMatrix;
Begin
  If ((m = Ub1) And (n = Ub2) And (o = Ub3)) Then
  Begin
    Result := Clone(Matriz, m, n, o);
    Exit;
  End;
  with TLineal3DInterpolation.Create(Matriz, m, n,o) do
  try
    temp:=Interpolate3D(Ub1, Ub2, Ub3);
    result:=round(temp, Ub1, Ub2, Ub3);
    DelMatrix(temp);
  finally
    Free;
  end;
End;

End.
