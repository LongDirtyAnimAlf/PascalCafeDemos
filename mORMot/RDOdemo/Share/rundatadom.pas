unit rundatadom;

interface

uses
  Classes,
  servicesshared;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type
  TElapsedValue       = Cardinal;
  TSetValue           = integer;

  { TMeasurementData }

  TMeasurementData = class(TCollectionItem)
  private
    fElapsed:TElapsedValue;
    fVoltage:double;
    fCurrent:double;
    fCapacity:double;
    fEnergy:double;
    fTemperature:integer;
    fLiveTime:TDateTime;
  protected
    procedure Init;
  public
    constructor Create(ACollection: TCollection); override;
    function LiveVoltage:Cardinal;
    function LiveCurrent:Cardinal;
    function LiveTemperature:Cardinal;
    property LiveTime:TDateTime read fLiveTime write fLiveTime;
  published
    property Elapsed:TElapsedValue read fElapsed write fElapsed;
    property Voltage:double read fVoltage write fVoltage;
    property Current:double read fCurrent write fCurrent;
    property Capacity:double read fCapacity write fCapacity;
    property Energy:double read fEnergy write fEnergy;
    property Temperature:integer read fTemperature write fTemperature;
  end;

  { TNewLiveDataCollection }

  TNewLiveDataCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TMeasurementData;
  public
    constructor Create(AOwner: TObject);overload;
    function Add: TMeasurementData;
    function Last: TMeasurementData;
    property Item[Index: integer]: TMeasurementData read GetItem;
  end;

  TThresholdModes = (tmNONE,tmMAXV,tmMINV,tmDELTAV,tmPLATEAUV,tmABST,tmDELTAT,tmDVT,tmTIME);

  TThresholdDataItem = class(TCollectionItem)
  strict private
    procedure SetTriggered(aValue:boolean);
  private
    fMode         : TThresholdModes;
    fPreTrigger   : boolean;
    fTriggered    : boolean;
    fTriggerStore : boolean;
    fData         : double;
    fMoment       : TDateTime;
  public
    constructor Create(ACollection: TCollection); override;
  published
    property Mode         : TThresholdModes read fMode write fMode;
    property PreTrigger   : boolean read fPreTrigger write fPreTrigger;
    property Triggered    : boolean read fTriggered write SetTriggered;
    property TriggerStore : boolean read fTriggerStore write fTriggerStore;
    property Data         : double read fData write fData;
    property Moment       : TDateTime read fMoment write fMoment;
  end;

  TThresholdDataCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TThresholdDataItem;
  public
    constructor Create(AOwner: TPersistent);overload;
    function Add: TThresholdDataItem;
    function AddOrUpdate(Mode:TThresholdModes; const AddIfNotFound:boolean; out TD:TThresholdDataItem): boolean;
    property Item[Index: integer]: TThresholdDataItem read GetItem;
  end;

  TDischargeBaseType  = (btUnknown, btSingleCycle, btMultiCycle);

  TBatteryMode   = (bmIdle,bmActive,bmPause,bmWaiting,bmOff,bmReady,bmError);
  TBatteryModes   = set of TBatteryMode;


  {$ifdef COINCELL}
  TStageMode     = (smUnknown,smResistor,smCurrent,smPower,smVoltage,smPulsedCurrent,smZero,smDisabled);
  {$else}
  TStageMode     = (smUnknown,smResistor,smCurrent,smPower,smVoltage,smCharge,smPulse,smTopOff,smTrickle,smZero,smDisabled);
  {$endif}
  TStageModes     = set of TStageMode;

  TDischargeMode  = smResistor..smVoltage;
  {$ifndef COINCELL}
  TChargeMode     = smCharge..smTrickle;
  {$endif}

  { TRunData }

  TRunData = class(TCollectionItem)
  private
    fCurrentStageNumber   : word;
    fBoardSerial          : RawUTF8;
    fCycles               : word;
    fSampleNumber         : integer;
    fDataInvalid          : boolean;
    fNewLiveData          : TNewLiveDataCollection;
    FThresholdDataCollection : TThresholdDataCollection;
  public
    BatteryMode        : TBatteryMode;
    StageTime          : TDateTime;       {amount of time [sec] in current stage}
    LastTime           : TDateTime;       {last time voltage was measured}
    RunningTime        : TDateTime;       {total time storage}

    TotalActiveTime    : LongWord;        {total active stagetime in milli-seconds: its limit [longword] is 1200 hours}

    CalcCurrent        : integer;
    CalcEnergy         : double;
    BoardEnergy        : double;
    EnvTemperature     : double;
    EnvHumidity        : double;
    ErrorCount         : longword;

    MeasuredVoltage     : double;
    MeasuredCurrent     : double;
    MeasuredCapacity    : double;
    MeasuredEnergy      : double;
    MeasuredTemperature : double;

    Save1200           : boolean;
    Save1150           : boolean;
    Save1100           : boolean;
    Save1050           : boolean;
    Save1000           : boolean;
    Save900            : boolean;
    Save800            : boolean;
    SaveEV             : boolean;

    BoardCaldate       : string[30];     {calibration date of board that is used to measure this battery}
    BoardFirmware      : word;           {firmware of board that is used to measure this battery}

    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;

    function GetOwner:TPersistent; override;

    procedure Init(const DT:TDateTime);
    procedure ResetCurrentStageNumber;
    procedure StepUpStage;
    procedure StepDownStage;
    procedure AddMeasurementData(const ElapsedTimeMS:TElapsedValue);overload;
    procedure AddMeasurementData(const SetLastTime:TDateTime);overload;
    property CurrentStageNumber  : word read fCurrentStageNumber;
  published
    property BoardSerial              : RawUTF8 read fBoardSerial write fBoardSerial;
    property Cycles                   : word read fCycles write fCycles;
    property SampleNumber             : integer read fSampleNumber write fSampleNumber;
    property DataInvalid              : boolean read fDataInvalid write fDataInvalid;
    property NewLiveData              : TNewLiveDataCollection read fNewLiveData write fNewLiveData;
    property ThresholdDataCollection  : TThresholdDataCollection read fThresholdDataCollection write fThresholdDataCollection;
  end;

  { TRunDataCollection }
  TRunDataCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TRunData;
  public
    property Item[Index: integer]: TRunData read GetItem;
  public
    constructor Create(AOwner: TPersistent);overload;
    function Add: TRunData;
    function AddOrUpdate(Sample:integer; out RD:TRunData): boolean;
    procedure InitAll;
  end;

