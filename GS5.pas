unit GS5;

interface

uses Windows, GS5_Intf;


type

TRunMode = ( RM_SDK, RM_WRAP );


TGSObject = class(TObject)
protected
  _handle: gs_handle_t;
public
  constructor Create(handle: gs_handle_t);
  destructor Destroy; override;

  property Handle: gs_handle_t read _handle;
end;

//User defined variables or Parameters of action / licenses.

TGSVariable = class(TGSObject)
private
    function getName: AnsiString;
    function getType: var_type_t;
    function getPermission: AnsiString;
    function getValAsStr: AnsiString;
    function getValAsFloat: Single;
    function getValAsInt: Integer;
    function getValAsInt64: Int64;
    function isValid: Boolean;
    function getValAsUTCTime: TDateTime;
    function getValAsDouble: Double;
public
  class function getTypeName(varType: var_type_t): AnsiString;

  //Permission conversion helpers
  class function PermissionFromString(const permitStr: AnsiString): Integer;
  class function PermissionToString(permit: Integer): AnsiString;
  //Setter
  procedure fromString(const v: AnsiString);
  procedure fromInt(const v: Integer);
  procedure fromInt64(const v: Int64);
  procedure fromFloat(const v: Single);
  procedure fromDouble(const v: Double);
  procedure fromUTCTime(const time: TDateTime);

  property Name: AnsiString read getName;
  property VarType: var_type_t read getType;
  property Permission: AnsiString read getPermission;

  property Valid: Boolean read isValid;
  //Getter
  property AsString: AnsiString read getValAsStr;
  property AsInt: Integer read getValAsInt;
  property AsInt64: Int64 read getValAsInt64;
  property AsFloat: Single read getValAsFloat;
  property AsDouble: Double read getValAsDouble;
  property AsUTCTime: TDateTime read getValAsUTCTime;
end;

TGSAction = class(TGSObject)
private
  _totalParams: Integer;

    procedure AfterConstruction; override;
    function getDescription: AnsiString;
    function getId: action_id_t;
    function getName: AnsiString;
    function getWhatToDo: AnsiString;
public
    function getParamByIndex(index: Integer): TGSVariable;
    function getParamByName(const name: AnsiString): TGSVariable;
  //Properties
  property Name: AnsiString read getName;
  property Id: action_id_t read getId;
  property Description: AnsiString read getDescription;
  property WhatToDo: AnsiString read getWhatToDo;

  property ParamCount : Integer read _totalParams;
  property Params[index: Integer]: TGSVariable read getParamByIndex;
end;

TGSEntity = class;

TGSLicense = class(TGSObject)
private
  _totalParams: Integer;
  _totalActs: Integer;
  _licensedEntity: TGSEntity;

  procedure AfterConstruction; override;
  function getDescription: AnsiString;
  function getId: AnsiString;
  function getIsValid: Boolean;
  function getName: AnsiString;
  function getStatus: TLicenseStatus;
  function getActionIds(index: Integer): action_id_t;
  function getActionNames(index: Integer): AnsiString;
  function getUnlockLicenseRequestCode: String;

  function getParamStr(const paramName: AnsiString): AnsiString;
  procedure setParamStr(const paramName, val: AnsiString);

  function getParamInt(const paramName: AnsiString): Integer;
  procedure setParamInt(const paramName: AnsiString; val: Integer);

  function getParamInt64(const paramName: AnsiString): Int64;
  procedure setParamInt64(const paramName: AnsiString; val: Int64);

  function getParamBool(const paramName: AnsiString): Boolean;
  procedure setParamBool(const paramName: AnsiString; val: Boolean);

  function getParamFloat(const paramName: AnsiString): Single;
  procedure setParamFloat(const paramName: AnsiString; val: Single);

  function getParamUTCTime(const paramName: AnsiString): TDateTime;
  procedure setParamUTCTime(const paramName: AnsiString; const val: TDateTime);
    function getParamDouble(const paramName: AnsiString): Double;
    procedure setParamDouble(const paramName: AnsiString;
      const Value: Double);


public
    constructor Create(hLic: TLicenseHandle); overload;
    constructor Create(const licId: AnsiString); overload;
    constructor Create(entity: TGSEntity; hLic: TLicenseHandle); overload;

    function bindToEntity( entity: TGSEntity): Boolean;

    function getParamByIndex(index: Integer): TGSVariable;
    function getParamByName(const name: AnsiString): TGSVariable;

    class function StatusToStr(stat: TLicenseStatus): string;
    {** \brief Lock a license
    *
    *  In GS5, we can lock a license from code explicitly, but cannot unlock it without applying an authorized action
    *}
    procedure lock;

  //Properties
  property Id: AnsiString read getId;
  property Name: AnsiString read getName;
  property Description: AnsiString read getDescription;
  property Status: TLicenseStatus read getStatus;
  property IsValid: Boolean read getIsValid;
  property LicensedEntity: TGSEntity read _licensedEntity;

  property ParamCount: Integer read _totalParams;
  property Params[ index: Integer ]: TGSVariable read getParamByIndex;
  //Param Helpers
  property ParamStr[const paramName: AnsiString]: AnsiString read getParamStr write setParamStr;
  property ParamInt[const paramName: AnsiString]: Integer read getParamInt write setParamInt;
  property ParamInt64[const paramName: AnsiString]: Int64 read getParamInt64 write setParamInt64;
  property ParamBool[const paramName: AnsiString]: Boolean read getParamBool write setParamBool;
  property ParamFloat[const paramName: AnsiString]: Single read getParamFloat write setParamFloat;
  property ParamDouble[const paramName: AnsiString]: Double read getParamDouble write setParamDouble;
  property ParamUTCTime[const paramName: AnsiString]: TDateTime read getParamUTCTime write setParamUTCTime;


  property ActionCount: Integer read _totalActs;
  property ActionIDs[ index: Integer ]: action_id_t read getActionIds;
  property ActionNames[ index: Integer ]: AnsiString read getActionNames;

  property UnlockRequestCode: String read getUnlockLicenseRequestCode;
end;

TGSRequest = class(TGSObject)
private
    function getCode: AnsiString;
