unit rundatastatemachine;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  rundatadom;

type
  TTransitionAction = procedure(const Sender:TObject; const Mode: TBatteryMode; const Trigger: TStageMode) of object;

  TBatteryModeTransition = record
    FromStates : TBatteryModes;
    Triggers   : TStageModes;
    ToState    : TBatteryMode;
    Action     : TTransitionAction;
    Error      : TTransitionAction;
  end;

  TBatteryModeStateMachine = class
  private
    fRunData:TRunData;
    fTransitions: array of TBatteryModeTransition;
  public
    constructor Create;
    procedure AddTransition(Transition: TBatteryModeTransition);
    procedure FireTriggerLess(T: TStageMode);
    procedure FireTrigger(T: TStageMode);
    procedure SetRunData(aRunData:TRunData);
    function GetCurrentState: TBatteryMode;
  end;

  TMyStateMachine = class
  private
    fAction: TTransitionAction;
    fError: TTransitionAction;
    StateMachine: TBatteryModeStateMachine;
    function GetState: TBatteryMode;
    procedure OnTrigger(const Sender:TObject; const Mode: TBatteryMode; const Trigger: TStageMode);
    procedure OnError(const Sender:TObject; const Mode: TBatteryMode; const Trigger: TStageMode);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetRunData(aRunData:TRunData);

    {$ifndef COINCELL}
    procedure StartCharging(aMode:TChargeMode);
    {$endif}
    procedure StartDischarging(aMode:TDischargeMode);
    procedure SetIdle;
    procedure SetReady;
    procedure SetPause;
    procedure SetError;

    property State:TBatteryMode read GetState;
    property Action: TTransitionAction read fAction write fAction;
    property Error: TTransitionAction read fError write fError;
  end;

implementation

constructor TBatteryModeStateMachine.Create;
begin
  fRunData:=nil;
  SetLength(fTransitions, 0);
end;

procedure TBatteryModeStateMachine.AddTransition(Transition: TBatteryModeTransition);
begin
  SetLength(fTransitions, Length(fTransitions) + 1);
  fTransitions[High(fTransitions)] := Transition;
end;

procedure TBatteryModeStateMachine.FireTriggerLess(T: TStageMode);
var
  i: Integer;
  Transition: TBatteryModeTransition;
  Success:boolean;
  OldMode:TBatteryMode;
begin
  if Assigned(fRunData) then
  begin
    Success:=false;
    for i := 0 to High(fTransitions) do
    begin
      Transition := fTransitions[i];
      if (NOT (Transition.Triggers=[])) then continue;
      if (fRunData.BatteryMode in Transition.FromStates) then
      begin
        OldMode:=fRunData.BatteryMode;
        fRunData.BatteryMode := Transition.ToState;
        if Assigned(Transition.Action) then Transition.Action(fRunData,OldMode,T);
        Success:=true;
        break;
      end;
    end;
    if NOT Success then
    begin
      if Assigned(Transition.Error) then Transition.Error(fRunData,fRunData.BatteryMode,T);
    end;
  end;
end;

procedure TBatteryModeStateMachine.FireTrigger(T: TStageMode);
var
  i: Integer;
  Transition: TBatteryModeTransition;
  Success:boolean;
  OldMode:TBatteryMode;
begin
  if Assigned(fRunData) then
  begin
    Success:=false;
    for i := 0 to High(fTransitions) do
    begin
      Transition := fTransitions[i];
      if (Transition.Triggers=[]) then continue;
      if (fRunData.BatteryMode in Transition.FromStates) then
      begin
        if (T in Transition.Triggers) then
        begin
          OldMode:=fRunData.BatteryMode;
          fRunData.BatteryMode := Transition.ToState;
          if Assigned(Transition.Action) then Transition.Action(fRunData,OldMode,T);
          Success:=true;
          break;
        end;
      end;
    end;
    if NOT Success then
    begin
      if Assigned(Transition.Error) then Transition.Error(fRunData,fRunData.BatteryMode,T);
    end;
  end;
end;

procedure TBatteryModeStateMachine.SetRunData(aRunData:TRunData);
begin
  Self.fRunData:=aRunData;
end;

