unit mainclientgui;

interface

uses
  {$ifdef MSWindows}
  Windows,
  {$endif}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Types,
  Dialogs, StdCtrls, Grids, Menus, ComCtrls, ExtCtrls, Buttons,
  TAGraph, TASeries,
  LCLIntf, LResources, LMessages, Spin,
  Laz.VirtualTrees,
  databaseinfra,
  documentdom,
  rundatadom,
  productdom;

const
  // Helper message to decouple node change handling from edit handling.
  WM_STARTEDITING = LM_USER + 778;

type
  PTPanel = ^TPanel;

  { TProcuctVisual }

  TProductVisual = class(TProduct)
    procedure SetAll(const aValue:TProduct);
    procedure GetAll(const aValue:TProduct);
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btnConnect: TButton;
    btnExport: TBitBtn;
    btnExport1: TBitBtn;
    btnExport2: TBitBtn;
    btnImport: TBitBtn;
    btnGraphAdd: TBitBtn;
    btnGraphAddAll: TBitBtn;
    btnGraphClear: TBitBtn;
    btnGraphMinMax: TBitBtn;
    btnImportData: TButton;
    btnImportMeasurements: TButton;
    btnDeleteSample: TButton;
    btnDeleteType: TButton;
    btnPrint: TBitBtn;
    Button1: TButton;
    Chart1: TChart;
    chkgrpEndPoints: TCheckGroup;
    chkAutoCreate: TCheckBox;
    chkCreateAppend: TCheckBox;
    chkCreateValidAll: TCheckBox;
    chkValidOnly: TCheckBox;
    DetailImage2: TImage;
    DetailImage3: TImage;
    DetailImage4: TImage;
    editCapacity: TEdit;
    EditDVOverride: TEdit;
    editEnergy: TEdit;
    EditBrand: TEdit;
    EditEAN: TEdit;
    editGraphMinimum: TEdit;
    editGraphMaximum: TEdit;
    EditModel: TEdit;
    EditProductCode: TEdit;
    EditProject: TEdit;
    editSkipMinutes: TEdit;
    editTime: TEdit;
    editVoltage: TEdit;
    FrontImage: TImage;
    BackImage: TImage;
    EmptyImage: TImage;
    DetailImage1: TImage;
    grpOverrides: TGroupBox;
    grpBaseEdits: TGroupBox;
    grpBatterySummaryLabels: TGroupBox;
    ImageList1: TImageList;
    ImageListDocument: TImageList;
    Label1: TLabel;
    LabelDTOverride: TLabel;
    LabelDVOverride: TLabel;
    labelSkipMinutes: TLabel;
    ListBox1: TListBox;
    ListViewProductDocs: TListView;
    ProductDrawGrid: TDrawGrid;
    BatteryDataDrawGrid: TDrawGrid;
    RunDataOverviewDrawGrid: TDrawGrid;
    AdminMemo: TMemo;
    MemoParticularities: TMemo;
    memoRemarks: TMemo;
    nodeDeleteData: TMenuItem;
    miMarkDelete: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pcBattery: TPageControl;
    PopupMenu1: TPopupMenu;
    spinStartSampleNumber: TSpinEdit;
    VST5PopupMenu: TPopupMenu;
    staticRemarks: TStaticText;
    staticDocuments: TStaticText;
    TreeImages1: TImageList;
    tsBatteryTable: TTabSheet;
    tsSampleTable: TTabSheet;
    tsDetails: TTabSheet;
    tsAdmin: TTabSheet;
    tsOverview: TTabSheet;
    tsImages: TTabSheet;
    VST5: TLazVirtualStringTree;
    procedure ProductDrawGridHeaderClick(Sender: TObject; IsColumn: Boolean;
      Index: Integer);
    procedure btnConnectClick({%H-}Sender: TObject);
    procedure btnDeleteSampleClick(Sender: TObject);
    procedure btnDeleteTypeClick({%H-}Sender: TObject);
    procedure btnExport1Click(Sender: TObject);
    procedure btnExport2Click(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnGraphAddAllClick(Sender: TObject);
    procedure btnGraphAddClick(Sender: TObject);
    procedure btnGraphClearClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnImportMeasurementsClick({%H-}Sender: TObject);
    procedure btnImportDataClick({%H-}Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure editKeyPressFloatOnly(Sender: TObject; var Key: char);
    procedure editVoltageDblClick({%H-}Sender: TObject);
    procedure FormCreate({%H-}Sender: TObject);
    procedure FormDestroy({%H-}Sender: TObject);
    procedure FormDropFiles({%H-}Sender: TObject; const FileNames: array of AnsiString);
    procedure RetrieveDocDblClick(Sender: TObject);
    procedure miMarkDeleteClick(Sender: TObject);
    procedure VST5Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VST5CreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure VST5DrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; const CellText: AnsiString;
      const CellRect: TRect; var DefaultDraw: Boolean);
    procedure VST5Edited(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure VST5Editing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure VST5GetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: AnsiString);
    procedure VST5GetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer);
    procedure VST5GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: AnsiString);
    procedure VST5InitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure VST5InitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure VST5MeasureItem(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
      Node: PVirtualNode; var NodeHeight: Integer);
    procedure VST5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VST5NodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure VST5PaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure VST5StateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
  private
    ProductVisual       : TProductVisual;
    DataBusy            : integer;
    procedure AddAllGraphs;
    procedure AddGraphs(aSampleNumber:integer;{$H-}validonly:boolean);
    procedure ClearGraph;

    procedure ConnectWithServer;

    procedure BatteryGridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
    procedure BatteryGridAfterSelection(Sender: TObject; aCol,aRow: Integer);

    procedure OnMouseWheel({%H-}Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

    procedure WMStartEditing(var Message: TLMessage); message WM_STARTEDITING;

    procedure GetDataFromGridRow(Sender: TObject; ARowIndex: Longint);
    function  GetRunDataFromGridRow(const Battery:TProduct; const aRow:longint; out aTestData:TTestData;out aRunData:TRundata):boolean;

    procedure SearchText(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);

    procedure BatteryGridDrawCell(Sender: TObject; aCol,aRow: Integer; aRect: TRect; aState: TGridDrawState);
    procedure BatteryOverviewDrawGridCheckBoxState(Sender: TObject; aCol, aRow: Integer; var aState: TCheckboxState);
    procedure BatteryOverviewDrawGridCheckBoxToggle(Sender: TObject; aCol, aRow: Integer; aState: TCheckboxState);


    procedure DeleteSelectedBattery;
    procedure DeleteSelectedRunData;

    procedure ImportProductData(aFile:string);

    procedure ImportProductRunData(aFile:string;OverrideDischargeType:TStageMode=TStageMode.smUnknown;OverrideDischargeValue:TSetValue=0;OverrideSampleNumber:integer=0);overload;
    procedure ImportProductRunData(DataFile:TStringList;OverrideDischargeType:TStageMode=TStageMode.smUnknown;OverrideDischargeValue:TSetValue=0;OverrideSampleNumber:integer=0);overload;

    procedure RefreshGUI;
  protected
    SelectedProduct:TProduct;
    SelectedTestData:TTestData;
    SelectedRunData:TRunData;
    procedure ExportAllData(aProductCode:string);
    procedure ExportRawData(aProductCode:string);
  public
    Products           : TProductCollection;
    SharedmORMotData   : TSharedmORMotDDD;
  end;

var
  Form1: TForm1 = nil;

implementation

{$R *.lfm}

uses
  StrUtils,
  DateUtils,
  Tools,
  Math,
  LCLType,
  TACustomSource,
  IniFiles,
  Themes,
  //TmSchema,
  editors,
  mormot.core.rtti;

const
  DefaultDelimiter = ';';

  INIFILE='basicsettings.ini';

  EndpointChoices: array[0..3] of integer = (
    1200,
    1100,
    1000,
    900
  );

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
  Form1.EditProductCode.Text:=AValue.B_code;
  Form1.EditBrand.Text:=AValue.B_name;
  Form1.EditModel.Text:=AValue.B_type;
  //Form1.EditEAN.Text:=AValue.EAN;
  //Form1.EditProject.Text:=AValue.ProjectNumber;
end;

procedure TProductVisual.GetAll(const aValue:TProduct);
begin
  AValue.B_code:=Form1.EditProductCode.Text;
  AValue.B_name:=Form1.EditBrand.Text;
  AValue.B_type:=Form1.EditModel.Text;
  //AValue.EAN:=Form1.EditEAN.Text;
  //AValue.ProjectNumber:=Form1.EditProject.Text;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  dt:TStageMode;
  i:integer;
begin
  Products:=TProductCollection.Create;
  SharedmORMotData := TSharedmORMotDDD.Create;

  SelectedProduct:=nil;
  SelectedTestData:=nil;
  SelectedRunData:=nil;

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

  ProductDrawGrid.OnDrawCell:=@BatteryGridDrawCell;
  ProductDrawGrid.OnSelectCell:=@BatteryGridSelectCell;
  ProductDrawGrid.OnAfterSelection:=@BatteryGridAfterSelection;

  RunDataOverviewDrawGrid.OnDrawCell:=@BatteryGridDrawCell;
  RunDataOverviewDrawGrid.OnSelectCell:=@BatteryGridSelectCell;
  RunDataOverviewDrawGrid.OnAfterSelection:=@BatteryGridAfterSelection;
  RunDataOverviewDrawGrid.OnGetCheckboxState:=@BatteryOverviewDrawGridCheckBoxState;
  RunDataOverviewDrawGrid.OnCheckboxToggled:=@BatteryOverviewDrawGridCheckBoxToggle;


  // Always tell the tree how much data space per node it must allocated for us. We can do this here, in the
  // object inspector or in the OnGetNodeDataSize event.
  VST5.RootNodeCount:=4;
  VST5.NodeDataSize := SizeOf(TPropertyData);
  //VST5.Header.AutoFitColumns(True,smaUseColumnOption,1);
  VST5.Header.Columns[0].MinWidth:=150;
  VST5.Header.Columns[0].MaxWidth:=300;

  ProductVisual:=TProductVisual.Create(nil);
  ListViewProductDocs.Clear;

  //comboChemistry.Items.AddStrings(ChemistryTypeText);
  //comboIEC.Items.AddStrings(IECCodeText);

  //intern:=TRawUTF8Interning.Create;

  tsAdmin.TabVisible:=True;
  Self.AllowDropFiles:=True;

  editGraphMinimum.Text:='0'+FormatSettings.DecimalSeparator+'8';
  editGraphMaximum.Text:='1'+FormatSettings.DecimalSeparator+'6';

  Chart1.LeftAxis.Range.Max:=1.6;
  Chart1.LeftAxis.Range.Min:=0.8;

  Chart1.LeftAxis.Range.UseMax:=True;
  Chart1.LeftAxis.Range.UseMin:=True;

  Chart1.LeftAxis.Intervals.NiceSteps:='0.1';
  Chart1.LeftAxis.Intervals.Options:=[aipGraphCoords,aipUseNiceSteps];

  Chart1.BottomAxis.Range.Min:=0;
  Chart1.BottomAxis.Range.UseMin:=True;

  //Chart1.BottomAxis.Intervals.NiceSteps:='100';
  //Chart1.BottomAxis.Intervals.Options:=Chart1.BottomAxis.Intervals.Options+[aipGraphCoords,aipUseNiceSteps];
  //Chart1.BottomAxis.Intervals.Options:=Chart1.BottomAxis.Intervals.Options+[aipUseNiceSteps];

  for dt in TStageMode do
  begin
    if dt=TStageMode.smUnknown then continue;
    ListBox1.Items.Append(ModeIdentifier[dt]);
  end;


  for i in EndpointChoices do
  begin
    chkgrpEndPoints.Items.Add(InttoStr(i)+'mV');
    // Set 1000mV by default
    if i=1000 then chkgrpEndPoints.Checked[chkgrpEndPoints.Items.Count-1]:=true;
  end;

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
  //intern.Free;
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
  if PopUp.PopupComponent=ProductDrawGrid then DeleteSelectedBattery;
  if PopUp.PopupComponent=RunDataOverviewDrawGrid then DeleteSelectedRunData;
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
    SelectedTestData:=nil;
    SelectedRunData:=nil;
    ProductDrawGrid.EndUpdate;
    ProductDrawGrid.Invalidate;
    if Products.Count>0 then GetDataFromGridRow(ProductDrawGrid,1);
  end;
end;

procedure TForm1.btnDeleteSampleClick(Sender: TObject);
begin
  if (MessageDlg('Are you sure to delete the measurement data ?',mtConfirmation,[mbYes, mbNo],0)<>mrYes) then
  begin
    DeleteSelectedRunData;
  end;
end;

procedure TForm1.BatteryGridAfterSelection(Sender: TObject; aCol, aRow: Integer);
var
  RunData:TRunData;
begin
  if Sender=ProductDrawGrid then
  begin
  end;
  if Sender=RunDataOverviewDrawGrid then
  begin
  end;

  if (NOT chkCreateAppend.Checked) AND (chkAutoCreate.Checked) then ClearGraph;

  if (chkAutoCreate.Checked) AND Assigned(SelectedRunData) then
    AddGraphs(SelectedRunData.SampleNumber,false);

  if (chkCreateValidAll.Checked) then AddAllGraphs;
end;

procedure TForm1.btnDeleteTypeClick(Sender: TObject);
begin
  if (MessageDlg('Are you sure to delete whole type ?',mtConfirmation,[mbYes, mbNo],0)<>mrYes) then
  begin
    DeleteSelectedBattery;
  end;
end;

procedure TForm1.btnExport1Click(Sender: TObject);
begin
  ExportAllData(SelectedProduct.B_code);
end;

procedure TForm1.btnExportClick(Sender: TObject);
var
  Product:TProduct;
begin
  for TCollectionItem(Product) in Products do
  begin
    ExportAllData(Product.B_code);
  end;
end;

procedure TForm1.btnExport2Click(Sender: TObject);
var
  Product:TProduct;
begin
  for TCollectionItem(Product) in Products do
  begin
    ExportRawData(Product.B_code);
  end;
end;

procedure TForm1.btnGraphAddAllClick(Sender: TObject);
begin
  AddAllGraphs;
end;

procedure TForm1.btnGraphAddClick(Sender: TObject);
begin
  AddGraphs(SelectedRunData.SampleNumber,false);
end;

procedure TForm1.btnGraphClearClick(Sender: TObject);
begin
  ClearGraph;
end;

procedure TForm1.BatteryGridDrawCell(Sender: TObject; aCol,aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  aDrawGrid    : TDrawGrid;
  LocalProduct : TProduct;
  TestDatas    : TTestCollection;
  TestData     : TTestData;
  RunData      : TRunData;
  RunDatas     : TRunDataCollection;
  s            : string;
  indexer:integer;
  Found:boolean;
begin
  aDrawGrid:=TDrawGrid(Sender);

  LocalProduct:=nil;
  if Sender=RunDataOverviewDrawGrid then LocalProduct:=SelectedProduct;
  if Sender=ProductDrawGrid then LocalProduct:=Products.GetBatteryData(aRow);

  if (aRow>0) then
  begin
    if Assigned(LocalProduct) then
    begin

      if Sender=RunDataOverviewDrawGrid then
      begin
        if GetRunDataFromGridRow(LocalProduct,aRow,TestData,RunData) then
        begin
          case aCol of
            0: s:=InttoStr(RunData.SampleNumber);
            1: s:='Unknown';
            2: s:=ModeIdentifier[TestData.StageMode];
            3: s:=InttoStr(TestData.SetValue);
            5: s:=FloattoStrF(RunData.MeasuredEnergy,ffFixed,8,1);
          end;
          if (aCol<>4) then
          begin
            InflateRect(ARect, -constCellpadding, -constCellPadding);
            aDrawGrid.Canvas.TextRect(ARect, ARect.Left, ARect.Top, s);
          end;
        end
        else
        begin
          s:='??'
        end;
      end;

      if Sender=ProductDrawGrid then
      begin
        if (aRow>Products.Count) then
        begin
          s:='??'
        end
        else
        begin
          case aCol of
            0: s:=LocalProduct.B_code;
            1: s:=LocalProduct.B_name;
            2: s:=LocalProduct.B_type;
          end;
          InflateRect(ARect, -constCellpadding, -constCellPadding);
          aDrawGrid.Canvas.TextRect(ARect, ARect.Left, ARect.Top, s);
        end;
      end;
    end;
  end;

end;

procedure TForm1.BatteryOverviewDrawGridCheckBoxState(Sender: TObject; aCol, aRow: Integer; var aState: TCheckboxState);
var
  aDrawGrid    : TDrawGrid;
  TestData     : TTestData;
  RunData      : TRunData;
begin
  aDrawGrid:=TDrawGrid(Sender);
  if Assigned(SelectedProduct) then
  begin
    if GetRunDataFromGridRow(SelectedProduct,aRow,TestData,RunData) then
    begin
      if (aCol=4) then
      begin
        if RunData.DataInvalid then
          aState:=TCheckboxState.cbChecked
        else
          aState:=TCheckboxState.cbUnchecked;
      end;
    end;
  end;
end;

procedure TForm1.BatteryOverviewDrawGridCheckBoxToggle(Sender: TObject; aCol, aRow: Integer; aState: TCheckboxState);
var
  aDrawGrid    : TDrawGrid;
  TestData     : TTestData;
  RunData      : TRunData;
begin
  aDrawGrid:=TDrawGrid(Sender);
  if Assigned(SelectedProduct) then
  begin
    if GetRunDataFromGridRow(SelectedProduct,aRow,TestData,RunData) then
    begin
      if (aCol=4) then
      begin
        RunData.DataInvalid:=(aState=TCheckboxState.cbChecked);
        SharedmORMotData.UpdateRunData(RunData,'DataInvalid');
      end;
    end;
  end;
end;

procedure TForm1.btnImportDataClick(Sender: TObject);
begin
  tsAdmin.Enabled:=False;

  OpenDialog1.FileName:='settings.dat';
  OpenDialog1.Filter := 'Data Files (*.dat)|*.dat';
  if OpenDialog1.Execute then
  try
    ImportProductData(OpenDialog1.FileName);
  except
    //on E: ESynException do AdminMemo.Lines.Append(E.Message);
  end;

  tsAdmin.Enabled:=True;
end;

procedure TForm1.btnPrintClick(Sender: TObject);
begin
end;

procedure TForm1.SearchText(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
var
  NodeData: PPropertyData;
  sText: String;
  bVisible: Boolean;
begin
  Abort := PPropertyData(Sender.GetNodeData(Node))^.Value = StrPas(Data);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  foundNode  : PVirtualNode;
begin
  VST5.BeginUpdate;
  try
   foundNode :=VST5.IterateSubtree(nil, @SearchText, PChar('no template used'));
   if Assigned(foundNode) then
     MemoParticularities.Lines.Append(PPropertyData(VST5.GetNodeData(foundNode))^.Value);
  finally
    VST5.EndUpdate;
  end;
end;

procedure TForm1.btnImportMeasurementsClick(Sender: TObject);
var
  aDischargeType:TStageMode;
  aDischargeValue:integer;
  aSampleNumber:integer;
begin
  tsAdmin.Enabled:=False;
  OpenDialog1.Filter := 'Data Files (*.dat;*.csv)|*.dat;*.csv';
  if OpenDialog1.Execute then
  begin
    try
      try
        // Process the datafile

        aDischargeType:=TStageMode.smUnknown;
        aDischargeValue:=0;
        aSampleNumber:=0;
        if (ListBox1.ItemIndex<>-1) then
        begin
          aDischargeType:=FromText(ListBox1.GetSelectedText);
          aDischargeValue:=StrToIntDef(EditDVOverride.Text,0);
        end;
        aSampleNumber:=spinStartSampleNumber.Value;
        ImportProductRunData(OpenDialog1.FileName,aDischargeType,aDischargeValue,aSampleNumber);
      except
        //on E: ESynException do AdminMemo.Lines.Append(E.Message);
      end;

    finally
      EditDVOverride.Text:='';
      ListBox1.ItemIndex:=-1;
    end;

  end;
  tsAdmin.Enabled:=True;
end;

procedure TForm1.ExportAllData(aProductCode:string);
type
  TTrigger = record
    TriggerValue:word;
    TriggerData:TMeasurementData;
  end;
var
  F                   : textfile;
  s,localfilename     : string;
  i,j                 : integer;
  triggerindex        : integer;
  samplenumber        : integer;
  skipminutes         : integer;
  runcount,batcount   : integer;
  Trigger             : TTrigger;
  NewTriggers         : array of TTrigger;
  TriggersCount       : integer;

  TDRunner            : TThresholdDataItem;

  LocalProduct        : TProduct;
  TestDatas           : TTestCollection;
  TestData            : TTestData;
  RunData             : TRunData;
  RunDatas            : TRunDataCollection;
  MeasurementData     : TMeasurementData;
  MeasurementDatas    : TNewLiveDataCollection;
begin
  Products.AddOrUpdate(aProductCode,False,LocalProduct);
  if NOT Assigned(LocalProduct) then exit;
  if NOT Assigned(SelectedTestData) then exit;

  TriggersCount:=0;
  for i:=0 to Pred(chkgrpEndPoints.Items.Count) do
  begin
    if chkgrpEndPoints.Checked[i] then Inc(TriggersCount);
  end;
  // Also add default endvoltage trigger
  Inc(TriggersCount);

  // Set length of new trigger to amount of triggers
  SetLength({%H-}NewTriggers,TriggersCount);

  // Fill triggers
  j:=0;
  for i:=0 to Pred(chkgrpEndPoints.Items.Count) do
  begin
    if chkgrpEndPoints.Checked[i] then
    begin
      NewTriggers[j].TriggerValue:=EndpointChoices[i];
      NewTriggers[j].TriggerData:=nil;
      Inc(j);
    end
  end;
  // Also set [default] trigger endpoint
  NewTriggers[j].TriggerValue:=0;
  NewTriggers[j].TriggerData:=nil;

  skipminutes:=StrToIntDef(editSkipMinutes.Text,0);

  localfilename:='exportalltest.csv';
  AssignFile(F,localfilename);

  try
    if FileExists(localfilename)
       then Append(F)
       else
       begin
         Rewrite(F);
         with Formatsettings do
         begin
           write(F,'B_code',ListSeparator);
           write(F,'B_name',ListSeparator);
           write(F,'B_type',ListSeparator);
           write(F,'B_id',ListSeparator);
           write(F,'Test_id',ListSeparator);
           write(F,'Brand#',ListSeparator);
           write(F,'Sample#',ListSeparator);
           write(F,'Total discharge time(sec)',ListSeparator);
           write(F,'Capacity(mAh)',ListSeparator);
           write(F,'Voltage',ListSeparator);
           write(F,'Energy',ListSeparator);
           write(F,'Cycle',ListSeparator);
           write(F,'Environment temperature (°C)',ListSeparator);
           write(F,'Environment humidity (%RH)',ListSeparator);
           write(F,'Board',ListSeparator);
           write(F,'Position in board',ListSeparator);
           write(F,'Battery mode',ListSeparator);
           write(F,'Battery mode value',ListSeparator);
           write(F,'Trigger moment UTC',ListSeparator);
           write(F,'Trigger source type',ListSeparator);
           write(F,'Trigger source value',ListSeparator);
         end;
         writeln(F);
       end;

    //for Trigger1000mV in boolean do

    TestDatas:=LocalProduct.TestDatas;
    for TCollectionItem(TestData) in TestDatas do
    begin
      if (TestData.StageMode=SelectedTestData.StageMode) AND (TestData.SetValue=SelectedTestData.SetValue) then
      begin
        RunDatas:=TestData.RunDatas;

        // Get the rundata summaries when needed
        if RunDatas.Count=0 then SharedmORMotData.GetProductRunDatas(RunDatas);

        if RunDatas.Count=0 then continue;

        samplenumber:=0;

        for TCollectionItem(RunData) in RunDatas do
        begin
          if (RunData.DataInvalid) AND (chkValidOnly.Checked) then continue;

          // Retrieve all rundata when needed
          if (RunData.NewLiveData.Count<=1) then SharedmORMotData.GetProductRunData(RunData);

          MeasurementDatas:=RunData.NewLiveData;

          if MeasurementDatas.Count=0 then continue;

          Inc(samplenumber);
          for triggerindex:=0 to Pred(Pred(Length(NewTriggers))) do NewTriggers[triggerindex].TriggerData:=nil;

          batcount:=MeasurementDatas.Count;
          Dec(batcount);

          // Add end voltage data
          NewTriggers[Pred(Length(NewTriggers))].TriggerData:=MeasurementDatas.Item[batcount];

          // Add other trigger data
          for j:=0 to batcount do
          begin
            // Skip first skipminutes
            if (skipminutes>0) then
            begin
              if (MeasurementDatas.Item[j].Elapsed<(skipminutes*60)) then continue;
            end;
            for triggerindex:=0 to Pred(Pred(Length(NewTriggers))) do
            begin
              if Assigned(NewTriggers[triggerindex].TriggerData) then continue;
              if ((MeasurementDatas.Item[j].Voltage*1000)<NewTriggers[triggerindex].TriggerValue) then
              begin
                if ((j=batcount) OR ((MeasurementDatas.Item[j+1].Voltage*1000)<NewTriggers[triggerindex].TriggerValue)) then
                begin
                  NewTriggers[triggerindex].TriggerData:=MeasurementDatas.Item[j];
                end;
              end;
            end;
          end;

          for Trigger in NewTriggers do
          begin
            if Assigned(Trigger.TriggerData) then
            begin
              with Formatsettings do
              begin
                // Write general data
                write(F,LocalProduct.B_code,ListSeparator);
                write(F,LocalProduct.B_name,ListSeparator);
                write(F,LocalProduct.B_type,ListSeparator);
                write(F,LocalProduct.B_id,ListSeparator);
                write(F,testdata.TestID,ListSeparator);
                write(F,'-',ListSeparator);
                write(F,samplenumber,ListSeparator);

                // Write LocalProduct data
                write(F,Trigger.TriggerData.Elapsed,ListSeparator);
                write(F,FloattoStrF(Trigger.TriggerData.Capacity,ffFixed,10,3),ListSeparator);
                write(F,FloattoStrF(Trigger.TriggerData.Voltage,ffFixed,10,5),ListSeparator);
                write(F,FloattoStrF(Trigger.TriggerData.Energy,ffFixed,10,3),ListSeparator);

                // Write miscellaneous data
                write(F,RunData.Cycles,ListSeparator);  // Cycle
                write(F,20,ListSeparator); // temperature
                write(F,65,ListSeparator); // humidity

                // Write extra rundata
                write(F,rundata.BoardSerial,ListSeparator);
                write(F,'-',ListSeparator);
                write(F,ModeIdentifier[TestData.StageMode],ListSeparator);
                write(F,TestData.SetValue,ModeUnitsCompat[TestData.StageMode],ListSeparator);

                // Write trigger data
                if (Trigger.TriggerValue>0) then
                begin
                  // Write other trigger data
                  write(F,'',ListSeparator);
                  write(F,ThresholdNames[TThresholdModes.tmMINV],ListSeparator);
                  write(F,InttoStr(Trigger.TriggerValue)+ThresholdIdentifiers[TThresholdModes.tmMINV],ListSeparator);
                end
                else
                begin
                  // Write last voltage trigger data

                  write(F,FloattoStrF(testdata.Date,ffFixed,16,10),ListSeparator);
                  if (rundata.ThresholdDataCollection.Count=0) then
                  begin
                    write(F,'unknownThresholdMode',ListSeparator);
                    write(F,Round(Trigger.TriggerData.Voltage*1000),ThresholdIdentifiers[TThresholdModes.tmMINV],ListSeparator);
                  end
                  else
                  begin
                    for TCollectionItem(TDRunner) in rundata.ThresholdDataCollection do
                    begin
                      with TDRunner do
                      begin
                        if (Mode=TThresholdModes.tmMINV) then
                          write(F,'endV',ListSeparator)
                        else
                          write(F,'strangeThresholdMode',ListSeparator);
                        write(F,FloattoStrF(Data,ffFixed,8,1),ThresholdIdentifiers[Mode],ListSeparator);
                        // Skip all other modes, if any
                        if (Mode=TThresholdModes.tmMINV) then break;
                      end;
                    end;
                  end;

                end;
              end;
              writeln(F);
            end;
          end;
        end;
      end;

    end;

  finally
    CloseFile(F);
  end;

  Finalize(NewTriggers);
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

procedure TForm1.editVoltageDblClick(Sender: TObject);
begin
  // set admin mode
  //btnImportMeasurements.Visible:=True;
  //btnImportData.Visible:=True;
  tsAdmin.TabVisible:=True;
  Self.AllowDropFiles:=True;
end;

procedure TForm1.ConnectWithServer;
var
  ServerOk:boolean;
begin
  SharedmORMotData.ConnectNew({remote:}False,{ownserver:}True);

  ServerOk:=SharedmORMotData.Connected;
  if NOT ServerOk then
  begin
    ShowMessage('Could not connect with online server.');
  end
  else
  begin
  end;
  (*

  ServerOk:=SharedmORMotData.Connected;
  if NOT ServerOk then
  begin
    ShowMessage('Could not connect with online server.');
  end
  else
  begin
    //SharedmORMotData.User:=;
    //SharedmORMotData.Password:=;
    ServerOk:=SharedmORMotData.Authenticate;
    if NOT ServerOk then
    begin
      ShowMessage('Could not authenticate.');
    end;
  end;
  if ServerOk then
  begin
    //ShowMessage('Server ok.');
  end;

  *)
end;

procedure TForm1.btnConnectClick(Sender: TObject);
begin
  TButton(Sender).Enabled:=False;

  try
    ConnectWithServer;

    if SharedmORMotData.Connected then
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

procedure TForm1.BatteryGridSelectCell(Sender: TObject; ACol, ARow: Longint; var CanSelect: Boolean);
begin
  GetDataFromGridRow(Sender,aRow);
end;

procedure TForm1.OnMouseWheel(Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled:=true;
end;

procedure TForm1.ClearGraph;
var
  x:integer;
begin
  if Chart1.SeriesCount>0 then for x:= Chart1.SeriesCount-1 downto 0 do Chart1.Series[x].Destroy;
  Chart1.Series.Clear;
  //Chart1.ZoomFull;
end;

procedure TForm1.AddAllGraphs;
begin
  AddGraphs(0,false);
end;

function GenerateRandomColor(const Mix: TColor = clWhite): TColor;
var
  Red, Green, Blue: Integer;
begin
  Red := Random(256);
  Green := Random(256);
  Blue := Random(256);
  Red := (Red + GetRValue(ColorToRGB(Mix))) div 2;
  Green := (Green + GetGValue(ColorToRGB(Mix))) div 2;
  Blue := (Blue + GetBValue(ColorToRGB(Mix))) div 2;
  Result := RGB(Red, Green, Blue);
end;

procedure TForm1.AddGraphs(aSampleNumber:integer;validonly:boolean);
const
  SERIESCOLORS : array [0..30] of TColor =
  (
    clRed,
    clAqua,
    clLime,
    clGreen,
    clYellow,
    clBlue,
    clFuchsia,
    clPurple,
    clOlive,
    TColor($e6194b),
    TColor($3cb44b),
    TColor($ffe119),
    TColor($4363d8),
    TColor($f58231),
    TColor($911eb4),
    TColor($46f0f0),
    TColor($f032e6),
    TColor($bcf60c),
    TColor($fabebe),
    TColor($008080),
    TColor($e6beff),
    TColor($9a6324),
    TColor($fffac8),
    TColor($800000),
    TColor($aaffc3),
    TColor($808000),
    TColor($ffd8b1),
    TColor($000075),
    TColor($808080),
    TColor($ffffff),
    TColor($000000)
  );
var
  addall               : boolean;
  i,j                  : integer;
  TestData             : TTestData;
  RunDatas             : TRunDataCollection;
  RunDataRunner        : TRunData;
  MeasurementData      : TMeasurementData;
  runcount,batcount    : integer;
  LineColor            : TColor;
  TitleString          : string;
  aSeries              : TLineSeries;
  AMin, AMax: Double;
  ChartAxisIntervalOptions:TAxisIntervalParamOptions;
begin
  addall:=((aSampleNumber<=0));

  if addall then ClearGraph;

  if Assigned(SelectedProduct) AND Assigned(SelectedTestData) then
  begin
    RunDatas:=SelectedTestData.RunDatas;

    for TCollectionItem(RunDataRunner) in RunDatas do
    begin
      with RunDataRunner do
      begin
        if (
           (((aSampleNumber>0) AND (aSampleNumber=SampleNumber)) OR (addall AND (((NOT DataInvalid) AND (chkValidOnly.Checked)) OR (NOT chkValidOnly.Checked)) ))
        ) then
        begin

          if (NewLiveData.Count<=1) then
          begin
            // This willl retrieve rundata and all of the measurement data
            // In fact, this will only update the measurement data, as the RunDataRunner is a contant in a loop ... nice trick ... ;-)
            SharedmORMotData.GetProductRunData(RunDataRunner);
          end;

          if NewLiveData.Count>0 then
          begin
            LineColor:=clBlack;
            if Chart1.SeriesCount<Length(SERIESCOLORS) then
              LineColor:=SERIESCOLORS[Chart1.SeriesCount]
            else
              LineColor:=GenerateRandomColor(clGray);
            aSeries:=TLineSeries.Create(Chart1);
            Chart1.AddSeries(aSeries);
            with aSeries do
            begin
              Marks.Visible := False;
              SeriesColor := LineColor;
              LinePen.Color := LineColor;
              LinePen.Width := 5;
              TitleString:=SelectedProduct.B_code+' #'+InttoStr(SampleNumber);
              Title := TitleString;
              Chart1.Title.Text.Text:='ID'+TitleString;
            end;

            for TCollectionItem(MeasurementData) in NewLiveData do
            begin
              aSeries.AddXY(MeasurementData.Elapsed,MeasurementData.Voltage);
              //aSeries.AddY(MeasurementData.Voltage);
            end;
          end;
        end;
      end;
    end;
  end;

  Chart1.Legend.Visible:=(Chart1.SeriesCount>1);

  if (Chart1.SeriesCount=0) then Chart1.Title.Text.Text:='No data';
  if addall then Chart1.Title.Text.Text:=SelectedProduct.B_code;

  with Chart1.BottomAxis do
  begin
    Intervals.NiceSteps:='1|2|5';
    Intervals.MinLength:=30;
    Intervals.MaxLength:=80;
    ChartAxisIntervalOptions:=Intervals.Options;
    Include(ChartAxisIntervalOptions,aipUseNiceSteps);
    Include(ChartAxisIntervalOptions,aipUseMaxLength);
    Include(ChartAxisIntervalOptions,aipUseMinLength);
    Exclude(ChartAxisIntervalOptions,aipUseCount);
    Exclude(ChartAxisIntervalOptions,aipGraphCoords);
    Intervals.Options:=ChartAxisIntervalOptions;
    //Intervals.Tolerance:=5; { more also works, less shows decimal digits in labels }

  end;
end;

procedure TForm1.VST5CreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  out EditLink: IVTEditLink);
// This is the callback of the tree control to ask for an application defined edit link. Providing one here allows
// us to control the editing process up to which actual control will be created.
// TPropertyEditLink implements an interface and hence benefits from reference counting. We don't need to keep a
// reference to free it. As soon as the tree finished editing the class will be destroyed automatically.
var
  Data: PPropertyData;
begin
  Data := Sender.GetNodeData(Node);
  if (Data^.ValueType in [vtString,vtNumber]) then
    EditLink := TMyStringEditLink.Create
  else
  if (Data^.ValueType=vtMemo) then
    EditLink := TMemoEditLink.Create
  else
    EditLink := TPropertyEditLink.Create;
end;

procedure TForm1.VST5Edited(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);
var
  ChildData,ParentData: PPropertyData;
  P: PRttiProp;
  DataObject:TObject;
  i:integer;
  aDate:TDate;
begin
  ChildData := Sender.GetNodeData(Node);

  if ChildData^.Changed then
  begin
    ParentData:=Sender.GetNodeData(Node^.Parent);
    if Assigned(ParentData) AND Assigned(SelectedProduct) then
    begin
      DataObject:=nil;
      if ParentData^.Title='Base info' then DataObject:=SelectedProduct.BatteryDetail;
      if ParentData^.Title='Warnings' then DataObject:=SelectedProduct.BatteryDetail.Warnings;
      if ParentData^.Title='Disposal' then DataObject:=SelectedProduct.BatteryDetail.Disposal;
      if ParentData^.Title='Rechargeable' then DataObject:=SelectedProduct.BatteryDetail.Rechargeable;
      if Assigned(DataObject) then
      begin
        P := ClassFieldProp(DataObject.ClassType, ChildData^.Title);
        if Assigned(P) then
        begin
          if (P^.TypeInfo^.IsDate) then
          begin
            if TryStrToDate(ChildData^.Value,aDate) then
            begin
              P^.SetDoubleProp(DataObject,aDate);
              ChildData^.Changed:=false;
            end;
          end
          else
            if (P^.SetValueText(DataObject,ChildData^.Value)) then
              ChildData^.Changed:=false;

          if (NOT ChildData^.Changed) then
          begin
            SharedmORMotData.AddProduct(SelectedProduct);
          end;
        end;
      end;
    end;
  end;

end;

procedure TForm1.VST5InitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data,ChildData: PPropertyData;
  i,j,Level: Integer;
  ChildNode: PVirtualNode;
  aClass:TClass;
  EP: PShortString;
  Value:variant;
  S:string;
  rc: TRttiCustom;
  p: PRttiCustomProp;
  desc: System.UTF8String;
begin
  Level := Sender.GetNodeLevel(Node);
  Data := Sender.GetNodeData(Node);

  if Data^.Title='Base info' then aClass:=TBatteryDetails;
  if Data^.Title='Warnings' then aClass:=TBatteryWarnings;
  if Data^.Title='Disposal' then aClass:=TBatteryDisposal;
  if Data^.Title='Rechargeable' then aClass:=TBatteryRechargeable;

  rc := Rtti.RegisterClass(aClass);
  p := pointer(rc.Props.List);
  for i := 1 to rc.Props.Count do
  begin
    if p^.Value.Kind = rkClass then continue;

    ChildNode := Sender.AddChild(Node);
    ChildData := Sender.GetNodeData(ChildNode);
    ChildData^.Title:=p^.Name;

    case p^.Value.Kind  of
      rkBool:ChildData^.ValueType:=vtBooleanText;
      rkInteger: ChildData^.ValueType:=vtNumber;
      rkFloat:
        begin
          if P^.Prop^.TypeInfo^.IsDate then
            ChildData^.ValueType:=vtDate
          else
            ChildData^.ValueType:=vtNumber;
        end;
      rkLString,rkWString{$ifdef HASVARUSTRING},rkUString{$endif}{$ifdef FPC},rkLStringOld{$endif}:ChildData^.ValueType:=vtString;
      rkEnumeration,rkSet:
        begin
          ChildData^.ValueType:=vtPickString;
          p^.Value.Cache.EnumInfo^.GetEnumNameTrimedAll({%H-}desc);
          ChildData^.PickList:=desc;
        end;
      else
        ChildData^.ValueType:=vtNone;
    end;
    inc(p);
  end;
  ChildCount := Sender.ChildCount[Node];
  Sender.ValidateNode(Node, False);
end;

procedure TForm1.VST5InitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PPropertyData;
  Level: Integer;
begin
  //Level := Sender.GetNodeLevel(Node);
  Level := Node^.Index;
  Data := Sender.GetNodeData(Node);

  if ParentNode=nil then
  begin
    InitialStates := InitialStates + [ivsHasChildren, ivsExpanded];
    if Level=0 then Data^.Title:='Base info';
    if Level=1 then Data^.Title:='Warnings';
    if Level=2 then Data^.Title:='Disposal';
    if Level=3 then Data^.Title:='Rechargeable';
  end
  else
  begin
    if Data^.ValueType = vtMemo then Include(InitialStates, ivsMultiline);
  end;
end;

procedure TForm1.VST5MeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
var
  Data: PPropertyData;
begin
  NodeHeight := VST5.ImagesWidth+2;
  if Sender.MultiLine[Node] then
  begin
    Data := VST5.GetNodeData(Node);
    TargetCanvas.Font := Sender.Font;
    NodeHeight := VST5.ComputeNodeHeight(TargetCanvas, Node, 1, Data^.Value);
    if NodeHeight < (VST5.ImagesWidth+2) then
      NodeHeight := (VST5.ImagesWidth+2);
  end;
end;

procedure TForm1.VST5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  HitInfo: THitInfo;
  Data: PPropertyData;
begin
  if (Button=TMouseButton.mbRight) then
  begin
    TBaseVirtualTree(Sender).GetHitTestInfoAt(X, Y, True, HitInfo);

    //if (HitInfo.Node = ?) and (HitInfo.Column = ?) then
    begin
    end;

    Data := TBaseVirtualTree(Sender).GetNodeData(hitinfo.HitNode);
    //Data^:=Default(TPropertyData);
    //Data^.Changed:=True;
  end;

end;

procedure TForm1.VST5NodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var
  Data: PPropertyData;
  im : TIntegerSet;
  mPos : integer;
  MousePos : TPoint;
  cbRect, cellRect: TRect;
  dy,dx : integer;
  CheckBoxSize: TSize;
begin
  Data := sender.GetNodeData(hitinfo.HitNode);

  ShowMessage(Format('Did you click Node "%s"?', [Data^.Value]));

  exit;

  // the hitinfo is incorrect when the below is true
  if toCenterScrollIntoView in VST5.TreeOptions.SelectionOptions then exit;


  //ThemeServices.GetElementSize(canvas.Handle, ThemeServices.GetElementDetails(tbCheckBoxUncheckedNormal), esActual, CheckBoxSize);
  //CheckBoxSize := ThemeServices.GetDetailSize(ThemeServices.GetElementDetails(tbCheckBoxUncheckedNormal));
  CheckBoxSize := ThemeServices.GetDetailSizeForPPI(ThemeServices.GetElementDetails(tbCheckBoxUncheckedNormal),ScreenInfo.PixelsPerInchX);

  if not (hiOnItem in HitInfo.HitPositions) then exit;
  if ((HitInfo.HitColumn=1)) then// AND (Data.ValueType in [vtBooleanText,vtBooleanSymbol,vtBooleanCheck])) then
  begin
    mousePos := VST5.ScreenToClient(mouse.CursorPos);
    mousePos := HitInfo.HitPoint;
    CellRect := VST5.GetDisplayRect(hitInfo.HitNode, hitInfo.HitColumn, false);
    cbRect   := CellRect;
    dy := (CellRect.Height - CheckBoxSize.Height ) div 2;
    inc(cbRect.Top, dy);
    cbRect.Bottom := cbRect.Top + CheckBoxSize.cy;
    dx := (CellRect.Width - CheckBoxSize.Width) div 2;
    inc(cbRect.Left, dx);
    cbRect.Right := cbRect.Left + CheckBoxSize.cx;
    if not cbRect.Contains(mousePos) then exit;
    mPos := HitInfo.HitColumn - 1;
    //if data.NodeType<>ntSource then exit;
    //data.DEMask := data.DEMask xor (1 shl mPos);
    sender.InvalidateNode(hitinfo.HitNode);
  end;
end;

procedure TForm1.VST5GetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: AnsiString);
var
  ChildData: PPropertyData;
  ParentData: PPropertyData;
  DataObject:TObject;
  Value:variant;
  EP: PShortString;
  i,j:integer;
  R:String;
  aDouble:double;

  rc: TRttiCustom;
  P: PRttiProp;
begin
  //CellText := Format('(%d,%d)', [Sender.GetNodeLevel(Node), Node^.Index]);
  //exit;
  ChildData := Sender.GetNodeData(Node);
  ChildData^.Value:='';

  //if TextType = ttNormal then
  begin
    if Column=0 then
      CellText := ChildData^.Title
    else
    begin
      //if SharedmORMotData.Connected then
      begin
        //if ChildData^.Changed then
        begin
          ParentData:=Sender.GetNodeData(Node^.Parent);
          if Assigned(ParentData) AND Assigned(SelectedProduct) then
          begin
            DataObject:=nil;
            if ParentData^.Title='Base info' then DataObject:=SelectedProduct.BatteryDetail;
            if ParentData^.Title='Warnings' then DataObject:=SelectedProduct.BatteryDetail.Warnings;
            if ParentData^.Title='Disposal' then DataObject:=SelectedProduct.BatteryDetail.Disposal;
            if ParentData^.Title='Rechargeable' then DataObject:=SelectedProduct.BatteryDetail.Rechargeable;

            if Assigned(DataObject) then
            begin
              rc := Rtti.RegisterClass(DataObject);
              P := ClassFieldProp(DataObject.ClassType, ChildData^.Title);
              if P = nil then exit;
              ChildData^.Value:=P^.GetValueText(DataObject);

              if (P^.TypeInfo^.Kind=rkEnumeration) then
              begin
                i:=P^.GetOrdValue(DataObject);
                ChildData^.Value:=GetEnumNameTrimed(P^.TypeInfo,i);
              end;

              if (P^.TypeInfo^.Kind=rkFloat) then
              begin
                aDouble:=P^.GetDoubleValue(DataObject);
                if (NOT MATH.IsZero(aDouble)) then
                begin
                  if P^.TypeInfo^.IsDate then
                    ChildData^.Value:=DateToStr(aDouble)
                  else
                    ChildData^.Value:=FloattoStr(aDouble);
                end;
              end;


            end;
          end;
        end;
      end;
      CellText := ChildData^.Value;
    end;
  end;

end;

procedure TForm1.VST5DrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; const CellText: AnsiString;
  const CellRect: TRect; var DefaultDraw: Boolean);
var
  Data: PPropertyData;
  CheckBoxDetails: TThemedElementDetails;
  CheckBoxSize: TSize;
  CheckBoxRect: TRect;
  r: TRect;
  size: TSize;
  ImgIndex:integer;
  B:boolean;
  CT: AnsiString;
begin
  // This is called after VST5GetText
  // So, Data value is filled with correct data !

  Data := Sender.GetNodeData(Node);
  if ((Column=1) AND (Data^.ValueType in [vtBooleanText,vtBooleanSymbol,vtBooleanCheck])) then
  begin
    B:=StrToBoolDef(Data^.Value,false);
    (*
    // Draw a checkbox
    r := CellRect;
    size.cx := GetSystemMetrics(SM_CXMENUCHECK);
    size.cy := GetSystemMetrics(SM_CYMENUCHECK);
    r.Top    := CellRect.Top + (CellRect.Bottom - CellRect.Top - size.cy) div 2;
    r.Bottom := r.Top + size.cy;
    r.Left   := r.Left + 4; // Add some padding
    r.Right  := r.Left + size.cx;

    if B then
      CheckBoxDetails:=ThemeServices.GetElementDetails(tbCheckBoxCheckedNormal)
    else
      CheckBoxDetails:=ThemeServices.GetElementDetails(tbCheckBoxUncheckedNormal);
    CheckBoxSize := ThemeServices.GetDetailSize(CheckBoxDetails);
    CheckBoxRect := Bounds(CellRect.Left + 4, CellRect.Top + (CellRect.Height - CheckBoxSize.Height) div 2, CheckBoxSize.Width, CheckBoxSize.Height);
    ThemeServices.DrawElement(TargetCanvas.Handle, CheckBoxDetails, CheckBoxRect);
    *)

    // Draw an check image
    if B then
      ImgIndex:=15
    else
      ImgIndex:=14;
    TreeImages1.DrawForPPI(TargetCanvas,CellRect.Left,CellRect.Top,ImgIndex,VST5.ImagesWidth,96,1);

    DefaultDraw:=false;
  end;
end;

procedure TForm1.VST5GetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: AnsiString);
begin
  // Add a dummy hint to the normal hint to demonstrate multiline hints.
  //if (Column = 0) and (Node^.Parent <> Sender.RootNode) then
  //  HintText := PropertyTexts[Node^.Parent^.Index, Node^.Index, ptkHint] + LineEnding + '(Multiline hints are supported too).';
