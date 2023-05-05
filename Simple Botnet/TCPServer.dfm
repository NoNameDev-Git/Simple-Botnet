object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 343
  ClientWidth = 619
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 63
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 49
    Height = 21
    TabOrder = 1
    Text = '9999'
  end
  object ListView1: TListView
    Left = 8
    Top = 39
    Width = 601
    Height = 274
    Columns = <>
    FlatScrollBars = True
    TabOrder = 2
    TabStop = False
    ViewStyle = vsList
  end
  object Button2: TButton
    Left = 144
    Top = 8
    Width = 369
    Height = 25
    Caption = 'Panel'
    TabOrder = 3
    OnClick = Button2Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 324
    Width = 619
    Height = 19
    Panels = <>
  end
  object Button3: TButton
    Left = 519
    Top = 8
    Width = 92
    Height = 25
    Caption = 'Builder'
    TabOrder = 5
    OnClick = Button3Click
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServerSocket1ClientConnect
    OnClientDisconnect = ServerSocket1ClientDisconnect
    OnClientRead = ServerSocket1ClientRead
    OnClientError = ServerSocket1ClientError
    Left = 536
    Top = 64
  end
end
