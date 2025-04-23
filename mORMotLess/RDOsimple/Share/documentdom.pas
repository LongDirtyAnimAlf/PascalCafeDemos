unit documentdom;

{$mode Delphi}{$H+}

interface

uses
  Classes,
  servicesshared;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type
  TDocumentTarget = (dtUnknown,dtProductFront,dtProductBack,dtPackageFront,dtPackageBack,dtDetail1,dtDetail2,dtDetail3,dtDetail4);

  TDocument = class(TCollectionItem)
  private
    fProductCode       : RawUTF8;
    fHash              : RawUTF8;
    fName              : RawUTF8;
    fPath              : RawUTF8;
    fSize              : integer;
    fFileThumb         : TBlobber;
    fFileContents      : TBlobber;
  public
    procedure Assign(Source: TPersistent); override;
    procedure SetPath(aValue:RawUTF8;SetFileContents:boolean=false);
    procedure SetThumb(aValue:TBlobber);
  published
    property ProductCode  : RawUTF8 read fProductCode write fProductCode;
    property Hash         : RawUTF8 read fHash write fHash;
    property Name         : RawUTF8 read fName write fName;
    property Path         : RawUTF8 read fPath write fPath;
    property Size         : integer read fSize write fSize;
    property FileThumb    : TBlobber read fFileThumb write fFileThumb;
    property FileContents : TBlobber read fFileContents write fFileContents;
  end;

  TDocumentCollection = class(TCollection)
  strict private
    function GetItem(Index: integer): TDocument;
  public
    constructor Create;overload;
    function Add: TDocument;
    function AddOrUpdate(const AHash:RawUTF8; const AddIfNotFound:boolean; out aDocument:TDocument): boolean;
    property Item[Index: integer]: TDocument read GetItem;
  end;

  function GetPictureTargetFromName(aName:string):TDocumentTarget;
  function GetNameFromPictureTarget(aTarget:TDocumentTarget):string;

var
  DOCUMENTTARGET2TXT : array[TDocumentTarget] of RawUTF8;
  DOCUMENTTARGET2TXTUNCAMEL : array[TDocumentTarget] of RawUTF8;


implementation

uses
  SysUtils,
  FPimage,
  FPReadBMP, FPReadJPEG, FPReadPNG, FPReadGif, FPReadTiff,
  FPWriteBMP,FPThumbResize;

function GetPictureTargetFromName(aName:string):TDocumentTarget;
begin
  result:=TDocumentTarget.dtUnknown;
  if aName='FrontImage' then result:=TDocumentTarget.dtProductFront;
  if aName='BackImage' then result:=TDocumentTarget.dtProductBack;
  if aName='DetailImage1' then result:=TDocumentTarget.dtDetail1;
  if aName='DetailImage2' then result:=TDocumentTarget.dtDetail2;
  if aName='DetailImage3' then result:=TDocumentTarget.dtDetail3;
  if aName='DetailImage4' then result:=TDocumentTarget.dtDetail4;
end;

function GetNameFromPictureTarget(aTarget:TDocumentTarget):string;
begin
  case aTarget of
    TDocumentTarget.dtUnknown:result:='';
    TDocumentTarget.dtProductFront:result:='FrontImage';
    TDocumentTarget.dtProductBack:result:='BackImage';
    TDocumentTarget.dtDetail1:result:='DetailImage1';
    TDocumentTarget.dtDetail2:result:='DetailImage2';
    TDocumentTarget.dtDetail3:result:='DetailImage3';
    TDocumentTarget.dtDetail4:result:='DetailImage4';
  end;
end;

function DocumentFileNameSort(const A,B): integer;
begin
  result := SysUtils.StrComp(PChar(pointer(TDocument(A).Name)),PChar(pointer(TDocument(B).Name)));
end;

function DocumentHashSort(const A,B): integer;
begin
  result := SysUtils.StrComp(PChar(pointer(TDocument(A).Hash)),PChar(pointer(TDocument(B).Hash)));
end;

function DocumentPathSort(const A,B): integer;
begin
  result := SysUtils.StrComp(PChar(pointer(TDocument(A).Path)),PChar(pointer(TDocument(B).Path)));
  {
  if result=0
     then result:=(TDocument(A).Size-TDocument(B).Size);
  }
end;

function GetReader(const FileName: string): TFPCustomImageReader;
var
  ext, TypeName, X: string;
  ReaderClass: TFPCustomImageReaderClass;
  I: Integer;
