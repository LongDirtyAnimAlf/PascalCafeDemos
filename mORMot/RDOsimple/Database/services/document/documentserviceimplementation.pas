unit documentserviceimplementation;

interface

{$I mormot.defines.inc}

uses
  mormot.core.base,
  mormot.soa.server,
  documentdom,
  servicesshared,  
  documentserviceinterface,
  documentstorageinterface;

type
  TDocumentService = class(TInjectableObjectRest, IDocumentService)
  private
    fStorage: IDocumentStorage;
  public
    constructor Create(AStorage: IInvokable); reintroduce;
    function AddDocument(const ADocument: TDocument): TServiceResult;
    function FindDocument(const AHash: RawUTF8; var ADocument:TDocument): TServiceResult;
    function GetDocumentThumb(var ADocument: TDocument): TServiceResult;
  end;

implementation

{
******************************** TBatteryService ********************************
}
constructor TDocumentService.Create(AStorage: IInvokable);
begin
  inherited Create;
  fStorage := AStorage AS IDocumentStorage;
end;

function TDocumentService.AddDocument(const ADocument: TDocument): TServiceResult;
begin
  if (ADocument.Path = '') then
  begin
    Result := TServiceResult.seMissingField;
    exit;
  end;
  if fStorage.SaveDocument(ADocument) = TStorageResult.stSuccess then
    Result := TServiceResult.seSuccess
  else
    Result := TServiceResult.sePersistenceError;
end;

function TDocumentService.FindDocument(const AHash: RawUTF8; var ADocument:TDocument): TServiceResult;
begin
  result:=TServiceResult.seNotFound;
  if fStorage.RetrieveDocument(AHash,ADocument) = TStorageResult.stSuccess then
    Result := TServiceResult.seSuccess
  else
    Result := TServiceResult.seNotFound;
end;

function TDocumentService.GetDocumentThumb(var ADocument: TDocument): TServiceResult;
begin
  if fStorage.RetrieveDocumentThumb(ADocument) = stSuccess then
    Result := seSuccess
  else
    Result := seNotFound;
end;

end.
