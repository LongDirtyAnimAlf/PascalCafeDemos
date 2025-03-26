unit tools;

interface

uses
  {$ifdef MSWINDOWS}
  Windows,
  {$endif}
  Classes,
  {$ifdef Linux}
  UnixType,
  {$endif}
  SysUtils
  //,DateUtils
  //,FileUtil
  ;

function NowUTC: TDateTime;
function Get_File_Size4(const S: string): Int64;
function OccurrencesOfChar(const ContentString: string; const CharToCount: char): integer;
function ExtractIntegerInString(aString:string): integer;
function ExtractFloatInString(aString:string): double;
function CopyFile(const sSrc, sDst: String): Boolean;
function MaybeQuoteIfNotQuoted(Const S: String): String;
implementation

{$ifdef UNIX}
uses
  Unix, BaseUnix {$ifndef Darwin},linux{$endif};
{$endif}

{$ifdef UNIX}
const // Date Translation - see http://en.wikipedia.org/wiki/Julian_day
  HoursPerDay = 24;
  MinsPerHour = 60;
  SecsPerMin  = 60;
  MinsPerDay  = HoursPerDay*MinsPerHour;
  SecsPerDay  = MinsPerDay*SecsPerMin;
  SecsPerHour = MinsPerHour*SecsPerMin;
  C1970       = 2440588;
  D0          = 1461;
  D1          = 146097;
  D2          = 1721119;

procedure JulianToGregorian(JulianDN: integer; out Year,Month,Day: Word);
var
  YYear,XYear,Temp,TempMonth: integer;
begin
  Temp := ((JulianDN-D2) shl 2)-1;
  JulianDN := Temp div D1;
  XYear := (Temp mod D1) or 3;
  YYear := (XYear div D0);
  Temp := ((((XYear mod D0)+4) shr 2)*5)-3;
  Day := ((Temp mod 153)+5) div 5;
  TempMonth := Temp div 153;
  if TempMonth>=10 then begin
    inc(YYear);
    dec(TempMonth,12);
  end;
  inc(TempMonth,3);
  Month := TempMonth;
  Year := YYear+(JulianDN*100);
end;

procedure EpochToLocal(epoch: integer; out year,month,day,hour,minute,second: Word);
begin
  JulianToGregorian((Epoch div SecsPerDay)+c1970,year,month,day);
  Epoch := abs(Epoch mod SecsPerDay);
  Hour := Epoch div SecsPerHour;
  Epoch := Epoch mod SecsPerHour;
  Minute := Epoch div SecsPerMin;
  Second := Epoch mod SecsPerMin;
end;

procedure GetNowUTCSystem(out result: TSystemTime);
var
  tz: timeval;
begin
  fpgettimeofday(@tz,nil);
  EpochToLocal(tz.tv_sec,result.year,result.month,result.day,result.hour,result.Minute,result.Second);
  result.MilliSecond := tz.tv_usec div 1000;
end;

function NowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetNowUTCSystem(SystemTime);
  result := SystemTimeToDateTime(SystemTime);
end;
{$else}
function NowUTC: TDateTime;
var
  st: TSystemTime;
begin
  {$ifdef DARWIN}
  GetLocalTime(st);
  {$else}
  GetSystemTime({%H-}st);
  {$endif}
  //result := EncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
  result := SysUtils.SystemTimeToDateTime (st);
  //result := TTimeZone.Local.ToUniversalTime(Now);
end;
{$endif}

function Get_File_Size4(const S: string): Int64;
{$ifdef MSWINDOWS}
var
  FD: TWin32FindData;
  FH: THandle;
begin
  FH := FindFirstFile(PChar(S), {%H-}FD);
  if FH = INVALID_HANDLE_VALUE then Result := 0
  else
    try
      Result := FD.nFileSizeHigh;
      Result := Result shl 32;
      Result := Result + FD.nFileSizeLow;
    finally
      Windows.FindClose(FH);
    end;
end;
{$else}
var f: THandle;
    res: Int64Rec absolute result;
function GetFileSize(hFile: cInt; lpFileSizeHigh: PDWORD): DWORD;
var FileInfo: TStat;
begin
      if fpFstat(hFile,FileInfo)<>0 then
        FileInfo.st_Size := 0; // returns 0 on error
      result := Int64Rec(FileInfo.st_Size).Lo;
      if lpFileSizeHigh<>nil then
        lpFileSizeHigh^ := Int64Rec(FileInfo.st_Size).Hi;
end;
begin
  result := 0;
  f := FileOpen(S,fmOpenRead or fmShareDenyNone);
  if PtrInt(f)>0 then begin
    res.Lo := GetFileSize(f,@res.Hi); // from SynKylix/SynFPCLinux
    FileClose(f);
  end;
end;
{$endif}

function OccurrencesOfChar(const ContentString: string; const CharToCount: char): integer;
var
  C: Char;
begin
  result := 0;
  for C in ContentString do
    if C = CharToCount then
      Inc(result);
