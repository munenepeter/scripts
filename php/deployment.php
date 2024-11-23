<?php


/*
|--------------------------------------------------------------------------
| Webhook script
|--------------------------------------------------------------------------
|
| This script triggers the deployment process for a Laravel application
| based on a folder name provided through a URL parameter 'site'.
|
| It resides on it's own subdomain - webhooks.instance.com as index.php
|
| https://webhooks.instance.com/<site>
|
| Copyright (c) 2024 Chungu Developers
| License: MIT 
| Author: Peter Munene <munenenjega@gmail.com>
*/

date_default_timezone_set('Africa/Nairobi');


//define the folder name to be used for deployment
define('LARAVEL_INSTALL_PATH', "/home/<hostname>/$folderName");


//-----------------------------------------------------------------------

// Enhanced ANSI escape sequence patterns
define('ANSI_PATTERNS', [
    // Basic colors
    '/\033\[0;31m(.*?)\033\[0m/' => '<span class="text-red">$1</span>',      // Red
    '/\033\[0;32m(.*?)\033\[0m/' => '<span class="text-green">$1</span>',    // Green
    '/\033\[0;33m(.*?)\033\[0m/' => '<span class="text-yellow">$1</span>',   // Yellow
    '/\033\[0;34m(.*?)\033\[0m/' => '<span class="text-blue">$1</span>',     // Blue
    
    // Complex ANSI patterns
    '/\033\[0m\033\[32m\[0m/' => '<span class="text-green">✓</span>',        // Green checkmark
    '/\033\[0m\033\[31m\[0m/' => '<span class="text-red">✖</span>',          // Red cross
    '/\033\[0;34m▶\033\[0m/' => '<span class="text-blue">▶</span>',          // Blue arrow
    
    // Clean up any remaining escape sequences
    '/\033\[\d+m/' => '',
    '/\033\[0m/' => '',
]);


$logHandle = fopen('deployment.log', 'a+');

writeLog($logHandle, "✓ Deployment script triggered by . IP: " . $_SERVER['REMOTE_ADDR'] . "\n");
writeLog($logHandle, "✓ User Agent: " . $_SERVER['HTTP_USER_AGENT']);

displayOutput('✓ DEPLOYMENT STARTED AT ' . date('d M Y H i s'),  false);
displayOutput("✓ Deployment script triggered by. IP: " . (php_sapi_name() === 'cli' ? 'N/A' : ($_SERVER['REMOTE_ADDR'] ?? 'N/A')), false);
displayOutput("✓ Logging deployment logs at ./deployment.log", false);

//valid folder names, incase of other deployments, add the folders here
$validFolders = ['instance-site', 'instance-test', 'instance-docs'];

// Get folder name from URL parameter (assuming it's called 'site')
$folderName = trim(str_replace("/", "", strtok($_SERVER['REQUEST_URI'], '? '))) ?? '';

// Validate folder name
if ($folderName === '' || !in_array($folderName, $validFolders)) {
    writeLog($logHandle, "Deployment script started with URL: " . $_SERVER['REQUEST_URI'] . " and foldername $folderName \n");
    displayOutput("Error: Invalid folder name. Please use 'instance-site', 'instance-test', or 'instance-docs'.", true);
    writeLog($logHandle, "Invalid folder name. '$folderName' \n");
    writeLog($logHandle, "Deployment Failed.\n");


    http_response_code(422);

    exit(1);
}


$source_folder = full_path('public');

$destination_dir = match ($folderName) {
    'instance-site' => '/home/<hostname>/public_html',
    'instance-test' => '/home/<hostname>/',
    'instance-docs' => '/home/<hostname>/',
    default => '/home/<hostname>/'
};

writeLog($logHandle, "Deployment script started. Folder: $folderName \n");

$descriptor = [
    0 => ["pipe", "r"],  // stdin
    1 => ["pipe", "w"],  // stdout
    2 => ["pipe", "w"]   // stderr
];

$command = '/bin/bash deployment.sh ' . escapeshellarg($folderName);


//make sure we retain unix line endings
// exec("sed -i 's/\r$//' deploy.sh");



$process = proc_open($command, $descriptor, $pipes);

if (!is_resource($process)) {
    writeLog($logHandle, "Error: Failed to open process\n");
    displayOutput("Failed to open process", true);
    writeLog($logHandle, "Deployment Failed. Could not run sh script\n");
}
displayOutput("RUNNING DEPLOY.SH", false);


fclose($pipes[0]);  // close unused stdin pipe

$output = stream_get_contents($pipes[1]);
$error = stream_get_contents($pipes[2]);

