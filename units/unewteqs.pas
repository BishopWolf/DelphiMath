{ ******************************************************************
  Newton-Raphson solver for system of nonlinear equations
  ****************************************************************** }

unit unewteqs;

interface

uses
  utypes, ulineq, ulinminq, ucompvec, umachar, uConstants;

procedure NewtEqs(Equations: TEquations; Jacobian: TJacobian; var X, F: TVector;
  Lb, Ub: Integer; MaxIter: Integer; Tol: Float);
{ ------------------------------------------------------------------
  Solves a system of nonlinear equations by Newton's method
  ------------------------------------------------------------------
  Input parameters  : Equations = subroutine to compute equations
  Jacobian  = subroutine to compute Jacobian
  X         = initial root
  MaxIter   = maximum number of iterations
  Tol       = required precision
  ------------------------------------------------------------------
  Output parameters : X = refined root
  F = function values
  ------------------------------------------------------------------
  Possible results : OptOk      = no error
  OptNonConv = non-convergence
  OptSing    = singular jacobian matrix
  ------------------------------------------------------------------ }

implementation

procedure NewtEqs(Equations: TEquations; Jacobian: TJacobian; var X, F: TVector;
  Lb, Ub: Integer; MaxIter: Integer; Tol: Float);

var
  I: Integer; { Loop variables }
  R: Float; { Step for line minimization }
  Det: Float; { Determinant of Jacobian }
  Iter: Integer; { Iteration count }
  Conv: Boolean; { Test convergence }
  OldX: TVector; { Old parameters }
  DeltaX: TVector; { New search direction }
  D: TMatrix; { Jacobian matrix }

  procedure Terminate(ErrCode: Integer);
  { Set error code and deallocate arrays }
  begin
    DelVector(OldX);
    DelVector(DeltaX);
    DelMatrix(D);
    SetErrCode(ErrCode);
  end;

begin
  { Initialize function vector }
  Equations(X, F);

  { Quit if no iteration required }
  if MaxIter < 1 then
  begin
    SetErrCode(OptOk);
    Exit;
  end;

  { Dimension arrays }
  DimVector(OldX, Ub);
  DimVector(DeltaX, Ub);
  DimMatrix(D, Ub, Ub);

  Iter := 0;

  repeat
    { Compute Jacobian }
    D := Jacobian(X);

    { Solve linear system }
    LinEq(D, F, Lb, Ub, Det);
    if MathErr <> MatOk then
    begin
      Terminate(OptSing);
      Exit;
    end;

    { Prepare next iteration }
    Iter := Iter + 1;
    if Iter > MaxIter then
    begin
      Terminate(OptNonConv);
      Exit;
    end;

    { Save current parameters and initialize the direction search }
    for I := Lb to Ub do
    begin
      OldX[I] := X[I];
      DeltaX[I] := -F[I];
    end;

    { Minimize in the direction specified by DeltaX,
      using an initial step of 0.1 }
    R := 0.1;
    LinMinEq(Equations, X, DeltaX, F, Lb, Ub, R, 10, 0.01);

    { Test for convergence }
    Conv := CompVec(X, OldX, Lb, Ub, Tol);
  until Conv;

  Terminate(OptOk);
end;

end.
