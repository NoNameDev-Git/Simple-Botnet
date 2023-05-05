program Server;

uses
  Vcl.Forms,
  TCPServer in 'TCPServer.pas' {Form1},
  Panel in 'Panel.pas' {Form3},
  Builder in 'Builder.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
