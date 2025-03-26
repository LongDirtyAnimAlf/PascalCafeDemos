unit databaseinfra;

//{$mode ObjFPC}{$H+}

{$I mormot.defines.inc}
{$I globaldefines.inc}

interface

uses
  Classes,
  SysUtils,
  servicesshared,
  productserviceinterface,
  documentserviceinterface,
  productdom,
  rundatadom,
  documentdom;

type
  TSharedmORMotDDD = class(TObject)
  private
    FConnected         : boolean;
    fDS                : IDocumentService;
    fPS                : IProductService;
    DataBaseConnection : TObject;
    DataBaseServer     : TObject;
  public
    constructor Create;
    destructor Destroy;override;

    procedure ConnectNew(remote:boolean; ownserver:boolean);
    procedure DisConnect;

    function  GetProductTable(var Products:TProductCollection):boolean;
    function  GetProductRunData(ARunData: TRunData):boolean;
    function  GetProductRunDatas(var ARunDatas: TRunDataCollection):boolean;
    function  UpdateRunData(const ARunData: TRunData; const Fieldinfo:RawUTF8):boolean;
    function  DeleteRunData(const ARunData: TRunData):boolean;

    function  GetProduct(var Product: TProduct):boolean;
    function  AddProduct(const Product: TProduct):boolean;
    function  UpdateProduct(const Product: TProduct; const Fieldinfo:RawUTF8):boolean;
    function  DeleteProduct(const Product: TProduct):boolean;
    function  ChangedProduct(const Product: TProduct;out Changed:boolean):boolean;

    function  GetDocuments(const Product: TProduct; var ADocuments: TDocumentCollection):boolean;
    function  GetDocument(const AProductDocument: TProductDocument; var ADocument: TDocument):boolean;
    function  GetDocumentThumb(const AProductDocument: TProductDocument):boolean;
    function  AddDocument(var AProductDocument: TProductDocument):boolean;

    function ImportDatabase(aDBFilename:string; var Batteries:TProductCollection):boolean;
  published
    property Connected         : boolean read FConnected;
    property DocumentService   : IDocumentService read fDS;
    property ProductService    : IProductService read fPS;
  end;


implementation

uses
  mormot.core.variants,
  mormot.core.text,
  mormot.core.rtti,
  {$ifdef USE_DEBUGSERVER}
  server,
  {$endif}
  client,
  productstorageimplementation; // for database import

constructor TSharedmORMotDDD.Create;
begin
  DataBaseConnection := nil;
  DataBaseServer := nil;
  inherited Create;
end;

destructor TSharedmORMotDDD.Destroy;
begin
  DisConnect;
  inherited Destroy;
end;

procedure TSharedmORMotDDD.ConnectNew(remote:boolean; ownserver:boolean);
begin
  if (NOT fConnected) then
  begin
    fConnected:=True;

    if remote then
    begin
      try
        {$ifdef USE_DEBUGSERVER}
        DataBaseServer := TServer.Create({HTTPServer=}true);
        {$endif}
        try
          DataBaseConnection:=TClient.Create('localhost');
          with DataBaseConnection AS TClient do
          begin
            if (ClientConnected) then
            begin
              fPS:=ClientProductService;
              fDS:=ClientDocumentService;
            end;
          end;
        except
          fConnected:=False;
        end;
      except
        fConnected:=False;
      end;
    end
    else
    begin
      try
        DataBaseConnection:=TServer.Create({$ifdef USE_DEBUGSERVER}true{$else}false{$endif});
        with DataBaseConnection AS TServer do
        begin
          fPS:=ServerProductService;
          fDS:=ServerDocumentService;
        end;
      except
        fConnected:=False;
      end;
    end;
  end;

  if fConnected then
  begin
    fConnected:=(Assigned(fPS) AND Assigned(fDS));
  end;

  if (NOT fConnected) then DisConnect;
end;

procedure TSharedmORMotDDD.DisConnect;
begin
  fDS:=nil;
  fPS:=nil;

  if Assigned(DataBaseConnection) then
  begin
    DataBaseConnection.Destroy;
    DataBaseConnection:=nil;
  end;

  if Assigned(DataBaseServer) then
  begin
    DataBaseServer.Destroy;
    DataBaseServer:=nil;
  end;

  fConnected:=false;
end;

function TSharedmORMotDDD.GetProductTable(var Products:TProductCollection):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if Assigned(Products) then
  begin
    result:=(ProductService.GetAllProducts(Products) = seSuccess);
  end;
