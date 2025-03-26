unit productdom;

interface

uses
  Classes,
  servicesshared,
  rundatadom,
  documentdom;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type

  TProduct = class;

  { TTestData }
  TTestData = class(TCollectionItem)
  private
    fTestID              : RawUTF8;
    fInfo                : RawUTF8;
    fDate                : TDateTime;
    fStageMode           : TStageMode;
    fSetValue            : TSetValue;
    fThresholdMode       : TThresholdModes;
    fThresholdValue      : RawUTF8;
    fMultiCycle          : boolean;
    fRunDatas            : TRunDataCollection;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Init;
    function GetTestName:string;
    function GetOwner:TProduct;reintroduce;
  published
    property TestID             : RawUTF8 read fTestID write fTestID;
    property Info               : RawUTF8 read fInfo write fInfo;
    property Date               : TDateTime read fDate write fDate;
    property StageMode          : TStageMode read fStageMode write fStageMode;
    property SetValue           : TSetValue read fSetValue write fSetValue;
    property ThresholdMode      : TThresholdModes read fThresholdMode write fThresholdMode;
    property ThresholdValue     : RawUTF8 read fThresholdValue write fThresholdValue;
    property MultiCycle         : boolean read fMultiCycle write fMultiCycle;
    property RunDatas           : TRunDataCollection read fRunDatas write fRunDatas;
  end;

  { TTestCollection }
  TTestCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TTestData;
  public
    constructor Create(AOwner: TPersistent);overload;
    property Item[Index: integer]: TTestData read GetItem;
    function Add: TTestData;
    function AddOrUpdate(AM:TStageMode;AV:TSetValue; out TD:TTestData): boolean;
    procedure InitAll;
  end;

  TThresholdSetting = record
    Enabled   : boolean;
    Value     : integer;
    EndOfTest : boolean;
  end;

  TThresholdSettings = array[TThresholdModes] of TThresholdSetting;

  { TStageData }
  TStageData = class(TCollectionItem)
  private
    fSType                         : TStageMode;
    fSValue                        : TSetValue;
    {$ifdef COINCELL}
    fSValueSpecial                 : TSetValue;
    {$else}
    fSValueText                    : RawUTF8;
    {$endif}
    fPause                         : TSetValue;
  public
    ThresholdsSetting              : TThresholdSettings;
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Init;
    function GetOwner:TProduct;reintroduce;
  published
    property SType                 : TStageMode read fSType write fSType;
    property SValue                : TSetValue read fSValue write fSValue;
    {$ifdef COINCELL}
    property SValueSpecial         : TSetValue read fSValueSpecial write fSValueSpecial;
    {$else}
    property SValueText            : RawUTF8 read fSValueText write fSValueText;
    {$endif}
    property Pause                 : TSetValue read fPause write fPause;
  end;

  { TStageCollection }
  TStageCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TStageData;
  private
    property Item[Index: integer]: TStageData read GetItem;
  public
    constructor Create(AOwner: TPersistent);overload;
    function Add: TStageData;
    procedure InitAll;
  end;

  TProductDocument = class(TCollectionItem)
  private
    function GetHash:ansistring;
    procedure SetPath(aPath:RawUTF8);
  protected
    fName              : RawUTF8;
    fPath              : RawUTF8;
    fHash              : RawUTF8;
    fTarget            : TDocumentTarget;
    fFileThumb         : TBlobber;
  public
    function GetOwner:TProduct;reintroduce;
    property FileThumb : TBlobber read fFileThumb write fFileThumb;
  published
    property Name      : RawUTF8 read fName;// write fName;
    property Path      : RawUTF8 read fPath write SetPath;
    property Hash      : RawUTF8 read fHash;// write fHash;
    property Target    : TDocumentTarget read fTarget write fTarget;
  end;

  { TProductDocumentCollection }
  TProductDocumentCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TProductDocument;
  private
    property Item[Index: integer]: TProductDocument read GetItem;
  public
    constructor Create(AOwner: TPersistent);overload;
    function Add: TProductDocument;
    function AddOrUpdate(const Target: TDocumentTarget; const AddIfNotFound:boolean; out aDocument:TProductDocument): boolean;
  end;

  TBatteryWarnings = class(TPersistent)
  private
    FDo_not_charge: boolean;
    FDo_not_destroy: boolean;
    FRemove_when_empty: boolean;
    FDo_not_throw_in_fire: boolean;
    FKeep_way_from_kids: boolean;
    FDo_not_mix_types: boolean;
    FDo_not_shortcircuit: boolean;
    FDo_not_swallow: boolean;
    FObserve_polarity: boolean;
  published
    property Do_not_charge                    : boolean read FDo_not_charge write FDo_not_charge;
    property Do_not_destroy                   : boolean read FDo_not_destroy write FDo_not_destroy;
    property Remove_when_empty                : boolean read FRemove_when_empty write FRemove_when_empty;
    property Do_not_throw_in_fire             : boolean read FDo_not_throw_in_fire write FDo_not_throw_in_fire;
    property Keep_way_from_kids               : boolean read FKeep_way_from_kids write FKeep_way_from_kids;
    property Do_not_mix_types                 : boolean read FDo_not_mix_types write FDo_not_mix_types;
    property Do_not_shortcircuit              : boolean read FDo_not_shortcircuit write FDo_not_shortcircuit;
    property Do_not_swallow                   : boolean read FDo_not_swallow write FDo_not_swallow;
    property Observe_polarity                 : boolean read FObserve_polarity write FObserve_polarity;
  end;

  TBatteryDisposal = class(TPersistent)
  private
    FRecycling_on_package         : boolean;
    FRecycling_on_battery         : boolean;
    FBEBAT_on_package             : boolean;
    FBEBAT_on_battery             : boolean;
    FGrunePunkte_on_package       : boolean;
    FGrunePunkte_on_battery       : boolean;
    FWasteBinEN50419_on_package   : boolean;
    FWasteBinEN50419_on_battery   : boolean;
    FNo_mercury                   : boolean;
    FNo_cadmium                   : boolean;
    FNo_heavy_metals              : RawUTF8;
    FDisposal_advice_on_package   : RawUTF8;
    FDisposal_advice_on_battery   : RawUTF8;
  published
    property Recycling_on_package             : boolean read FRecycling_on_package write FRecycling_on_package;
    property Recycling_on_battery             : boolean read FRecycling_on_battery write FRecycling_on_battery;
    property BEBAT_on_package                 : boolean read FBEBAT_on_package write FBEBAT_on_package;
    property BEBAT_on_battery                 : boolean read FBEBAT_on_battery write FBEBAT_on_battery;
    property GrunePunkte_on_package           : boolean read FGrunePunkte_on_package write FGrunePunkte_on_package;
    property GrunePunkte_on_battery           : boolean read FGrunePunkte_on_battery write FGrunePunkte_on_battery;
    property WasteBinEN50419_on_package       : boolean read FWasteBinEN50419_on_package write FWasteBinEN50419_on_package;
    property WasteBinEN50419_on_battery       : boolean read FWasteBinEN50419_on_battery write FWasteBinEN50419_on_battery;
    property No_mercury                       : boolean read FNo_mercury write FNo_mercury;
    property No_cadmium                       : boolean read FNo_cadmium write FNo_cadmium;
    property No_heavy_metals                  : RawUTF8 read FNo_heavy_metals write FNo_heavy_metals;
    property Disposal_advice_on_package       : RawUTF8 read FDisposal_advice_on_package write FDisposal_advice_on_package;
    property Disposal_advice_on_battery       : RawUTF8 read FDisposal_advice_on_battery write FDisposal_advice_on_battery;
  end;

  TBatteryRechargeable = class(TPersistent)
  private
    FChargeAdvice:RawUTF8;
    FReadyToUse:RawUTF8;
    FSelfDischarge:RawUTF8;
  published
    property ChargeAdvice:RawUTF8 read FChargeAdvice write FChargeAdvice;
    property ReadyToUse:RawUTF8 read FReadyToUse write FReadyToUse;
    property SelfDischarge:RawUTF8 read FSelfDischarge write FSelfDischarge;
  end;

  TBaseType = (btUnknown,btDisposable, btRechargable);
  TChemistryType = (ctUnknown,ctAlkaline, ctZincCarbon, ctZincAir, ctNiCd, ctNiMH, ctLead, ctLiMnO2, ctLiFeS2, ctLiPo, ctLiFePO4);
  TIECCode = (iecUnknown,iecR20,iecR14,iecR6,iecR03,iecLR20,iecLR14,iecLR6,iecLR03,iecHR20,iecHR14,iecHR6,iecHR03,iec6LR61,iec6HR61,iec6F22,iecCR2016,iecCR2032,iecPR44,iecPR41,iecPR48,iecPR70);

  TBatteryDetails = class(TPersistent)
  private
    fBaseType             : TBaseType;
    fChemistry            : TChemistryType;
    fVoltage              : double;
    fCapacity             : integer;
    fIECCode              : TIECCode;
    fProductionDate       : TDateTime;
    fUltimateUseDate      : TDateTime;

    FWarnings             : TBatteryWarnings;
    FDisposal             : TBatteryDisposal;
    FRechargeable         : TBatteryRechargeable;
    FPerformanceClaims    : RawUTF8;
    FAmount_per_package   : integer;
    FAmount_of_packs      : integer;
    FPackage_remarks      : RawUTF8;
    function GetTotal:integer;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    property Total_amount_of_batteries:integer read GetTotal;
  published
    property BaseType            : TBaseType read fBaseType write fBaseType;
    property Chemistry           : TChemistryType read fChemistry write fChemistry;
    property Voltage             : double read fVoltage write fVoltage;
    property Capacity            : integer read fCapacity write fCapacity;
    property IECCode             : TIECCode read fIECCode write fIECCode;
    property ProductionDate      : TDateTime read fProductionDate write fProductionDate;
    property UltimateUseDate     : TDateTime read fUltimateUseDate write fUltimateUseDate;
    property Warnings            : TBatteryWarnings read FWarnings;
    property Disposal            : TBatteryDisposal read FDisposal;
    property Rechargeable        : TBatteryRechargeable read FRechargeable;
    property PerformanceClaims   : RawUTF8 read FPerformanceClaims write FPerformanceClaims;
    property Amount_per_package  : integer read FAmount_per_package write FAmount_per_package;
    property Amount_of_packs     : integer read FAmount_of_packs write FAmount_of_packs;
    property Package_remarks     : RawUTF8 read FPackage_remarks write FPackage_remarks;
  end;

  TProduct = class(TCollectionItem)
  strict private
    fB_code            : RawUTF8;
    fB_name            : RawUTF8;
    fB_type            : RawUTF8;
    fStatedCapacity    : integer;
    fB_id              : RawUTF8;
    fTest_id           : RawUTF8;
    fStages            : TStageCollection;
    fTesDatas          : TTestCollection;

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
    fThumb             : TBlobber;
    fVersion           : Int64;
    function GetTypeNumber:integer;
  public
    OnTime :TSetValue;
    OffTime :TSetValue;
    Cycli :TSetValue;
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Init;
    function GetSampleData(TestIndex:integer;Sample:integer):TRunData;overload;
    function GetMeasurementSampleData(SampleIndex:integer):TRunData;overload;
    function GetStageData(StageIndex:integer):TStageData;
    function GetMeasurementTestData:TTestData;
    property TypeNumber        : integer read GetTypeNumber;
    property Code              : RawUTF8 read fB_code;
  published
    property B_code            : RawUTF8 read fB_code write fB_code;
    property B_name            : RawUTF8 read fB_name write fB_name;
    property B_type            : RawUTF8 read fB_type write fB_type;
    property StatedCapacity    : integer read fStatedCapacity write fStatedCapacity;
    property B_id              : RawUTF8 read fB_id write fB_id;
    property Test_id           : RawUTF8 read fTest_id write fTest_id;
    property Stages            : TStageCollection read fStages write fStages;
    property TestDatas         : TTestCollection read fTesDatas write fTesDatas;

    property ProjectNumber     : RawUTF8 read fProjectNumber write fProjectNumber;
    property EAN               : RawUTF8 read fEAN write fEAN; // stored AS_UNIQUE;
    property Articlenumber     : RawUTF8 read fArticlenumber write fArticlenumber;
    property MadeIn            : RawUTF8 read fMadeIn write fMadeIn;
    property BaseType          : TBaseType read fBaseType write fBaseType;
    property Chemistry         : TChemistryType read fChemistry write fChemistry;
    property Voltage           : double read fVoltage write fVoltage;
    property Capacity          : integer read fCapacity write fCapacity;
    property IECCode           : TIECCode read fIECCode write fIECCode;
    property ProductionDate    : TDateTime read fProductionDate write fProductionDate;
    property UltimateUseDate   : TDateTime read fUltimateUseDate write fUltimateUseDate;
    property Particularities   : RawUTF8 read fParticularities write fParticularities;
    property BatteryDetail     : TBatteryDetails read fBatteryDetail write fBatteryDetail;
    property Documents         : TProductDocumentCollection read fDocuments write fDocuments;
    property Thumb             : TBlobber read fThumb write fThumb;
    property Version           : Int64 read fVersion write fVersion;
  end;

  { TProductCollection }
  TProductCollection = class(TCollection)
  strict private
    function GetItem(Index: integer): TProduct;
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  public
    Compare: TCollectionSortCompare;
    constructor Create;overload;
    property Item[Index: integer]: TProduct read GetItem;
    function GetBatteryData(BatteryIndex:integer):TProduct;
    function GetStageData(BatteryIndex,StageIndex:integer):TStageData;
    function GetMeasurementSampleData(BatteryIndex,SampleIndex:integer):TRunData;
    function Add: TProduct;
    function AddOrUpdate(const ABC:RawUTF8; const AddIfNotFound:boolean; out aBattery:TProduct): boolean;
  end;

  function CompareProductCode(const a, b: TCollectionItem): Integer;
  function CompareProductName(const a, b: TCollectionItem): Integer;

