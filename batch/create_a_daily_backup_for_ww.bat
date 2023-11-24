@echo off
setlocal

REM Set the source and destination paths
set "source=%APPDATA%\aignes"
set "destination=%USERPROFILE%\Desktop\JWG Tracking\WW Backups"

REM Get the current date in the format YYYYMMDD
for /F "tokens=1-3 delims=/ " %%a in ('wmic os get localdatetime ^| findstr /r "[0-9]"') do (
  set "currentDate=%%c%%a%%b"
)

REM Set the name of the compressed file with the appended date
set "zipFileName=_ww_backup_%currentDate%.zip"

REM Create a temporary directory
set "tempDir=%TEMP%\_backup_temp"
mkdir "%tempDir%"

REM Copy the source folder to the temporary directory
xcopy "%source%" "%tempDir%" /E /I /H /C /K

REM Compress the temporary directory to a zip file
powershell -Command "Compress-Archive -Path '%tempDir%' -DestinationPath '%destination%\%zipFileName%'"

REM Check if the compression was successful
if %errorlevel% equ 0 (
  echo Compression completed successfully.
  REM You can add additional commands here if needed.
) else (
  echo Compression failed. Please check the source and destination paths.
)

REM Remove the temporary directory
rd /S /Q "%tempDir%"

endlocal
