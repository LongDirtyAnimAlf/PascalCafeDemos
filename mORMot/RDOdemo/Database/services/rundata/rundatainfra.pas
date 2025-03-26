unit rundatainfra;

interface

{$I mormot.defines.inc}

uses
  SysUtils,
  rundatadom,
  mormot.core.base,
  mormot.core.os,
  mormot.core.rtti,
  mormot.orm.base,
  mormot.orm.core;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type
  TOrmRunData = class(TOrm)
  private
    fProductCode          : RawUTF8;
    fSampleNumber         : integer;

    fBatID                : RawUTF8;
    fTestID               : RawUTF8;

    fInfo                 : RawUTF8;
    fDate                 : TDateTime;
    fBoardSerial          : RawUTF8;

    fDischargeBaseType    : TDischargeBaseType;
    fDischargeType        : TStageMode;
    fDischargeTypes       : TStageModes;
    fDischargeValue       : TSetValue;

    fTThresholdMode       : TThresholdModes;
    fTThresholdValue      : RawUTF8;

    fDataInvalid          : boolean;

    fBatteryData          : TNewLiveDataCollection;
    fVersion              : TRecordVersion;
  public
    procedure InternalCreate;override;
    destructor Destroy;override;
  published
    property ProductCode         : RawUTF8 read fProductCode write fProductCode;
    property SampleNumber        : integer read fSampleNumber write fSampleNumber;

    property BatID               : RawUTF8 read fBatID write fBatID;
    property TestID              : RawUTF8 read fTestID write fTestID;

    property Info                : RawUTF8 read fInfo write fInfo;
    property Date                : TDateTime read fDate write fDate;
    property BoardSerial         : RawUTF8 read fBoardSerial write fBoardSerial;

    property DischargeBaseType   : TDischargeBaseType read fDischargeBaseType write fDischargeBaseType;
    property DischargeType       : TStageMode read fDischargeType write fDischargeType;
    property DischargeTypes      : TStageModes read fDischargeTypes write fDischargeTypes;
    property DischargeValue      : TSetValue read fDischargeValue write fDischargeValue;

    property TThresholdMode      : TThresholdModes read fTThresholdMode write fTThresholdMode;
    property TThresholdValue     : RawUTF8 read fTThresholdValue write fTThresholdValue;

    property DataInvalid         : boolean read fDataInvalid write fDataInvalid;

    property BatteryData         : TNewLiveDataCollection read fBatteryData write fBatteryData;
    property Version             : TRecordVersion read fVersion write fVersion;
  end;

implementation

procedure TOrmRunData.InternalCreate;
begin
  inherited InternalCreate;
  fBatteryData := TNewLiveDataCollection.Create(Self);
end;

destructor TOrmRunData.Destroy;
begin
  fBatteryData.Free;
  inherited Destroy;
end;

initialization
  Rtti.RegisterCollection(TNewLiveDataCollection,TMeasurementData);
  Rtti.RegisterCollection(TThresholdDataCollection,TThresholdDataItem);
  Rtti.RegisterCollection(TRunDataCollection,TRunData);
  Rtti.ByClass[TMeasurementData].Props.NameChanges(
  ['Elapsed','Voltage','Current','Capacity','Energy','Temperature']
  ,
  ['EL','V','I','C','E','T']
  );

end.
