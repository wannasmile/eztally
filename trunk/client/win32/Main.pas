
unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, WinSkinData, ComCtrls, ExtCtrls, ImgList,
  RpcProxy, XmlRpcClient, Login, Tally, Setting;

type
  TFrmMain = class(TForm)
    FrmLogin: TFrmLogin;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FrmLoginBtnOkClick(Sender: TObject);
    procedure FrmLoginBtnSetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FRpcCaller: TRpcCaller;
    FRpcProxy: TRpcProxy;
    FrmTally: TFrmTally;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.DFM}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FrmSetting := TFrmSetting.Create(FrmMain);

  FrmLogin.CbUsers.ItemIndex := FrmSetting.UserId;
  FrmLogin.EdtPassword.Text := FrmSetting.Password;
  FrmLogin.CbRembPasswd.Checked := FrmSetting.RembPasswd;
  FrmLogin.CbAutoLogin.Checked := FrmSetting.AutoLogin;

  FRpcCaller := TRpcCaller.Create;
  FRpcCaller.EndPoint := '/RPC2';

  FRpcProxy := TRpcProxy.Create(FRpcCaller);
  //FRpcCaller.HostName := FrmSetting.LeHost.Text;
  //FRpcCaller.HostPort := FrmSetting.UdPort.Position;

  FrmTally := TFrmTally.Create(FrmMain);
  FrmTally.Align := alClient;
  FrmTally.RpcProxy := FRpcProxy;
  FrmTally.MaxCount := FrmSetting.UdCount.Position;
  FrmTally.Parent := FrmMain;
  FrmTally.Left := 0;
  FrmTally.Top := 0;
  FrmTally.Visible := False;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  FRpcProxy.Free;
  FRpcCaller.Free;
  FrmTally.Free;
  FrmSetting.Free;
end;

procedure TFrmMain.FrmLoginBtnOkClick(Sender: TObject);
begin
  if FrmLogin.EdtPassword.Text = '' then
  begin
    FrmLogin.LbInfo.Caption := '没有输入密码, 请输入!';
    FrmLogin.LbInfo.Visible := True;
  end
  else
  begin
    FrmLogin.LbInfo.Caption := '正在登录中···';
    FrmLogin.LbInfo.Visible := True;
    FrmLogin.LbInfo.Show;

    FRpcCaller.HostName := FrmSetting.LeHost.Text;
    FRpcCaller.HostPort := FrmSetting.UdPort.Position;
    if FRpcProxy.UserLogin(FrmLogin.CbUsers.ItemIndex, FrmLogin.EdtPassword.Text) then
    begin
      FrmSetting.UserId := FrmLogin.CbUsers.ItemIndex;
      if FrmLogin.CbRembPasswd.Checked then
        FrmSetting.Password := FrmLogin.EdtPassword.Text
      else
        FrmSetting.Password := '';
      FrmSetting.RembPasswd := FrmLogin.CbRembPasswd.Checked;
      FrmSetting.AutoLogin := FrmLogin.CbAutoLogin.Checked;

      FrmTally.Reset(True, True);
      FrmTally.ShowLastTallyItems;
      FrmTally.Visible := True;
      FrmTally.BringToFront;
      
      FrmLogin.LbInfo.Visible := False;
    end
    else
    begin
      FrmLogin.LbInfo.Caption := '登录失败, 密码不正确或网络服务无法访问!';
      FrmLogin.LbInfo.Visible := True;
    end;
  end;
end;

procedure TFrmMain.FrmLoginBtnSetClick(Sender: TObject);
begin
  if FrmSetting.ShowModal = mrOk then
  begin
    FRpcCaller.HostName := FrmSetting.LeHost.Text;
    FRpcCaller.HostPort := FrmSetting.UdPort.Position;
    FrmTally.MaxCount := FrmSetting.UdCount.Position;
  end;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  if FrmLogin.CbAutoLogin.Checked then
    FrmLogin.BtnOk.Click;
end;

end.

