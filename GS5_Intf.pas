unit GS5_Intf;

interface

uses Windows;

const
  INVALID_GS_HANDLE = nil;

  //---------- Entity Status Attributes ------
  /// Entity is currently accessible.
  ENTITY_ATTRIBUTE_ACCESSIBLE = 1;
  /// Entity's license is fully activated, no expire /trial limits at all.
  ENTITY_ATTRIBUTE_UNLOCKED = 2;
  ENTITY_ATTRIBUTE_FULLLICENSED = 2; //For backward compatibility
  /// Entity is active (being accessed via gsBeginAccessEntity())
  ENTITY_ATTRIBUTE_ACCESSING = 4;
  ENTITY_ATTRIBUTE_ACTIVE = 4; // For backward compatibility
  /// Entity is locked.
  ENTITY_ATTRIBUTE_LOCKED = 8;
  /// Entity is auto-start
  ENTITY_ATTRIBUTE_AUTOSTART = 16;

  //---------- License Model Property Permission ------------
  //the param is invisible from ICore/api and ILicenseInspector
  LM_PARAM_HIDDEN  = 1;
  //the param is not persistent
  LM_PARAM_TEMP  = 2;
  //the param can read via ICore
  LM_PARAM_READ =		4;
  //the param can write via ICore
  LM_PARAM_WRITE = 8;
  //the param is inheritable
  LM_PARAM_INHERIT = 16;

  //---------- Event IDs -------------
  //
  //IApplication
  EVENT_IDBASE_APPLICATION = 0;

  ///Application just gets started, please initialize
  EVENT_APP_BEGIN = 1;
  ///Application is going to terminate, last signal before game exits.
  EVENT_APP_END = 2;
  ///Alarm: Application detects the clock is rolled back
  EVENT_APP_CLOCK_ROLLBACK = 3;
  ///Fatal Error: Application integrity is corrupted.
  EVENT_APP_INTEGRITY_CORRUPT = 4;
  ///Application starts to run, last signal before game code is executing
  EVENT_APP_RUN = 5;

  //ILdrCore [INTERNAL]
  EVENT_PASS_BEGIN_RING1 = 20;
  EVENT_PASS_BEGIN_RING2 = 22;

  EVENT_PASS_END_RING1 = 21;
  EVENT_PASS_END_RING2 = 24;

  EVENT_PASS_CHANGE = 23;

  
  //ILicenseDoc
  EVENT_IDBASE_LICENSE = 100;
  ///Original license is uploaded to license store for the first time.
  EVENT_LICENSE_NEWINSTALL = 101;
  ///The application's license store is connected /initialized successfully (gsCore::gsInit() == 0)
  EVENT_LICENSE_READY = 102;

  ///The application's license store cannot be connected /initialized! (gsCore::gsInit() != 0)
  EVENT_LICENSE_FAIL = 103;

  //License is loading...
  EVENT_LICENSE_LOADING = 105;

  //IEntityCtl
  EVENT_IDBASE_ENTITY = 200;
(*
 * The entity is to be accessed.
 *
 * The listeners might be able to modify the license store here.
 * The internal licenses status are untouched. (inactive if not accessed before)
 *)
  EVENT_ENTITY_TRY_ACCESS = 201;

(*
 * The entity is being accessed.
 *
 * The listeners can enable any protected resources here. (inject decrypting keys, etc.)
 * The internal licenses status have changed to active mode.
 *)
  EVENT_ENTITY_ACCESS_STARTED = 202;
(*
 * The entity is leaving now.
 *
 * The listeners can revoke any protected resources here. (remove injected decrypting keys, etc.)
 * Licenses are still in active mode.
 *)
  EVENT_ENTITY_ACCESS_ENDING = 203;

(*
 * The entity is deactivated now.
 *
 * The listeners can revoke any protected resources here. (remove injected decrypting keys, etc.)
 * Licenses are kept in inactive mode.
 *)
  EVENT_ENTITY_ACCESS_ENDED = 204;

  /// Alarm: Entity access invalid (due to expiration, etc)
  EVENT_ENTITY_ACCESS_INVALID = 205;
  /// Internal ping event indicating entity is still alive.
  EVENT_ENTITY_ACCESS_HEARTBEAT = 206;
  /// Alarm: Entity Controller detects that the clock is rolled back!
  ///[ INTERNAL. translated to APP_CLOCK_ROLLBACK ]
  /// EVENT_ENTITY_CLOCK_ROLLBACK = 207;

