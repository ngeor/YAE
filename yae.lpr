program yae;

{$MODE Delphi}

uses
  Forms,
  Interfaces,
  MainForm in 'MainForm.pas' {Form1},
  prop1 in 'prop1.pas' {Form2},
  engine in 'engine.pas',
  MonitorThread in 'MonitorThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
