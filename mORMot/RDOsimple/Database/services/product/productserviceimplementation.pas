unit productserviceimplementation;

interface

{$I mormot.defines.inc}

uses
  mormot.core.base,
  mormot.soa.server,
  productdom,
  servicesshared,
  productserviceinterface,
  productstorageinterface;

type
  TProductService = class(TInjectableObjectRest, IProductService)
  private
    fStorage: IProductStorage;
  public
    constructor Create(AStorage: IInvokable); reintroduce;

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

implementation

uses
  mormot.core.rtti,
  mormot.core.buffers,
  mormot.core.text,
  mormot.core.variants,
  mormot.core.json;

{
******************************** TProductService ********************************
}
constructor TProductService.Create(AStorage: IInvokable);
begin
  inherited Create;
  fStorage := AStorage AS IProductStorage;
end;

function TProductService.AddProduct(const AProduct: TProduct): TServiceResult;
begin
  if (AProduct.ProductCode = '') then
  begin
    Result := seMissingField;
    exit;
  end;
  if fStorage.SaveNewProduct(AProduct) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;

function TProductService.GetProduct(var AProduct: TProduct): TServiceResult;
begin
  if fStorage.RetrieveProduct(AProduct) = stSuccess then
    Result := seSuccess
  else
    Result := seNotFound;
end;

function TProductService.GetProductByCode(const aCode:RawUTF8; out AProduct: TProduct): TServiceResult;
begin
  AProduct.ProductCode:=aCode;
  if fStorage.RetrieveProduct(AProduct) = stSuccess then
    Result := seSuccess
  else
    Result := seNotFound;
end;

function TProductService.GetProductImageByCode(const aCode:RawUTF8; out AImage: RawBlob): TServiceResult;
begin
  if fStorage.RetrieveProductImage(aCode,AImage) = stSuccess then
    Result := seSuccess
  else
    Result := seNotFound;
end;

function TProductService.GetAllProducts(out AProducts: TProductCollection): TServiceResult;
begin
  if fStorage.RetrieveProducts(AProducts) = stSuccess then
    Result := seSuccess
  else
    Result := seNotFound;
end;

function TProductService.UpdateProductCode(const aProductCode:RawUTF8; const NewCode:RawUTF8):TServiceResult;
begin
  if fStorage.UpdateProductCode(aProductCode, NewCode) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;

function TProductService.UpdateProduct(const aProductCode:RawUTF8; const FieldData:Variant): TServiceResult;
var
  rA           : TRttiCustom;
  pa           : PRttiCustomProp;
  Valid        : boolean;
  LocalProduct : TProduct;
  FieldNames   : RawUTF8;
  indexer      : integer;
  FieldContent : RawUTF8;
  BlobField    : boolean;
begin
  Result := sePersistenceError;

  if (TDocVariantData(FieldData).Count=0) then exit;

  // Create a local product to store the variant data
  LocalProduct := TProduct.Create(nil);
  try
    LocalProduct.ProductCode:=aProductCode;

    rA := Rtti.RegisterClass(PClass(LocalProduct)^);

    // Convert/store then variant data into the product
    Valid := DocVariantToObject(_Safe(FieldData)^,LocalProduct, rA);

    if Valid then
    //if false then
    begin
      // The blob data is transmitted as encoded base64 [possibly with some mORMot magic pre-amble]
      // If a blobber is included, decode this data and set its value !!
      if Assigned(rA) then
      begin
        with _Safe(FieldData)^ do
        begin
          for indexer := 0 to Count-1 do
          begin
            //FieldContent:=U[Names[indexer]];
            //if IsBase64(FieldContent) then
            begin
              pa := rA.Props.Find(Names[indexer]);
              if Assigned(pa) then
              begin
                BlobField := false;
                // Detect blobber fields
                if NOT BlobField then BlobField:=(pa^.Value.Info^.IsRawBlob);
                if NOT BlobField then BlobField:=(pa^.Value.Info=TypeInfo(TBlobber));
                //if NOT BlobField then BlobField:=(pa^.Prop^.TypeInfo=TypeInfo(TBlobber));
                if BlobField then
                begin
                  FieldContent:=U[Names[indexer]];
                  //pa^.SetValueText(LocalProduct,BlobToRawBlob(FieldContent)); // in case of mormot magic
                  pa^.SetValueText(LocalProduct,Base64ToBin(FieldContent)); // normal base64
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    if Valid then
    begin
      // Finally, save the data into the storage !
      FieldNames:=RawUtf8ArrayToCsv(TDocVariantData(FieldData).GetNames);
      if fStorage.UpdateProduct(LocalProduct,FieldNames) = stSuccess then
        Result := seSuccess
      else
        Result := sePersistenceError;
    end;

  finally
    LocalProduct.Free;
  end;
end;

function TProductService.DeleteProduct(const aProductCode:RawUTF8): TServiceResult;
begin
  if fStorage.DeleteProduct(aProductCode) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;

function TProductService.ChangedProduct(const aProductCode:RawUTF8; const aVersion:Int64; out Changed:boolean): TServiceResult;
begin
  if fStorage.ChangedProduct(aProductCode, aVersion, Changed) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;



end.