(*
 * The status of attached licenses have been modified by applying license action.
 *
 * It is called after the change has been made.
 *
 *)
  EVENT_ENTITY_ACTION_APPLIED = 208;

  //ITimeEngine
  EVENT_IDBASE_TIMER = 400;

  //******************* Action IDs ********************
  /// Generic actions
  ACT_UNLOCK = 1;
  ACT_LOCK = 2;
  ACT_ENABLE_COPYPROTECTION = 6;
  ACT_DISABLE_COPYPROTECTION = 7;
  ACT_RESET_ALLEXPIRATION = 10;
  ACT_CLEAN = 11;
  ACT_DUMMY = 12;
  ACT_PUSH = 13;
  ACT_PULL = 14;

  ACT_NAG_ON = 15;
  ACT_NAG_OFF = 16;
  ACT_ONE_SHOT = 17;
  ACT_SHELFTIME= 18;
  ACT_FP_FIX = 19;  //deprecated by ACT_FIX sine 5.3
  ACT_FIX = 19;
  ACT_REVOKE = 20;

  (*
   * LM-specific actions
   *)

  //LM.expire.accessTime
  ACT_ADD_ACCESSTIME = 100;
  ACT_SET_ACCESSTIME = 101;

  //LM.expire.hardDate
  ACT_SET_STARTDATE = 102;
  ACT_SET_ENDDATE = 103;

  ACT_SET_SESSIONTIME = 104;

  //LM.expire.period
  ACT_SET_EXPIRE_PERIOD = 105;
  ACT_ADD_EXPIRE_PERIOD = 106;

  //LM.expire.duration
  ACT_SET_EXPIRE_DURATION = 107;
  ACT_ADD_EXPIRE_DURATION = 108;



type

  gs_handle_t = Pointer;

  TEntityHandle = gs_handle_t;
  TLicenseHandle = gs_handle_t;
  TVarHandle    = gs_handle_t;
  TMonitorHandle = gs_handle_t;
  TActionHandle = gs_handle_t;
  TRequestHandle = gs_handle_t;
  TEventHandle = gs_handle_t;
  TEventSourceHandle = gs_handle_t;
  TMPHandle = gs_handle_t;


  entity_id_t = PAnsiChar;
  license_id_t = PAnsiChar;
  action_id_t = Byte;

  var_type_t = Integer;
  vm_mask_t = DWORD;

  TLicensePolicy = (
    POLICY_INVALID,
    POLICY_ANY,  //Entity can be accessed if *any* of the associated licenses is valid (Default)
    POLICY_ALL 	 //Entity can be accessed only when *All* associated licenses are valid
    );

  TLicenseStatus = (
    STATUS_INVALID = -1, //The current status value is invalid
    STATUS_LOCKED = 0, ///isValid() always return false  the license is disabled permanently.
    STATUS_UNLOCKED = 1,///isValid() always return true, it happens when fully purchased.
    STATUS_ACTIVE = 2 ///isValid() works by its own logic.
  );

  TEventType = (
    EVENT_TYPE_APP = 0,
    EVENT_TYPE_LICENSE = 100,
    EVENT_TYPE_ENTITY = 200
  );

  //Event callback (aka. gs5_monitor_ex in SDK 5.0.10)
  gs5_monitor_callback = procedure(evtId: Integer; hEvent: TEventHandle; usrData: Pointer); stdcall;

  //Custom License Model Callback
  lm_isValid_callback = function (usrData: Pointer): Boolean; stdcall;
  lm_startAccess_callback = procedure (usrData: Pointer); stdcall;
  lm_finishAccess_callback = procedure (usrData: Pointer); stdcall;
  lm_onAction_callback = procedure (hAction: TActionHandle; usrData: Pointer); stdcall;

  lm_destroy_callback = procedure (usrData: Pointer); stdcall;
  lm_create_callback = function(usrData: Pointer): gs_handle_t; stdcall;


function gsInit(const productId, origLic, password: PAnsiChar; reserved: Pointer): Integer; stdcall;
function gsInitEx(const productId: PAnsiChar; const pLicData: Pointer; licSize: Integer; const password: PAnsiChar; reserved: Pointer): Integer; stdcall;

function gsCleanUp: Integer; stdcall;

function gsGetVersion: PAnsiChar; stdcall;

