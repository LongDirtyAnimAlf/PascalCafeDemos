program SensorTask;
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
  //heapmgr,
  sysutils,
  MBF.__CONTROLLERTYPE__.SystemCore,
  MBF.__CONTROLLERTYPE__.GPIO,
  MBF.__CONTROLLERTYPE__.LCD,
  FreeRTOS,
  FreeRTOS.Heap_4;

procedure BlinkyTask({%H-}pvParameters:pointer);
begin
  while true do
  begin
    GPIO.PinValue[PIN_LED] := 1;
    SystemCore.Delay(500);
    GPIO.PinValue[PIN_LED] := 0;
    SystemCore.Delay(500);
  end;
  //In case we ever break out the while loop the task must end itself
  vTaskDelete(nil);
end;

type
  LisHandle = THandle;

var
  BlinkyTaskHandle  : TTaskHandle;
  SensorTaskHandle  : TTaskHandle;
  DisplayTaskHandle : TTaskHandle;
  DataQueueHandle   : TQueueHandle;
  Lis               : LisHandle;

function lis_init:LisHandle; cdecl; external name 'lis_init';
function getAccelerationX(Lis:LisHandle):double; cdecl; external name 'getAccelerationX';
function getAccelerationY(Lis:LisHandle):double; cdecl; external name 'getAccelerationY';
function getAccelerationZ(Lis:LisHandle):double; cdecl; external name 'getAccelerationZ';

procedure disp_sight;
begin
    drawCircle(159,119,90,TFT_WHITE);
    drawCircle(159,119,60,TFT_WHITE);
    drawCircle(159,119,30,TFT_WHITE);
    drawLine(159,29,159,209,TFT_WHITE);
    drawLine(69,119,249,119,TFT_WHITE);
    fillCircle(159,119,3,TFT_RED);

    fillRoundRect(56,215,206,20,10,TFT_DARKGREEN);
    fillRoundRect(295,16,20,206,10,TFT_DARKGREEN);
end;

var
  p_plot_x:integer = 159;
  p_plot_y:integer = 119;
  scale:integer = 1;
  p_scale:integer = 5;

procedure SensorTask({%H-}pvParameters:pointer);
var
  x_values, y_values, z_values: double;
begin
  Lis:=lis_init;

  while true do
  begin
    x_values := getAccelerationX(Lis);
    y_values := getAccelerationY(Lis);
    z_values := getAccelerationZ(Lis);
    xQueueSend( DataQueueHandle, @x_values, portMAX_DELAY  );
    xQueueSend( DataQueueHandle, @y_values, portMAX_DELAY  );
    xQueueSend( DataQueueHandle, @z_values, portMAX_DELAY  );
    SystemCore.Delay(10);
  end;
  //In case we ever break out the while loop the task must end itself
  vTaskDelete(nil);
end;

procedure DisplayTask({%H-}pvParameters:pointer);
var
  x_values, y_values, z_values: double;
  x_values_sum, y_values_sum, z_values_sum: double;
  counter:integer;
  plot_x, plot_y: integer;
  dataok:boolean;
