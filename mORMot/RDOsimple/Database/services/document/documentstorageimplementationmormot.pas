unit documentstorageimplementationmormot;

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

  mormot.rest.sqlite3,
  mormot.db.raw.sqlite3.static,

  servicesshared,  
  documentdom,
  documentinfra,
  documentstorageinterface;

type
  TDocumentStoragemORMot = class(TInterfacedObject, IDocumentStorage)
  strict private
    fRestServerDB : TRestServerDB;
    fRestOrm      : TRestOrm;
    fMap          : TRttiMap;
  protected
    procedure CopyDTOtoORM(const ADocument: TDocument; var OrmDocument: TOrmDocument);
    procedure CopyORMtoDTO(const OrmDocument: TOrmDocument; var ADocument: TDocument);
    function GetDocument(const AHash: string): TOrmDocument;
  public
    constructor Create(ARestOrm:TRestOrm=nil);
    destructor Destroy;override;
    function RetrieveDocument(const AHash: RawUTF8; var ADocument: TDocument): TStorageResult;
    function RetrieveDocumentThumb(var ADocument: TDocument): TStorageResult;
    function SaveDocument(const ADocument: TDocument): TStorageResult;
  end;

implementation

uses
  mormot.db.core,
  mormot.core.buffers,
  mormot.core.json,
  mormot.core.text;

{
****************************** TDocumentStoragemORMot *******************************
}

constructor TDocumentStoragemORMot.Create(ARestOrm:TRestOrm);
begin
  if ARestOrm=nil then
  begin
    // Create the server connected to the SQLite database for documents
    fRestServerDB:=TRestServerDB.Create(TOrmModel.Create([TOrmDocument]), DOCUMENT_DATABASE_FILENAME);
    fRestServerDB.Model.Owner:=fRestServerDB;
    fRestServerDB.Server.CreateMissingTables;
    fRestServerDB.CreateSqlMultiIndex(TOrmDocument,['Hash'],true);

    fRestOrm:=fRestServerDB.OrmInstance;
  end
  else
  begin
    fRestOrm:=ARestOrm;
    fRestServerDB:=nil;
  end;

  inherited Create;

  TOrmDocument.AddFilterNotVoidText(['ProductCode']);

  // Mapping of fields for easy copying.
  fMap.Init(TOrmDocument, TDocument).AutoMap;
end;

destructor TDocumentStoragemORMot.Destroy;
begin
  if Assigned(fRestServerDB) then fRestServerDB.Destroy;
  fRestServerDB:=nil;
  inherited Destroy;
end;

procedure TDocumentStoragemORMot.CopyDTOtoORM(const ADocument: TDocument; var OrmDocument: TOrmDocument);
begin
  fMap.ToA(OrmDocument,ADocument);
end;

procedure TDocumentStoragemORMot.CopyORMtoDTO(const OrmDocument: TOrmDocument; var ADocument: TDocument);
begin
  fMap.ToB(OrmDocument,ADocument);
end;

function TDocumentStoragemORMot.GetDocument(const AHash: string): TOrmDocument;
begin
  Result := TOrmDocument.Create(fRestOrm,'Hash=?',[AHash]);
end;

function TDocumentStoragemORMot.RetrieveDocument(const AHash: RawUTF8; var ADocument: TDocument): TStorageResult;
var
  OrmDocument:TOrmDocument;
begin
  Result:=stNotFound;
  OrmDocument:=GetDocument(AHash);
  try
    if OrmDocument.IDValue = 0 then exit;
    fRestOrm.RetrieveBlobFields(OrmDocument);
    CopyORMtoDTO(OrmDocument,ADocument);
    Result := TStorageResult.stSuccess;
  finally
    OrmDocument.Free;
  end;
end;

function TDocumentStoragemORMot.RetrieveDocumentThumb(var ADocument: TDocument): TStorageResult;
var
  JSON : RawUTF8;
begin
  Result := stNotFound;
  JSON:=FRestOrm.OneFieldValue(TOrmDocument,'FileThumb','Hash = ?',[ADocument.Hash]);
  if Length(JSON)>0 then
  begin
    ADocument.SetThumb(BlobToRawBlob(pointer(JSON)));
    Result := stSuccess;
  end;
end;

function TDocumentStoragemORMot.SaveDocument(const ADocument: TDocument): TStorageResult;
var
  OrmDocument:TOrmDocument;
begin
  Result := TStorageResult.stWriteFailure;

  OrmDocument := GetDocument(ADocument.Path);
  try
    CopyDTOtoORM(ADocument,OrmDocument);
    if fRestOrm.AddWithBlobs(OrmDocument) > 0 then
      Result := TStorageResult.stSuccess;
  finally
    OrmDocument.Free;
  end;
end;

end.