implementation

uses
  SysUtils,
  fpsha256;

function CompareProductCode(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TProduct)) or (not (b is TProduct)) then
    raise Exception.Create('Invalid TProduct reference.');
  result:=SysUtils.StrComp(PChar(pointer(TProduct(a).B_code)),PChar(pointer(TProduct(b).B_code)));
 end;

function CompareProductName(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TProduct)) or (not (b is TProduct)) then
    raise Exception.Create('Invalid TProduct reference.');
  result:=SysUtils.StrComp(PChar(pointer(TProduct(a).B_name)),PChar(pointer(TProduct(b).B_name)));
  if result=0 then
    result:=SysUtils.StrComp(PChar(pointer(TProduct(a).B_type)),PChar(pointer(TProduct(b).B_type)));
end;

{ TTestData }

constructor TTestData.Create(ACollection: TCollection);
begin
  fRunDatas := TRunDataCollection.Create(Self);
  inherited Create (ACollection);
end;

destructor TTestData.Destroy;
begin
  fRunDatas.Destroy;
  inherited Destroy;
end;

procedure TTestData.Init;
begin
  TestID             :='';
  Info               :='';
  Date               :=0;;
  StageMode          :=TStageMode.smDisabled;
  SetValue           :=0;
  ThresholdMode      :=TThresholdModes.tmNONE;
  ThresholdValue     :='';
  MultiCycle         :=false;
  RunDatas.InitAll;
