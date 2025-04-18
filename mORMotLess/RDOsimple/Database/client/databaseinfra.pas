unit databaseinfra;

//{$mode ObjFPC}{$H+}

{$MODE OBJFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$OPTIMIZATION NOORDERFIELDS}

{$I globaldefines.inc}

interface

uses
  Classes,
  SysUtils,
  servicesshared,
  fpjson,
  fpjsonrtti,
  typinfo,
  productdom,
  documentdom;

type
  TSharedmORMotDDD = class(TObject)
  private
    procedure restoreProperty(Sender : TObject; AObject : TObject; Info : PPropInfo;
      AValue : TJSONData; Var Handled : Boolean);
  public
    constructor Create;
    destructor Destroy;override;

    function  GetProductTable(var Products:TProductCollection):boolean;
    function  SaveProductTable(const Products:TProductCollection):boolean;

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
  end;


implementation

constructor TSharedmORMotDDD.Create;
begin
  inherited Create;
end;

destructor TSharedmORMotDDD.Destroy;
begin
  inherited Destroy;
end;

procedure TSharedmORMotDDD.restoreProperty(Sender : TObject; AObject : TObject; Info : PPropInfo;
  AValue : TJSONData; Var Handled : Boolean);
begin
  if not (Sender is TJSONDeStreamer) then
    raise EJSONRTTI.Create('Sender has invalid type');

  if Info^.PropType = TProductDocumentCollection.ClassInfo then
  begin
    // We might do some special things for the documents collection if needed
  end;

  // Prevent readonly properties to cause an exception
  if (Info^.SetProc=nil) then Handled:=True;
end;

function TSharedmORMotDDD.GetProductTable(var Products:TProductCollection):boolean;
var
  JD:TJSONDeStreamer;
  MS:TStringStream;
begin
  result:=false;
  if Assigned(Products) then
  begin
    JD := TJSONDeStreamer.Create(nil);
    try
      MS := TStringStream.Create;
      try
        MS.LoadFromFile('database.json');
        JD.OnRestoreProperty := @restoreProperty;
        JD.JSONToCollection(MS.DataString,Products);
      finally
        MS.Free;
      end;
    finally
      JD.Free;
    end;
  end;
end;

function TSharedmORMotDDD.SaveProductTable(const Products:TProductCollection):boolean;
var
  JS : TJSONStreamer;
  MS : TStringStream;
begin
  result:=true;
  if Assigned(Products) then
  begin
    JS := TJSONStreamer.Create(nil);
    try
      MS := TStringStream.Create;
      try
        MS.WriteString(JS.CollectionToJSON(Products));
        MS.SaveToFile('database.json');
      finally
        MS.Free;
      end;
    finally
      JS.Free;
    end;
  end;
end;

function TSharedmORMotDDD.GetProduct(var Product: TProduct):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.AddProduct(const Product: TProduct):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.UpdateProductCode(const Product: TProduct; const NewCode:RawUTF8):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.UpdateProduct(const Product: TProduct; const FieldInfo:RawUTF8):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.DeleteProduct(const Product: TProduct):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.ChangedProduct(const Product: TProduct; out Changed:boolean):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.GetDocuments(const Product: TProduct; var ADocuments: TDocumentCollection):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.GetDocument(const AProductDocument: TProductDocument; var ADocument: TDocument):boolean;
begin
  result:=false;
end;

function TSharedmORMotDDD.GetDocumentThumb(const AProductDocument: TProductDocument):boolean;
var
  Document:TDocument;
begin
  result:=false;
end;

function TSharedmORMotDDD.AddDocument(var AProductDocument: TProductDocument):boolean;
begin
  result:=false;
  if Assigned(AProductDocument) then
  begin
  end;
end;

end.