end;

function TSharedmORMotDDD.GetProductRunData(ARunData: TRunData):boolean;
var
  LocalProduct : TProduct;
  TestData     : TTestData;
  SampleNumber : integer;
  i            : integer;
begin
  result:=false;
  if (NOT fConnected) then exit;
  SampleNumber:=ARunData.SampleNumber;
  if (SampleNumber<1) then exit;
  TestData:=(ARundata.GetOwner AS TTestData);
  if Assigned(TestData) then
  begin
    LocalProduct:=TestData.GetOwner;
    if Assigned(LocalProduct) then
      result:=(ProductService.FindRunData(LocalProduct.B_code,TestData.StageMode,TestData.SetValue,SampleNumber,ARunData) = seSuccess);
  end;
end;

function TSharedmORMotDDD.GetProductRunDatas(var ARunDatas: TRunDataCollection):boolean;
var
  LocalProduct : TProduct;
  TestData     : TTestData;
  ARunData     : TRunData;
  i            : integer;
begin
  result:=false;
  if (NOT fConnected) then exit;
  TestData:=TTestData(ARunDatas.Owner);
  if Assigned(TestData) then
  begin
    LocalProduct:=TestData.GetOwner;
    if Assigned(LocalProduct) then
      result:=(ProductService.FindRunDatas(LocalProduct.B_code,TestData.StageMode,TestData.SetValue,true,ARunDatas) = seSuccess);
  end;
end;

function TSharedmORMotDDD.UpdateRunData(const ARunData: TRunData; const Fieldinfo:RawUTF8):boolean;
var
  TD            : variant;
  LocalProduct  : TProduct;
  TestData      : TTestData;
begin
  result:=false;
  if (NOT fConnected) then exit;
  TestData:=(ARundata.GetOwner AS TTestData);
  if Assigned(TestData) then
  begin
    LocalProduct:=TestData.GetOwner;
    if Assigned(LocalProduct) then
    begin
      if RunDataFieldsToVariant(ARunData,Fieldinfo,TD) then
        result:=(ProductService.UpdateRunData(LocalProduct.B_code,TestData.StageMode,TestData.SetValue,TD) = seSuccess);
    end;
  end;
end;

function TSharedmORMotDDD.GetProduct(var Product: TProduct):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.GetProduct(Product) = seSuccess);
end;

function TSharedmORMotDDD.AddProduct(const Product: TProduct):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.AddProduct(Product) = seSuccess);
end;

function TSharedmORMotDDD.UpdateProduct(const Product: TProduct; const Fieldinfo:RawUTF8):boolean;
var
  TD           : variant;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if ProductFieldsToVariant(Product,Fieldinfo,TD) then
    result:=(ProductService.UpdateProduct(Product.Code,TD) = seSuccess);
end;

function TSharedmORMotDDD.DeleteProduct(const Product: TProduct):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.DeleteProduct(Product.B_code) = seSuccess);
end;

function TSharedmORMotDDD.ChangedProduct(const Product: TProduct;out Changed:boolean):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.ChangedProduct(Product.B_code,Product.Version,Changed) = seSuccess);
end;

function TSharedmORMotDDD.DeleteRunData(const ARunData: TRunData):boolean;
var
  LocalProduct   : TProduct;
  TestData       : TTestData;
  SampleNumber   : integer;
begin
  result:=false;
  if (NOT fConnected) then exit;
  SampleNumber:=ARunData.SampleNumber;
  if (SampleNumber<1) then exit;
  TestData:=(ARundata.GetOwner AS TTestData);
  if Assigned(TestData) then
  begin
    LocalProduct:=TestData.GetOwner;
    if Assigned(LocalProduct) then
    begin
      ProductService.DeleteRunData(LocalProduct.B_code,TestData.StageMode,TestData.SetValue,SampleNumber);
    end;
  end;
  result:=true;
end;

function TSharedmORMotDDD.GetDocuments(const Product: TProduct; var ADocuments: TDocumentCollection):boolean;
var
  ProductDocumentRunner: TProductDocument;
  ADocument:TDocument;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if Assigned(ADocuments) then
  begin
    for TCollectionItem(ProductDocumentRunner) in Product.Documents do
    begin
      // Find the document or create a new one if not existing
      ADocuments.AddOrUpdate(ProductDocumentRunner.Hash,true,ADocument);
      // Get the document if any
      result:=(DocumentService.FindDocument(ProductDocumentRunner.Hash,ADocument) = seSuccess);
    end;
  end;