end;

procedure TForm1.VST5GetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var Index: Integer);
var
  Data: PPropertyData;
begin
  if (Kind in [ikNormal, ikSelected]) and (Column = 0) then
  begin
    if Node^.Parent = Sender.RootNode then
      Index := 5 // root nodes, this is an open folder
    else
    begin
      Data := Sender.GetNodeData(Node);
      if Data^.ValueType in [vtBooleanText,vtBooleanSymbol,vtBooleanCheck] then
        Index := 11
      else
      if Data^.ValueType=vtMemo then
        Index := 10
      else
      if Data^.ValueType=vtDate then
        Index := 12
      else
      if Data^.ValueType=vtPickString then
        Index := 9
      else
      if Data^.ValueType <> vtNone then
        Index := 7
      else
        Index := 6;
    end;
  end;
end;

procedure TForm1.VST5Editing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  Data: PPropertyData;
begin
  with Sender do
  begin
    Data := GetNodeData(Node);
    Allowed := (Node^.Parent <> RootNode) and (Column = 1) and (Data^.ValueType <> vtNone);
  end;
end;

procedure TForm1.VST5Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  with Sender do
  begin
    // Start immediate editing as soon as another node gets focused.
    if Assigned(Node) and (Node^.Parent <> RootNode) and not (tsIncrementalSearching in TreeStates) then
    begin
      // We want to start editing the currently selected node. However it might well happen that this change event
      // here is caused by the node editor if another node is currently being edited. It causes trouble
      // to start a new edit operation if the last one is still in progress. So we post us a special message and
      // in the message handler we then can start editing the new node. This works because the posted message
      // is first executed *after* this event and the message, which triggered it is finished.
      PostMessage(Self.Handle, WM_STARTEDITING, PtrInt(Node), 0);
    end;
  end;
