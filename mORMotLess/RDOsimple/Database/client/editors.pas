unit editors;

//{$MODE Delphi}

// Utility unit for the advanced Virtual Treeview demo application which contains the implementation of edit link
// interfaces used in other samples of the demo.

interface

uses
  Windows,
  LCLIntf, LCLType, LMessages,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, MaskEdit,
  Laz.VirtualTrees;

const
  // Decoupling message for auto-adjusting the internal edit window.
  CM_AUTOADJUST = CM_BASE + 2005;
  FALSETRUETEXT    : array[boolean] of string = ('No','Yes');
  FALSETRUESYMBOL  : array[boolean] of string = ('-','x');

type
  // Describes the type of value a property tree node stores in its data property.
  TValueType = (
    vtNone,
    vtString,
    vtPickString,
    vtNumber,
    vtFloat,
    vtMemo,
    vtDate,
    vtBooleanText,
    vtBooleanSymbol,
    vtBooleanCheck
  );

type
  // Node data record for the the document properties treeview.
  PPropertyData = ^TPropertyData;
  TPropertyData = record
    Title: String[255];
    ValueType: TValueType;
    Value: String[255];      // This value can actually be a date or a number too.
    PickList: String[255];
    Changed: Boolean;
  end;

  // Our own edit link to implement several different node editors.

  { TPropertyEditLink }

  TPropertyEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit       : TWinControl;           // One of the property editor classes.
    FTree       : TLazVirtualStringTree; // A back reference to the tree calling.
    FNode       : PVirtualNode;          // The node being edited.
    FColumn     : Integer;             // The column of the node being edited.
    FTextBounds : TRect;              // Smallest rectangle around the text.
    FPData      : PPropertyData;
    FStopping   : Boolean;              // Set to True when the edit link requests stopping the edit action.
  protected
    procedure SetOnEditDone(DoneProc:TNotifyEvent);
    procedure EditingDone(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    destructor Destroy; override;

    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;

  TMyStringEditLink = class(TStringEditLink)
  public
    function BeginEdit: Boolean; override; stdcall;
    function EndEdit: Boolean; override; stdcall;
  end;

  // Edit support classes.
  TMemoEditLink = class;

  TVTMemoEdit = class(TCustomMemo)
  private
    procedure CMAutoAdjust(var {%H-}Message: TLMessage); message CM_AUTOADJUST;
    procedure CMExit(var {%H-}Message: TLMessage); message CM_EXIT;
    procedure CNCommand(var Message: TLMCommand); message CN_COMMAND;
    procedure DoRelease({%H-}Data: PtrInt);
    procedure WMChar(var Message: TLMChar); message LM_CHAR;
    procedure WMDestroy(var Message: TLMDestroy); message LM_DESTROY;
    procedure WMGetDlgCode(var Message: TLMNoParams); message LM_GETDLGCODE;
    procedure WMKeyDown(var Message: TLMKeyDown); message LM_KEYDOWN;
  protected
    FRefLink: IVTEditLink;
    FLink: TMemoEditLink;
    procedure AutoAdjustSize; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(Link: TMemoEditLink); reintroduce;

    procedure Release; virtual;

    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property CharCase;
    //property HideSelection;
    property MaxLength;
    //property OEMConvert;
  end;

  TMemoEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TVTMemoEdit;                  // A normal custom edit control.
  protected
    FTree: TLazVirtualStringTree; // A back reference to the tree calling.
    FNode: PVirtualNode;             // The node to be edited.
    FPData: PPropertyData;
    FColumn: TColumnIndex;           // The column of the node.
    FAlignment: TAlignment;
    FTextBounds: TRect;              // Smallest rectangle around the text.
    FStopping: Boolean;              // Set to True when the edit link requests stopping the edit action.
    procedure SetEdit(const Value: TVTMemoEdit); // Setter for the FEdit member;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;

    //property Node  : PVirtualNode read FNode; // [IPK] Make FNode accessible
    //property Column: TColumnIndex read FColumn; // [IPK] Make Column(Index) accessible
  end;

implementation

uses
  Types,
  Math,
  DateTimePicker;

type
  TVirtualStringTreeAccess = class(TLazVirtualStringTree);

destructor TPropertyEditLink.Destroy;
begin
  if (Assigned(FEdit) AND (FEdit.HandleAllocated)) then Application.ReleaseComponent(FEdit);
  inherited;
end;

procedure TPropertyEditLink.EditingDone(Sender: TObject);
begin
  //exit;
  if Assigned(FTree) then
  begin
    if FTree.IsEditing then
      FTree.EndEditNode;
  end;
end;

procedure TPropertyEditLink.EditMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TPropertyEditLink.SetOnEditDone(DoneProc:TNotifyEvent);
var
  EditingDoneSet:boolean;
begin
  EditingDoneSet:=false;

  //if FEdit.InheritsFrom(TComboBox)

  if Assigned(FEdit) then
  begin
    if (FEdit is TComboBox) then
    begin
      TComboBox(FEdit).OnEditingDone:=DoneProc;
      EditingDoneSet:=true;
    end;
    if (FEdit is TEdit) then
    begin
      TEdit(FEdit).OnEditingDone:=DoneProc;
      EditingDoneSet:=true;
    end;
    if (FEdit is TMemo) then
    begin
      TMemo(FEdit).OnEditingDone:=DoneProc;
      EditingDoneSet:=true;
    end;
    if (FEdit is TCheckBox) then
    begin
      TCheckBox(FEdit).OnEditingDone:=DoneProc;
      EditingDoneSet:=true;
    end;

    if EditingDoneSet then
      FEdit.OnExit:=nil
    else
      FEdit.OnExit:=DoneProc
  end;
end;

procedure TPropertyEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  CanAdvance: Boolean;
  node: PVirtualNode;
  col: TColumnIndex;
  GetStartColumn: function(ConsiderAllowFocus: Boolean = False): TColumnIndex of object;
  GetNextColumn: function(Column: TColumnIndex; ConsiderAllowFocus: Boolean = False): TColumnIndex of object;
  GetNextNode: TGetNextNodeProc;
  EditReady: Boolean;
begin
  CanAdvance := true;
  
  case Key of
    VK_ESCAPE:
      if CanAdvance then
      begin
        FTree.CancelEditNode;
        Key := 0;
      end;

    VK_RETURN:
      begin
        EditReady := not (vsMultiline in FNode^.States);

        if (not EditReady) then
        begin
          // If a multiline node is being edited the finish editing only if Ctrl+Enter was pressed,
          // otherwise allow to insert line breaks into the text.
          EditReady := ssCtrl in Shift;
        end;
        if EditReady then
        begin
          if CanAdvance then
          begin
            FTree.InvalidateNode(FNode);
            //if FTree.IsEditing then FTree.EndEditNode;
            FTree.SetFocus;
          end;
        end;
      end;

    VK_UP,
    VK_DOWN:
      begin
        // Consider special cases before finishing edit mode.
        CanAdvance := Shift = [];
        if FEdit is TComboBox then
          CanAdvance := CanAdvance and not TComboBox(FEdit).DroppedDown;
        //todo: there's no way to know if date is being edited in LCL
        //if FEdit is TDateEdit then
        //  CanAdvance := CanAdvance and not TDateEdit(FEdit).DroppedDown;

        if CanAdvance then
        begin
          // Forward the keypress to the tree. It will asynchronously change the focused node.
          PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
          Key := 0;
        end;
      end;

    VK_TAB:
      if CanAdvance then
      begin
        FTree.InvalidateNode(FNode);
        if ssShift in Shift then
        begin
          GetStartColumn := @FTree.Header.Columns.GetLastVisibleColumn;
          GetNextColumn := @FTree.Header.Columns.GetPreviousVisibleColumn;
          GetNextNode := @FTree.GetPreviousVisible;
        end
        else
        begin
          GetStartColumn := @FTree.Header.Columns.GetFirstVisibleColumn;
          GetNextColumn := @FTree.Header.Columns.GetNextVisibleColumn;
          GetNextNode :=@FTree.GetNextVisible;
        end;

        // Advance to next/previous visible column/node.
        node := FNode;
        col := GetNextColumn(FColumn, True);
        repeat
          // Find a column for the current node which can be focused.
          while (col > NoColumn) and
          {$PUSH}
          {$OBJECTCHECKS OFF}
            not TVirtualStringTreeAccess(FTree).DoFocusChanging(FNode, node, FColumn, col)
          {$POP}
          do
            col := GetNextColumn(col, True);

          if col > NoColumn then
          begin
            // Set new node and column in one go.
            {$PUSH}
            {$OBJECTCHECKS OFF}
            TVirtualStringTreeAccess(FTree).SetFocusedNodeAndColumn(node, col);
            {$POP}
            Break;
          end;

          // No next column was accepted for the current node. So advance to next node and try again.
          node := GetNextNode(node);
          col := GetStartColumn();
        until node = nil;

        FTree.EndEditNode;
        Key := 0;
        if node <> nil then
        begin
          FTree.FocusedNode := node;
          FTree.FocusedColumn := col;
        end;
        if FTree.CanEdit(FTree.FocusedNode, FTree.FocusedColumn) then
          {$PUSH}
          {$OBJECTCHECKS OFF}
          with TVirtualStringTreeAccess(FTree) do
          begin
            EditColumn := FocusedColumn;
            DoEdit;
          end;
        {$POP}
      end;

  end;
end;

function TPropertyEditLink.BeginEdit: Boolean; stdcall;
begin
  Result := not FStopping;
  if Result then
  begin
    FEdit.Show;
    FEdit.SetFocus;
    if (FEdit is TComboBox) then TComboBox(FEdit).DroppedDown:=True;
  end;
end;

function TPropertyEditLink.CancelEdit: Boolean; stdcall;
begin
  Result := not FStopping;
  if Result then
  begin
    FStopping := True;
    FEdit.Hide;
    FTree.CancelEditNode;
  end;
end;

function TPropertyEditLink.EndEdit: Boolean; stdcall;
var
  S: String;
  B: boolean;
begin
  Result := not FStopping;

  if Result then
  try
    FStopping := True;

    if FPData^.ValueType=vtBooleanText then
    begin
      B:=StrToBoolDef(TComboBox(FEdit).Text,false);
      S:=BoolToStr(B,True);
    end
    else
    if FEdit is TComboBox then
    begin
      S := TComboBox(FEdit).Text
    end
    else
    if FEdit is TCheckBox then
    begin
      if FPData^.ValueType=vtBooleanText then S := FALSETRUETEXT[TCheckBox(FEdit).Checked];
      if FPData^.ValueType=vtBooleanSymbol then S := FALSETRUESYMBOL[TCheckBox(FEdit).Checked];
    end
    else
    if FEdit is TDateTimePicker then
      S := DateToStr(TDateTimePicker(FEdit).Date)
    else
    begin
      if FEdit is TCustomEdit then
        S := TCustomEdit(FEdit).Text
      else
        raise Exception.Create('Unknow edit control');
    end;

    if (S<>FPData^.Value) then
    begin
      FPData^.Value := S;
      FPData^.Changed := True;
      FTree.InvalidateNode(FNode);
    end;

    FEdit.Hide;

    if (NOT FTree.Focused) then
    begin
      if FTree.CanFocus then FTree.SetFocus;
    end;

  except
    FStopping := False;
    raise;
  end;

end;

function TPropertyEditLink.GetBounds: TRect; stdcall;
begin
  Result := FEdit.BoundsRect;
end;

function TPropertyEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex): Boolean; stdcall;
var
  NodeText: String;
  aDate:TDate;