begin
  setRotation(3);

  setTextColor(TFT_YELLOW);
  setTextSize(1);
  fillScreen(TFT_BLACK);
  disp_sight;
  drawString('Angle', 5, 20, TTEXTFONT.FONT2);
  drawString('X: ', 10, 40, TTEXTFONT.FONT2);
  drawString('Y: ', 10, 60, TTEXTFONT.FONT2);
  drawString('Accel.', 5, 120, TTEXTFONT.FONT2);
  drawString('X: ', 10, 140, TTEXTFONT.FONT2);
  drawString('Y: ', 10, 160, TTEXTFONT.FONT2);
  drawString('Z: ', 10, 180, TTEXTFONT.FONT2);
  drawString('Scale', 238, 20, TTEXTFONT.FONT2);

  while true do
  begin

    counter:=0;
    x_values_sum:=0;
    y_values_sum:=0;
    z_values_sum:=0;

    repeat
      dataok:=(xQueueReceive(DataQueueHandle, @x_values, portMAX_DELAY)=pdPass);
      if dataok then
        x_values_sum:=x_values_sum+x_values;

      if dataok then
        dataok:=(xQueueReceive(DataQueueHandle, @y_values, portMAX_DELAY)=pdPass);
      if dataok then
        y_values_sum:=y_values_sum+y_values;

      if dataok then
        dataok:=(xQueueReceive(DataQueueHandle, @z_values, portMAX_DELAY)=pdPass);
      if dataok then
        z_values_sum:=z_values_sum+z_values;

      if dataok then
        Inc(Counter);
    until ((NOT dataok) OR (Counter>=20));

    if (Counter>0) then
    begin
      x_values:=(x_values_sum / counter);
      y_values:=(y_values_sum / counter);
      z_values:=(z_values_sum / counter);

      fillRect(50,40,72,35,TFT_BLACK);
      fillRect(50,140,72,55,TFT_BLACK);

      drawString(PChar(FloattoStrF(180.0/3.1415*asin(x_values),ffFixed,3,1)), 50, 40, TTEXTFONT.FONT2);
      drawString(PChar(FloattoStrF(180.0/3.1415*asin(y_values),ffFixed,3,1)), 50, 60, TTEXTFONT.FONT2);
      drawString(PChar(FloattoStrF(x_values,ffFixed,6,3)), 50, 140, TTEXTFONT.FONT2);
      drawString(PChar(FloattoStrF(y_values,ffFixed,6,3)), 50, 160, TTEXTFONT.FONT2);
      drawString(PChar(FloattoStrF(z_values,ffFixed,6,3)), 50, 180, TTEXTFONT.FONT2);

      if (scale <> p_scale) then
      begin
        fillRect(260,41,25,20,TFT_BLACK);
        drawString(PChar(InttoStr(scale)), 260, 41, TTEXTFONT.FONT2);
      end;

      fillCircle(p_plot_x,p_plot_y,10,TFT_BLACK);
      fillRect(p_plot_x+3,215,6,20,TFT_DARKGREEN);
      fillRect(295,p_plot_y-3,20,6,TFT_DARKGREEN);
      disp_sight;
      plot_x := 159 + round(scale*(90.0/3.1415 * 2 * asin(y_values)));
      if (plot_x > 249) then plot_x := 249;
      if (plot_x < 69) then plot_x := 69;
      plot_y := 119 - round(scale*(90.0/3.1415 * 2 * asin(x_values)));
      if (plot_y > 209) then plot_y := 209;
      if (plot_y < 29) then plot_y := 29;
      fillCircle(plot_x,plot_y,10,TFT_YELLOW);
      fillRect(plot_x-3,215,6,20,TFT_WHITE);
      drawLine(plot_x,215,plot_x,235,TFT_BLACK);
      fillRect(295,plot_y-3,20,6,TFT_WHITE);
      drawLine(295,plot_y,315,plot_y,TFT_BLACK);

      p_plot_x := plot_x;
      p_plot_y := plot_y;
    end;

    //SystemCore.Delay(200);
  end;
  //In case we ever break out the while loop the task must end itself
  vTaskDelete(nil);
end;


begin
  BasicSystemInit;

  SystemCoreClock:=SystemCore.GetMaxCPUFrequency;
  SystemCore.Initialize;

  GPIO.PinMode[PIN_LED] := TPinMode.Output;

  TFTCreate;
  initTFT;

  DataQueueHandle := xQueueCreate( 20*3, sizeof( double ) );

  BlinkyTaskHandle := nil;
  if xTaskCreate(@BlinkyTask,
                 'BlinkyTask',
                 configMINIMAL_STACK_SIZE,
                 nil,
                 tskIDLE_PRIORITY,
                 BlinkyTaskHandle) = pdPass then
  begin
  end;

  SensorTaskHandle := nil;
  if xTaskCreate(@SensorTask,
                 'SensorTask',
                 configMINIMAL_STACK_SIZE*4,
                 nil,
                 tskIDLE_PRIORITY+1,
                 SensorTaskHandle) = pdPass then
  begin
  end;

  DisplayTaskHandle := nil;
  if xTaskCreate(@DisplayTask,
                 'DisplayTask',
                 configMINIMAL_STACK_SIZE*6,
                 nil,
                 tskIDLE_PRIORITY+2,
                 DisplayTaskHandle) = pdPass then
  begin
  end;

  vTaskStartScheduler;

  repeat
  until 1=0;

  TFTFree;
end.