procedure gsCloseHandle( handle : gs_handle_t); stdcall;

procedure gsFlush; stdcall;

function gsGetLastErrorMessage: PAnsiChar; stdcall;

function gsGetLastErrorCode: Integer; stdcall;

function gsGetBuildId: Integer; stdcall;
function gsGetProductName: PAnsiChar; stdcall;
function gsGetProductId: PAnsiChar; stdcall;

function gsRunInWrappedMode: Boolean; stdcall;

function gsRunInsideVM( vmask: vm_mask_t ): Boolean; stdcall;

//Entity
function gsGetEntityCount: Integer; stdcall;


function gsOpenEntityByIndex(index: Integer): TEntityHandle; stdcall;

function gsOpenEntityById(entityId: entity_id_t): TEntityHandle; stdcall;

function gsGetEntityAttributes(hEntity: TEntityHandle): DWORD; stdcall;

function gsGetEntityId(hEntity: TEntityHandle): entity_id_t; stdcall;

function gsGetEntityName( hEntity: TEntityHandle): PAnsiChar; stdcall;

function gsGetEntityDescription( hEntity: TEntityHandle): PAnsiChar; stdcall;

//function gsGetEntityLicensePolicy( hEntity: TEntityHandle): TLicensePolicy; stdcall;

function gsBeginAccessEntity(hEntity: TEntityHandle): Boolean; stdcall;

function gsEndAccessEntity(hEntity: TEntityHandle): Boolean; stdcall;

//------- License --------
//SDK 5.3
function gsHasLicense(hEntity: TEntityHandle): Boolean; stdcall;
function gsOpenLicense(hEntity: TEntityHandle): TLicenseHandle; stdcall;
procedure gsLockLicense(hLicense: TLicenseHandle); stdcall;
//function gsGetLicenseCount( hEntity: TEntityHandle): Integer; stdcall;

//function gsOpenLicenseByIndex(hEntity: TEntityHandle; index: Integer): TLicenseHandle; stdcall;

//function gsOpenLicenseById(hEntity: TEntityHandle; licenseId: license_id_t): TLicenseHandle; stdcall;
(*
 * Inspect the license model's status
 *)
function gsGetLicenseId( hLicense: TLicenseHandle) :license_id_t; stdcall;

function gsGetLicenseName( hLicense: TLicenseHandle): PAnsiChar; stdcall;

function gsGetLicenseDescription( hLicense: TLicenseHandle): PAnsiChar; stdcall;

function gsGetLicenseStatus( hLicense: TLicenseHandle): TLicenseStatus; stdcall;

function gsIsLicenseValid(hLicense: TLicenseHandle): Boolean; stdcall;

function gsGetLicensedEntity(hLicense: TLicenseHandle): TEntityHandle; stdcall;

(*
 * Inspect the license model's parameters
 *)
/// Get total number of parameters in a license.
function gsGetLicenseParamCount( hLicense: TLicenseHandle) : Integer; stdcall;
/// Get the index'th parameter info handle
function gsGetLicenseParamByIndex( hLicense: TLicenseHandle; index: Integer): TVarHandle; stdcall;

function gsGetLicenseParamByName( hLicense: TLicenseHandle; const name: PAnsiChar ):TVarHandle; stdcall;

 (**
 * Inspect license model's actions
 *)
function gsGetActionInfoCount( hLicense: TLicenseHandle): Integer; stdcall;

function gsGetActionInfoByIndex( hLicense: TLicenseHandle; index: Integer;
      out actionId: action_id_t): PAnsiChar; stdcall;

(**
 *	Inspect an action
 *)
function gsGetActionName( hAct: TActionHandle): PAnsiChar; stdcall;

function gsGetActionId( hAct: TActionHandle):action_id_t; stdcall;

function gsGetActionString(hAct: TActionHandle): PAnsiChar; stdcall;

function gsGetActionDescription(hAct: TActionHandle): PAnsiChar; stdcall;
(**
 * Inspect action's parameters
 *)
function gsGetActionParamCount( hAct: TActionHandle): Integer; stdcall;

function gsGetActionParamByIndex( hAct: TActionHandle; index: Integer): TVarHandle; stdcall;

function gsGetActionParamByName( hAct: TActionHandle; const paramName: PAnsiChar): TVarHandle; stdcall;
(**
* parameter / Variable
*
*	Open an existent variable by its name
*
*	The variable can be from user-defined variables and system built-in ones.
*
*)
function gsGetVariable(const varName: PAnsiChar): TVarHandle; stdcall;

