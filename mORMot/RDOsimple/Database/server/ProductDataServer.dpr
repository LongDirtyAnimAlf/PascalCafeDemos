program ProductDataServer;

{$APPTYPE CONSOLE}

{$I mormot.defines.inc}

uses
  {$I mormot.uses.inc}
  mormot.rest.http.server,
  mormot.db.raw.sqlite3,
  mormot.core.log,
  servicesshared,
  server in 'server.pas';

var
  ServiceServer: TServiceServer;
  LogFamily: TSynLogFamily;

begin
  LogFamily := SQLite3Log.Family;
  LogFamily.Level := LOG_VERBOSE;
  LogFamily.PerThreadLog := ptIdentifiedInOnFile;
  LogFamily.EchoToConsole := LOG_VERBOSE;
  try
    ServiceServer := TServiceServer.Create(True);
    ServiceServer.HttpServer.AccessControlAllowOrigin := '*';
    Writeln('Server started on port ' + HTTP_PORT);
    Readln;
  finally
    ServiceServer.Free;
  end;
end.