end;

procedure TForm1.VST5PaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType);
var
  PropertyData: PPropertyData;
begin
  // Make the root nodes underlined and draw changed nodes in bold style.
  if Node^.Parent = Sender.RootNode then
    TargetCanvas.Font.Style := [fsUnderline]
  else
  begin
    PropertyData := Sender.GetNodeData(Node);
    if PropertyData^.Changed then
      TargetCanvas.Font.Style := [fsBold]
    else
      TargetCanvas.Font.Style := [];
  end;
end;

procedure TForm1.VST5StateChange(Sender: TBaseVirtualTree; Enter, Leave: TVirtualTreeStates);
begin
  {
  if tsIncrementalSearching in Enter then
    SetStatusbarText('Searching for: ' + Sender.SearchBuffer);
  if tsIncrementalSearching in Leave then
    SetStatusbarText('');
  }
  //if not (csDestroying in ComponentState) then
  //  UpdateStateDisplay(Sender.TreeStates, Enter, Leave);
end;

procedure TForm1.WMStartEditing(var Message: TLMessage);
// This message was posted by ourselves from the node change handler above to decouple that change event and our
// intention to start editing a node. This is necessary to avoid interferences between nodes editors potentially created
// for an old edit action and the new one we start here.
var
  Node: PVirtualNode;