public
  //Global action targeting all entities
  function addAction(actId: action_id_t): TGSAction; overload;
  //Action targeting all licenses of an entity
  function addAction(actId: action_id_t; entity: TGSEntity): TGSAction; overload;
  //Action targeting a single license of an entity by object
  function addAction(actId: action_id_t; lic: TGSLicense): TGSAction; overload;
  //Action targeting a single license of an entity by names
  function addAction(actId: action_id_t; const entityId, licenseId: AnsiString): TGSAction; overload;

  property Code: AnsiString read getCode;
end;


TGSEntity = class(TGSObject)
private
    _license: TGSLicense;

    function getAttr: DWORD;
    function getId: AnsiString;
    function getName: AnsiString;
    function getDescription: AnsiString;
    function isAccessible: Boolean;
    function isAccessing: Boolean;
    function isUnlocked: Boolean;
    function getUnlockEntityRequestCode: String;
    function isLocked: Boolean;

public
  constructor Create(hEntity: TEntityHandle);
  destructor Destroy; override;

  function beginAccess: Boolean;
  function endAccess: Boolean;

  /// Lock the bundled license
  procedure lock;

  //Properties
  property License: TGSLicense read _license;

  property Attribute: DWORD read getAttr;
  property Id: AnsiString read getId;
  property Name: AnsiString read getName;
  property Description: AnsiString read getDescription;

  property Accessing: Boolean read isAccessing;
  property Accessible: Boolean read isAccessible;
  property Unlocked: Boolean read isUnlocked;
  property Locked: Boolean read isLocked;

  property UnlockRequestCode: String read getUnlockEntityRequestCode;
end;

//TMovePackage
TMovePackage = class(TGSObject)
public
  constructor Create(handle: TMPHandle);
  destructor Destroy; override;

  procedure addEntityId(const entityId: AnsiString);
    ///------- Move License Online --------
    ///Returns a receipt ( actually a SN ) from server on success
    ///
    /// It will be used to activate app on the target machine so
    /// should be saved in a safely place.
    ///
    /// After this api returns, the entities in this move package are locked.
    ///
  function upload(const preSN: AnsiString = ''):AnsiString;
  function isTooBigToUpload: Boolean;

    ///----- Move License Offline ---------
    ///Returns encrypted data string of move package
    /// It will be used to activate app on the target machine so
    /// should be saved in a safely place.
    ///
    /// On Success:
    ///   return non-empty string, and the entities in this move package are locked.
    ///
    function exportData: AnsiString;
    function getImportOfflineRequestCode: AnsiString;
    function importOffline(const licenseCode: AnsiString): Boolean;
    function importOnline(const preSN: AnsiString): Boolean;
    function canPreliminarySNResolved: Boolean;

end;

TGSAppEventHandler = procedure (eventId: Integer) of object;
TGSLicenseEventHandler = procedure (eventId: Integer) of object;
TGSEntityEventHandler = procedure (eventId: Integer; entity: TGSEntity) of object;

TGSCore = class(TObject)
private
  _rc: Integer;
//  _totalEntities: Integer;

  _appEventHandler : TGSAppEventHandler;
  _licEventHandler : TGSLicenseEventHandler;
  _entityEventHandler: TGSEntityEventHandler;

    function getSDKVer: AnsiString;
    function getLastErrorCode: Integer;
    function getLastErrorMessage: AnsiString;
    function getBuildId: Integer;
    function getRunMode: TRunMode;
    function isRunInVM: Boolean;
    function getVarByName(const name: AnsiString): TGSVariable;
    procedure OnEvent(eventId: Integer; hEvent: TEventHandle);
    function getProductId: AnsiString;
    function getProductName: AnsiString;

    constructor Create;
    function getUnlockAllEntitiesRequestCode: String;
    function getCleanRequestCode: String;
    function getDummyRequestCode: String;
    function getFixRequestCode: String;
    function getTotalEntities: Integer;
    function getPreliminarySN: string;
public
  class function getInstance: TGSCore;

  //Convert event id to human readable string, for debug purpose
  class function getEventName(const eventId: Integer): String;

  { Runtime Initializer, always update local storage as needed. [Read & Write] }
  //Loads from local storage first, if not found, loads from external license file.
  function init(const productId, productLic, licPassword: AnsiString): Boolean; overload;
  //Loads from local storage first, if not found, loads from embedded license data.
  //wrapped application embeds all parameters in game.
  function init: Boolean; overload;

  //Initialize from in-memory license data
  function init(const productId: AnsiString; const pLicData: Pointer; licSize: Integer;  const licPassword: AnsiString): Boolean; overload;

  procedure cleanUp;

  //Save license immediately if dirty
  procedure flush;

  function revokeApp: Boolean;
  function revokeSN(const sn: AnsiString): Boolean;

  function getEntityByIndex(index: Integer): TGSEntity;
  function getEntityById(entityId: entity_id_t): TGSEntity;

  //Variables
  function addVariable(const varName: AnsiString; varType: var_type_t;
      permission: DWORD; const initValStr: AnsiString): TGSVariable;

  function removeVariable(const varName: AnsiString): Boolean;

  function getTotalVariables: Integer;
  function getVariableByIndex(idx: Integer): TGSVariable;
  function getVariableByName(const varName: AnsiString): TGSVariable;

  //app first launch
  function isAppFirstLaunched: Boolean;

  //Request
  function createRequest: TGSRequest;
  function applyLicenseCode(const code: AnsiString; const sn: AnsiString = ''): Boolean;


  //---------- Time Engine Service ------------
  procedure turnOnInternalTimer;
  procedure turnOffInternalTimer;
  function isInternalTimerActive: Boolean;
  procedure tickFromExternalTimer;
  procedure pauseTimeEngine;
  procedure resumeTimeEngine;
  function isTimeEngineActive: Boolean;

  //-------- HTML Render -----------
  function renderHTML(const url, title: AnsiString; width, height: Integer): Boolean; overload;
  function renderHTML(const url, title: AnsiString; width, height: Integer;
    resizable, exitAppWhenUIClosed, cleanUpAfterRendering: Boolean): Boolean; overload;

  //-------- Monitor Events ----------

  //------- Debug Helpers ---------
  class function isDebugVersion: Boolean;
  procedure trace(const msg: String);

  //------ Server ----------
  function isServerAlive: Boolean;
  function applySN(const sn: AnsiString;  pRetCode: PInteger = nil): Boolean;
  function isValidSN(const sn: AnsiString): Boolean;


  //Deactivate all entities
   procedure lockAllEntities;
   function isAllEntitiesLocked: Boolean;
  //------ Move ------------
  { \brief Create a new move package
  *
  *  \param mpDataStr the encrypted data string of a move package.
  *         if mpDataStr == '', then an empty move package is created
  *}
  function createMovePackage(const mpDataStr: AnsiString = ''): TMovePackage;

  //Move the whole license via online license server
  //Return: on success, a non-empty receipt (SN) to activate app later on target machine
  function uploadApp(const preSN: AnsiString = ''): AnsiString;

  //Move the whole license manually / offline
  //Return: on success, a non-empty encrypted string contains the current license data.
  function exportApp: AnsiString;

  //======================================================
  property ReturnCode: Integer read _rc;
  property LastErrorMessage: AnsiString read getLastErrorMessage;
  property LastErrorCode: Integer read getLastErrorCode;

  property SDKVersion: AnsiString read getSDKVer;

  property ProductName: AnsiString read getProductName;
  property ProductId: AnsiString read getProductId;
  property BuildId: Integer read getBuildId;

  property RunMode: TRunMode read getRunMode;
  property RunInVM: Boolean read isRunInVM;

  property EntityCount: Integer read getTotalEntities;
  property Entities[index: Integer]: TGSEntity read getEntityByIndex;

  property Variables[ const name: AnsiString ]: TGSVariable read getVarByName;

  property OnAppEvent: TGSAppEventHandler read _appEventHandler write _appEventHandler;
  property OnLicenseEvent: TGSLicenseEventHandler read _licEventHandler write _licEventHandler;
  property OnEntityEvent: TGSEntityEventHandler read _entityEventHandler write _entityEventHandler;

  (* --------------- Request Code Helpers ------------------------ *)
  //Unlock all entities request code
  property UnlockRequestCode: String read getUnlockAllEntitiesRequestCode;
  //Cleanup request code
  property CleanRequestCode: String read getCleanRequestCode;
  //license error fix request code
  property FixRequestCode: String read getFixRequestCode;
  //Dummy request code
  property DummyRequestCode: String read getDummyRequestCode;

  property PreliminarySN: String read getPreliminarySN;
