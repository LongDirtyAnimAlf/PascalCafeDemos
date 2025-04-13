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

    function  GetProduct(var Product: TProduct):boolean;
    function  AddProduct(const Product: TProduct):boolean;
    function  UpdateProductCode(const Product: TProduct; const NewCode:RawUTF8):boolean;
    function  UpdateProduct(const Product: TProduct; const FieldInfo:RawUTF8):boolean;overload; // FieldInfo can only be a single fieldname or all fields "*"
    function  DeleteProduct(const Product: TProduct):boolean;
    function  ChangedProduct(const Product: TProduct;out Changed:boolean):boolean;

    function  GetDocuments(const Product: TProduct; var ADocuments: TDocumentCollection):boolean;
    function  GetDocument(const AProductDocument: TProductDocument; var ADocument: TDocument):boolean;
    function  GetDocumentThumb(const AProductDocument: TProductDocument):boolean;
    function  AddDocument(var AProductDocument: TProductDocument):boolean;

  published
    property Connected         : boolean read FConnected;
    property DocumentService   : IDocumentService read fDS;
    property ProductService    : IProductService read fPS;
  end;


implementation

uses
  {$ifdef USE_DEBUGSERVER}
  server,
  {$endif}
  client;

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
        if ownserver then
        begin
          DataBaseServer := TServer.Create({HTTPServer=}true);
        end;
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
        DataBaseConnection:=TServer.Create(ownserver);
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

function TSharedmORMotDDD.UpdateProductCode(const Product: TProduct; const NewCode:RawUTF8):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.UpdateProductCode(Product.Code,NewCode) = seSuccess);
end;

function TSharedmORMotDDD.UpdateProduct(const Product: TProduct; const FieldInfo:RawUTF8):boolean;
var
  TD           : variant;
begin
  result:=false;
  if (NOT fConnected) then exit;
  if ProductFieldsToVariant(Product,FieldInfo,TD) then
    result:=(ProductService.UpdateProduct(Product.Code,TD) = seSuccess);
end;

function TSharedmORMotDDD.DeleteProduct(const Product: TProduct):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.DeleteProduct(Product.ProductCode) = seSuccess);
end;

function TSharedmORMotDDD.ChangedProduct(const Product: TProduct; out Changed:boolean):boolean;
begin
  result:=false;
  if (NOT fConnected) then exit;
  result:=(ProductService.ChangedProduct(Product.ProductCode,Product.Version,Changed) = seSuccess);
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
      Document.ProductCode:=LocalProduct.ProductCode;
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

end.

