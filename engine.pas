unit engine;

{$MODE Delphi}

interface

uses SysUtils;

type
  TMyDriveData = class
    Drive: String;
    constructor Create(ADrive: Char);
  end;

  TMyListItemData = class
  private
    function GetPath: String;
    procedure SetPath(const Value: String);
    function GetExtention: String;
  public
    InPath: String;
    Name: String;
    Size: Integer;
    Attr: Integer;
    Time: TDateTime;
    constructor Create(const AName, AInPath: String; ASize, AAttr: Integer;
      ATime: TDateTime); overload;
    constructor Create(const FullPath: String); overload;
    property Path: String read GetPath write SetPath;
    property Extention: String read GetExtention;
  end;


function CompareInt(i1, i2: Integer): Integer;
function CompareDateTime(d1, d2: TDateTime): Integer;

function FormatBytes(t: Integer): String;

function HasSubFolders(const Path: String): Boolean;

implementation

function HasSubFolders(const Path: String): Boolean;
var
  sr: TSearchRec;
begin
  Result := False;
  if FindFirst(IncludeTrailingBackslash(Path) + '*.*', faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr and faDirectory <> 0) then
        Result := True;
    until Result or (FindNext(sr) <> 0);
    FindClose(sr);
  end;
end;

function CompareInt(i1, i2: Integer): Integer;
begin
  if i1 < i2 then
    Result := -1
  else if i1 > i2 then
    Result := 1
  else
    Result := 0;
end;

function CompareDateTime(d1, d2: TDateTime): Integer;
begin
  if d1 < d2 then
    Result := -1
  else if d1 > d2 then
    Result := 1
  else
    Result := 0;
end;

function FormatBytes(t: Integer): String;
begin
  Result := FormatFloat('#,##0', t);
end;

{ TMyListItemData }

constructor TMyListItemData.Create(const AName, AInPath: String;
  ASize, AAttr: Integer; ATime: TDateTime);
begin
  inherited Create;
  Name := AName;
  InPath := AInPath;
  Size := ASize;
  Attr := AAttr;
  Time := ATime;
end;

constructor TMyListItemData.Create(const FullPath: String);
begin
  Path := FullPath;
end;

function TMyListItemData.GetExtention: String;
begin
  Result := ExtractFileExt(Name);
  if Result <> '' then
    Result := Copy(Result, 2, Length(Result) - 1);
end;

function TMyListItemData.GetPath: String;
begin
  Result := IncludeTrailingBackslash(InPath) + Name;
end;

procedure TMyListItemData.SetPath(const Value: String);
begin
  Name := ExtractFileName(Value);
  InPath := ExtractFilePath(Value);
  Size := 0;
  Attr := FileGetAttr(Path);
  //Time := FileDateToDateTime(FileAge(Path));
end;

{ TMyDriveData }

constructor TMyDriveData.Create(ADrive: Char);
begin
  Drive := ADrive + ':\';
end;

end.