begin
  Result   := True;

  FTree    := (Tree as TLazVirtualStringTree);
  FNode    := Node;
  FColumn  := Column;
  FPData   := FTree.GetNodeData(Node);

  NodeText := FPData^.Value;
  UniqueString(NodeText);

  // determine what edit type actually is needed
  FEdit.Free;
  FEdit := nil;

  case FPData^.ValueType of
    vtPickString:
      begin
        FEdit := TComboBox.Create(nil);
        with FEdit as TComboBox do
        begin
          Items.CommaText:=FPData^.PickList;
          ItemIndex:=Items.IndexOf(NodeText);
          Text := NodeText;
        end;
      end;
    vtBooleanCheck:
      begin
        FEdit := TCheckBox.Create(nil);
        with FEdit as TCheckBox do
        begin
          Checked := (FPData^.Value=FALSETRUESYMBOL[True]);
        end;
      end;
    vtBooleanText,vtBooleanSymbol:
      begin
        FEdit := TComboBox.Create(nil);
        with FEdit as TComboBox do
        begin
          Text := NodeText;
          if FPData^.ValueType=vtBooleanText then
          begin
            Items.Add(FALSETRUETEXT[True]);
            Items.Add(FALSETRUETEXT[False]);
          end;
          if FPData^.ValueType=vtBooleanSymbol then
          begin
            Items.Add(FALSETRUESYMBOL[True]);
            Items.Add(FALSETRUESYMBOL[False]);
          end;
          DroppedDown:=True;
        end;
      end;
    vtDate:
      begin
        FEdit := TDateTimePicker.Create(nil);
        with FEdit as TDateTimePicker do
        begin
          if TryStrToDate(NodeText,aDate) then
            Date:=aDate;
        end;
      end;
  else
    Result := False;
  end;
  if Result then
  begin
    if Assigned(FEdit) then
    begin
      // Initial size, font and text of the node.
      //FTree.GetTextInfo(Node, Column, FEdit.Font, FTextBounds, NodeText);
      //FEdit.Font.Color := clWindowText;
      FEdit.Visible := False;
      FEdit.Parent := Tree;
      FEdit.HandleNeeded;
      FEdit.OnKeyDown := @EditKeyDown;
      SetOnEditDone(@EditingDone);
    end;
  end;