const
  BatteryModeIdentifier : array[TBatteryMode] of string   = ('Idle','Active','Pause','Waiting','Off','Ready','Error');

  {$ifdef COINCELL}
  ChargeModes     = [];
  {$else}
  ChargeModes     = [smCharge,smPulse,smTopOff,smTrickle];
  {$endif}
  DischargeModes  = [smResistor,smCurrent,smPower,smVoltage];

  {$ifdef COINCELL}
  ModeIdentifier : array[TStageMode] of string =
    ('Unknown','Resistor','Current','Power','Voltage','PulsedCurrent','Zero','Disabled');
  ModeUnits : array[TStageMode] of string =
    ('-','Ω','μA','μW','V','μA','s','-');
  DischargeTypeTextCompat : array[TStageMode] of string =
    ('NA','RD','CD','PD','VD','PC','IT','D');
  {$else}
  ModeIdentifier : array[TStageMode] of string =
    ('Unknown','Resistor','Current','Power','Voltage','Charge','Pulse','TopOff','Trickle','Zero','Disabled');
  ModeUnits : array[TStageMode] of string =
    ('-','mΩ','mA','mW','V','mA','mA','mA','mA','s','-');
  DischargeTypeTextCompat : array[TStageMode] of string =
    ('NA','RD','CD','PD','VD','CC','PC','TC','CTr','IT','D');
  ModeUnitsCompat : array[TStageMode] of string =
    ('-','mOhm','mAmps','mWatt','Volt','mAmps','mAmps','mAmps','mAmps','sec','-');
  {$endif}

  ThresholdNames : array[TThresholdModes] of string = (
    'none',
    'maxV',
    'minV',
    'deltaV',
    'plateauV',
    'absT',
    'deltaT',
    'dvT',
    'Time'
  );

  ThresholdNamesCompat : array[TThresholdModes] of string = (
    'None',
    'MaxV',
    'MinV',
    'dV',
    'dVdt',
    'MaxT',
    'dT',
    'dTdt',
    'TT'
  );

  VoltageIdentifier = 'mV';
  TemperatureIdentifier = '°C';
  {$ifdef COINCELL}
  CapacityIdentifier = 'μAh';
  EnergyIdentifier = 'μWh';
  {$else}
  CapacityIdentifier = 'mAh';
  EnergyIdentifier = 'mWh';
  {$endif}
  TimeIdentifier = 's';

  ThresholdIdentifiers : array[TThresholdModes] of string = (
    '-',
    VoltageIdentifier,
    VoltageIdentifier,
    VoltageIdentifier,
    VoltageIdentifier,
    TemperatureIdentifier,
    TemperatureIdentifier,
    TemperatureIdentifier+'/s',
    TimeIdentifier
  );

  function FromText(Stage:shortstring):TStageMode;
  function FromTextCompat(Stage:shortstring):TStageMode;
  function CompareRunDataSampleNumber(const a, b: TCollectionItem): Integer;