end;

function TSharedmORMotDDD.GetDocument(const AProductDocument: TProductDocument; var ADocument: TDocument):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if Assigned(ADocument) then
  begin
    // Get the document if any
    result:=(DocumentService.FindDocument(AProductDocument.Hash,ADocument) = seSuccess);
  end;
end;

function TSharedmORMotDDD.GetDocumentThumb(const AProductDocument: TProductDocument):boolean;
var
  Document:TDocument;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if Assigned(AProductDocument) then
  begin
    Document:=TDocument.Create(nil);
    Document.Hash:=AProductDocument.Hash;
    // Get the document thumb if any
    result:=(DocumentService.GetDocumentThumb(Document) = seSuccess);
    if result then
    begin
      AProductDocument.FileThumb:=Document.FileThumb;
    end;
    Document.Free;
  end;
end;


function TSharedmORMotDDD.AddDocument(var AProductDocument: TProductDocument):boolean;
var
  Document       : TDocument;
  LocalProduct   : TProduct;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if Assigned(AProductDocument) then
  begin
    LocalProduct:=AProductDocument.GetOwner;
    Document:=TDocument.Create(nil);
    try
      Document.SetPath(AProductDocument.Path,True);
      Document.ProductCode:=LocalProduct.B_code;
      Document.Hash:=AProductDocument.Hash;
      result:=(DocumentService.AddDocument(Document) = seSuccess);
      if result then
      begin
        // We now have a thumb of the file
        // Save it in the ProductDocument for rapid GUI
        AProductDocument.FileThumb:=Document.FileThumb;
      end;
    finally
      Document.Free;
    end;
  end;
end;

function TSharedmORMotDDD.ImportDatabase(aDBFilename:string; var Batteries:TProductCollection):boolean;
var
  NewProductStore     : TProductStorage;
  NewProduct          : TProduct;
  NewProducts         : TProductCollection;
  NewTestData         : TTestData;
  NewTestDatas        : TTestCollection;
  NewRunData          : TRunData;
  NewRunDatas         : TRunDataCollection;
  AddedProduct        : TProduct;
begin
  result:=false;

  if (NOT fConnected) then exit;

  // This is all somehat low level coding to be able to append database contents into the current datastore
  // However, might work better than export/import through data files

  NewProductStore:=TProductStorage.Create(nil,aDBFilename);

  NewProducts := TProductCollection.Create;
  NewProductStore.RetrieveProducts(NewProducts);

  for TCollectionItem(NewProduct) in NewProducts do
  begin
    if Batteries.AddOrUpdate(NewProduct.B_code, True, AddedProduct) then
    begin
      // We have new a new battery: get the new battery data !
      NewProductStore.RetrieveProduct(AddedProduct);

      // Store the new battery data
      AddProduct(AddedProduct);

      // Handle the rundata
      NewTestDatas:=AddedProduct.TestDatas;
      for TCollectionItem(NewTestData) in NewTestDatas do
      begin
        NewRunDatas:=NewTestData.RunDatas;
        NewRunDatas.Clear;
        // We have new a new battery: get the new battery rundata !
        NewProductStore.RetrieveRunDatas(AddedProduct.B_code, NewTestData.StageMode, NewTestData.SetValue, false, NewRunDatas);
        for TCollectionItem(NewRunData) in NewRunDatas do
        begin
          // Store the new battery rundata
          ProductService.AddRunData(AddedProduct.B_code,NewTestData.StageMode,NewTestData.SetValue,NewRunData);
        end;

      end;
    end
    else
    begin
      // We have existing data !!
      // Retrieve all data from database to append the new data
      NewTestDatas:=AddedProduct.TestDatas;
      for TCollectionItem(NewTestData) in NewTestDatas do
      begin
        NewRunDatas:=NewTestData.RunDatas;
        if NewRunDatas.Count=0 then GetProductRunDatas(NewRunDatas);
        if NewRunDatas.Count=0 then continue;
        for TCollectionItem(NewRunData) in NewRunDatas do
        begin
          if (NewRunData.NewLiveData.Count<=1) then GetProductRunData(NewRunData);
        end;
      end;

      // Now add the additional data into this existing battery !!


    end;
  end;

  NewProducts.Free;
  NewProductStore.free;
end;

end.

