unit documentstorageimplementationdisk;

interface

{$I mormot.defines.inc}

uses
  Classes,
  SysUtils,
  mormot.core.base,
  servicesshared,
  documentdom,
  documentinfra,
  documentstorageinterface;

type
  TDocumentStorageDisk = class(TInterfacedObject, IDocumentStorage)
  private
    fStorageDirectory:RawUTF8;
  public
    constructor Create(aDir:RawUTF8='DocStore');
    destructor Destroy;override;
    function RetrieveDocument(const AHash: RawUTF8; var ADocument: TDocument): TStorageResult;
    function RetrieveDocumentThumb(var ADocument: TDocument): TStorageResult;
    function SaveDocument(const ADocument: TDocument): TStorageResult;
  end;

implementation

{
****************************** TDocumentStorageDisk *******************************
}

uses
  Tools; // for CopyFile

const
  EXTENSION = '.str';

constructor TDocumentStorageDisk.Create(aDir:RawUTF8);
begin
  inherited Create;
  fStorageDirectory:=ExpandFilename(aDir);
  ForceDirectories(fStorageDirectory)
end;

destructor TDocumentStorageDisk.Destroy;
begin
  inherited Destroy;
end;

function TDocumentStorageDisk.RetrieveDocument(const AHash: RawUTF8; var ADocument: TDocument): TStorageResult;
var
  aFile:string;
begin
  Result:=stNotFound;
  try
    aFile:=IncludeTrailingPathDelimiter(fStorageDirectory)+AHash+EXTENSION;
    if SysUtils.FileExists(aFile) then
    begin
      // Retrieve the file
      ADocument.SetPath(aFile,true);
      Result := TStorageResult.stSuccess;
    end;
  finally
  end;
end;

function TDocumentStorageDisk.RetrieveDocumentThumb(var ADocument: TDocument): TStorageResult;
begin
  Result:=stNotFound;
end;

function TDocumentStorageDisk.SaveDocument(const ADocument: TDocument): TStorageResult;
var
  aFile:string;
begin
  Result := TStorageResult.stWriteFailure;
  aFile:=IncludeTrailingPathDelimiter(fStorageDirectory)+ADocument.Hash+EXTENSION;
  if SysUtils.FileExists(aFile) then exit;
  try
    // Store the file on disk with the hash as filename
    if CopyFile(ADocument.Path,aFile) then
    begin
      Result := TStorageResult.stSuccess;
    end;
  finally
  end;
end;

end.