// close stdout && stderr and wait for the script to finish
fclose($pipes[1]);
fclose($pipes[2]);

$return_value = proc_close($process);

if ($return_value !== 0) {

    writeLog($logHandle, "Error: status $return_value\n");
    writeLog($logHandle, "Standard Error: $error \n");


    displayOutput("Error: status $return_value", true);
    writeLog($logHandle, "DEPLOY.SH FAILED TO DEPLOY: $error \n");

    displayOutput("DEPLOY.SH FAILED TO DEPLOY: \n COPYING ASSESTS USING PHP", true);


    // this is a back up cause bash does not seem like it's copying the front-end assets correctly
    if (move_files($source_folder, $destination_dir)) {
        displayOutput("✓ Success: updated front-end assets");
        writeLog($logHandle, "Success: updated front-end assets at $destination_dir.\n");
    } else {
        displayOutput("✗ Failed to update the new front-end assets from $source_folder", true);
        writeLog($logHandle, "Error: Failed to update the new front-end assets fromt $destination_dir.\n");
        writeLog($logHandle, "Deployment Failed.\n");
    }
}


writeLog($logHandle, "Deployment script completed successfully.\n");

displayOutput($output);


// Close log file
fclose($logHandle);

http_response_code(200);

echo PHP_EOL . PHP_EOL . PHP_EOL;


/*
   -------------------------------------------------
           FUNCTIONS
   -------------------------------------------------
*/

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
    $items = array_diff(scandir($source), ['.', '..', 'index.php']);

    $res = [];

    $success = true;

    foreach ($items as $item) {
        $source_path = $source . DIRECTORY_SEPARATOR . $item; // Use DIRECTORY_SEPARATOR for portability
        $destination_path = $destination . DIRECTORY_SEPARATOR . $item;

        $res[] = "Moving $source_path \n";

        if (is_link($source_path)) {
            $success = $success && symlink(readlink($source_path), $destination_path);

            echo ($success) ? "Symlink Move OK" : "Symlick Move Fail";
        } elseif (is_dir($source_path)) {
            // Create destination directory if it doesn't exist
            if (!file_exists($destination_path)) {
                mkdir($destination_path);
            }
            // Recursively move files within the directory
            $success = $success && move_files($source_path, $destination_path);
        } else {
            $success = $success && copy($source_path, $destination_path);
        }
    }
    displayOutput(implode("\n", $res));
    return $success;
}

/**
 * Concatenate the relative path to the full path of where the laravel application is uplooded
 *
 * @param string $path relative path from the folder where the laravel app is uploaded
 * 
 * @return string full path starting from root
 */
function full_path(string $path): string {
    return LARAVEL_INSTALL_PATH . DIRECTORY_SEPARATOR . $path;
}
/**
 * A helper to write logs to the deployment.log file on the webhooks domainr 
 *
 * @param resource $resource handle for the log file
 * @param string $msg log message to be written
 * 
 * @return void
 */
function writeLog($resource, string $msg): void {
    fwrite($resource, date('Y-m-d H:i:s') . " - $msg");
}

/**
 * Convert ANSI color codes to HTML spans with classes
 */
function convertAnsiToHtml(string $text): string {
    // First clean up any weird character encodings
    $text = preg_replace('/\x1B/', "\033", $text);
    
    // Replace ANSI codes with HTML
    return preg_replace(
        array_keys(ANSI_PATTERNS),
        array_values(ANSI_PATTERNS),
        $text
    );
}

/**
 * Parse timestamp from log line
 */
function parseTimestamp(string $line): ?string {
    if (preg_match('/^\[(\d{2}:\d{2}:\d{2})\]/', $line, $matches)) {
        return $matches[1];
    }
    return null;
}

/**
 * Enhanced display output function with better formatting
 */
