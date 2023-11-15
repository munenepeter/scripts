@echo off
setlocal enabledelayedexpansion

set "source_directory=%USERPROFILE%\Downloads"

for %%F in ("%source_directory%\*.mp3") do (
    set "filename=%%~nF"
    set "new_filename=!filename:~14!"
    ren "%%F" "!new_filename!"
)

echo Files renamed successfully.

