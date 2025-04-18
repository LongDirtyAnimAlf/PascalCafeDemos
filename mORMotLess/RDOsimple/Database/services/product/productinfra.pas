unit productinfra;

interface

{$I mormot.defines.inc}

uses
  SysUtils,
  mormot.core.base,
  mormot.core.os,
  mormot.core.rtti,
  mormot.orm.base,
  mormot.orm.core,
  servicesshared,
  productdom;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type
  TOrmProduct = class(TOrm)
  protected
    fProductCode       : RawUTF8;
    fBrand             : RawUTF8;
    fModel             : RawUTF8;
    fDocuments         : TProductDocumentCollection;
    fThumb             : RawBlob;
    fVersion           : TRecordVersion;
  public
    procedure InternalCreate;override;
    destructor Destroy; override;
  published
    property ProductCode      : RawUTF8 read fProductCode write fProductCode; // stored AS_UNIQUE;
    property Brand            : RawUTF8 read fBrand write fBrand;
    property Model            : RawUTF8 read fModel write fModel;
    property Documents        : TProductDocumentCollection read fDocuments write fDocuments;
    property Thumb            : RawBlob read fThumb write fThumb;
    property Version          : TRecordVersion read fVersion write fVersion;
  end;

function CreateProductModel: TOrmModel;

implementation

function CreateProductModel: TOrmModel;
begin
  result := TOrmModel.Create([TOrmProduct]);
end;

procedure TOrmProduct.InternalCreate;
begin
  inherited InternalCreate;
  fDocuments:=TProductDocumentCollection.Create(nil);
end;

destructor TOrmProduct.Destroy;
begin
  fDocuments.Free;
  inherited Destroy;
end;

initialization
  Rtti.RegisterCollection(TProductDocumentCollection,TProductDocument);
  Rtti.RegisterCollection(TProductCollection,TProduct);

end.
