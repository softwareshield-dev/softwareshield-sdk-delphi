unit GS5_Ext;
{

  GS5 Extension Development

}
interface

uses Windows, Graphics, GS5_Intf, GS5;

type
{
     Custom License Model Development
}

//---- Application Monitor -----------
TGSApp = class
  private
    _core: TGSCore;

    _icon: TIcon;
    function getGameTitle: string; //Game Icon

    //Initialize for every game passes
    procedure init;
    procedure registerLicenseModels;

    //[INTERNAL]
    procedure OnPassBegin(ring: Integer);
    procedure OnPassEnd(ring: Integer);

  protected

    //
    function OnAppInit: Boolean; virtual;

    //Event Category handlers
    procedure OnAppEvent(evtId: Integer); virtual;
    procedure OnLicenseEvent( evtId: Integer); virtual;
    procedure OnEntityEvent(evtId: Integer; entity: TGSEntity); virtual;

    //--- App Specific Event Handlers
    procedure OnAppBegin; virtual;   //EVENT_APP_BEGIN
    procedure OnAppRun; virtual;     //EVENT_APP_RUN
    procedure OnAppEnd; virtual;     //EVENT_APP_END
    procedure OnClockRolledBack; virtual; //EVENT_APP_CLOCK_ROLLBACK
    procedure OnIntegrityCorrupted; virtual; //EVENT_APP_INTEGRITY_CORRUPT
    //---- License Specific Event Handlers
    procedure OnNewInstall; virtual; //EVENT_LICENSE_NEWINSTALL
    procedure OnLicenseLoading; virtual; //EVENT_LICENSE_LOADING
    procedure OnLicenseLoaded; virtual; //EVENT_LICENSE_READY
    procedure OnLicenseFail; virtual;  //EVENT_LICENSE_FAIL
    //----- Entity Specific Event Handlers
    procedure OnEntityAccessStarting(entity: TGSEntity); virtual;  //EVENT_ENTITY_TRY_ACCESS
    procedure OnEntityAccessStarted(entity: TGSEntity); virtual;    //EVENT_ENTITY_ACCESS_STARTED
    procedure OnEntityAccessEnding(entity: TGSEntity); virtual;    //EVENT_ENTITY_ACCESS_ENDING
    procedure OnEntityAccessEnded(entity: TGSEntity); virtual;      //EVENT_ENTITY_ACCESS_ENDED

    procedure OnEntityAccessInvalid(entity: TGSEntity); virtual; //EVENT_ENTITY_ACCESS_INVALID
    procedure OnEntityHeartBeat(entity: TGSEntity); virtual;  //EVENT_ENTITY_ACCESS_HEARTBEAT
    //------ Action Applied Event ------
    procedure OnEntityActionApplied(entity: TGSEntity); virtual; //EVENT_ENTITY_ACTION_APPLIED

    //
  public
    constructor Create;
    destructor Destroy; override;

    //------- App Control --------
    procedure exitApp(rc: Integer);
    procedure terminateApp(rc: Integer);
    procedure playApp;
    procedure restartApp;
    function isRestartedApp: Boolean;

    //----- App Running Context -----
    function isFirstLaunched: Boolean;

    function isFirstPass: Boolean;
    function isGamePass: Boolean;
    function isLastPass: Boolean;

    function isFirstGameExe: Boolean;
    function isLastGameExe: Boolean;

    function isMainThread: Boolean;

    function getAppRootPath: String;
    function getAppCommandLine: String;
    function getAppMainExe: String;
    //App Session Variables
    procedure setSessionVar(const name, val: AnsiString);
    function getSessionVar(const name: AnsiString): AnsiString;


    //Properties
    property GameTitle: string read getGameTitle;
    property GameIcon: TIcon read _icon;

    property RootPath: String read getAppRootPath;
    property CommandLine: String read getAppCommandLine;
    property MainExe: String read getAppMainExe;

    property SessionVars[ const name: AnsiString ]: AnsiString read getSessionVar write setSessionVar;
    property Core: TGSCore read _core;
end;

