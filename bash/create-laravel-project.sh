#---------------------------------------------------------------------------------
# A Bash script that creates a new laravel app in the specified folder
# and installs a TALL stack preset (Livewire, Tailwind, & Alpine) - https://github.com/laravel-frontend-presets/tall
# Since most apps will have auth, we will install the auth preset
#---------------------------------------------------------------------------------

#!/usr/bin/bash/env bash

# bash -c "$(curl -sS https://raw.githubusercontent.com/munenepeter/scripts/main/create-laravel-project.sh)" my_laravel_project

# Set the project name from the command line argument
project_name=$0

echo  "Hi, the script will create a new laravel project in $project_name and install a TALL preset..."
# Install Laravel
composer create-project --prefer-dist laravel/laravel $project_name

project_path=$(pwd)/$project_name
# Change directory to the project folder
cd $project_path

# Run additional commands
# Install a TALL preset
composer require livewire/livewire laravel-frontend-presets/tall

# Publish the assets
php artisan ui tall --auth

# Install front-end dependencies
npm install

# Build assets
npm run dev

composer remove laravel-frontend-presets/tall

echo "Laravel project '$project_name' created successfully in '$project_path'."
