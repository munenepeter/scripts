#!/usr/bin/env bash

## ## ======================================================================= ##
##
## Script to automate the deployment process for a Laravel application.
## This works hand-in hand with <https://github.com/munenepeter/scripts/blob/main/php/deployment.php>
##
## ## ======================================================================= ##

# Copyright (c) 2024 Chungu Developers
# Author: Peter Munene <munenenjega@gmail.com>
# License: MIT

# Colors and symbols for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
CHECK_MARK="${GREEN}✓${NC}"
CROSS_MARK="${RED}✖${NC}"

# Logging functions
log_success() {
    echo -e "${CHECK_MARK} $1"
}

log_error() {
    echo -e "${CROSS_MARK} $1" >&2
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error_exit() {
    log_error "Error: $1"
    exit 1
}

log_step() {
    echo -e "\n${BLUE}▶${NC} $1"
}

log_step_result() {
    if [ $1 -eq 0 ]; then
        log_success "$2"
    else
        log_error "$3"
        return 1
    fi
}

# Check if folder name is provided
if [ $# -eq 0 ]; then
    error_exit "Please provide a folder name as an argument (e.g., ./deploy.sh <instance>-site)"
fi

folder_name="$1"

# Change directory to the specified folder
cd $HOME/"$folder_name" || error_exit "Failed to change directory to $HOME/$folder_name"

# Check if it's a Laravel app

# if the installed php version does not work, use the full path to the php executable

log_step "Validating Laravel installation"
version=$(php artisan --version 2>/dev/null)
if [[ ${version} != *"Laravel Framework"* ]]; then
    error_exit "Not a Laravel app, exiting."
fi
log_success "Laravel installation verified: $version"

# Check for .env file existence
log_step "Checking environment configuration"
if [[ ! -f .env ]]; then
    error_exit ".env file '$HOME/$folder_name/.env' does not exist."
fi
log_success "Environment file found and verified"

log_step "Enabling maintenance mode"
if php artisan down; then
    log_success "Maintenance mode enabled"
else
    log_warning "Could not enable maintenance mode, continuing anyway"
fi

# Determine branch based on folder name
branch_name="main"
if [[ "$folder_name" == "<instance>-test" ]]; then
    branch_name="dev"
fi

# Git operations
log_step "Pulling latest changes from Git ($branch_name branch)"
git reset --hard HEAD || error_exit "Git reset failed"
log_success "Git reset completed"

git clean -f -d || error_exit "Git clean failed"
log_success "Git clean completed"

git pull origin "$branch_name" || error_exit "Git pull failed"
log_success "Successfully pulled latest changes from $branch_name"

# Composer dependencies
log_step "Installing Composer dependencies"
#user composer directly or use the full path - /opt/cpanel/composer/bin/composer
if php composer install --optimize-autoloader --no-dev --profile --ignore-platform-reqs > /dev/null; then
    log_success "Composer dependencies installed successfully"
else
    error_exit "Composer installation failed"
fi

# Database migrations
log_step "Running database migrations"
if php artisan migrate --force; then
    log_success "Database migrations completed successfully"
else
    error_exit "Database migrations failed"
fi

# Application optimization
log_step "Optimizing application"

commands=(
    "cache:clear|Clearing application cache"
    "route:cache|Caching routes"
    "config:cache|Caching configuration"
    "view:cache|Caching views"
    "optimize|Optimizing application"
    "responsecache:clear|Clearing response cache"
    "icons:cache|Caching icons"
    #comment if filament is not installed
    "filament:clear-cached-components|Clearing Filament components"
    "filament:cache-components|Caching Filament components"
)

for cmd in "${commands[@]}"; do
    IFS="|" read -r command description <<< "$cmd"
    log_info "$description"
    if php artisan $command; then
        log_success "$description completed"
    else
        log_warning "$description failed, continuing anyway"
    fi
done

# Determine target directory
log_step "Preparing deployment target"
case "$folder_name" in
    "<instance>-site")
        target_dir="$HOME/public_html/"
        ;;
    "<instance>-test")
        target_dir="$HOME/test.<instance>.com/"
        ;;
    "<instance>-docs")
        target_dir="$HOME/docs.<instance>.com/"
        ;;
    *)
        log_error "Unknown folder name: $folder_name. Skipping copy step."
        target_dir=""
        ;;
esac

if [[ -n "$target_dir" ]]; then
    log_step "Creating storage link"
    if ln -s $HOME/"$folder_name"/storage/app/public "$target_dir"storage; then
        log_success "Storage link created successfully"
    else
        log_warning "Storage link creation failed (might already exist)"
    fi

    log_step "Copying public assets"
    if rsync -avzl --exclude=index.php "$HOME/$folder_name/public/" "$target_dir" -u > /dev/null; then
        log_success "Public assets copied successfully"
    else
        error_exit "Failed to copy public assets"
    fi
fi

# Clear logs
log_step "Cleaning up"
echo "" > $HOME/"$folder_name"/storage/logs/laravel.log
log_success "Logs cleared successfully"

# Disable maintenance mode
log_step "Finishing deployment"
if php artisan up; then
    log_success "Application is now live"
else
    log_warning "Could not disable maintenance mode"
fi

log_success "Deployment completed successfully!"
