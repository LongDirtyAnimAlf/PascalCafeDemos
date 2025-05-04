unit mainclientgui;

interface

uses
  {$ifdef MSWindows}
  Windows,
  {$endif}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Types,
  Dialogs, StdCtrls, Grids, Menus, ComCtrls, ExtCtrls, Buttons,
  LCLIntf,
  databaseinfra,
  documentdom,
  productdom;

type
  PTPanel = ^TPanel;

  { TProcuctVisual }

  TProductVisual = class(TProduct)
    procedure SetAll(const aValue:TProduct);
    procedure GetAll(const aValue:TProduct);
  end;

  { Define an observer }
  (*
  TMyObserver = class(TInterfacedObject, IFPObserver)
  public
    procedure FPOObservedChanged(ASender: TObject; Operation: TFPObservedOperation; Data: Pointer);
  end;
  *)

  { TForm1 }

  TForm1 = class(TForm)
    btnConnectLocal: TButton;
    btnAddProduct: TButton;
    btnConnectRemote: TButton;
    DetailImage2: TImage;
    DetailImage3: TImage;
    DetailImage4: TImage;
    EditBrand: TEdit;
    EditModel: TEdit;
    EditProductCode: TEdit;
    FrontImage: TImage;
    BackImage: TImage;
    EmptyImage: TImage;
    DetailImage1: TImage;
    grpBaseEdits: TGroupBox;
    ImageList1: TImageList;
    ImageListDocument: TImageList;
    ListViewProductDocs: TListView;
    ProductDrawGrid: TDrawGrid;
    MemoParticularities: TMemo;
    memoRemarks: TMemo;
    miMarkDelete: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    PopupMenu1: TPopupMenu;
    staticRemarks: TStaticText;
    staticDocuments: TStaticText;
    tsDetails: TTabSheet;
    tsAdmin: TTabSheet;
    tsOverview: TTabSheet;
    tsImages: TTabSheet;
    procedure btnAddProductClick(Sender: TObject);
    procedure FieldEditingDone(Sender: TObject);
    procedure ProductDrawGridHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure btnConnectLocalClick({%H-}Sender: TObject);
    procedure btnDeleteTypeClick({%H-}Sender: TObject);
    procedure editKeyPressFloatOnly(Sender: TObject; var Key: char);
    procedure FormCreate({%H-}Sender: TObject);
    procedure FormDestroy({%H-}Sender: TObject);
    procedure FormDropFiles({%H-}Sender: TObject; const FileNames: array of AnsiString);
    procedure RetrieveDocDblClick(Sender: TObject);
    procedure miMarkDeleteClick(Sender: TObject);
  private
    ProductVisual       : TProductVisual;
    DataBusy            : integer;

    procedure ProductGridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
    procedure ProductGridAfterSelection(Sender: TObject; aCol,aRow: Integer);

    procedure OnMouseWheel({%H-}Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    procedure GetDataFromGridRow(Sender: TObject; ARowIndex: Longint);

    procedure ProductGridDrawCell(Sender: TObject; aCol,aRow: Integer; aRect: TRect; aState: TGridDrawState);

    procedure DeleteSelectedProduct;

    procedure RefreshGUI;
  protected
    SelectedProduct:TProduct;
  public
    Products           : TProductCollection;
    SharedmORMotData   : TSharedmORMotDDD;
  end;

var
  Form1: TForm1 = nil;

implementation

{$R *.lfm}

uses
  DateUtils,
  LCLType,
  IniFiles;

const
  INIFILE='basicsettings.ini';

function GetFileImageIndex(filename:string):integer;
var
  S:string;
begin
  Result := 0;
  S:=LowerCase(ExtractFileExt(filename));
  if S='.dat' then Result := 1;
  if S='.txt' then Result := 2;
  if S='.doc' then Result := 3;
  if S='.docx' then Result := 3;
    if S='.xls' then Result := 4;
  if S='.xlsx' then Result := 4;
  if S='.csv' then Result := 4;
  if S='.mdb' then Result := 5;
  if (S='.jpg') OR (S='.jpeg') then Result := 6;
  if (S='.png') OR (S='.gif') OR (S='.bmp') OR (S='.ico') then Result := 7;
  if S='.tif' then Result := 7;
  if S='.tiff' then Result := 7;
  if S='.pdf' then Result := 8;
  if S='.wav' then Result := 9;
  if S='.mp3' then Result := 9;
  if S='.eml' then Result := 10;
  if S='.m4a' then Result := 11;
  if S='.m4p' then Result := 11;
  if S='.mov' then Result := 11;
  if S='.exe' then Result := 12;
  if (S='.zip') OR (S='.rar') OR (S='.tar') then Result := 13;
  if S='.xml' then Result := 14;
end;


{ TProcuctVisual }

procedure TProductVisual.SetAll(const aValue:TProduct);
begin
  Form1.EditProductCode.Text:=AValue.ProductCode;
  Form1.EditBrand.Text:=AValue.Brand;
  Form1.EditModel.Text:=AValue.Model;
end;

procedure TProductVisual.GetAll(const aValue:TProduct);
begin
  //AValue.ProductCode:=Form1.EditProductCode.Text;
  AValue.Brand:=Form1.EditBrand.Text;
  AValue.Model:=Form1.EditModel.Text;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
  Products:=TProductCollection.Create;

  (*
  // Create observer
  MyObserver := TMyObserver.Create;
  // Attach observer to collection (TPersistent handles this)
  Products.FPOAttachObserver(MyObserver);
  *)

  SharedmORMotData := TSharedmORMotDDD.Create;

  SelectedProduct:=nil;

  DataBusy:=integer(false);
  with TIniFile.Create(INIFILE) do
  try
    if ValueExists('General','Maximized') then
    begin
      if ReadBool('General','Maximized',False) then
      begin
        Self.WindowState:=wsMaximized;
      end
      else
      begin
        Self.WindowState:=wsNormal;
        Self.Top := ReadInteger('General','Top',Self.Top);
        Self.Left := ReadInteger('General','Left',Self.Left);
        Self.Width := ReadInteger('General','Width',Self.Width);
        Self.Height := ReadInteger('General','Height',Self.Height);
      end;
    end;
  finally
    Free;
  end;

  ProductDrawGrid.OnDrawCell:=@ProductGridDrawCell;
  ProductDrawGrid.OnSelectCell:=@ProductGridSelectCell;
  ProductDrawGrid.OnAfterSelection:=@ProductGridAfterSelection;

  ProductVisual:=TProductVisual.Create(nil);
  ListViewProductDocs.Clear;

  tsAdmin.TabVisible:=True;
  AllowDropFiles:=True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SharedmORMotData.Free;
  SharedmORMotData:=nil;

  Products.Free;

  ProductVisual.Free;

  with TMemIniFile.Create(INIFILE) do
  try
    if Self.WindowState=wsNormal then
    begin
      WriteInteger('General','Top',Self.Top);
      WriteInteger('General','Left',Self.Left);
      WriteInteger('General','Width',Self.Width);
      WriteInteger('General','Height',Self.Height);
      WriteBool('General','Maximized',False);
    end
    else
    begin
      WriteBool('General','Maximized',True);
    end;
    UpdateFile;
  finally
    Free;
  end;
end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of AnsiString);
var
  locFileName : string;
  c, i        : Integer;
  aItem       : TListItem;
  result      : boolean;
  aImage      : TImage;
  aDropTarget : TControl;
  aTarget     : TDocumentTarget;
  aStream     : TMemoryStream;
  run         : Integer;
  ProductDocument:TProductDocument;
