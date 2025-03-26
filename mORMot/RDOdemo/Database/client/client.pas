unit client;

interface

{$I mormot.defines.inc}
{$I globaldefines.inc}

uses
  Classes,
  mormot.core.base,
  mormot.orm.core,

  mormot.rest.client,
  mormot.rest.http.client,

  servicesshared,

  documentserviceinterface,
  rundataserviceinterface,
  productserviceinterface;

type
  TClient = class(TObject)
  strict private
    function GetDocumentService:IDocumentService;
    function GetProductService:IProductService;
  private
    fConnected          : boolean;
    fClient             : TRestClientURI;
    fDocumentService    : IDocumentService;
    fProductService     : IProductService;
  public
    constructor Create(IPAddress:string);
    destructor Destroy; override;
    function Vacuum:boolean;
    property ClientConnected         : boolean read fConnected;
    property Client                  : TRestClientURI read fClient;
    property ClientDocumentService   : IDocumentService read GetDocumentService;
    property ClientProductService    : IProductService read GetProductService;
  end;

implementation

{
******************************** TServiceServer ********************************
}

uses
  {$ifdef USE_JWT}
  mormot.crypt.jwt,
  {$endif}
  mormot.core.os;

{$ifdef USE_JWT}
function GenerateJwtToken(const UserName: RawUtf8 = ''): RawUtf8;
var
  Jwt: TJwtHS256;
begin
  Jwt := TJwtHS256.Create(SECRET_KEY, 10, [jrcIssuer, jrcExpirationTime, jrcIssuedAt, jrcJWTID], [], 60);
  try
    if Length(UserName)=0 then
      result:=Jwt.Compute([], 'Dummy') // the server always expects an issuer, so use a dummy
    else
      result:=Jwt.Compute([], UserName);
  finally
    Jwt.Free;
  end;
end;
{$endif}

constructor TClient.Create(IPAddress:string);
begin
  inherited Create;

  fConnected:=false;

  fClient:=TRestHttpClient.Create(IPAddress, HTTP_PORT, TOrmModel.Create([]));
  fClient.Model.Owner := fClient;
  {$ifdef USE_JWT}
  fClient.SessionHttpHeader:=HEADER_BEARER_UPPER + GenerateJwtToken;
  {$endif}
  {$ifdef USE_AUTHENTICATION}
  fClient.SetUser('User', 'synopse');
  {$endif}

  if (fClient.SessionID>0) then
  begin
   try
     fConnected:=(fClient.ServiceDefineSharedApi(IProductService,EXAMPLE_CONTRACT)<>nil);
     if fConnected then
     begin
       fClient.Services.Resolve(IProductService, fProductService);
       fConnected:=(fClient.ServiceDefineSharedApi(IDocumentService)<>nil);
       if fConnected then
       begin
         fClient.Services.Resolve(IDocumentService, fDocumentService);
         fConnected:=fClient.ServerTimestampSynchronize;
       end;
     end;
   except
     fConnected:=False;
   end;
  end else fConnected:=False;

  if fConnected then
  begin
   //fClient.Client.SetForceBlobTransfertTable(TOrmProduct);
  end;
end;

destructor TClient.Destroy;
begin
  fDocumentService:=nil;
  fProductService:=nil;
  fClient.Free;
  inherited Destroy;
end;

function TClient.Vacuum:boolean;
var
  Refreshed: boolean;
begin
  result:=false;
  if Client.SessionUser = nil then // only if has the right for EngineExecute
    result:=Client.Orm.Execute('VACUUM;');
end;

function TClient.GetProductService:IProductService;
begin
  result:=fProductService;
end;

function TClient.GetDocumentService:IDocumentService;
begin
  result:=fDocumentService;
end;

end.
