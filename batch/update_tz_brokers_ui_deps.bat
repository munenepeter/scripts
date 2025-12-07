@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM simple script to help you update the project dependencies
REM for the TZ Brokers UI
REM ============================================================================

REM check if the following dirs exist, if so, use it
set "projectDir="
set "foundPath="

if exist "C:\Users\%USERPROFILE%\laragon\www\TZ_Broker_UI" (
    set "projectDir=C:\Users\%USERPROFILE%\laragon\www\TZ_Broker_UI"
    set "foundPath=C:\Users\%USERPROFILE%\laragon\www\TZ_Broker_UI"
)
if exist "C:\Users\%USERNAME%\laragon\www\TZ_Broker_UI" (
    set "projectDir=C:\Users\%USERNAME%\laragon\www\TZ_Broker_UI"
    set "foundPath=C:\Users\%USERNAME%\laragon\www\TZ_Broker_UI"
)
if exist "C:\laragon\www\TZ_Broker_UI" (
    set "projectDir=C:\laragon\www\TZ_Broker_UI"
    set "foundPath=C:\laragon\www\TZ_Broker_UI"
)

REM do we have the project dir? If not, exit with error
if not defined projectDir (
    echo [ERROR] Project directory not found!
    echo.
    echo Checked locations:
    echo - C:\Users\%USERPROFILE%\laragon\www\TZ_Broker_UI
    echo - C:\Users\%USERNAME%\laragon\www\TZ_Broker_UI
    echo - C:\laragon\www\TZ_Broker_UI
    echo.
    echo Please ensure the TZ_Broker_UI project exists in one of these locations.
    pause
    exit /b 1
)

echo [INFO] Found project at: %foundPath%
echo.

REM move to the project dir
echo [STEP 1] Changing to project directory...
cd /d "%projectDir%" 2>nul
if errorlevel 1 (
    echo [ERROR] failed to change to project directory: %projectDir%
    echo cannot proceed further, please try manually updating
    pause
    exit /b 1
)
echo [OK] Changed to: %cd%
echo.


REM check for uncommitted changes before stashing
echo [STEP 2] Checking for uncommitted changes...
git status --porcelain > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git command failed. Is git installed and in your PATH?
    echo cannot proceed further, please try manually updating
    pause
    exit /b 1
)

REM Git stash all the current working changes, if any
echo [STEP 3] Stashing current working changes...
git diff-index --quiet HEAD -- 2>nul
if errorlevel 1 (
    echo [INFO] Uncommitted changes detected. Stashing...
    git stash push -m "Auto-stash by update script %date% %time%" 2>nul
    if errorlevel 1 (
        echo [ERROR] Failed to stash changes!
        echo.
        echo Possible reasons:
        echo - You may have unpushed commits
        echo - You may have conflicts
        echo - Git configuration issues
        echo.
        echo Please manually review your changes with 'git status'
        echo cannot proceed further, please try manually updating.
        pause
        exit /b 1
    )
    echo [OK] Changes stashed successfully
) else (
    echo [INFO] No uncommitted changes to stash
)
echo.

REM Git pull origin main -> check if this was successful
echo [STEP 4] Pulling latest changes from origin/main...
git pull origin main
if errorlevel 1 (
    echo [ERROR] Git pull failed!
    echo.
    echo Possible reasons:
    echo - Network connectivity issues
    echo - Merge conflicts
    echo - Remote repository access issues
    echo.
    echo Please resolve manually with 'git status' and 'git pull'
    echo This is an unrecoverable error. Stopping execution.
    pause
    exit /b 1
)
echo [OK] Successfully pulled latest changes
echo.

REM Unstash changes if we stashed any earlier
echo [STEP 5] Restoring stashed changes (if any)...
git stash list | find "Auto-stash by update script" >nul 2>&1
if not errorlevel 1 (
    echo [INFO] Restoring your previously stashed changes...
    git stash pop
    if errorlevel 1 (
        echo [WARNING] Failed to apply stashed changes automatically!
        echo [WARNING] There might be merge conflicts.
        echo.
        echo Your changes are still in the stash. You can:
        echo - Run 'git stash list' to see your stashes
        echo - Run 'git stash apply' to try applying them manually
        echo - Run 'git diff stash@{0}' to see what was stashed
        echo.
        echo Continuing with the update process...
    ) else (
        echo [OK] Stashed changes restored successfully
    )
) else (
    echo [INFO] No stashed changes to restore
)
echo.

REM Kill Chrome (to force clear cache)
echo [STEP 5] Killing Chrome processes to clear cache...
taskkill /F /IM chrome.exe >nul 2>&1
if errorlevel 1 (
    echo [INFO] No Chrome processes found (or already closed)
) else (
    echo [OK] Chrome processes terminated
    timeout /t 2 /nobreak >nul
)
echo.

REM Kill any dev servers running on port 3000
echo [STEP 6] Checking for dev servers on port 3000...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do (
    echo [INFO] Found process %%a on port 3000, terminating...
    taskkill /F /PID %%a >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Failed to kill process %%a
    ) else (
        echo [OK] Process %%a terminated
    )
)
echo [INFO] Port 3000 check complete
echo.

REM Delete node_modules if it exists
echo [STEP 7] Cleaning node_modules directory...
if exist "node_modules" (
    echo [INFO] Deleting node_modules folder...
    rmdir /s /q "node_modules" 2>nul
    if exist "node_modules" (
        echo [WARNING] Some files in node_modules could not be deleted
        echo [WARNING] They may be in use. Continuing anyway...
    ) else (
        echo [OK] node_modules deleted successfully
    )
) else (
    echo [INFO] node_modules folder does not exist
)
echo.

REM Run npm clean cache --force && npm install --legacy-peer-deps
echo [STEP 9] Cleaning npm cache...
npm cache clean --force
if errorlevel 1 (
    echo [WARNING] npm cache clean had issues, but continuing...
)
echo.

echo [STEP 10] Installing dependencies (this may take a while)...
npm install --legacy-peer-deps
if errorlevel 1 (
    echo [ERROR] npm install failed!
    echo.
    echo Please check the error messages above.
    echo Common solutions:
    echo - Delete node_modules and package-lock.json manually
    echo - Check your internet connection
    echo - Try running 'npm install --legacy-peer-deps --verbose' manually
    echo.
    echo This is an unrecoverable error. Stopping execution.
    pause
    exit /b 1
)
echo [OK] Dependencies installed successfully
echo.




REM Run npx next dev - to restart the dev server
echo [STEP 11] Starting Next.js development server...
echo.
echo Dev server starting...
echo Press Ctrl+C to stop the server
echo.

npx next dev