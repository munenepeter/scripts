<?php

/**|
 * |   =================================================
 * |    Move files and directories to script directory
 * |   ===================================================
 * |
 * |    This script is designed to be run exclusively from the command line. It moves files and
 * |    directories from a specified source folder to the directory where the script is located.
 */

$source_folder = '/path/to/your/source/folder';

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

        if (is_dir($source_path)) {
            // it's a dir, create the dest dir
            if (!file_exists($destination_path)) {
                mkdir($destination_path);
            }
            move_files($source_path, $destination_path);
        } else {
            // it's a file, copy
            if (copy($source_path, $destination_path)) {
                // Uncomment the line below to delete the source file after copying
                // unlink($source_path);
                echo "Copied: $item\n";
            } else {
                echo "Error copying $item\n";
            }
        }
    }
}

move_files($source_folder, __DIR__);
