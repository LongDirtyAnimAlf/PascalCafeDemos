unit productstorageinterface;

interface

{$I mormot.defines.inc}

uses
  mormot.core.base,
  mormot.core.interfaces,
  servicesshared,
  rundatastorageinterface,
  productdom;

type
  IProductStorage = interface(IRunDataStorage)
    ['{F953DFBC-F69C-4E4C-967B-CDD40EA9DF5F}']
    function RetrieveProduct(var AProduct: TProduct): TStorageResult;
    function RetrieveProductImage(const aCode:RawUTF8; out AImage: RawBlob): TStorageResult;
    function RetrieveProducts(out AProducts: TProductCollection): TStorageResult;
    function SaveNewProduct(const AProduct: TProduct): TStorageResult;
    function UpdateProduct(const AProduct: TProduct; const Fieldinfo:RawUTF8):TStorageResult;
    function DeleteProduct(const aProductCode:RawUTF8): TStorageResult;
    function ChangedProduct(const aProductCode:RawUTF8; const aVersion:Int64; out Changed:boolean): TStorageResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IProductStorage)
    ]);

end.
