unit productdom;

interface

uses
  Classes,
  servicesshared,
  documentdom;

{$ifdef FPC_EXTRECORDRTTI}
  {$rtti explicit fields([vcPublic])} // mantadory :(
{$endif FPC_EXTRECORDRTTI}

type
  TProduct = class;

  TProductDocument = class(TCollectionItem)
  private
    function GetHash:ansistring;
    procedure SetPath(aPath:RawUTF8);
  protected
    fName              : RawUTF8;
    fPath              : RawUTF8;
    fHash              : RawUTF8;
    fTarget            : TDocumentTarget;
    fFileThumb         : TBlobber;
  public
    function GetOwner:TProduct;reintroduce;
    property FileThumb : TBlobber read fFileThumb write fFileThumb;
  published
    property Name      : RawUTF8 read fName;// write fName;
    property Path      : RawUTF8 read fPath write SetPath;
    property Hash      : RawUTF8 read fHash;// write fHash;
    property Target    : TDocumentTarget read fTarget write fTarget;
  end;

  { TProductDocumentCollection }
  TProductDocumentCollection = class(TOwnedCollection)
  strict private
    function GetItem(Index: integer): TProductDocument;
  private
    property Item[Index: integer]: TProductDocument read GetItem;
  public
    constructor Create(AOwner: TPersistent);overload;
    function Add: TProductDocument;
    function AddOrUpdate(const Target: TDocumentTarget; const AddIfNotFound:boolean; out aDocument:TProductDocument): boolean;
  end;

  TProduct = class(TCollectionItem)
  strict private
    fB_code            : RawUTF8;
    fB_name            : RawUTF8;
    fB_type            : RawUTF8;
    fDocuments         : TProductDocumentCollection;
    fThumb             : TBlobber;
    fVersion           : Int64;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Init;
    property Code              : RawUTF8 read fB_code;
  published
    property B_code            : RawUTF8 read fB_code write fB_code;
    property B_name            : RawUTF8 read fB_name write fB_name;
    property B_type            : RawUTF8 read fB_type write fB_type;
    property Documents         : TProductDocumentCollection read fDocuments write fDocuments;
    property Thumb             : TBlobber read fThumb write fThumb;
    property Version           : Int64 read fVersion write fVersion;
  end;

  { TProductCollection }
  TProductCollection = class(TCollection)
  strict private
    function GetItem(Index: integer): TProduct;
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  public
    Compare: TCollectionSortCompare;
    constructor Create;overload;
    property Item[Index: integer]: TProduct read GetItem;
    function GetBatteryData(BatteryIndex:integer):TProduct;
    function Add: TProduct;
    function AddOrUpdate(const ABC:RawUTF8; const AddIfNotFound:boolean; out aBattery:TProduct): boolean;
  end;

  function CompareProductCode(const a, b: TCollectionItem): Integer;
  function CompareProductName(const a, b: TCollectionItem): Integer;

implementation

uses
  SysUtils,
  fpsha256;

function CompareProductCode(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TProduct)) or (not (b is TProduct)) then
    raise Exception.Create('Invalid TProduct reference.');
  result:=SysUtils.StrComp(PChar(pointer(TProduct(a).B_code)),PChar(pointer(TProduct(b).B_code)));
 end;

function CompareProductName(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TProduct)) or (not (b is TProduct)) then
    raise Exception.Create('Invalid TProduct reference.');
  result:=SysUtils.StrComp(PChar(pointer(TProduct(a).B_name)),PChar(pointer(TProduct(b).B_name)));
  if result=0 then
    result:=SysUtils.StrComp(PChar(pointer(TProduct(a).B_type)),PChar(pointer(TProduct(b).B_type)));
end;

{ TProductDocument }

function TProductDocument.GetHash:ansistring;
var
  lSHA256  : fpsha256.TSHA256;
  S        : TBytes;
  FS:int64;