function displayOutput(string $output, bool $isError = false): void {
    if (php_sapi_name() === 'cli' || str_contains($_SERVER['HTTP_USER_AGENT'] ?? '', 'curl')) {
        echo $output . PHP_EOL;
        return;
    }
    
    // If we haven't output the HTML header yet, do it now
    if (!defined('HEADER_SENT')) {
        outputHtmlHeader();
        define('HEADER_SENT', true);
    }
    
    // Split output into lines and process each separately
    $lines = explode("\n", $output);
    foreach ($lines as $line) {
        if (empty(trim($line))) continue;
        
        $timestamp = parseTimestamp($line);
        $cleanLine = $timestamp ? substr($line, strlen($timestamp) + 3) : $line;
        $processedLine = convertAnsiToHtml($cleanLine);
        
        $statusClass = '';
        if (strpos($line, '✓') !== false || strpos($line, 'SUCCESS') !== false) {
            $statusClass = 'status-success';
        } elseif (strpos($line, '✖') !== false || strpos($line, 'ERROR') !== false) {
            $statusClass = 'status-error';
        } elseif (strpos($line, 'INFO') !== false) {
            $statusClass = 'status-info';
        } elseif (strpos($line, 'WARNING') !== false) {
            $statusClass = 'status-warning';
        }
        
        echo "<div class='log-entry $statusClass'>";
        if ($timestamp) {
            echo "<span class='timestamp'>[$timestamp]</span>";
        }
        echo "<span class='message'>$processedLine</span>";
        echo "</div>";
    }
}

/**
 * Output the HTML header with styles
 */
function outputHtmlHeader(): void {
    global $folderName;
    ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Deployment Dashboard</title>
        <style>
       :root{--bg-color:#1e1e1e;--text-color:#e0e0e0;--success-color:#4caf50;--error-color:#f44336;--info-color:#2196f3;--warning-color:#ff9800;--header-bg:#2d2d2d;--card-bg:#2d2d2d;--timestamp-color:#666}body{font-family:'SF Mono',Monaco,Consolas,'Liberation Mono','Courier New',monospace;background:var(--bg-color);color:var(--text-color);margin:0;padding:20px;line-height:1.6}.dashboard{max-width:1200px;margin:0 auto}.header{background:var(--header-bg);padding:20px;border-radius:8px;margin-bottom:20px;box-shadow:0 4px 6px rgb(0 0 0 / .1)}.header h1{margin:0;font-size:24px;color:var(--text-color)}.deployment-info{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin-bottom:20px}.info-card{background:var(--card-bg);padding:15px;border-radius:6px;box-shadow:0 2px 4px rgb(0 0 0 / .1)}.log-container{background:var(--card-bg);padding:20px;border-radius:8px;box-shadow:0 4px 6px rgb(0 0 0 / .1);font-size:14px}.log-entry{padding:6px 12px;margin:4px 0;border-radius:4px;display:flex;align-items:flex-start;gap:12px;line-height:1.4}.timestamp{color:var(--timestamp-color);font-size:.9em;white-space:nowrap;min-width:90px}.message{flex:1;white-space:pre-wrap;word-wrap:break-word}.text-red{color:#f44336}.text-green{color:#4caf50}.text-yellow{color:gold}.text-blue{color:#2196f3}.status-success .message{color:var(--success-color)}.status-error .message{color:var(--error-color)}.status-info .message{color:var(--info-color)}.status-warning .message{color:var(--warning-color)}pre{margin:0;white-space:pre-wrap;word-wrap:break-word}
        </style>
    </head>
    <body>
        <div class="dashboard">
            <div class="header">
                <h1>StyleSoup Deployment Dashboard</h1>
            </div>
            <div class="deployment-info">
                <div class="info-card">
                    <strong>Deployment Target:</strong>
                    <div><?php echo $folderName ?? 'Unknown'; ?></div>
                </div>
                <div class="info-card">
                    <strong>Started At:</strong>
                    <div><?php echo date('Y-m-d H:i:s'); ?></div>
                </div>
                <div class="info-card">
                    <strong>Triggered By:</strong>
                    <div><?php echo htmlspecialchars($_SERVER['REMOTE_ADDR'] ?? 'CLI'); ?></div>
                </div>
            </div>
            <div class="log-container">
    <?php
}

/**
 * Output the HTML footer
 */
function outputHtmlFooter(): void {
    ?>
            </div>
        </div>
        <footer>
        <p style="margin-top: 1; color:#e0e0e0; text-align:center;">
            © 2020 - <?= date('Y') ?>
            <a href="mailto:munenenjega@gmail.com" rel="home">Chungu Developers</a> – Automating at Scale...
        </p>
        </footer>
        <script>
        // Auto-scroll to bottom
        const logContainer = document.querySelector('.log-container');
        logContainer.scrollTop = logContainer.scrollHeight;
        
        // Set up auto-refresh
        setInterval(() => {
            logContainer.scrollTop = logContainer.scrollHeight;
        }, 1000);
        </script>
    </body>
    </html>
    <?php
}

// Register shutdown function to output footer
register_shutdown_function(function() {
    if (!php_sapi_name() === 'cli' && !str_contains($_SERVER['HTTP_USER_AGENT'] ?? '', 'curl')) {
        outputHtmlFooter();
    }
});
