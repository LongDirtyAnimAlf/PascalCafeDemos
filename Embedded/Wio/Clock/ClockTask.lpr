program ClockTask;
{
  This file is part of Pascal Microcontroller Board Framework (MBF)
  Copyright (c) 2015 -  Michael Ring
  based on Pascal eXtended Library (PXL)
  Copyright (c) 2000 - 2015  Yuriy Kotsarenko

  This program is free software: you can redistribute it and/or modify it under the terms of the FPC modified GNU
  Library General Public License for more

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the FPC modified GNU Library General Public
  License for more details.
}

{
  This example uses dynamic Initialization of FreeRTOS, this means you need to include
  freetos.heap_4 heapmanager that will do memory alllocation for FreeRTOS Objects
}

{$INCLUDE MBF.Config.inc}

uses
  heapmgr,
  MBF.__CONTROLLERTYPE__.SystemCore,
  MBF.__CONTROLLERTYPE__.GPIO,
  MBF.__CONTROLLERTYPE__.LCD,
  FreeRTOS,
  FreeRTOS.Heap_4;

procedure BlinkyTask({%H-}pvParameters:pointer);
var
  LastWakeTime:TMilliseconds;
begin
  LastWakeTime := SystemCore.GetTickCount;
  while true do
  begin
    GPIO.PinValue[PIN_LED] := 1;
    //SystemCore.Delay(500);
    SystemCore.DelayUntil(LastWakeTime,500);
    GPIO.PinValue[PIN_LED] := 0;
    //SystemCore.Delay(500);
    SystemCore.DelayUntil(LastWakeTime,500);
  end;
  //In case we ever break out the while loop the task must end itself
  vTaskDelete(nil);
end;

procedure ClockTask({%H-}pvParameters:pointer);
var
  k:integer;
  hh,mm,ss:Cardinal;
  osx,osy,omx,omy,ohx,ohy:Cardinal;
  initial:boolean;
  mx,my:Double;
  hx,hy:Double;
  sdeg,mdeg,hdeg:Double;
  ssx,ssy:Double;
  LastWakeTime:TMilliseconds;
begin
  //setRotation(0);

  //fillScreen(TFT_NAVY);
  fillCircle(120, 120, 118, TFT_GREEN);
  fillCircle(120, 120, 110, TFT_BLACK);

  // Draw 12 lines
  k:=0;
  while (k<360) do
  begin
    sdeg:=(k-90) * 0.0174532925;
    mdeg := cos(sdeg);
    hdeg := sin(sdeg);
    osx := round(mdeg * 114) + 120;
    osy := round(hdeg * 114) + 120;
    omx := round(mdeg * 100) + 120;
    omy := round(hdeg * 100) + 120;
    drawLine(osx, osy, omx, omy, TFT_RED);
    Inc(k,30);
    SystemCore.Delay(50);
  end;

  // Draw 60 dots
  k:=0;
  while (k<360) do
  begin
    sdeg   := (k - 90) * 0.0174532925;
    mdeg  := cos(sdeg);
    hdeg  := sin(sdeg);
    osx  := round(mdeg * 102) + 120;
    osy := round(hdeg * 102) + 120;

    // Draw minute markers
    drawPixel(osx, osy, TFT_WHITE);

    // Draw main quadrant dots
    if ((k = 0) OR (k = 180)) then
        fillCircle(osx, osy, 2, TFT_WHITE);
    if ((k = 90) OR (k = 270)) then
        fillCircle(osx, osy, 2, TFT_WHITE);

    Inc(k,6);
    SystemCore.Delay(20);
  end;

  fillCircle(120, 121, 3, TFT_WHITE);

  setTextColor(TFT_WHITE, TFT_BLUE);
  //drawString('Time flies', 10, 260, TTEXTFONT.GFXFF);
  setGFXFont(TGFXFONT.FF17);
  drawString('Pascal Cafe IJsselstein', 20, 260, TTEXTFONT.GFXFF);
  drawString('By Blaise Pascal Magazine', 10, 290, TTEXTFONT.GFXFF);

  ss:=0;
  mm:=0;
  hh:=0;
  osx:=120;
  osy:=120;
  omx:=120;
  omy:=120;
  ohx:=120;
  ohy:=120;

  initial:=true;

  LastWakeTime := SystemCore.GetTickCount;

  while true do
  begin
    Inc(ss);
    if (ss = 60) then
    begin
      ss := 0;
      Inc(mm);
      if (mm > 59) then
      begin
        mm := 0;
        Inc(hh);
        if (hh > 23)  then hh := 0;
      end;
    end;

    // Pre-compute hand degrees, x & y coords for a fast screen update
    sdeg := ss * 6;                // 0-59 -> 0-354
    mdeg := mm * 6 + (sdeg * 0.01666667); // 0-59 -> 0-360 - includes seconds
    hdeg := hh * 30 + (mdeg * 0.0833333); // 0-11 -> 0-360 - includes minutes and seconds

    hx := cos((hdeg - 90.0) * 0.0174532925);
    hy := sin((hdeg - 90.0) * 0.0174532925);
    mx := cos((mdeg - 90.0) * 0.0174532925);
    my := sin((mdeg - 90.0) * 0.0174532925);
    ssx := cos((sdeg - 90.0) * 0.0174532925);
    ssy := sin((sdeg - 90.0) * 0.0174532925);

    if ((ss = 0) OR (initial)) then
    begin
      initial := false;
      // Erase hour and minute hand positions every minute
      drawLine(ohx, ohy, 120, 121, TFT_BLACK);
      ohx := round(hx * 62.0) + 121;
      ohy := round(hy * 62.0) + 121;
      drawLine(omx, omy, 120, 121, TFT_BLACK);
      omx := round(mx * 84.0) + 120;
      omy := round(my * 84.0) + 121;
    end;

    // Redraw new hand positions, hour and minute hands not erased here to avoid flicker
    drawLine(osx, osy, 120, 121, TFT_BLACK);
    osx := round(ssx * 90.0) + 121;
    osy := round(ssy * 90.0) + 121;
    drawLine(ohx, ohy, 120, 121, TFT_LIGHTYELLOW);
    drawLine(omx, omy, 120, 121, TFT_LIGHTYELLOW);
    drawLine(osx, osy, 120, 121, TFT_RED);

    fillCircle(120, 121, 3, TFT_RED);

    //SystemCore.Delay(1000);
    SystemCore.DelayUntil(LastWakeTime,1000);
  end;
  //In case we ever break out the while loop the task must end itself
  vTaskDelete(nil);
end;


var
  BlinkyTaskHandle : TTaskHandle;
  ClockTaskHandle : TTaskHandle;

begin
  BasicSystemInit;

  SystemCoreClock:=SystemCore.GetMaxCPUFrequency;
  SystemCore.Initialize;

  GPIO.PinMode[PIN_LED] := TPinMode.Output;

  BlinkyTaskHandle := nil;
  if xTaskCreate(@BlinkyTask,
                 'BlinkyTask',
                 configMINIMAL_STACK_SIZE,
                 nil,
                 tskIDLE_PRIORITY+0,
                 BlinkyTaskHandle)=pdPass then
  begin
  end;

  ClockTaskHandle := nil;
  if xTaskCreate(@ClockTask,
                 'ClockTask',
                 configMINIMAL_STACK_SIZE*4,
                 nil,
                 tskIDLE_PRIORITY+1,
                 ClockTaskHandle)= pdPass then
  begin
  end;

  TFTCreate;
  initTFT;

  setRotation(0);
  fillScreen(TFT_RED);

  vTaskStartScheduler;

  repeat
  until 1=0;

  TFTFree;
end.