end;

function TTestData.GetTestName:string;
begin
  case fStageMode of
    TStageMode.smCurrent: Result:='Current discharge at '+InttoStr(fSetValue);
  end;
end;

function TTestData.GetOwner:TProduct;
begin
  result:=nil;
  if Assigned(Collection) then
    result:=TProduct(Collection.Owner);
end;

{ TTestCollection }

constructor TTestCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner,TTestData);
end;

function TTestCollection.GetItem(Index: integer): TTestData;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TTestData;
end;

function TTestCollection.Add: TTestData;
begin
  Result := inherited Add as TTestData;
end;

function TTestCollection.AddOrUpdate(AM:TStageMode;AV:TSetValue; out TD:TTestData): boolean;
var
  TestRunner:TCollectionItem;
begin
  result:=true;
  TD:=nil;
  for TestRunner in Self do
  begin
    if (TTestData(TestRunner).StageMode=AM) AND (TTestData(TestRunner).SetValue=AV) then
    begin
      TD:=TTestData(TestRunner);
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(TD) then
  begin
    TD := Add;
    TD.StageMode:=AM;
    TD.SetValue:=AV;
  end;
end;

procedure TTestCollection.InitAll;
var
  i:integer;
begin
  for i:=0 to Pred(Count) do Item[i].Init;
