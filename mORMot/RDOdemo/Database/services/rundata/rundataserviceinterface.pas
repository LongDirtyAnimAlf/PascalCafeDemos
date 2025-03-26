unit rundataserviceinterface;

interface

{$I mormot.defines.inc}

uses
  mormot.core.interfaces,
  servicesshared,  
  rundatainfra, // only needed for initialization (registration) of the collections.
  rundatadom;

type
  IRundataService = interface(IInvokable)
    ['{CC2EFD74-4086-4AA6-8707-07C6C09C89EA}']
    function AddRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ARunData: TRunData): TServiceResult;
    function FindRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; out ARunData: TRunData): TServiceResult;
    function FindRunDatas(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue;const Summary:boolean; out ARunDatas: TRunDataCollection): TServiceResult;
    function UpdateRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const FieldData:Variant): TServiceResult;
    function DeleteRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer): TServiceResult;
    function ChangedRunData(const ABC: RawUTF8; const AStage:TStageMode; const AStageValue:TSetValue; const ASampleNumber:integer; const aVersion:Int64; out Changed:boolean): TServiceResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IRunDataService)
    ]);

end.
