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
    fProductCode       : RawUTF8;
    fBrand             : RawUTF8;
    fModel             : RawUTF8;
    fDocuments         : TProductDocumentCollection;
    fThumb             : TBlobber;
    fVersion           : Int64;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Init;
    property Code              : RawUTF8 read fProductCode;
  published
    property ProductCode       : RawUTF8 read fProductCode write fProductCode;
    property Brand             : RawUTF8 read fBrand write fBrand;
    property Model             : RawUTF8 read fModel write fModel;
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
    function GetProductData(ProductIndex:integer):TProduct;
    function Add: TProduct;
    function AddOrUpdate(const ABC:RawUTF8; const AddIfNotFound:boolean; out aBattery:TProduct): boolean;
  end;

  function CompareProductCode(const a, b: TCollectionItem): Integer;
  function CompareProductName(const a, b: TCollectionItem): Integer;

implementation

uses
  SysUtils,
  md5;

function CompareProductCode(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TProduct)) or (not (b is TProduct)) then
    raise Exception.Create('Invalid TProduct reference.');
  result:=SysUtils.StrComp(PChar(pointer(TProduct(a).ProductCode)),PChar(pointer(TProduct(b).ProductCode)));
 end;

function CompareProductName(const a, b: TCollectionItem): Integer;
begin
  if (a = nil) or (b = nil) or (not (a is TProduct)) or (not (b is TProduct)) then
    raise Exception.Create('Invalid TProduct reference.');
  result:=SysUtils.StrComp(PChar(pointer(TProduct(a).Brand)),PChar(pointer(TProduct(b).Brand)));
  if result=0 then
    result:=SysUtils.StrComp(PChar(pointer(TProduct(a).Model)),PChar(pointer(TProduct(b).Model)));
end;

{ TProductDocument }

function TProductDocument.GetHash:ansistring;
var
  FS:int64;
  MD5Hash: TMD5Digest;
begin
  FS:=GetTickCount64;
  MD5Hash := MD5String(Format('%s'#1'%d'#2,[fPath,FS]));
  result := MD5Print(MD5Hash);
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
  ProductCode            := 'Undefined';
  Brand            := '';
  Model            := '';
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

function TProductCollection.GetProductData(ProductIndex:integer):TProduct;
begin
  result:=nil;
  if ((ProductIndex<=Count) AND (ProductIndex>0)) then
  begin
    result:=Item[ProductIndex-1];
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
    if (BatteryRunner.ProductCode=ABC) then
    begin
      aBattery:=BatteryRunner;
      result:=false;
      break;
    end;
  end;
  if NOT Assigned(aBattery) then if AddIfNotFound then
  begin
    aBattery := Add;
    aBattery.ProductCode:=ABC;
  end;
end;

initialization
  //Rtti.RegisterClass(TBatteryDetails);
  //Rtti.RegisterClass(TBatteryWarnings);
  //Rtti.RegisterClass(TBatteryDisposal);
  //Rtti.RegisterClass(TBatteryRechargeable);

end.