begin
  aDropTarget:=FindControlAtPosition(Mouse.CursorPos, false);
  if NOT Assigned(aDropTarget) then exit;

  c := Length(FileNames);
  if (c > 0) then
  begin
    locFileName := '';
    for i := 0 to c - 1 do
    begin
      if FileExists(FileNames[i]) then
      begin
        locFileName := FileNames[i];
        if (c=1) AND (i=0)  then
        begin

          // Process files dropped on an image
          if aDropTarget.ClassType.InheritsFrom(TImage) { OR aDropTarget.ClassType.InheritsFrom(TPanel)} then
          begin
            aImage:=TImage(aDropTarget);
            aTarget:=GetPictureTargetFromName(aImage.Name);
            SelectedProduct.Documents.AddOrUpdate(aTarget,True,ProductDocument);
            ProductDocument.Path:=locFileName;
            ProductDocument.Target:=aTarget;
            ProductDocument.SetHash;
            result:=SharedmORMotData.AddDocument(ProductDocument);
            if result then
            begin
              // Saving of document successfull
              // So, save the identification data into the selected product
              SharedmORMotData.UpdateProduct(SelectedProduct,'Documents');
              if ProductDocument.Target=TDocumentTarget.dtProductFront then
              begin
                // Update the thumb
                SelectedProduct.Thumb:=ProductDocument.FileThumb;
                SharedmORMotData.UpdateProduct(SelectedProduct,'Thumb');
              end;
              aStream:=TMemoryStream.Create;
              try
                aStream.WriteBuffer(pointer(ProductDocument.FileThumb)^,Length(ProductDocument.FileThumb));
                aStream.Position:=0;
                if aImage.Picture.Bitmap.IsStreamFormatSupported(aStream) then
                begin
                  aStream.Position:=0;
                  aImage.Picture.Bitmap.LoadFromStream(aStream);
                end;
                aImage.Invalidate;
              finally
                aStream.Free;
              end;
            end;
          end;
        end;

        // Process files dropped on the listview
        if (aDropTarget.ClassType.InheritsFrom(TListView)) then
        begin
          if (aDropTarget=ListViewProductDocs) then
          begin
            ProductDocument:=SelectedProduct.Documents.Add;
            ProductDocument.Path:=locFileName;
            ProductDocument.Target:=TDocumentTarget.dtUnknown;
            result:=SharedmORMotData.AddDocument(ProductDocument);
            if result then
            begin
              // Saving of document successfull
              // So, save the identification data into the selected product
              SharedmORMotData.UpdateProduct(SelectedProduct,'Documents');

              // Update the listview
              aItem := TListView(ListViewProductDocs).Items.Add;
              aItem.Caption := ExtractFileName(locFileName);
              aItem.ImageIndex:=GetFileImageIndex(aItem.Caption);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TForm1.RetrieveDocDblClick(Sender: TObject);
