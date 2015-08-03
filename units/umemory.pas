unit umemory;

{ Unit umemory : memory handling Unit

  Created by : Alex Vergara Gil

  Contains the routines for handling system resources as memory,
  priorities and time

}

interface

uses windows, utypes;

function SystemResources: TMemoryStatus; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
function GetAppVersion(tipo: boolean = true): string;
function GetLocalT(tipo: boolean = true): String;
function tiempo_en_milisegundos(prioridad: TPriority = TPNormal): integer;
function Tiempo_transcurrido(milisegundos: integer;
  inittext: string = 'Tiempo Transcurrido = '): string;
procedure CambiaPrioridadaProceso(var Proceso: Cardinal;
  NuevaPrioridad: Cardinal); {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure CambiaPrioridadaHilo(var Hilo: Cardinal; NuevaPrioridad: integer);
{$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure DameMaximaPrioridad; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure DamePrioridadAlta; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure DamePrioridadNormal; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure DamePrioridadBaja; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure DameMinimaPrioridad; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}
procedure RunAndWaitShell(Ejecutable, Argumentos: string; Visibilidad: integer;
  Sender: Tobject);

implementation

uses SysUtils, Forms, Controls, ShellApi;

function SystemResources: TMemoryStatus;
var
  MemoryStatus: TMemoryStatus;
begin

  MemoryStatus.dwLength := SizeOf(MemoryStatus);

  GlobalMemoryStatus(MemoryStatus);

  { with MemoryStatus do
    begin
    // Size of MemoryStatus record
    Strings.Add(IntToStr(dwLength) +
    ' Size of ''MemoryStatus'' record');
    // Per-Cent of Memory in use by your system
    Strings.Add(IntToStr(dwMemoryLoad) +
    '% memory in use');
    //The amount of Total Physical memory allocated to your system.
    Strings.Add(IntToStr(dwTotalPhys) +
    ' Total Physical Memory in bytes');
    // The amount available of physical memory in your system.
    Strings.Add(IntToStr(dwAvailPhys) +
    ' Available Physical Memory in bytes');
    // The amount of Total Bytes allocated to your page file
    Strings.Add(IntToStr(dwTotalPageFile) +
    ' Total Bytes of Paging File');
    // The amount of available bytes in your page file
    Strings.Add(IntToStr(dwAvailPageFile) +
    ' Available bytes in paging file');
    // The amount of Total bytes allocated to this program
    (generally 2 gigabytes of virtual space)
    Strings.Add(IntToStr(dwTotalVirtual) +
    ' User Bytes of Address space');
    // The amount of avalable bytes that is left to your program to use
    Strings.Add(IntToStr(dwAvailVirtual) +
    ' Available User bytes of address space');
    end; }
  result := MemoryStatus;
end;

procedure DameMinimaPrioridad;
begin
  SetPriorityClass(GetCurrentProcess, IDLE_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_IDLE);
end;

procedure DamePrioridadBaja;
begin
  SetPriorityClass(GetCurrentProcess, IDLE_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_BELOW_NORMAL);
end;

procedure DamePrioridadNormal;
begin
  SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_NORMAL);
end;

procedure DamePrioridadAlta;
begin
  SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_HIGHEST);
end;

procedure DameMaximaPrioridad; // no recomendado pues desestabiliza el sistema
begin
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
end;

procedure CambiaPrioridadaProceso(var Proceso: Cardinal;
  NuevaPrioridad: Cardinal);
begin
  SetPriorityClass(Proceso, NuevaPrioridad);
end;

procedure CambiaPrioridadaHilo(var Hilo: Cardinal; NuevaPrioridad: integer);
begin
  SetThreadPriority(Hilo, NuevaPrioridad);
end;

function GetAppVersion(tipo: boolean): string;
var
  Size, Size2: DWord;
  Pt, Pt2: Pointer;
