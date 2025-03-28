unit productserviceinterface;

interface

{$I mormot.defines.inc}

uses
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
    function UpdateProduct(const aProductCode:RawUTF8; const FieldData:Variant): TServiceResult;
    function DeleteProduct(const aProductCode:RawUTF8): TServiceResult;
    function ChangedProduct(const aProductCode:RawUTF8; const aVersion:Int64; out Changed:boolean): TServiceResult;
  end;

  function ObjectFieldsToVariant(const AObject: TObject; const Fieldinfo:RawUTF8; out TD:variant):boolean;
  function ProductFieldsToVariant(const Product: TProduct; const Fieldinfo:RawUTF8; out TD:variant):boolean;

implementation

uses
  mormot.core.variants,
  mormot.core.text,
  mormot.core.rtti;

function ObjectFieldsToVariant(const AObject: TObject; const Fieldinfo:RawUTF8; out TD:variant):boolean;
var
  rA           : TRttiCustom;
  pa           : PRttiCustomProp;
  TD2          : variant;
  count        : integer;
  SkipField    : boolean;
begin
  result:=false;

  TDocVariantData(TD).Clear;

  rA := Rtti.RegisterClass(PClass(AObject)^);
  if Assigned(rA) then
  begin
    if Fieldinfo='*' then
    begin
      // All fields
      // However, the fields are filtered: not the specific collections
      pa := pointer(rA.Props.List);
      count:=rA.Props.Count;
      repeat
        begin
          if (pa^.Value<>nil) and (pa^.Value.Info<>nil) then
          begin
            SkipField:=false;
            // Skip certain collections
            if (pa^.Value.Info^.Kind=rkClass) then
            begin
              if (pa^.Value.ValueRtlClass=vcCollection) then
              begin
                // Skip the LiveData collection
                //if NOT SkipField then SkipField:=(pa^.Value.Info^.RttiClass^.RttiClass=TNewLiveDataCollection);
                // Skip the ThresholdData collection
                //if NOT SkipField then SkipField:=(pa^.Value.Info^.RttiClass^.RttiClass=TThresholdDataCollection);
              end;
            end;
            if NOT SkipField then
            begin
              // Get fielddata as variant
              pa^.GetValueVariant(AObject,TVarData(TD2), @JSON_[mDefault]);
              // Add requested fieldname and fielddata
              TDocVariantData(TD).AddValue(pa^.Name,TD2);
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
        // Get fielddata as variant
        pa^.GetValueVariant(AObject,TVarData(TD2), @JSON_[mDefault]);
        // Add requested fieldname and fielddata
        TDocVariantData(TD).AddValue(FieldInfo,TD2);
      end;
    end;

    if (TDocVariantData(TD).Count>0) then result:=true;
  end;
end;

function ProductFieldsToVariant(const Product: TProduct; const Fieldinfo:RawUTF8; out TD:variant):boolean;
var
  rA           : TRttiCustom;
  pa           : PRttiCustomProp;
  TD2          : variant;
  count        : integer;
  SkipField    : boolean;
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
            SkipField:=false;
            // Skip Blobs
            if NOT SkipField then SkipField:=(pa^.Value.Info^.IsRawBlob);
            if NOT SkipField then SkipField:=(pa^.Value.Info=TypeInfo(TBlobber));
            // Skip certain collections
            if (pa^.Value.Info^.Kind=rkClass) then
            begin
              if (pa^.Value.ValueRtlClass=vcCollection) then
              begin
                // Skip the document collection
                if NOT SkipField then SkipField:=(pa^.Value.Info^.RttiClass^.RttiClass=TProductDocumentCollection);
              end;
            end;
            if NOT SkipField then
            begin
              // Get fielddata as variant
              pa^.GetValueVariant(Product,TVarData(TD2), @JSON_[mDefault]);
              // Add requested fieldname and fielddata
              TDocVariantData(TD).AddValue(pa^.Name,TD2);
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
        // Get fielddata as variant
        pa^.GetValueVariant(Product,TVarData(TD2), @JSON_[mDefault]);
        // Add requested fieldname and fielddata
        TDocVariantData(TD).AddValue(FieldInfo,TD2);
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