end;

procedure TPropertyEditLink.SetBounds(R: TRect); stdcall;
var
  Dummy: Integer;
begin
  // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
  // we have to set the edit's width explicitly to the width of the column.
  FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
  if FEdit is TDateTimePicker then
    R.Right := R.Right - TDateTimePicker(FEdit).Width;
  if FEdit is TCheckBox then
    R.Right := R.Right - TCheckBox(FEdit).Width+1000;
  FEdit.BoundsRect := R;
end;

procedure TPropertyEditLink.ProcessMessage(var Message: TMessage); stdcall;
begin
  FEdit.WindowProc(Message);
end;

function TMyStringEditLink.BeginEdit: Boolean; stdcall;
var
  S      : string;
  FPData : PPropertyData;
begin
  result:=inherited;
  if result then
  begin
    FPData:=FTree.GetNodeData(Node);
    Edit.NumbersOnly:=(FPData^.ValueType=vtNumber);
  end;
end;

function TMyStringEditLink.EndEdit: Boolean; stdcall;
var
  S      : string;
  FPData : PPropertyData;
begin
  result:=inherited;
  if result then
  begin
    //S := FTree.Text[Node, Column];
    S := Edit.Text;
    FPData:=FTree.GetNodeData(Node);
    if (S<>FPData^.Value) then
    begin
      FPData^.Value := S;
      FPData^.Changed := True;
      FTree.InvalidateNode(FNode);
    end;
  end;
