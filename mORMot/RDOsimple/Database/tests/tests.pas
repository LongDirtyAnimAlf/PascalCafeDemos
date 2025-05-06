unit tests;

interface

{$I mormot.defines.inc}
{$I globaldefines.inc}

uses
  sysutils,
  classes,
  variants,
  mormot.core.base,
  mormot.core.text,
  mormot.core.rtti,
  mormot.core.json,
  mormot.core.test;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mandatory :(
{$endif FPC_EXTRECORDRTTI}

type
  TTestCoreProcess = class(TSynTestCase)
  published
    procedure EncodeDecodeJSON;
    procedure ClientServer;
    procedure PreparedClientServer;
  end;

implementation

uses
  {$ifdef USE_JWT}
  mormot.crypt.jwt,
  {$endif}
  mormot.core.os,
  mormot.core.perf,
  mormot.rest.http.server,
  mormot.rest.sqlite3,
  mormot.rest.client,
  mormot.rest.http.client,
  mormot.soa.core,

  productinfra,
  productdom,
  rundatainfra,
  rundatadom,
  documentinfra,
  documentdom,

  servicesshared,

  documentserviceinterface,
  documentstorageinterface,
  documentstorageimplementationmormot,
  documentstorageimplementationdisk,
  documentserviceimplementation,

  rundataserviceinterface,
  rundatastorageinterface,
  rundatastorageimplementation,
  rundataserviceimplementation,

  productserviceinterface,
  productstorageinterface,
  productstorageimplementation,
  productserviceimplementation,

  client,
  server;

const
  NUMRUNDATAS = 10;
  NUMMEASUREMENTS = 5000;

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

procedure TTestCoreProcess.EncodeDecodeJSON;
var
  J, U: RawUtf8;
  P: PUtf8Char;
  i: integer;
  Valid: boolean;
  Instance: TRttiCustom;
  MyProduct:TProduct;
  Product:TProduct;
  SampleData:TRunData;
  RunData:TRunDataCollection;
  MeasurementData:TMeasurementData;
  m: TRttiMap;
  os:TOrmRunData;

  procedure TestBatColl(MyColl: TProductCollection);
  begin
    if CheckFailed(MyColl <> nil) then exit;
    MyProduct := MyColl.Add as TProduct;
    Check(MyProduct.ClassType = TProduct);

    MyProduct.ProductCode:='ID000';
    U := ObjectToJson(MyColl);
    P := UniqueRawUtf8(U); // make local copy of source constant

    MyProduct.ProductCode:='ID001';
    JsonToObject(MyColl,P,Valid);
    Check(Valid);

    Check(MyProduct.ProductCode='ID000');

    MyColl.Free;
  end;

begin
  Product:=TProduct.Create(nil);

  try
    U := ObjectToJson(Product);
    check(IsValidJson(U));

    U := ObjectToJson(Product,[woStoreClassName]);
    check(IsValidJson(U));

    P := UniqueRawUtf8(U); // make local copy of source constant

    MyProduct:=TProduct(JsonToNewObject(P,Valid{,[jpoObjectListClassNameGlobalFindClass]}));
    try
      Check(Valid);
    finally
      MyProduct.Free;
    end;

    TestBatColl(TProductCollection.Create);

    Instance := Rtti.RegisterCollection(TProductCollection, TProduct);
    TestBatColl(TObject(Instance.ClassNewInstance) as TProductCollection);

  finally
    Product.Free;
  end;
end;

procedure TTestCoreProcess.ClientServer;
var
  ProductService    : IProductService;
  DocumentService   : IDocumentService;
  ServiceServer     : TServiceServer;
  PreparedServer    : TServer;
  PreparedClient    : TClient;
  RestClient        : TRestHttpClient;
  timer             : TPrecisionTimer;
  json              : RawUTF8;

procedure TestServices;
var
  Product           : TProduct;
  AllProducts       : TProductCollection;
  Document          : TDocument;
  D                 : double;
  i,j               : integer;
  TMode             : TThresholdModes;

begin
  Product:=TProduct.Create(nil);
  try
    Product.ProductCode:='Product001';

    Check(ProductService.AddProduct(Product) = seSuccess);
    Check(ProductService.GetProduct(Product) = seSuccess);

    Document:=TDocument.Create(nil);
    DocumentService.FindDocument(Product.ProductCode,Document);
    Document.Free;

    AllProducts:=TProductCollection.Create;
    Check(ProductService.GetAllProducts(AllProducts) = seSuccess);
    json := ObjectToJSON(AllProducts);
    AllProducts.Free;

  finally
    Product.Free;
  end;
end;

begin
  // ******************************
  // Test direct access of database

  DeleteFile(PRODUCT_DATABASE_FILENAME);
  ServiceServer := TServiceServer.Create({WithHTTPServer=}False);

  ServiceServer.Services.Resolve(IProductService, ProductService);
  ServiceServer.Services.Resolve(IDocumentService, DocumentService);

  timer.Start;
  TestServices;
  NotifyTestSpeed('Direct access', 0, 0, @timer);

  DocumentService:=nil;
  ProductService:=nil;
  ServiceServer.Free;


  // ****************************************
  // Test database access through http server

  DeleteFile(PRODUCT_DATABASE_FILENAME);
  ServiceServer := TServiceServer.Create({WithHTTPServer=}True);
  RestClient := TRestHttpClient.Create('localhost', HTTP_PORT, ServiceServer.Model);
  {$ifdef USE_JWT}
  RestClient.SessionHttpHeader:=HEADER_BEARER_UPPER + GenerateJwtToken;
  {$endif}
  {$ifdef USE_AUTHENTICATION}
  RestClient.SetUser('User', 'synopse');
  {$endif}
  Check(RestClient.ServiceDefineSharedApi(IProductService,EXAMPLE_CONTRACT)<>nil);
  //RestClient.ServiceDefine(IProductService, sicShared, EXAMPLE_CONTRACT);
  RestClient.Services.Resolve(IProductService, ProductService);
  Check(RestClient.ServiceDefineSharedApi(IDocumentService)<>nil);
  //RestClient.ServiceDefine(IDocumentService, sicShared);
  RestClient.Services.Resolve(IDocumentService, DocumentService);
  Check(RestClient.ServerTimestampSynchronize);

  timer.Start;
  TestServices;
  NotifyTestSpeed('HTTP localhost access', 0, 0, @timer);

  CheckEqual(RestClient.CallBackGet('stat', ['findservice', '*'], json), HTTP_SUCCESS);
  Check(IsValidJson(json));

  RestClient.CallBackGet('stat', [
    'withtables',     true,
    'withmethods',    true,
    'withinterfaces', true,
    'withsessions',   true], Json);
  FileFromString(JsonReformat(Json), 'stats.json');

  DocumentService:=nil;
  ProductService:=nil;
  RestClient.Free;
  ServiceServer.Free;
end;


procedure TTestCoreProcess.PreparedClientServer;
var
  ProductService    : IProductService;
  DocumentService   : IDocumentService;
  PreparedServer    : TObject;
  PreparedClient    : TObject;
  timer             : TPrecisionTimer;
  json              : RawUTF8;

procedure TestServices;
var
  Product           : TProduct;
  AllProducts       : TProductCollection;
  Document          : TDocument;
  D                 : double;
  i,j               : integer;
  TMode             : TThresholdModes;

begin
  Product:=TProduct.Create(nil);
  try
    Product.ProductCode:='Product001';

    Check(ProductService.AddProduct(Product) = seSuccess);
    Check(ProductService.GetProduct(Product) = seSuccess);

    Document:=TDocument.Create(nil);
    DocumentService.FindDocument(Product.ProductCode,Document);
    Document.Free;

    AllProducts:=TProductCollection.Create;
    Check(ProductService.GetAllProducts(AllProducts) = seSuccess);
    json := ObjectToJSON(AllProducts);
    AllProducts.Free;

  finally
    Product.Free;
  end;
end;


begin
  DeleteFile(PRODUCT_DATABASE_FILENAME);

  PreparedServer:=TServer.Create({HTTPServer=}false);
  with PreparedServer AS TServer do
  begin
    ProductService:=ServerProductService;
    DocumentService:=ServerDocumentService;
  end;


  timer.Start;
  TestServices;
  NotifyTestSpeed('Direct access', 0, 0, @timer);

  DocumentService:=nil;
  ProductService:=nil;
  PreparedServer.Free;

  DeleteFile(PRODUCT_DATABASE_FILENAME);

  PreparedServer := TServer.Create({HTTPServer=}true);
  PreparedClient:=TClient.Create('localhost');
  with PreparedClient AS TClient do
  begin
    Check(ClientConnected);
    if (ClientConnected) then
    begin
      ProductService:=ClientProductService;
      DocumentService:=ClientDocumentService;

      timer.Start;
      TestServices;
      NotifyTestSpeed('Remote access', 0, 0, @timer);
    end;
  end;

  DocumentService:=nil;
  ProductService:=nil;
  PreparedClient.Free;
  PreparedServer.Free;
end;

end.

