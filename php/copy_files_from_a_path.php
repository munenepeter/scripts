<?php
/*
|--------------------------------------------------------------------------
| Move files and directories to script directory
|--------------------------------------------------------------------------
|
| This script is designed to be run exclusively from the command line.
| It moves files and directories from a specified source folder 
| to the directory where the script is located.
|
*/

$source_folder = __DIR__ . '/../path/to/copy/from/';

/**
 * Recursively move files and directories.
 *
 * @param string $source      The source directory or file.
 * @param string $destination The destination directory or file.
 */
function move_files(string $source, string $destination) {
    // Remove "." and ".."
    $items = array_diff(scandir($source), ['.', '..']);


    foreach ($items as $item) {
        $source_path = $source . '/' . $item;
        $destination_path = $destination . '/' . $item;
        
        if (is_link($source_path)) {
            //link to the intended symbolic link
            symlink(readlink($source_path), $destination_path);
            printf("Copied symlink: %s\n", $item);
        } elseif (is_dir($source_path)) {
            // it's a dir, create the dest dir
            if (!file_exists($destination_path)) {
                mkdir($destination_path);
            }
            move_files($source_path, $destination_path);
        } else {
            if (copy($source_path, $destination_path)) {
                printf("Copied: %s\n", $item);
            } else {
                printf("Error copying %s\n", $item);
            }
        }
    }
}
//remove all pre-existing files first
 shell_exec('rm -rf $(ls | grep -v mv.php)');
// if() === false){
//     printf("Could not remove previous files in %s", $source_folder);
//     exit;
// }

move_files($source_folder, __DIR__);