end;

constructor TVTMemoEdit.Create(Link: TMemoEditLink);
begin
  inherited Create(nil);
  ShowHint := False;
  ParentShowHint := False;
  // This assignment increases the reference count for the interface.
  FRefLink := Link;
  // This reference is used to access the link.
  FLink := Link;
end;

procedure TVTMemoEdit.CMAutoAdjust(var Message: TLMessage);
begin
  AutoAdjustSize;
end;

procedure TVTMemoEdit.CMExit(var Message: TLMessage);
begin
  if Assigned(FLink) and not FLink.FStopping then
    with FLink do
    begin
      if (toAutoAcceptEditChange in FTree.TreeOptions.StringOptions) then
      {$PUSH}
      {$OBJECTCHECKS OFF}
      TVirtualStringTreeAccess(FTree).DoEndEdit
      {$POP}
      else
      {$PUSH}
      {$OBJECTCHECKS OFF}
      TVirtualStringTreeAccess(FTree).DoCancelEdit;
      {$POP}
    end;
end;

procedure TVTMemoEdit.CNCommand(var Message: TLMCommand);
begin
  if Assigned(FLink) and Assigned(FLink.FTree) and (Message.NotifyCode = EN_UPDATE) and
    not (vsMultiline in FLink.FNode^.States) then
    // Instead directly calling AutoAdjustSize it is necessary on Win9x/Me to decouple this notification message
    // and eventual resizing. Hence we use a message to accomplish that.
    AutoAdjustSize()
  else
    inherited;