end;

function ExtractIntegerInString(aString:string): integer;
var
  i: Integer;
  aNumberString: string;
begin
  Result:=0;
  aNumberString:='';
  for i:=1 to length(aString) do
  begin
    if aString[i] in ['0'..'9'] then
      aNumberString:=aNumberString+aString[i];
  end;
  if (Length(aNumberString)>0) then result:=StrtoInt(aNumberString);
end;

function ExtractFloatInString(aString:string): double;
var
  i: Integer;
  aNumberString: string;
begin
  Result:=0;
  aNumberString:='';
  for i:=1 to length(aString) do
  begin
    if aString[i] in ['0'..'9'] then
      aNumberString:=aNumberString+aString[i];
    if aString[i] in ['.',','] then
      aNumberString:=aNumberString+DefaultFormatSettings.DecimalSeparator;
  end;
  if (Length(aNumberString)>0) then
    result:=StrtoFloatDef(aNumberString,0);
end;

{$ifdef Windows}
function CopyFile(const sSrc, sDst: String): Boolean;
const
  cBlockSize=16384; // size of block if copyfile
var
  src: TFileStream = nil;
  dst: TFileStream = nil;
  iDstBeg:Integer; // in the append mode we store original size
  Buffer: PChar = nil;
begin
  Result:=False;
  iDstBeg:=0;
  if not FileExists(sSrc) then exit;
  GetMem(Buffer,cBlockSize+1);
  try
    try
      src:=TFileStream.Create(sSrc,fmOpenRead or fmShareDenyNone);
      if not Assigned(src) then exit;

      dst:=TFileStream.Create(sDst,fmCreate);
      if not Assigned(dst) then exit;


      while (dst.Size+cBlockSize)<= (src.Size) do
      begin
        Src.ReadBuffer(Buffer^, cBlockSize);
        dst.WriteBuffer(Buffer^, cBlockSize);
      end;

      if (iDstBeg+src.Size)>dst.Size then
      begin
        src.ReadBuffer(Buffer^, src.Size-dst.size);
        dst.WriteBuffer(Buffer^, src.Size-dst.size);
      end;
      result:=true;

    except
      on EStreamError do begin end;
    end;

  finally
    if assigned(src) then
      FreeAndNil(src);
    if assigned(dst) then
      FreeAndNil(dst);
    if assigned(Buffer) then
      FreeMem(Buffer);
  end;
end;
{$else}
function CopyFile(const sSrc, sDst: string): Boolean;
var
  SrcHandle, DestHandle: cint;
  Buffer: array[1..4096] of byte;
  BytesRead, BytesWritten: ssize_t;
  StatInfo: stat;
  TimeBuffer: TUtimBuf;
begin
  Result := False;

  // Open the source file
  SrcHandle := fpopen(PChar(sSrc), O_RDONLY);
  if SrcHandle = -1 then
  begin
    Writeln('Error opening source file.');
    Exit;
  end;

  try
    // Get file attributes from the source
    if fpstat(sSrc, {%H-}StatInfo) = -1 then
    begin
      Writeln('Error reading source file attributes.');
      Exit;
    end;

    // Open the destination file with same permissions as the source
    DestHandle := fpopen(PChar(sDst), O_WRONLY or O_CREAT or O_TRUNC, StatInfo.st_mode);
    if DestHandle = -1 then
    begin
      Writeln('Error creating destination file.');
      Exit;
    end;

    try
      // Copy data from source to destination
      repeat
        BytesRead := fpread(SrcHandle, @Buffer, SizeOf(Buffer));
        if BytesRead = -1 then
        begin
          Writeln('Error reading from source file.');
          Exit;
        end;

        BytesWritten := fpwrite(DestHandle, @Buffer, BytesRead);
        if BytesWritten = -1 then
        begin
          Writeln('Error writing to destination file.');
          Exit;
        end;
      until BytesRead = 0;

      // Set the destination file's permissions to match the source
      if fpchmod(sDst, StatInfo.st_mode) = -1 then
      begin
        Writeln('Error setting permissions on destination file.');
        Exit;
      end;

      TimeBuffer.actime := StatInfo.st_atime;
      TimeBuffer.modtime := StatInfo.st_mtime;

      // Set the destination file's access and modification times to match the source
      if fputime(sDst, @TimeBuffer) = -1 then
      begin
        Writeln('Error setting timestamps on destination file.');
        Exit;
      end;

      Result := True;
    finally
      // Ensure destination handle is closed in case of errors
      if fpfcntl(DestHandle, F_GETFD) <> -1 then
         fpclose(DestHandle);
    end;
  finally
    fpclose(SrcHandle);
  end;
end;


{$endif}

function MaybeQuoteIfNotQuoted(Const S: String): String;
begin
  If (Pos(' ',S)<>0) and (pos('"',S)=0) then
    Result:='"'+S+'"'
  else
     Result:=S;
end;

end.