end;

{ TStageData }

constructor TStageData.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
end;

destructor TStageData.Destroy;
begin
  inherited Destroy;
end;

procedure TStageData.Init;
var
  Mode:TThresholdModes;
begin
  // Add some default settings

  SType         := TStageMode.smDisabled;
  SValue        := 0;
  {$ifdef COINCELL}
  SValueSpecial := 0;
  {$else}
  SValueText    := '';
  {$endif}
  Pause         := 0;

  for Mode in TThresholdModes do
  begin
    //ThresholdsSetting[Mode]:=Default(TThresholdSetting);
    ThresholdsSetting[Mode].Enabled   := false;
    ThresholdsSetting[Mode].EndOfTest := false;
    ThresholdsSetting[Mode].Value     := 0;
  end;
end;

function TStageData.GetOwner:TProduct;
begin
  result:=nil;
  if Assigned(Collection) then
    result:=TProduct(Collection.Owner);
end;

{ TStageCollection }

constructor TStageCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner,TStageData);
end;

function TStageCollection.GetItem(Index: integer): TStageData;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TStageData;
end;

function TStageCollection.Add: TStageData;
begin
  Result := inherited Add as TStageData;
end;

procedure TStageCollection.InitAll;
var
  i:integer;
begin
  for i:=0 to Pred(Count) do Item[i].Init;