end;

procedure TVTMemoEdit.DoRelease(Data: PtrInt);
begin
  Free;
end;

procedure TVTMemoEdit.WMChar(var Message: TLMChar);
begin
  if not (Message.CharCode in [VK_ESCAPE, VK_TAB]) then
    inherited;
end;

procedure TVTMemoEdit.WMDestroy(var Message: TLMDestroy);
begin
  // If editing stopped by other means than accept or cancel then we have to do default processing for
  // pending changes.
  if Assigned(FLink) and not FLink.FStopping then
  begin
    with FLink, FTree do
    begin
      if (toAutoAcceptEditChange in TreeOptions.StringOptions) and Modified then
        Text[FNode, FColumn] := FEdit.Text;
    end;
    FLink := nil;
    FRefLink := nil;
  end;
  inherited;
end;

procedure TVTMemoEdit.WMGetDlgCode(var Message: TLMNoParams);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS;
end;

procedure TVTMemoEdit.WMKeyDown(var Message: TLMKeyDown);
// Handles some control keys.
var
  Shift: TShiftState;
  EndEdit: Boolean;
  Tree: TBaseVirtualTree;
  NextNode: PVirtualNode;
begin
  Tree := FLink.FTree;
  case Message.CharCode of
    VK_ESCAPE:
      begin
        {$PUSH}
        {$OBJECTCHECKS OFF}
        TVirtualStringTreeAccess(Tree).DoCancelEdit;
        {$POP}
        Tree.SetFocus;
      end;
    VK_RETURN:
      begin
        EndEdit := not (vsMultiline in FLink.FNode^.States);
        if not EndEdit then
        begin
          // If a multiline node is being edited the finish editing only if Ctrl+Enter was pressed,
          // otherwise allow to insert line breaks into the text.
          Shift := KeyDataToShiftState(Message.KeyData);
          EndEdit := ssCtrl in Shift;
        end;
        if EndEdit then
        begin
          Tree := FLink.FTree;
          FLink.FTree.InvalidateNode(FLink.FNode);
          {$PUSH}
          {$OBJECTCHECKS OFF}
          TVirtualStringTreeAccess(FLink.FTree).DoEndEdit;
          {$POP}
          Tree.SetFocus;
        end;
      end;
    VK_UP:
      begin
        if not (vsMultiline in FLink.FNode^.States) then
          Message.CharCode := VK_LEFT;
        inherited;
      end;
    VK_DOWN:
      begin
        if not (vsMultiline in FLink.FNode^.States) then
          Message.CharCode := VK_RIGHT;
        inherited;
      end;
    VK_TAB:
      begin
        if Tree.IsEditing then
        begin
          Tree.InvalidateNode(FLink.FNode);
          NextNode := Tree.GetNextVisible(FLink.FNode, True);
          Tree.EndEditNode;
          Tree.FocusedNode := NextNode;
          if Tree.CanEdit(Tree.FocusedNode, Tree.FocusedColumn) then
            {$PUSH}
            {$OBJECTCHECKS OFF}
            TVirtualStringTreeAccess(Tree).DoEdit;
            {$POP}
        end;
      end;
    Ord('A'):
      begin
        if Tree.IsEditing and ([ssCtrl] = KeyDataToShiftState(Message.KeyData) {KeyboardStateToShiftState}) then
        begin
          Self.SelectAll();
          Message.CharCode := 0;
        end;
      end;
  else
    inherited;
  end;
end;

procedure TVTMemoEdit.AutoAdjustSize;
// Changes the size of the edit to accomodate as much as possible of its text within its container window.
// NewChar describes the next character which will be added to the edit's text.
var
  DC: HDC;
  Size: TSize;
  LastFont: THandle;