end;



TLM_Inspector = class
protected
  _lic: TGSLicense;
public
  constructor Create(lic: TGSLicense);

  //Properties
  property License: TGSLicense read _lic;
end;

//*********** Built-in License Model Inspectors **************
TLM_Period = class
private
  _lic: TGSLicense;

  function getExpireDate: TDateTime;
  function getExpirePeriodInSeconds: Integer;
  function getFirstAccessDate: TDateTime;
  function getSecondsLeft: Integer;
  function getSecondsPassed: Integer;

public
  constructor Create; overload;
  constructor Create(lic: TGSLicense); overload;

  procedure attach(lic: TGSLicense);

  //The license has already been used before. (first access time is valid date time)
  function isUsed: Boolean;

  property ExpirePeriodInSeconds: Integer read getExpirePeriodInSeconds;
  property SecondsLeft: Integer read getSecondsLeft;
  property SecondsPassed: Integer read getSecondsPassed;
  property FirstAccessDate: TDateTime read getFirstAccessDate; //UTC
  property ExpireDate: TDateTime read getExpireDate;           //UTC
end;

//Helpers
function UTCToLocal(const dtUTC: TDateTime): TDateTime;
function LocalToUTC(const dtLocal: TDateTime): TDateTime;
function UnixTimeToUTC(const unixTime: Int64): TDateTime;
function UTCToUnixTime(const dtUTC: TDateTime): Int64;

function TimeSpanStr(const seconds: Integer): string;


implementation

uses SysUtils, DateUtils
{$ifdef DEBUG}
 ,unDebugHelper
{$endif};


//------------ Helpers -----------------------------
function UTCToLocal(const dtUTC: TDateTime): TDateTime;
var
  stUTC, stLocal: SYSTEMTIME;
begin
  DateTimeToSystemTime(dtUTC, stUTC);
  SystemTimeToTzSpecificLocalTime(nil, stUTC, stLocal);
  Result := SystemTimeToDateTime(stLocal);
end;

function TzSpecificLocalTimeToSystemTime(lpTimeZoneInformation: PTimeZoneInformation;
  var lpLocalTime, lpUniversalTime: TSystemTime): BOOL; stdcall; external kernel32 name 'TzSpecificLocalTimeToSystemTime';

function LocalToUTC(const dtLocal: TDateTime): TDateTime;
var
  stUTC, stLocal: SYSTEMTIME;
begin
  DateTimeToSystemTime(dtLocal, stLocal);
  TzSpecificLocalTimeToSystemTime(nil, stLocal, stUTC);
  Result := SystemTimeToDateTime(stUTC);
end;

function UnixTimeToUTC(const unixTime: Int64): TDateTime;
begin
  Result := IncSecond(EncodeDateTime(1970,1,1,0,0,0,0), unixTime);
end;

function UTCToUnixTime(const dtUTC: TDateTime): Int64;
begin
  Result := SecondsBetween(dtUTC, EncodeDateTime(1970,1,1,0,0,0,0));
end;

function TimeSpanStr(const seconds: Integer): string;
const
  SecsPerHour = SecsPerMin * MinsPerHour;
var
  x, d, h, m, s : Integer;
begin
  d := seconds div SecsPerDay;
  x := seconds - d * SecsPerDay;

  h := x div SecsPerHour;
  x := x - h * SecsPerHour;

  m := x div SecsPerMin;
  s := x - m * SecsPerMin;

  Result := '';
  if d > 0 then begin
    Result := Result + IntToStr(d) + ' day';
    if d > 1 then Result := Result + 's';
  end;

  if h > 0 then begin
    Result := Result + ' ' + IntToStr(h) + ' hour';
    if h > 1 then Result := Result + 's';
  end;

  if m > 0 then begin
    Result := Result + ' ' + IntToStr(m) + ' minute';
    if m > 1 then Result := Result + 's';
  end;

  if s > 0 then begin
    Result := Result + ' ' + IntToStr(s) + ' second';
    if s > 1 then Result := Result + 's';
  end;

  Result := TrimLeft(Result);
end;

{ TGSCore }

