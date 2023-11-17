@echo off

REM A Batch script that creates a new Laravel app in the specified folder
REM and installs a TALL stack preset (Livewire, Tailwind, & Alpine) - https://github.com/laravel-frontend-presets/tall
REM Since most apps will have auth, we will install the auth preset

REM curl -o create-laravel-project.bat https://raw.githubusercontent.com/munenepeter/scripts/main/new-laravel-app-Win.bat && call create-laravel-project.bat <my_laravel_project>


REM Usage: create-laravel-project.bat <project_name>

REM Check if the correct number of arguments is provided
if "%1"=="" (
    echo Usage: %0 ^<project_name^>
    exit /B 1
)

echo Hi, the script will create a new Laravel project in %1 and install a TALL preset...

REM Set the project name from the command line argument
set "project_name=%1"
set "project_path=%cd%\%project_name%"

REM Install Laravel
composer create-project --prefer-dist laravel/laravel %project_name%

REM Change directory to the project folder
cd %project_path%

REM Run additional commands
REM Install a TALL preset
composer require livewire/livewire laravel-frontend-presets/tall

REM Publish the assets
php artisan ui tall --auth

REM Install front-end dependencies
npm install

REM Build assets
npm run dev

REM Remove unnecessary packages
composer remove laravel-frontend-presets/tall

echo Laravel project '%project_name%' created successfully in '%project_path%'.
