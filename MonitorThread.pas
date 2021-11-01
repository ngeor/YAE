unit MonitorThread;

{$MODE Delphi}

interface

uses
  Classes, Windows, Messages;

type
  TMonitorThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    Path: string;
    WatchSubTree: boolean;
    NotifyFilter: integer;
    hWnd: HWND;
    msg2Send: UINT;
    constructor Create(ahwnd: HWND; amsg2Send: UINT; const aPath: string; aWST: boolean; aNF: integer);
  end;


implementation


{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TMonitorThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TMonitorThread }

constructor TMonitorThread.Create(ahwnd: HWND; amsg2Send: UINT; const aPath: string; aWST: boolean; aNF: integer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  hwnd := ahwnd;
  msg2Send := amsg2send;
  Path := aPath;
  WatchSubTree := aWST;
  NotifyFilter := aNF;
  Resume;
end;

procedure TMonitorThread.Execute;
var
  h: THandle;
begin
  h := FindFirstChangeNotification(PChar(Path), WatchSubTree, NotifyFilter);
  if (h <> INVALID_HANDLE_VALUE) then
    repeat
      if WaitForSingleObject(h, 200) = WAIT_OBJECT_0 then
      begin
        PostMessage(hWnd, msg2Send, 0, 0);
        if not FindNextChangeNotification(h) then
          Break;
      end;
    until Terminated;
end;

end.
