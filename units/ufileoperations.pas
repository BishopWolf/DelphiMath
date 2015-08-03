Unit ufileoperations;

{ Unit ufileoperations : file operation Unit

  Created by : Alex Vergara Gil

  Contains the file handling routines.
  This unit can process both binary and text files.

}

Interface

Uses utypes, sysutils, Controls, GaugeFloat, gauges;

Procedure ReadFromFile(Filename: TFilename; Out Vector: TVector;
  Out Ub: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Vector: TIntVector;
  Out Ub: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Vector: TWordVector;
  Out Ub: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Vector: TCompVector;
  Out Ub: integer); Overload;

Procedure SaveToFile(Filename: TFilename; Vector: TVector;
  Ub: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Vector: TIntVector;
  Ub: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Vector: TWordVector;
  Ub: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Vector: TCompVector;
  Ub: integer); Overload;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TMatrix;
  Out Ub1, Ub2: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: TIntMatrix;
  Out Ub1, Ub2: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: TWordMatrix;
  Out Ub1, Ub2: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: TBoolMatrix;
  Out Ub1, Ub2: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: TCompMatrix;
  Out Ub1, Ub2: integer); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: TStrMatrix;
  Out Ub1, Ub2: integer; Out title: String); Overload;

Procedure SaveToFile(Filename: TFilename; Matriz: TMatrix;
  Ub1, Ub2: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: TIntMatrix;
  Ub1, Ub2: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: TWordMatrix;
  Ub1, Ub2: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: TBoolMatrix;
  Ub1, Ub2: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: TCompMatrix;
  Ub1, Ub2: integer); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: TStrMatrix; Ub1, Ub2: integer;
  title: String); Overload;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DIntMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DWordMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DCompMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DBoolMatrix;
  Out Ub1, Ub2, Ub3: integer); Overload;

Procedure SaveToFile(Filename: TFilename; Matriz: T3DMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: T3DIntMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: T3DWordMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: T3DCompMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl); Overload;
Procedure SaveToFile(Filename: TFilename; Matriz: T3DBoolMatrix;
  Ub1, Ub2, Ub3: integer); Overload;

Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TVector;
  Out Ub1: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TIntVector;
  Out Ub1: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TWordVector;
  Out Ub1: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TCompVector;
  Out Ub1: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TStrVector;
  Out Ub1: integer; Out title: String); Overload;

Procedure SaveToTextFile(Filename: TFilename; Vector: TVector; Ub1: integer;
  title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Vector: TIntVector; Ub1: integer;
  title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Vector: TWordVector; Ub1: integer;
  title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Vector: TCompVector; Ub1: integer;
  title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Vector: TStrVector; Ub1: integer;
  title: String = ''); Overload;

Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TMatrix;
  Out Ub1, Ub2: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TIntMatrix;
  Out Ub1, Ub2: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TWordMatrix;
  Out Ub1, Ub2: integer; Out title: String); Overload;
Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TCompMatrix;
  Out Ub1, Ub2: integer; Out title: String); Overload;
// function SMReadFromTextFile(Filename:TFilename;out Ub1,Ub2:integer;out Title:string): TStrMatrix;//same as SMReadFromFile

Procedure SaveToTextFile(Filename: TFilename; Matriz: TMatrix;
  Ub1, Ub2: integer; title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Matriz: TIntMatrix;
  Ub1, Ub2: integer; title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Matriz: TWordMatrix;
  Ub1, Ub2: integer; title: String = ''); Overload;
Procedure SaveToTextFile(Filename: TFilename; Matriz: TCompMatrix;
  Ub1, Ub2: integer; title: String = ''); Overload;
// procedure SMSaveToTextFile(Filename:TFilename;Matriz: TStrMatrix;Ub1,Ub2:integer;Title:string='');//same as SMSaveToFile

Implementation

Uses Classes, uoperations, ucomplex, ustrings, uinterpolation, Dialogs, Forms,
  uConstants;

{ typed files }

Procedure ReadFromFile(Filename: TFilename; Out Vector: TVector;
  Out Ub: integer);