end;


{ TProductDocument }

function TProductDocument.GetHash:ansistring;
var
  lSHA256  : fpsha256.TSHA256;
  S        : TBytes;
  FS:int64;
begin
  //FS:=GetFileSize(aPath);
  FS:=GetTickCount64;
  //FS:=Random(High(Int64));

  lSHA256.Init;
  S:=TEncoding.UTF8.GetAnsiBytes(fPath);
  lSHA256.Update(S);
  S:=TEncoding.UTF8.GetAnsiBytes(InttoStr(FS));
  lSHA256.Update(S);
  lSHA256.Final;
  lSHA256.OutputHexa(result);

  //result:= Int64(Hash32(aPath)) or (Int64(UnixTimeUtc) shl 31);
  //result := SHA256(FormatUTF8('%'#1'%'#2,[Hash32(aPath),GetFileSize(aPath)]));
end;


procedure TProductDocument.SetPath(aPath:RawUTF8);
begin
  if fPath<>aPath then
  begin
    fPath:=aPath;
    if Length(fPath)>0 then
    begin
      fName:=ExtractFileName(fPath);
      fHash:=GetHash;
    end;
  end;
end;

function TProductDocument.GetOwner:TProduct;
begin
  result:=nil;
  if Assigned(Collection) then
    result:=TProduct(Collection.Owner);
end;

{ TProductDocumentCollection }

constructor TProductDocumentCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner,TProductDocument);
end;

function TProductDocumentCollection.GetItem(Index: integer): TProductDocument;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TProductDocument;
end;

function TProductDocumentCollection.Add: TProductDocument;
begin
  Result := inherited Add as TProductDocument;
end;

function TProductDocumentCollection.AddOrUpdate(const Target: TDocumentTarget; const AddIfNotFound:boolean; out aDocument:TProductDocument): boolean;
var
  DocumentRunner:TProductDocument;
begin
  result:=true;
  aDocument:=nil;
  for TCollectionItem(DocumentRunner) in Self do
  begin
    if (DocumentRunner.Target=Target) then
    begin
      aDocument:=DocumentRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(aDocument) then if AddIfNotFound then
  begin
    aDocument := Add;
    aDocument.Target:=Target;
  end;
end;

{ TProduct }

constructor TProduct.Create(ACollection: TCollection);
begin
  fBatteryDetail:=TBatteryDetails.Create;
  fTesDatas := TTestCollection.Create(Self);
  fStages := TStageCollection.Create(Self);
  fDocuments:=TProductDocumentCollection.Create(Self);
  inherited Create(ACollection);
