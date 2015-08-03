unit usearch;

interface

uses utypes, uConstants;

type
  TSearch = class
  private
    jsav: integer;
    fcorrelated: boolean;
  public
    dj: integer;
    constructor Create(N: integer);
    function Locate(Xa: TVector; N: integer; X: float): integer;
    function Hunt(Xa: TVector; N: integer; X: float): integer;
    property Correlated: boolean read fcorrelated;
  end;

implementation

uses math;

constructor TSearch.Create(N: integer);
begin
  jsav := 1;
  fcorrelated := false;
  dj := min(1, floor(Power(N, 0.25)));
end;

function TSearch.Locate(Xa: TVector; N: integer; X: float): integer;
var
  ju, jm, jl: integer;
  ascnd: boolean;
begin
  if (N < 2 { || mm < 2 || mm > n } ) then
  begin
    result := 1;
    exit; // throw("locate size error");
  end;
  ascnd := (Xa[N] >= Xa[1]);
  // True if ascending order of table, false otherwise.
  jl := 1; // Initialize lower
  ju := N; // and upper limits.
  while (ju - jl > 1) do // If we are not yet done,
  begin
    jm := (ju + jl) shr 1; // compute a midpoint,
    if ((X >= Xa[jm]) = ascnd) then
      jl := jm // and replace either the lower limit
    else
      ju := jm; // or the upper limit, as appropriate.
  end; // Repeat until the test condition is satisfied.
  fcorrelated := not(abs(jl - jsav) > dj);
  // Decide whether to use hunt or locate next time.
  jsav := jl;
  result := max(1, min(N, jl));
end;

function TSearch.Hunt(Xa: TVector; N: integer; X: float): integer;
var
  jl, jm, ju, inc: integer;
  ascnd, breaking: boolean;
begin
  jl := jsav;
  inc := 1;
  breaking := false;
  if (N < 2 { || mm < 2 || mm > n } ) then
  begin
    result := 1;
    exit; // throw("hunt size error");
  end;
  ascnd := (Xa[N] >= Xa[1]);
  // True if ascending order of table, false otherwise.
  if (jl < 1) or (jl > N) then
  // Input guess not useful. Go immediately to bisection.
  begin
    jl := 1;
    ju := N;
  end
  else
  begin
    if ((X >= Xa[jl]) = ascnd) then // Hunt up:
      repeat
        ju := jl + inc;
        if (ju >= N) then
        begin
          ju := N;
          breaking := true;
        end // Off end of table.
        else if ((X < Xa[ju]) = ascnd) then
          breaking := true // Found bracket.
        else
        begin // Not done, so double the increment and try again.
          jl := ju;
          inc := inc shl 1;
        end;
      until breaking
    else
    begin // Hunt down:
      ju := jl;
      repeat
        jl := jl - inc;
        if (jl <= 1) then
        begin
          jl := 1;
          breaking := true;
        end // Off end of table.
        else if ((X >= Xa[jl]) = ascnd) then
          breaking := true // Found bracket.
        else
        begin // Not done, so double the increment and try again.
          ju := jl;
          inc := inc shl 1;
        end;
      until breaking;
    end;
  end;
  while (ju - jl > 1) do
  begin // Hunt is done, so begin the final bisection phase:
    jm := (ju + jl) shr 1;
    if ((X >= Xa[jm]) = ascnd) then
      jl := jm
    else
      ju := jm;
  end;
  fcorrelated := not(abs(jl - jsav) > dj);
  // Decide whether to use hunt or locate next time.
  jsav := jl;
  result := max(1, min(N, jl));
end;

end.
