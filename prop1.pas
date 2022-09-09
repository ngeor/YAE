unit prop1;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Engine, ShellAPI;

type
  TForm2 = class(TForm)
    chkR: TCheckBox;
    chkH: TCheckBox;
    chkS: TCheckBox;
    chkA: TCheckBox;
    SpeedButton1: TSpeedButton;
    Shape1: TShape;
    txtName: TEdit;
    ListBox1: TListBox;
    Shape2: TShape;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure FormDeactivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBox1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
    FOneItem: TMyListItemData;
    procedure CalcHeight;
  public
    procedure SetForOne(const ItemData: TMyListItemData);
  end;

var
  Form2: TForm2;

implementation



{$R *.lfm}

procedure TForm2.FormDeactivate(Sender: TObject);
begin
  Visible := False;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
var
  sOld, sNew: String;
begin
  if Assigned(FOneItem) then
  begin
    sOld := FOneItem.Path;
    sNew := IncludeTrailingBackSlash(FOneItem.InPath) + txtName.Text;
    if sOld <> sNew then
      RenameFile(sOld, sNew);
  end;
  Visible := False;
end;

procedure TForm2.SpeedButton2Click(Sender: TObject);
begin
  Visible := False;
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    SpeedButton1Click(Sender)
  else if Key = #27 then
    Visible := False;
end;

procedure TForm2.ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  i := ListBox1.ItemAtPos(Point(x, y), True);
  if (i >= 0) and (i < ListBox1.Items.Count) then
    ListBox1.ItemIndex := i;
end;

procedure TForm2.ListBox1Click(Sender: TObject);
begin
  Visible := False;
end;

procedure TForm2.SetForOne(const ItemData: TMyListItemData);
begin
  FOneItem := ItemData;
  txtName.Text := ItemData.Name;
  chkR.AllowGrayed := False;
  chkH.AllowGrayed := False;
  chkS.AllowGrayed := False;
  chkA.AllowGrayed := False;
  chkR.Checked := (ItemData.Attr and faReadOnly) <> 0;
  chkH.Checked := (ItemData.Attr and faHidden) <> 0;
  chkS.Checked := (ItemData.Attr and faSysFile) <> 0;
  chkA.Checked := (ItemData.Attr and faArchive) <> 0;
  CalcHeight;
end;

procedure TForm2.SpeedButton3Click(Sender: TObject);
var
  shfop: TSHFileOpStruct;
begin
  if Assigned(FOneItem) then
  begin
    shfop.Wnd := handle;
    shfop.wFunc := FO_DELETE;

    shfop.pFrom := PChar(GlobalAlloc(GPTR, Length(FOneItem.Path) + 2));
    lstrcpy(shfop.pFrom, PChar(FOneItem.Path));

    if (GetKeyState(VK_SHIFT) and $8000) <> 0 then
      shfop.fFlags := 0
    else
      shfop.fFlags := FOF_ALLOWUNDO;
    SHFileOperation(shfop);
    GlobalFree(HGLOBAL(shfop.pFrom));
  end;
  Visible := False;
end;

procedure TForm2.SpeedButton4Click(Sender: TObject);
begin
  if Assigned(FOneItem) then
    ShellExecute(0, nil, PWideChar(FOneItem.Path), nil, nil, SW_SHOWNORMAL);
  Visible := False;
end;

procedure TForm2.CalcHeight;
begin
  Height := ListBox1.Top + ListBox1.Items.Count * 14;
end;

end.
