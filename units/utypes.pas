{ ******************************************************************
  Types and constants - Error handling - Dynamic arrays
  ******************************************************************
  The default real Type is DOUBLE (8-byte real).
  Other Types may be selected by defining the symbols:

  SINGLEREAL   (Single precision, 4 bytes)
  EXTENDEDREAL (Extended precision, 12 bytes)

  modified by Alex Vergara Gil
  1. Included 3d Matrixes of all kinds
  2. Included creating and destroying Procedures
  3. Included user initialization
  4. Included self sizing on zero element
  5. Modified all definitions of dinamic arrays to accomplish delphi's need
  ****************************************************************** }

Unit uTypes;

Interface

Uses windows, ucomplex, uConstants;

{$I Types.inc}
{ ------------------------------------------------------------------
  Dynamic arrays
  ------------------------------------------------------------------ }

Procedure DimVector(Out V: TVector; Ub: Cardinal;
  InitialValue: Float = 0); Overload;
{ Creates floating point vector V[0..Ub] }

Procedure DimVector(Out V: TIntVector; Ub: Cardinal;
  InitialValue: Integer = 0); Overload;
{ Creates integer vector V[0..Ub] }

Procedure DimVector(Out V: TInt64Vector; Ub: Cardinal;
  InitialValue: int64 = 0); Overload;
{ Creates integer vector V[0..Ub] }

Procedure DimVector(Out V: TWordVector; Ub: Cardinal;
  InitialValue: Word = 0); Overload;
{ Creates Word vector V[0..Ub] }

Procedure DimVector(Out V: TCompVector; Ub: Cardinal;
  InitialValue: Complex); Overload;
{ Creates complex vector V[0..Ub] }

Procedure DimVector(Out V: TBoolVector; Ub: Cardinal;
  InitialValue: Boolean = False); Overload;
{ Creates boolean vector V[0..Ub] }

Procedure DimVector(Out V: TStrVector; Ub: Cardinal;
  InitialValue: String = ''); Overload;
{ Creates string vector V[0..Ub] }

Procedure DimMatrix(Out A: TMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Float = 0); Overload;
{ Creates floating point matrix A[0..Ub1, 0..Ub2] }

Procedure DimMatrix(Out A: TIntMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Integer = 0); Overload;
{ Creates integer matrix A[0..Ub1, 0..Ub2] }

Procedure DimMatrix(Out A: TWordMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Word = 0); Overload;
{ Creates Word matrix A[0..Ub1, 0..Ub2] }

Procedure DimMatrix(Out A: TCompMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Complex); Overload;
{ Creates complex matrix A[0..Ub1, 0..Ub2] }

Procedure DimMatrix(Out A: TBoolMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Boolean = False); Overload;
{ Creates boolean matrix A[0..Ub1, 0..Ub2] }

Procedure DimMatrix(Out A: TStrMatrix; Ub1, Ub2: Cardinal;
  InitialValue: String = ''); Overload;
{ Creates string matrix A[0..Ub1, 0..Ub2] }