begin
  Node := Pointer(Message.WParam);
  // Note: the test whether a node can really be edited is done in the OnEditing event.
  VST5.EditNode(Node, 1);
end;

procedure TForm1.DeleteSelectedBattery;
begin
  if Assigned(SelectedProduct) then
  begin
    SharedmORMotData.DeleteProduct(SelectedProduct);
    Products.Delete(SelectedProduct.Index);
    ProductDrawGrid.RowCount:=ProductDrawGrid.RowCount-1;
    RefreshGUI;
  end;
end;

procedure TForm1.DeleteSelectedRunData;
begin
  if Assigned(SelectedProduct) then
  begin
    if Assigned(SelectedRunData) then
    begin
      SharedmORMotData.DeleteRunData(SelectedRunData);
      SelectedTestData.RunDatas.Delete(SelectedRunData.Index);
      SelectedTestData:=nil;
      SelectedRunData:=nil;
      RunDataOverviewDrawGrid.Invalidate;
      RunDataOverviewDrawGrid.RowCount:=RunDataOverviewDrawGrid.RowCount-1;
    end;
  end;
end;

procedure TForm1.ImportProductData(aFile:string);
type
  TDataType = (dtCode,dtName,dtType,dtBatID,dtCapacity);
  TDataRecord = record
    Position:integer;
    Valid:boolean;
    Data:string;
  end;
