<?php
declare(strict_types=1);

/*
|--------------------------------------------------------------------------
| CI for Laravel apps on shared hosting (copy public, delete logs, & create symlink)
|--------------------------------------------------------------------------
|
| This script is designed to be run from the command line. but can also be called programatically
| It moves files and directories from a specified source folder, by default all files in public/ to where this script was uploaded
|
| If you're using github actions you can curl <your_site_url>/[script_name].php and the speficed actions will be done on your server.
| 
| 1. upload this script to the entry point of your application e.g public_html & update the constant LARAVEL_INSTALL_PATH
| 2. call this file programatically, maybe use curl in your github actions
| 3. ...you're done, that's it, the script has 
|   a).copied your new front-end assets (all files [laravel_install_path]/public) to public_html ([script_install_path])
|   b).cleared all laravel & server logs for you (only logs that concern this application)
|   c).created a symbolic link in [script_install_path]/storage which points to [laravel_install_path]/storage/app/public
|
*/

define('LARAVEL_INSTALL_PATH', __DIR__.'/path/to/laravel-app/install/');

if(!file_exists(LARAVEL_INSTALL_PATH) || !is_dir(LARAVEL_INSTALL_PATH)){
    printf("\033[31m ✓ \033[0m Error: seems like you have not updated your LARAVEL_INSTALL_PATH -> %s or it is not accessible\n", LARAVEL_INSTALL_PATH);
    exit(1);
}

//remove all pre-existing files first
exec('rm -rf $(ls | grep -v ' . basename(__FILE__) . ')', $output, $result_code);

if ($result_code === 0) {
    printf("\033[32m ✓ \033[0m Success: removed old front-end files in %s\n", dirname(__FILE__));
} else {
    printf("\033[31m ✗ \033[0m Error: Could not remove old front-end files in %s\n", dirname(__FILE__));
    exit(1);
}
//remove logs
exec('rm -f ' . full_path('storage/logs/*.log'), $output1, $result_code1);

if ($result_code1 === 0) {
    printf("\033[32m ✓ \033[0m Success: removed framework logs\n");
} else {
    printf("\033[31m ✗\033[0m Error: Could not remove framework logs\n");
    exit(1);
}

// host logs
exec('rm -f ' . __DIR__ . '*.log', $output2, $result_code2);

if ($result_code2 === 0) {
    printf("\033[32m ✓ \033[0m Success: removed local logs\n");
} else {
    printf("\033[31m ✗\033[0m Error: Could not remove local logs\n");
    exit(1);
}

// clear compiled views
exec('rm -f ' . full_path('storage/framework/views/*.php'), $output3, $result_code3);

if ($result_code3 === 0) {
    printf("\033[32m ✓ \033[0m Success: removed compiled views\n");
} else {
    printf("\033[31m ✗\033[0m Error: Could not remove compiled views\n");
    exit(1);
}

//create symlink for storage
if (symlink(full_path('storage/app/public'),  dirname(__FILE__).'/storage')) {
    printf("\033[32m ✓ \033[0m Success: Created symbolic link to public_html\storage\n");
} else {
    printf("\033[31m ✗\033[0m Error: Could not create a symbolic link to your storage folder\n");
    exit(1);
}

$source_folder = full_path('public/');

if (move_files($source_folder, __DIR__)) {
    printf("\033[32m ✓ \033[0m Success: updated front-end assets\n");
} else {
    printf("\033[31m ✗ \033[0m Error: update the new front-end assets from %s\n", $source_folder);
    exit(1);
}

/* -------------------------------------------------
           FUNCTIONS
   -------------------------------------------------*/

/**
 * Recursively move files and directories.
 *
 * @param string $source      The source directory or file.
 * @param string $destination The destination directory or file.
 * 
 * @return bool                The status of the copy operation
 */
function move_files(string $source, string $destination): bool {
    // Remove "." and ".."
    $items = array_diff(scandir($source), ['.', '..']);

    foreach ($items as $item) {
        $source_path = $source . '/' . $item;
        $destination_path = $destination . '/' . $item;

        if (is_link($source_path)) {
            symlink(readlink($source_path), $destination_path);
        } elseif (is_dir($source_path)) {
            // it's a dir, create the dest dir
            if (!file_exists($destination_path)) {
                mkdir($destination_path);
            }
            move_files($source_path, $destination_path);
        } else {
            if (!copy($source_path, $destination_path)) {
                return false;
            }
        }
    }
    return true;
}
/**
 * Concatenate the relative path to the full path of where the laravel application is uplooded
 *
 * @param string $path relative path from the folder where the laravel app is uploaded
 * 
 * @return string full path starting from root
 */
function full_path(string $path): string {
    return LARAVEL_INSTALL_PATH . $path;
}
