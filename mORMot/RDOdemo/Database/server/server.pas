unit server;

interface

{$I mormot.defines.inc}
{$I globaldefines.inc}

uses
  SysUtils,

  mormot.core.base,
  mormot.orm.core,
  mormot.core.mustache,

  mormot.rest.server,
  mormot.rest.memserver,
  mormot.net.http, // for Request
  mormot.rest.http.server,

  {$ifdef USE_AUTHENTICATION}
  mormot.rest.sqlite3, // for TRestServerDB
  mormot.db.raw.sqlite3.static,// for TRestServerDB
  {$endif}

  servicesshared,

  documentserviceinterface,
  documentserviceimplementation,
  documentstorageinterface,
  documentstorageimplementationmormot,
  documentstorageimplementationdisk,

  rundataserviceinterface,
  rundatastorageinterface,

  productserviceinterface,
  productserviceimplementation,
  productstorageinterface,
  productstorageimplementation;

type
  {$ifdef USE_AUTHENTICATION}
  TServiceServer = class(TRestServerDB) // to persist user and group into separate database
  {$else}
  TServiceServer = class(TRestServerFullMemory) // no authentication for user and password
  {$endif}
  private
    fDocumentStorage    : IDocumentStorage;
    fProductStorage     : IProductStorage;
    fHttpServer         : TRestHttpServer;
    fTableMustache      : TSynMustache;
    function AfterRequest(Ctxt: THttpServerRequestAbstract): cardinal;
  protected
    ProductService        : TProductService;
    DocumentService       : TDocumentService;
  public
    constructor Create(IncludeHttpServer:boolean=false); overload;
    destructor Destroy; override;
    property HttpServer     : TRestHttpServer read fHttpServer;
    property TableMustache  : TSynMustache read fTableMustache;
  published
    // This method return a table of batteries in case the SOA methods are protected from outside access
    procedure AllBatteries(Ctxt: TRestServerUriContext);
  end;

  TServer = class(TObject)
  strict private
    function GetDocumentService:IDocumentService;
    function GetProductService:IProductService;
  private
    fServiceServer:TServiceServer;
  public
    constructor Create(IncludeHttpServer:boolean=false);
    destructor Destroy; override;
    property ServerDocumentService    : IDocumentService read GetDocumentService;
    property ServerProductService     : IProductService read GetProductService;
  end;

implementation

uses
  productdom,
  mormot.core.text,
  mormot.core.os,
  mormot.core.interfaces,
  mormot.core.buffers,
  mormot.core.unicode,
  mormot.core.json,
  {$ifdef USE_JWT}
  mormot.crypt.jwt, // for JWT desurity
  {$endif}
  {$ifdef USE_AUTHENTICATION}
  mormot.rest.core, // for TAuthUser, TAuthGroup
  {$endif}
  mormot.soa.core;

constructor TServer.Create(IncludeHttpServer:boolean);
begin
  fServiceServer:=TServiceServer.Create(IncludeHttpServer);
  inherited Create;
end;

destructor TServer.Destroy;
begin
  fServiceServer.Free;
  inherited Destroy
end;

function TServer.GetDocumentService:IDocumentService;
begin
  result:=fServiceServer.DocumentService;
end;

function TServer.GetProductService:IProductService;
begin
  result:=fServiceServer.ProductService;
end;

{
******************************** TServiceServer ********************************
}

