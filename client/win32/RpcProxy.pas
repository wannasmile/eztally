unit RpcProxy;

interface

uses
  Classes, SysUtils, Windows, Forms, ComCtrls, Dialogs, DIMime, XmlRpcTypes, XmlRpcClient;

type
  TTallyItem = record
    Id: Integer;
    TypeId: Integer;
    SubTypeId: Integer;
    Count: Integer;
    UserId: Integer;
    DateStr: String;
    Memo: String;
    TimeTag: String;
  end;
  TPTallyItem = ^TTallyItem;

  TStatItem = record
    Name: String;
    Value: Integer;
  end;
  TPStatItem = ^TStatItem;

  TStatReport = class(TObject)
  private
    FT0SubTypeStat: TList;
    FT1SubTypeStat: TList;
    FT0MonthStat: TList;
    FT1MonthStat: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property T0SubTypeStat: TList read FT0SubTypeStat write FT0SubTypeStat;
    property T1SubTypeStat: TList read FT1SubTypeStat write FT1SubTypeStat;
    property T0MonthStat: TList read FT0MonthStat write FT0MonthStat;
    property T1MonthStat: TList read FT1MonthStat write FT1MonthStat;
  end;

  TRpcProxy = class(TObject)
  private
    FRpcCaller: TRpcCaller;
    FSessionKey: String;
    F0SubTypes: TStrings;
    F1SubTypes: TStrings;
    FUsers: TStrings;
  public
    constructor Create(RpcCaller: TRpcCaller);
    destructor Destroy; override;

    function UserLogin(UserId: Integer; Password: String): Boolean;
    function GetLastTallyItems(Count, Offset: Integer; PTallyItems: TList): Integer; //return count
    function GetTallyItems(FromDate, ToDate: String; TypeId, SubTypeId, UserId: Integer; List: TListView): Integer; //return count
    function AddTallyItem(PTallyItem: TPTallyItem): Integer; //return ID
    function SaveTallyItem(PTallyItem: TPTallyItem): Boolean;
    function DelTallyItem(TallyItemId: Integer): Boolean;
    function GetStatReport(FromMonth, ToMonth: String; UserId: Integer; StatReport: TStatReport): Integer;
    function ExportTallyItems(FileName: String): Integer;

    property RpcCaller : TRpcCaller read FRpcCaller write FRpcCaller;
    property T0SubTypes: TStrings read F0SubTypes;
    property T1SubTypes: TStrings read F1SubTypes;
    property Users: TStrings read FUsers;
  end;


implementation

constructor TStatReport.Create;
begin
  inherited Create;

  FT0SubTypeStat := TList.Create;
  FT1SubTypeStat := TList.Create;
  FT0MonthStat := TList.Create;
  FT1MonthStat := TList.Create;
end;

destructor TStatReport.Destroy;
begin
  FT0SubTypeStat.Free;
  FT1SubTypeStat.Free;
  FT0MonthStat.Free;
  FT1MonthStat.Free;

  inherited Destroy;
end;

procedure TStatReport.Clear;
var
  i: Integer;
  PStatItem: TPStatItem;
begin
  for i:= 0 to (FT0SubTypeStat.Count-1) do
  begin
    PStatItem := FT0SubTypeStat[i];
    Dispose(PStatItem);
  end;
  FT0SubTypeStat.Clear;

  for i:= 0 to (FT1SubTypeStat.Count-1) do
  begin
    PStatItem := FT1SubTypeStat[i];
    Dispose(PStatItem);
  end;
  FT1SubTypeStat.Clear;

  for i:= 0 to (FT0MonthStat.Count-1) do
  begin
    PStatItem := FT0MonthStat[i];
    Dispose(PStatItem);
  end;
  FT0MonthStat.Clear;

  for i:= 0 to (FT1MonthStat.Count-1) do
  begin
    PStatItem := FT1MonthStat[i];
    Dispose(PStatItem);
  end;
  FT1MonthStat.Clear;
end;