var
  DataType                     : TDataType;
  DataArray                    : Array[TDataType] of TDataRecord;
  LocalProduct                 : TProduct;
  aResult                      : boolean;
  MyArray                      : array of ansistring;
  i,j,x                        : integer;
  DataLine                     : string;
  aProductCode                 : string;
  Separator                    : char;
  tsFile                       : TextFile;
  TempList                     : TStringList;
begin
  for DataType in TDataType do DataArray[DataType].Position:=-1;

  AssignFile(tsFile, aFile);
  try
    Reset(tsFile);
    TempList:=TStringList.Create;
    try
      TempList.QuoteChar:='"';
      if (NOT Eof(tsFile)) then
      begin
        // Parse the first dataline for column titles
        Readln(tsFile,DataLine);
        i:=OccurrencesOfChar(DataLine, ',');
        j:=OccurrencesOfChar(DataLine, ';');
        if i>j
           then Separator:=','
           else if i<j
                then Separator:=';'
                else Separator:=FormatSettings.ListSeparator;

        TempList.CommaText:='"'+StringReplace(DataLine,Separator,'","',[rfReplaceAll])+'"';
        SetLength({%H-}MyArray, TempList.Count);
        try
          for x := 0 To TempList.Count-1 do MyArray[x] := TempList[x];
          DataArray[dtCode].Position:=AnsiIndexStr('Code',MyArray);
          DataArray[dtName].Position:=AnsiIndexStr('Name',MyArray);
          DataArray[dtType].Position:=AnsiIndexStr('Type',MyArray);
          DataArray[dtCapacity].Position:=AnsiIndexStr('Capacity',MyArray);
          DataArray[dtBatID].Position:=AnsiIndexStr('BatteryId',MyArray);
        finally
          Finalize(MyArray);
        end;
      end;

      while (NOT EOF(tsFile)) do
      begin
        Readln(tsFile,DataLine);

        // check for a comma as list separator !!
        if Separator=FormatSettings.DecimalSeparator then
        begin
          DataLine:=StringReplace(DataLine,Separator,FormatSettings.ListSeparator,[rfReplaceAll]);
          //if separator is comma, -> decimal separator is dot !!
          DataLine:=StringReplace(DataLine,'.',FormatSettings.DecimalSeparator,[rfReplaceAll]);
        end
        else if Separator<>FormatSettings.ListSeparator then
        begin
          DataLine:=StringReplace(DataLine,Separator,FormatSettings.ListSeparator,[rfReplaceAll]);
        end;

        TempList.CommaText:='"'+StringReplace(DataLine,FormatSettings.ListSeparator,'","',[rfReplaceAll])+'"';

        for DataType in TDataType do
        begin
          with DataArray[DataType] do
          begin
            Valid:=(Position<TempList.Count);
            if Valid then
              Data:=TempList.Strings[Position]
            else
              Data:='';
          end;
        end;

        // Get LocalProduct
        LocalProduct:=nil;
        if (DataArray[dtCode].Valid) then
        begin
          aProductCode:=DataArray[dtCode].Data;

          // Special code ... to be discarded !!!!
          // ALF
          if Pos('00-W-02',aProductCode)>0 then
          begin
            aProductCode:=StringReplace(aProductCode,'00-W-02','00-W-01',[]);
          end;

          if Products.AddOrUpdate(aProductCode, True, LocalProduct) then
          begin
            // We have new testdata: provide the data !
            with DataArray[dtName] do if Valid then LocalProduct.B_name:=Data;
            with DataArray[dtType] do if Valid then LocalProduct.B_type:=Data;
            with DataArray[dtBatID] do if Valid then LocalProduct.B_id:=Data;
            with DataArray[dtCapacity] do if Valid then LocalProduct.Capacity:=StrToIntDef(Data,0);
          end;
        end;
      end;
    finally
      TempList.Free;
    end;
  finally
    CloseFile(tsFile)
  end;

  // Sort !!
  Products.Sort(TCollectionSortCompare(@CompareProductName));

  // Store in database, if any
  for TCollectionItem(LocalProduct) in Products do SharedmORMotData.AddProduct(LocalProduct);

  RefreshGUI;