//--------- Custom License Model -----------
TGS_LM_OnIsValid = function: Boolean of object;
TGS_LM_OnStartAccess = procedure of object;
TGS_LM_OnFinishAccess = procedure of object;
TGS_LM_OnApplyAction = procedure(act: TGSAction) of object;

TGSDynamicLM = class
  private
    _lic: TGSLicense;

    //Event Handlers
    _onIsValid: TGS_LM_OnIsValid;
    _onStart: TGS_LM_OnStartAccess;
    _onFinish: TGS_LM_OnFinishAccess;
    _onApplyAction: TGS_LM_OnApplyAction;

    function getDescription: AnsiString;
    function getId: AnsiString;
    function getName: AnsiString;

    function isValid_: Boolean;
    procedure startAccess_;
    procedure finishAccess_;
    procedure onAction_(hAct: TActionHandle);


  protected
    //Initialize the instance (init properties, etc.)
    procedure init; virtual;

    procedure defineParamStr(const paramName,  paramInitValue: String; permission: Cardinal);
    procedure defineParamInt(const paramName: String; const paramInitValue: Integer; permission: Cardinal);
    procedure defineParamInt64(const paramName: String; const paramInitValue: Int64; permission: Cardinal);
    procedure defineParamBool(const paramName: String; const paramInitValue: Boolean; permission: Cardinal);
    procedure defineParamDouble(const paramName: String; const paramInitValue: Double; permission: Cardinal);
    procedure defineParamFloat(const paramName: String; const paramInitValue: Single; permission: Cardinal);
    procedure defineParamTime(const paramName: String; const paramInitValue: TDateTime; permission: Cardinal);

    //LM handlers
    //Sub-class should override these handlers or uses event properties
    function isValid: Boolean; virtual;
    procedure startAccess; virtual;
    procedure finishAccess; virtual;
    procedure onAction(act: TGSAction); virtual;

    constructor Create;
    destructor Destroy; override;

  public
    //Property
    property Id: AnsiString read getId;
    property Name: AnsiString read getName;
    property Description: AnsiString read getDescription;

    property License: TGSLicense read _lic;

    //Event Handlers
    property OnIsValid: TGS_LM_OnIsValid write _onIsValid;
    property OnStartAccess: TGS_LM_OnStartAccess write _onStart;
    property OnFinishAccess: TGS_LM_OnFinishAccess write _onFinish;
    property OnApplyAction: TGS_LM_OnApplyAction write _onApplyAction;
end;

TGSAppCls = class of TGSApp;
TGSLMCls =  class of TGSDynamicLM;

procedure registerApp(clsApp: TGSAppCls);
procedure registerLM(clsLM: TClass; const licId, licName, description: AnsiString);

function getGSApp: TGSApp;

implementation

uses ShellAPI, Classes
{$ifdef DEBUG}
  ,unDebugHelper
{$endif};

type
  PCustomLMInfo = ^TCustomLMInfo;
  TCustomLMInfo = record
    _cls: TClass;
    _id, _name, _description: AnsiString;
  end;

var
  s_clsApp: TGSAppCls = TGSApp;
  s_app: TGSApp;

  s_lms: TList = nil;

procedure registerApp(clsApp: TGSAppCls);
begin
  s_clsApp := clsApp;
end;

procedure registerLM(clsLM: TClass; const licId, licName, description: AnsiString);
var
  p : PCustomLMInfo;
begin
  if s_lms = nil then begin
    s_lms := TList.Create;
  end;

  New(p);
  p^._cls := clsLM;
  p^._id := licId;
  p^._name := licName;
  p^._description := description;
  s_lms.Add(p);
end;

function getGSApp: TGSApp;
begin
  if s_app = nil then s_app := s_clsApp.Create;
  Result := s_app;
end;

procedure GS5_Entry(srv: Pointer);stdcall;
begin
  {$IFDEF DEBUG}
  DebugMsg('GS5_Entry: Initialize GSApp...');
  {$ENDIF}
  //Application launching, initializes my LM class instance.
  getGSApp;
end;

exports GS5_Entry;


{ TGSDynamicLM }

