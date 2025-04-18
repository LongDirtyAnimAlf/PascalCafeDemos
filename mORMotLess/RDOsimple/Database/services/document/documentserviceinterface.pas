unit documentserviceinterface;

interface

{$I mormot.defines.inc}

uses
  mormot.core.base,
  mormot.core.interfaces,
  servicesshared,
  documentinfra, // only needed for initialization (registration) of the collections.
  documentdom;

type
  IDocumentService = interface(IInvokable)
    ['{5F3F7021-814B-43D3-ABF9-818AEFBDA078}']
    function AddDocument(const ADocument: TDocument): TServiceResult;
    function FindDocument(const AHash: RawUTF8; var ADocument:TDocument): TServiceResult;
    function GetDocumentThumb(var ADocument: TDocument): TServiceResult;
  end;

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IDocumentService)
    ]);

end.