end;

procedure TForm1.ImportProductRunData(aFile:string;OverrideDischargeType:TStageMode;OverrideDischargeValue:TSetValue;OverrideSampleNumber:integer);
var
  DataFile : TStringList;
begin
  DataFile:=TStringList.Create;
  try
    DataFile.LoadFromFile(aFile);
    ImportProductRunData(DataFile,OverrideDischargeType,OverrideDischargeValue,OverrideSampleNumber);
  finally
    DataFile.Free;
  end;
end;

{$define TIME}

procedure TForm1.ImportProductRunData(DataFile:TStringList;OverrideDischargeType:TStageMode;OverrideDischargeValue:TSetValue;OverrideSampleNumber:integer);
const
  CYCLETIME = 14400;
type
  TDataType = (
    dtCode,dtName,dtType,dtBatID,dtTestID,dtBrand,
    dtSample,dtDischargeType,dtDischargeValue,
    dtDate,dtBoardSerial,dtBoardPosition,dtTriggerType,
    dtTriggerValue,dtElapsed,dtElapsed_Total,dtCycle,
    dtVoltage,dtCurrent,dtCapacity,dtEnergy);

  TDataRecord = record
    Position:integer;
    Valid:boolean;
    Data:string;
  end;

var
  DataType           : TDataType;
  DataArray          : Array[TDataType] of TDataRecord;

  TestData           : TTestData;
  TestDatas          : TTestCollection;
  RunData            : TRunData;
  RunDatas           : TRunDataCollection;
  MeasurementData    : TMeasurementData;
  MeasurementDatas   : TNewLiveDataCollection;

  TD                 : TThresholdDataItem;

  ProductRunner      : TProduct;
  LocalProduct       : TProduct;

  aProductCode         : string;

  aDischargeType       : TStageMode;
  aDischargeValue      : TSetValue;

  aThresholdMode       : TThresholdModes;

  aSampleNumber        : integer;
  aCycleTime           : integer;
  aStartDateTime       : TDateTime;
  aDataDateTime        : TDateTime;

  aFS                          : TFormatSettings;

  MyArray                      : array of ansistring;
  i,j,k                        : integer;
  DataLine,S                   : ansistring;
  Separator                    : char;
  TempList                     : TStringList;
  DataFileIndex                : integer;
  aDouble                      : double;

  TimeMS,ElapsedMs             : boolean;
  Success                      : boolean;

  SampleNumberIncrementer      : integer;

  CommaCount:integer;
  SemiCount:integer;
  DotCount:integer;

  {$ifdef TIMECORRECT}
  TimeDiff                     : integer;
  TimeCounter                  : qword;
  TimeAverage                  : double;
  {$endif TIME}