function gsAddVariable(const varName: PAnsiChar; varType: var_type_t;
      permission: DWORD; const initValStr: PAnsiChar): TVarHandle; stdcall;

function gsRemoveVariable(varName: PAnsiChar): Boolean; stdcall;
//Attr
function gsGetVariableName( hVar: TVarHandle ): PAnsiChar; stdcall;

function gsGetVariableType( hVar: TVarHandle): var_type_t; stdcall;

function gsIsVariableValid( hVar: TVarHandle): Boolean; stdcall;


function gsVariableTypeToString( paramType: var_type_t): PAnsiChar; stdcall;

function gsGetVariablePermission( hVar: TVarHandle): Integer; stdcall;

function gsVariablePermissionToString( permit: Integer; buf: PAnsiChar; bufSize: Integer): PAnsiChar; stdcall;

function gsVariablePermissionFromString( const permitStr: PAnsiChar): Integer; stdcall;
//Value Get/Set
function gsGetVariableValueAsString( hVar: TVarHandle): PAnsiChar; stdcall;
function gsSetVariableValueFromString( hVar: TVarHandle; const valstr: PAnsiChar): Boolean; stdcall;

function gsGetVariableValueAsInt( hVar: TVarHandle; out val: Integer): Boolean; stdcall;
function gsSetVariableValueFromInt( hVar: TVarHandle; val: Integer): Boolean; stdcall;

function gsGetVariableValueAsInt64( hVar: TVarHandle; out val: Int64): Boolean; stdcall;
function gsSetVariableValueFromInt64( hVar: TVarHandle; val: Int64): Boolean; stdcall;

function gsGetVariableValueAsFloat( hVar: TVarHandle; out val: Single): Boolean; stdcall;
function gsSetVariableValueFromFloat( hVar: TVarHandle; val: Single): Boolean; stdcall;

function gsGetVariableValueAsDouble( hVar: TVarHandle; out val: Double): Boolean; stdcall;
function gsSetVariableValueFromDouble( hVar: TVarHandle; val: Double): Boolean; stdcall;

function gsGetVariableValueAsTime( hVar: TVarHandle; out val: Int64): Boolean; stdcall;
function gsSetVariableValueFromTime( hVar: TVarHandle; val: Int64): Boolean; stdcall;

 //Request
function gsCreateRequest: TRequestHandle; stdcall;

function gsAddRequestAction( hReq: TRequestHandle; actId: action_id_t; hLic: TLicenseHandle): TActionHandle; stdcall;

function gsAddRequestActionEx( hReq: TRequestHandle; actId: action_id_t; const entityId, licenseId: PAnsiChar): TActionHandle; stdcall;

function gsGetRequestCode( hReq: TRequestHandle): PAnsiChar; stdcall;

function gsApplyLicenseCode(const licenseCode: PAnsiChar): Boolean; stdcall;
function gsApplyLicenseCodeEx(const licenseCode, sn, snRef: PAnsiChar): Boolean; stdcall;

 //---------- Time Engine Service ------------
procedure gsTurnOnInternalTimer; stdcall;

procedure gsTurnOffInternalTimer; stdcall;

function gsIsInternalTimerActive: Boolean; stdcall;

(**
*	External Timer
*
*	The external timer should call this api once per second otherwise the internal timing is not precise.
*)
procedure gsTickFromExternalTimer; stdcall;

(**
*  Time Engine controlling
*
*  Time engine can be paused or resumed on demand, when paused, the internal event system is frozen. 
*
*)
procedure gsPauseTimeEngine; stdcall;

procedure gsResumeTimeEngine; stdcall;

function gsIsTimeEngineActive: Boolean; stdcall;

//Event handling
function gsCreateMonitorEx(cbMonitor: gs5_monitor_callback; usrData: Pointer; const monitorName: PAnsiChar): TMonitorHandle; stdcall;

function gsGetEventId(hEvent: TEventHandle): Integer; stdcall;
function gsGetEventType(hEvent: TEventHandle): TEventType; stdcall;
function gsGetEventSource(hEvent: TEventHandle): TEventSourceHandle; stdcall;

(**
	Rendering HTML in process.

	It can be called before gsInit() to render generic HTML pages.
	gsInit() must be called before to render LMApp HTML pages.

	The default behavior is:
		Windows Resizable = True;
		ExitAppAfterUI = False;
		CleanUpAfterRender = False;

*)
function gsRenderHTML(const url, title: PAnsiChar; width, height: Integer): Boolean; stdcall;

