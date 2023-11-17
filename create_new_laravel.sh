#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

# Set the project name from the command line argument
project_name=$1
project_path=$(pwd)/$project_name

# Install Laravel
composer create-project --prefer-dist laravel/laravel $project_name

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
