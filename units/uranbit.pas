unit uranbit;

{ Generation of random bits }

interface

uses utypes, urandom;

type
  TRanBit = class(TRandomGen)
  private
    FSeed: Cardinal;
    procedure SetSeed(const Value: Cardinal);
  public
    constructor Create(USeed: Cardinal);
    property Seed: Cardinal read FSeed write SetSeed;
    function RandomBit1: MiBool; // returns 0 or 1 randomly
    function RandomBit2: MiBool; // returns 0 or 1 randomly
    function RandomChoice: boolean; // returns true or False randomly
  end;

implementation

constructor TRanBit.Create(USeed: Cardinal);
begin
  inherited Create;
  Seed := USeed;
end;

function TRanBit.RandomBit1: MiBool;
var
  newbit: Cardinal; // The accumulated XOR’s.
begin
  newbit := ((Seed shr 17) and 1) // Get bit 18.
    xor ((Seed shr 4) and 1) // XOR with bit 5.
    xor ((Seed shr 1) and 1) // XOR with bit 2.
    xor (Seed and 1); // XOR with bit 1.
  Seed := (Seed shl 1) or newbit;
  // Leftshift the seed and put the result of the XOR’s in its bit 1.
  result := newbit;
end;

function TRanBit.RandomBit2: MiBool;
const
  IB1 = 1;
  IB2 = 2;
  IB5 = 16;
  IB18 = 131072;
  MASK = (IB1 + IB2 + IB5);
begin
  if not((Seed and IB18) = 0) then
  begin // Change all masked bits, shift, and put 1 into bit 1.
    Seed := ((Seed xor MASK) shl 1) or IB1;
    result := 1;
  end
  else
  begin // Shift and put 0 into bit 1.
    Seed := Seed shl 1;
    result := 0;
  end;
end;

function TRanBit.RandomChoice: boolean;
begin
  result := RandomBit1 = 1;
  // if RandomBit1 = 1 then result:=true else result:=false;
end;

procedure TRanBit.SetSeed(const Value: Cardinal);
begin
  FSeed := Value;
end;

end.