(**
	Rendering HTML with more control	 (Since SDK 5.0.7)

	@resizable: The HTML windows is resizable.
	@exitAppWhenUIClosed: Terminate current process when the HTML main windows is manually closed (clicking [x] button on right title for Windows).
		if false, the UI is just closed.
	@cleanUpAfterRendering: Clean up all of the internal rendering facilities before this API returns.
		If you cleanup rendering, then the possible conflicts with game are minimized, however, next time the render engine has to be re-created again.
		   WARNING: If set to true, the Qt rendering engine might CRASH for the second time api calling due to Qt internal issue!!!
		   So the best practice is that: Only set cleanUpAfterRendering to true if it is the last time rendering.

		If you do not cleanup rendering, the render engine stays active in memory and is quick for next rendering.
		However, since the Qt/Win stuffs still alive, it might conflict with game in unexpected way.(Mac: The top main menu bar, about, etc.)

*)
function gsRenderHTMLEx(const url, title: PAnsiChar; width, height: Integer;
    resizable, exitAppWhenUIClosed, cleanUpAfterRendering: Boolean): Boolean; stdcall;


function gsIsDebugVersion: Boolean; stdcall;
procedure gsTrace( const msg: PAnsiChar); stdcall;


//Application Control
procedure gsExitApp(rc: Integer); stdcall;
procedure gsTerminateApp(rc: Integer); stdcall;
procedure gsPlayApp; stdcall;
procedure gsRestartApp; stdcall;
function gsIsRestartedApp: Boolean; stdcall;
procedure gsPauseApp; stdcall;
procedure gsResumeAndExitApp; stdcall;
function gsIsAppFirstLaunched: Boolean; stdcall;

function gsGetAppRootPath: PAnsiChar; stdcall;
function gsGetAppCommandLine: PAnsiChar; stdcall;
function gsGetAppMainExe: PAnsiChar; stdcall;
//Session Variables
procedure gsSetAppVar(const name, val: PAnsiChar); stdcall;
function gsGetAppVar(const name: PAnsiChar): PAnsiChar; stdcall;

//Custom LM
function gsCreateCustomLicense(const licId, licName, description: PAnsiChar; usrData: Pointer;
	cbIsValid: lm_isValid_callback; cbStartAccess: lm_startAccess_callback;
  cbFinishAccess: lm_finishAccess_callback; cbOnAction: lm_onAction_callback; cbDestroy: lm_destroy_callback): TLicenseHandle; stdcall;

function gsBindLicense(hEntity: TEntityHandle; hLic: TLicenseHandle): Boolean; stdcall;

function gsCreateLicense(const licId: PAnsiChar): TLicenseHandle; stdcall;

procedure gsRegisterCustomLicense(const licId: PAnsiChar; createLM: lm_create_callback; usrData: Pointer); stdcall;

procedure gsAddLicenseParamStr(hLic: TLicenseHandle; const paramName: PAnsiChar; const initValue: PAnsiChar; permission: integer); stdcall;
procedure gsAddLicenseParamInt(hLic: TLicenseHandle; const paramName: PAnsiChar; initValue: Integer; permission: integer); stdcall;
procedure gsAddLicenseParamInt64(hLic: TLicenseHandle; const paramName: PAnsiChar; initValue: Int64; permission: integer); stdcall;
procedure gsAddLicenseParamBool(hLic: TLicenseHandle; const paramName: PAnsiChar; initValue: Boolean; permission: integer); stdcall;
procedure gsAddLicenseParamFloat(hLic: TLicenseHandle; const paramName: PAnsiChar; initValue: Single; permission: integer); stdcall;
procedure gsAddLicenseParamDouble(hLic: TLicenseHandle; const paramName: PAnsiChar; initValue: Double; permission: integer); stdcall;
procedure gsAddLicenseParamTime(hLic: TLicenseHandle; const paramName: PAnsiChar; initValue: Int64; permission: integer); stdcall;

//Execution Context
function gsIsFirstPass: Boolean; stdcall;
function gsIsGamePass: Boolean; stdcall;
function gsIsLastPass: Boolean; stdcall;
function gsIsFirstGameExe: Boolean; stdcall;
function gsIsLastGameExe: Boolean; stdcall;
function gsIsMainThread: Boolean; stdcall;

