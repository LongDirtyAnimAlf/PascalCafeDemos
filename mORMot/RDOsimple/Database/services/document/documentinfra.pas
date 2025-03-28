unit documentinfra;

interface

{$I mormot.defines.inc}

uses
  documentdom,
  mormot.core.base,
  mormot.core.rtti,
  mormot.orm.base,
  mormot.orm.core;

type
  TOrmDocument = class(TOrm)
  private
    fProductCode          : RawUTF8;
    fHash                 : RawUTF8;
    fName                 : RawUTF8;
    fPath                 : RawUTF8;
    fSize                 : integer;
    fFileThumb            : RawBlob;
    fFileContents         : RawBlob;
  published
    property ProductCode  : RawUTF8 read fProductCode write fProductCode;
    property Hash         : RawUTF8 read fHash write fHash stored AS_UNIQUE;
    property Name         : RawUTF8 read fName write fName;
    property Path         : RawUTF8 read fPath write fPath;
    property Size         : integer read fSize write fSize;
    property FileThumb    : RawBlob read fFileThumb write fFileThumb;
    property FileContents : RawBlob read fFileContents write fFileContents;
  end;

implementation

initialization
  Rtti.RegisterCollection(TDocumentCollection,TDocument);

end.

