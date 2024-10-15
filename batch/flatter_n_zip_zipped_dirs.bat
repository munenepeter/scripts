@echo off
setlocal enabledelayedexpansion

echo.
echo ============================================================================================
echo                                        Batch Script Description
echo ============================================================================================
echo.
echo This batch script automates the process of unzipping multiple zip files in a specified source directory,
echo flattening the folder structure by extracting files directly into a new destination folder without 
echo additional subdirectories. After unzipping, the script zips the contents back into a new zip file 
echo for each original zip file, appending "_new" to the new zip file names.
echo.
echo Functionality:
echo - Scans the specified source directory for .zip files. (if not it fails)
echo - Unzips the contents of each zip file one folder and removes any child directories.
REM Usage:
REM Place the UnzipAndRezip.bat script in a convenient location.
REM Edit the script to set the `source_dir` variable to the path of the directory containing the zip files.
REM Run the script by double-clicking it or executing it from the command line.
REM Check the destination folder (default is the user's `Documents/NewZippedFolders`) for  the newly created zip files.
REM Review the log file for any warnings or errors during execution.
echo.

echo Are you sure you want to run this script?
echo.
set /p prompt="Are you sure you want to run this script? (Y/N): "
if /i "!prompt!" NEQ "Y" (
    echo Exiting script. Thanks for trying the script.
    exit /b 1
)

REM Set paths
set "source_dir=%USERPROFILE%\Documents\folders" 
set "destination_dir=%USERPROFILE%\Documents\NewZippedFolders"
set "log_file=%destination_dir%\log.log"


echo Please confirm your paths:
echo.
echo Source Directory: %source_dir%
echo Destination Directory: %destination_dir%
echo.
set /p confirm="Are these paths correct? (Y/N): "
if /i "!confirm!" NEQ "Y" (
    echo Exiting script. Please check your paths and try again.
    exit /b 1
)

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
echo ========================================= >> "%log_file%"
echo Starting processing of zipped folders... >> "%log_file%"
echo.


for %%F in ("%source_dir%\*.zip") do (
    set "folder_name=%%~nF"
    set "unzip_folder=%source_dir%\%%~nF_unzipped"
    set "new_zip=%destination_dir%\!folder_name!_new.zip"

    echo Processing "%%F"...
    echo.

    REM Create temporary unzip folder
    mkdir "!unzip_folder!"
    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to create folder "!unzip_folder!". Script will terminate. >> "!log_file!"
        echo ERROR: Failed to create folder "!unzip_folder!". Script will terminate.
        exit /b 1
    )

    REM Unzip the folder
    echo Unzipping "%%F" to "!unzip_folder!"...
    echo.
    powershell -Command "Expand-Archive -Path '%%F' -DestinationPath '!unzip_folder!'"

    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to unzip "%%F". Script will terminate. >> "!log_file!"
        echo ERROR: Failed to unzip "%%F". Script will terminate.
        exit /b 1
    )

    REM Check if files exist in unzipped folder
    if exist "!unzip_folder!\!folder_name!\*" (
        set "target_folder=!unzip_folder!\!folder_name!"
        
        REM Check if we can go two directories deep
        if exist "!target_folder!\*" (
            set "target_folder=!target_folder!"
        ) else (
            echo WARNING: Only one directory found for "%%F", zipping files from the first level. >> "!log_file!"
            echo WARNING: Only one directory found for "%%F", zipping files from the first level.
            set "target_folder=!unzip_folder!"
        )
    ) else (
        echo WARNING: No folder named "!folder_name!" found after unzipping "%%F". Zipping from the first level. >> "!log_file!"
        echo WARNING: No folder named "!folder_name!" found after unzipping "%%F". Zipping from the first level.
        set "target_folder=!unzip_folder!"
    )

    echo Zipping contents of "!target_folder!" to "!new_zip!"...
    echo.
    
    REM Zip only files, excluding subfolders getting only children
    powershell -Command "Get-ChildItem '!target_folder!' -File | Compress-Archive -DestinationPath '!new_zip!'"

    if !ERRORLEVEL! neq 0 (
        echo ERROR: Failed to zip files for "%%F". Script will terminate. >> "!log_file!"
        echo ERROR: Failed to zip files for "%%F". Script will terminate.
        exit /b 1
    )

    echo Successfully processed "%%F"!
    echo Successfully processed "%%F"! >> "!log_file!"

    REM Cleaning up unzipped folder
    rd /s /q "!unzip_folder!"
)
echo.
echo All operations completed! Opening "%log_file%" for warnings or errors.
notepad "%log_file%"
pause
