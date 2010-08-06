unit Tally;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DateUtils,
  Dialogs, ImgList, StdCtrls, ComCtrls, RpcProxy, ExtCtrls, Setting, Report, Query;

type
  TFrmTally = class(TFrame)
    Label1: TLabel;
    List: TListView;
    BtnQuery: TButton;
    BtnSave: TButton;
    BtnDel: TButton;
    BtnAdd: TButton;
    Panel: TPanel;
    Label2: TLabel;
    DtpDate: TDateTimePicker;
    Memo: TMemo;
    RbIncome: TRadioButton;
    RbExpense: TRadioButton;
    CbSubTypes: TComboBox;
    EdtCount: TEdit;
    CbUsers: TComboBox;
    BtnSet: TButton;
    BtnReport: TButton;
    ImageList: TImageList;
    BtnLogoff: TButton;
    BtnUp: TButton;
    BtnDown: TButton;
    BtnExport: TButton;
    BtnImport: TButton;
    SaveDialog: TSaveDialog;
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EdtCountKeyPress(Sender: TObject; var Key: Char);
    procedure BtnQueryClick(Sender: TObject);
    procedure BtnLogoffClick(Sender: TObject);
    procedure BtnSetClick(Sender: TObject);
    procedure ListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure EdtCountChange(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure RbIncomeClick(Sender: TObject);
    procedure RbExpenseClick(Sender: TObject);
    procedure BtnReportClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
  private
    { Private declarations }
    FRpcProxy: TRpcProxy;
    FMaxCount: Integer;
    FPageNo: Integer;
    FPTallyItems: TList;
    procedure DoOnListItemSelect;
    procedure DoOnRbTypeClick;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Reset(InitDate, InitPageNo: Boolean);
    function ShowLastTallyItems(PageNo: Integer=0): Integer;

    property MaxCount: Integer read FMaxCount write FMaxCount;
    property RpcProxy: TRpcProxy read FRpcProxy write FRpcProxy;
  end;

implementation

{$R *.dfm}

constructor TFrmTally.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRpcProxy := nil;
  FMaxCount := 10;

  FPTallyItems := TList.Create;
end;

destructor TFrmTally.Destroy;
var
  i: Integer;
  PTallyItem: TPTallyItem;
begin
  for i:= 0 to (FPTallyItems.Count-1) do
  begin
    PTallyItem := FPTallyItems[i];
    Dispose(PTallyItem);
  end;
  FPTallyItems.Clear;
  FPTallyItems.Free;

  inherited Destroy;
end;

procedure TFrmTally.Reset(InitDate, InitPageNo: Boolean);
begin
  List.Clear;
  if InitPageNo then FPageNo := 0;

  BtnSave.Enabled := False;
  BtnDel.Enabled := False;

  if InitDate then DtpDate.Date := Today;
  RbIncome.Checked := False;
  RbExpense.Checked := True;
  DoOnRbTypeClick;

  CbUsers.ItemIndex := FrmSetting.UserId;
  EdtCount.Text := '';
  Memo.Text := '';
end;

function TFrmTally.ShowLastTallyItems(PageNo: Integer): Integer;
var
  i: Integer;
  Item: TListItem;
  PTallyItem: TPTallyItem;
begin
  Result := 0;
  List.Clear;
  if not Assigned(FRpcProxy) then Exit;

  for i:= 0 to (FPTallyItems.Count-1) do
  begin
    PTallyItem := FPTallyItems[i];
    Dispose(PTallyItem);
  end;
  FPTallyItems.Clear;

  Result := FRpcProxy.GetLastTallyItems(FMaxCount, PageNo * FMaxCount, FPTallyItems);
  BtnUp.Enabled := (PageNo > 0);
  BtnDown.Enabled := (Result = FMaxCount);

  for i := 0 to (FPTallyItems.Count-1) do
  begin
    Item := List.Items.Add;
    PTallyItem := FPTallyItems[i];
    if (PTallyItem^.TypeId = 0) then
    begin
      Item.Caption := '收';
      Item.ImageIndex := 0;
      Item.SubItems.Add(FRpcProxy.T0SubTypes[PTallyItem^.SubTypeId])
    end;
    if (PTallyItem^.TypeId = 1) then
    begin
      Item.Caption := '支';
      Item.ImageIndex := 1;
      Item.SubItems.Add(FRpcProxy.T1SubTypes[PTallyItem^.SubTypeId])
    end;
    Item.SubItems.Add(IntToStr(PTallyItem^.Count));
    Item.SubItems.Add(PTallyItem^.DateStr);
    Item.SubItems.Add(RpcProxy.Users[PTallyItem^.UserId]);
    Item.SubItems.Add(PTallyItem^.Memo);
  end;
end;

procedure TFrmTally.BtnSaveClick(Sender: TObject);
var
  Changed: Boolean;
  Item: TListItem;
  PTallyItem: TPTallyItem;
begin
  if not Assigned(FRpcProxy) then Exit;
  if List.SelCount = 0 then Exit;

  Item := List.Selected;
  PTallyItem := FPTallyItems[List.ItemIndex];
  Changed := False;

  if FormatDateTime('yyyy-MM-dd', DtpDate.Date) <> Item.SubItems[2] then
  begin
    Changed := true;
    PTallyItem^.DateStr := FormatDateTime('yyyy-MM-dd', DtpDate.Date);
  end;
  if (RbIncome.Checked and (Item.Caption <> '收'))
    or (RbExpense.Checked and (Item.Caption <> '支')) then
  begin
    Changed := true;
    if RbIncome.Checked then
      PTallyItem^.TypeId := 0
    else
      PTallyItem^.TypeId := 1;
  end;
  if CbSubTypes.Text <> Item.SubItems[0] then
  begin
    Changed := true;
    if RbIncome.Checked then
      PTallyItem^.SubTypeId := FRpcProxy.T0SubTypes.IndexOf(CbSubTypes.Text)
    else
      PTallyItem^.SubTypeId := FRpcProxy.T1SubTypes.IndexOf(CbSubTypes.Text);
  end;
  if EdtCount.Text <> Item.SubItems[1] then
  begin
    Changed := true;
    PTallyItem^.Count := StrToInt(EdtCount.Text);
  end;
  if CbUsers.Text <> Item.SubItems[3] then
  begin
    Changed := true;
    PTallyItem^.UserId := CbUsers.ItemIndex;
  end;
  if Memo.Text <> Item.SubItems[4] then
  begin
    Changed := true;
    PTallyItem^.Memo := Memo.Text;
  end;

  if Changed then
  begin
    FRpcProxy.SaveTallyItem(PTallyItem);

    Reset(True, False);
    ShowLastTallyItems;
  end;
end;

procedure TFrmTally.BtnDelClick(Sender: TObject);
var
  PTallyItem: TPTallyItem;
begin
  if (List.SelCount = 0) or (not Assigned(FRpcProxy)) then Exit;

  PTallyItem := FPTallyItems[List.ItemIndex];
  FRpcProxy.DelTallyItem(PTallyItem^.Id);

  Reset(True, False);
  ShowLastTallyItems;
end;

procedure TFrmTally.BtnAddClick(Sender: TObject);
var
  PTallyItem: TPTallyItem;
begin
  if not Assigned(FRpcProxy) then Exit;

  New(PTallyItem);
  try
    if RbIncome.Checked then
      PTallyItem^.TypeId := 0
    else
      PTallyItem^.TypeId := 1;
    PTallyItem^.SubTypeId := CbSubTypes.ItemIndex;
    PTallyItem^.Count := StrToInt(EdtCount.Text);
    PTallyItem^.UserId := CbUsers.ItemIndex;
    PTallyItem^.DateStr := FormatDateTime('yyyy-MM-dd', DtpDate.Date);
    PTallyItem^.Memo := Memo.Text;

    PTallyItem^.Id := FRpcProxy.AddTallyItem(PTallyItem);
  finally
    Dispose(PTallyItem);
  end;

  Reset(True, True);
  ShowLastTallyItems;
end;

procedure TFrmTally.DoOnRbTypeClick;
var
  i: Integer;
begin
  CbSubTypes.Clear;
  if RbIncome.Checked then
  begin
    RbExpense.Checked := False;
    for i:= 0 to FRpcProxy.T0SubTypes.Count-1 do
      CbSubTypes.Items.Add(FRpcProxy.T0SubTypes[i]);
  end
  else
  begin
    RbExpense.Checked := True;
    for i:= 0 to FRpcProxy.T1SubTypes.Count-1 do
      CbSubTypes.Items.Add(FRpcProxy.T1SubTypes[i]);
  end;
  CbSubTypes.ItemIndex := 0;
end;

procedure TFrmTally.EdtCountKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
  begin
    MessageDlg('金额只能输入整数!', mtWarning, [mbOK], 0);
    Key := #0;
  end;
end;

procedure TFrmTally.BtnLogoffClick(Sender: TObject);
begin
  Visible := False;
end;

procedure TFrmTally.BtnSetClick(Sender: TObject);
begin
  if FrmSetting.ShowModal = mrOk then
  begin
    FMaxCount := FrmSetting.UdCount.Position;
  end;
end;

procedure TFrmTally.ListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
    DoOnListItemSelect;
end;

procedure TFrmTally.ListClick(Sender: TObject);
begin
  DoOnListItemSelect;
end;

procedure TFrmTally.DoOnListItemSelect;
var
  FormatSettings: TFormatSettings;
  Item: TListItem;
begin
  if List.SelCount > 0 then
  begin
    BtnSave.Enabled := True;
    BtnDel.Enabled := True;

    Item := List.Selected;
    FormatSettings.ShortDateFormat := 'yyyy-MM-dd';
    FormatSettings.DateSeparator := '-';
    DtpDate.Date := StrToDate(Item.SubItems[2], FormatSettings);
    RbIncome.Checked := (Item.Caption = '收');
    RbExpense.Checked := not RbIncome.Checked;
    DoOnRbTypeClick;
    CbSubTypes.ItemIndex := CbSubTypes.Items.IndexOf(Item.SubItems[0]);
    EdtCount.Text := Item.SubItems[1];
    CbUsers.ItemIndex := CbUsers.Items.IndexOf(Item.SubItems[3]);
    Memo.Text := Item.SubItems[4];
  end
  else
  begin
    BtnSave.Enabled := False;
    BtnDel.Enabled := False;
  end;
end;

procedure TFrmTally.EdtCountChange(Sender: TObject);
begin
  BtnAdd.Enabled := (EdtCount.Text <> '');
  BtnSave.Enabled := BtnSave.Enabled and (EdtCount.Text <> '') ;
end;

procedure TFrmTally.RbIncomeClick(Sender: TObject);
begin
  DoOnRbTypeClick;
end;

procedure TFrmTally.RbExpenseClick(Sender: TObject);
begin
  DoOnRbTypeClick;
end;

procedure TFrmTally.BtnQueryClick(Sender: TObject);
begin
  if not Assigned(FRpcProxy) then Exit;
  FrmQuery.SetRpcProxy(FRpcProxy);
  FrmQuery.Init;
  FrmQuery.Show;
end;

procedure TFrmTally.BtnReportClick(Sender: TObject);
begin
  if not Assigned(FRpcProxy) then Exit;
  FrmReport.SetRpcProxy(FRpcProxy);
  FrmReport.Show;
end;

procedure TFrmTally.BtnUpClick(Sender: TObject);
begin
  Reset(True, False);
  if FPageNo > 0 then Dec(FPageNo);
  ShowLastTallyItems(FPageNo);
end;

procedure TFrmTally.BtnDownClick(Sender: TObject);
begin
  Reset(True, False);
  Inc(FPageNo);
  ShowLastTallyItems(FPageNo);
end;

procedure TFrmTally.BtnExportClick(Sender: TObject);
begin
  if not Assigned(FRpcProxy) then Exit;
  if SaveDialog.Execute then
  begin
    Cursor := crHourGlass;
    try
      FRpcProxy.ExportTallyItems(SaveDialog.FileName);
    except
    end;
    Cursor := crDefault;
    Application.MessageBox('恭喜,已经成功从网络服务器导出所有的收支记录!', 'Info', MB_OK);
  end;
end;

end.