//User Event
procedure gsPostUserEvent(evtId: Cardinal; bSync: Boolean; usrData: Pointer; usrDataSize: Cardinal); stdcall;
function gsGetUserEventData(hEvent: TEventHandle;  out usrDataSize: Cardinal): Pointer; stdcall;

//User Defined Variable Enumeration
function gsGetTotalVariables: Integer; stdcall;
function gsGetVariableByIndex(idx: Integer): TVarHandle; stdcall;

//Online Activation (SDK 5.3)
function gsIsServerAlive(timeout: Integer): Boolean; stdcall;
function gsApplySN(const sn: PAnsiChar;  pRetCode: PInteger; out pSNRef: PAnsiChar; timeout: Integer): Boolean; stdcall;
function gsIsSNValid(const sn: PAnsiChar; timeout: Integer): Boolean; stdcall;

function gsRevokeApp(timeout: Integer; const sn: PAnsiChar): Boolean; stdcall;
function gsRevokeSN(timeout: Integer; const sn: PAnsiChar): Boolean; stdcall;

//;;;;;;;;;;;;;;;; MOVE ;;;;;;;;;;;;;;;;
function gsMPCreate(reserved: Integer): TMPHandle; stdcall;
procedure gsMPAddEntity(hMP: TMPHandle; const entityId: PAnsiChar); stdcall;
function gsMPExport(hMP: TMPHandle): PAnsiChar; stdcall;
function gsMPUpload(hMP: TMPHandle; const sn: PAnsiChar; timeout: Integer): PAnsiChar; stdcall;
function gsMPIsTooBigToUpload(hMP: TMPHandle): Boolean; stdcall;

function gsMPOpen(const mpStr: PAnsiChar): TMPHandle; stdcall;

function gsMPCanPreliminarySNResolved(hMP: TMPHandle): Boolean; stdcall; //156
function gsMPImportOnline(hMP: TMPHandle; const sn: PAnsiChar; timeout: Integer): Boolean; stdcall;//141

function gsMPGetImportOfflineRequestCode(hMP: TMPHandle): PAnsiChar; stdcall; // 150
function gsMPImportOffline(hMP: TMPHandle; const licenseCode: PAnsiChar): Boolean; stdcall;
function gsMPUploadApp(const sn: PAnsiChar; timeout: Integer): PAnsiChar; stdcall;
function gsMPExportApp: PAnsiChar; stdcall;

function gsGetPreliminarySN: PAnsiChar; stdcall;

implementation

{$IFDEF DEBUG}
  uses unDebugHelper;
{$ENDIF}

function gsGetVersion; external 'gsCore.dll' index 2;
function gsInit; external 'gsCore.dll' index 3;
function gsInitEx; external 'gsCore.dll' index 103;
function gsCleanUp; external 'gsCore.dll' index 4;
procedure gsCloseHandle;external 'gsCore.dll' index 5;
procedure gsFlush; external 'gsCore.dll' index 6;
function gsGetLastErrorMessage; external 'gsCore.dll' index 7;
function gsGetLastErrorCode; external 'gsCore.dll' index 8;
function gsGetBuildId; external 'gsCore.dll' index 9;
function gsGetProductName; external 'gsCore.dll' index 84;
function gsGetProductId; external 'gsCore.dll' index 85;
//Entity
function gsGetEntityCount: Integer; external 'gsCore.dll' index 10;
function gsOpenEntityByIndex; external 'gsCore.dll' index 11;
function gsOpenEntityById; external 'gsCore.dll' index 12;

function gsGetEntityAttributes; external 'gsCore.dll' index 13;
function gsGetEntityId; external 'gsCore.dll' index 14;
function gsGetEntityName; external 'gsCore.dll' index 15;
function gsGetEntityDescription; external 'gsCore.dll' index 16;

function gsBeginAccessEntity; external 'gsCore.dll' index 20;
function gsEndAccessEntity; external 'gsCore.dll' index 21;

(*
 * Inspect the license model's status
 *)
 function gsGetLicenseId; external 'gsCore.dll' index 28;
 function gsGetLicenseName; external 'gsCore.dll' index 22;
 function gsGetLicenseDescription; external 'gsCore.dll' index 23;
 function gsGetLicenseStatus; external 'gsCore.dll' index 24;
 function gsIsLicenseValid; external 'gsCore.dll' index 34;
 function gsGetLicensedEntity; external 'gsCore.dll' index 48;
