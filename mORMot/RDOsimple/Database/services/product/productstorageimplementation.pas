unit productstorageimplementation;

interface

{$I mormot.defines.inc}

uses
  SysUtils,
  mormot.core.base,
  mormot.core.os,
  mormot.core.rtti, // for TRttiMap
  mormot.orm.base,
  mormot.orm.core,
  mormot.orm.rest, // for TRestOrm

  mormot.rest.sqlite3, // for TRestServerDB
  mormot.db.raw.sqlite3.static,// for TRestServerDB

  servicesshared,

  productdom,
  productinfra,
  productstorageinterface;

type
  TProductStorage = class(TInterfacedObject, IProductStorage)
  strict private
    fRestServerDB : TRestServerDB;
    fMap          : TRttiMap;
    fRestOrm      : TRestOrm;
  private
    procedure CopyDTOtoORM(const AProduct: TProduct; var OrmProduct: TOrmProduct);
    procedure CopyORMtoDTO(const OrmProduct: TOrmProduct; var AProduct: TProduct);
    function GetProductIDVersionOnly(const AProductCode: string): TOrmProduct;
  public
    constructor Create(ARestOrm:TRestOrm; aDBFile:string='');
    destructor Destroy;override;
    function RetrieveProduct(var AProduct: TProduct): TStorageResult;
    function RetrieveProductImage(const aCode:RawUTF8; out AImage: RawBlob): TStorageResult;
    function RetrieveProducts(out AProducts: TProductCollection): TStorageResult;
    function SaveNewProduct(const AProduct: TProduct): TStorageResult;
    function UpdateProduct(const AProduct: TProduct; const Fieldinfo:RawUTF8):TStorageResult;
    function DeleteProduct(const aProductCode:RawUTF8): TStorageResult;
    function ChangedProduct(const aProductCode:RawUTF8; const aVersion:Int64; out Changed:boolean): TStorageResult;
  end;

implementation

uses
  mormot.db.core,
  mormot.core.json,
  mormot.core.buffers,
  mormot.core.text;

const
  MAINFIELD = 'ProductCode';

{
****************************** TProductRepository *******************************
}

constructor TProductStorage.Create(ARestOrm:TRestOrm; aDBFile:string);
begin
  if ARestOrm=nil then
  begin
    if (Length(aDBFile)=0) then raise SysUtils.Exception.Create('No database filename defined !');

    // Create the server connected to the SQLite database for Product
    fRestServerDB := TRestServerDB.Create(TOrmModel.Create([TOrmProduct]), aDBFile);
    fRestServerDB.Model.Owner:=fRestServerDB;
    fRestServerDB.Server.CreateMissingTables;
    fRestServerDB.CreateSqlMultiIndex(TOrmProduct,[MAINFIELD],true);
    fRestServerDB.CreateSqlMultiIndex(TOrmProduct,['Brand','Model'],false);
    fRestOrm:=fRestServerDB.OrmInstance;
  end
  else
  begin
    fRestOrm:=ARestOrm;
    fRestServerDB:=nil;
  end;

  inherited Create;

  fMap.Init(TOrmProduct, TProduct).AutoMap;
end;

destructor TProductStorage.Destroy;
begin
  if Assigned(fRestServerDB) then fRestServerDB.Destroy;
  fRestServerDB:=nil;
  inherited Destroy;
end;

procedure TProductStorage.CopyDTOtoORM(const AProduct: TProduct; var OrmProduct: TOrmProduct);
begin
  fMap.ToA(OrmProduct,AProduct);
  if (AProduct.Documents.Count>0) then CopyObject(AProduct.Documents,OrmProduct.Documents);
end;

procedure TProductStorage.CopyORMtoDTO(const OrmProduct: TOrmProduct; var AProduct: TProduct);
begin
  fMap.ToB(OrmProduct,AProduct);
  if (OrmProduct.Documents.Count>0) then CopyObject(OrmProduct.Documents,AProduct.Documents);
end;

function TProductStorage.GetProductIDVersionOnly(const AProductCode: string): TOrmProduct;
var
  aID,aVersion : TID;
  res          : array[0..1] of RawUtf8;
  where        : RawUtf8;
begin
  // Get the ORM-ID and ORM-Version of the Battery from the server
  where := FormatSql(MAINFIELD+' = ?', [], [AProductCode]);
  if FRestOrm.MultiFieldValue(TOrmProduct,[ROWID_TXT,TOrmProduct.OrmProps.RecordVersionField.Name],res,where) then
  begin
    SetInt64(pointer(res[0]), {%H-}aID);
    SetInt64(pointer(res[1]), {%H-}aVersion);
    result:=TOrmProduct.CreateWithID(aID);
    result.Version:=aVersion;
  end
  else
    result := TOrmProduct.Create;
