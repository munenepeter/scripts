@REM This is just a test -- It has not been tested yet

@echo off
set program = %1

@REM  Get the program running
@REM TASKLIST /FI "IMAGENAME eq %1.exe"


@REM Kill the whole process by force and then shutdown the machine.

taskkill -im %1.exe /f

@REM then restart the program incases when it was not responding
@REM start %1.exe 

@REM Maybe later you might wanna shutdown or restart the machine 
@REM shutdown /p

pause
