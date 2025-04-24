unit servicesshared;

interface

const
  HTTP_PORT = '11111';
  HTTP_URL = '192.168.2.12';  
  EXAMPLE_CONTRACT = 'MyContractName';
  BATTERY_DATABASE_FILENAME = 'hallo1.db3';
  DOCUMENT_DATABASE_FILENAME = 'docs.db3';
  SECRET_KEY = 'secretjwtkey'; // Shared JWT secret known by both client and server

type
  RawUtf8 = System.UTF8String; // CP_UTF8 Codepage
  //RawUtf8 = mormot.core.base.RawUtf8;

  TBlobber = type RawByteString;
  //TBlobber = mormot.core.base.RawBlob;

  TServiceResult = (
    seSuccess, seNotFound, seMissingField, sePersistenceError);

  TStorageResult = (
    stSuccess, stNotFound, stWriteFailure);

implementation

end.