end;

function TProductStorage.RetrieveProduct(var AProduct: TProduct): TStorageResult;
var
  OrmProduct:TOrmProduct;
begin
  Result := stNotFound;
  OrmProduct := TOrmProduct.Create;
  //OrmProduct := TOrmProduct.Create(FRestOrm,MAINFIELD+' = ?',[AProduct.Code]);
  // We need this statement (and not the above), because the version field must also be retrieved !!
  fRestOrm.Retrieve(FormatSql(MAINFIELD+' = ?', [], [AProduct.Code]),OrmProduct,'*');
  try
    if OrmProduct.IDValue = 0 then exit;
    CopyORMtoDTO(OrmProduct,AProduct);
    Result := stSuccess;
  finally
    OrmProduct.Free;
  end;
end;

function TProductStorage.RetrieveProductImage(const aCode:RawUTF8; out AImage: RawBlob): TStorageResult;
var
  JSON : RawUTF8;
begin
  Result := stNotFound;
  JSON:=FRestOrm.OneFieldValue(TOrmProduct,'Thumb',MAINFIELD+' = ?',[aCode]);
  if Length(JSON)>0 then
  begin
    AImage := BlobToRawBlob(pointer(JSON));
    Result := stSuccess;
  end;
end;

function TProductStorage.RetrieveProducts(out AProducts: TProductCollection): TStorageResult;
var
  OrmProduct:TOrmProduct;
  Product:TProduct;
begin
  Result := stNotFound;
  OrmProduct := TOrmProduct.CreateAndFillPrepare(fRestOrm,'Order by '+MAINFIELD,'*');
  try
    if OrmProduct.FillTable.RowCount = 0 then exit;
    while OrmProduct.FillOne do
    begin
      Product:=(AProducts.Add as TProduct);
      CopyORMtoDTO(OrmProduct,Product);
    end;
    Result := stSuccess;
  finally
    OrmProduct.Free;
  end;

end;

function TProductStorage.SaveNewProduct(const AProduct: TProduct): TStorageResult;
var
  OrmProduct:TOrmProduct;
begin
  Result := stWriteFailure;
  OrmProduct := GetProductIDVersionOnly(AProduct.Code);
  try
    CopyDTOtoORM(AProduct,OrmProduct);
    if (fRestOrm.AddOrUpdate(OrmProduct)>0) then
      Result := stSuccess;

    if (Result=stSuccess) AND (Length(AProduct.Thumb)>0) then
    begin
      fRestOrm.UpdateBlobFields(OrmProduct);
    end;

  finally
    OrmProduct.Free;
  end;
end;

function TProductStorage.UpdateProduct(const AProduct: TProduct; const Fieldinfo:RawUTF8):TStorageResult;
var
  OrmProduct   : TOrmProduct;
begin
  Result := stWriteFailure;
  OrmProduct := GetProductIDVersionOnly(AProduct.Code);
  try
    if (OrmProduct.IDValue=0) then exit;
    if Fieldinfo = '*' then
    begin
      // Update all fields
      CopyDTOtoORM(AProduct,OrmProduct);
      if FRestOrm.AddOrUpdate(OrmProduct) > 0 then
        Result := stSuccess;
    end
    else
    begin
      //if OrmProduct.OrmProps.IsFieldName(pointer(Fieldinfo)) then
      begin
        // Update some fields
        fMap.ToA(OrmProduct,AProduct);
        if FRestOrm.Update
        (OrmProduct,Fieldinfo) then
          Result := stSuccess;
      end;
    end;
  finally
    OrmProduct.Free;
  end;
end;

function TProductStorage.DeleteProduct(const aProductCode:RawUTF8): TStorageResult;
var
  OrmProduct:TOrmProduct;
begin
  Result := stNotFound;
  OrmProduct := GetProductIDVersionOnly(aProductCode);
  try
    if (OrmProduct.IDValue>0) then
    begin
      if (fRestOrm.Delete(TOrmProduct,OrmProduct.IDValue)) then
        Result := stSuccess;
    end;
  finally
    OrmProduct.Free;
  end;
end;

function TProductStorage.ChangedProduct(const aProductCode:RawUTF8; const aVersion:Int64; out Changed:boolean): TStorageResult;
var
  OrmProduct:TOrmProduct;
begin
  Result := stNotFound;
  OrmProduct := GetProductIDVersionOnly(aProductCode);
  try
    if (OrmProduct.IDValue>0) then
    begin
      Changed:=(aVersion<>OrmProduct.Version);
      Result := stSuccess;
    end;
  finally
    OrmProduct.Free;
  end;
end;


end.
