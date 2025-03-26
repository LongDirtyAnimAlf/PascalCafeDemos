unit rundatastorageimplementation;

interface

{$I mormot.defines.inc}
uses
  Classes,
  SysUtils,
  mormot.core.base,
  mormot.core.os,
  mormot.core.rtti,
  mormot.orm.base,
  mormot.orm.core,
  mormot.orm.rest,
  servicesshared,
  rundatadom,
  rundatainfra,
  rundatastorageinterface;

type
  TRunDataStorage = class(TInterfacedObject, IRunDataStorage)
  strict private
    fRestOrm   : TRestOrm;
    fMap       : TRttiMap;
  protected
    procedure CopyORMRunData(const OrmSample: TOrmRunData; var ARunData: TRunData);
    procedure CopyRunDataORM(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData; var OrmSample: TOrmRunData);
    function GetRunData(const APC:RawUTF8;const ADT:TStageMode;const ADV:TSetValue; const ASN: integer): TOrmRunData;
    function GetRunDataIDVersionOnly(const APC:RawUTF8;const ADT:TStageMode;const ADV:TSetValue; const ASN: integer): TOrmRunData;
    function GetRunDatas(const APC:RawUTF8; const ADT:TStageMode;const ADV:TSetValue;const Summary:boolean): TOrmRunData;
  public
    constructor Create(ARestOrm:TRestOrm);
    function RetrieveRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:TSetValue; out ARunData: TRunData): TStorageResult;
    function RetrieveRunDatas(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue;const Summary:boolean; out ARunDatas: TRunDataCollection): TStorageResult;
    function SaveNewRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData): TStorageResult;
    function UpdateRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const Fieldinfo:RawUTF8; const ARunData: TRunData):TStorageResult;
    function DeleteRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:TSetValue): TStorageResult;
    function ChangedRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; const aVersion:Int64; out Changed:boolean): TStorageResult;
  end;


implementation

uses
  tools,
  mormot.db.core,
  mormot.core.json,
  mormot.core.text;

{
****************************** TProductRepository *******************************
}

constructor TRunDataStorage.Create(ARestOrm:TRestOrm);
begin
  inherited Create;

  fRestOrm :=ARestOrm;

  fMap.Init(TOrmRunData, TRunData).AutoMap;
end;

procedure TRunDataStorage.CopyORMRunData(const OrmSample: TOrmRunData; var ARunData: TRunData);
var
  i:integer;
begin
  // Copy data to DTO
  fMap.ToB(OrmSample,ARunData);

  if (OrmSample.TThresholdMode<>TThresholdModes.tmNONE) then
  begin
    with ARunData.ThresholdDataCollection.Add do
    begin
      Triggered:=True;
      Mode:=OrmSample.TThresholdMode;
      Data:=ExtractFloatInString(OrmSample.TThresholdValue);
      Moment:=OrmSample.Date;
    end;
  end;

  //ASample.SampleNumber := OrmSample.SampleNumber;
  CopyObject(OrmSample.BatteryData,ARunData.NewLiveData);
end;

procedure TRunDataStorage.CopyRunDataORM(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData; var OrmSample: TOrmRunData);
var
  Mode                    : TThresholdModes;
  //MeasurementDataRunner   : TMeasurementData;
  //MeasurementData         : TMeasurementData;
  TDRunner                : TThresholdDataItem;
begin
  // Copy DTO to ORM
  fMap.ToA(OrmSample,ARunData);

  OrmSample.ProductCode:=ABC;
  OrmSample.DischargeType:=AStage;
  OrmSample.DischargeTypes:=[AStage];
  OrmSample.DischargeValue:=AStageValue;

  for TCollectionItem(TDRunner) in ARunData.ThresholdDataCollection do
  begin
    with TDRunner do
    begin
      if Triggered then
      begin
        OrmSample.TThresholdMode:=Mode;
        OrmSample.TThresholdValue:=FloatToStr(Data)+ThresholdIdentifiers[Mode];
        OrmSample.Date:=Moment;
        break;
      end;
    end;
  end;

  // Overwite or append !!
  // For now, clear the measurement data and replace with new ones
  (*
  OrmSample.BatteryData.Clear;
  for TCollectionItem(MeasurementDataRunner) in ASample.NewLiveData do
  begin
    MeasurementData:=OrmSample.BatteryData.Add;
    CopyObject(MeasurementDataRunner,MeasurementData);
  end;
  *)
  // Should work !!
  if (ARunData.NewLiveData.Count>0) then
  begin
    CopyObject(ARunData.NewLiveData,OrmSample.BatteryData);
  end;
