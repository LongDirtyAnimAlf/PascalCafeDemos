unit databaseinfra;

{$mode ObjFPC}{$H+}

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
    Documents: TDocumentCollection;
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

    function  GetDocument(const AProductDocument: TProductDocument; var ADocument: TDocument):boolean;
    function  GetDocumentThumb(const AProductDocument: TProductDocument):boolean;
    function  AddDocument(var AProductDocument: TProductDocument):boolean;
  end;


implementation

const
  DATABASEFILE    = 'database.json';
  DOCUMENTSFILE   = 'documents.json';

constructor TSharedmORMotDDD.Create;
begin
  inherited Create;
  Documents:=TDocumentCollection.Create;
end;

destructor TSharedmORMotDDD.Destroy;
begin
  Documents.Free;
  inherited Destroy;
end;

procedure TSharedmORMotDDD.restoreProperty(Sender : TObject; AObject : TObject; Info : PPropInfo;
  AValue : TJSONData; Var Handled : Boolean);
var
  PI : TPropInfo;
begin
  if not (Sender is TJSONDeStreamer) then
    raise EJSONRTTI.Create('Sender has invalid type');

  if Info^.PropType = TProductDocumentCollection.ClassInfo then
  begin
    // We might do some special things for the product documents collection if needed
  end;

  if (NOT IsWriteableProp(Info)) then
  begin
    // This is or might be very "dirty" !!!
    // Trick to write fields that do not have write access
    // But its the same way as done by the mORMot
    PI := Info^;
    PI.PropProcs:=(PI.PropProcs shl 2);
    PI.SetProc:=PI.GetProc;
    case PI.PropType^.Kind of
      tkAString: SetStrProp(AObject,@PI,AValue.AsString);
      tkInteger: SetOrdProp(AObject,@PI,AValue.AsInt64);
    else
      SetVariantProp(AObject,@PI,AValue.Value);
    end;
    Handled:=True;
  end;
end;

function TSharedmORMotDDD.GetProductTable(var Products:TProductCollection):boolean;
var
  JD:TJSONDeStreamer;
  MS:TStringStream;
begin
  result:=false;
  if Assigned(Products) then
  begin

    if FileExists(DATABASEFILE) then
    begin
      // Get all products from product store
      JD := TJSONDeStreamer.Create(nil);
      try
        MS := TStringStream.Create;
        try
          MS.LoadFromFile(DATABASEFILE);
          JD.OnRestoreProperty := @restoreProperty;
          JD.JSONToCollection(MS.DataString,Products);
        finally
          MS.Free;
        end;
      finally
        JD.Free;
      end;

      if FileExists(DOCUMENTSFILE) then
      begin
        // Get all docments from document store
        JD := TJSONDeStreamer.Create(nil);
        try
          MS := TStringStream.Create;
          try
            MS.LoadFromFile(DOCUMENTSFILE);
            JD.OnRestoreProperty := @restoreProperty;
            JD.JSONToCollection(MS.DataString,Documents);
          finally
            MS.Free;
          end;
        finally
          JD.Free;
        end;
      end;

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

    // Save all products if any
    if (Products.Count>0) then
    begin
      JS := TJSONStreamer.Create(nil);
      try
        MS := TStringStream.Create;
        try
          MS.WriteString(JS.CollectionToJSON(Products));
          MS.SaveToFile(DATABASEFILE);
        finally
          MS.Free;
        end;
      finally
        JS.Free;
      end;
    end;

    // Save all documents, if any
    if (Documents.Count>0) then
    begin
      JS := TJSONStreamer.Create(nil);
      try
        MS := TStringStream.Create;
        try
          MS.WriteString(JS.CollectionToJSON(Documents));
          MS.SaveToFile(DOCUMENTSFILE);
        finally
          MS.Free;
        end;
      finally
        JS.Free;
      end;
    end;

  end;
end;

function TSharedmORMotDDD.GetProduct(var Product: TProduct):boolean;
begin
  // Nothing to be done
  result:=false;
end;

function TSharedmORMotDDD.AddProduct(const Product: TProduct):boolean;
begin
  // Nothing to be done
  result:=false;
end;

function TSharedmORMotDDD.UpdateProductCode(const Product: TProduct; const NewCode:RawUTF8):boolean;
begin
  result:=false;
  if (Product.ProductCode<>NewCode) then
  begin
    Product.ProductCode:=NewCode;
    // This statement triggers a notify change with the item itself as the data !!
    Product.DisplayName:=Product.ProductCode;
    result:=true;
  end;
end;

function TSharedmORMotDDD.UpdateProduct(const Product: TProduct; const FieldInfo:RawUTF8):boolean;
begin
  result:=false;
  if (FieldInfo='*') then
  begin
    // As we do not check for changes of the data, this update will also be triggered when the edit leaves the focus
    // See: procedure TWinControl.WMKillFocus(var Message: TLMKillFocus); in wincontrols.inc
    // This WMKillFocus procedure will also call EditingDone unfortunately

    // Product fields are already updated in the GUI, so noting to be done here
    // This statement triggers a notify change with the item itself as the data !!
    Product.DisplayName:=Product.ProductCode;
    result:=true;
  end;
end;

function TSharedmORMotDDD.DeleteProduct(const Product: TProduct):boolean;
begin
  // Nothing to be done
  result:=false;
end;

function TSharedmORMotDDD.ChangedProduct(const Product: TProduct; out Changed:boolean):boolean;
begin
  // Nothing to be done
  result:=false;
end;

function TSharedmORMotDDD.GetDocument(const AProductDocument: TProductDocument; var ADocument: TDocument):boolean;
var
  Document:TDocument;
begin
  result:=false;
  if Assigned(ADocument) then
  begin
    // Get the document if any
    Documents.AddOrUpdate(AProductDocument.Hash,false,Document);
    if Assigned(Document) then
    begin
      ADocument.Assign(Document);
      result:=true;
    end;
  end;
end;

function TSharedmORMotDDD.GetDocumentThumb(const AProductDocument: TProductDocument):boolean;
var
  Document:TDocument;
begin
  result:=false;
  if Assigned(AProductDocument) then
  begin
    // Get the document if any
    Documents.AddOrUpdate(AProductDocument.Hash,false,Document);
    if Assigned(Document) then result:=true;
    if result then
    begin
      AProductDocument.FileThumb:=Document.FileThumb;
    end;
  end;
end;

function TSharedmORMotDDD.AddDocument(var AProductDocument: TProductDocument):boolean;
var
  LocalProduct   : TProduct;
  Document       : TDocument;
begin
  result:=false;
  if Assigned(AProductDocument) then
  begin
    LocalProduct:=AProductDocument.GetOwner;
    Documents.AddOrUpdate(AProductDocument.Hash,true,Document);
    Document.SetPath(AProductDocument.Path,True);
    Document.ProductCode:=LocalProduct.ProductCode;
    Document.Hash:=AProductDocument.Hash;
    AProductDocument.FileThumb:=Document.FileThumb;
    result:=true;
  end;
end;

end.