function TGSCore.addVariable(const varName: AnsiString; varType: var_type_t;
  permission: DWORD; const initValStr: AnsiString): TGSVariable;
var
  h : gs_handle_t;
begin
  h := gsAddVariable(PAnsiChar(varName), varType, permission, PAnsiChar(initValStr));
  if h <> INVALID_GS_HANDLE then Result := TGSVariable.Create(h) else Result := nil;
end;

function TGSCore.applyLicenseCode(const code: AnsiString; const sn: AnsiString): Boolean;
begin
  Result := gsApplyLicenseCodeEx(PAnsiChar(code), PAnsiChar(sn), nil);
end;

procedure s_MonitorCB(evtId: Integer; hEvent: TEntityHandle; usrData: Pointer);stdcall;
begin
  TGSCore(usrData).OnEvent(evtId, hEvent);
end;

constructor TGSCore.Create;
begin
  _rc := 0;
  _appEventHandler := nil;
  _licEventHandler := nil;
  _entityEventHandler := nil;

  gsCreateMonitorEx(s_MonitorCB, self, '$SDK');
end;

function TGSCore.init(const productId, productLic,
  licPassword: AnsiString): Boolean;
begin
  _rc := gsInit(PAnsiChar(productId), PAnsiChar(productLic), PAnsiChar(licPassword), nil);
  Result := _rc = 0;
end;

function TGSCore.init(const productId: AnsiString; const pLicData: Pointer; licSize: Integer;  const licPassword: AnsiString): Boolean;
begin
  _rc := gsInitEx(PAnsiChar(productId), pLicData, licSize, PAnsiChar(licPassword), nil);
  Result := _rc = 0;
end;

function TGSCore.init: Boolean;
begin
  _rc := gsInit(nil, nil, nil, nil);
  Result := _rc = 0;
end;

function TGSCore.createRequest: TGSRequest;
begin
  Result := TGSRequest.Create(gsCreateRequest);
end;

procedure TGSCore.cleanUp;
begin
  _rc := gsCleanUp;
end;

procedure TGSCore.flush;
begin
  gsFlush;
end;

function TGSCore.getBuildId: Integer;
begin
  Result := gsGetBuildId;
end;

function TGSCore.getEntityById(entityId: entity_id_t): TGSEntity;
var
  h : gs_handle_t;
begin
  h := gsOpenEntityById(entityId);
  if h <> INVALID_GS_HANDLE then Result := TGSEntity.Create(h)
  else Result := nil;
end;

function TGSCore.getEntityByIndex(index: Integer): TGSEntity;
var
  h: gs_handle_t;
begin
  if (index >= 0) and (index < EntityCount) then h := gsOpenEntityByIndex(index)
  else h := INVALID_GS_HANDLE;

  if h <> INVALID_GS_HANDLE then Result := TGSEntity.Create(h)
  else Result := nil;
end;

function TGSCore.getLastErrorCode: Integer;
begin
  Result := gsGetLastErrorCode;
end;

function TGSCore.getLastErrorMessage: AnsiString;
begin
  Result := gsGetLastErrorMessage;
end;

function TGSCore.getProductId: AnsiString;
begin
  Result := gsGetProductId;
end;

function TGSCore.getProductName: AnsiString;
begin
  Result := gsGetProductName;
end;

function TGSCore.getRunMode: TRunMode;
begin
  if gsRunInWrappedMode then Result := RM_WRAP
  else Result := RM_SDK;
end;

function TGSCore.getSDKVer: AnsiString;
begin
  Result := gsGetVersion;
end;

function TGSCore.getVarByName(const name: AnsiString): TGSVariable;
var
  h: gs_handle_t;
begin
  h := gsGetVariable(PAnsiChar(name));
  if h <> INVALID_GS_HANDLE then Result := TGSVariable.Create(h)
  else Result := nil;
end;

function TGSCore.isInternalTimerActive: Boolean;
begin
  Result := gsIsInternalTimerActive;
end;

function TGSCore.isRunInVM: Boolean;
begin
  Result := gsRunInsideVM($FFFFFFFF);
end;

function TGSCore.isTimeEngineActive: Boolean;
begin
  Result := gsIsTimeEngineActive;
end;

procedure TGSCore.OnEvent(eventId: Integer; hEvent: TEventHandle);
var
  entity: TGSEntity;
  evtType: TEventType;
begin
  evtType := gsGetEventType(hEvent);
  case evtType of
    EVENT_TYPE_APP:
      if Assigned(_appEventHandler) then _appEventHandler(eventId);
    EVENT_TYPE_LICENSE:
      if Assigned(_licEventHandler) then _licEventHandler(eventId);
    EVENT_TYPE_ENTITY:
      if Assigned(_entityEventHandler) then begin
        entity := TGSEntity.Create(gsGetEventSource(hEvent));
        try
          _entityEventHandler(eventId, entity);
        finally
          entity.Free;
        end;
      end;
  end;
end;

procedure TGSCore.pauseTimeEngine;
begin
  gsPauseTimeEngine;
end;

function TGSCore.removeVariable(const varName: AnsiString): Boolean;
begin
  Result := gsRemoveVariable(PAnsiChar(varName));
end;

function TGSCore.renderHTML(const url, title: AnsiString; width,
  height: Integer): Boolean;
begin
  Result := gsRenderHTML(PAnsiChar(url), PAnsiChar(title), width, height);
end;

function TGSCore.renderHTML(const url, title: AnsiString; width,
  height: Integer; resizable, exitAppWhenUIClosed,
  cleanUpAfterRendering: Boolean): Boolean;
begin
  Result := gsRenderHTMLEx(PAnsiChar(url), PAnsiChar(title), width, height, resizable, exitAppWhenUIClosed, cleanUpAfterRendering);
end;

procedure TGSCore.resumeTimeEngine;
begin
  gsResumeTimeEngine;
end;

procedure TGSCore.tickFromExternalTimer;
begin
  gsTickFromExternalTimer;
end;

procedure TGSCore.turnOffInternalTimer;
begin
  gsTurnOffInternalTimer;
end;

procedure TGSCore.turnOnInternalTimer;
begin
  gsTurnOnInternalTimer;
end;

var
  s_core : TGSCore = nil;