begin
  Size := GetFileVersionInfoSize(PChar(ParamStr(0)), Size2);
  if Size > 0 then
  begin
    GetMem(Pt, Size);
    try
      GetFileVersionInfo(PChar(ParamStr(0)), 0, Size, Pt);
      VerQueryValue(Pt, '\', Pt2, Size2);
      with TVSFixedFileInfo(Pt2^) do
      begin
        if tipo then
          result := Format('Versión %d.%d.%d.%d', [HiWord(dwFileVersionMS),
            LoWord(dwFileVersionMS), (HiWord(dwFileVersionLS) and $FF),
            (LoWord(dwFileVersionLS) and $FF)])
        else
          result := Format('Versión %d.%d', [HiWord(dwFileVersionMS),
            LoWord(dwFileVersionMS)]);
      end;
    finally
      FreeMem(Pt);
    end;
  end;
end;

function GetLocalT(tipo: boolean): String;
var
  stSystemTime: TSystemTime;
begin
  windows.GetLocalTime(stSystemTime);
  if tipo then
    result := DateTimeToStr(SystemTimeToDateTime(stSystemTime))
  else
    result := DateToStr(SystemTimeToDateTime(stSystemTime));
end;

function tiempo_en_milisegundos(prioridad: TPriority): integer;
var
  hora, minuto, segundo, milisegundo: word;
  stSystemTime: TSystemTime;
begin
  screen.Cursor := crHourGlassAni;
  case prioridad of
    TPLowest:
      DameMinimaPrioridad;
    TPLow:
      DamePrioridadBaja;
    TPNormal:
      DamePrioridadNormal;
    TPHigh:
      DamePrioridadAlta;
    TPHighest:
      DameMaximaPrioridad;
  end;
  windows.GetLocalTime(stSystemTime);
  DecodeTime(SystemTimeToDateTime(stSystemTime), hora, minuto, segundo,
    milisegundo);
  result := (hora * 60 * 60 * 1000) + (minuto * 60 * 1000) + (segundo * 1000) +
    (milisegundo);
end;

function Tiempo_transcurrido(milisegundos: integer; inittext: string): string;
var
  hora, minuto, segundo, milisegundo: word;
  temp: integer;
  tempsec: real;
  line: string;
begin
  screen.Cursor := crDefault;
  DamePrioridadNormal;
  hora := trunc(milisegundos / (60 * 60 * 1000));
  temp := milisegundos - (hora * 60 * 60 * 1000);
  minuto := trunc(temp / (60 * 1000));
  temp := temp - (minuto * 60 * 1000);
  segundo := trunc(temp / (1000));
  temp := temp - (segundo * 1000);
  milisegundo := temp;
  tempsec := segundo + (milisegundo / 1000);
  temp := length(inittext);
  if (temp > 0) and (inittext[temp] <> ' ') then
    inittext := inittext + ' ';
  if hora <> 0 then
  begin
    line := Format('%s%d%s%d%s%f%s', [inittext, hora, 'h:', minuto, 'm:',
      tempsec, 's']);
  end
  else if minuto <> 0 then
  begin
    line := Format('%s%d%s%f%s', [inittext, minuto, 'm:', tempsec, 's']);
  end
  else
    line := Format('%s%f%s', [inittext, tempsec, 's']);
  result := line;
  // result:=DateTimeToStr(EncodeTime(hora,minuto,segundo,milisegundo));
end;

procedure RunAndWaitShell(Ejecutable, Argumentos: string; Visibilidad: integer;
  Sender: Tobject);
var
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
  exitCode: DWord;
begin
  { Puntero a Info }
  { Pointer to Info }
  pInfo := @Info;
  { Rellenamos Info }
  { Fill info }
  with Info do
  begin
    cbSize := SizeOf(Info);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    wnd := (Sender as tform).Handle;
    lpVerb := nil;
    lpFile := PChar(Ejecutable);
    { Parametros al ejecutable }
    { Executable parameters }
    lpParameters := PChar(Argumentos + #0);
    lpDirectory := nil;
    nShow := Visibilidad;
    hInstApp := 0;
  end;
  { Ejecutamos }
  { Execute }
  ShellExecuteEx(pInfo);

  { Esperamos que termine }
  { Wait to finish }
  repeat
    exitCode := WaitForSingleObject(Info.hProcess, 500);
    Application.ProcessMessages;
  until (exitCode <> WAIT_TIMEOUT);
end;

initialization

screen.Cursors[crHourGlassAni] := LoadCursorFromFile('HourGlas.Ani');
screen.Cursors[crAppStartAni] := LoadCursorFromFile('AppStart.Ani');
screen.Cursors[crGlobe] := LoadCursorFromFile('Globe.Ani');

end.
