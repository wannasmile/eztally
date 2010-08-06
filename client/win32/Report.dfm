object FrmReport: TFrmReport
  Left = 279
  Top = 196
  Width = 900
  Height = 540
  Caption = 'Report'
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
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object PageControl: TPageControl
    Left = 0
    Top = 56
    Width = 892
    Height = 456
    ActivePage = TsSubType
    Align = alClient
    TabOrder = 0
    object TsSubType: TTabSheet
      Caption = #25910#25903#31867#30446#25253#21578
      object Splitter1: TSplitter
        Left = 433
        Top = 0
        Width = 5
        Height = 424
        Beveled = True
      end
      object T1SubTypeChart: TChart
        Left = 438
        Top = 0
        Width = 446
        Height = 424
        AllowPanning = pmNone
        AllowZoom = False
        BackWall.Brush.Color = clWhite
        BackWall.Brush.Style = bsClear
        BackWall.Pen.Visible = False
        Title.Font.Charset = GB2312_CHARSET
        Title.Font.Color = clBlue
        Title.Font.Height = -12
        Title.Font.Name = #24494#36719#38597#40657
        Title.Font.Style = []
        Title.Text.Strings = (
          #25903#20986#24635#39069': XXX '#20803)
        AxisVisible = False
        ClipPoints = False
        Frame.Visible = False
        Legend.Alignment = laBottom
        Legend.Font.Charset = GB2312_CHARSET
        Legend.Font.Color = clBlack
        Legend.Font.Height = -11
        Legend.Font.Name = #24494#36719#38597#40657
        Legend.Font.Style = []
        View3DOptions.Elevation = 315
        View3DOptions.Orthogonal = False
        View3DOptions.Perspective = 0
        View3DOptions.Rotation = 360
        View3DWalls = False
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Series1: TPieSeries
          Marks.ArrowLength = 8
          Marks.Font.Charset = GB2312_CHARSET
          Marks.Font.Color = clBlack
          Marks.Font.Height = -11
          Marks.Font.Name = #24494#36719#38597#40657
          Marks.Font.Style = []
          Marks.Style = smsLabelPercent
          Marks.Visible = True
          PercentFormat = '##0.# %'
          SeriesColor = clRed
          OtherSlice.Text = 'Other'
          PieValues.DateTime = False
          PieValues.Name = 'Pie'
          PieValues.Multiplier = 1.000000000000000000
          PieValues.Order = loNone
        end
      end
      object T0SubTypeChart: TChart
        Left = 0
        Top = 0
        Width = 433
        Height = 424
        AllowPanning = pmNone
        AllowZoom = False
        BackWall.Brush.Color = clWhite
        BackWall.Brush.Style = bsClear
        BackWall.Pen.Visible = False
        Title.Font.Charset = GB2312_CHARSET
        Title.Font.Color = clBlue
        Title.Font.Height = -12
        Title.Font.Name = #24494#36719#38597#40657
        Title.Font.Style = []
        Title.Text.Strings = (
          #25910#20837#24635#39069': XXX '#20803)
        AxisVisible = False
        ClipPoints = False
        Frame.Visible = False
        Legend.Alignment = laBottom
        Legend.Font.Charset = GB2312_CHARSET
        Legend.Font.Color = clBlack
        Legend.Font.Height = -11
        Legend.Font.Name = #24494#36719#38597#40657
        Legend.Font.Style = []
        Legend.TopPos = 0
        View3DOptions.Elevation = 315
        View3DOptions.Orthogonal = False
        View3DOptions.Perspective = 0
        View3DOptions.Rotation = 360
        View3DWalls = False
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object PieSeries1: TPieSeries
          Marks.ArrowLength = 8
          Marks.Font.Charset = GB2312_CHARSET
          Marks.Font.Color = clBlack
          Marks.Font.Height = -11
          Marks.Font.Name = #24494#36719#38597#40657
          Marks.Font.Style = []
          Marks.Style = smsLabelPercent
          Marks.Visible = True
          PercentFormat = '##0.# %'
          SeriesColor = clRed
          OtherSlice.Text = 'Other'
          PieValues.DateTime = False
          PieValues.Name = 'Pie'
          PieValues.Multiplier = 1.000000000000000000
          PieValues.Order = loNone
        end
      end
    end
    object TsMonth: TTabSheet
      Caption = #26376#24230#27719#24635#25253#21578
      ImageIndex = 1
      object MonthChart: TChart
        Left = 0
        Top = 0
        Width = 884
        Height = 424
        BackWall.Brush.Color = clWhite
        BackWall.Color = clSilver
        BottomWall.Brush.Color = clWhite
        Title.Font.Charset = GB2312_CHARSET
        Title.Font.Color = clBlue
        Title.Font.Height = -12
        Title.Font.Name = #24494#36719#38597#40657
        Title.Font.Style = []
        Title.Text.Strings = (
          #32467#20313#24635#39069': XXX '#20803)
        BackColor = clSilver
        Legend.Alignment = laBottom
        Legend.ColorWidth = 45
        Legend.Font.Charset = GB2312_CHARSET
        Legend.Font.Color = clBlack
        Legend.Font.Height = -11
        Legend.Font.Name = #24494#36719#38597#40657
        Legend.Font.Style = []
        Legend.TopPos = 0
        Legend.VertMargin = 5
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Series2: TBarSeries
          Marks.ArrowLength = 20
          Marks.Style = smsValue
          Marks.Visible = True
          SeriesColor = clRed
          Title = #25910#20837
          XValues.DateTime = False
          XValues.Name = 'X'
          XValues.Multiplier = 1.000000000000000000
          XValues.Order = loAscending
          YValues.DateTime = False
          YValues.Name = 'Bar'
          YValues.Multiplier = 1.000000000000000000
          YValues.Order = loNone
        end
        object Series3: TBarSeries
          Marks.ArrowLength = 20
          Marks.Style = smsValue
          Marks.Visible = True
          SeriesColor = clGreen
          Title = #25903#20986
          XValues.DateTime = False
          XValues.Name = 'X'
          XValues.Multiplier = 1.000000000000000000
          XValues.Order = loAscending
          YValues.DateTime = False
          YValues.Name = 'Bar'
          YValues.Multiplier = 1.000000000000000000
          YValues.Order = loNone
        end
        object Series4: TBarSeries
          Marks.ArrowLength = 20
          Marks.Style = smsValue
          Marks.Visible = True
          DataSource = Series2
          SeriesColor = clYellow
          Title = #32467#20313
          XValues.DateTime = False
          XValues.Name = 'X'
          XValues.Multiplier = 1.000000000000000000
          XValues.Order = loAscending
          YValues.DateTime = False
          YValues.Name = 'Bar'
          YValues.Multiplier = 1.000000000000000000
          YValues.Order = loNone
          DataSources = (
            'Series2'
            'Series3')
          object TeeFunction1: TSubtractTeeFunction
          end
        end
      end
    end
  end
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 892
    Height = 56
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object Label1: TLabel
      Left = 144
      Top = 20
      Width = 12
      Height = 17
      Caption = #33267
    end
    object Label2: TLabel
      Left = 77
      Top = 20
      Width = 5
      Height = 17
      Caption = '/'
    end
    object Label3: TLabel
      Left = 229
      Top = 20
      Width = 5
      Height = 17
      Caption = '/'
    end
    object CbUsers: TComboBox
      Left = 328
      Top = 16
      Width = 81
      Height = 25
      Style = csDropDownList
      ItemHeight = 17
      ItemIndex = 0
      TabOrder = 0
      Text = #20840#23478
      Items.Strings = (
        #20840#23478
        #30007#20027#20154
        #22899#20027#20154)
    end
    object BtnStat: TButton
      Left = 432
      Top = 8
      Width = 89
      Height = 41
      Caption = #33719#21462#25253#21578
      Default = True
      TabOrder = 1
      OnClick = BtnStatClick
    end
    object CbStartYear: TComboBox
      Left = 16
      Top = 16
      Width = 57
      Height = 25
      Style = csDropDownList
      ItemHeight = 17
      ItemIndex = 0
      TabOrder = 2
      Text = '2010'
      Items.Strings = (
        '2010'
        '2011'
        '2012'
        '2013'
        '2014'
        '2015')
    end
    object CbStartMonth: TComboBox
      Left = 88
      Top = 16
      Width = 49
      Height = 25
      Style = csDropDownList
      DropDownCount = 12
      ItemHeight = 17
      ItemIndex = 0
      TabOrder = 3
      Text = '01'
      Items.Strings = (
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '10'
        '11'
        '12')
    end
    object CbEndYear: TComboBox
      Left = 168
      Top = 16
      Width = 57
      Height = 25
      Style = csDropDownList
      ItemHeight = 17
      ItemIndex = 0
      TabOrder = 4
      Text = '2010'
      Items.Strings = (
        '2010'
        '2011'
        '2012'
        '2013'
        '2014'
        '2015')
    end
    object CbEndMonth: TComboBox
      Left = 240
      Top = 16
      Width = 49
      Height = 25
      Style = csDropDownList
      DropDownCount = 12
      ItemHeight = 17
      ItemIndex = 0
      TabOrder = 5
      Text = '01'
      Items.Strings = (
        '01'
        '02'
        '03'
        '04'
        '05'
        '06'
        '07'
        '08'
        '09'
        '10'
        '11'
        '12')
    end
  end
end