class function TGSCore.getInstance: TGSCore;
begin
  if s_core = nil then begin
    s_core := TGSCore.Create;
  end;
  Result := s_core;
end;

class function TGSCore.isDebugVersion: Boolean;
begin
  Result := gsIsDebugVersion;
end;

procedure TGSCore.trace(const msg: String);
begin
  gsTrace(PAnsiChar(msg));
end;


type
  TEventIdName = record
    id: Integer;
    name: String;
  end;

var
  s_id_names: array [0..20] of TEventIdName = (
    ( id: EVENT_APP_BEGIN; name: 'EVENT_APP_BEGIN'),
    ( id: EVENT_APP_RUN; name: 'EVENT_APP_RUN'),
    ( id: EVENT_APP_END; name: 'EVENT_APP_END'),
    ( id: EVENT_APP_CLOCK_ROLLBACK; name: 'EVENT_APP_CLOCK_ROLLBACK'),
    ( id: EVENT_APP_INTEGRITY_CORRUPT; name: 'EVENT_APP_INTEGRITY_CORRUPT'),

    ( id: EVENT_PASS_BEGIN_RING1; name: 'EVENT_PASS_BEGIN_RING1'),
    ( id: EVENT_PASS_BEGIN_RING2; name: 'EVENT_PASS_BEGIN_RING2'),
    ( id: EVENT_PASS_END_RING1; name: 'EVENT_PASS_END_RING1'),
    ( id: EVENT_PASS_END_RING2; name: 'EVENT_PASS_END_RING2'),
    ( id: EVENT_PASS_CHANGE; name: 'EVENT_PASS_CHANGE'),

    ( id: EVENT_LICENSE_NEWINSTALL; name: 'EVENT_LICENSE_NEWINSTALL'),
    ( id: EVENT_LICENSE_READY; name: 'EVENT_LICENSE_READY'),
    ( id: EVENT_LICENSE_FAIL; name: 'EVENT_LICENSE_FAIL'),
    ( id: EVENT_LICENSE_LOADING; name: 'EVENT_LICENSE_LOADING'),

    ( id: EVENT_ENTITY_TRY_ACCESS; name: 'EVENT_ENTITY_TRY_ACCESS'),
    ( id: EVENT_ENTITY_ACCESS_STARTED; name: 'EVENT_ENTITY_ACCESS_STARTED'),
    ( id: EVENT_ENTITY_ACCESS_ENDING; name: 'EVENT_ENTITY_ACCESS_ENDING'),
    ( id: EVENT_ENTITY_ACCESS_ENDED; name: 'EVENT_ENTITY_ACCESS_ENDED'),
    ( id: EVENT_ENTITY_ACCESS_INVALID; name: 'EVENT_ENTITY_ACCESS_INVALID'),
    ( id: EVENT_ENTITY_ACCESS_HEARTBEAT; name: 'EVENT_ENTITY_ACCESS_HEARTBEAT'),
    ( id: EVENT_ENTITY_ACTION_APPLIED; name: 'EVENT_ENTITY_ACTION_APPLIED')
    );

class function TGSCore.getEventName(const eventId: Integer): String;
var
  i: Integer;
begin
  for i := 0 to High(s_id_names) do begin
    if s_id_names[i].id = eventId then begin
      Result := s_id_names[i].name;
      Exit;
    end;
  end;
  Result := Format('Unknown Event [%d]', [eventId]);
end;

function TGSCore.getUnlockAllEntitiesRequestCode: String;
begin
  with createRequest do
  try
    addAction(ACT_UNLOCK);
    Result := Code;
  finally
    Free;
  end;
end;
function TGSCore.getFixRequestCode: String;
begin
  with createRequest do
  try
    addAction(ACT_FIX);
    Result := Code;
  finally
    Free;
  end;
end;

function TGSCore.getCleanRequestCode: String;
begin
  with createRequest do
  try
    addAction(ACT_CLEAN);
    Result := Code;
  finally
    Free;
  end;
end;

function TGSCore.getDummyRequestCode: String;
begin
  with createRequest do
  try
    addAction(ACT_DUMMY);
    Result := Code;
  finally
    Free;
  end;
end;

function TGSCore.getTotalEntities: Integer;
begin
  Result := gsGetEntityCount;
end;

function TGSCore.getTotalVariables: Integer;
begin
  Result := gsGetTotalVariables;
end;

function TGSCore.getVariableByIndex(idx: Integer): TGSVariable;
begin
  Result := TGSVariable.Create(gsGetVariableByIndex(idx));
end;

function TGSCore.getVariableByName(const varName: AnsiString): TGSVariable;
begin
  Result := TGSVariable.Create(gsGetVariable(PAnsiChar(varName)));
end;

function TGSCore.isAppFirstLaunched: Boolean;
begin
  Result := gsIsAppFirstLaunched;
end;

function TGSCore.isServerAlive: Boolean;
begin
  Result := gsIsServerAlive(-1);
end;

function TGSCore.applySN(const sn: AnsiString;  pRetCode: PInteger): Boolean;
var
  psnRef: PAnsiChar;
begin
  Result := gsApplySN(PAnsiChar(sn), pRetCode, psnRef, -1);
end;

function TGSCore.revokeApp: Boolean;
begin
  Result := gsRevokeApp(-1, nil);
end;

function TGSCore.revokeSN(const sn: AnsiString): Boolean;
begin
  Result := gsRevokeSN(-1, PAnsiChar(sn));
end;

function TGSCore.getPreliminarySN: string;
begin
  Result := gsGetPreliminarySN;
end;

function TGSCore.uploadApp(const preSN: AnsiString): AnsiString;
begin
  //make sure we have a valid preliminary serial number for online operation
  if (preSN <> '') or gsMPCanPreliminarySNResolved(nil) then
      Result := gsMPUploadApp(PAnsiChar(preSN), -1)
  else
    raise Exception.Create('TGSCore.uploadApp: Preliminary Serial must be available to upload app!');
end;

function TGSCore.createMovePackage(
  const mpDataStr: AnsiString): TMovePackage;
var
  hMP: TMPHandle;
begin
  if mpDataStr = '' then hMP := gsMPCreate(0)
  else hMP := gsMPOpen(PAnsiChar(mpDataStr));

  if hMP = nil then Result := nil
  else Result := TMovePackage.Create(hMP);
end;

