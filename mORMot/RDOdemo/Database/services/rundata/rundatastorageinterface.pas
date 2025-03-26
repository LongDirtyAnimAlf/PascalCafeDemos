unit rundatastorageinterface;

interface

{$I mormot.defines.inc}

uses
  mormot.core.interfaces,
  servicesshared,
  rundatadom;

type
  IRunDataStorage = interface(IInvokable)
    ['{EF6E8B31-8DBF-47F8-BA25-DDD92DA66CAC}']
    function RetrieveRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:TSetValue; out ARunData: TRunData): TStorageResult;
    function RetrieveRunDatas(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue;const Summary:boolean; out ARunDatas: TRunDataCollection): TStorageResult;
    function SaveNewRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData): TStorageResult;
    function UpdateRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const Fieldinfo:RawUTF8; const ARunData: TRunData):TStorageResult;
    function DeleteRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:TSetValue): TStorageResult;
    function ChangedRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; const aVersion:Int64; out Changed:boolean): TStorageResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IRunDataStorage)
    ]);

end.
