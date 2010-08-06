unit Report;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Series, TeEngine, TeeProcs, Chart,
  TeeFunci, RpcProxy;

type
  TFrmReport = class(TForm)
    PageControl: TPageControl;
    TsSubType: TTabSheet;
    TsMonth: TTabSheet;
    T1SubTypeChart: TChart;
    MonthChart: TChart;
    Series2: TBarSeries;
    Series3: TBarSeries;
    Series1: TPieSeries;
    Splitter1: TSplitter;
    T0SubTypeChart: TChart;
    PieSeries1: TPieSeries;
    Panel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CbUsers: TComboBox;
    BtnStat: TButton;
    CbStartYear: TComboBox;
    CbStartMonth: TComboBox;
    CbEndYear: TComboBox;
    CbEndMonth: TComboBox;
    Series4: TBarSeries;
    TeeFunction1: TSubtractTeeFunction;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnStatClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FRpcProxy: TRpcProxy;
    FStatReport: TStatReport;
    procedure ShowChart;
  public
    { Public declarations }
    procedure SetRpcProxy(RpcProxy: TRpcProxy);
    //property SetStatReport: TStatReport read FStatReport write FStatReport;
  end;

var
  FrmReport: TFrmReport;

implementation

{$R *.dfm}

procedure TFrmReport.ShowChart;
var
  i: Integer;
  Income, Expense, Balance: Integer;
  PeriodStr: String;
  PStatItem: TPStatItem;
begin
  Income := TPStatItem(FStatReport.T0MonthStat[FStatReport.T0MonthStat.Count-1])^.Value;
  Expense := TPStatItem(FStatReport.T1MonthStat[FStatReport.T1MonthStat.Count-1])^.Value;
  Balance := Income - Expense;
  if (CbStartYear.Text = CbEndYear.Text) and (CbStartMonth.Text = CbEndMonth.Text) then
    PeriodStr := Format('%s-%s', [CbStartYear.Text, CbStartMonth.Text])
  else
    PeriodStr := Format('%s-%s 至 %s-%s', [CbStartYear.Text, CbStartMonth.Text,
                                           CbEndYear.Text, CbEndMonth.Text]);

  T0SubTypeChart.Title.Text.Text :=
    Format('%s %s 收入总额: %d 元, 分布如下:', [CbUsers.Text, PeriodStr, Income]);
  T1SubTypeChart.Title.Text.Text :=
    Format('%s %s 支出总额: %d 元, 分布如下:', [CbUsers.Text, PeriodStr, Expense]);
  MonthChart.Title.Text.Text :=
    Format('%s %s 结余总额: %d 元, 分布如下:', [CbUsers.Text, PeriodStr, Balance]);

  T0SubTypeChart.Series[0].Clear;
  for i := 0 to (FStatReport.T0SubTypeStat.Count-1) do
  begin
    PStatItem := FStatReport.T0SubTypeStat[i];
    T0SubTypeChart.Series[0].Add(PStatItem^.Value, FRpcProxy.T0SubTypes[StrToInt(PStatItem^.Name)]);
  end;

  T1SubTypeChart.Series[0].Clear;
  for i := 0 to (FStatReport.T1SubTypeStat.Count-1) do
  begin
    PStatItem := FStatReport.T1SubTypeStat[i];
    T1SubTypeChart.Series[0].Add(PStatItem^.Value, FRpcProxy.T1SubTypes[StrToInt(PStatItem^.Name)]);
  end;

  MonthChart.Series[0].Clear;
  for i := 0 to (FStatReport.T0MonthStat.Count-2) do
  begin
    PStatItem := FStatReport.T0MonthStat[i];
    MonthChart.Series[0].Add(PStatItem^.Value, PStatItem^.Name);
  end;

  MonthChart.Series[1].Clear;
  for i := 0 to (FStatReport.T1MonthStat.Count-2) do
  begin
    PStatItem := FStatReport.T1MonthStat[i];
    MonthChart.Series[1].Add(PStatItem^.Value, PStatItem^.Name);
  end;

  with MonthChart.Series[2] do
  begin
    DataSources.Clear;
    DataSources.Add(MonthChart.Series[0]);
    DataSources.Add(MonthChart.Series[1]);
    SetFunction(TSubtractTeeFunction.Create(Self));
  end;
end;

procedure TFrmReport.SetRpcProxy(RpcProxy: TRpcProxy);
begin
  FRpcProxy := RpcProxy;
end;

procedure TFrmReport.FormCreate(Sender: TObject);
begin
  FStatReport := TStatReport.Create;
end;

procedure TFrmReport.FormDestroy(Sender: TObject);
begin
  FStatReport.Free;
end;

procedure TFrmReport.FormResize(Sender: TObject);
begin
  T0SubTypeChart.Width := TsSubType.Width div 2;
end;

procedure TFrmReport.BtnStatClick(Sender: TObject);
var
  StartMonth, EndMonth: String;
  UserId: Integer;
begin
  StartMonth := CbStartYear.Text+'-'+CbStartMonth.Text;
  EndMonth := CbEndYear.Text+'-'+CbEndMonth.Text;
  UserId := CbUsers.ItemIndex - 1;
  FStatReport.Clear;
  FRpcProxy.GetStatReport(StartMonth, EndMonth, UserId, FStatReport);
  ShowChart;
end;

procedure TFrmReport.FormShow(Sender: TObject);
var
  CurYear, CurMonth: String;
  CurTime: TDateTime;
begin
  CurTime := Now;
  CurYear := FormatDateTime('yyyy', CurTime);
  CurMonth := FormatDateTime('MM', CurTime);
  CbStartYear.ItemIndex := CbStartYear.Items.IndexOf(CurYear);
  CbStartMonth.ItemIndex := CbStartMonth.Items.IndexOf(CurMonth);
  CbEndYear.ItemIndex := CbEndYear.Items.IndexOf(CurYear);
  CbEndMonth.ItemIndex := CbEndMonth.Items.IndexOf(CurMonth);
  CbUsers.ItemIndex := 0;

  BtnStat.Click;
end;

end.