function fcb_isValid(usrData: Pointer): Boolean; stdcall;
begin
  Result := TGSDynamicLM(usrData).IsValid_();
end;

procedure fcb_startAccess(usrData: Pointer); stdcall;
begin
  TGSDynamicLM(usrData).startAccess_;
end;

procedure fcb_finishAccess(usrData: Pointer); stdcall;
begin
  TGSDynamicLM(usrData).finishAccess_;
end;

procedure fcb_onAction(hAct: TActionHandle; usrData: Pointer); stdcall;
begin
  TGSDynamicLM(usrData).onAction_(hAct);
end;

procedure fcb_onDestroy(usrData: Pointer); stdcall;
begin
  TGSDynamicLM(usrData).Destroy;
end;

constructor TGSDynamicLM.Create;
begin
end;

procedure TGSDynamicLM.defineParamBool(const paramName: String;
  const paramInitValue: Boolean; permission: Cardinal);
begin
  gsAddLicenseParamBool(_lic.Handle, PAnsiChar(paramName), paramInitValue, permission);
end;

procedure TGSDynamicLM.defineParamDouble(const paramName: String;
  const paramInitValue: Double; permission: Cardinal);
begin
  gsAddLicenseParamDouble(_lic.Handle, PAnsiChar(paramName), paramInitValue, permission);
end;

procedure TGSDynamicLM.defineParamFloat(const paramName: String;
  const paramInitValue: Single; permission: Cardinal);
begin
  gsAddLicenseParamFloat(_lic.Handle, PAnsiChar(paramName), paramInitValue, permission);
end;

procedure TGSDynamicLM.defineParamInt(const paramName: String;
  const paramInitValue: Integer; permission: Cardinal);
begin
  gsAddLicenseParamInt(_lic.Handle, PAnsiChar(paramName), paramInitValue, permission);
end;

procedure TGSDynamicLM.defineParamInt64(const paramName: String;
  const paramInitValue: Int64; permission: Cardinal);
begin
  gsAddLicenseParamInt64(_lic.Handle, PAnsiChar(paramName), paramInitValue, permission);
end;

procedure TGSDynamicLM.defineParamStr(const paramName,
  paramInitValue: String; permission: Cardinal);
begin
  gsAddLicenseParamStr(_lic.Handle, PAnsiChar(paramName), PAnsiChar(paramInitValue), permission);
end;

procedure TGSDynamicLM.defineParamTime(const paramName: String;
  const paramInitValue: TDateTime; permission: Cardinal);
begin
  gsAddLicenseParamTime(_lic.Handle, PAnsiChar(paramName), UTCToUnixTime(paramInitValue), permission);
end;

destructor TGSDynamicLM.Destroy;
begin
  _lic.Free;
  inherited;
end;


procedure TGSDynamicLM.finishAccess;
begin
end;

procedure TGSDynamicLM.finishAccess_;
begin
  if Assigned(_onFinish) then _onFinish;
  finishAccess;
end;

function TGSDynamicLM.getDescription: AnsiString;
begin
  Result := _lic.Description;
end;

function TGSDynamicLM.getId: AnsiString;
begin
  Result := _lic.Id;
end;

function TGSDynamicLM.getName: AnsiString;
begin
  Result := _lic.Name;
end;

procedure TGSDynamicLM.init;
begin

end;

function TGSDynamicLM.isValid: Boolean;
begin
  Result := False;
end;

function TGSDynamicLM.isValid_: Boolean;
begin
  if Assigned(_onIsValid) then Result := _onIsValid()
  else Result := self.isValid;
end;

procedure TGSDynamicLM.onAction(act: TGSAction);
begin
end;

procedure TGSDynamicLM.onAction_(hAct: TActionHandle);
var
  act: TGSAction;
begin
  act := TGSAction.Create(hAct);
  try
    if Assigned(_onApplyAction) then _onApplyAction(act);
    onAction(act);
  finally
    act.Free;
  end;
end;

procedure TGSDynamicLM.startAccess;
begin
end;

procedure TGSDynamicLM.startAccess_;
begin
  if Assigned(_onStart) then _onStart;
  startAccess;
end;

{ TGSApp }

