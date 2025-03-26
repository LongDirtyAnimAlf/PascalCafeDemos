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
  productdom,
  rundatainfra;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type
  TOrmProduct = class(TOrm)
  protected
    fProductCode       : RawUTF8;
    fBrand             : RawUTF8;
    fModel             : RawUTF8;
    fProjectNumber     : RawUTF8;
    fEAN               : RawUTF8;
    fArticlenumber     : RawUTF8;
    fMadeIn            : RawUTF8;
    fBaseType          : TBaseType;
    fChemistry         : TChemistryType;
    fVoltage           : double;
    fCapacity          : integer;
    fIECCode           : TIECCode;
    fProductionDate    : TDateTime;
    fUltimateUseDate   : TDateTime;
    fParticularities   : RawUTF8;
    fBatteryDetail     : TBatteryDetails;
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
    property ProjectNumber    : RawUTF8 read fProjectNumber write fProjectNumber;
    property EAN              : RawUTF8 read fEAN write fEAN; // stored AS_UNIQUE;
    property Articlenumber    : RawUTF8 read fArticlenumber write fArticlenumber;
    property MadeIn           : RawUTF8 read fMadeIn write fMadeIn;
    property BaseType         : TBaseType read fBaseType write fBaseType;
    property Chemistry        : TChemistryType read fChemistry write fChemistry;
    property Voltage          : double read fVoltage write fVoltage;
    property Capacity         : integer read fCapacity write fCapacity;
    property IECCode          : TIECCode read fIECCode write fIECCode;
    property ProductionDate   : TDateTime read fProductionDate write fProductionDate;
    property UltimateUseDate  : TDateTime read fUltimateUseDate write fUltimateUseDate;
    property Particularities  : RawUTF8 read fParticularities write fParticularities;
    property BatteryDetail    : TBatteryDetails read fBatteryDetail write fBatteryDetail;
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
  fBatteryDetail:=TBatteryDetails.Create;
  fDocuments:=TProductDocumentCollection.Create(nil);
end;

destructor TOrmProduct.Destroy;
begin
  fDocuments.Free;
  fBatteryDetail.Free;
  inherited Destroy;
end;

initialization
  Rtti.RegisterCollection(TStageCollection,TStageData);
  Rtti.RegisterCollection(TTestCollection,TTestData);
  Rtti.RegisterCollection(TProductDocumentCollection,TProductDocument);
  Rtti.RegisterCollection(TProductCollection,TProduct);

end.
