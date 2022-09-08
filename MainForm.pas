unit MainForm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ToolWin, ComCtrls, ExtCtrls, Buttons, Grids, ImgList, Menus,
  ShellAPI, ShlObj, MonitorThread;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    StatusBar1: TStatusBar;
    Panel4: TPanel;
    txtAddress: TEdit;
    SpeedButton1: TSpeedButton;
    TreeView1: TTreeView;
    ListView1: TListView;
    panError: TPanel;
    panCustom: TPanel;
    Splitter2: TSplitter;
    ListBox1: TListBox;
    Notebook1: TNotebook;
    RichEdit1: TMemo;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    StringGrid1: TStringGrid;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    Refresh1: TMenuItem;
    Refresh2: TMenuItem;
    File1: TMenuItem;
    NewWindow1: TMenuItem;
    ComboBox1: TComboBox;
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure txtAddressKeyPress(Sender: TObject; var Key: Char);
    procedure ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListBox1Click(Sender: TObject);
    procedure ListView1Deletion(Sender: TObject; Item: TListItem);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1DblClick(Sender: TObject);
    procedure TreeView1Deletion(Sender: TObject; Node: TTreeNode);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
    procedure Panel4Resize(Sender: TObject);
    procedure NewWindow1Click(Sender: TObject);
    procedure TreeView1Expanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    FPath: String;
    FSortKey, FSortOrder: Integer;
    FListMonitor: TMonitorThread;
    procedure BuildListView;
    procedure BuildTreeRoot;
    procedure BuildOneTreeLevel(Parent: TTreeNode);
    function GetNodePath(Node: TTreeNode): String;
  protected
    procedure WMListViewChanged(var Msg: TMessage); message WM_USER + 1;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses prop1, engine;

{$R *.lfm}

function AttrToStr(attr: Integer): String;
const
  fa: array [1..6] of Char = ('R', 'H', 'S', 'V', 'D', 'A');
  ma: array [1..6] of Integer = (1, 2, 4, 8, 16, 32);
var
  i: Integer;
begin
  Result := '';
  for i := 1 to 6 do
    if (attr and ma[i]) <> 0 then
      Result := Result + fa[i]
    else
      Result := Result + '-';
end;

{ TForm1 }

procedure TForm1.BuildListView;
var
  sr: TSearchRec;
