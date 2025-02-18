@echo off
setlocal enabledelayedexpansion

echo Hello %username%, I'm here to help you clean up your computer :)
echo This script will perform comprehensive system cleanup and optimization
timeout /t 3 /nobreak > NUL

:: Create a log file
set "logfile=%userprofile%\Desktop\cleanup_log_%date:~-4,4%%date:~-10,2%%date:~-7,2%.txt"
echo Cleanup started at: %date% %time% > "%logfile%"

:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please run this script as Administrator!
    pause
    exit /b 1
)

echo === Starting System Cleanup ===

:: Clear Temporary Files
echo Cleaning temporary files...
rd /s /q "%temp%" 2>nul
md "%temp%"
del /s /q "%SystemRoot%\Temp\*.*" 2>nul
del /s /q "%USERPROFILE%\AppData\Local\Temp\*.*" 2>nul

:: Clear Prefetch
echo Cleaning Prefetch...
del /s /q "%SystemRoot%\Prefetch\*.*" 2>nul

:: Clear Windows Update Cache
echo Cleaning Windows Update Cache...
net stop wuauserv 2>nul
net stop bits 2>nul
del /s /q "%SystemRoot%\SoftwareDistribution\Download\*.*" 2>nul
net start wuauserv 2>nul
net start bits 2>nul

:: Clear DNS Cache
echo Cleaning DNS Cache...
ipconfig /flushdns

:: Clear Browser Caches (Chrome, Firefox, Edge)
echo Cleaning Browser Caches...
taskkill /F /IM "chrome.exe" 2>nul
taskkill /F /IM "firefox.exe" 2>nul
taskkill /F /IM "msedge.exe" 2>nul
del /s /q "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache\*.*" 2>nul
del /s /q "%USERPROFILE%\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.*" 2>nul
del /s /q "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*.*" 2>nul

:: Clear Windows Store Cache
echo Cleaning Windows Store Cache...
WSReset.exe

:: Run Disk Cleanup
echo Running Disk Cleanup...
cleanmgr /sagerun:1

:: Optimize System Performance
echo Optimizing System Performance...

:: Disable unnecessary services
echo Disabling unnecessary services...
sc config "DiagTrack" start= disabled
sc config "dmwappushservice" start= disabled
sc config "SysMain" start= disabled

:: Clear Event Logs
echo Clearing Event Logs...
for /F "tokens=*" %%G in ('wevtutil el') do (
    echo Clearing %%G
    wevtutil cl "%%G" 2>nul
)

:: Defragment drives (only for HDDs)
echo Checking drive type and defragmenting if needed...
for /f "tokens=2 delims==" %%a in ('wmic volume get DriveLetter^,FileSystem /value ^| find "FileSystem"') do (
    if "%%a"=="NTFS" (
        defrag %SystemDrive% /A /V >> "%logfile%"
    )
)

:: Run System File Checker
echo Running System File Checker...
sfc /scannow

:: Optional: Change Password
echo Do you want to change your password? (Y/N)
set /p changepw=
if /i "%changepw%"=="Y" (
    echo Changing password for %username%...
    net user %username% *
)

echo === Cleanup Complete ===
echo Log file created at: %logfile%
echo Please restart your computer for all changes to take effect.

pause
