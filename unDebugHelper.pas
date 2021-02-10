unit unDebugHelper;

(*

  Debug Helper APIs

*)

interface

  //Debug Helpers
  procedure DebugMsg(const msg: string);overload;
  procedure DebugMsg(const fmt: string; const args: array of const); overload;

implementation

uses Windows, SysUtils, GS5;

procedure DebugMsg(const msg: string);overload;
begin
  OutputDebugString(PAnsiChar(msg));
  TGSCore.getInstance.trace(msg);
end;

procedure DebugMsg(const fmt: string; const args: array of const); overload;
begin
  OutputDebugString(PAnsiChar(Format(fmt, args)));
end;

end.