constructor TRpcProxy.Create(RpcCaller: TRpcCaller);
begin
  inherited Create;
  FRpcCaller := RpcCaller;
  FSessionKey := '';

  F0SubTypes := TStringList.Create;
  F1SubTypes := TStringList.Create;
  FUsers := TStringList.Create;

  F0SubTypes.Add('未分类');
  F0SubTypes.Add('薪资福利');
  F0SubTypes.Add('兼职外快');
  F0SubTypes.Add('投资收益');
  F0SubTypes.Add('人情礼金');

  F1SubTypes.Add('未分类');
  F1SubTypes.Add('餐饮食品');
  F1SubTypes.Add('公共服务');
  F1SubTypes.Add('家居日用');
  F1SubTypes.Add('汽车交通');
  F1SubTypes.Add('服饰化妆');
  F1SubTypes.Add('文化教育');
  F1SubTypes.Add('休闲娱乐');
  F1SubTypes.Add('房屋物业');
  F1SubTypes.Add('储蓄投资');
  F1SubTypes.Add('医疗保健');
  F1SubTypes.Add('人情交际');

  FUsers.Add('男主人');
  FUsers.Add('女主人');
end;

destructor TRpcProxy.Destroy;
begin
  F0SubTypes.Clear;
  F0SubTypes.Free;
  F1SubTypes.Clear;
  F1SubTypes.Free;
  FUsers.Clear;
  FUsers.Free;

  inherited Destroy;
end;

function TRpcProxy.UserLogin(UserId: Integer; Password: String): Boolean;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
begin
  Result := False;
  FSessionKey := '';

  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'user_login';
  RpcFunc.AddItem(UserId);
  RpcFunc.AddItem(Password);

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if not RpcRes.IsError then
      //ShowMessageFmt('Error: (%d) %s', [RpcRes.ErrorCode, RpcRes.ErrorMsg])
    //else
    begin
      FSessionKey := RpcRes.AsString;
      Result := True;
    end;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络服务设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.GetStatReport(FromMonth, ToMonth: String; UserId: Integer; StatReport: TStatReport): Integer;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
  Item: TRpcArrayItem;
  PStatItem: TPStatItem;
  i: Integer;
begin
  Result := 0;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'get_stat_report';
  RpcFunc.AddItem(FSessionKey);
  RpcFunc.AddItem(FromMonth);
  RpcFunc.AddItem(ToMonth);
  RpcFunc.AddItem(UserId);

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if not RpcRes.IsError then
    begin
      //ShowMessage(RpcRes.AsArray.GetAsXML);
      Item := RpcRes.AsArray.Items[0];
      for i := 0 to (Item.AsArray.Count-1) do
      begin
        New(PStatItem);
        //ShowMessage(Item.AsArray.GetAsXML);
        PStatItem^.Name := Item.AsArray.Items[i].AsArray.Items[0].AsString;
        PStatItem^.Value := Item.AsArray.Items[i].AsArray.Items[1].AsInteger;
        StatReport.T0SubTypeStat.Add(PStatItem);
      end;
      Item := RpcRes.AsArray.Items[1];
      for i := 0 to (Item.AsArray.Count-1) do
      begin
        New(PStatItem);
        PStatItem^.Name := Item.AsArray.Items[i].AsArray.Items[0].AsString;
        PStatItem^.Value := Item.AsArray.Items[i].AsArray.Items[1].AsInteger;
        StatReport.T1SubTypeStat.Add(PStatItem);
      end;
      Item := RpcRes.AsArray.Items[2];
      for i := 0 to (Item.AsArray.Count-1) do
      begin
        New(PStatItem);
        PStatItem^.Name := Item.AsArray.Items[i].AsArray.Items[0].AsString;
        PStatItem^.Value := Item.AsArray.Items[i].AsArray.Items[1].AsInteger;
        StatReport.T0MonthStat.Add(PStatItem);
      end;
      Item := RpcRes.AsArray.Items[3];
      for i := 0 to (Item.AsArray.Count-1) do
      begin
        New(PStatItem);
        PStatItem^.Name := Item.AsArray.Items[i].AsArray.Items[0].AsString;
        PStatItem^.Value := Item.AsArray.Items[i].AsArray.Items[1].AsInteger;
        StatReport.T1MonthStat.Add(PStatItem);
      end;
      Result := RpcRes.AsArray.Count;
    end;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.GetTallyItems(FromDate, ToDate: String; TypeId, SubTypeId, UserId: Integer; List: TListView): Integer;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
  RpcItem: TRpcArrayItem;
  PTallyItem: TPTallyItem;
  Item: TListItem;
  i: Integer;
