<?php
/**
 * V1 11.12.2024
 * 
 * Script to process files (.php, .tpl, .js) of a specific SuiteCRM custom module
 * into a TXT file with the following structure:
 *
 *   <File Start: ./path/filename.extension>
 *     Content of file
 *   <End File: ./path/filename.extension>
 *
 * Usage: php suitecrm_promptgen.php <module-path> [output-filename]
 */

// Check arguments
if ($argc < 2 || $argc > 3) {
    echo "Usage: php suitecrm_promptgen.php <module-path> [output-filename]" . PHP_EOL;
    exit(1);
}

// Get the module directory (convert to absolute path if relative)
$moduleDir = realpath($argv[1]);

// Ensure the module directory exists
if (!is_dir($moduleDir)) {
    echo "Error: The specified module path does not exist: $moduleDir" . PHP_EOL;
    exit(1);
}

// Set output filename
$outputName = $argv[2] ?? 'suitecrm_prompt.txt';
$outputDir = getenv("HOME") . '/SuiteCRM_Prompts';
$outputPath = $outputDir . '/' . $outputName;

// Create output directory if it doesn't exist
if (!is_dir($outputDir)) {
    mkdir($outputDir, 0777, true);
}

// Open the output file
$outputFile = fopen($outputPath, 'w');
if (!$outputFile) {
    echo "Failed to create output file: $outputPath" . PHP_EOL;
    exit(1);
}

// Define allowed file extensions
$allowedExtensions = ['php', 'tpl', 'js'];

// Process files in the module directory
echo "Processing SuiteCRM files from: $moduleDir" . PHP_EOL;
$iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($moduleDir));
foreach ($iterator as $fileInfo) {
    $extension = $fileInfo->getExtension();
    if (in_array($extension, $allowedExtensions)) {
        $filePath = $fileInfo->getPathname();
        fwrite($outputFile, "<File Start: $filePath>" . PHP_EOL);
        fwrite($outputFile, file_get_contents($filePath) . PHP_EOL);
        fwrite($outputFile, "<End File: $filePath>" . PHP_EOL);
    }
}

// Close the output file
fclose($outputFile);

// Display a success message
echo "Files have been compiled to: $outputPath" . PHP_EOL;
