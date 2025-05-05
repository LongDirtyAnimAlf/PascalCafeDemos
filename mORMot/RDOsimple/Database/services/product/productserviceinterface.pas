unit productserviceinterface;

interface

{$I mormot.defines.inc}

uses
  classes,
  mormot.core.base,
  mormot.core.interfaces,
  servicesshared,
  productinfra, // only needed for initialization (registration) of the collections.
  productdom;

type
  IProductService = interface(IInvokable)
    ['{B8DE093D-A027-4C61-A67B-638FB0F23242}']
    function AddProduct(const AProduct: TProduct): TServiceResult;
    function GetProduct(var AProduct: TProduct): TServiceResult;
    function GetProductByCode(const aCode:RawUTF8; out AProduct: TProduct): TServiceResult;
    function GetProductImageByCode(const aCode:RawUTF8; out AImage: RawBlob): TServiceResult;
    function GetAllProducts(out AProducts: TProductCollection): TServiceResult;
    function UpdateProductCode(const aProductCode:RawUTF8; const NewCode:RawUTF8):TServiceResult;
    function UpdateProduct(const aProductCode:RawUTF8; const FieldData:Variant): TServiceResult;
    function DeleteProduct(const aProductCode:RawUTF8): TServiceResult;
    function ChangedProduct(const aProductCode:RawUTF8; const aVersion:Int64; out Changed:boolean): TServiceResult;
  end;

  function ProductFieldsToVariant(const Product: TProduct; const Fieldinfo:RawUTF8; out TD:variant):boolean;

implementation

uses
  mormot.core.data,
  mormot.core.buffers,
  mormot.core.variants,
  mormot.core.text,
  mormot.core.json,
  mormot.core.rtti;

function ProductFieldsToVariant(const Product: TProduct; const Fieldinfo:RawUTF8; out TD:variant):boolean;
var
  rA           : TRttiCustom;
  pa           : PRttiCustomProp;
  TD2          : variant;
  count        : integer;
  BlobField    : boolean;
  json,magic   : RawUTF8;
begin
  result:=false;

  TDocVariantData(TD).Clear;

  //rA := Rtti.RegisterClass(TProduct);
  rA := Rtti.RegisterClass(PClass(Product)^);
  if Assigned(rA) then
  begin
    if Fieldinfo='*' then
    begin
      // All fields
      // However, the fields are filtered: not the collections and not the thumb
      pa := pointer(rA.Props.List);
      count:=rA.Props.Count;
      repeat
        begin
          if (pa^.Value<>nil) and (pa^.Value.Info<>nil) then
          begin
            BlobField:=false;
            // Detect blobber fields
            if NOT BlobField then BlobField:=(pa^.Value.Info^.IsRawBlob);
            if NOT BlobField then BlobField:=(pa^.Value.Info=TypeInfo(TBlobber));
            // Skip certain collections
            if (pa^.Value.Info^.Kind=rkClass) then
            begin
              if (pa^.Value.ValueRtlClass=vcCollection) then
              begin
                // Skip the document collection
                if NOT BlobField then BlobField:=(pa^.Value.Info^.RttiClass^.RttiClass=TProductDocumentCollection);
              end;
            end;
            if NOT BlobField then
            begin
              // Get fielddata as variant
              pa^.GetValueVariant(Product,TVarData(TD2), @JSON_[mDefault]);
              // Add requested fieldname and fielddata
              _ObjAddProps([FieldInfo,TD2],TD);
              // Prevent memory leak
              TDocVariantData(TD2).Clear;
            end;
          end;
        end;
        inc(pa);
        dec(count);
      until count = 0;
    end
    else
    begin
      // Single field
      pa := rA.Props.Find(FieldInfo);
      if Assigned(pa) then
      begin
        BlobField:=false;
        // Detect blobber fields
        if NOT BlobField then BlobField:=(pa^.Value.Info^.IsRawBlob);
        if NOT BlobField then BlobField:=(pa^.Value.Info=TypeInfo(TBlobber));
        if BlobField then
        begin
          // Blob data needs to be converted into Base64 [with some exta magic]
          json:=pa^.GetValueText(Product);
          //magic:=BinToBase64WithMagic(json); // with magic
          magic:=BinToBase64(json); // without magic
          //magic:=json;
          // Add requested fieldname and fielddata
          TD:=_ObjFast([FieldInfo,magic]);
        end
        else
        begin
          pa^.GetValueVariant(Product,TVarData(TD2), @JSON_[mDefault]);
          // Add requested fieldname and fielddata
          TD:=_ObjFast([FieldInfo,TD2]);
          // Prevent memory leak
          TDocVariantData(TD2).Clear;
        end;
      end;
    end;

    if (TDocVariantData(TD).Count>0) then result:=true;
  end;
end;

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IProductService)
    ]);

end.
