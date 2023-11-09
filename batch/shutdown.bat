@REM This shutsdown only at the time specified  + 1 min
@echo off
:a 
if %time% == 23:47:00.00 goto :b
goto a:
:b
shutdown.exe /s /f /t 120 /c "Time sleep!"
exit