Unit uHistogram;

{ Unit uHistogram : Histogram procesing Unit

  Created by : Alex Vergara Gil

  Contains the routines for Histogram procesing

}

Interface

Uses utypes, uComplex, uConstants, ugraphics;

Const
  Numbin = 512;

Function Histograma(F: TVector; n: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: TMatrix; m, n: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: T3DMatrix; m, n, o: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: TIntVector; n: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: TIntMatrix; m, n: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: T3DIntMatrix; m, n, o: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: TWordVector; n: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: TWordMatrix; m, n: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;
Function Histograma(F: T3DWordMatrix; m, n, o: integer; min, max: float;
  BinNumber: integer = Numbin; HistogramType: THistogramType = THTDifferential)
  : TIntVector; Overload;

Function DVH(F: TVector; n: integer; BinNumber: integer = Numbin;
  Level: integer = 30): TVector; Overload;
Function DVH(F: TMatrix; m, n: integer; BinNumber: integer = Numbin;
  Level: integer = 30): TVector; Overload;
Function DVH(F: T3DMatrix; m, n, o: integer; BinNumber: integer = Numbin;
  Level: integer = 30): TVector; Overload;
Function DVH(F: T3DMatrix; m, n, o: integer; lROI: TPolyROI;
  Out min, max, lmean, vol: float; BinNumber: integer = Numbin;
  Level: integer = 30): TVector; Overload;
Function DVH(F, Ref: T3DMatrix; m, n, o: integer; lROI: TPolyROI;
  Out min, max, lmean, vol: float; Var Level: integer;
  BinNumber: integer = Numbin): TVector; Overload;

Implementation

Uses uinterpolation, umath, uminmax;

Function Histograma(F: TVector; n: integer; min, max: float; BinNumber: integer;
  HistogramType: THistogramType): TIntVector;
Var
  i: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To n Do
  Begin
    If InRange(F[i], min, max) Then
      inc(result[round(LinealInterpolation(min, 1, max, BinNumber, F[i]))]);
  End;
  If (HistogramType = THTAcumulative) Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: TMatrix; m, n: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i, j: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To m Do
    For j := 1 To n Do
      If InRange(F[i, j], min, max) Then
        inc(result[round(LinealInterpolation(min, 1, max, BinNumber,
          F[i, j]))]);
  If HistogramType = THTAcumulative Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: T3DMatrix; m, n, o: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i, j, k: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To m Do
    For j := 1 To n Do
      For k := 1 To o Do
      Begin
        If InRange(F[i, j, k], min, max) Then
          inc(result[round(LinealInterpolation(min, 1, max, BinNumber,
            F[i, j, k]))]);
      End;
  If HistogramType = THTAcumulative Then
  Begin

    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: TIntVector; n: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To n Do
  Begin
    If InRange(F[i], min, max) Then
      inc(result[round(LinealInterpolation(min, 1, max, BinNumber, F[i]))]);
  End;
  If (HistogramType = THTAcumulative) Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: TIntMatrix; m, n: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i, j: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To m Do
    For j := 1 To n Do
      If InRange(F[i, j], min, max) Then
        inc(result[round(LinealInterpolation(min, 1, max, BinNumber,
          F[i, j]))]);
  If HistogramType = THTAcumulative Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: T3DIntMatrix; m, n, o: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i, j, k: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To m Do
    For j := 1 To n Do
      For k := 1 To o Do
      Begin
        If InRange(F[i, j, k], min, max) Then
          inc(result[round(LinealInterpolation(min, 1, max, BinNumber,
            F[i, j, k]))]);
      End;
  If HistogramType = THTAcumulative Then
  Begin

    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: TWordVector; n: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To n Do
  Begin
    If InRange(F[i], min, max) Then
      inc(result[round(LinealInterpolation(min, 1, max, BinNumber, F[i]))]);
  End;
  If (HistogramType = THTAcumulative) Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: TWordMatrix; m, n: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i, j: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To m Do
    For j := 1 To n Do
      If InRange(F[i, j], min, max) Then
        inc(result[round(LinealInterpolation(min, 1, max, BinNumber,
          F[i, j]))]);
  If HistogramType = THTAcumulative Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function Histograma(F: T3DWordMatrix; m, n, o: integer; min, max: float;
  BinNumber: integer; HistogramType: THistogramType): TIntVector;
Var
  i, j, k: integer;
  Total: integer;
Begin
  DimVector(result, BinNumber);
  For i := 1 To m Do
    For j := 1 To n Do
      For k := 1 To o Do
      Begin
        If InRange(F[i, j, k], min, max) Then
          inc(result[round(LinealInterpolation(min, 1, max, BinNumber,
            F[i, j, k]))]);
      End;
  If HistogramType = THTAcumulative Then
  Begin
    For i := 2 To BinNumber Do
      result[i] := result[i] + result[i - 1];
    Total := result[BinNumber];
    For i := 1 To BinNumber Do
      result[i] := round(divide(result[i] * 100, Total));
  End;
End;

Function DVH(F: TVector; n: integer; BinNumber, Level: integer): TVector;
Var
  res: TIntVector;
  i, lev: integer;
  min, max, _total: float;
Begin
  MinMax(F, 1, n, min, max);
  lev := round(LinealInterpolation(min, 1, max, BinNumber, max * Level / 100));
  res := Histograma(F, n, min, max, BinNumber, THTDifferential);
  For i := BinNumber - 1 Downto lev Do
    res[i] := res[i] + res[i + 1];
  _total := divide(100, res[lev]);
  DimVector(result, BinNumber);
  For i := BinNumber - 1 Downto lev Do
    result[i] := res[i] * _total;
  For i := 1 To lev - 1 Do
    result[i] := 100;
  DelVector(res);
End;

Function DVH(F: TMatrix; m, n: integer; BinNumber, Level: integer): TVector;
Var
  res: TIntVector;
  i, lev: integer;
  min, max, _total: float;
Begin
  MinMax(F, 1, m, 1, n, min, max);
  lev := round(LinealInterpolation(min, 1, max, BinNumber, max * Level / 100));
  res := Histograma(F, m, n, min, max, BinNumber, THTDifferential);
  For i := BinNumber - 1 Downto lev Do
    res[i] := res[i] + res[i + 1];
  _total := divide(100, res[lev]);
  DimVector(result, BinNumber);
  For i := BinNumber - 1 Downto lev Do
    result[i] := res[i] * _total;
  For i := 1 To lev - 1 Do
    result[i] := 100;
  DelVector(res);
End;

Function DVH(F: T3DMatrix; m, n, o: integer; BinNumber, Level: integer)
  : TVector;
Var
  res: TIntVector;
  i, lev: integer;
  min, max, _total: float;
Begin
  MinMax(F, 1, m, 1, n, 1, o, min, max);
  lev := round(LinealInterpolation(min, 1, max, BinNumber, max * Level / 100));
  res := Histograma(F, m, n, o, min, max, BinNumber, THTDifferential);
  For i := BinNumber - 1 Downto lev Do
    res[i] := res[i] + res[i + 1];
  _total := divide(100, res[lev]);
  DimVector(result, BinNumber);
  For i := BinNumber - 1 Downto lev Do
    result[i] := res[i] * _total;
  For i := 1 To lev - 1 Do
    result[i] := 100;
  DelVector(res);
End;

Function DVH(F: T3DMatrix; m, n, o: integer; lROI: TPolyROI;
  Out min, max, lmean, vol: float; BinNumber, Level: integer): TVector;
Var
  res: TIntVector;
  i, j, k, lev, cont: integer;
  _total, lmin: float;
  lbounds: TBox;
Begin
  min := F[1, 1, 1];
  max := F[1, 1, 1];
  lROI.MinMax(lbounds);
  For i := round(lbounds.ini.X) To round(lbounds.fin.X) Do
    For j := round(lbounds.ini.y) To round(lbounds.fin.y) Do
      For k := round(lbounds.ini.z) To round(lbounds.fin.z) Do
      Begin
        If lROI.PointInside(i, j, k) Then
        Begin
          If F[i, j, k] > max Then
            max := F[i, j, k];
          If F[i, j, k] < min Then
            min := F[i, j, k];
        End;
      End;
  lmin := max * Level / 100;
  lev := round(LinealInterpolation(min, 1, max, BinNumber, lmin));
  DimVector(res, BinNumber);
  _total := 0;
  cont := 0;
  For i := round(lbounds.ini.X) To round(lbounds.fin.X) Do
    For j := round(lbounds.ini.y) To round(lbounds.fin.y) Do
      For k := round(lbounds.ini.z) To round(lbounds.fin.z) Do
      Begin
        If lROI.PointInside(i, j, k) Then
        Begin
          inc(res[round(LinealInterpolation(min, 1, max, BinNumber,
            F[i, j, k]))]);
          If F[i, j, k] > lmin Then
          Begin
            _total := _total + F[i, j, k];
            inc(cont);
          End;
        End;
      End;
  lmean := divide(_total, cont);
  vol := cont;
  For i := BinNumber - 1 Downto lev Do
    res[i] := res[i] + res[i + 1];
  _total := divide(100, res[lev]);
  DimVector(result, BinNumber);
  For i := BinNumber - 1 Downto lev Do
    result[i] := res[i] * _total;
  For i := 1 To lev - 1 Do
    result[i] := 100;
  DelVector(res);
End;

Function DVH(F, Ref: T3DMatrix; m, n, o: integer; lROI: TPolyROI;
  Out min, max, lmean, vol: float; Var Level: integer;
  BinNumber: integer): TVector;
Var
  res: TIntVector;
  i, j, k, lev, cont: integer;
  _total, lmin, min1, tmin, max1: float;
  lbounds: TBox;
Begin
  lROI.MinMax(lbounds);
  // falta LinealInterpolation
  min1 := Ref[round(lbounds.ini.X), round(lbounds.ini.y), round(lbounds.ini.z)];
  max1 := Ref[round(lbounds.ini.X), round(lbounds.ini.y), round(lbounds.ini.z)];
  min := F[round(lbounds.ini.X), round(lbounds.ini.y), round(lbounds.ini.z)];
  max := F[round(lbounds.ini.X), round(lbounds.ini.y), round(lbounds.ini.z)];
  For i := round(lbounds.ini.X) To round(lbounds.fin.X) Do
    For j := round(lbounds.ini.y) To round(lbounds.fin.y) Do
      For k := round(lbounds.ini.z) To round(lbounds.fin.z) Do
      Begin
        If lROI.PointInside(i, j, k) Then
        Begin
          If Ref[i, j, k] > max1 Then
            max1 := Ref[i, j, k];
          If Ref[i, j, k] < min1 Then
            min1 := Ref[i, j, k];
          If F[i, j, k] > max Then
            max := F[i, j, k];
          If F[i, j, k] < min Then
            min := F[i, j, k];
        End;
      End;
  lmin := LinealInterpolation(0, 0, 100, max1, Level);
  DimVector(res, BinNumber);
  _total := 0;
  cont := 0;
  tmin := min;
  min := max;
  For i := round(lbounds.ini.X) To round(lbounds.fin.X) Do
    For j := round(lbounds.ini.y) To round(lbounds.fin.y) Do
      For k := round(lbounds.ini.z) To round(lbounds.fin.z) Do
      Begin
        If lROI.PointInside(i, j, k) Then
        Begin
          inc(res[round(LinealInterpolation(tmin, 1, max, BinNumber,
            F[i, j, k]))]);
          If Ref[i, j, k] > lmin Then
          Begin
            _total := _total + F[i, j, k];
            inc(cont);
            If F[i, j, k] < min Then
              min := F[i, j, k];
          End;
        End;
      End;
  lmean := divide(_total, cont);
  Level := round(min * 100 / max);
  vol := cont;
  lev := round(LinealInterpolation(tmin, 1, max, BinNumber, min));
  // lev := round(LinealInterpolation(min1, 1, max1, BinNumber, lmin));
  For i := BinNumber - 1 Downto lev Do
    res[i] := res[i] + res[i + 1];
  _total := divide(100, res[lev]);
  DimVector(result, BinNumber);
  For i := BinNumber - 1 Downto lev Do
    result[i] := res[i] * _total;
  For i := 1 To lev - 1 Do
    result[i] := 100;
  DelVector(res);
End;

End.
