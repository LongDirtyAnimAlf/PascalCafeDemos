program BatteryTests;

{$I mormot.defines.inc}

{$ifdef OSWINDOWS}
  {$apptype console}
{$endif OSWINDOWS}

uses
  {$I mormot.uses.inc} // follow FPC_X64MM or FPC_LIBCMM conditionals
  {$ifdef UNIX}
  cwstring, // needed as fallback if ICU is not available
  {$endif UNIX}
  classes,
  sysutils,
  mormot.core.os,
  mormot.core.base,
  mormot.core.test,
  mormot.core.unicode,
  mormot.core.text,
  mormot.core.datetime,
  mormot.core.log,
  tests;

{ TIntegrationTests }

type
  TIntegrationTests = class(TSynTestsLogged)
  protected
    class procedure DescribeCommandLine; override;
  public
    function Run: boolean; override;
  published
    procedure CoreUnits;
  end;

class procedure TIntegrationTests.DescribeCommandLine;
begin
  with Executable.Command do
  begin
    ExeDescription := 'mORMot '+ SYNOPSE_FRAMEWORK_VERSION + ' Regression Tests';
  end;
end;

function TIntegrationTests.Run: boolean;
begin
  CustomVersions := Format(CRLF + CRLF + '%s [%s %s %x]'+ CRLF +
    '    %s' + CRLF + '    on %s'+ CRLF + 'Using mORMot %s %s',
    [OSVersionText, CodePageToText(Unicode_CodePage), KBNoSpace(SystemMemorySize),
     OSVersionInt32, CpuInfoText, BiosInfoText, SYNOPSE_FRAMEWORK_FULLVERSION,
     UnixTimeToTextDateShort(FileAgeToUnixTimeUtc(Executable.ProgramFileName))]);
  result := inherited Run;
end;

procedure TIntegrationTests.CoreUnits;
begin
  //exit;
  AddCase([
    TTestCoreProcess
  ]);
end;

begin
  SetExecutableVersion(SYNOPSE_FRAMEWORK_VERSION);
  TIntegrationTests.RunAsConsole('Battery DOM Regression Tests',
    //LOG_VERBOSE +
    LOG_FILTER[lfExceptions] // + [sllErrors, sllWarning]
    ,[]);
  {$ifdef FPC_X64MM}
  WriteHeapStatus(' ', 16, 8, {compileflags=}true);
  {$endif FPC_X64MM}
end.

