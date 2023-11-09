@echo off

echo Hello %username%, I'm here to help you clean up your computer :)
timeout /t 3 /nobreak > NUL
echo Let's start


echo Deleting your Temprary files....

@REM remove the echo below for it to run
del /s /q %temp%\*.* 1>nul


@REM This folder contains the log about the frequently running application on your machine. 
@REM c:\windows\Prefetch

del /s /q %SystemRoot%\Prefetch\*.* 1>nul
timeout /t 2 /nobreak > NUL

@REM This folder contains your Windows Update data 
@REM c:\windows\softwaredistribution\download
echo Deleting Windows updates Temprary files....


del /s /q %SystemRoot%\SoftwareDistribution\Download\*.* 1>nul
timeout /t 1 /nobreak > NUL




echo Cleaning DNS cache.....

@REM remove the echo below for it to run
ipconfig/flushdns
timeout /t 2 /nobreak > NUL

echo Deleting unnecessary files in your Cache....
echo Please follow the prompts outside of CMD

@REM remove the echo below for it to run
Cleanmgr
timeout /t 2 /nobreak > NUL


@REM echo Clearing Windows Store Cache......
WSReset.exe

@REM Now lets change the user's in this case Admin's password

echo Now let's change the Admin's password, Please be careful!!
timeout /t 2 /nobreak > NUL
echo We trust you have received the usual lecture from the local System Administrator... 
echo It usually boils down to these three things:
timeout /t 3 /nobreak > NUL
echo    #1) Respect the privacy of others.
timeout /t 2 /nobreak > NUL
echo    #2) Think before you type.
timeout /t 2 /nobreak > NUL
echo    #3) And With great power comes great responsibility.

timeout /t 2 /nobreak > NUL

@REM remove the echo below for it to run

echo net user %username% *