begin
  if Assigned(FListMonitor) then
  begin
    FListMonitor.Terminate;
    FListMonitor.WaitFor;
  end;

  ListView1.Items.Clear;
  if FindFirst(IncludeTrailingBackSlash(FPath) + '*.*', faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
        with ListView1.Items.Add do
        begin
          Caption := sr.Name;
          Data := TMyListItemData.Create(sr.Name, FPath, sr.Size,
            sr.Attr, FileDateToDateTime(sr.Time));
          SubItems.Add(TMyListItemData(Data).Extention);
          if sr.Attr and faDirectory = 0 then
            SubItems.Add(FormatBytes(sr.Size))
          else
            SubItems.Add('');
          SubItems.Add(DateTimeToStr(FileDateToDateTime(sr.Time)));
          SubItems.Add(AttrToStr(sr.Attr));

          ImageIndex := -1;
        end;
    until FindNext(sr) <> 0;
    FindClose(sr);
    ListView1.AlphaSort;
  end;

  FListMonitor := TMonitorThread.Create(Handle, WM_USER + 1,
    IncludeTrailingBackslash(FPath), False, FILE_NOTIFY_CHANGE_FILE_NAME or
    FILE_NOTIFY_CHANGE_DIR_NAME or FILE_NOTIFY_CHANGE_ATTRIBUTES or
    FILE_NOTIFY_CHANGE_SIZE or FILE_NOTIFY_CHANGE_LAST_WRITE);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  FPath := ExcludeTrailingBackSlash(txtAddress.Text);
  try
    ChDir(FPath);
    BuildListView;
    ListView1.Visible := True;
    panError.Visible := False;
  except
    on E: Exception do
    begin
      panError.Caption := E.Message;
      panError.Visible := True;
      ListView1.Visible := False;
    end;
  end;
end;

procedure TForm1.ListView1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  pt: TPoint;
begin
  Handled := True;
  pt := ListView1.ClientToScreen(MousePos);
  if ListView1.SelCount = 0 then
  begin

  end
  else if ListView1.SelCount = 1 then
  begin
    Form2.SetForOne(ListView1.Selected.Data);
    Form2.Left := pt.X;
    Form2.Top := pt.Y;
    Form2.Visible := True;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FListMonitor := nil;

  Font := Screen.IconFont;
  FSortOrder := 1;
  FSortKey := -1;

  BuildTreeRoot;
end;

procedure TForm1.txtAddressKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    SpeedButton1Click(Sender);
    Key := #0;
  end;
end;

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if ListView1.SelCount = 1 then

  else if ListView1.SelCount = 0 then
    panCustom.Caption := 'No items selected';
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  NoteBook1.PageIndex := ListBox1.ItemIndex;
end;

procedure TForm1.ListView1Deletion(Sender: TObject; Item: TListItem);
begin
  if Assigned(Item.Data) then
    TMyListItemData(Item.Data).Free;
end;


procedure TForm1.ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
  case FSortKey of
    0: Compare := lstrcmp(PChar(Item1.Caption), PChar(Item2.Caption)) * FSortOrder;
    1: Compare := lstrcmp(PChar(TMyListItemData(Item1.Data).Extention),
        PChar(TMyListItemData(Item2.Data).Extention)) * FSortOrder;
    2: Compare := CompareInt(TMyListItemData(Item1.Data).Size,
        TMyListItemData(Item2.Data).Size) * FSortOrder;
    3: Compare := CompareDateTime(TMyListItemData(Item1.Data).Time,
        TMyListItemData(Item2.Data).Time) * FSortOrder;
    4: Compare := CompareText(Item1.SubItems[3], Item2.SubItems[3]) * FSortOrder;
    else
      Compare := 0;
  end;
end;

procedure TForm1.ListView1ColumnClick(Sender: TObject; Column: TListColumn);
begin
  if FSortKey = Column.Index then
  begin
    FSortOrder := -FSortOrder;
    Column.ImageIndex := (Column.ImageIndex + 1) mod 2;
  end
  else
  begin
    if FSortKey >= 0 then
      ListView1.Columns[FSortKey].ImageIndex := -1;
    FSortKey := Column.Index;
    FSortOrder := 1;

    Column.ImageIndex := 0;
  end;

  ListView1.AlphaSort;
end;

procedure TForm1.ListView1DblClick(Sender: TObject);
var
  i: TMyListItemData;
begin
  if Assigned(ListView1.Selected) and Assigned(ListView1.Selected.Data) then
  begin
    i := TMyListItemData(ListView1.Selected.Data);
    if i.Attr and faDirectory <> 0 then
    begin
      txtAddress.Text := i.Path;
      SpeedButton1Click(Sender);
    end
    else
    begin
      ShellExecute(Handle, nil, PChar(i.Path), nil, nil, SW_SHOWNORMAL);
    end;
  end;
end;

procedure TForm1.BuildTreeRoot;
var
  d: DWORD;
  ch: Char;
  ppidl: PItemIDList;
  buf: array [0..MAX_PATH] of Char;
begin
  TreeView1.Items.Clear;
  d := GetLogicalDrives;
  ch := 'A';
  while d <> 0 do
  begin
    if (d and 1) <> 0 then
      with TreeView1.Items.Add(nil, ch + ':\') do
      begin
        HasChildren := True;
        Data := TMyDriveData.Create(ch);
      end;
    d := d shr 1;
    Inc(ch);
  end;

  with TreeView1.Items.Add(nil, 'Desktop') do
  begin
    HasChildren := True;
    SHGetSpecialFolderLocation(Handle, CSIDL_DESKTOPDIRECTORY, ppidl);
    SHGetPathFromIDList(ppidl, buf);
    Data := TMyListItemData.Create(buf);
  end;

  with TreeView1.Items.Add(nil, 'My Documents') do
  begin
    HasChildren := True;
    SHGetSpecialFolderLocation(Handle, CSIDL_PERSONAL, ppidl);
    SHGetPathFromIDList(ppidl, buf);
    Data := TMyListItemData.Create(buf);
  end;

end;

procedure TForm1.TreeView1Deletion(Sender: TObject; Node: TTreeNode);
var
  t: Pointer;
begin
  if Assigned(Node.Data) then
  begin
    t := Node.Data;
    FreeAndNil(t);
  end;
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  dir: TMyListItemData;
  drive: TMyDriveData;
begin
  if Assigned(Node) then
  begin
    if Assigned(Node.Data) then
    begin
      if TObject(Node.Data) is TMyListItemData then
      begin
        dir := TMyListItemData(Node.Data);
        txtAddress.Text := dir.Path;
        SpeedButton1Click(Sender);
      end
      else if TObject(Node.Data) is TMyDriveData then
      begin
        drive := TMyDriveData(Node.Data);
        txtAddress.Text := drive.Drive;
        SpeedButton1Click(Sender);
      end;
    end
    else
    begin
      txtAddress.Text := GetNodePath(Node);
      SpeedButton1Click(Sender);
    end;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(FListMonitor) then
  begin
    FListMonitor.Terminate;
    FListMonitor.WaitFor;
  end;
end;

procedure TForm1.WMListViewChanged(var Msg: TMessage);
begin
  SpeedButton1Click(nil);
end;

procedure TForm1.Panel4Resize(Sender: TObject);
begin
  txtAddress.Width := Panel4.ClientWidth - SpeedButton1.Width;
  SpeedButton1.Left := Panel4.ClientWidth - SpeedButton1.Width;
end;

procedure TForm1.NewWindow1Click(Sender: TObject);
var
  f: TForm1;
begin
  Application.CreateForm(TForm1, f);
  f.Show;
end;

function TForm1.GetNodePath(Node: TTreeNode): String;
begin
  if Node.Data = nil then
    Result := GetNodePath(Node.Parent) + '\' + Node.Text
  else if TObject(Node.Data) is TMyDriveData then
    Result := ExcludeTrailingBackslash(TMyDriveData(Node.Data).Drive)
  else if TObject(Node.Data) is TMyListItemData then
    Result := ExcludeTrailingBackslash(TMyListItemData(Node.Data).Path);
end;

procedure TForm1.BuildOneTreeLevel(Parent: TTreeNode);
var
  sr: TSearchRec;
  s: String;
begin
  s := IncludeTrailingBackslash(GetNodePath(Parent));
  if FindFirst(s + '*.*', faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr and faDirectory <> 0) then
        with TreeView1.Items.AddChild(Parent, sr.Name) do
          HasChildren := HasSubFolders(s + sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  Parent.HasChildren := Parent.GetFirstChild <> nil;
  Parent.AlphaSort;
end;

procedure TForm1.TreeView1Expanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
begin
  if Node.HasChildren and (Node.GetFirstChild = nil) then
    BuildOneTreeLevel(Node);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
end;

end.