constructor TServiceServer.Create(IncludeHttpServer:boolean);
begin
  {$ifdef USE_AUTHENTICATION}
  inherited CreateWithOwnModel([TAuthUser, TAuthGroup],'users.db3',true);
  Server.CreateMissingTables;
  {$else}
  inherited CreateWithOwnModel([],false);
  {$endif}

  //ServiceMethodByPassAuthentication('AllBatteries'); // ByPass authentication for a single method [by name]
  ServiceMethodByPassAuthentication(''); // ByPass authentication for all methods

  fProductStorage := TProductStorage.Create(nil,BATTERY_DATABASE_FILENAME);
  ProductService := TProductService.Create(fProductStorage);
  with ServiceDefine(ProductService, [IProductService], EXAMPLE_CONTRACT) do
  begin
    ResultAsJsonObjectWithoutResult := true;
    //SetOptions([],[optExecLockedPerInterface]);
    //ByPassAuthentication := true; // ByPass authentication for all soa methods of this service
  end;

  fDocumentStorage := TDocumentStoragemORMot.Create;
  //fDocumentStorage := TDocumentStorageDisk.Create;
  DocumentService := TDocumentService.Create(fDocumentStorage);
  with ServiceDefine(DocumentService, [IDocumentService]) do
  begin
    ResultAsJsonObjectWithoutResult := true;
    //SetOptions([],[optExecLockedPerInterface]);
    //ByPassAuthentication := true; // ByPass authentication for all soa methods of this service
  end;

  {$ifdef USE_JWT}
  // Set up simple JWT safety if we do not need any extra info from the JWT
  JwtForUnauthenticatedRequest := TJwtHS256.Create(SECRET_KEY, 10, [jrcIssuer, jrcExpirationTime, jrcIssuedAt, jrcJWTID], [], 60); // Enable automatic JWT validation
  {$endif}

  fHttpServer:=nil;
  if IncludeHttpServer then
  begin
    fHttpServer := TRestHttpServer.Create(HTTP_PORT, Self, '+', useHttpSocket);
    fHttpServer.HttpServer.OnAfterRequest:=AfterRequest;
    fHttpServer.AccessControlAllowOrigin := '*';
    fHttpServer.Route.Get('/info', 'root/timestamp/info');
    fHttpServer.Route.Get('/batteries', '/root/ProductService.GetAllProducts');
    fHttpServer.Route.Get('/battery/<id>', '/root/ProductService.GetProductByCode?aCode=<id>');
    fHttpServer.Route.Get('/battery/<id>/image', '/root/ProductService.GetProductImageByCode?aCode=<id>');
    //fHttpServer.Route.Get('/battery/<code>/rundata/<id>', '/root/ProductService.GetProductByCode?aCode=<id>');
    //fHttpServer.Route.Get('/battery/<id>/picture', '/root/ProductService.newpic?id=<id>&pic=');
    //fHttpServer.Route.Get('/battery/<id>/picture/<pic>', '/root/ProductService.newpic?pic=<pic>&id=<id>');

    fTableMustache := TSynMustache.Parse(
    '<!doctype html>'+
    '<html lang="en">'+
    '<head>'+
      '<meta charset="utf-8">'+
      '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'+
      '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">'+
      '<title Mustache renderer of battery database></title>'+
    '</head>'+
    '<body>'+
      'My Batteries:'#13#10+
      '<table class="table table-striped table-bordered table-sm">'+
      '<thead class="thead-dark">'+
      '<tr id="colHeaders">'+
      '<th scope="col">#</th>'+
      '<th scope="col">Code</th>'+
      '<th scope="col">Brand</th>'+
      '<th scope="col">Type</th>'+
      '<th scope="col" style="width: 140px">Picture</th>'+
      '<th scope="col"></th>'+
      '</tr>'+
      '</thead>'+
      '<tbody>'+
      #$A'{{#AProducts}}'+
      '<tr>'+
      '<th scope="row">{{-index}}</th>'+
      '<td>{{B_code}}</td>'+
      '<td>{{B_name}}</td>'+
      '<td>{{B_type}}</td>'+
      '<td><img src="data:image/bmp;base64,{{Thumb}}"></td>'+
      '<td><a href="#" id="getDetails">Details</a></td>'+
      '</tr>'+
      #$A'{{/AProducts}}'+
      '</tbody>'+
      '</table>'+
      '</body>'
      );

  end;
end;

destructor TServiceServer.Destroy;
begin
  if Assigned(fHttpServer) then
  begin
    fHttpServer.Free;
  end;

  fProductStorage := nil;
  fDocumentStorage := nil;

  inherited Destroy;
end;

function TServiceServer.AfterRequest(Ctxt: THttpServerRequestAbstract): cardinal;
var
  interfdata, interf, data, method: RawUtf8;
  html        : RawUtf8;
begin
  if IsGet(Ctxt.Method) then
  begin
    Split(copy(Ctxt.URL, Model.RootLen + 3, 1024), '.', {%H-}interf, {%H-}interfdata);
    Split(interfdata, '?', {%H-}method, {%H-}data);

    if method='GetProductImageByCode' then
    begin
      data:=JsonDecode(pointer(Ctxt.OutContent),'AImage',nil,false);
      Ctxt.OutContent:=Base64ToBinSafe(data);
      Ctxt.OutContentType := MIME_TYPE[mtBmp];
    end;

    if method='GetAllProducts' then
    begin
      // We now have OutContent with a field title and a json array with results
      // Use TableMustache to render it into a table
      html := TableMustache.RenderJson(Ctxt.OutContent);
      Ctxt.OutContent:=html;
      Ctxt.OutContentType := MIME_TYPE[mtHtml];
    end;

  end;
  result:=HTTP_NONE;
end;

procedure TServiceServer.AllBatteries(Ctxt: TRestServerUriContext);
var
  Products       : TProductCollection;
  json, html     : RawUtf8;
  W              : TTextWriterStackBuffer;
begin
  if (Ctxt.Method=TUriMethod.mGET) then
  begin
    if ((self=nil) or (Ctxt.TableIndex<0)) then
      Ctxt.Error('Bad Request', HTTP_BADREQUEST)
    else
    begin
      Products:=TProductCollection.create;
      try
        // Get the Products directly from the service
        ProductService.GetAllProducts(Products);
        // Create expected JSON for TableMustache renderer.
        with DefaultJsonWriter.CreateOwnedStream({%H-}W) do
        try
          AddDirect('{');
          AddFieldName('AProducts');
          WriteObject(Products);
          AddDirect('}');
          SetText({%H-}json);
        finally
          Free;
        end;
        // Rnder the json with the TableMustache renderer
        html := TableMustache.RenderJson(json);
        // return the HTML contents
        Ctxt.Returns(html,HTTP_SUCCESS,HTML_CONTENT_TYPE_HEADER,true);
      finally
        Products.Free;
      end;
    end;
  end
  else
  begin
    Ctxt.Error('Forbidden', HTTP_FORBIDDEN);
  end;
end;


end.