Procedure DimMatrix(Out A: T3DMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Float = 0); Overload;
{ Creates floating point matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DimMatrix(Out A: T3DIntMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Integer = 0); Overload;
{ Creates integer matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DimMatrix(Out A: T3DWordMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Word = 0); Overload;
{ Creates Word matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DimMatrix(Out A: T3DCompMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Complex); Overload;
{ Creates complex matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DimMatrix(Out A: T3DBoolMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Boolean = False); Overload;
{ Creates boolean matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DimMatrix(Out A: T3DStrMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: String = ''); Overload;
{ Creates string matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure SeqVector(Out V: TVector; Ub: Cardinal); Overload;
Procedure SeqVector(Out V: TIntVector; Ub: Cardinal); Overload;

Procedure DelVector(Var V: TVector); Overload;
{ Deletes floating point vector V[0..Ub] }

Procedure DelVector(Var V: TIntVector); Overload;
{ Deletes integer vector V[0..Ub] }

Procedure DelVector(Var V: TInt64Vector); Overload;
{ Deletes integer vector V[0..Ub] }

Procedure DelVector(Var V: TWordVector); Overload;
{ Deletes Word vector V[0..Ub] }

Procedure DelVector(Var V: TCompVector); Overload;
{ Deletes complex vector V[0..Ub] }

Procedure DelVector(Var V: TBoolVector); Overload;
{ Deletes boolean vector V[0..Ub] }

Procedure DelVector(Var V: TStrVector); Overload;
{ Deletes string vector V[0..Ub] }

Procedure DelMatrix(Var A: TMatrix); Overload;
{ Deletes floating point matrix A[0..Ub1, 0..Ub2] }

Procedure DelMatrix(Var A: TIntMatrix); Overload;
{ Deletes integer matrix A[0..Ub1, 0..Ub2] }

Procedure DelMatrix(Var A: TWordMatrix); Overload;
{ Deletes Word matrix A[0..Ub1, 0..Ub2] }

Procedure DelMatrix(Var A: TCompMatrix); Overload;
{ Deletes complex matrix A[0..Ub1, 0..Ub2] }

Procedure DelMatrix(Var A: TBoolMatrix); Overload;
{ Deletes boolean matrix A[0..Ub1, 0..Ub2] }

Procedure DelMatrix(Var A: TStrMatrix); Overload;
{ Deletes string matrix A[0..Ub1, 0..Ub2] }

Procedure DelMatrix(Var A: T3DMatrix); Overload;
{ Deletes floating point matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DelMatrix(Var A: T3DIntMatrix); Overload;
{ Deletes integer matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DelMatrix(Var A: T3DWordMatrix); Overload;
{ Deletes Word matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DelMatrix(Var A: T3DCompMatrix); Overload;
{ Deletes complex matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DelMatrix(Var A: T3DBoolMatrix); Overload;
{ Deletes boolean matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Procedure DelMatrix(Var A: T3DStrMatrix); Overload;
{ Deletes string matrix A[0..Ub1, 0..Ub2, 0..Ub3] }

Function size(V: TVector): Integer; {$IFDEF INLININGSUPPORTED}Inline; {$ENDIF}
{ Return the size of a vector }

Implementation

Uses umemory, sysutils, Classes;

Function size(V: TVector): Integer;
Begin
  result := System.High(V);
End;

Procedure DimVector(Out V: TVector; Ub: Cardinal; InitialValue: Float);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * Bytes_FLt > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub;                 // on position 0 it has the size like strings
  If (InitialValue <> 0) Then // SetLength already allocates 0
    For I := 1 To Ub Do
      V[I] := InitialValue;
  SetErrCode(FOk);
End;

Procedure SeqVector(Out V: TVector; Ub: Cardinal);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * Bytes_Integer > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub; // on position 0 it has the size like strings
  For I := 1 To Ub Do
    V[I] := I;
  SetErrCode(FOk);
End;

Procedure DimVector(Out V: TIntVector; Ub: Cardinal; InitialValue: Integer);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * Bytes_Integer > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub;                 // on position 0 it has the size like strings
  If (InitialValue <> 0) Then // SetLength already allocates 0
    For I := 1 To Ub Do
      V[I] := InitialValue;
  SetErrCode(FOk);
End;

Procedure SeqVector(Out V: TIntVector; Ub: Cardinal);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * Bytes_Integer > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub; // on position 0 it has the size like strings
  For I := 1 To Ub Do
    V[I] := I;
  SetErrCode(FOk);
End;

Procedure DimVector(Out V: TInt64Vector; Ub: Cardinal; InitialValue: int64);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * Bytes_Integer > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub;                 // on position 0 it has the size like strings
  If (InitialValue <> 0) Then // SetLength already allocates 0
    For I := 1 To Ub Do
      V[I] := InitialValue;
  SetErrCode(FOk);
End;

Procedure DimVector(Out V: TWordVector; Ub: Cardinal; InitialValue: Word);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * Bytes_Word > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub;                 // on position 0 it has the size like strings
  If (InitialValue <> 0) Then // SetLength already allocates 0
    For I := 1 To Ub Do
      V[I] := InitialValue;
  SetErrCode(FOk);
End;

Procedure DimVector(Out V: TCompVector; Ub: Cardinal; InitialValue: Complex);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * 2 * Bytes_FLt > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }
  V[0] := Ub; // on position 0 it has the size like strings
  For I := 1 To Ub Do
  Begin
    V[I] := InitialValue;
  End;
  SetErrCode(FOk);
End;

Procedure DimVector(Out V: TBoolVector; Ub: Cardinal; InitialValue: Boolean);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub / 8 > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  { Initialize vector }  // Here it cannot be applied the size on zero
  If (InitialValue) Then // SetLength already allocates 0
    For I := 0 To Ub Do
      V[I] := InitialValue;
  SetErrCode(FOk);
End;

Procedure DimVector(Out V: TStrVector; Ub: Cardinal; InitialValue: String);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub * 256 > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    V := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate vector }
  setlength(V, Ub + 1);
  If V = Nil Then
    Exit;

  Try                            { Initialize vector }
    V[0] := inttostr(Ub);        // on position 0 it has the size like strings
    If (InitialValue <> '') Then // SetLength already allocates 0
      For I := 1 To Ub Do
        V[I] := InitialValue;
    SetErrCode(FOk);
  Except
    Finalize(V, Ub + 1);
    SetErrCode(FtLoss);
  End;
End;

Procedure DimMatrix(Out A: TMatrix; Ub1, Ub2: Cardinal; InitialValue: Float);
Var
  I, J  : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Bytes_FLt > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate matrix }
  setlength(A, Ub1 + 1);
  // GetMem(A, (Ub1 + 1) * SizeOf(PVector));
  If A = Nil Then
    Exit;

  { Allocate each row }
  For I := 0 To Ub1 Do
  Begin
    DimVector(A[I], Ub2, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0] := Ub1 * Ub2; // size of matrix
  For J := 1 To Ub2 Do
    A[0, J] := Ub1; // size of each row

  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: TIntMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Integer);
Var
  I, J  : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Bytes_Integer > memory.dwAvailPhys +
    memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate matrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each row }
  For I := 0 To Ub1 Do
  Begin
    DimVector(A[I], Ub2, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0] := Ub1 * Ub2; // size of matrix
  For J := 1 To Ub2 Do
    A[0, J] := Ub1; // size of each row

  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: TWordMatrix; Ub1, Ub2: Cardinal; InitialValue: Word);
Var
  I, J  : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Bytes_Word > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate matrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each row }
  For I := 0 To Ub1 Do
  Begin
    DimVector(A[I], Ub2, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0] := Ub1 * Ub2; // size of matrix
  For J := 1 To Ub2 Do
    A[0, J] := Ub1; // size of each row

  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: TCompMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Complex);
Var
  I, J  : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * 2 * Bytes_FLt > memory.dwAvailPhys +
    memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate matrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each row }
  For I := 0 To Ub1 Do
  Begin
    DimVector(A[I], Ub2, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0] := Ub1 * Ub2; // size of matrix
  For J := 1 To Ub2 Do
    A[0, J] := Ub1; // size of each row

  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: TBoolMatrix; Ub1, Ub2: Cardinal;
  InitialValue: Boolean);
Var
  I { , J } : Integer;
  memory    : tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 / 8 > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate matrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each row }
  For I := 0 To Ub1 Do
  Begin
    DimVector(A[I], Ub2, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: TStrMatrix; Ub1, Ub2: Cardinal;
  InitialValue: String);
