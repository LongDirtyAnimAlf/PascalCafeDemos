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
    function JSONToCollection(const Data:string; Coll:TCollection):boolean;
    function CollectionToJSON(const Coll:TCollection; out Data:string):boolean;
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

uses
  DateUtils;

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
  S:string;
begin
  if not (Sender is TJSONDeStreamer) then
    raise EJSONRTTI.Create('Sender has invalid type');

  if (NOT IsWriteableProp(Info)) then
  begin
    // This is or might be very "dirty" !!!
    // Trick to write fields that do not have write access by writing to read field
    // But its the same way as done by the mORMot
    // FPC only !!
    {$ifdef FPC}
    if ((NOT Handled) AND IsReadableProp(Info)) then
    begin
      PI := Info^;
      PI.PropProcs:=(PI.PropProcs shl 2); // shift read-procs towards write-procs
      PI.SetProc:=PI.GetProc; // use getproc as setproc
      if ((PI.SetProc<>nil) AND ((integer(PI.PropProcs) and 3 = ptField))) then
      begin
        Handled:=True;
        case PI.PropType^.Kind of
            tkAString,tkWString,tkUString,tkSString: SetStrProp(AObject,@PI,AValue.AsString);
            tkInteger: SetOrdProp(AObject,@PI,AValue.AsInteger);
            tkInt64,tkQWord: SetInt64Prop(AObject,@PI,AValue.AsInt64);
            tkFloat:
              begin
                if PI.PropType=TypeInfo(TDateTime) then
                begin
                  S:=DateTimeToStr(AValue.AsFloat);
                  SetStrProp(AObject,@PI,S);
                end
                else
                  SetFloatProp(AObject,@PI,AValue.AsFloat);
              end;
            tkVariant: SetVariantProp(AObject,@PI,AValue.Value);
        else
          Handled:=False;
        end;
      end;

    end;
    {$endif FPC}
  end;

end;

function TSharedmORMotDDD.JSONToCollection(const Data:string; Coll:TCollection):boolean;
var
  JD:TJSONDeStreamer;
begin
  result:=false;
  if Assigned(Coll) then
  begin
    JD := TJSONDeStreamer.Create(nil);
    try
      JD.OnRestoreProperty := @restoreProperty;
      JD.JSONToCollection(Data,Coll);
    finally
      JD.Free;
    end;
  end;
end;

function TSharedmORMotDDD.CollectionToJSON(const Coll:TCollection; out Data:string):boolean;
var
  JS : TJSONStreamer;
begin
  result:=true;
  if Assigned(Coll) then
  begin
    if (Coll.Count>0) then
    begin
      JS := TJSONStreamer.Create(nil);
      try
        JS.Options:=[jsoDateTimeAsString,jsoCheckEmptyDateTime];
        Data:=JS.CollectionToJSON(Coll);
      finally
        JS.Free;
      end;
    end;
  end;
end;

function TSharedmORMotDDD.GetProductTable(var Products:TProductCollection):boolean;
var
  MS:TStringStream;
begin
  result:=false;
  if Assigned(Products) then
  begin

    if FileExists(DATABASEFILE) then
    begin
      MS := TStringStream.Create;
      try
        MS.LoadFromFile(DATABASEFILE);
        JSONToCollection(MS.DataString,Products);
      finally
        MS.Free;
      end;

      if FileExists(DOCUMENTSFILE) then
      begin
        MS := TStringStream.Create;
        try
          MS.LoadFromFile(DOCUMENTSFILE);
          JSONToCollection(MS.DataString,Documents);
        finally
          MS.Free;
        end;
      end;

    end;
  end;
end;

function TSharedmORMotDDD.SaveProductTable(const Products:TProductCollection):boolean;
var
  Data:string;
  MS : TStringStream;
begin
  result:=true;
  if Assigned(Products) then
  begin

    // Save all products if any
    if (Products.Count>0) then
    begin
      CollectionToJSON(Products,Data);
      MS := TStringStream.Create;
      try
        MS.WriteString(Data);
        MS.SaveToFile(DATABASEFILE);
      finally
        MS.Free;
      end;
    end;

    // Save all documents, if any
    if (Documents.Count>0) then
    begin
      CollectionToJSON(Documents,Data);
      MS := TStringStream.Create;
      try
        MS.WriteString(Data);
        MS.SaveToFile(DOCUMENTSFILE);
      finally
        MS.Free;
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
    Document.SetData(AProductDocument.Path,True);
    Document.ProductCode:=LocalProduct.ProductCode;
    Document.Hash:=AProductDocument.Hash;
    AProductDocument.FileThumb:=Document.FileThumb;
    result:=true;
  end;
end;

end.