function TBatteryModeStateMachine.GetCurrentState: TBatteryMode;
begin
  Result := fRunData.BatteryMode;
end;

constructor TMyStateMachine.Create;
var
  Transition: TBatteryModeTransition;
begin
  StateMachine := TBatteryModeStateMachine.Create;

  Transition.Action := @OnTrigger;
  Transition.Error  := @OnError;

  // Can we go to active discharging ?
  Transition.FromStates := [bmIdle];
  Transition.Triggers := [smResistor,smCurrent,smPower,smVoltage];
  Transition.ToState := bmActive;
  StateMachine.AddTransition(Transition);

  {$ifndef COINCELL}

  // Can we go to waiting ?
  Transition.FromStates := [bmIdle];
  Transition.Triggers := [smCharge,smPulse];
  Transition.ToState := bmWaiting;
  StateMachine.AddTransition(Transition);

  // Can we go to active ?
  Transition.FromStates := [bmIdle];
  Transition.Triggers := [smTopOff,smTrickle];
  Transition.ToState := bmActive;
  StateMachine.AddTransition(Transition);

  // Can we go to active charging ?
  Transition.FromStates := [bmWaiting];
  Transition.Triggers := [smCharge,smPulse,smTopOff,smTrickle];
  Transition.ToState := bmActive;
  StateMachine.AddTransition(Transition);

  {$endif}

  // Can we go to idle ?
  Transition.FromStates := [bmIdle,bmActive,bmWaiting,bmPause,bmOff];
  Transition.Triggers := [TStageMode.smZero];
  Transition.ToState := bmIdle;
  StateMachine.AddTransition(Transition);

  // Can we go to ready ?
  Transition.FromStates := [bmActive,bmPause,bmIdle];
  Transition.Triggers := [TStageMode.smDisabled];
  Transition.ToState := bmReady;
  StateMachine.AddTransition(Transition);

  // Can we go to error ?
  Transition.FromStates := [bmIdle,bmActive,bmPause,bmWaiting,bmOff,bmReady];
  Transition.Triggers := [TStageMode.smUnknown];
  Transition.ToState := bmError;
  StateMachine.AddTransition(Transition);

  // Can we go to pause ?
  // We have no special triggers to enter pause
  // So, use a triggerless manner.
  // Bit tricky.
  Transition.FromStates := [bmActive];
  Transition.Triggers := [];
  Transition.ToState := bmPause;
  StateMachine.AddTransition(Transition);
end;

destructor TMyStateMachine.Destroy;
begin
  StateMachine.Free;
  inherited;
end;

function TMyStateMachine.GetState: TBatteryMode;
begin
  result:=StateMachine.GetCurrentState;
end;

procedure TMyStateMachine.OnTrigger(const Sender:TObject; const Mode: TBatteryMode; const Trigger: TStageMode);
begin
  if Assigned(fAction) then fAction(Sender,Mode,Trigger);
end;

procedure TMyStateMachine.OnError(const Sender:TObject; const Mode: TBatteryMode; const Trigger: TStageMode);
begin
  if Assigned(fError) then fError(Sender,Mode,Trigger);
end;

procedure TMyStateMachine.SetRunData(aRunData:TRunData);
begin
  StateMachine.SetRunData(aRunData);
end;

{$ifndef COINCELL}
procedure TMyStateMachine.StartCharging(aMode:TChargeMode);
begin
  StateMachine.FireTrigger(aMode);
end;
{$endif}

procedure TMyStateMachine.StartDischarging(aMode:TDischargeMode);
begin
  StateMachine.FireTrigger(aMode);
end;

procedure TMyStateMachine.SetIdle;
begin
  StateMachine.FireTrigger(TStageMode.smZero);
end;

procedure TMyStateMachine.SetReady;
begin
  StateMachine.FireTrigger(TStageMode.smDisabled);
end;

procedure TMyStateMachine.SetPause;
begin
  // We have no trigger to go to pause, so use dedicated procedure
  StateMachine.FireTriggerLess(TStageMode.smZero);
end;

procedure TMyStateMachine.SetError;
begin
  StateMachine.FireTrigger(TStageMode.smUnknown);
end;

end.

