unit Login;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, RpcProxy, ExtCtrls, jpeg;

type
  TFrmLogin = class(TFrame)
    CbUsers: TComboBox;
    Label1: TLabel;
    EdtPassword: TEdit;
    Label2: TLabel;
    BtnOk: TButton;
    CbRembPasswd: TCheckBox;
    CbAutoLogin: TCheckBox;
    Image1: TImage;
    BtnSet: TButton;
    LbInfo: TLabel;
    procedure CbAutoLoginClick(Sender: TObject);
    procedure CbRembPasswdClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}


procedure TFrmLogin.CbAutoLoginClick(Sender: TObject);
begin
  if CbAutoLogin.Checked then
    CbRembPasswd.Checked := True;
end;

procedure TFrmLogin.CbRembPasswdClick(Sender: TObject);
begin
  if not CbRembPasswd.Checked then
    CbAutoLogin.Checked := False;
end;

end.