begin
  Result := nil;
  ReaderClass := nil;
  ext := LowerCase(ExtractFileExt(filename));
  if ext = '' then Exit;
  if ext[1] = '.' then
    Delete(ext, 1, 1);
  ext := ext + ';';
  for I := 0 to ImageHandlers.Count - 1 do
  begin
    TypeName := ImageHandlers.TypeNames[I];
    X := ImageHandlers.Extensions[TypeName];
    if (pos(ext, X + ';') <> 0) then
    begin
      ReaderClass := ImageHandlers.ImageReader[TypeName];
      Break;
    end;
  end;
  if Assigned(ReaderClass) then
    Result := ReaderClass.Create;
end;

procedure TDocument.Assign(Source: TPersistent);
begin
  If Assigned(Source) then
  begin
    fProductCode       := TDocument(Source).ProductCode;
    fHash              := TDocument(Source).Hash;
    fName              := TDocument(Source).Name;
    fPath              := TDocument(Source).Path;
    fSize              := TDocument(Source).Size;
    fFileThumb         := TDocument(Source).FileThumb;
    fFileContents      := TDocument(Source).FileContents;
  end;
end;

procedure TDocument.SetPath(aValue:RawUTF8;SetFileContents:boolean);
var
  Pic:TMemoryStream;
  Reader: TFPCustomImageReader;
  WriterBMP: TFPWriterBMP;
  Image, DestImage: TFPMemoryImage;
  AWidth, AHeight: word;
  area: TRect;
begin
  fPath:=aValue;
  fName:=ExtractFileName(fPath);

  if (NOT SetFileContents) then exit;

  if Length(fPath)=0 then exit;
  if (NOT FileExists(fPath)) then exit;

  Pic:=TMemoryStream.Create;

  try
    Pic.Clear;

    Pic.LoadFromFile(fPath);
    Pic.Position:=0;

    fSize:=Pic.Size;
    SetCodePage(fFileContents,CP_NONE,true);
    SetLength(fFileContents,fSize);
    Pic.ReadBuffer(pointer(fFileContents)^, fSize);

    // get a thumb !!
    Image := TFPMemoryImage.Create(0, 0);
    try
      Image.UsePalette := false;
      Reader := GetReader(fPath);
      try
        if Assigned(Reader) then
        begin
          Image.LoadFromFile(fPath, Reader);
        end
      finally
        Reader.Free;
      end;

      if (Image.Width=0) or (Image.Height=0) then exit;

      // this size is the same as the timage size on the mainform !!
      AWidth := 140;
      AHeight := 180;

      if (Image.Height>AHeight) OR (Image.Width>AWidth) then
      begin
        Pic.Clear;
        // Scale image whilst preserving aspect ratio
        if (Image.Width / Image.Height) > (AWidth / AHeight) then
           AHeight := Round(AWidth / (Image.Width / Image.Height))
        else if (Image.Width / Image.Height) < (AWidth / AHeight) then
           AWidth := Round(AHeight * (Image.Width / Image.Height));
        DestImage := ThumbResize(Image, AWidth, AHeight, area);
        try
          WriterBMP := TFPWriterBMP.Create;
          try
            DestImage.SaveToStream(Pic, WriterBMP);
          finally
            WriterBMP.Free;
          end;
        finally
          DestImage.free;
        end;
      end;
      Pic.Position:=0;
      SetCodePage(fFileThumb,CP_NONE,true);
      SetLength(fFileThumb,Pic.Size);
      Pic.ReadBuffer(pointer(fFileThumb)^, Pic.Size);
    finally
      FreeAndNil(Image);
    end;
  finally
    FreeAndNil(Pic);
  end;
end;

procedure TDocument.SetThumb(aValue:TBlobber);
begin
  fFileThumb:=aValue;
end;

constructor TDocumentCollection.Create;
begin
  inherited Create(TDocument);
end;

function TDocumentCollection.GetItem(Index: integer): TDocument;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TDocument;
end;

function TDocumentCollection.Add: TDocument;
begin
  Result := inherited Add as TDocument;
end;

function TDocumentCollection.AddOrUpdate(const AHash:RawUTF8; const AddIfNotFound:boolean; out aDocument:TDocument): boolean;
var
  DocumentRunner:TDocument;
begin
  result:=true;
  aDocument:=nil;
  for TCollectionItem(DocumentRunner) in Self do
  begin
    if (DocumentRunner.Hash=AHash) then
    begin
      aDocument:=DocumentRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(aDocument) then if AddIfNotFound then
  begin
    aDocument := Add;
    aDocument.Hash:=AHash;
  end;
end;


end.