Var
  f: File Of float;
  i: integer;
  temp: float;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 1 Then
  Begin
    showmessage(format('File %s is not a Float Vector', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub := trunc(temp);
  DimVector(Vector, Ub);
  For i := 1 To Ub Do
    Read(f, Vector[i]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Vector: TVector; Ub: integer);
Var
  f: File Of float;
  i: integer;
  temp: float;

Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := 1;
  Write(f, temp);
  temp := Ub;
  Write(f, temp);
  For i := 1 To Ub Do
    Write(f, Vector[i]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Vector: TIntVector;
  Out Ub: integer);
Var
  f: File Of integer;
  i: integer;
  temp: integer;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 1 Then
  Begin
    showmessage(format('File %s is not an Integer Vector', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub := temp;
  DimVector(Vector, Ub);
  For i := 1 To Ub Do
    Read(f, Vector[i]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Vector: TIntVector; Ub: integer);
Var
  f: File Of integer;
  i: integer;
  temp: integer;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := 1;
  Write(f, temp);
  temp := Ub;
  Write(f, temp);
  For i := 1 To Ub Do
    Write(f, Vector[i]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Vector: TWordVector;
  Out Ub: integer);
Var
  f: File Of word;
  i: integer;
  temp: word;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 1 Then
  Begin
    showmessage(format('File %s is not a Word Vector', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub := temp;
  DimVector(Vector, Ub);
  For i := 1 To Ub Do
    Read(f, Vector[i]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Vector: TWordVector; Ub: integer);
Var
  f: File Of word;
  i: integer;
  temp: word;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := 1;
  Write(f, temp);
  temp := Ub;
  Write(f, temp);
  For i := 1 To Ub Do
    Write(f, Vector[i]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Vector: TCompVector;
  Out Ub: integer);
Var
  f: File Of Complex;
  i: integer;
  temp: Complex;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp = tcomplex(1, 0) Then
  Begin
    showmessage(format('File %s is not a Complex Vector', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub := trunc(temp.Real);
  DimVector(Vector, Ub, 0);
  For i := 1 To Ub Do
    Read(f, Vector[i]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Vector: TCompVector; Ub: integer);
Var
  f: File Of Complex;
  i: integer;
  temp: Complex;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := tcomplex(1, 0);
  Write(f, temp);
  temp := tcomplex(Ub, 0);
  Write(f, temp);
  For i := 1 To Ub Do
    Write(f, Vector[i]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TMatrix;
  Out Ub1, Ub2: integer);
Var
  f: File Of float;
  i, j: integer;
  temp: float;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 2 Then
  Begin
    showmessage(format('File %s is not a Float Matrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := trunc(temp);
  Read(f, temp);
  Ub2 := trunc(temp);
  DimMatrix(Matrix, Ub1, Ub2);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Read(f, Matrix[i, j]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: TMatrix; Ub1, Ub2: integer);
Var
  f: File Of float;
  i, j: integer;
  temp: float;

Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := 2;
  Write(f, temp);
  temp := Ub1;
  Write(f, temp);
  temp := Ub2;
  Write(f, temp);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Write(f, Matriz[i, j]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TIntMatrix;
  Out Ub1, Ub2: integer);
Var
  f: File Of integer;
  i, j: integer;
  temp: integer;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 2 Then
  Begin
    showmessage(format('File %s is not an Integer Matrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := temp;
  Read(f, temp);
  Ub2 := temp;
  DimMatrix(Matrix, Ub1, Ub2);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Read(f, Matrix[i, j]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: TIntMatrix;
  Ub1, Ub2: integer);
Var
  f: File Of integer;
  i, j, temp: integer;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := 2;
  Write(f, temp);
  Write(f, Ub1);
  Write(f, Ub2);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Write(f, Matriz[i, j]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TWordMatrix;
  Out Ub1, Ub2: integer);
Var
  f: File Of word;
  i, j: integer;
  temp: word;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 2 Then
  Begin
    showmessage(format('File %s is not an Word Matrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := temp;
  Read(f, temp);
  Ub2 := temp;
  DimMatrix(Matrix, Ub1, Ub2);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Read(f, Matrix[i, j]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: TWordMatrix;
  Ub1, Ub2: integer);
Var
  f: File Of word;
  i, j: integer;
  temp: word;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp := 2;
  Write(f, temp);
  temp := Ub1;
  Write(f, temp);
  temp := Ub2;
  Write(f, temp);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Write(f, Matriz[i, j]);
  CloseFile(f);
End;

Function bool(x: float): boolean;
Begin
  result := Not(x = 0);
  // if x=0 then result:=false else result:=true;
End;

Function invbool(x: boolean): integer;
Begin
  // result = ord(x);
  If x Then
    result := 1
  Else
    result := 0;
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TBoolMatrix;
  Out Ub1, Ub2: integer);
Var
  f: File Of byte;
  temp: byte;
  i, j: integer;
  Function read4: integer;
  Var
    res: integer;
  Begin
    Read(f, temp);
    res := temp;
    Read(f, temp);
    res := res Or (temp Shl 8);
    Read(f, temp);
    res := res Or (temp Shl 16);
    Read(f, temp);
    result := res Or (temp Shl 24);
  End;

Begin
  AssignFile(f, Filename);
  reset(f);
  Ub1 := read4;
  Ub2 := read4;
  DimMatrix(Matrix, Ub1, Ub2);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
    Begin
      Read(f, temp);
      Matrix[i, j] := bool(temp);
    End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: TBoolMatrix;
  Ub1, Ub2: integer);
Var
  f: File Of byte;
  temp: byte;
  i, j: integer;
  Procedure write4(x: integer);
  Begin
    temp := x And $FF;
    Write(f, temp);
    temp := (x Shr 8) And $FF;
    Write(f, temp);
    temp := (x Shr 16) And $FF;
    Write(f, temp);
    temp := (x Shr 24) And $FF;
    Write(f, temp);
  End;

Begin
  AssignFile(f, Filename);
  rewrite(f);
  write4(Ub1);
  write4(Ub2);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
    Begin
      temp := invbool(Matriz[i, j]);
      Write(f, temp);
    End;
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TCompMatrix;
  Out Ub1, Ub2: integer);
Var
  f: File Of Complex;
  i, j: integer;
  temp: Complex;
Begin
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  Ub1 := trunc(temp.Real);
  Ub2 := trunc(temp.Imaginary);
  DimMatrix(Matrix, Ub1, Ub2, 0);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Read(f, Matrix[i, j]);
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: TCompMatrix;
  Ub1, Ub2: integer);
Var
  f: File Of Complex;
  i, j: integer;
  temp: Complex;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  temp.Real := Ub1;
  temp.Imaginary := Ub2;
  Write(f, temp);
  For j := 1 To Ub2 Do
    For i := 1 To Ub1 Do
      Write(f, Matriz[i, j]);
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: TStrMatrix;
  Out Ub1, Ub2: integer; Out title: String);
Var
  f: textfile;
  i, j, posc, cont: integer;
  linea, char: String;
Begin
  AssignFile(f, Filename);
  reset(f);
  readln(f, linea);
  If linea = '2' Then
  Begin
    readln(f, linea);
    posc := pos(' ', linea);
    Ub1 := Str2Int(copy(linea, 1, posc - 1));
    Ub2 := Str2Int(copy(linea, posc + 1, length(linea) - posc));
    DimMatrix(Matrix, Ub1, Ub2);
    readln(f, title); // description title
    For i := 1 To Ub1 Do
    Begin
      readln(f, linea);
      If linea = '' Then
        continue;
      char := '';
      cont := 0;
      If linea[length(linea)] <> #10 Then
        linea := linea + #10;
      For j := 1 To length(linea) Do
        If charinset(linea[j], [#9, #10, ' ', ',', ';']) Then
        Begin
          If char = '' Then
            continue;
          inc(cont);
          If cont > Ub2 Then
            break;
          Matrix[i, cont] := char;
          char := '';
        End
        Else
          char := char + linea[j];
    End;
  End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: TStrMatrix; Ub1, Ub2: integer;
  title: String);
Var
  f: textfile;
  i, j: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, '2');
  writeln(f, format('%d %d', [Ub1, Ub2]));
  writeln(f, title);
  For j := 1 To Ub2 Do
  Begin
    linea := '';
    For i := 1 To Ub1 Do
      linea := linea + Matriz[i, j] + #10;
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of float;
  i, j, k: integer;
  temp: float;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 3 Then
  Begin
    showmessage(format('File %s is not a Float 3DMatrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := trunc(temp);
  Read(f, temp);
  Ub2 := trunc(temp);
  Read(f, temp);
  Ub3 := trunc(temp);
  DimMatrix(Matrix, Ub1, Ub2, Ub3);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Read(f, Matrix[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else If (Progreso Is TGauge) Then
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: T3DMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of float;
  i, j, k: integer;
  temp: float;
  ShowProgress: boolean;

Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  rewrite(f);
  temp := 3;
  Write(f, temp);
  temp := Ub1;
  Write(f, temp);
  temp := Ub2;
  Write(f, temp);
  temp := Ub3;
  Write(f, temp);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Write(f, Matriz[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DIntMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of integer;
  i, j, k: integer;
  temp: integer;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 3 Then
  Begin
    showmessage(format('File %s is not an Integer 3DMatrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := temp;
  Read(f, temp);
  Ub2 := temp;
  Read(f, temp);
  Ub3 := temp;
  DimMatrix(Matrix, Ub1, Ub2, Ub3);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Read(f, Matrix[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: T3DIntMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of integer;
  i, j, k: integer;
  temp: integer;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  rewrite(f);
  temp := 3;
  Write(f, temp);
  temp := Ub1;
  Write(f, temp);
  temp := Ub2;
  Write(f, temp);
  temp := Ub3;
  Write(f, temp);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Write(f, Matriz[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DWordMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of word;
  i, j, k: integer;
  temp: word;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp <> 3 Then
  Begin
    showmessage(format('File %s is not a Word 3DMatrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := temp;
  Read(f, temp);
  Ub2 := temp;
  Read(f, temp);
  Ub3 := temp;
  DimMatrix(Matrix, Ub1, Ub2, Ub3);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Read(f, Matrix[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: T3DWordMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of word;
  i, j, k: integer;
  temp: word;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  rewrite(f);
  temp := 3;
  Write(f, temp);
  temp := Ub1;
  Write(f, temp);
  temp := Ub2;
  Write(f, temp);
  temp := Ub3;
  Write(f, temp);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Write(f, Matriz[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DCompMatrix;
  Out Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of Complex;
  i, j, k: integer;
  temp: Complex;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  reset(f);
  Read(f, temp);
  If temp = tcomplex(3, 0) Then
  Begin
    showmessage(format('File %s is not a Word 3DMatrix', [Filename]));
    exit
  End;
  Read(f, temp);
  Ub1 := trunc(temp.Real);
  Read(f, temp);
  Ub2 := trunc(temp.Real);
  Read(f, temp);
  Ub3 := trunc(temp.Real);
  DimMatrix(Matrix, Ub1, Ub2, Ub3, 0);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Read(f, Matrix[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: T3DCompMatrix;
  Ub1, Ub2, Ub3: integer; Progreso: TGraphicControl);
Var
  f: File Of Complex;
  i, j, k: integer;
  temp: Complex;
  ShowProgress: boolean;
Begin
  ShowProgress := (Progreso <> Nil);
  AssignFile(f, Filename);
  rewrite(f);
  temp := tcomplex(3, 0);
  Write(f, temp);
  temp := tcomplex(Ub1, 0);
  Write(f, temp);
  temp := tcomplex(Ub2, 0);
  Write(f, temp);
  temp := tcomplex(Ub3, 0);
  Write(f, temp);
  For k := 1 To Ub3 Do
  Begin
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
        Write(f, Matriz[i, j, k]);
    If ShowProgress Then
    Begin
      If (Progreso Is TGaugeFloat) Then
        (Progreso As TGaugeFloat).Progress :=
          LinealInterpolation(1, (Progreso As TGaugeFloat).MinValue, Ub3,
          (Progreso As TGaugeFloat).MaxValue, k)
      Else
        (Progreso As TGauge).Progress :=
          round(LinealInterpolation(1, (Progreso As TGauge).MinValue, Ub3,
          (Progreso As TGauge).MaxValue, k));
      Application.ProcessMessages;
    End;
  End;
  CloseFile(f);
End;

Procedure ReadFromFile(Filename: TFilename; Out Matrix: T3DBoolMatrix;
  Out Ub1, Ub2, Ub3: integer);
Var
  f: File Of byte;
  temp: byte;
  i, j, k: integer;
  Function read4: integer;
  Var
    res: integer;
  Begin
    Read(f, temp);
    res := temp;
    Read(f, temp);
    res := res Or (temp Shl 8);
    Read(f, temp);
    res := res Or (temp Shl 16);
    Read(f, temp);
    result := res Or (temp Shl 24);
  End;

Begin
  AssignFile(f, Filename);
  reset(f);
  Ub1 := read4;
  Ub2 := read4;
  Ub3 := read4;
  DimMatrix(Matrix, Ub1, Ub2, Ub3);
  For k := 1 To Ub3 Do
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
      Begin
        Read(f, temp);
        Matrix[i, j, k] := bool(temp);
      End;
  CloseFile(f);
End;

Procedure SaveToFile(Filename: TFilename; Matriz: T3DBoolMatrix;
  Ub1, Ub2, Ub3: integer);
Var
  f: File Of byte;
  i, j, k: integer;
  temp: byte; // Boolean is 1 byte long so no optimization is possible here
  Procedure write4(x: integer);
  Begin
    temp := x And $FF;
    Write(f, temp);
    temp := (x Shr 8) And $FF;
    Write(f, temp);
    temp := (x Shr 16) And $FF;
    Write(f, temp);
    temp := (x Shr 24) And $FF;
    Write(f, temp);
  End;

Begin
  AssignFile(f, Filename);
  rewrite(f);
  write4(Ub1);
  write4(Ub2);
  write4(Ub3);
  For k := 1 To Ub3 Do
    For j := 1 To Ub2 Do
      For i := 1 To Ub1 Do
      Begin
        temp := invbool(Matriz[i, j, k]);
        Write(f, temp);
      End;
  CloseFile(f);
End;

{ text files }

Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TVector;
  Out Ub1: integer; Out title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  reset(f);
  readln(f, linea);
  Ub1 := Str2Int(linea);
  readln(f, title);
  DimVector(Vector, Ub1);
  For i := 1 To Ub1 Do
  Begin
    readln(f, linea);
    Vector[i] := Str2Float(linea);
  End;
  CloseFile(f);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TIntVector;
  Out Ub1: integer; Out title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  reset(f);
  readln(f, linea);
  Ub1 := Str2Int(linea);
  readln(f, title);
  DimVector(Vector, Ub1);
  For i := 1 To Ub1 Do
  Begin
    readln(f, linea);
    Vector[i] := Str2Int(linea);
  End;
  CloseFile(f);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TWordVector;
  Out Ub1: integer; Out title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  reset(f);
  readln(f, linea);
  Ub1 := Str2Int(linea);
  readln(f, title);
  DimVector(Vector, Ub1);
  For i := 1 To Ub1 Do
  Begin
    readln(f, linea);
    Vector[i] := Str2Int(linea);
  End;
  CloseFile(f);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TCompVector;
  Out Ub1: integer; Out title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  reset(f);
  readln(f, linea);
  Ub1 := Str2Int(linea);
  readln(f, title);
  DimVector(Vector, Ub1, 0);
  For i := 1 To Ub1 Do
  Begin
    readln(f, linea);
    Vector[i] := Str2Complex(linea);
  End;
  CloseFile(f);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Vector: TStrVector;
  Out Ub1: integer; Out title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  reset(f);
  readln(f, linea);
  Ub1 := Str2Int(linea);
  readln(f, title);
  DimVector(Vector, Ub1);
  For i := 1 To Ub1 Do
  Begin
    readln(f, Vector[i]);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Vector: TVector; Ub1: integer;
  title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, format('%d', [Ub1]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := ArreglaString(floattostr(Vector[i])) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Vector: TIntVector; Ub1: integer;
  title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, format('%d', [Ub1]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := ArreglaString(inttostr(Vector[i])) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Vector: TWordVector; Ub1: integer;
  title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, format('%d', [Ub1]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := ArreglaString(inttostr(Vector[i])) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Vector: TCompVector; Ub1: integer;
  title: String);
Var
  f: textfile;
  i: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, format('%d', [Ub1]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := Complex2String(Vector[i]);
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Vector: TStrVector; Ub1: integer;
  title: String);
Var
  f: textfile;
  i: integer;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, format('%d', [Ub1]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    writeln(f, Vector[i]);
  End;
  CloseFile(f);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TMatrix;
  Out Ub1, Ub2: integer; Out title: String);
Var
  i, j: integer;
  tmat: TStrMatrix;
Begin
  ReadFromFile(Filename, tmat, Ub1, Ub2, title);
  DimMatrix(Matrix, Ub1, Ub2);
  For i := 1 To Ub1 Do
    For j := 1 To Ub2 Do
      Matrix[i, j] := Str2Float(tmat[i, j]);
  DelMatrix(tmat);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TIntMatrix;
  Out Ub1, Ub2: integer; Out title: String);
Var
  i, j: integer;
  tmat: TStrMatrix;
Begin
  ReadFromFile(Filename, tmat, Ub1, Ub2, title);
  DimMatrix(Matrix, Ub1, Ub2);
  For i := 1 To Ub1 Do
    For j := 1 To Ub2 Do
      Matrix[i, j] := Str2Int(tmat[i, j]);
  DelMatrix(tmat);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TWordMatrix;
  Out Ub1, Ub2: integer; Out title: String);
Var
  i, j: integer;
  tmat: TStrMatrix;
Begin
  ReadFromFile(Filename, tmat, Ub1, Ub2, title);
  DimMatrix(Matrix, Ub1, Ub2);
  For i := 1 To Ub1 Do
    For j := 1 To Ub2 Do
      Matrix[i, j] := Str2Word(tmat[i, j]);
  DelMatrix(tmat);
End;

Procedure ReadFromTextFile(Filename: TFilename; Out Matrix: TCompMatrix;
  Out Ub1, Ub2: integer; Out title: String);
Var
  i, j: integer;
  tmat: TStrMatrix;
Begin
  ReadFromFile(Filename, tmat, Ub1, Ub2, title);
  DimMatrix(Matrix, Ub1, Ub2, tcomplex(0, 0));
  For i := 1 To Ub1 Do
    For j := 1 To Ub2 Do
      Matrix[i, j] := Str2Complex(tmat[i, j]);
  DelMatrix(tmat);
End;

Procedure SaveToTextFile(Filename: TFilename; Matriz: TMatrix;
  Ub1, Ub2: integer; title: String);
Var
  f: textfile;
  i, j: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, '2');
  writeln(f, format('%d %d', [Ub1, Ub2]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := '';
    For j := 1 To Ub2 Do
      linea := linea + ArreglaString(floattostr(Matriz[i, j])) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Matriz: TIntMatrix;
  Ub1, Ub2: integer; title: String);
Var
  f: textfile;
  i, j: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, '2');
  writeln(f, format('%d %d', [Ub1, Ub2]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := '';
    For j := 1 To Ub2 Do
      linea := linea + ArreglaString(inttostr(Matriz[i, j])) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Matriz: TWordMatrix;
  Ub1, Ub2: integer; title: String);
Var
  f: textfile;
  i, j: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, '2');
  writeln(f, format('%d %d', [Ub1, Ub2]));
  writeln(f, title);
  For i := 1 To Ub1 Do
  Begin
    linea := '';
    For j := 1 To Ub2 Do
      linea := linea + ArreglaString(inttostr(Matriz[i, j])) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

Procedure SaveToTextFile(Filename: TFilename; Matriz: TCompMatrix;
  Ub1, Ub2: integer; title: String);
Var
  f: textfile;
  i, j: integer;
  linea: String;
Begin
  AssignFile(f, Filename);
  rewrite(f);
  writeln(f, '2');
  writeln(f, format('%d %d', [Ub1, Ub2]));
  writeln(f, title);;
  For i := 1 To Ub1 Do
  Begin
    linea := '';
    For j := 1 To Ub2 Do
      linea := linea + Complex2String(Matriz[i, j]) + ' ';
    writeln(f, linea);
  End;
  CloseFile(f);
End;

End.