begin
  aFS:=DefaultFormatSettings;

  aFS.ShortDateFormat:='dd-mm-yyyy';
  aFS.LongTimeFormat:='hh:nn:ss';

  aDischargeType:=TStageMode.smUnknown;
  aDischargeValue:=0;

  {$ifdef TIMECORRECT}
  TimeAverage:=0;
  TimeCounter:=0;
  {$endif TIME}

  aStartDateTime:=0;
  aDataDateTime:=0;

  if (DataFile.Count<2) then exit;

  for DataType in TDataType do DataArray[DataType].Position:=-1;

  TempList:=TStringList.Create;
  TempList.StrictDelimiter:=true;
  TempList.QuoteChar:='"';

  try
    DataFileIndex:=0;

    repeat
      DataLine:=DataFile[DataFileIndex];

      // Calculate separators only for first line (titles) and second line (first dataline)
      if ((DataFileIndex=0) OR (DataFileIndex=1)) then
      begin
        aFS.ListSeparator:=DefaultDelimiter;
        aFS.DecimalSeparator:=',';

        CommaCount:=OccurrencesOfChar(dataline,',');
        SemiCount:=OccurrencesOfChar(dataline,DefaultDelimiter);
        DotCount:=OccurrencesOfChar(dataline,'.');

        if (CommaCount>SemiCount) then
        begin
          aFS.ListSeparator:=',';
          aFS.DecimalSeparator:='.';
        end
        else
        begin
          if (DotCount>CommaCount) then
          begin
            aFS.DecimalSeparator:='.';
          end;
        end;

        TempList.Delimiter:=aFS.ListSeparator;
      end;

      TempList.DelimitedText:=DataLine;
      SetLength({%H-}MyArray, TempList.Count);

      try
        // Get the data positions from the datafile

        for i := 0 To Pred(TempList.Count) do MyArray[i] := TempList[i];

        DataArray[dtCode].Position:=AnsiIndexStr('B_code',MyArray);
        DataArray[dtName].Position:=AnsiIndexStr('B_name',MyArray);
        DataArray[dtType].Position:=AnsiIndexStr('B_type',MyArray);
        DataArray[dtBatID].Position:=AnsiIndexStr('B_id',MyArray);
        DataArray[dtTestID].Position:=AnsiIndexStr('Test_id',MyArray);
        DataArray[dtBrand].Position:=AnsiIndexStr('Brand#',MyArray);
        DataArray[dtSample].Position:=AnsiIndexStr('Sample#',MyArray);
        DataArray[dtDischargeType].Position:= AnsiIndexStr('Battery mode',MyArray);
        DataArray[dtDischargeValue].Position:=AnsiIndexStr('Battery mode value',MyArray);
        DataArray[dtDate].Position:=AnsiIndexStr('Trigger moment UTC',MyArray);
        DataArray[dtBoardSerial].Position:=AnsiIndexStr('Board',MyArray);
        DataArray[dtBoardPosition].Position:=AnsiIndexStr('Position in board',MyArray);
        DataArray[dtTriggerType].Position:=AnsiIndexStr('Trigger source type',MyArray);
        DataArray[dtTriggerValue].Position:=AnsiIndexStr('Trigger source value',MyArray);
        DataArray[dtCycle].Position:=AnsiIndexStr('Cycle',MyArray);

        TimeMs:=false;
        with DataArray[dtElapsed] do
        begin
          Position:=AnsiIndexStr('Time(sec)',MyArray);
          if (Position=-1) then
          begin
            Position := AnsiIndexStr('Time(msec)',MyArray);
            if (Position<>-1) then TimeMs:=true;
          end;
        end;

        ElapsedMs:=false;
        with DataArray[dtElapsed_Total] do
        begin
          Position:=AnsiIndexStr('Total discharge time(sec)',MyArray);
          if (Position=-1) then
          begin
            Position := AnsiIndexStr('Total discharge time(msec)',MyArray);
            if (Position<>-1) then ElapsedMs:=true;
          end;
        end;

        with DataArray[dtVoltage] do
        begin
          Position := AnsiIndexStr('Voltage',MyArray);
          if (Position=-1) then  Position := AnsiIndexStr('Voltage(V)',MyArray);
        end;
        with DataArray[dtCurrent] do
        begin
          Position := AnsiIndexStr('Set current',MyArray);
          if Position=-1 then Position := AnsiIndexStr('Current',MyArray);
          if Position=-1 then Position := AnsiIndexStr('Current(mA)',MyArray);

        end;
        with DataArray[dtCapacity] do
        begin
          Position := AnsiIndexStr('Capacity(mAh)',MyArray);
          if Position=-1 then Position := AnsiIndexStr('Capacity',MyArray);

        end;
        with DataArray[dtEnergy] do
        begin
          Position := AnsiIndexStr('CalcEnergy',MyArray);
          if Position=-1 then Position := AnsiIndexStr('Energy',MyArray);
          if Position=-1 then Position := AnsiIndexStr('Energy(mWh)',MyArray);
        end;

      finally
        Finalize(MyArray);
      end;

      Inc(DataFileIndex);

      if ((DataArray[dtCode].Position<>-1) AND (DataArray[dtSample].Position<>-1)) then break;

    until (DataFileIndex=DataFile.Count);

    aProductCode:='';

    while (DataFileIndex<DataFile.Count) do
    begin
      DataLine:=DataFile[DataFileIndex];
      Inc(DataFileIndex);
      TempList.Clear;
      TempList.DelimitedText:=DataLine;
      if TempList.Count=0 then continue;

      SampleNumberIncrementer:=(OverrideSampleNumber-1);

      for DataType in TDataType do
      begin
        with DataArray[DataType] do
        begin
          Valid:=(Position<TempList.Count);
          if Valid then
            Data:=TempList.Strings[Position]
          else
            Data:='';
        end;
      end;

      // Get product
      LocalProduct:=nil;
      if (DataArray[dtCode].Valid) then
      begin
        aProductCode:=DataArray[dtCode].Data;

        // Special code ... to be discarded !!!!
        // ALF
        if Pos('00-W-02',aProductCode)>0 then
        begin
          aProductCode:=StringReplace(aProductCode,'00-W-02','00-W-01',[]);
          Inc(SampleNumberIncrementer,4);
        end;

        if Products.AddOrUpdate(aProductCode, True, LocalProduct) then
        begin
          // We have new testdata: provide the data !
          with DataArray[dtName] do if Valid then LocalProduct.B_name:=Data;
          with DataArray[dtType] do if Valid then LocalProduct.B_type:=Data;
          with DataArray[dtBatID] do if Valid then LocalProduct.B_id:=Data;
          with DataArray[dtTestID] do if Valid then LocalProduct.Test_id:=Data;
        end
        else
        begin
          // We have existing data !!
          // Retrieve all data from database to append the new data
          TestDatas:=LocalProduct.TestDatas;
          for TCollectionItem(TestData) in TestDatas do
          begin
            RunDatas:=TestData.RunDatas;
            if RunDatas.Count=0 then SharedmORMotData.GetProductRunDatas(RunDatas);
            if RunDatas.Count=0 then continue;
            for TCollectionItem(RunData) in RunDatas do
            begin
              if (RunData.NewLiveData.Count<=1) then SharedmORMotData.GetProductRunData(RunData);
            end;
          end;
        end;
      end;

      if Assigned(LocalProduct) then
      begin
        with DataArray[dtSample] do if Valid then
        begin
          aSampleNumber:=StrToInt(Data);
          Inc(aSampleNumber,SampleNumberIncrementer);
        end;


        aDischargeType:=TStageMode.smUnknown;
        aDischargeValue:=0;

        with DataArray[dtDischargeType] do if Valid then
        begin
          S:=UpperCase(Data);
          aDischargeType:=FromTextCompat(S);
        end;
        if (aDischargeType=TStageMode.smUnknown) then
        begin
          // We might have defined it ourselves: use it
          if OverrideDischargeType<>TStageMode.smUnknown then aDischargeType:=OverrideDischargeType;
        end;


        with DataArray[dtDischargeValue] do if Valid then
        begin
          aDischargeValue:=ExtractIntegerInString(Data);
        end;
        if (aDischargeValue=0) then
        begin
          // We might have defined it ourselves: use it
          if OverrideDischargeValue<>0 then aDischargeValue:=OverrideDischargeValue;
        end;

        // We now have the data to find the rundata through the test data and the rundata itself
        TestDatas:=LocalProduct.TestDatas;
        if TestDatas.AddOrUpdate(aDischargeType,aDischargeValue,TestData) then
        begin
          // We have new testdata: provide the data !
          TestData.TestID:=LocalProduct.Test_id;
        end;

        RunDatas:=TestData.RunDatas;
        if RunDatas.AddOrUpdate(aSampleNumber,RunData) then
        begin
          // We have new rundata: provide the data !
          with DataArray[dtBoardSerial] do if Valid then RunData.BoardSerial:=Data;
        end;

        // Trigger things
        aThresholdMode := TThresholdModes.tmNONE;

        with DataArray[dtTriggerType] do if Valid then
        begin
          S:=Data;
          if AnsiSameText(ThresholdNamesCompat[TThresholdModes.tmMINV],S) then aThresholdMode:=TThresholdModes.tmMINV;
          if AnsiSameText(ThresholdNamesCompat[TThresholdModes.tmDELTAV],S) then aThresholdMode:=TThresholdModes.tmDELTAV;
          if AnsiSameText(ThresholdNames[TThresholdModes.tmTIME],S) then aThresholdMode:=TThresholdModes.tmTIME;
        end;
        with DataArray[dtTriggerValue] do if Valid then
        begin
          if (aThresholdMode<>TThresholdModes.tmNONE) then
          begin
            RunData.ThresholdDataCollection.AddOrUpdate(aThresholdMode,true,TD);
            TD.Triggered:=True;
            S:=Data;
            TD.Data:=ExtractFloatInString(S);
            if DataArray[dtDate].Valid then TD.Moment:=FloatToDateTime(StrToFloatDef(DataArray[dtDate].Data,0,aFS));
          end;
        end;

        // If we have all MeasurementData
        if RunData.SaveEV then continue;

        MeasurementDatas:=RunData.NewLiveData;
        if Assigned(MeasurementDatas) then
        begin
          MeasurementData:=MeasurementDatas.Add;
          // Add some more info into localrundata

          // if available, try to get elapsed from UTC
          {$ifdef TIME}
          if DataArray[dtDate].Valid then
          begin
            aDataDateTime:=FloatToDateTime(StrToFloatDef(DataArray[dtDate].Data,0,aFS));
            TestData.Date:=aDataDateTime;
            if (aStartDateTime=0) then
            begin
              aStartDateTime:=aDataDateTime;
              if DataArray[dtElapsed].Valid then
              begin
                j:=Round(StrToFloat(DataArray[dtElapsed].Data,aFS));
                if TimeMS then
                  aStartDateTime:=IncMilliSecond(aStartDateTime,-1*j)
                else
                  aStartDateTime:=IncSecond(aStartDateTime,-1*j);
              end;
            end;
          end;
          {$endif TIME}

          // Get the time (in ms) !!
          with DataArray[dtElapsed_Total] do if Valid then
          begin
            MeasurementData.Elapsed:=(StrToInt(Data));
            if ElapsedMs then MeasurementData.Elapsed:=(MeasurementData.Elapsed DIV 1000);
          end
          else
          begin
            {$ifdef TIME}
            if ((aStartDateTime<>0) AND (aDataDateTime<>0)) then
            begin
              j:=SecondsBetween(aDataDateTime,aStartDateTime);
              MeasurementData.Elapsed:=j;
            end
            else
            begin
              aCycleTime:=1;

              with DataArray[dtCycle] do if Valid then
              begin
                aCycleTime:=StrToInt(Data);
              end;

              aCycleTime:=CYCLETIME*(aCycleTime-1);
              with DataArray[dtElapsed] do if Valid then
              begin
                if TimeMS then
                  j:=Round(StrToFloat(Data,aFS)/1000)
                else
                  j:=Round(StrToFloat(Data,aFS));
                MeasurementData.Elapsed:=j;
                // An elapsed value of 0 or 86400 is considered a quirck of the measurement system: skip the data !!
                if
                (
                  //(newbatterydata.Elapsed=0) OR
                  (MeasurementData.Elapsed=86400) OR
                  (MeasurementData.Elapsed>CYCLETIME)
                )
                then
                begin
                  // This newbatterydata will NOT be used
                  MeasurementDatas.Delete(MeasurementData.Index);
                  continue;
                end;
                MeasurementData.Elapsed:=MeasurementData.Elapsed+aCycleTime;
              end;
            end;
            {$endif TIME}
          end;

          // Get the rest !!
          with DataArray[dtVoltage] do if Valid then
          begin
            if TryStrToFloat(Data,aDouble,aFS) then MeasurementData.Voltage:=aDouble;
          end;
          with DataArray[dtEnergy] do if Valid then
          begin
            if TryStrToFloat(Data,aDouble,aFS) then MeasurementData.Energy:=RoundTo(aDouble,-1);
          end;
          with DataArray[dtCurrent] do if Valid then
          begin
            if TryStrToFloat(Data,aDouble,aFS) then MeasurementData.Current:=aDouble;
          end;
          with DataArray[dtCapacity] do if Valid then
          begin
            if TryStrToFloat(Data,aDouble,aFS) then MeasurementData.Capacity:=RoundTo(aDouble,-1);
          end;
        end;// if Assigned(MeasurementDatas)

        // Flag that we are ready with the LocalProduct daya
        // This is used to skip invalid datapoints
        // Tricky
        if (aThresholdMode=TThresholdModes.tmMINV) then RunData.SaveEV:=True;

      end;// if Assigned(LocalProduct) then

    end;
  finally
    TempList.Free;
  end;

  // We now have a full list of LocalBatteries, including test and rundata from the text file data.
  // Process this list and save into database.

  // Sort !!
  Products.Sort(TCollectionSortCompare(@CompareProductName));
  for TCollectionItem(ProductRunner) in Products do
  begin
    TestDatas:=ProductRunner.TestDatas;
    for TCollectionItem(TestData) in TestDatas do
    begin
      RunDatas:=TestData.RunDatas;
      RunDatas.Sort(TCollectionSortCompare(@CompareRunDataSampleNumber));
    end;
  end;

  // Store in database, if any
  LocalProduct:=TProduct.Create(nil);
  try
    for TCollectionItem(ProductRunner) in Products do
    begin
      Success:=(Length(ProductRunner.B_code)>0); // trivial, but anyhow
      if Success then
      begin
        // Did we get a new LocalProduct ?
        // If so, add it
        LocalProduct.B_code:=ProductRunner.B_code;
        Success:=SharedmORMotData.GetProduct(LocalProduct);
        if (NOT Success) then
          Success:=SharedmORMotData.AddProduct(ProductRunner);
        // Now add the rundatas !!
        if Success then
        begin
          TestDatas:=ProductRunner.TestDatas;
          for TCollectionItem(TestData) in TestDatas do
          begin
            RunDatas:=TestData.RunDatas;
            for TCollectionItem(RunData) in RunDatas do
            begin
              SharedmORMotData.ProductService.AddRunData(ProductRunner.B_code,TestData.StageMode,TestData.SetValue,RunData);
            end;
          end;
        end;
      end;
    end;
  finally
    LocalProduct.Free;
  end;

  RefreshGUI;
