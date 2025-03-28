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
  {$rtti explicit fields([vcPublic])} // mantadory :(
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
  StageData:TStageData;
  TestData:TTestData;
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

    MyProduct.B_code:='ID000';
    U := ObjectToJson(MyColl);
    P := UniqueRawUtf8(U); // make local copy of source constant

    MyProduct.B_code:='ID001';
    JsonToObject(MyColl,P,Valid);
    Check(Valid);

    Check(MyProduct.B_code='ID000');

    MyColl.Free;
  end;

begin
  Product:=TProduct.Create(nil);

  try
    U := ObjectToJson(Product);
    check(IsValidJson(U));

    StageData:=Product.Stages.Add;
    StageData.SValueText:='1234';

    U := ObjectToJson(Product);
    check(IsValidJson(U));

    TestData:=Product.TestDatas.Add;
    U := ObjectToJson(Product);
    check(IsValidJson(U));

    SampleData:=TestData.RunDatas.Add;
    SampleData.SampleNumber:=1;
    SampleData.AddMeasurementData(Now);

    U := ObjectToJson(SampleData);
    check(IsValidJson(U));

    U := ObjectToJson(Product);
    check(IsValidJson(U));

    U := ObjectToJson(Product,[woStoreClassName]);
    check(IsValidJson(U));

    P := UniqueRawUtf8(U); // make local copy of source constant

    MyProduct:=TProduct(JsonToNewObject(P,Valid{,[jpoObjectListClassNameGlobalFindClass]}));
    try
      Check(Valid);

      TestData:=MyProduct.GetMeasurementTestData;
      TestData.Info:='Measurement TestData';

      SampleData:=MyProduct.GetMeasurementSampleData(1);
      Check(SampleData.SampleNumber=1);

      StageData:=MyProduct.GetStageData(0);
      StageData.SValueText:='9999';

      U := ObjectToJson(MyProduct);
      check(IsValidJson(U));

      P := UniqueRawUtf8(U); // make local copy of source constant
      Check(JsonToObject(Product, P, Valid)^ = #0);
      Check(Valid);

      TestData:=Product.GetMeasurementTestData;
      Check(TestData.Info='Measurement TestData');

      SampleData:=TestData.RunDatas.Add;
      SampleData.SampleNumber:=200;

      Check(TestData.RunDatas.Count=2);

      SampleData.AddMeasurementData(Now);
      U := ObjectToJson(SampleData);
      check(IsValidJson(U));

      StageData:=Product.GetStageData(0);
      Check(StageData.SValueText='9999');

      MyProduct.B_code:='YOLO!!!';
      StageData:=MyProduct.GetStageData(0);
      ClearObject(MyProduct);
      ClearObject(StageData);
      StageData:=MyProduct.GetStageData(0);

      J := ObjectToJson(Product, [woHumanReadable]);

      m.Init(TOrmRunData, TRunData).AutoMap;

      SampleData.BoardSerial:='Hallo allemaal !!!!';

      os := m.ToA(SampleData);

      Check(os.SampleNumber=200);
      Check(os.BoardSerial='Hallo allemaal !!!!');

      os.Free;

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
  TestData          : TTestData;
  TestDatas         : TTestCollection;
  SampleData        : TRunData;
  SampleDatas       : TRunDataCollection;
  TD                : TThresholdDataItem;
  Document          : TDocument;
  D                 : double;
  i,j               : integer;
  TMode             : TThresholdModes;
  localtimer        : TPrecisionTimer;

begin
  Product:=TProduct.Create(nil);
  try
    Product.B_code:='Product001';

    Check(ProductService.AddProduct(Product) = seSuccess);
    Check(ProductService.GetProduct(Product) = seSuccess);

    TestData:=Product.TestDatas.Add;

    TestData.StageMode:=TStageMode.smCurrent;
    TestData.SetValue:=1234;

    SampleDatas:=TestData.RunDatas;

    localtimer.Start;

    for i:=1 to NUMRUNDATAS do
    begin
      SampleData:=SampleDatas.Add;

      SampleData.SampleNumber:=i;

      for j:=1 to NUMMEASUREMENTS do
      begin
        SampleData.MeasuredVoltage:=1111;
        SampleData.AddMeasurementData(Now);
        SampleData.MeasuredVoltage:=2222;
        SampleData.AddMeasurementData(Now);
      end;
      Check(SampleData.NewLiveData.Count=(NUMMEASUREMENTS*2));

      SampleData.ThresholdDataCollection.AddOrUpdate(TThresholdModes.tmMINV,true,TD);
      TD.Triggered:=True;
      TD.Data:=1.987;

      // Add the rundata into the database
      Check(ProductService.AddRunData(Product.B_code,TestData.StageMode,TestData.SetValue,SampleData) = seSuccess);

      SampleData.NewLiveData.Clear;
      SampleData.SampleNumber:=0;
      //Retrieve the rundata from the database
      Check(ProductService.FindRunData(Product.B_code,TestData.StageMode,TestData.SetValue,i,SampleData) = seSuccess);

      Check(SampleData.SampleNumber=i);
      Check(SampleData.NewLiveData.Count=(NUMMEASUREMENTS*2));

      D:=SampleData.NewLiveData.Item[0].Voltage;
      CheckSame(D,1111);
      D:=SampleData.NewLiveData.Item[1].Voltage;
      CheckSame(D,2222);
    end;
    NotifyTestSpeed('Storing and checking rundata', 0, 0, @localtimer);

    SampleDatas:=TestData.RunDatas;
    SampleDatas.Clear;
    Check(SampleDatas.Count=0);

    localtimer.Start;
    Check(ProductService.FindRunDatas(Product.B_code,TestData.StageMode,TestData.SetValue,{Summary=}true,SampleDatas) = seSuccess);
    json:=ObjectToJSON(SampleDatas);
    Check(SampleDatas.Count=NUMRUNDATAS);
    for i:=1 to NUMRUNDATAS do
    begin
      SampleData:=SampleDatas.Item[i-1];
      CheckSame(SampleData.NewLiveData.Count,1);
      D:=SampleData.NewLiveData.Item[0].Voltage;
      CheckSame(D,2222);
      TD:=SampleData.ThresholdDataCollection.Item[0];
      Check(TD.Mode=TThresholdModes.tmMINV);
      Check(TD.Triggered);
      CheckSame(TD.Data,1.987);
    end;
    NotifyTestSpeed('Retrieving summary of rundata', 0, 0, @localtimer);


    SampleDatas:=TestData.RunDatas;
    SampleDatas.Clear;
    Check(SampleDatas.Count=0);

    localtimer.Start;
    Check(ProductService.FindRunDatas(Product.B_code,TestData.StageMode,TestData.SetValue,{Summary=}false,SampleDatas) = seSuccess);
    Check(SampleDatas.Count=NUMRUNDATAS);
    for i:=1 to NUMRUNDATAS do
    begin
      SampleData:=SampleDatas.Item[i-1];
      CheckSame(SampleData.NewLiveData.Count,(NUMMEASUREMENTS*2));
      D:=SampleData.NewLiveData.Item[0].Voltage;
      CheckSame(D,1111);
      D:=SampleData.NewLiveData.Item[1].Voltage;
      CheckSame(D,2222);
      TD:=SampleData.ThresholdDataCollection.Item[0];
      Check(TD.Mode=TThresholdModes.tmMINV);
      Check(TD.Triggered);
      CheckSame(TD.Data,1.987);
    end;
    NotifyTestSpeed('Retrieving all of rundata', 0, 0, @localtimer);

    Document:=TDocument.Create(nil);
    DocumentService.FindDocument(Product.B_code,Document);
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

  DeleteFile(BATTERY_DATABASE_FILENAME);
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

  DeleteFile(BATTERY_DATABASE_FILENAME);
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
  TestData          : TTestData;
  TestDatas         : TTestCollection;
  SampleData        : TRunData;
  SampleDatas       : TRunDataCollection;
  TD                : TThresholdDataItem;
  Document          : TDocument;
  D                 : double;
  i,j               : integer;
  TMode             : TThresholdModes;
  localtimer        : TPrecisionTimer;

begin
  Product:=TProduct.Create(nil);
  try
    Product.B_code:='Product001';

    Check(ProductService.AddProduct(Product) = seSuccess);
    Check(ProductService.GetProduct(Product) = seSuccess);

    TestData:=Product.TestDatas.Add;

    TestData.StageMode:=TStageMode.smCurrent;
    TestData.SetValue:=1234;

    SampleDatas:=TestData.RunDatas;

    localtimer.Start;

    for i:=1 to NUMRUNDATAS do
    begin
      SampleData:=SampleDatas.Add;

      SampleData.SampleNumber:=i;

      for j:=1 to NUMMEASUREMENTS do
      begin
        SampleData.MeasuredVoltage:=1111;
        SampleData.AddMeasurementData(Now);
        SampleData.MeasuredVoltage:=2222;
        SampleData.AddMeasurementData(Now);
      end;
      Check(SampleData.NewLiveData.Count=(NUMMEASUREMENTS*2));

      SampleData.ThresholdDataCollection.AddOrUpdate(TThresholdModes.tmMINV,true,TD);
      TD.Triggered:=True;
      TD.Data:=1.987;

      // Add the rundata into the database
      Check(ProductService.AddRunData(Product.B_code,TestData.StageMode,TestData.SetValue,SampleData) = seSuccess);

      SampleData.NewLiveData.Clear;
      SampleData.SampleNumber:=0;
      //Retrieve the rundata from the database
      Check(ProductService.FindRunData(Product.B_code,TestData.StageMode,TestData.SetValue,i,SampleData) = seSuccess);

      Check(SampleData.SampleNumber=i);
      Check(SampleData.NewLiveData.Count=(NUMMEASUREMENTS*2));

      D:=SampleData.NewLiveData.Item[0].Voltage;
      CheckSame(D,1111);
      D:=SampleData.NewLiveData.Item[1].Voltage;
      CheckSame(D,2222);
    end;
    NotifyTestSpeed('Storing and checking rundata', 0, 0, @localtimer);

    SampleDatas:=TestData.RunDatas;
    SampleDatas.Clear;
    Check(SampleDatas.Count=0);

    localtimer.Start;
    Check(ProductService.FindRunDatas(Product.B_code,TestData.StageMode,TestData.SetValue,{Summary=}true,SampleDatas) = seSuccess);
    json:=ObjectToJSON(SampleDatas);
    Check(SampleDatas.Count=NUMRUNDATAS);
    for i:=1 to NUMRUNDATAS do
    begin
      SampleData:=SampleDatas.Item[i-1];
      CheckSame(SampleData.NewLiveData.Count,1);
      D:=SampleData.NewLiveData.Item[0].Voltage;
      CheckSame(D,2222);
      TD:=SampleData.ThresholdDataCollection.Item[0];
      Check(TD.Mode=TThresholdModes.tmMINV);
      Check(TD.Triggered);
      CheckSame(TD.Data,1.987);
    end;
    NotifyTestSpeed('Retrieving summary of rundata', 0, 0, @localtimer);


    SampleDatas:=TestData.RunDatas;
    SampleDatas.Clear;
    Check(SampleDatas.Count=0);

    localtimer.Start;
    Check(ProductService.FindRunDatas(Product.B_code,TestData.StageMode,TestData.SetValue,{Summary=}false,SampleDatas) = seSuccess);
    Check(SampleDatas.Count=NUMRUNDATAS);
    for i:=1 to NUMRUNDATAS do
    begin
      SampleData:=SampleDatas.Item[i-1];
      CheckSame(SampleData.NewLiveData.Count,(NUMMEASUREMENTS*2));
      D:=SampleData.NewLiveData.Item[0].Voltage;
      CheckSame(D,1111);
      D:=SampleData.NewLiveData.Item[1].Voltage;
      CheckSame(D,2222);
      TD:=SampleData.ThresholdDataCollection.Item[0];
      Check(TD.Mode=TThresholdModes.tmMINV);
      Check(TD.Triggered);
      CheckSame(TD.Data,1.987);
    end;
    NotifyTestSpeed('Retrieving all of rundata', 0, 0, @localtimer);

    Document:=TDocument.Create(nil);
    DocumentService.FindDocument(Product.B_code,Document);
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
  DeleteFile(BATTERY_DATABASE_FILENAME);

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

  DeleteFile(BATTERY_DATABASE_FILENAME);

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

