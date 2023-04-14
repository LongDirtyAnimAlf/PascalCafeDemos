@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Upload binary for Wio
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set CROSS=C:\fpclazbydeluxe\newembedded\cross
set SDK=%CROSS%\bin\arm-freertos\arm-none-eabi\lib
set GCC=%CROSS%\bin\arm-freertos
set LIBDIR=%CROSS%\lib\arm-freertos\armv7em\eabihf
set BOARDDIR=.\..\..\Boards\WioTerminal
set ARDUINODIR=%BOARDDIR%\ArduinoCore

set BOSSAC=%GCC%\bossac\1.8.0-48-gb176eee\bossac.exe

echo
echo ---------------------------------------------------
echo Building and uploading firmware

@rem del .\bin\ClockTask.bin
@rem del .\bin\ClockTask.hex

@rem call %GCC%\bin\arm-none-eabi-objcopy -O binary .\bin\ClockTask.elf .\bin\ClockTask.bin
@rem call %GCC%\bin\arm-none-eabi-objcopy -O ihex -R .eeprom .\bin\ClockTask.elf .\bin\ClockTask.hex

@rem call %GCC%\bin\arm-none-eabi-g++ -Os -Wl,--gc-sections -save-temps -Tflash_with_bootloader.ld --specs=nano.specs --specs=nosys.specs -mcpu=cortex-m4 -mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -u _printf_float -u _scanf_float -Wl,--wrap,_write -u __wrap__write -o .\bin\ClockTask.elf .\lib\arm-freertos\ClockTask.o %LIBDIR%\TFT_Interface.o %LIBDIR%\TFT_eSPI.o %LIBDIR%\SPI.o %LIBDIR%\Adafruit_ZeroDMA.o %LIBDIR%\variant.o -Wl,--start-group -L%ARDUINODIR%\variants\wio_terminal -larm_cortexM4lf_math -mfloat-abi=hard -mfpu=fpv4-sp-d16 -L%ARDUINODIR%\variants\wio_terminal -lm %LIBDIR%\libfreertos.a -Wl,--end-group
@rem call %GCC%\bin\arm-none-eabi-g++ -Os -Wl,--gc-sections -save-temps -Tflash_with_bootloader.ld --specs=nano.specs --specs=nosys.specs -mcpu=cortex-m4 -mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -u _printf_float -u _scanf_float -o .\bin\ClockTask.elf .\lib\arm-freertos\ClockTask.o %LIBDIR%\TFT_Interface.o %LIBDIR%\TFT_eSPI.o %LIBDIR%\SPI.o %LIBDIR%\Adafruit_ZeroDMA.o %LIBDIR%\variant.o -Wl,--start-group -L%ARDUINODIR%\variants\wio_terminal -larm_cortexM4lf_math -mfloat-abi=hard -mfpu=fpv4-sp-d16 -L%ARDUINODIR%\variants\wio_terminal -lm %LIBDIR%\libfreertos.a -Wl,--end-group

call %BOSSAC% -i -d --port=COM5 -U -i --offset=0x4000 -w -v .\bin\ClockTask.bin -R

if "%OS%"=="Windows_NT" endlocal

@rem pause