function TGSCore.exportApp: AnsiString;
begin
  Result := gsMPExportApp;
end;

function TGSCore.isValidSN(const sn: AnsiString): Boolean;
begin
  Result := gsIsSNValid(PAnsiChar(sn), -1);
end;

function TGSCore.isAllEntitiesLocked: Boolean;
var
  i, N: Integer;
  e: TGSEntity;
begin
  Result := False;
  N := getTotalEntities;

  for i := 0 to N -1 do
  try
    e := getEntityByIndex(i);
    if not e.isLocked then Exit;
  finally
    e.Free;
  end;

  Result := true;
end;

procedure TGSCore.lockAllEntities;
var
  i, N: Integer;
  e: TGSEntity;
begin
  N := getTotalEntities;

  for i := 0 to N -1 do
  try
    e := getEntityByIndex(i);
    e.lock;
  finally
    e.Free;
  end;
end;


{ TGSObject }

constructor TGSObject.Create(handle: gs_handle_t);
begin
  if handle = INVALID_GS_HANDLE then raise Exception.Create('TGSObject.Create >> Invalid Handle!');
   
  _handle := handle;
end;

destructor TGSObject.Destroy;
begin
  gsCloseHandle(_handle);

  inherited;
end;

{ TGSEntity }


function TGSEntity.beginAccess: Boolean;
begin
  Result := gsBeginAccessEntity(_handle);
end;

constructor TGSEntity.Create(hEntity: TEntityHandle);
var
  h: gs_handle_t;
begin
  inherited Create(hEntity);

  _license := nil;
  if gsHasLicense(_handle) then begin
    h := gsOpenLicense(_handle);
    if h <> INVALID_GS_HANDLE then _license := TGSLicense.Create(Self, h);
  end;
end;

destructor TGSEntity.Destroy;
begin
  _license.Free;

  inherited;
end;

function TGSEntity.endAccess: Boolean;
begin
  Result := gsEndAccessEntity(_handle);
end;

function TGSEntity.getAttr: DWORD;
begin
  Result := gsGetEntityAttributes(_handle);
end;

function TGSEntity.getDescription: AnsiString;
begin
  Result := gsGetEntityDescription(_handle);
end;

function TGSEntity.getId: AnsiString;
begin
  Result := gsGetEntityId(_handle);
end;

function TGSEntity.getName: AnsiString;
begin
  Result := gsGetEntityName(_handle);
end;

function TGSEntity.getUnlockEntityRequestCode: String;
begin
  with TGSCore.getInstance.createRequest do
  try
    addAction(ACT_UNLOCK, self);
    Result := Code;
  finally
    Free;
  end;
end;

function TGSEntity.isAccessible: Boolean;
begin
  Result := (self.Attribute and ENTITY_ATTRIBUTE_ACCESSIBLE) <> 0;
end;

function TGSEntity.isAccessing: Boolean;
begin
  Result := (self.Attribute and ENTITY_ATTRIBUTE_ACCESSING) <> 0;
end;

function TGSEntity.isLocked: Boolean;
begin
  Result := (self.Attribute and ENTITY_ATTRIBUTE_LOCKED) <> 0;
end;

function TGSEntity.isUnlocked: Boolean;
begin
  Result := (self.Attribute and ENTITY_ATTRIBUTE_UNLOCKED) <> 0;
end;

procedure TGSEntity.lock;
begin
  self._license.lock;
end;

{ TGSLicense }

procedure TGSLicense.AfterConstruction;
begin
  inherited;
  _totalParams := gsGetLicenseParamCount(_handle);
  _totalActs := gsGetActionInfoCount(_handle);
end;

function TGSLicense.bindToEntity(entity: TGSEntity): Boolean;
begin
  if gsBindLicense(entity.Handle, Handle) then begin
    _licensedEntity := entity;
    Result := True;
  end else Result := False;
end;

constructor TGSLicense.Create(entity: TGSEntity; hLic: TLicenseHandle);
begin
  inherited Create(hLic);
  _licensedEntity := entity;
end;

constructor TGSLicense.Create(hLic: TLicenseHandle);
begin
  inherited Create(hLic);
  _licensedEntity := nil;
end;


constructor TGSLicense.Create(const licId: AnsiString);
begin
  self.Create(gsCreateLicense(PAnsiChar(licId)));
end;

function TGSLicense.getActionIds(index: Integer): action_id_t;
begin
  gsGetActionInfoByIndex(_handle, index, Result);
end;

function TGSLicense.getActionNames(index: Integer): AnsiString;
var
  dummy: action_id_t;
begin
  Result := gsGetActionInfoByIndex(_handle, index, dummy);
end;

function TGSLicense.getDescription: AnsiString;
begin
  Result := gsGetLicenseDescription(_handle);
end;

function TGSLicense.getId: AnsiString;
begin
  Result := gsGetLicenseId(_handle);
end;

function TGSLicense.getIsValid: Boolean;
begin
  Result := gsIsLicenseValid(_handle);
end;

function TGSLicense.getName: AnsiString;
begin
  Result := gsGetLicenseName(_handle);
end;

function TGSLicense.getParamByIndex(index: Integer): TGSVariable;
var
  h : gs_handle_t;
begin
  Result := nil;
  if (index >= 0) and (index < _totalParams) then begin
    h := gsGetLicenseParamByIndex(_handle, index);
    if h <> INVALID_GS_HANDLE then Result := TGSVariable.Create(h);
  end;
end;

function TGSLicense.getParamByName(const name: AnsiString): TGSVariable;
var
  h : gs_handle_t;
begin
  Result := nil;
  h := gsGetLicenseParamByName(_handle, PAnsiChar(name));
  if h <> INVALID_GS_HANDLE then Result := TGSVariable.Create(h);
end;

function TGSLicense.getParamBool(const paramName: AnsiString): Boolean;
begin
  with getParamByName(paramName) do
  try
    Result := AsInt <> 0;
  finally
    Free;
  end;
end;

function TGSLicense.getParamFloat(const paramName: AnsiString): Single;
begin
  with getParamByName(paramName) do
  try
    Result := AsFloat;
  finally
    Free;
  end;
end;

function TGSLicense.getParamDouble(const paramName: AnsiString): Double;
begin
  with getParamByName(paramName) do
  try
    Result := AsDouble;
  finally
    Free;
  end;
