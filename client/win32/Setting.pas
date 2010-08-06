unit Setting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Registry, Grids, ValEdit;

type
  TFrmSetting = class(TForm)
    PageControl: TPageControl;
    TsService: TTabSheet;
    TsFunction: TTabSheet;
    BtnOk: TButton;
    BtnCancel: TButton;
    LeHost: TLabeledEdit;
    LePort: TLabeledEdit;
    UdPort: TUpDown;
    LeCount: TLabeledEdit;
    UdCount: TUpDown;
    Label1: TLabel;
    TabSheet1: TTabSheet;
    CbUsers: TComboBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    TabSheet2: TTabSheet;
    ComboBox1: TComboBox;
    ValueListEditor1: TValueListEditor;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
  private
    { Private declarations }
    FRegistry: TRegistry;
    FUserId: Integer;
    FPassword: String;
    FRembPasswd: Boolean;
    FAutoLogin: Boolean;
    procedure SetUserId(Value: Integer);
    procedure SetPassword(Value: String);
    procedure SetRembPasswd(Value: Boolean);
    procedure SetAutoLogin(Value: Boolean);
  public
    { Public declarations }
    property UserId: Integer read FUserId write SetUserId;
    property Password: String read FPassword write SetPassword;
    property RembPasswd: Boolean read FRembPasswd write SetRembPasswd;
    property AutoLogin: Boolean read FAutoLogin write SetAutoLogin;
  end;

var
  FrmSetting: TFrmSetting;

implementation

{$R *.dfm}

procedure TFrmSetting.FormCreate(Sender: TObject);
begin
  FUserId := -1;
  FPassword := '';
  FRembPasswd := False;
  FAutoLogin := False;
  
  FRegistry:= TRegistry.Create;
  try
    FRegistry.RootKey:= HKEY_CURRENT_USER;
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', False) then
    begin
      LeHost.Text := FRegistry.ReadString('Host');
      UdPort.Position := FRegistry.ReadInteger('Port');
      UdCount.Position := FRegistry.ReadInteger('Count');
      FUserId := FRegistry.ReadInteger('UserId');
      FPassword := FRegistry.ReadString('Password');
      FRembPasswd := FRegistry.ReadBool('RembPasswd');
      FAutoLogin := FRegistry.ReadBool('AutoLogin');
      FRegistry.CloseKey;
    end
    else
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', True) then
    begin
      FRegistry.WriteString('Host', LeHost.Text);
      FRegistry.WriteInteger('Port', UdPort.Position);
      FRegistry.WriteInteger('Count', UdCount.Position);
      FRegistry.CloseKey;
    end;
  except
  end;
end;

procedure TFrmSetting.FormDestroy(Sender: TObject);
begin
  FRegistry.Free;
end;

procedure TFrmSetting.SetUserId(Value: Integer);
begin
  FUserId := Value;
  try
    FRegistry.RootKey:= HKEY_CURRENT_USER;
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', True) then
    begin
      FRegistry.WriteInteger('UserId', Value);
      FRegistry.CloseKey;
    end;
  except
  end;
end;

procedure TFrmSetting.SetPassword(Value: String);
begin
  FPassword := Value;
  try
    FRegistry.RootKey:= HKEY_CURRENT_USER;
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', True) then
    begin
      FRegistry.WriteString('Password', Value);
      FRegistry.CloseKey;
    end;
  except
  end;
end;

procedure TFrmSetting.SetRembPasswd(Value: Boolean);
begin
  FRembPasswd := Value;
  try
    FRegistry.RootKey:= HKEY_CURRENT_USER;
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', True) then
    begin
      FRegistry.WriteBool('RembPasswd', Value);
      FRegistry.CloseKey;
    end;
  except
  end;
end;

procedure TFrmSetting.SetAutoLogin(Value: Boolean);
begin
  FAutoLogin := Value;
  try
    FRegistry.RootKey:= HKEY_CURRENT_USER;
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', True) then
    begin
      FRegistry.WriteBool('AutoLogin', Value);
      FRegistry.CloseKey;
    end;
  except
  end;
end;

procedure TFrmSetting.BtnOkClick(Sender: TObject);
begin
  try
    FRegistry.RootKey:= HKEY_CURRENT_USER;
    if FRegistry.OpenKey('\Software\Lanbo\ezFamily', True) then
    begin
      FRegistry.WriteString('Host', LeHost.Text);
      FRegistry.WriteInteger('Port', UdPort.Position);
      FRegistry.WriteInteger('Count', UdCount.Position);
      FRegistry.CloseKey;
    end;
  except
  end;
end;

end.
