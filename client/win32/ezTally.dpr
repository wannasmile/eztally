
program ezTally;

uses
  Forms,
  Controls,
  RpcProxy in 'RpcProxy.pas',
  Main in 'Main.pas' {FrmMain},
  Tally in 'Tally.pas' {FrmTally: TFrame},
  Login in 'Login.pas' {FrmLogin: TFrame},
  Setting in 'Setting.pas' {FrmSetting},
  Report in 'Report.pas' {FrmReport},
  Query in 'Query.pas' {FrmQuery};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'ezTally';
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmReport, FrmReport);
  Application.CreateForm(TFrmQuery, FrmQuery);
  Application.Run;
end.