end;


function TGSLicense.getParamInt(const paramName: AnsiString): Integer;
begin
  with getParamByName(paramName) do
  try
    Result := AsInt;
  finally
    Free;
  end;
end;

function TGSLicense.getParamInt64(const paramName: AnsiString): Int64;
begin
  with getParamByName(paramName) do
  try
    Result := AsInt64;
  finally
    Free;
  end;
end;

function TGSLicense.getParamStr(
  const paramName: AnsiString): AnsiString;
begin
  with getParamByName(paramName) do
  try
    Result := AsString;
  finally
    Free;
  end;
end;

function TGSLicense.getParamUTCTime(
  const paramName: AnsiString): TDateTime;
begin
  with getParamByName(paramName) do
  try
    Result := AsUTCTime;
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamBool(const paramName: AnsiString;
  val: Boolean);
begin
  with getParamByName(paramName) do
  try
    fromInt(Ord(val));
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamFloat(const paramName: AnsiString;
  val: Single);
begin
  with getParamByName(paramName) do
  try
    fromFloat(val);
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamDouble(const paramName: AnsiString;
  const Value: Double);
begin
  with getParamByName(paramName) do
  try
    fromDouble(Value);
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamInt(const paramName: AnsiString;
  val: Integer);
begin
  with getParamByName(paramName) do
  try
    fromInt(val);
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamInt64(const paramName: AnsiString;
  val: Int64);
begin
  with getParamByName(paramName) do
  try
    fromInt64(val);
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamStr(const paramName, val: AnsiString);
begin
{$ifdef DEBUG}
  DebugMsg('TGSLicense.setParamStr(%s, %s)', [paramName, val]);
{$endif}  
  with getParamByName(paramName) do
  try
    fromString(val);
  finally
    Free;
  end;
end;

procedure TGSLicense.setParamUTCTime(const paramName: AnsiString;
  const val: TDateTime);
begin
  with getParamByName(paramName) do
  try
    fromUTCTime(val);
  finally
    Free;
  end;
end;

function TGSLicense.getStatus: TLicenseStatus;
begin
  Result := gsGetLicenseStatus(_handle);
end;

function TGSLicense.getUnlockLicenseRequestCode: String;
begin
  with TGSCore.getInstance.createRequest do
  try
    addAction(ACT_UNLOCK);
    Result := Code;
  finally
    Free;
  end;
end;

class function TGSLicense.StatusToStr(stat: TLicenseStatus): string;
begin
  case stat of
    STATUS_INVALID: Result := 'STATUS_INVALID';
    STATUS_LOCKED: Result := 'STATUS_LOCKED';
    STATUS_UNLOCKED: Result := 'STATUS_UNLOCKED';
    STATUS_ACTIVE: Result := 'STATUS_ACTIVE';
  else
    Result := 'Unknown Status: ' + IntToStr(Ord(stat));
  end;
end;


procedure TGSLicense.lock;
begin
  gsLockLicense(_handle);
end;

{ TGSAction }

procedure TGSAction.AfterConstruction;
begin
  inherited;
  _totalParams := gsGetActionParamCount(_handle);
end;

function TGSAction.getDescription: AnsiString;
begin
  Result := gsGetActionDescription(_handle);
end;

function TGSAction.getId: action_id_t;
begin
  Result := gsGetActionId(_handle);
end;

function TGSAction.getName: AnsiString;
begin
  Result := gsGetActionName(_handle);
end;

function TGSAction.getParamByIndex(index: Integer): TGSVariable;
var
  h: gs_handle_t;
begin
  Result := nil;
  if (index >= 0) and (index < _totalParams) then begin
    h := gsGetActionParamByIndex(_handle, index);
    if h <> INVALID_GS_HANDLE then Result := TGSVariable.Create(h);
  end;
end;

function TGSAction.getParamByName(const name: AnsiString): TGSVariable;
var
  h : gs_handle_t;
begin
  h := gsGetActionParamByName(_handle, PAnsiChar(name));
  if h <> INVALID_GS_HANDLE then Result := TGSVariable.Create(h)
  else Result := nil;
end;

function TGSAction.getWhatToDo: AnsiString;
begin
  Result := gsGetActionString(_handle);
end;

{ TGSVariable }

function TGSVariable.getName: AnsiString;
begin
  Result := gsGetVariableName(_handle);
end;

function TGSVariable.getPermission: AnsiString;
begin
  Result := PermissionToString(gsGetVariablePermission(_handle));
end;

function TGSVariable.getType: var_type_t;
begin
  Result := gsGetVariableType(_handle);
end;

class function TGSVariable.getTypeName(varType: var_type_t): AnsiString;
begin
  Result := gsVariableTypeToString(varType);
end;

function TGSVariable.getValAsFloat: Single;
begin
  if not gsGetVariableValueAsFloat(_handle, Result) then
    raise Exception.Create('Float conversion error');
end;

function TGSVariable.getValAsInt: Integer;
begin
  if not gsGetVariableValueAsInt(_handle, Result) then
    raise Exception.Create('Integer conversion error');
end;

function TGSVariable.getValAsInt64: Int64;
begin
  if not gsGetVariableValueAsInt64(_handle, Result) then
    raise Exception.Create('Int64 conversion error');
end;

function TGSVariable.getValAsStr: AnsiString;
begin
  Result := gsGetVariableValueAsString(_handle);
end;

procedure TGSVariable.fromInt(const v: Integer);
begin
  if not gsSetVariableValueFromInt(_handle, v) then
    raise Exception.Create('Integer conversion error');
end;

procedure TGSVariable.fromString(const v: AnsiString);
begin
  {$ifdef DEBUG}
  DebugMsg('TGSVariable.fromString: perm [ %s ]', [ Self.Permission ]);
  {$endif}
  if not gsSetVariableValueFromString(_handle, PAnsiChar(v)) then
    raise Exception.Create('AnsiString conversion error');
end;

procedure TGSVariable.fromFloat(const v: Single);
begin
  if not gsSetVariableValueFromFloat(_handle, v) then
    raise Exception.Create('Float conversion error');
end;

procedure TGSVariable.fromInt64(const v: Int64);
begin
  if not gsSetVariableValueFromInt64(_handle, v) then
    raise Exception.Create('Int64 conversion error');
end;

