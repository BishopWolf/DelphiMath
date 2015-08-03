
{ Sumatory of Gaussians   X = variable x
                          A[i] = B(k)
                          A[i+1] = E(k)
                          A[i+2] = G(k)
                          k = NumberOfGaussians
                          i=1..3*k=1..na
                          out dyda = derivatives with respect of coeficients
                          N is considered if BaseType=polinomial and is the order of the polinomium
                          if BaseType<>flat then the array A has also the coeficients of the base function }

function Gaussians(X : Float; A :TVector;var dyda :TVector;
                   na : Integer; BaseType: Adjust_Base; N:Integer=0) : Float;
var i,j:integer;y,arg,ex,fac:float;
begin
  y:=0;i:=1;
  repeat
     arg:= (x-a[i+1])/a[i+2];
     ex := system.exp(-arg*arg);
     fac:= a[i]*ex*2.0*arg;
     y  := y+a[i]*ex;
     dyda[i]:=ex;
     dyda[i+1]:=fac/a[i+2];
     dyda[i+2]:=fac*arg/a[i+2];
     inc(i,3);
  until i>=na;
  case BaseType of
      flat:begin
          y:=y+N;
          dyda[i]:=0;
      end;
      Linear:begin
          y:=y+A[i]*x+A[i+1];
          dyda[i]:=A[i];
          dyda[i+1]:=0;
      end;
      polinomial:begin
          j:=0;
          repeat
             fac:=intPower(x,j);
             y:=y+A[i]*fac;
             dyda[i]:=fac;
             inc(j);inc(i);
          until j>N;
      end;
      Exponential:begin
          ex := system.exp((x-A[i+2])/A[i+1]);
          y:=y+A[i]*ex;
          dyda[i]:=ex;
          dyda[i+1]:=-A[i]*ex*(x-A[i+2])/sqr(A[i+1]);
          dyda[i+2]:=-A[i]*ex/A[i+1]
      end;
  end;
  result:=y;
end;