end;

function TRunDataStorage.GetRunData(const APC:RawUTF8;const ADT:TStageMode;const ADV:TSetValue; const ASN: integer): TOrmRunData;
var
  where        : RawUtf8;
begin
  //Result := TOrmRunData.Create(fRestOrm,'ProductCode = ? AND DischargeType = ? AND DischargeValue = ? AND SampleNumber = ?',[APC,ADT,ADV,ASN]);
  result := TOrmRunData.Create;
  where := FormatSql('ProductCode = ? AND DischargeType = ? AND DischargeValue = ? AND SampleNumber = ?', [], [APC,ADT,ADV,ASN]);
  // Retrieve all fields, including blobs and calculated
  FRestOrm.Retrieve(where,result,'*');
end;

function TRunDataStorage.GetRunDataIDVersionOnly(const APC:RawUTF8;const ADT:TStageMode;const ADV:TSetValue; const ASN: integer): TOrmRunData;
var
  aID,aVersion : TID;
  res          : array[0..1] of RawUtf8;
  where        : RawUtf8;
begin
  // Get the ORM-ID and ORM-Version of the rundata from the server
  where := FormatSql('ProductCode = ? AND DischargeType = ? AND DischargeValue = ? AND SampleNumber = ?', [], [APC,ADT,ADV,ASN]);
  if FRestOrm.MultiFieldValue(TOrmRunData,[ROWID_TXT,TOrmRunData.OrmProps.RecordVersionField.Name],res,where) then
  begin
    SetInt64(pointer(res[0]), {%H-}aID);
    SetInt64(pointer(res[1]), {%H-}aVersion);
    result:=TOrmRunData.CreateWithID(aID);
    result.Version:=aVersion;
  end
  else
    result := TOrmRunData.Create;
end;

function TRunDataStorage.GetRunDatas(const APC:RawUTF8; const ADT:TStageMode;const ADV:TSetValue;const Summary:boolean): TOrmRunData;
var
  SQL:RawUTF8;
  Fields:TFieldBits;
begin
  if Summary then
  begin
    // Get a summary of the data !!
    // So, get all the fields, except the battery data
    // Ask only the last array element of the BatteryData
    Fields:=TOrmRunData.OrmProps.FieldBitsFromExcludingClass([TNewLiveDataCollection],ooSelect,True);
    //Fields:=TOrmRunData.OrmProps.FieldBitsFromExcludingCsv('BatteryData');
    // Add Version field
    FieldBitSet(Fields,TOrmRunData.OrmProps.RecordVersionField.PropertyIndex);
    // We now have the fieldbits for all simple fields
    // Get all the names
    SQL:=TOrmRunData.OrmProps.CsvTextFromFieldBits(Fields);
    // Now include the ID field and the special batterydata field that holds only the last array element
    SQL:=ROWID_TXT+','+SQL+',json_array(json_extract(BatteryData, "$[#-1]")) AS BatteryData';
  end
  else
  begin
    SQL:='';
  end;
  if ((ADT=TStageMode.smUnknown) AND (ADV=0)) then
  begin
    Result:=TOrmRunData.CreateAndFillPrepare(fRestOrm,'ProductCode = ? Order by ProductCode,DischargeType,length(DischargeValue),DischargeValue,SampleNumber',[APC],SQL);
  end
  else
  begin
    Result:=TOrmRunData.CreateAndFillPrepare(fRestOrm,'ProductCode = ? AND DischargeType = ? AND DischargeValue = ? Order by ProductCode,DischargeType,length(DischargeValue),DischargeValue,SampleNumber',[APC,ADT,ADV],SQL);
  end;
