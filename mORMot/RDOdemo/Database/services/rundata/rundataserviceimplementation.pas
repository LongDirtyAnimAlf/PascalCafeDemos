unit rundataserviceimplementation;

interface

{$I mormot.defines.inc}

uses
  mormot.soa.server,
  servicesshared,  
  rundatadom,
  rundataserviceinterface,
  rundatastorageinterface;

type
  TRunDataService = class(TInjectableObjectRest, IRunDataService)
  private
    fStorage: IRunDataStorage;
  public
    constructor Create(AStorage: IInvokable); reintroduce;

    function AddRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData): TServiceResult;
    function FindRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; out ARunData: TRunData): TServiceResult;
    function FindRunDatas(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue;const Summary:boolean; out ARunDatas: TRunDataCollection): TServiceResult;
    function UpdateRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const FieldData:Variant): TServiceResult;
    function DeleteRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer): TServiceResult;
    function ChangedRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; const aVersion:Int64; out Changed:boolean): TServiceResult;
  end;

implementation

uses
  mormot.core.text,
  mormot.core.variants,
  mormot.core.json;

{
******************************** TBatteryService ********************************
}
constructor TRunDataService.Create(AStorage: IInvokable);
begin
  inherited Create;
  fStorage := AStorage AS IRunDataStorage;
end;

function TRunDataService.AddRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData): TServiceResult;
begin
  if (Length(ABC)=0) OR (ARunData.SampleNumber <= 0) then
  begin
    Result := seMissingField;
    exit;
  end;
  if fStorage.SaveNewRunData(ABC,AStage,AStageValue,ARunData) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;

function TRunDataService.FindRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; out ARunData: TRunData): TServiceResult;
var
  i:integer;
begin
  if fStorage.RetrieveRunData(ABC, AStage, AStageValue, ASampleNumber, ARunData) = stSuccess then
  begin
    Result := seSuccess
  end
  else
    Result := seNotFound;
end;

function TRunDataService.FindRunDatas(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue;const Summary:boolean; out ARunDatas: TRunDataCollection): TServiceResult;
begin
  if fStorage.RetrieveRunDatas(ABC, AStage, AStageValue, Summary, ARunDatas) = stSuccess then
  begin

    Result := seSuccess
  end
  else
    Result := seNotFound;
end;

function TRunDataService.UpdateRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const FieldData:Variant): TServiceResult;
var
  Valid        : boolean;
  LocalRunData : TRunData;
  FieldNames   : RawUTF8;
begin
  Result := sePersistenceError;

  if (TDocVariantData(FieldData).Count=0) then exit;

  Valid := false;

  LocalRunData := TRunData.Create(nil);
  try
    Valid := DocVariantToObject(_Safe(FieldData)^,LocalRunData);
    if Valid then
    begin
      FieldNames:=RawUtf8ArrayToCsv(TDocVariantData(FieldData).GetNames);
      if fStorage.UpdateRunData(ABC, AStage, AStageValue, FieldNames, LocalRunData) = stSuccess then
        Result := seSuccess
      else
        Result := sePersistenceError;
    end;
  finally
    LocalRunData.Free;
  end;
end;

function TRunDataService.DeleteRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer): TServiceResult;
begin
  if fStorage.DeleteRunData(ABC,AStage,AStageValue,ASampleNumber) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;

function TRunDataService.ChangedRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; const aVersion:Int64; out Changed:boolean): TServiceResult;
begin
  if fStorage.ChangedRunData(ABC,AStage,AStageValue,ASampleNumber,aVersion,Changed) = stSuccess then
    Result := seSuccess
  else
    Result := sePersistenceError;
end;

end.