begin
  if not (vsMultiline in FLink.FNode^.States) and not (toGridExtensions in FLink.FTree.TreeOptions.MiscOptions{see issue #252}) then
  begin
    DC := GetDC(Handle);
    LastFont := SelectObject(DC, Font.Reference.Handle);
    try
      // Read needed space for the current text.
      GetTextExtentPoint32(DC, PChar(Text), Length(Text), {%H-}Size);
      Inc(Size.cx, 2 * FLink.FTree.TextMargin);
      Inc(Size.cy, 2 * FLink.FTree.TextMargin);
      Height := Max(Size.cy, Height); // Ensure a minimum height so that the edit field's content and cursor are displayed correctly. See #159
      // Repaint associated node if the edit becomes smaller.
      if Size.cx < Width then
        FLink.FTree.Invalidate();

      if FLink.FAlignment = taRightJustify then
        FLink.SetBounds(Rect(Left + Width - Size.cx, Top, Left + Width, Top + Height))
      else
        FLink.SetBounds(Rect(Left, Top, Left + Size.cx, Top + Height));
    finally
      SelectObject(DC, LastFont);
      ReleaseDC(Handle, DC);
    end;
  end;
end;

procedure TVTMemoEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  // Only with multiline style we can use the text formatting rectangle.
  // This does not harm formatting as single line control, if we don't use word wrapping.
  with Params do
  begin
    //todo: delphi uses Multiline for all
    //Style := Style or ES_MULTILINE;
    if vsMultiline in FLink.FNode^.States then
    begin
      Style := Style and not (ES_AUTOHSCROLL or WS_HSCROLL) or WS_VSCROLL or ES_AUTOVSCROLL;
      Style := Style or ES_MULTILINE;
    end;
    if tsUseThemes in FLink.FTree.TreeStates then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end
    else
    begin
      Style := Style or WS_BORDER;
      ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TVTMemoEdit.Release;
begin
  //if HandleAllocated then
  //  Application.QueueAsyncCall(DoRelease, 0);
end;

//----------------- TMemoEditLink ------------------------------------------------------------------------------------

constructor TMemoEditLink.Create;
begin
  inherited;
  FEdit := TVTMemoEdit.Create(Self);
  with FEdit do
  begin
    Visible := False;
    //BorderStyle := bsSingle;
    AutoSize := False;
  end;
end;

destructor TMemoEditLink.Destroy;
begin
  //if Assigned(FEdit) then FEdit.Release;
  if (Assigned(FEdit) AND (FEdit.HandleAllocated)) then Application.ReleaseComponent(FEdit);
  inherited;
end;

function TMemoEditLink.BeginEdit: Boolean; stdcall;
// Notifies the edit link that editing can start now. descendants may cancel node edit
// by returning False.
begin
  Result := not FStopping;
  if Result then
  begin
    FEdit.Show;
    FEdit.SelectAll;
    FEdit.SetFocus;
    FEdit.AutoAdjustSize;
  end;
end;

procedure TMemoEditLink.SetEdit(const Value: TVTMemoEdit);
begin
  if Assigned(FEdit) then
    FEdit.Free;
  FEdit := Value;
end;

function TMemoEditLink.CancelEdit: Boolean; stdcall;
begin
  Result := not FStopping;
  if Result then
  begin
    FStopping := True;
    FEdit.Hide;
    FTree.CancelEditNode;
    FEdit.FLink := nil;
    FEdit.FRefLink := nil;
  end;
end;

function TMemoEditLink.EndEdit: Boolean; stdcall;
begin
  Result := not FStopping;
  if Result then
  try
    FStopping := True;
    if FEdit.Modified then
    begin
      FTree.Text[FNode, FColumn] := FEdit.Lines.Text;
      if (FEdit.Text<>FPData^.Value) then
      begin
        //FEdit.Lines.TextLineBreakStyle:=TTextLineBreakStyle.tlbsCRLF;
        FPData^.Value := FEdit.Lines.Text;
        FPData^.Changed := True;
        FTree.InvalidateNode(FNode);
      end;
    end;
    FEdit.Hide;
    FEdit.FLink := nil;
    FEdit.FRefLink := nil;
  except
    FStopping := False;
    raise;
  end;
end;

function TMemoEditLink.GetBounds: TRect; stdcall;

begin
  Result := FEdit.BoundsRect;
end;

function TMemoEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
// Retrieves the true text bounds from the owner tree.
var
  Text: String;
begin
  Result := Tree is TCustomVirtualStringTree;
  if Result then
  begin
    if not Assigned(FEdit) then
    begin
      FEdit := TVTMemoEdit.Create(Self);
      FEdit.Visible := False;
      //FEdit.BorderStyle := bsSingle;
      FEdit.AutoSize := False;
    end;
    //FTree := Tree as TCustomVirtualStringTree;
    FTree := (Tree as TLazVirtualStringTree);
    FNode := Node;
    FColumn := Column;
    FPData   := FTree.GetNodeData(FNode);
    // Initial size, font and text of the node.
    FTree.GetTextInfo(Node, Column, FEdit.Font, FTextBounds, Text);
    //FEdit.Font.Color := clWindowText;
    FEdit.Parent := Tree;
    FEdit.HandleNeeded;
    FEdit.Text := Text;

    if Column <= NoColumn then
    begin
      FEdit.BidiMode := FTree.BidiMode;
      FAlignment := FTree.Alignment;
    end
    else
    begin
      FEdit.BidiMode := FTree.Header.Columns[Column].BidiMode;
      FAlignment := FTree.Header.Columns[Column].Alignment;
    end;

    //if FEdit.BidiMode <> bdLeftToRight then
    //  ChangeBidiModeAlignment(FAlignment);
  end;
end;

procedure TMemoEditLink.ProcessMessage(var Message: TLMessage); stdcall;
begin
  FEdit.WindowProc(Message);
end;

procedure TMemoEditLink.SetBounds(R: TRect); stdcall;
// Sets the outer bounds of the edit control and the actual edit area in the control.
var
  lOffset: Integer;
begin
  if not FStopping then
  begin
    // Set the edit's bounds but make sure there's a minimum width and the right border does not
    // extend beyond the parent's left/right border.
    if R.Left < 0 then
      R.Left := 0;
    if R.Right - R.Left < 30 then
    begin
      if FAlignment = taRightJustify then
        R.Left := R.Right - 30
      else
        R.Right := R.Left + 30;
    end;
    if R.Right > FTree.ClientWidth then
      R.Right := FTree.ClientWidth;
    FEdit.BoundsRect := R;

    // The selected text shall exclude the text margins and be centered vertically.
    // We have to take out the two pixel border of the edit control as well as a one pixel "edit border" the
    // control leaves around the (selected) text.
    R := FEdit.ClientRect;
    lOffset := IfThen(vsMultiline in FNode^.States, 0, 2);
    if tsUseThemes in FTree.TreeStates then
      Inc(lOffset);
    InflateRect(R, -FTree.TextMargin + lOffset, lOffset);
    if not (vsMultiline in FNode^.States) then
      Types.OffsetRect(R, 0, FTextBounds.Top - FEdit.Top);
    R.Top := Max(-1, R.Top); // A value smaller than -1 will prevent the edit cursor from being shown by Windows, see issue #159
    R.Left := Max(-1, R.Left);
    SendMessage(FEdit.Handle, EM_SETRECTNP, 0, {%H-}LPARAM(@R));
  end;
end;


procedure InitBools;
begin
  if (Length(TrueBoolStrs)<3) then
  begin
    SetLength(TrueBoolStrs,3);
    TrueBoolStrs[0]:='True';
    TrueBoolStrs[1]:=FALSETRUETEXT[True];
    TrueBoolStrs[2]:=FALSETRUESYMBOL[True];

  end;
  if (Length(FalseBoolStrs)<3) then
  begin
    SetLength(FalseBoolStrs,3);
    FalseBoolStrs[0]:='False';
    FalseBoolStrs[1]:=FALSETRUETEXT[False];
    FalseBoolStrs[2]:=FALSETRUESYMBOL[False];
  end;
end;

initialization
  InitBools;

end.