Var
  I, J  : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * 256 > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate matrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each row }
  For I := 0 To Ub1 Do
  Begin
    DimVector(A[I], Ub2, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0] := inttostr(Ub1 * Ub2); // size of matrix
  For J := 1 To Ub2 Do
    A[0, J] := inttostr(Ub1); // size of each row

  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: T3DMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Float);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Ub3 * Bytes_FLt > memory.dwAvailPhys +
    memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate 3Dmatrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each matrix }
  DimMatrix(A[0], Ub2, Ub3, Ub1); // the zero matrix has the number of matrixes
  If A[0] = Nil Then
  Begin
    DelMatrix(A);
    SetErrCode(FMemOverflow);
    Exit;
  End;
  For I := 1 To Ub1 Do
  Begin
    DimMatrix(A[I], Ub2, Ub3, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0, 0] := Ub1 * Ub2 * Ub3; // here is stored the total size of the matrix
  // It is already initialized on DimMatrix
  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: T3DIntMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Integer);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Ub3 * Bytes_Integer > memory.dwAvailPhys +
    memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate 3Dmatrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each matrix }
  DimMatrix(A[0], Ub2, Ub3, Ub1); // the zero matrix has the number of matrixes
  If A[0] = Nil Then
  Begin
    DelMatrix(A);
    SetErrCode(FMemOverflow);
    Exit;
  End;
  For I := 1 To Ub1 Do
  Begin
    DimMatrix(A[I], Ub2, Ub3, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0, 0] := Ub1 * Ub2 * Ub3; // here is stored the total size of the matrix
  // It is already initialized on DimIntMatrix
  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: T3DWordMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Word);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Ub3 * Bytes_Word > memory.dwAvailPhys +
    memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate 3Dmatrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each matrix }
  DimMatrix(A[0], Ub2, Ub3, Ub1); // the zero matrix has the number of matrixes
  If A[0] = Nil Then
  Begin
    DelMatrix(A);
    SetErrCode(FMemOverflow);
    Exit;
  End;
  For I := 1 To Ub1 Do
  Begin
    DimMatrix(A[I], Ub2, Ub3, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0, 0] := Ub1 * Ub2 * Ub3; // here is stored the total size of the matrix
  // It is already initialized on DimIntMatrix
  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: T3DCompMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Complex);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Ub3 * 2 * Bytes_FLt > memory.dwAvailPhys +
    memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate 3Dmatrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each matrix }
  DimMatrix(A[0], Ub2, Ub3, Ub1); // the zero matrix has the number of matrixes
  If A[0] = Nil Then
  Begin
    DelMatrix(A);
    SetErrCode(FMemOverflow);
    Exit;
  End;
  For I := 1 To Ub1 Do
  Begin
    DimMatrix(A[I], Ub2, Ub3, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0, 0] := Ub1 * Ub2 * Ub3; // here is stored the total size of the matrix
  For I := 1 To Ub3 Do
    A[0, 0, I] := Ub3; // size of each row
  // It is already initialized on DimCompMatrix
  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: T3DBoolMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: Boolean);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Ub3 / 8 > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate 3Dmatrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each matrix }
  For I := 0 To Ub1 Do
  Begin
    DimMatrix(A[I], Ub2, Ub3, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  // It is already initialized on DimBoolMatrix
  SetErrCode(FOk);
End;

Procedure DimMatrix(Out A: T3DStrMatrix; Ub1, Ub2, Ub3: Cardinal;
  InitialValue: String);
Var
  I     : Integer;
  memory: tMemoryStatus;
Begin

  memory := SystemResources;
  If (Ub1 * Ub2 * Ub3 * 256 > memory.dwAvailPhys + memory.dwAvailPageFile) Then
  // No hay suficiente memoria fisica disponible
  Begin
    A := Nil;
    SetErrCode(FMemOverflow);
    Exit;
  End;

  { Allocate 3Dmatrix }
  setlength(A, Ub1 + 1);
  If A = Nil Then
    Exit;

  { Allocate each matrix }
  DimMatrix(A[0], Ub2, Ub3, inttostr(Ub1));
  // the zero matrix has the number of matrixes
  If A[0] = Nil Then
  Begin
    DelMatrix(A);
    SetErrCode(FMemOverflow);
    Exit;
  End;
  For I := 0 To Ub1 Do
  Begin
    DimMatrix(A[I], Ub2, Ub3, InitialValue);
    If A[I] = Nil Then
    Begin
      DelMatrix(A);
      SetErrCode(FMemOverflow);
      Exit;
    End;
  End;

  { Initialize matrix }
  A[0, 0, 0] := inttostr(Ub1 * Ub2 * Ub3);
  // here is stored the total size of the matrix
  // It is already initialized on DimStrMatrix
  SetErrCode(FOk);
End;

Procedure DelVector(Var V: TVector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelVector(Var V: TIntVector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelVector(Var V: TInt64Vector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelVector(Var V: TWordVector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelVector(Var V: TCompVector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelVector(Var V: TBoolVector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelVector(Var V: TStrVector);
Begin
  If V <> Nil Then
  Begin
    Finalize(V);
  End;
End;

Procedure DelMatrix(Var A: TMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelVector(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: TIntMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelVector(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: TWordMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelVector(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: TCompMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelVector(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: TBoolMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelVector(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: TStrMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelVector(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: T3DMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelMatrix(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: T3DIntMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelMatrix(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: T3DWordMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelMatrix(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: T3DCompMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelMatrix(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: T3DBoolMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelMatrix(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

Procedure DelMatrix(Var A: T3DStrMatrix);
Var
  I: Integer;
Begin
  For I := 0 To System.High(A) Do
    DelMatrix(A[I]);
  If A <> Nil Then
  Begin
    Finalize(A);
  End;
End;

End.
