object FrmSetting: TFrmSetting
  Left = 473
  Top = 363
  BorderStyle = bsDialog
  Caption = #35774#32622
  ClientHeight = 281
  ClientWidth = 417
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #24494#36719#38597#40657
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 17
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 401
    Height = 225
    ActivePage = TsService
    TabOrder = 0
    object TsService: TTabSheet
      Caption = #32593#32476#35774#32622
      object Label1: TLabel
        Left = 16
        Top = 168
        Width = 299
        Height = 17
        Caption = #27880': '#30331#24405#29366#24577#19979#26356#25913#30340#32593#32476#35774#32622#21482#33021#22312#37325#26032#30331#24405#20043#21518#29983#25928'!'
      end
      object LeHost: TLabeledEdit
        Left = 16
        Top = 32
        Width = 177
        Height = 25
        EditLabel.Width = 213
        EditLabel.Height = 17
        EditLabel.Caption = #26381#21153#31471#22320#22336'('#22914'"eztally.appspot.com"): '
        TabOrder = 0
        Text = 'eztally.appspot.com'
      end
      object LePort: TLabeledEdit
        Left = 16
        Top = 88
        Width = 65
        Height = 25
        EditLabel.Width = 87
        EditLabel.Height = 17
        EditLabel.Caption = #31471#21475#21495'('#22914'"80"): '
        TabOrder = 1
        Text = '80'
      end
      object UdPort: TUpDown
        Left = 81
        Top = 88
        Width = 16
        Height = 25
        Associate = LePort
        Min = 1
        Max = 32767
        Position = 80
        TabOrder = 2
        Thousands = False
      end
    end
    object TabSheet2: TTabSheet
      Caption = #31867#30446#31649#29702
      ImageIndex = 3
      TabVisible = False
      object ComboBox1: TComboBox
        Left = 16
        Top = 8
        Width = 209
        Height = 25
        Style = csDropDownList
        ItemHeight = 17
        ItemIndex = 0
        TabOrder = 0
        Text = #25910#20837#31867#30446
        Items.Strings = (
          #25910#20837#31867#30446
          #25903#20986#31867#30446)
      end
      object ValueListEditor1: TValueListEditor
        Left = 16
        Top = 40
        Width = 209
        Height = 145
        KeyOptions = [keyUnique]
        Strings.Strings = (
          '0='
          '1='
          '2='
          '3='
          '4='
          '5='
          '6='
          '7='
          '8='
          '9='
          '10='
          '11='
          '12='
          '13='
          '14='
          '15='
          '16='
          '17='
          '18='
          '19='
          '20=')
        TabOrder = 1
        TitleCaptions.Strings = (
          #32534#21495
          #21517#31216)
        ColWidths = (
          50
          137)
      end
    end
    object TsFunction: TTabSheet
      Caption = #21151#33021#21442#25968
      ImageIndex = 1
      object LeCount: TLabeledEdit
        Left = 16
        Top = 32
        Width = 65
        Height = 25
        EditLabel.Width = 203
        EditLabel.Height = 17
        EditLabel.Caption = #26368#36817#25910#25903#39033#27599#39029#26174#31034#26465#25968'('#25512#33616#20540'"10"):'
        TabOrder = 0
        Text = '10'
      end
      object UdCount: TUpDown
        Left = 81
        Top = 32
        Width = 15
        Height = 25
        Associate = LeCount
        Min = 1
        Position = 10
        TabOrder = 1
        Thousands = False
      end
    end
    object TabSheet1: TTabSheet
      Caption = #20462#25913#23494#30721
      ImageIndex = 2
      TabVisible = False
      object CbUsers: TComboBox
        Left = 16
        Top = 16
        Width = 105
        Height = 25
        Style = csDropDownList
        Enabled = False
        ItemHeight = 17
        ItemIndex = 0
        TabOrder = 0
        Text = #30007#20027#20154
        Items.Strings = (
          #30007#20027#20154
          #22899#20027#20154)
      end
      object LabeledEdit1: TLabeledEdit
        Left = 16
        Top = 72
        Width = 137
        Height = 25
        EditLabel.Width = 36
        EditLabel.Height = 17
        EditLabel.Caption = #21407#23494#30721
        PasswordChar = '*'
        TabOrder = 1
      end
      object LabeledEdit2: TLabeledEdit
        Left = 16
        Top = 120
        Width = 137
        Height = 25
        EditLabel.Width = 36
        EditLabel.Height = 17
        EditLabel.Caption = #26032#23494#30721
        PasswordChar = '*'
        TabOrder = 2
      end
      object LabeledEdit3: TLabeledEdit
        Left = 168
        Top = 120
        Width = 137
        Height = 25
        EditLabel.Width = 84
        EditLabel.Height = 17
        EditLabel.Caption = #20877#27425#36755#20837#26032#23494#30721
        PasswordChar = '*'
        TabOrder = 3
      end
    end
  end
  object BtnOk: TButton
    Left = 240
    Top = 248
    Width = 75
    Height = 25
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 328
    Top = 248
    Width = 75
    Height = 25
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