begin
  Result := 0;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'get_tallies';
  RpcFunc.AddItem(FSessionKey);
  RpcFunc.AddItem(FromDate);
  RpcFunc.AddItem(ToDate);
  RpcFunc.AddItem(TypeId);
  RpcFunc.AddItem(SubTypeId);
  RpcFunc.AddItem(UserId);

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if not RpcRes.IsError then
    begin
      New(PTallyItem);
      try
        for i := 0 to (RpcRes.AsArray.Count-1) do
        begin
          RpcItem := RpcRes.AsArray.Items[i];
          PTallyItem^.Id := RpcItem.AsArray.Items[0].AsInteger;
          PTallyItem^.TypeId := RpcItem.AsArray.Items[1].AsInteger;
          PTallyItem^.SubTypeId := RpcItem.AsArray.Items[2].AsInteger;
          PTallyItem^.Count := RpcItem.AsArray.Items[3].AsInteger;
          PTallyItem^.UserId := RpcItem.AsArray.Items[4].AsInteger;
          PTallyItem^.DateStr := RpcItem.AsArray.Items[5].AsString;
          if RpcItem.AsArray.Count > 6 then
            PTallyItem^.Memo := MimeDecodeString(RpcItem.AsArray.Items[6].AsString)
          else
            PTallyItem^.Memo := '';

          Item := List.Items.Add;
          if (PTallyItem^.TypeId = 0) then
          begin
            Item.Caption := '收';
            Item.ImageIndex := 0;
            Item.SubItems.Add(F0SubTypes[PTallyItem^.SubTypeId])
          end;
          if (PTallyItem^.TypeId = 1) then
          begin
            Item.Caption := '支';
            Item.ImageIndex := 1;
            Item.SubItems.Add(F1SubTypes[PTallyItem^.SubTypeId])
          end;
          Item.SubItems.Add(IntToStr(PTallyItem^.Count));
          Item.SubItems.Add(PTallyItem^.DateStr);
          Item.SubItems.Add(FUsers[PTallyItem^.UserId]);
          Item.SubItems.Add(PTallyItem^.Memo);
        end;
      finally
        Dispose(PTallyItem);
      end;
      Result := RpcRes.AsArray.Count;
    end;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.GetLastTallyItems(Count, Offset: Integer; PTallyItems: TList): Integer;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
  PTallyItem: TPTallyItem;
  RpcTallyItem: TRpcArrayItem;
  i: Integer;
begin
  Result := 0;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'get_last_tallies';
  RpcFunc.AddItem(FSessionKey);
  RpcFunc.AddItem(Count);
  RpcFunc.AddItem(Offset);

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if not RpcRes.IsError then
    begin
      for i := 0 to (RpcRes.AsArray.Count-1) do
      begin
        New(PTallyItem);
        RpcTallyItem := RpcRes.AsArray.Items[i];
        PTallyItem^.Id := RpcTallyItem.AsArray.Items[0].AsInteger;
        PTallyItem^.TypeId := RpcTallyItem.AsArray.Items[1].AsInteger;
        PTallyItem^.SubTypeId := RpcTallyItem.AsArray.Items[2].AsInteger;
        PTallyItem^.Count := RpcTallyItem.AsArray.Items[3].AsInteger;
        PTallyItem^.UserId := RpcTallyItem.AsArray.Items[4].AsInteger;
        PTallyItem^.DateStr := RpcTallyItem.AsArray.Items[5].AsString;
        if RpcTallyItem.AsArray.Count > 6 then
          PTallyItem^.Memo := MimeDecodeString(RpcTallyItem.AsArray.Items[6].AsString)
        else
          PTallyItem^.Memo := '';
        PTallyItems.Add(PTallyItem);
      end;
      Result := RpcRes.AsArray.Count;
    end;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.AddTallyItem(PTallyItem: TPTallyItem): Integer;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