var
  ProductDocuments           : TProductDocumentCollection;
  ProductDocument            : TProductDocument;
  Document                   : TDocument;
  doccount                   : integer;
  aFileName,aStoreFileName   : AnsiString;
  aFile                      : string;
  LLV:TListView;
  i,j:integer;
  S:string;
  aSource:TControl;
  aStream:TMemoryStream;
  aImage:TImage;
  aTarget:TDocumentTarget;
begin
  aSource:=TControl(Sender);

  aFileName:='';
  aTarget:=TDocumentTarget.dtUnknown;

  if (aSource=ListViewProductDocs) then
  begin
    LLV:=TListView(aSource);
    if LLV.ItemFocused=nil then exit;
    aFileName:=LLV.ItemFocused.Caption;
    if aFileName='' then exit;
  end;

  if aSource.ClassType.InheritsFrom(TImage) then
  begin
    aImage:=TImage(aSource);
    aTarget:=GetPictureTargetFromName(aImage.Name);
    if (aTarget=TDocumentTarget.dtUnknown) then exit;
  end;

  Document := TDocument.Create(nil);
  try
    for TCollectionItem(ProductDocument) in SelectedProduct.Documents do
    begin
      if (ProductDocument.Name=aFileName) OR ((ProductDocument.Target<>dtUnknown) AND (ProductDocument.Target=aTarget)) then
      begin
        if SharedmORMotData.GetDocument(ProductDocument,Document) then
        begin
          aStoreFileName:=SysUtils.GetTempDir+ProductDocument.Name;
          aStream:=TMemoryStream.Create;
          try
            aStream.WriteBuffer(pointer(Document.FileContents)^,Length(Document.FileContents));
            aStream.Position:=0;
            aStream.SaveToFile(aStoreFileName);
            OpenDocument(aStoreFileName);
          finally
            aStream.Free;
          end;
        end;
        break;
      end;
    end;
  finally
    Document.Free;
  end;

end;

procedure TForm1.miMarkDeleteClick(Sender: TObject);
var
  PopUp:TPopupMenu;
begin
  PopUp:=TPopupMenu(TMenuItem(Sender).GetParentMenu);
  if PopUp.PopupComponent=ProductDrawGrid then DeleteSelectedProduct;
end;

procedure TForm1.btnAddProductClick(Sender: TObject);
var
  LocalProduct : TProduct;
begin
  if Products.AddOrUpdate('NewProduct',true,LocalProduct) then
  begin
    //GetDataFromGridRow(nil,1);
    SharedmORMotData.AddProduct(LocalProduct);
  end;
  RefreshGUI;
end;

procedure TForm1.FieldEditingDone(Sender: TObject);
begin
  if (Sender=EditProductCode) then
  begin
    // Product code is something spcial.
    // It is our main search and lookup field.
    // Must be unique also
    // Changing it requires some special handling
    if SharedmORMotData.UpdateProductCode(SelectedProduct,EditProductCode.Text) then
      SelectedProduct.ProductCode:=EditProductCode.Text;
  end
  else
  begin
    ProductVisual.GetAll(SelectedProduct);
    SharedmORMotData.UpdateProduct(SelectedProduct,'*');
  end;
  RefreshGUI;