end;

procedure TForm1.GetDataFromGridRow(Sender: TObject; ARowIndex: Longint);
var
  TestDatas        : TTestCollection;
  TestData         : TTestData;
  RunDatas         : TRunDataCollection;
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
    RunDataOverviewDrawGrid.BeginUpdate;
    RunDataOverviewDrawGrid.RowCount:=1;

    editVoltage.Text:='';
    editCapacity.Text:='';
    editEnergy.Text:='';
    editTime.Text:='';

    SelectedProduct:=Products.GetBatteryData(ARowIndex);

    if Assigned(SelectedProduct) then
    begin
      // Check for changes.
      if (SharedmORMotData.ChangedProduct(SelectedProduct,RefreshNeeded) AND RefreshNeeded) then
      begin
        // Due to version tracking, we now know that the battery has changed.
        // So, get the new data from the server !!
        SelectedProduct.TestDatas.Clear;
        SelectedProduct.Stages.Clear;
        SharedmORMotData.GetProduct(SelectedProduct);
      end;

      ProductVisual.SetAll(SelectedProduct);

      TestDatas:=SelectedProduct.TestDatas;
      for TCollectionItem(TestData) in TestDatas do
      begin
        RunDatas:=TestData.RunDatas;
        if RunDatas.Count=0 then
        begin
          // This willl retrieve rundata and the last value (summary) of the measurement data
          SharedmORMotData.GetProductRunDatas(RunDatas);
        end;

        RunDataOverviewDrawGrid.RowCount:=RunDataOverviewDrawGrid.RowCount+RunDatas.Count;
      end;

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

      RunDataOverviewDrawGrid.EndUpdate;
    end;
    VST5.InvalidateColumn(1);

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
    if (Sender=RunDataOverviewDrawGrid) then aCustomRow:=ARowIndex;
    if GetRunDataFromGridRow(SelectedProduct,aCustomRow,SelectedTestData,SelectedRunData) then
    begin
      editVoltage.Text:=FloattoStrF(SelectedRunData.MeasuredVoltage,ffFixed,8,3)+' [V]';
      editCapacity.Text:=FloattoStrF(SelectedRunData.MeasuredCapacity,ffFixed,8,1)+' ['+CapacityIdentifier+']';
      editEnergy.Text:=FloattoStrF(SelectedRunData.MeasuredEnergy,ffFixed,8,1)+' ['+EnergyIdentifier+']';
      //editTime.Text:=FloattoStrF(SelectedRunData.MeasuredElapsed,ffFixed,8,0)+' [sec]';

      if Sender=RunDataOverviewDrawGrid then
      begin
        // Retrieve all rundata when selected
        if (SelectedRunData.NewLiveData.Count<=1) then
        begin
          // This willl retrieve rundata and all of the measurement data
          SharedmORMotData.GetProductRunData(SelectedRunData);
        end;
      end;
    end;
  end;

end;

function TForm1.GetRunDataFromGridRow(const Battery:TProduct; const aRow:longint; out aTestData:TTestData;out aRunData:TRundata):boolean;
var
  TestDatas    : TTestCollection;
  TestData     : TTestData;
  RunData      : TRunData;
  RunDatas     : TRunDataCollection;
  indexer      : integer;
  found        : boolean;
begin
  if (aRow=0) then exit;
  indexer:=0;
  found:=false;
  TestDatas:=Battery.TestDatas;
  for TCollectionItem(TestData) in TestDatas do
  begin
    RunDatas:=TestData.RunDatas;
    for TCollectionItem(RunData) in RunDatas do
    begin
       Inc(indexer);
       if indexer=aRow then Found:=true;
       if found then
       begin
         aRunData:=RunData;
         break;
       end;
    end;
    if found then
    begin
      aTestData:=TestData;
      break;
    end;
  end;

  if found then
  begin
    // Store final measurement data for easy GUI
    indexer:=(ARunData.NewLiveData.Count-1);
    if (indexer>=0) then
    begin
      ARunData.MeasuredVoltage:=ARunData.NewLiveData.Item[indexer].Voltage;
      ARunData.MeasuredCurrent:=ARunData.NewLiveData.Item[indexer].Current;
      ARunData.MeasuredCapacity:=ARunData.NewLiveData.Item[indexer].Capacity;
      ARunData.MeasuredEnergy:=ARunData.NewLiveData.Item[indexer].Energy;
      //ARunData.MeasuredElapsed:=ARunData.NewLiveData.Item[indexer].Elapsed;
    end;
  end;

  result:=found;
end;

procedure TForm1.RefreshGUI;
begin
  SelectedProduct:=nil;
  SelectedTestData:=nil;
  SelectedRunData:=nil;
  ProductDrawGrid.RowCount:=Products.Count+1;
  ProductDrawGrid.Invalidate;
  if Products.Count>0 then GetDataFromGridRow(ProductDrawGrid,ProductDrawGrid.Row);
end;

procedure TForm1.ExportRawData(aProductCode:string);
var
  F                   : textfile;
  s,localfilename     : string;
  i,j                 : integer;
  samplenumber        : integer;
  runcount,batcount   : integer;
  LocalProduct        : TProduct;
  TestDatas           : TTestCollection;
  TestData            : TTestData;
  RunData             : TRunData;
  RunDatas            : TRunDataCollection;
  MeasurementData     : TMeasurementData;
  MeasurementDatas    : TNewLiveDataCollection;
begin
  Products.AddOrUpdate(aProductCode,False,LocalProduct);
  if NOT Assigned(LocalProduct) then exit;
  if NOT Assigned(SelectedTestData) then exit;

  localfilename:='exportallrundata.csv';
  AssignFile(F,localfilename);

  try
    if FileExists(localfilename)
       then Append(F)
       else
       begin
         Rewrite(F);
         with Formatsettings do
         begin
           write(F,'B_code',ListSeparator);
           write(F,'B_name',ListSeparator);
           write(F,'B_type',ListSeparator);
           write(F,'B_id',ListSeparator);
           write(F,'Test_id',ListSeparator);
           write(F,'Brand#',ListSeparator);
           write(F,'Sample#',ListSeparator);
           write(F,'Total discharge time(sec)',ListSeparator);
           write(F,'Capacity(mAh)',ListSeparator);
           write(F,'Voltage',ListSeparator);
           write(F,'Energy',ListSeparator);
           write(F,'Cycle',ListSeparator);
           write(F,'Environment temperature (°C)',ListSeparator);
           write(F,'Environment humidity (%RH)',ListSeparator);
           write(F,'Board',ListSeparator);
           write(F,'Position in board',ListSeparator);

           write(F,'Battery mode',ListSeparator);
           write(F,'Battery mode value',ListSeparator);

           write(F,'Trigger moment UTC',ListSeparator);
           write(F,'Trigger source type',ListSeparator);
           write(F,'Trigger source value',ListSeparator);
         end;
         writeln(F);
       end;

    TestDatas:=LocalProduct.TestDatas;
    for TCollectionItem(TestData) in TestDatas do
    begin
      if (TestData.StageMode=SelectedTestData.StageMode) AND (TestData.SetValue=SelectedTestData.SetValue) then
      begin
        RunDatas:=TestData.RunDatas;

        // Get the rundata summaries when needed
        if RunDatas.Count=0 then SharedmORMotData.GetProductRunDatas(RunDatas);

        if RunDatas.Count=0 then continue;

        samplenumber:=0;

        for TCollectionItem(RunData) in RunDatas do
        begin
          if (RunData.DataInvalid) AND (chkValidOnly.Checked) then continue;

          // Retrieve all rundata when needed
          if (RunData.NewLiveData.Count<=1) then SharedmORMotData.GetProductRunData(RunData);

          MeasurementDatas:=RunData.NewLiveData;

          if MeasurementDatas.Count=0 then continue;

          Inc(samplenumber);

          batcount:=MeasurementDatas.Count;
          Dec(batcount);

          // Add other trigger data
          for j:=0 to batcount do
          begin
            MeasurementData:=MeasurementDatas.Item[j];
            with Formatsettings do
            begin
              // Write general data
              write(F,LocalProduct.B_code,ListSeparator);
              write(F,LocalProduct.B_name,ListSeparator);
              write(F,LocalProduct.B_type,ListSeparator);
              write(F,LocalProduct.B_id,ListSeparator);
              write(F,TestData.TestID,ListSeparator);
              write(F,'-',ListSeparator);
              write(F,samplenumber,ListSeparator);

              // Write LocalProduct data
              write(F,MeasurementData.Elapsed,ListSeparator);
              write(F,FloattoStrF(MeasurementData.Capacity,ffFixed,10,3),ListSeparator);
              write(F,FloattoStrF(MeasurementData.Voltage,ffFixed,10,5),ListSeparator);
              write(F,FloattoStrF(MeasurementData.Energy,ffFixed,10,3),ListSeparator);

              // Write miscellaneous data
              write(F,RunData.Cycles,ListSeparator);  // Cycle
              write(F,20,ListSeparator); // temperature
              write(F,65,ListSeparator); // humidity

              // Write extra rundata
              write(F,rundata.BoardSerial,ListSeparator);
              write(F,'-',ListSeparator);
              write(F,DischargeTypeTextCompat[TestData.StageMode],ListSeparator);
              write(F,TestData.SetValue,ModeUnits[TestData.StageMode],ListSeparator);

              if (j=batcount) then
              begin
                write(F,FloattoStrF(TestData.Date,ffFixed,16,10),ListSeparator);
                write(F,ThresholdNames[TThresholdModes.tmMINV],ListSeparator);
                write(F,Round(MeasurementData.Voltage*1000),ThresholdIdentifiers[TThresholdModes.tmMINV],ListSeparator);
              end;

            end;
            writeln(F);
          end;
        end;
      end;
    end;
  finally
    CloseFile(F);
  end;
end;

procedure TForm1.btnImportClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'Database Files (*.db3;*.db)|*.db3;*.db';
  if OpenDialog1.Execute then
  begin
    SharedmORMotData.ImportDatabase(OpenDialog1.FileName,Products);
  end;
end;


end.