implementation

uses
  DateUtils,
  SysUtils;

function FromText(Stage:shortstring):TStageMode;
var
  Mode:TStageMode;
begin
  result:=TStageMode.smUnknown;
  for Mode in TStageMode do
  begin
    if Stage=ModeIdentifier[Mode] then
    begin
      result:=Mode;
      break;
    end;
  end;
end;

function FromTextCompat(Stage:shortstring):TStageMode;
var
  Mode:TStageMode;
begin
  result:=TStageMode.smUnknown;
  for Mode in TStageMode do
  begin
    if Stage=DischargeTypeTextCompat[Mode] then
    begin
      result:=Mode;
      break;
    end;
  end;
end;

function CompareRunDataSampleNumber(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TRunData)) or (not (b is TRunData)) then
    raise Exception.Create('Invalid TBattery reference.');
  result:=(TRunData(a).SampleNumber-TRunData(b).SampleNumber);
end;

constructor TMeasurementData.Create(ACollection: TCollection);
begin
  // Defaults to be sure
  Init;
  inherited Create(ACollection);
end;

procedure TMeasurementData.Init;
begin
  fElapsed      := 0;
  fVoltage      := 0;
  fCurrent      := 0;
  fCapacity     := 0;
  fEnergy       := 0;
  fTemperature  := 0;
  fLiveTime     := 0;
end;

function TMeasurementData.LiveVoltage:Cardinal;
begin
  result:=round(1000000*Voltage);
end;
function TMeasurementData.LiveCurrent:Cardinal;
begin
  result:=round(1000000*Current);
end;
function TMeasurementData.LiveTemperature:Cardinal;
begin
  result:=round((1000000/10)*Temperature);
end;

{ TNewLiveDataCollection }

constructor TNewLiveDataCollection.Create(AOwner: TObject);
begin
  if AOwner is TPersistent then
    inherited Create((AOwner AS TPersistent),TMeasurementData)
  else
    inherited Create(nil,TMeasurementData);
end;

function TNewLiveDataCollection.GetItem(Index: integer): TMeasurementData;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TMeasurementData;
end;

function TNewLiveDataCollection.Add: TMeasurementData;
begin
  Result := inherited Add as TMeasurementData;
  (*
  if Count>0 then
  begin
    Result.Elapsed:=Result.Elapsed+Item[Pred(Count)].Elapsed;
  end;
  *)
end;

function TNewLiveDataCollection.Last: TMeasurementData;
begin
  if Count>0 then
    result:=Item[Pred(Count)]
  else
    result:=nil;
end;

constructor TThresholdDataItem.Create(ACollection: TCollection);
begin
  // Defaults to be sure
  fMode         := TThresholdModes.tmNONE;
  fPreTrigger   := false;
  fTriggered    := false;
  fTriggerStore := false;
  fData         := 0;
  inherited Create(ACollection);
end;

procedure TThresholdDataItem.SetTriggered(aValue:boolean);
begin
  if aValue<>fTriggered then
  begin
    fTriggered:=aValue;
    if fTriggered then fTriggerStore:=True;
  end;
end;

constructor TThresholdDataCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner,TThresholdDataItem);
end;

function TThresholdDataCollection.GetItem(Index: integer): TThresholdDataItem;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TThresholdDataItem;
end;

function TThresholdDataCollection.Add: TThresholdDataItem;
begin
  Result := inherited Add as TThresholdDataItem;
end;

function TThresholdDataCollection.AddOrUpdate(Mode:TThresholdModes; const AddIfNotFound:boolean; out TD:TThresholdDataItem): boolean;
var
  ThresholdRunner:TThresholdDataItem;
begin
  TD:=nil;
  result:=true;
  for TCollectionItem(ThresholdRunner) in Self do
  begin
    if (ThresholdRunner.Mode=Mode) then
    begin
      TD:=ThresholdRunner;
      result:=false;
      break;
    end;
  end;
  if ((NOT Assigned(TD)) AND AddIfNotFound) then
  begin
    TD := Add;
    TD.Mode:=Mode;
  end;
