{ ******************************************************************
  Median
  ****************************************************************** }

unit umedian;

interface

uses
  utypes, uConstants;

function Median(var X: TVector; Lb, Ub: Integer): Float; overload;
function Median(var X: TIntVector; Lb, Ub: Integer): Integer; overload;
function Median(var X: TStrVector; Lb, Ub: Integer): string; overload;
{ ------------------------------------------------------------------
  returns the median value of vector X which is rearranged
  ------------------------------------------------------------------ }

function Modal(var X: TIntVector; Lb, Ub: Integer; Sorted: Boolean = false)
  : Integer; overload;
function Modal(var X: TStrVector; Lb, Ub: Integer; Sorted: Boolean = false)
  : string; overload;
{ ------------------------------------------------------------------
  Sorts vector X in ascending order (if it's not sorted already)
  and returns its modal value
  ------------------------------------------------------------------ }

function QSelect(var X: TVector; K, Lb, Ub: Integer): Float; overload;
function QSelect(var X: TIntVector; K, Lb, Ub: Integer): Integer; overload;
function QSelect(var X: TStrVector; K, Lb, Ub: Integer): string; overload;
{ ------------------------------------------------------------------
  Select the k-th smallest value in vector X which is rearranged
  ------------------------------------------------------------------ }

implementation

uses uqsort, uoperations, uminmax, urandom;

function QSelect(var X: TVector; K, Lb, Ub: Integer): Float;
var
  lRNG: TRandomGen;
  procedure Select(L, R: Integer);
  var
    I, J, N2: Integer;
    U, V: Float;
  begin
    I := L;
    J := R;
    N2 := K - L + 1;
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
    if I > N2 then
      Select(L, I); // nos pasamos, probar con la primera parte
    if I < N2 then
      Select(I, R); // no llegamos, probar con la segunda parte
    // si i=N2 entonces el k-ésimo menor ya está en X[K]
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Select(Lb, Ub);
  lRNG.Free;
  result := X[K];
end;

function QSelect(var X: TIntVector; K, Lb, Ub: Integer): Integer;
var
  lRNG: TRandomGen;
  procedure Select(L, R: Integer);
  var
    I, J, N2: Integer;
    U, V: Integer;
  begin
    I := L;
    J := R;
    N2 := K - L + 1;
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
    if I > N2 then
      Select(L, I); // nos pasamos, probar con la primera parte
    if I < N2 then
      Select(I, R); // no llegamos, probar con la segunda parte
    // si i=N2 entonces el k-ésimo menor ya está en X[K]
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Select(Lb, Ub);
  lRNG.Free;
  result := X[K];
end;

function QSelect(var X: TStrVector; K, Lb, Ub: Integer): string;
var
  lRNG: TRandomGen;
  procedure Select(L, R: Integer);
  var
    I, J, N2: Integer;
    U, V: String;
  begin
    I := L;
    J := R;
    N2 := K - L + 1;
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
    if I > N2 then
      Select(L, I); // nos pasamos, probar con la primera parte
    if I < N2 then
      Select(I, R); // no llegamos, probar con la segunda parte
    // si i=N2 entonces el k-ésimo menor ya está en X[K]
  end;

begin
  lRNG := TRandomGen.Create(1234543);
  Select(Lb, Ub);
  lRNG.Free;
  result := X[K];
end;

function Median(var X: TVector; Lb, Ub: Integer): Float;
var
  N, N2: Integer;
begin
  N := Ub - Lb + 1; // Tamaño real
  N2 := N div 2 + Lb; // Posicion de la mitad + 1
  Median := QSelect(X, N2, Lb, Ub); // La mediana es el n2 valor más pequeño
end;

function Median(var X: TIntVector; Lb, Ub: Integer): Integer;
var
  N, N2: Integer;
begin
  N := Ub - Lb + 1;
  N2 := N div 2 + Lb;
  Median := QSelect(X, N2, Lb, Ub);
end;

function Median(var X: TStrVector; Lb, Ub: Integer): String;
var
  N, N2: Integer;
begin
  N := Ub - Lb + 1;
  N2 := N div 2 + Lb;
  Median := QSelect(X, N2, Lb, Ub);
end;

function Modal(var X: TIntVector; Lb, Ub: Integer; Sorted: Boolean): Integer;
var
  N, I, cont, cont2, min, max: Integer;
  temp: Integer;
  ranked: TIntVector;
begin
  N := Ub - Lb + 1;
  MinMax(X, Lb, Ub, min, max);
  if min = max then
  begin // caso crítico
    result := min;
    exit;
  end;
  cont := max - min + 1;
  if (cont <= N) then
  begin // podemos aplicar el procedimiento rápido
    DimVector(ranked, cont);
    for I := 1 to N do
      inc(ranked[X[I] - min + 1]);
    max := uminmax.max(ranked, 1, cont, cont2);
    result := min + cont2 - 1;
    exit;
  end;
  if not Sorted then
    QSort(X, Lb, Ub);
  cont := 1;
  cont2 := 0;
  temp := X[1];
  for I := 2 to N do
  begin
    if X[I] = X[I - 1] then
      inc(cont)
    else
    begin
      if cont2 < cont then
      begin
        cont2 := cont;
        cont := 0;
        temp := X[I - 1];
      end;
    end;
  end;
  result := temp;
end;

function Modal(var X: TStrVector; Lb, Ub: Integer; Sorted: Boolean): string;
var
  N, I, cont, cont2: Integer;
  temp: string;
begin
  N := Ub - Lb + 1;
  if not Sorted then
    QSort(X, Lb, Ub);
  cont := 1;
  cont2 := 0;
  temp := X[1];
  for I := 2 to N do
  begin
    if X[I] = X[I - 1] then
      inc(cont)
    else
    begin
      if cont2 < cont then
      begin
        cont2 := cont;
        cont := 0;
        temp := X[I - 1];
      end;
    end;
  end;
  result := temp;
end;

end.
