unit documentstorageinterface;

interface

{$I mormot.defines.inc}

uses
  mormot.core.base,
  mormot.core.interfaces,
  servicesshared,  
  documentdom;

type
  IDocumentStorage = interface(IInvokable)
    ['{1060E7FB-5605-4592-BD25-690093607C09}']
    function RetrieveDocument(const AHash: RawUTF8; var ADocument: TDocument): TStorageResult;
    function RetrieveDocumentThumb(var ADocument: TDocument): TStorageResult;
    function SaveDocument(const ADocument: TDocument): TStorageResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IDocumentStorage)
    ]);

end.