constructor TGSApp.Create;
begin
  //Initializes the gsCore
  _core := TGSCore.getInstance;
  //register my event handlers
  _core.OnAppEvent := OnAppEvent;
  _core.OnLicenseEvent := OnLicenseEvent;
  _core.OnEntityEvent := OnEntityEvent;

  _icon := TIcon.Create;
  _icon.Handle := ExtractIcon(GetModuleHandle(nil), PAnsiChar(MainExe), 0);
end;

destructor TGSApp.Destroy;
begin
  _core.cleanUp;
  _icon.Free;

  inherited;
end;

function TGSApp.getGameTitle: string;
begin
  Result := _core.ProductName;
end;

procedure TGSApp.init;
begin
  if not OnAppInit then begin
    {$ifdef DEBUG}
    DebugMsg('TGSApp.init >> terminating...');
    {$ENDIF}
    terminateApp(-1);
  end;
end;

function TGSApp.OnAppInit: Boolean;
begin
  Result := True;
end;

procedure TGSApp.OnAppBegin;
begin

end;

procedure TGSApp.OnAppEnd;
begin

end;

procedure TGSApp.OnAppEvent(evtId: Integer);
begin
  {$IFDEF DEBUG}
  DebugMsg('OnAppEvent >> Event [%s]', [_core.getEventName(evtId)]);
  {$ENDIF}
  case evtId of
    EVENT_PASS_BEGIN_RING1: OnPassBegin(1);
    EVENT_PASS_BEGIN_RING2: OnPassBegin(2);
    EVENT_PASS_END_RING1: OnPassEnd(1);
    EVENT_PASS_END_RING2: OnPassEnd(2);

    EVENT_APP_BEGIN: OnAppBegin;
    EVENT_APP_END:  OnAppEnd;
    EVENT_APP_RUN: OnAppRun;
    EVENT_APP_CLOCK_ROLLBACK: OnClockRolledBack;
    EVENT_APP_INTEGRITY_CORRUPT: OnIntegrityCorrupted;
  else
    {$IFDEF DEBUG}
    DebugMsg('Unknown Application Event [%s]', [_core.getEventName(evtId)]);
    {$ENDIF}
  end;
  {$IFDEF DEBUG}
  DebugMsg('OnAppEvent << Event [%s]', [_core.getEventName(evtId)]);
  {$ENDIF}
end;

procedure TGSApp.OnAppRun;
begin

end;

procedure TGSApp.OnClockRolledBack;
begin

end;

procedure TGSApp.OnEntityAccessEnded(entity: TGSEntity);
begin

end;

procedure TGSApp.OnEntityAccessInvalid(entity: TGSEntity);
begin

end;

procedure TGSApp.OnEntityAccessStarted(entity: TGSEntity);
begin

end;

procedure TGSApp.OnEntityActionApplied(entity: TGSEntity);
begin

end;

procedure TGSApp.OnEntityEvent(evtId: Integer; entity: TGSEntity);
begin
  case evtId of
    EVENT_ENTITY_TRY_ACCESS: OnEntityAccessStarting(entity);
    EVENT_ENTITY_ACCESS_STARTED: OnEntityAccessStarted(entity);
    EVENT_ENTITY_ACCESS_ENDING: OnEntityAccessStarting(entity);
    EVENT_ENTITY_ACCESS_ENDED: OnEntityAccessEnded(entity);
    EVENT_ENTITY_ACCESS_INVALID: OnEntityAccessInvalid(entity);
    EVENT_ENTITY_ACCESS_HEARTBEAT: OnEntityHeartBeat(entity);
    EVENT_ENTITY_ACTION_APPLIED: OnEntityActionApplied(entity);
  end;
end;

procedure TGSApp.OnEntityHeartBeat(entity: TGSEntity);
begin

end;

procedure TGSApp.OnIntegrityCorrupted;
begin

end;

