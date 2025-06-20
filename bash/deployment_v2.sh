#!/usr/bin/env bash


## ## =========================================================================== ##
##
## Script to automate the deployment process for a Laravel application.
##
## ## =========================================================================== ##

# Copyright (c) 2024 Stylesoup Beauty Ltd
# Author: Peter Munene <munenenjega@gmail.com>
# License: MIT

# add composer to path

# export PATH=$PATH:/opt/cpanel/composer/bin/composer

function error_exit() {
  echo -e >&2 "** Error: $1"
  exit 1
}

# Check if folder name is provided
if [ $# -eq 0 ]; then
  error_exit "Please provide a folder name as an argument (e.g., ./deploy.sh stylesoup-site)"
fi

folder_name="$1"

# Change directory to the specified folder
cd $HOME/"$folder_name" || error_exit "Failed to change directory to $HOME/$folder_name"

# Check if it's a Laravel app
version=$(/opt/cpanel/ea-php83/root/usr/bin/php artisan --version 2>/dev/null)

if [[ ${version} != *"Laravel Framework"* ]]; then
  error_exit "Not a Laravel app, exiting."
fi

# Check for .env file existence
if [[ ! -f .env ]]; then
  error_exit ".env file '$HOME/$folder_name/.env' does not exist."
fi

echo "** Enabling maintenance mode... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan down || true

# Determine branch based on folder name
branch_name="main"
if [[ "$folder_name" == "stylesoup-test" ]]; then
  branch_name="dev"
fi

# Fetch latest code depending on branch
echo "** Pulling latest changes from Git ($branch_name branch)... **"
git reset --hard HEAD || error_exit "Git reset failed"
git clean -f -d || error_exit "Git clean failed"
git pull origin "$branch_name" || error_exit "Git pull failed"

# Install dependencies
echo "** SKIPPING Installing/Updating Composer dependencies... **"
echo "** Installing/Updating Composer dependencies... **"
# composer install --no-interaction --optimize-autoloader --no-dev --profile --ignore-platform-reqs || error_exit "Composer install failed"

# Run database migrations with error handling
echo "** Running database migrations... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan migrate --force
if [[ $? -ne 0 ]]; then
  error_exit "Database migrations failed! Exiting."
fi

# App Optimization steps
echo "** Clearing application cache... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan cache:clear || true

echo "** Clearing and caching routes... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan route:cache || true

echo "** Clearing and caching configuration... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan config:cache || true

echo "** Clearing and caching views... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan view:cache || true

/opt/cpanel/ea-php83/root/usr/bin/php artisan optimize || true

echo "** Caching filament assets like components & icons... **"
/opt/cpanel/ea-php83/root/usr/bin/php artisan icons:cache || true
/opt/cpanel/ea-php83/root/usr/bin/php artisan filament:clear-cached-components || true
/opt/cpanel/ea-php83/root/usr/bin/php artisan filament:cache-components || true

# Determine the target directory based on the site being deployed
case "$folder_name" in
  "stylesoup-site")
    target_dir="$HOME/public_html/"
    ;;
  "stylesoup-test")
    target_dir="$HOME/test.stylesoup.co.ke/"
    ;;
  "stylesoup-docs")
    target_dir="$HOME/docs.stylesoup.co.ke/"
    ;;
  *)
    echo "** Unknown folder name: $folder_name. Skipping copy step. **"
    target_dir=""
    ;;
esac


if [[ -n "$target_dir" ]]; then
  echo "** Creating storage link... **"
  # Create storage link
  ln -s $HOME/"$folder_name"/storage/app/public "$target_dir"storage || true

  # copy files
  echo "** Copying $HOME/$folder_name/public/ directory to $target_dir (except index./opt/cpanel/ea-php83/root/usr/bin/php)... **"
  rsync -avzl --exclude=index./opt/cpanel/ea-php83/root/usr/bin/php "$HOME/$folder_name/public/" "$target_dir" -u || error_exit "Rsync failed"
fi

# Finish up deployment
/opt/cpanel/ea-php83/root/usr/bin/php artisan up || true

echo "** Deployment script completed! **"


#https://webhooks.stylesoup.co.ke/stylesoup-site