unit Query;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ComCtrls, StdCtrls, ExtCtrls, DateUtils, RpcProxy;

type
  TFrmQuery = class(TForm)
    List: TListView;
    ImageList: TImageList;
    Panel: TPanel;
    DtpFromDate: TDateTimePicker;
    CbSubTypes: TComboBox;
    CbUsers: TComboBox;
    CbTypes: TComboBox;
    DtpToDate: TDateTimePicker;
    Label1: TLabel;
    BtnQuery: TButton;
    procedure CbTypesSelect(Sender: TObject);
    procedure BtnQueryClick(Sender: TObject);
  private
    { Private declarations }
    FRpcProxy: TRpcProxy;
  public
    { Public declarations }
    procedure Init;
    procedure SetRpcProxy(RpcProxy: TRpcProxy);
  end;

var
  FrmQuery: TFrmQuery;

implementation

{$R *.dfm}

procedure TFrmQuery.Init;
var
  CurDate: TDateTime;
begin
  List.Clear;
  CurDate := Today;
  DtpFromDate.Date := StartOfTheMonth(CurDate);
  DtpToDate.Date := CurDate;
  CbTypes.ItemIndex := 0;
  CbSubTypes.Visible := False;
  CbUsers.ItemIndex := 0;
end;

procedure TFrmQuery.SetRpcProxy(RpcProxy: TRpcProxy);
begin
  FRpcProxy := RpcProxy;
end;

procedure TFrmQuery.CbTypesSelect(Sender: TObject);
begin
  CbSubTypes.Clear;
  CbSubTypes.Items.Add('所有类目');
  case CbTypes.ItemIndex of
    0: CbSubTypes.Visible := False;
    1: begin CbSubTypes.Items.AddStrings(FRpcProxy.T0SubTypes); CbSubTypes.Visible := True; end;
    2: begin CbSubTypes.Items.AddStrings(FRpcProxy.T1SubTypes); CbSubTypes.Visible := True; end;
  end;
  CbSubTypes.ItemIndex := 0;
end;

procedure TFrmQuery.BtnQueryClick(Sender: TObject);
var
  FromDateStr, ToDateStr: String;
  TypeId, SubTypeId, UserId: Integer;
begin
  List.Clear;
  if not Assigned(FRpcProxy) then Exit;
  FromDateStr := FormatDateTime('yyyy-MM-dd', DtpFromDate.Date);
  ToDateStr := FormatDateTime('yyyy-MM-dd', DtpToDate.Date);
  TypeId := CbTypes.ItemIndex -1;
  SubTypeId := CbSubTypes.ItemIndex -1;
  UserId := CbUsers.ItemIndex -1;

  FRpcProxy.GetTallyItems(FromDateStr, ToDateStr, TypeId, SubTypeId, UserId, List);
end;

end.
