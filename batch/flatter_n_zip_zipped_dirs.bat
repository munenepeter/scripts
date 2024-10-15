@echo off
setlocal enabledelayedexpansion

REM set paths
set "source_dir=%USERPROFILE%\Documents\folders" 
set "destination_dir=%USERPROFILE%\Documents\NewZippedFolders"
set "log_file=%destination_dir%\log.log"


REM create destination folder if it doesn't exist
if not exist "%destination_dir%" (
    mkdir "%destination_dir%"
)

REM clear the log file if it exists
if exist "%log_file%" (
    del "%log_file%"
)

echo.
echo Starting processing of zipped folders...
echo.
echo =========================================
echo Starting processing of zipped folders... >> "%log_file%"
echo.
echo ========================================= >> "%log_file%"

REM each zipped file 
for %%F in ("%source_dir%\*.zip") do (
    set "folder_name=%%~nF"
    set "unzip_folder=%source_dir%\%%~nF_unzipped"
    set "new_zip=%destination_dir%\!folder_name!_new.zip"

    echo Processing "%%F"...
    echo.

    REM create temporary unzip folder
    mkdir "!unzip_folder!"
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to create folder "!unzip_folder!". Script will terminate. >> "!log_file!"
        echo ERROR: Failed to create folder "!unzip_folder!". Script will terminate.
        exit /b 1
    )

    REM unzip the folder
    echo Unzipping "%%F" to "!unzip_folder!"...
    echo.
    powershell -Command "Expand-Archive -Path '%%F' -DestinationPath '!unzip_folder!'"

    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to unzip "%%F". Script will terminate. >> "!log_file!"
        echo ERROR: Failed to unzip "%%F". Script will terminate.
        exit /b 1
    )

    REM check if the first-level directory exists
    if exist "!unzip_folder!\!folder_name!\*" (
        set "target_folder=!unzip_folder!\!folder_name!"
        
        REM check if we can go two directories deep
        if exist "!target_folder!\*" (
            set "target_folder=!target_folder!"
        ) else (
            echo WARNING: Only one directory found for "%%F", zipping files from the first level. >> "!log_file!"
            echo.
            echo WARNING: Only one directory found for "%%F", zipping files from the first level.
            set "target_folder=!unzip_folder!"
        )
    ) else (
        echo WARNING: No folder named "!folder_name!" found after unzipping "%%F". Zipping from the first level. >> "!log_file!"
        echo.
        echo WARNING: No folder named "!folder_name!" found after unzipping "%%F". Zipping from the first level.
        set "target_folder=!unzip_folder!"
    )

    echo Zipping contents of "!target_folder!" to "!new_zip!"...
    echo.
    REM zip only files, excluding subfolders getting the children only
    powershell -Command "Get-ChildItem '!target_folder!' -File | Compress-Archive -DestinationPath '!new_zip!'"

    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to zip files for "%%F". Script will terminate. >> "!log_file!"
        echo.
        echo ERROR: Failed to zip files for "%%F". Script will terminate.
        exit /b 1
    )

    echo Successfully processed "%%F"!
    echo.
    echo Successfully processed "%%F"! >> "!log_file!"

    REM cleaning up the unzipped folder
    rd /s /q "!unzip_folder!"
)
echo.
echo.
echo All operations completed! Check "%log_file%" for warnings or errors.
pause
