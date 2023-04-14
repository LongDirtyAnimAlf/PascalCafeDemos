program Display;
{
  This example uses dynamic Initialization of FreeRTOS, this means you need to include
  freetos.heap_4 heapmanager that will do memory alllocation for FreeRTOS Objects
}

{$INCLUDE MBF.Config.inc}


{$define WATER2}

uses
  //heapmgr,
  SysUtils,
  MBF.__CONTROLLERTYPE__.SystemCore,
  MBF.__CONTROLLERTYPE__.GPIO,
  MBF.__CONTROLLERTYPE__.LCD,
  FreeRTOS,
  FreeRTOS.Heap_4;

const
  BLINKY_PRIORITY       = (tskIDLE_PRIORITY+1);

var
  BlinkyTaskHandle           : TTaskHandle;

procedure BlinkyTask({%H-}pvParameters:pointer);
begin
  while true do
  begin
    SystemCore.Delay(500);
    GPIO.PinValue[PIN_LED] := 0;
    SystemCore.Delay(500);
    GPIO.PinValue[PIN_LED] := 1;
  end;
  //In case we ever break out the while loop the task must end itself
  vTaskDelete(nil);
end;

begin
  BasicSystemInit;
  SystemCoreClock:=SystemCore.GetMaxCPUFrequency;
  SystemCore.Initialize;

  BlinkyTaskHandle    := nil;

  GPIO.PinMode[PIN_LED] := TPinMode.Output;
  GPIO.PinValue[PIN_LED] := 0;

  if xTaskCreate(@BlinkyTask,
                 'BlinkyTask',
                 configMINIMAL_STACK_SIZE,
                 nil,
                 BLINKY_PRIORITY,
                 BlinkyTaskHandle) = pdPass then
  begin
  end;

  TFTCreate;
  initTFT;

  setRotation(3);
  fillScreen(TFT_RED);

  drawCircle(100,100,50,TFT_PINK);

  setTextColor(TFT_GREEN,TFT_BLUE);
  drawString('Hallo allemaal',25,25,TTEXTFONT.FONT2);

  setTextSize(5);
  drawString('Yolo',25,150,TTEXTFONT.FONT2);

  fillRoundRect(200, 20, 60 , 60 , 10, TFT_YELLOW);

  vTaskStartScheduler;

  repeat
  until 1=0;
end.