end;

procedure TForm1.ProductDrawGridHeaderClick(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
begin
  if IsColumn then
  begin
    ProductDrawGrid.BeginUpdate;
    if Index=0 then Products.Sort(TCollectionSortCompare(@CompareProductCode));
    if Index=1 then Products.Sort(TCollectionSortCompare(@CompareProductName));
    SelectedProduct:=nil;
    ProductDrawGrid.EndUpdate;
    ProductDrawGrid.Invalidate;
    if Products.Count>0 then GetDataFromGridRow(ProductDrawGrid,1);
  end;
end;

procedure TForm1.btnDeleteTypeClick(Sender: TObject);
begin
  if (MessageDlg('Are you sure to delete whole type ?',mtConfirmation,[mbYes, mbNo],0)<>mrYes) then
  begin
    DeleteSelectedProduct;
  end;
end;

procedure TForm1.ProductGridDrawCell(Sender: TObject; aCol,aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  aDrawGrid    : TDrawGrid;
  LocalProduct : TProduct;
  s            : string;
  indexer:integer;
  Found:boolean;
begin
  aDrawGrid:=TDrawGrid(Sender);

  LocalProduct:=nil;
  if Sender=ProductDrawGrid then LocalProduct:=Products.GetProductData(aRow);

  if (aRow>0) then
  begin
    if Assigned(LocalProduct) then
    begin
      if Sender=ProductDrawGrid then
      begin
        if (aRow>Products.Count) then
        begin
          s:='??'
        end
        else
        begin
          case aCol of
            0: s:=LocalProduct.ProductCode;
            1: s:=LocalProduct.Brand;
            2: s:=LocalProduct.Model;
          end;
          InflateRect(ARect, -constCellpadding, -constCellPadding);
          aDrawGrid.Canvas.TextRect(ARect, ARect.Left, ARect.Top, s);
        end;
      end;
    end;
  end;

end;

procedure TForm1.editKeyPressFloatOnly(Sender: TObject; var Key: char);
begin
  //if not (Key in [#8, '0'..'9', DecimalSeparator]) then begin
  if (not CharInSet(Key,[#8, '0'..'9', '-', FormatSettings.DecimalSeparator])) then begin
    //ShowMessage('Invalid key: ' + Key);
    Key := #0;
  end
  else if (Key = FormatSettings.DecimalSeparator) and
          (Pos(Key, (Sender as TEdit).Text) > 0) then begin
    //ShowMessage('Invalid Key: twice ' + Key);
    Key := #0;
  end
  else if (Key = '-') and
          ((Sender as TEdit).SelStart <> 0) then begin
    ShowMessage('Only allowed at beginning of number: ' + Key);
    Key := #0;
  end;
end;

procedure TForm1.btnConnectLocalClick(Sender: TObject);
var
  ServerOk:boolean;
begin
  ServerOk:=SharedmORMotData.Connected;
  if ServerOk then
  begin
    ShowMessage('Already connected !');
    exit;
  end;

  TButton(Sender).Enabled:=False;
  try
    if Sender=btnConnectLocal then SharedmORMotData.ConnectNew({remote:}False,{ownserver:}True);
    if Sender=btnConnectRemote then SharedmORMotData.ConnectNew({remote:}True,{ownserver:}False);

    ServerOk:=SharedmORMotData.Connected;
    if (NOT ServerOk) then
    begin
      ShowMessage('Could not connect with server.');
    end
    else
    begin
      // Get the Products from the database
      SharedmORMotData.GetProductTable(Products);

      // Show them !!
      ProductDrawGrid.RowCount:=Products.Count+1;
      ProductDrawGrid.Show;
      ProductDrawGrid.Invalidate;

      // Select first available sample, if any
      if Products.Count>0 then GetDataFromGridRow(ProductDrawGrid,1);
    end;
  finally
    TButton(Sender).Enabled:=True;
  end;
end;

procedure TForm1.ProductGridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
begin
  GetDataFromGridRow(Sender,aRow);
end;

procedure TForm1.ProductGridAfterSelection(Sender: TObject; aCol, aRow: Integer);
begin
end;

procedure TForm1.OnMouseWheel(Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:=true;
end;

procedure TForm1.DeleteSelectedProduct;
begin
  if Assigned(SelectedProduct) then
  begin
    SharedmORMotData.DeleteProduct(SelectedProduct);
    Products.Delete(SelectedProduct.Index);
    ProductDrawGrid.RowCount:=ProductDrawGrid.RowCount-1;
    RefreshGUI;
  end;
end;

procedure TForm1.GetDataFromGridRow(Sender: TObject; ARowIndex: Longint);
var
  ProductDocument  : TProductDocument;

  aCustomRow       : longint;
  aItem            : TListItem;

  aTarget          : TDocumentTarget;
  i                : integer;
  aImage           : TImage;
  aStream          : TMemoryStream;
  RefreshNeeded    : boolean;
begin
  if ARowIndex=0 then exit;

  if Sender=ProductDrawGrid then
  begin

    SelectedProduct:=Products.GetProductData(ARowIndex);

    if Assigned(SelectedProduct) then
    begin
      // Check for changes.
      if (SharedmORMotData.ChangedProduct(SelectedProduct,RefreshNeeded) AND RefreshNeeded) then
      begin
        // Due to version tracking, we now know that the battery has changed.
        // So, get the new data from the server !!
        SharedmORMotData.GetProduct(SelectedProduct);
      end;

      ProductVisual.SetAll(SelectedProduct);

      ListViewProductDocs.BeginUpdate;
      ListViewProductDocs.Clear;
      if (SelectedProduct.Documents.Count>0) then
      begin
        for TCollectionItem(ProductDocument) in SelectedProduct.Documents do
        begin
          if (ProductDocument.Target<>TDocumentTarget.dtUnknown) then continue;
          aItem := TListView(ListViewProductDocs).Items.Add;
          aItem.Caption := ExtractFileName(ProductDocument.Path);
          aItem.ImageIndex:=GetFileImageIndex(aItem.Caption);
        end;
      end;
      ListViewProductDocs.EndUpdate;
    end;

    // get all the pictures [thumbs]

    aStream := TMemoryStream.Create;

    for i := 0 to ComponentCount - 1 do
    begin
      if (NOT (Components[i] is TControl)) then continue;
      if Components[i] is TImage then
      begin
        aImage:=TImage(Components[i]);
        if aImage=EmptyImage then continue;
        aTarget:=GetPictureTargetFromName(aImage.Name);
        if aTarget=TDocumentTarget.dtUnknown then continue;

        aStream.Clear;
        aImage.Picture.Clear;
        if (aTarget=TDocumentTarget.dtProductFront) then
        begin
          aStream.WriteBuffer(pointer(SelectedProduct.Thumb)^,Length(SelectedProduct.Thumb));
        end;
        if (aStream.Position=0) then
        begin
          for TCollectionItem(ProductDocument) in SelectedProduct.Documents do
          begin
            if ProductDocument.Target=aTarget then
            begin
              if Length(ProductDocument.FileThumb)=0 then
                SharedmORMotData.GetDocumentThumb(ProductDocument);
              aStream.WriteBuffer(pointer(ProductDocument.FileThumb)^,Length(ProductDocument.FileThumb));
            end;
          end;
        end;
        aStream.Position:=0;
        if aImage.Picture.Bitmap.IsStreamFormatSupported(aStream) then
        begin
          aStream.Position:=0;
          aImage.Picture.Bitmap.LoadFromStream(aStream);
        end;

        if aImage.Picture.Bitmap.Empty then aImage.Picture.Assign(EmptyImage.Picture);
        aImage.Invalidate;
      end;
    end;
    aStream.Free;
  end;

  if Assigned(SelectedProduct) then
  begin
    aCustomRow:=0;
    if (Sender=ProductDrawGrid) then aCustomRow:=1;
  end;
end;

procedure TForm1.RefreshGUI;
begin
  SelectedProduct:=nil;
  ProductDrawGrid.RowCount:=Products.Count+1;
  ProductDrawGrid.Invalidate;
  if Products.Count>0 then GetDataFromGridRow(ProductDrawGrid,ProductDrawGrid.Row);
end;

(*
procedure TMyObserver.FPOObservedChanged(ASender: TObject; Operation: TFPObservedOperation; Data: Pointer);
begin
  case Operation of
    ooAddItem:
      Form1.Memo1.Append('Item added');
    ooDeleteItem:
      Form1.Memo1.Append('Item removed');
    ooChange:
      Form1.Memo1.Append('Collection changed');
    ooFree:
      Form1.Memo1.Append('Item free');
    ooCustom:
      Form1.Memo1.Append('Item custom');
  end;
end;
*)

end.