begin
  Result := -1;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'add_tally';
  RpcFunc.AddItem(FSessionKey);
  RpcFunc.AddItem(PTallyItem^.TypeId);
  RpcFunc.AddItem(PTallyItem^.SubTypeId);
  RpcFunc.AddItem(PTallyItem^.Count);
  RpcFunc.AddItem(PTallyItem^.UserId);
  RpcFunc.AddItem(PTallyItem^.DateStr);
  RpcFunc.AddItem(MimeEncodeString(PTallyItem^.Memo));

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if RpcRes.IsError then
      ShowMessageFmt('Error: (%d) %s', [RpcRes.ErrorCode, RpcRes.ErrorMsg])
    else
      Result := RpcRes.AsInteger;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.SaveTallyItem(PTallyItem: TPTallyItem): Boolean;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
begin
  Result := False;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'save_tally';
  RpcFunc.AddItem(FSessionKey);
  RpcFunc.AddItem(PTallyItem^.Id);
  RpcFunc.AddItem(PTallyItem^.TypeId);
  RpcFunc.AddItem(PTallyItem^.SubTypeId);
  RpcFunc.AddItem(PTallyItem^.Count);
  RpcFunc.AddItem(PTallyItem^.UserId);
  RpcFunc.AddItem(PTallyItem^.DateStr);
  RpcFunc.AddItem(MimeEncodeString(PTallyItem^.Memo));

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if not RpcRes.IsError then
      Result := True;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.DelTallyItem(TallyItemId: Integer): Boolean;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
begin
  Result := False;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'del_tally';
  RpcFunc.AddItem(FSessionKey);
  RpcFunc.AddItem(TallyItemId);

  try
    RpcRes := FRpcCaller.Execute(RpcFunc);
    if not RpcRes.IsError then
      Result := True;
  except
    Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
  end;
end;

function TRpcProxy.ExportTallyItems(FileName: String): Integer;
var
  RpcFunc: IRpcFunction;
  RpcRes: IRpcResult;
  RpcTallyItem: TRpcArrayItem;
  ItemStr: String;
  i, PageNo: Integer;
  Finished: Boolean;
  F: Text;
begin
  Result := 0;
  AssignFile(F, FileName);
  Rewrite(F);
  WriteLn(F, 'type_id,sub_type_id,count,user_id,date_str,memo');

  PageNo := 0;
  RpcFunc := TRpcFunction.Create;
  RpcFunc.ObjectMethod := 'get_last_tallies';

  Finished := False;
  while not Finished do
  begin
    RpcFunc.AddItem(FSessionKey);
    RpcFunc.AddItem(100); //limit
    RpcFunc.AddItem(100 * PageNo);   //offset
    try
      RpcRes := FRpcCaller.Execute(RpcFunc);
      Finished := RpcRes.IsError;
      
      if not Finished then
      begin
        Finished := (RpcRes.AsArray.Count = 0);
        for i := 0 to (RpcRes.AsArray.Count-1) do
        begin
          RpcTallyItem := RpcRes.AsArray.Items[i];
          ItemStr := IntToStr(RpcTallyItem.AsArray.Items[1].AsInteger) + ',';   //type_id
          ItemStr := ItemStr + IntToStr(RpcTallyItem.AsArray.Items[2].AsInteger) + ',';  //sub_type_id
          ItemStr := ItemStr + IntToStr(RpcTallyItem.AsArray.Items[3].AsInteger) + ',';    //count
          ItemStr := ItemStr + IntToStr(RpcTallyItem.AsArray.Items[4].AsInteger) + ',';    //user_id
          ItemStr := ItemStr + RpcTallyItem.AsArray.Items[5].AsString + ',';    //date_str
          if RpcTallyItem.AsArray.Count > 6 then
            ItemStr := ItemStr + RpcTallyItem.AsArray.Items[6].AsString;  //memo
          WriteLn(F, ItemStr);
        end;

        Result := Result + RpcRes.AsArray.Count;
        Inc(PageNo);
        RpcFunc.Clear;
      end;
    except
      Application.MessageBox('无法访问网络服务, 请检查网络连接或软件的网络设置!', 'Error', MB_OK);
      Finished := True;
    end;
  end;
  
  CloseFile(F);
end;

end.