end;

function TRunDataStorage.RetrieveRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:TSetValue; out ARunData: TRunData): TStorageResult;
var
  OrmSample: TOrmRunData;
begin
  Result := stNotFound;
  OrmSample := GetRunData(ABC,AStage,AStageValue,ASampleNumber);
  try
    if OrmSample.IDValue = 0 then
      exit;

    CopyORMRunData(OrmSample,ARunData);

    Result := stSuccess;
  finally
    OrmSample.Free;
  end;
end;

function TRunDataStorage.RetrieveRunDatas(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue;const Summary:boolean; out ARunDatas: TRunDataCollection): TStorageResult;
var
  OrmSample: TOrmRunData;
  RunData:TRunData;
begin
  Result := stNotFound;
  OrmSample := GetRunDatas(ABC,AStage,AStageValue,Summary);
  try
    if OrmSample.FillTable.RowCount = 0 then
      exit;

    while OrmSample.FillOne do
    begin
      RunData:=ARunDatas.Add;
      CopyORMRunData(OrmSample,RunData);
    end;

    Result := stSuccess;
  finally
    OrmSample.Free;
  end;
end;

function TRunDataStorage.SaveNewRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData):TStorageResult;
var
  OrmSample               : TOrmRunData;
begin
  Result := stWriteFailure;
  OrmSample := GetRunData(ABC,AStage,AStageValue,ARunData.SampleNumber);
  try
    CopyRunDataORM(ABC,AStage,aStageValue,ARunData,OrmSample);
    if fRestOrm.AddOrUpdate(OrmSample) > 0 then
      Result := stSuccess;
  finally
    OrmSample.Free;
  end;
end;

function TRunDataStorage.UpdateRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const Fieldinfo:RawUTF8; const ARunData: TRunData):TStorageResult;
var
  JSON       : RawUTF8;
  aID        : TID;
  OrmSample  : TOrmRunData;
begin
  Result := stWriteFailure;

  // Get the ORM-aID of the RunData from the server
  OrmSample := GetRunDataIDVersionOnly(ABC,AStage,AStageValue,ARunData.SampleNumber);

  try
    if (OrmSample.IDValue=0) then exit;
    if Fieldinfo = '*' then
    begin
      // Update all fields
      CopyRunDataORM(ABC,AStage,AStageValue,ARunData,OrmSample);
      if fRestOrm.AddOrUpdate(OrmSample) > 0 then
        Result := stSuccess;
    end
    else
    begin
      if OrmSample.OrmProps.IsFieldName(pointer(Fieldinfo)) then
      begin
        // Update some field[s]
        fMap.ToA(OrmSample,ARunData);
        if fRestOrm.Update(OrmSample,Fieldinfo) then
          Result := stSuccess;
      end;
    end;
  finally
    OrmSample.Free;
  end;
end;

function TRunDataStorage.DeleteRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:TSetValue): TStorageResult;
var
  OrmSample: TOrmRunData;
begin
  Result := stNotFound;
  OrmSample := GetRunData(ABC,AStage,AStageValue,ASampleNumber);
  try
    if (OrmSample.IDValue>0) then
    begin
      fRestOrm.Delete(TOrmRunData,OrmSample.IDValue);
      Result := stSuccess;
    end;
  finally
    OrmSample.Free;
  end;
end;

function TRunDataStorage.ChangedRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; const aVersion:Int64; out Changed:boolean): TStorageResult;
var
  OrmRun:TOrmRunData;
begin
  Result := stNotFound;
  OrmRun := GetRunDataIDVersionOnly(ABC,AStage,AStageValue,ASampleNumber);
  try
    if (OrmRun.IDValue>0) then
    begin
      Changed:=(aVersion<>OrmRun.Version);
      Result := stSuccess;
    end;
  finally
    OrmRun.Free;
  end;
end;

end.