(*
 * Inspect the license model's parameters
 *)
/// Get total number of parameters in a license.
 function gsGetLicenseParamCount; external 'gsCore.dll' index 29;
/// Get the index'th parameter info handle
 function gsGetLicenseParamByIndex; external 'gsCore.dll' index 30;
 function gsGetLicenseParamByName; external 'gsCore.dll' index 31;

 (**
 * Inspect license model's actions
 *)
 function gsGetActionInfoCount; external 'gsCore.dll' index 32;
 function gsGetActionInfoByIndex; external 'gsCore.dll' index 33;

(**
 *	Inspect an action
 *)
 function gsGetActionName; external 'gsCore.dll' index 38;
 function gsGetActionId; external 'gsCore.dll' index 39;
 function gsGetActionDescription; external 'gsCore.dll' index 40;
 function gsGetActionString; external 'gsCore.dll' index 41;
(**
 * Inspect action's parameters
 *)
 function gsGetActionParamCount; external 'gsCore.dll' index 42;
 function gsGetActionParamByName; external 'gsCore.dll' index 43;
 function gsGetActionParamByIndex; external 'gsCore.dll' index 44;

 function gsRevokeApp; external 'gsCore.dll' index 135;
 function gsRevokeSN; external 'gsCore.dll' index 144;

//Variables
function gsAddVariable; external 'gsCore.dll' index 50;
function gsRemoveVariable; external 'gsCore.dll' index 51;
function gsGetVariable; external 'gsCore.dll' index 52;

function gsGetVariableName; external 'gsCore.dll' index 53;
function gsGetVariableType; external 'gsCore.dll' index 54;
function gsVariableTypeToString; external 'gsCore.dll' index 55;
function gsGetVariablePermission; external 'gsCore.dll' index 56;
function gsVariablePermissionToString; external 'gsCore.dll' index 65;
function gsVariablePermissionFromString; external 'gsCore.dll' index 66;
//Value Get/Set
 function gsGetVariableValueAsString; external 'gsCore.dll' index 57;
 function gsSetVariableValueFromString; external 'gsCore.dll' index 58;

 function gsGetVariableValueAsInt; external 'gsCore.dll' index 59;
 function gsSetVariableValueFromInt; external 'gsCore.dll' index 60;

 function gsGetVariableValueAsInt64; external 'gsCore.dll' index 61;
 function gsSetVariableValueFromInt64; external 'gsCore.dll' index 62;

 function gsGetVariableValueAsFloat; external 'gsCore.dll' index 63;
 function gsSetVariableValueFromFloat; external 'gsCore.dll' index 64;

 function gsIsVariableValid; external 'gsCore.dll' index 67;

 function gsGetVariableValueAsTime; external 'gsCore.dll' index 68;
 function gsSetVariableValueFromTime; external 'gsCore.dll' index 69;

 function gsGetVariableValueAsDouble; external 'gsCore.dll' index 78;
 function gsSetVariableValueFromDouble; external 'gsCore.dll' index 79;

 //Request
 function gsCreateRequest; external 'gsCore.dll' index 36;
 function gsAddRequestAction; external 'gsCore.dll' index 37;
 function gsAddRequestActionEx; external 'gsCore.dll' index 47;
 function gsGetRequestCode; external 'gsCore.dll' index 45;
 function gsApplyLicenseCode; external 'gsCore.dll' index 46;
 function gsApplyLicenseCodeEx; external 'gsCore.dll' index 158;

 //---------- Time Engine Service ------------
 procedure gsTurnOnInternalTimer; external 'gsCore.dll' index 70;
 procedure gsTurnOffInternalTimer; external 'gsCore.dll' index 71;
 function gsIsInternalTimerActive; external 'gsCore.dll' index 72;
 procedure gsTickFromExternalTimer; external 'gsCore.dll' index 73;
 procedure gsPauseTimeEngine; external 'gsCore.dll' index 74;
 procedure gsResumeTimeEngine; external 'gsCore.dll' index 75;
 function gsIsTimeEngineActive; external 'gsCore.dll' index 76;
 //Monitor
function gsCreateMonitorEx ; external 'gsCore.dll' index 90;

//HTML
function gsRenderHTML; external 'gsCore.dll' index 80;
function gsRenderHTMLEx; external 'gsCore.dll' index 83;

