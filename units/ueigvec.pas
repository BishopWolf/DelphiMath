{ ******************************************************************
  Eigenvalues and eigenvectors of a general square matrix
  ****************************************************************** }

unit ueigvec;

interface

uses
  utypes;

procedure EigenVect(A: TMatrix; Lb, Ub: Integer; out Lambda: TCompVector;
  out V: TMatrix);

implementation

uses
  uoperations, ubalance, uelmhes, ueltran, uhqr2, ubalbak, uConstants;

procedure EigenVect(A: TMatrix; Lb, Ub: Integer; out Lambda: TCompVector;
  out V: TMatrix);
var
  I_low, I_igh: Integer;
  Scale: TVector;
  I_Int: TIntVector;
  tempM: TMatrix;
begin
  DimVector(Scale, Ub);
  DimVector(I_Int, Ub);
  tempM := Clone(A, Ub, Ub);
  Balance(tempM, Lb, Ub, I_low, I_igh, Scale);
  ElmHes(tempM, Lb, Ub, I_low, I_igh, I_Int);
  Eltran(tempM, Lb, Ub, I_low, I_igh, I_Int, V);
  Hqr2(tempM, Lb, Ub, I_low, I_igh, Lambda, V);
  DelMatrix(tempM);
  if MathErr = 0 then
    BalBak(V, Lb, Ub, I_low, I_igh, Scale, Ub);

  DelVector(Scale);
  DelVector(I_Int);
end;

end.