end;

{ TRunData }

constructor TRunData.Create(ACollection: TCollection);
begin
  fNewLiveData := TNewLiveDataCollection.Create(Self);
  FThresholdDataCollection := TThresholdDataCollection.Create(Self);
  inherited Create(ACollection);
end;

destructor TRunData.Destroy;
begin
  FThresholdDataCollection.Destroy;
  fNewLiveData.Destroy;
  inherited Destroy;
end;

procedure TRunData.AddMeasurementData(const ElapsedTimeMS:TElapsedValue);
var
  PreviousData:TMeasurementData;
begin
  with NewLiveData.Add do
  begin
    Voltage:=MeasuredVoltage;
    Current:=MeasuredCurrent;
    Capacity:=MeasuredCapacity;
    Energy:=MeasuredEnergy;
    LiveTime:=LastTime;
    Elapsed:=ElapsedTimeMS;
    if (LiveTime=0) then raise Exception.Create('Invalid LiveTime for storing of measurement data.');
  end;
end;

procedure TRunData.AddMeasurementData(const SetLastTime:TDateTime);
var
  PreviousData:TMeasurementData;
begin
  PreviousData:=NewLiveData.Last;
  with NewLiveData.Add do
  begin
    Voltage:=MeasuredVoltage;
    Current:=MeasuredCurrent;
    Capacity:=MeasuredCapacity;
    Energy:=MeasuredEnergy;
    LiveTime:=SetLastTime;
    if Assigned(PreviousData) then
      Elapsed:=PreviousData.Elapsed+MilliSecondsBetween(LiveTime,PreviousData.LiveTime)
    else
      Elapsed:=0;
    if (LiveTime=0) then raise Exception.Create('Invalid LiveTime for storing of measurement data.');
  end;
end;

procedure TRunData.Init(const DT:TDateTime);
begin
  fCurrentStageNumber   := 0;

  MeasuredVoltage       := 0;
  MeasuredCurrent       := 0;
  MeasuredCapacity      := 0;
  MeasuredEnergy        := 0;
  MeasuredTemperature   := 0;

  BatteryMode           := TBatteryMode.bmIdle;

  if (DT<>0) then
  begin
    // Only set if we have a valid TDateTime
    StageTime           := DT;
    LastTime            := DT;
    RunningTime         := DT;
  end;

  TotalActiveTime       := 0;

  CalcCurrent           := 0;
  CalcEnergy            := 0;
  BoardEnergy           := 0;
  Cycles                := 0;
  EnvTemperature        := 0;
  EnvHumidity           := 0;
  ErrorCount            := 0;

  Save1200              := false;
  Save1150              := false;
  Save1100              := false;
  Save1050              := false;
  Save1000              := false;
  Save900               := false;
  Save800               := false;
  SaveEV                := false;

  DataInvalid           := false;

  NewLiveData.Clear;
  ThresholdDataCollection.Clear;
end;

function TRunData.GetOwner:TPersistent;
begin
  result:=nil;
  if Assigned(Collection) then
    result:=TPersistent(Collection.Owner);
end;

procedure TRunData.ResetCurrentStageNumber;
begin
  fCurrentStageNumber:=0;
end;

procedure TRunData.StepUpStage;
begin
  Inc(fCurrentStageNumber)
end;

procedure TRunData.StepDownStage;
begin
  if (fCurrentStageNumber>0) then Dec(fCurrentStageNumber);
end;

{ TRunDataCollection }

constructor TRunDataCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner,TRunData);
end;

function TRunDataCollection.GetItem(Index: integer): TRunData;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TRunData;
end;

function TRunDataCollection.Add: TRunData;
begin
  Result := inherited Add as TRunData;
end;

function TRunDataCollection.AddOrUpdate(Sample:integer; out RD:TRunData): boolean;
var
  DataRunner:TRunData;
begin
  RD:=nil;
  result:=true;
  for TCollectionItem(DataRunner) in Self do
  begin
    if (DataRunner.SampleNumber=Sample) then
    begin
      RD:=DataRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(RD) then
  begin
    RD := Add;
    RD.SampleNumber:=Sample;
  end;
end;

procedure TRunDataCollection.InitAll;
var
  i:integer;
begin
  for i:=0 to Pred(Count) do Item[i].Init(0);
end;

end.