function gsRunInWrappedMode; external 'gsCore.dll' index 81;
function gsRunInsideVM; external 'gsCore.dll' index 82;

function gsGetEventId; external 'gsCore.dll' index 86;
function gsGetEventType; external 'gsCore.dll' index 87;
function gsGetEventSource; external 'gsCore.dll' index 88;

//Debug Helper
function gsIsDebugVersion; external 'gsCore.dll' index 91;
procedure gsTrace; external 'gsCore.dll' index 92;

//Application Helper
procedure gsExitApp; external 'gsCore.dll' index 93
procedure gsTerminateApp; external 'gsCore.dll' index 94
procedure gsPlayApp; external 'gsCore.dll' index 95
procedure gsRestartApp; external 'gsCore.dll' index 96

function gsGetAppRootPath; external 'gsCore.dll' index 97
function gsGetAppCommandLine; external 'gsCore.dll' index 98

procedure gsSetAppVar; external 'gsCore.dll' index 99
function gsGetAppVar; external 'gsCore.dll' index 100

function gsGetAppMainExe; external 'gsCore.dll' index 101
function gsIsRestartedApp; external 'gsCore.dll' index 102

function gsCreateCustomLicense; external 'gsCore.dll' index 105
function gsBindLicense; external 'gsCore.dll' index 106
function gsCreateLicense; external 'gsCore.dll' index 107
procedure gsRegisterCustomLicense; external 'gsCore.dll' index 108

procedure gsAddLicenseParamStr; external 'gsCore.dll' index 109
procedure gsAddLicenseParamInt; external 'gsCore.dll' index 110
procedure gsAddLicenseParamInt64; external 'gsCore.dll' index 111
procedure gsAddLicenseParamBool; external 'gsCore.dll' index 112
procedure gsAddLicenseParamFloat; external 'gsCore.dll' index 113
procedure gsAddLicenseParamTime; external 'gsCore.dll' index 114
procedure gsAddLicenseParamDouble; external 'gsCore.dll' index 115

//Execution Context
function gsIsFirstPass; external 'gsCore.dll' index 116
function gsIsGamePass; external 'gsCore.dll' index 117
function gsIsLastPass; external 'gsCore.dll' index 118
function gsIsFirstGameExe; external 'gsCore.dll' index 119
function gsIsLastGameExe; external 'gsCore.dll' index 120
function gsIsMainThread; external 'gsCore.dll' index 121
function gsIsAppFirstLaunched; external 'gsCore.dll' index 130

//User Event
procedure gsPostUserEvent; external 'gsCore.dll' index 89
function gsGetUserEventData; external 'gsCore.dll' index 124

//User Defined Variable Enumeration
function gsGetTotalVariables; external 'gsCore.dll' index 122
function gsGetVariableByIndex; external 'gsCore.dll' index 123

procedure gsPauseApp; external 'gsCore.dll' index 125
procedure gsResumeAndExitApp; external 'gsCore.dll' index 126

//Online Activation (SDK 5.3)
function gsIsServerAlive; external 'gsCore.dll' index 131
function gsApplySN; external 'gsCore.dll' index 133
function gsIsSNValid; external 'gsCore.dll' index 139

function gsHasLicense;  external 'gsCore.dll' index 136
function gsOpenLicense;  external 'gsCore.dll' index 137
procedure gsLockLicense; external 'gsCore.dll' index 138

//;;;;;;;;;;;;;;;; MOVE ;;;;;;;;;;;;;;;;
function gsMPCreate;  external 'gsCore.dll' index 145
procedure gsMPAddEntity;  external 'gsCore.dll' index 146
function gsMPExport;  external 'gsCore.dll' index 147
function gsMPUpload;  external 'gsCore.dll' index 148
function gsMPIsTooBigToUpload;  external 'gsCore.dll' index 157

function gsMPOpen;  external 'gsCore.dll' index 149
function gsMPCanPreliminarySNResolved;  external 'gsCore.dll' index 156
function gsMPImportOnline;  external 'gsCore.dll' index 141

function gsMPGetImportOfflineRequestCode;  external 'gsCore.dll' index 150
function gsMPImportOffline;  external 'gsCore.dll' index 151
function gsMPUploadApp;  external 'gsCore.dll' index 152
function gsMPExportApp;  external 'gsCore.dll' index 153

function gsGetPreliminarySN;  external 'gsCore.dll' index 155

end.