begin
  //FS:=GetFileSize(aPath);
  FS:=GetTickCount64;
  //FS:=Random(High(Int64));

  lSHA256.Init;
  S:=TEncoding.UTF8.GetAnsiBytes(fPath);
  lSHA256.Update(S);
  S:=TEncoding.UTF8.GetAnsiBytes(InttoStr(FS));
  lSHA256.Update(S);
  lSHA256.Final;
  lSHA256.OutputHexa(result);

  //result:= Int64(Hash32(aPath)) or (Int64(UnixTimeUtc) shl 31);
  //result := SHA256(FormatUTF8('%'#1'%'#2,[Hash32(aPath),GetFileSize(aPath)]));
end;

procedure TProductDocument.SetPath(aPath:RawUTF8);
begin
  if fPath<>aPath then
  begin
    fPath:=aPath;
    if Length(fPath)>0 then
    begin
      fName:=ExtractFileName(fPath);
      fHash:=GetHash;
    end;
  end;
end;

function TProductDocument.GetOwner:TProduct;
begin
  result:=nil;
  if Assigned(Collection) then
    result:=TProduct(Collection.Owner);
end;

{ TProductDocumentCollection }

constructor TProductDocumentCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner,TProductDocument);
end;

function TProductDocumentCollection.GetItem(Index: integer): TProductDocument;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TProductDocument;
end;

function TProductDocumentCollection.Add: TProductDocument;
begin
  Result := inherited Add as TProductDocument;
end;

function TProductDocumentCollection.AddOrUpdate(const Target: TDocumentTarget; const AddIfNotFound:boolean; out aDocument:TProductDocument): boolean;
var
  DocumentRunner:TProductDocument;
begin
  result:=true;
  aDocument:=nil;
  for TCollectionItem(DocumentRunner) in Self do
  begin
    if (DocumentRunner.Target=Target) then
    begin
      aDocument:=DocumentRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(aDocument) then if AddIfNotFound then
  begin
    aDocument := Add;
    aDocument.Target:=Target;
  end;
end;

{ TProduct }

constructor TProduct.Create(ACollection: TCollection);
begin
  fDocuments:=TProductDocumentCollection.Create(Self);
  inherited Create(ACollection);
end;

destructor TProduct.Destroy;
begin
  fDocuments.Destroy;
  inherited Destroy;
end;

procedure TProduct.Init;
begin
  B_code            := 'Undefined';
  B_name            := '';
  B_type            := '';
end;

{ TProductCollection }

constructor TProductCollection.Create;
begin
  inherited Create(TProduct);
end;

function TProductCollection.GetItem(Index: integer): TProduct;
begin
  result:=nil;
  if (Index<Count) then
    result := inherited GetItem(Index) as TProduct;
end;

procedure TProductCollection.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited;
end;

function TProductCollection.GetBatteryData(BatteryIndex:integer):TProduct;
begin
  result:=nil;
  if ((BatteryIndex<=Count) AND (BatteryIndex>0)) then
  begin
    result:=Item[BatteryIndex-1];
  end;
end;

function TProductCollection.Add: TProduct;
begin
  Result := inherited Add as TProduct;
end;

function TProductCollection.AddOrUpdate(const ABC:RawUTF8; const AddIfNotFound:boolean; out aBattery:TProduct): boolean;
var
  BatteryRunner:TProduct;
begin
  result:=true;
  aBattery:=nil;
  for TCollectionItem(BatteryRunner) in Self do
  begin
    if (BatteryRunner.B_code=ABC) then
    begin
      aBattery:=BatteryRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(aBattery) then if AddIfNotFound then
  begin
    aBattery := Add;
    aBattery.B_code:=ABC;
  end;
end;

initialization
  //Rtti.RegisterClass(TBatteryDetails);
  //Rtti.RegisterClass(TBatteryWarnings);
  //Rtti.RegisterClass(TBatteryDisposal);
  //Rtti.RegisterClass(TBatteryRechargeable);

end.