end;

destructor TProduct.Destroy;
begin
  fDocuments.Destroy;
  fBatteryDetail.Free;
  fStages.Destroy;
  fTesDatas.Destroy;
  inherited Destroy;
end;

procedure TProduct.Init;
begin
  B_code            := 'Undefined';
  B_name            := '';
  B_type            := '';
  StatedCapacity    := 0;
  B_id              := '';
  Test_id           := '';
  Stages.InitAll;
  TestDatas.InitAll;
end;

function TProduct.GetSampleData(TestIndex:integer;Sample:integer):TRunData;
var
  TD:TTestData;
begin
  result:=nil;
  if (TestIndex<TestDatas.Count) then
  begin
    TD:=TestDatas.Item[TestIndex];
    if (Sample>0) AND (Sample<=TD.RunDatas.Count) then
      result:=TD.RunDatas.Item[Sample-1];
  end;
end;

function TProduct.GetMeasurementSampleData(SampleIndex:integer):TRunData;
begin
  result:=GetSampleData(0,SampleIndex);
end;

function TProduct.GetStageData(StageIndex:integer):TStageData;
begin
  result:=nil;
  if (StageIndex<Stages.Count) then
  begin
    result:=Stages.Item[StageIndex];
  end;
end;

function TProduct.GetMeasurementTestData:TTestData;
begin
  result:=nil;
  if (TestDatas.Count>0) then result:=TestDatas.Item[0];
end;

function TProduct.GetTypeNumber:integer;
begin
  result:=(Index+1);
end;

constructor TBatteryDetails.Create;
begin
  FWarnings             := TBatteryWarnings.Create;
  FDisposal             := TBatteryDisposal.Create;
  FRechargeable         := TBatteryRechargeable.Create;
end;

destructor TBatteryDetails.Destroy;
begin
  FWarnings.Free;
  FDisposal.Free;
  FRechargeable.Free;
end;

function TBatteryDetails.GetTotal:integer;
begin
  result:=FAmount_per_package*FAmount_of_packs;
end;


{ TProductCollection }

constructor TProductCollection.Create;
begin
  inherited Create(TProduct);
end;

function TProductCollection.GetItem(Index: integer): TProduct;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TProduct;
end;

procedure TProductCollection.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited;
end;

function TProductCollection.Add: TProduct;
begin
  Result := inherited Add as TProduct;
end;

function TProductCollection.AddOrUpdate(const ABC:RawUTF8; const AddIfNotFound:boolean; out aBattery:TProduct): boolean;
var
  BatteryRunner:TProduct;
begin
  result:=true;
  aBattery:=nil;
  for TCollectionItem(BatteryRunner) in Self do
  begin
    if (BatteryRunner.B_code=ABC) then
    begin
      aBattery:=BatteryRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(aBattery) then if AddIfNotFound then
  begin
    aBattery := Add;
    aBattery.B_code:=ABC;
  end;
end;


function TProductCollection.GetBatteryData(BatteryIndex:integer):TProduct;
begin
  result:=nil;
  if ((BatteryIndex<=Count) AND (BatteryIndex>0)) then
  begin
    result:=Item[BatteryIndex-1];
  end;
end;

function TProductCollection.GetMeasurementSampleData(BatteryIndex,SampleIndex:integer):TRunData;
var
  Battery:TProduct;
begin
  result:=nil;
  Battery:=GetBatteryData(BatteryIndex);
  if Assigned(Battery) then result:=Battery.GetMeasurementSampleData(SampleIndex);
end;

function TProductCollection.GetStageData(BatteryIndex,StageIndex:integer):TStageData;
var
  Battery:TProduct;
begin
  result:=nil;
  Battery:=GetBatteryData(BatteryIndex);
  if Assigned(Battery) then result:=Battery.GetStageData(StageIndex);
end;


initialization
  //Rtti.RegisterClass(TBatteryDetails);
  //Rtti.RegisterClass(TBatteryWarnings);
  //Rtti.RegisterClass(TBatteryDisposal);
  //Rtti.RegisterClass(TBatteryRechargeable);

end.

