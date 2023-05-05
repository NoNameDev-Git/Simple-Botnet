object Form4: TForm4
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 174
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object sGroupBox2: TsGroupBox
    Left = 8
    Top = 8
    Width = 265
    Height = 137
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    CaptionLayout = clTopCenter
    object sEdit1: TsEdit
      Left = 32
      Top = 24
      Width = 113
      Height = 22
      TabStop = False
      TabOrder = 0
      TextHint = '192.168.100.5'
      BoundLabel.Active = True
      BoundLabel.ParentFont = False
      BoundLabel.Caption = 'Ip'
    end
    object sEdit2: TsEdit
      Left = 192
      Top = 24
      Width = 49
      Height = 22
      TabStop = False
      TabOrder = 1
      Text = '9999'
      TextHint = '9999'
      BoundLabel.Active = True
      BoundLabel.ParentFont = False
      BoundLabel.Caption = 'Port'
    end
    object sEdit3: TsEdit
      Left = 24
      Top = 64
      Width = 217
      Height = 22
      TabStop = False
      ReadOnly = True
      TabOrder = 2
      Text = '%ProgramData%\App\unsecapp.exe'
      BoundLabel.Active = True
      BoundLabel.ParentFont = False
      BoundLabel.Caption = 'Path'
      BoundLabel.Layout = sclTopCenter
    end
    object Button1: TButton
      Left = 24
      Top = 92
      Width = 217
      Height = 25
      Caption = 'Compile'
      TabOrder = 3
      OnClick = Button1Click
    end
  end
  object sStatusBar1: TsStatusBar
    Left = 0
    Top = 155
    Width = 285
    Height = 19
    Panels = <>
  end
  object sSaveDialog1: TsSaveDialog
    FileName = 'Install'
    Filter = '.exe|*.exe'
    Left = 248
    Top = 128
  end
end