procedure TGSApp.OnLicenseEvent(evtId: Integer);
begin
  case evtId of
    EVENT_LICENSE_NEWINSTALL:
    begin
      OnNewInstall();
    end;

    EVENT_LICENSE_LOADING:
    begin
      registerLicenseModels;
      OnLicenseLoading();
    end;

    EVENT_LICENSE_READY:
    begin
      OnLicenseLoaded();
    end;
    EVENT_LICENSE_FAIL:
    begin
      OnLicenseFail();
    end;
  end;
end;


procedure TGSApp.OnLicenseFail;
begin

end;

procedure TGSApp.OnLicenseLoaded;
begin
end;

procedure TGSApp.OnNewInstall;
begin

end;

procedure TGSApp.OnPassBegin(ring: Integer);
begin
  case ring of
    1:
    begin

    end;
    2:
    begin
      init;
    end;
  end;
end;

procedure TGSApp.OnPassEnd(ring: Integer);
begin

end;

function s_createLM(usrData: Pointer): TLicenseHandle; stdcall;
var
  p : PCustomLMInfo;
  lm: TObject;
begin
  p := PCustomLMInfo(usrData);
  lm := p^._cls.Create;  //freed on fcb_onDestroy

  Result := gsCreateCustomLicense(PAnsiChar(p^._id), PAnsiChar(p^._name), PAnsiChar(p^._description), Pointer(lm),
    fcb_isValid, fcb_startAccess, fcb_finishAccess, fcb_onAction, fcb_onDestroy);

  TGSDynamicLM(lm)._lic := TGSLicense.Create(Result);
  TGSDynamicLM(lm).init;
end;

procedure TGSApp.OnEntityAccessEnding(entity: TGSEntity);
begin

end;

procedure TGSApp.OnEntityAccessStarting(entity: TGSEntity);
begin

end;

procedure TGSApp.registerLicenseModels;
var
  i : Integer;
  p : PCustomLMInfo;
begin
  {$ifdef DEBUG}
  DebugMsg('registerLicenseModels >>');
  {$endif}
  if s_lms <> nil then begin
    for i := 0 to s_lms.Count-1 do begin
      p := PCustomLMInfo(s_lms[i]);
      gsRegisterCustomLicense(PAnsiChar(p^._id), s_createLM, p);
    end;
  end;
  {$ifdef DEBUG}
  DebugMsg('registerLicenseModels <<');
  {$endif}
end;

procedure TGSApp.OnLicenseLoading;
begin

end;

procedure TGSApp.exitApp(rc: Integer);
begin
  gsExitApp(rc);
end;

function TGSApp.getAppCommandLine: String;
begin
  Result := gsGetAppCommandLine;
end;

function TGSApp.getAppMainExe: String;
begin
  Result := gsGetAppMainExe;
end;

function TGSApp.getAppRootPath: String;
begin
  Result := gsGetAppRootPath;
end;

function TGSApp.getSessionVar(const name: AnsiString): AnsiString;
begin
  Result := gsGetAppVar(PAnsiChar(name));
end;

function TGSApp.isFirstGameExe: Boolean;
begin
  Result := gsIsFirstGameExe;
end;

function TGSApp.isFirstPass: Boolean;
begin
  Result := gsIsFirstPass;
end;

function TGSApp.isGamePass: Boolean;
begin
  Result := gsIsGamePass;
end;

function TGSApp.isLastGameExe: Boolean;
begin
  Result := gsIsLastGameExe;
end;

function TGSApp.isLastPass: Boolean;
begin
  Result := gsIsLastPass;
end;

function TGSApp.isMainThread: Boolean;
begin
  Result := gsIsMainThread;
end;

function TGSApp.isRestartedApp: Boolean;
begin
  Result := gsIsRestartedApp;
end;

procedure TGSApp.playApp;
begin
  gsPlayApp;
end;

procedure TGSApp.restartApp;
begin
  gsRestartApp;
end;

procedure TGSApp.setSessionVar(const name, val: AnsiString);
begin
  gsSetAppVar(PAnsiChar(name), PAnsiChar(val));
end;

procedure TGSApp.terminateApp(rc: Integer);
begin
  gsTerminateApp(rc);
end;

function TGSApp.isFirstLaunched: Boolean;
begin
  Result := gsIsAppFirstLaunched;
end;

end.