function TGSVariable.isValid: Boolean;
begin
  Result := gsIsVariableValid(_handle);
end;

procedure TGSVariable.fromUTCTime(const time: TDateTime);
var
  t: Int64;
begin
  t := UTCToUnixTime(time);
  if not gsSetVariableValueFromTime(_handle, t) then
    raise Exception.Create('Time conversion error');
end;

function TGSVariable.getValAsUTCTime: TDateTime;
var
  t: Int64;
begin
  if not gsGetVariableValueAsTime(_handle, t) then
    raise Exception.Create('Time conversion error');
    
  Result := UnixTimeToUTC( t );
end;

procedure TGSVariable.fromDouble(const v: Double);
begin
  if not gsSetVariableValueFromDouble(_handle, v) then
    raise Exception.Create('Double conversion error');
end;

function TGSVariable.getValAsDouble: Double;
begin
  if not gsGetVariableValueAsDouble(_handle, Result) then
    raise Exception.Create('Double conversion error');
end;

{ TGSRequest }

function TGSRequest.addAction(actId: action_id_t;
  lic: TGSLicense): TGSAction;
var
  h: gs_handle_t;
begin
  h := gsAddRequestAction(_handle, actId, lic._handle);
  if h <> INVALID_GS_HANDLE then Result := TGSAction.Create(h) else Result := nil;
end;

function TGSRequest.addAction(actId: action_id_t; const entityId,
  licenseId: AnsiString): TGSAction;
var
  h: gs_handle_t;
begin
  h := gsAddRequestActionEx(_handle, actId, PAnsiChar(entityId), PAnsiChar(licenseId));
  if h <> INVALID_GS_HANDLE then Result := TGSAction.Create(h) else Result := nil;
end;

function TGSRequest.addAction(actId: action_id_t): TGSAction;
var
  h: gs_handle_t;
begin
  h := gsAddRequestActionEx(_handle, actId, nil, nil);
  if h <> INVALID_GS_HANDLE then Result := TGSAction.Create(h) else Result := nil;
end;

function TGSRequest.addAction(actId: action_id_t;
  entity: TGSEntity): TGSAction;
var
  h: gs_handle_t;
begin
  h := gsAddRequestActionEx(_handle, actId, PAnsiChar(entity.Name), nil);
  if h <> INVALID_GS_HANDLE then Result := TGSAction.Create(h) else Result := nil;
end;

function TGSRequest.getCode: AnsiString;
begin
  Result := gsGetRequestCode(_handle);
end;

class function TGSVariable.PermissionFromString(const permitStr: AnsiString): Integer;
begin
  Result := gsVariablePermissionFromString(PAnsiChar(permitStr));
end;

class function TGSVariable.PermissionToString(permit: Integer): AnsiString;
begin
  SetLength(Result, 32);
  Result := gsVariablePermissionToString(permit, PAnsiChar(Result), 32);
end;

{ TLM_Period }

procedure TLM_Period.attach(lic: TGSLicense);
begin
  _lic := lic;
end;

constructor TLM_Period.Create(lic: TGSLicense);
begin
  _lic := lic;
end;

constructor TLM_Period.Create;
begin
end;

function TLM_Period.getExpireDate: TDateTime;
begin
  Result := IncSecond(self.FirstAccessDate, Self.ExpirePeriodInSeconds);
end;

function TLM_Period.getExpirePeriodInSeconds: Integer;
begin
  Result := _lic.getParamByName('periodInSeconds').getValAsInt;
end;

function TLM_Period.getFirstAccessDate: TDateTime;
var
  v : TGSVariable;
begin
  v := _lic.getParamByName('timeFirstAccess');
  try
    Result := UnixTimeToUTC(v.getValAsInt64);
  except
    raise ERangeError.Create('TLM_Period.FirstAccessDate');
  end;
end;

function TLM_Period.getSecondsLeft: Integer;
begin
  Result := Self.ExpirePeriodInSeconds - Self.SecondsPassed;
  if Result < 0 then Result := 0;
end;

function TLM_Period.getSecondsPassed: Integer;
begin
  if isUsed then begin
    Result := SecondsBetween(Now, UTCToLocal(Self.getFirstAccessDate));
    if Result < 0 then Result := 0;
  end else begin
    Result := 0;
  end;
end;

function TLM_Period.isUsed: Boolean;
begin
  Result := _lic.getParamByName('timeFirstAccess').Valid;
end;



{ TLM_Inspector }

constructor TLM_Inspector.Create(lic: TGSLicense);
begin
  _lic := lic;
end;


{ TMovePackage }

procedure TMovePackage.addEntityId(const entityId: AnsiString);
begin
  gsMPAddEntity(_handle, PAnsiChar(entityId));
end;

function TMovePackage.canPreliminarySNResolved: Boolean;
begin
  Result := gsMPCanPreliminarySNResolved(_handle);
end;

constructor TMovePackage.Create(handle: TMPHandle);
begin
  inherited Create(handle);
end;

destructor TMovePackage.Destroy;
begin
  inherited;
end;

function TMovePackage.exportData: AnsiString;
begin
  Result := gsMPExport(_handle);
end;

function TMovePackage.getImportOfflineRequestCode: AnsiString;
begin
  Result := gsMPGetImportOfflineRequestCode(_handle);
end;

function TMovePackage.importOffline(const licenseCode: AnsiString): Boolean;
begin
  Result := gsMPImportOffline(_handle, PAnsiChar(licenseCode));
end;

function TMovePackage.importOnline(const preSN: AnsiString): Boolean;
begin
  //make sure we have a valid preliminary SN for online operation
  if (preSN <> '') or canPreliminarySNResolved then
    Result := gsMPImportOnline(_handle, PAnsiChar(preSN), -1)
  else
    Result := False;
end;

function TMovePackage.isTooBigToUpload: Boolean;
begin
  Result := gsMPIsTooBigToUpload(_handle);
end;

function TMovePackage.upload(const preSN: AnsiString): AnsiString;
begin
  //make sure we have a valid preliminary SN for online operation
  if (preSN <> '') or canPreliminarySNResolved then
    Result := gsMPUpload(_handle, PAnsiChar(preSN), -1)
  else
    raise Exception.Create('TMovePackage.upload: Preliminary Serial must be available for uploading!');
end;

end.
