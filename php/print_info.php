<?php


function print_out_apache_sites() {
    $filename = 'server_configuration.txt';

    if (!file_exists($filename)) touch($filename);

    $output = "\n\nCurrent Apache Sites\n";
    $output .= "======================================================================\n";
    $output .= shell_exec('apachectl -S');
    file_put_contents($filename, $output, FILE_APPEND);


    $path = '/etc/apache2/sites-enabled/';
    $output = "\n\nCurrent Apache Sites in " . $path . "\n";
    $output .= "======================================================================\n";
    $output .= shell_exec('ls -l ' . $path);
    file_put_contents($filename, $output, FILE_APPEND);

    $enabled_subdomains = [
        'demo-redian-crm',
    ];

    //get apache config for each subdomain
    foreach ($enabled_subdomains as $subdomain) {
        $output = "\n\nCurrent Apache Config for " . $subdomain . "\n";
        $output .= "======================================================================\n";
        $output .= file_get_contents('/etc/apache2/sites-enabled/' . $subdomain . '.conf');
        file_put_contents($filename, $output, FILE_APPEND);
    }
}

function print_out_sys_info() {
    // Get PHP and server information
    $serverInfo = [
        'PHP Version' => PHP_VERSION,
        'PHP SAPI' => php_sapi_name(),
        'Server Software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
        'Server OS' => PHP_OS,
        'Server OS Family' => PHP_OS_FAMILY,
        'Server Architecture' => php_uname('m'),
        'PHP Memory Limit' => ini_get('memory_limit'),
        'PHP Max Execution Time' => ini_get('max_execution_time') . ' seconds',
        'PHP Max Input Time' => ini_get('max_input_time') . ' seconds',
        'PHP Upload Max Filesize' => ini_get('upload_max_filesize'),
        'PHP Post Max Size' => ini_get('post_max_size'),
        'PHP Max Input Vars' => ini_get('max_input_vars'),
        'Timezone' => date_default_timezone_get(),
    ];

    // Get loaded extensions
    $extensions = get_loaded_extensions();
    sort($extensions);

    $extensionsInfo = array_map(function ($ext) {
        return "- $ext (version: " . phpversion($ext) . ")";
    }, $extensions);

    // Format the output
    $output = "Server Configuration Details\n";
    $output .= "Generated: " . date('Y-m-d H:i:s') . "\n\n";

    $output .= "Server Information:\n";
    $output .= "==================\n";
    foreach ($serverInfo as $key => $value) {
        $output .= sprintf("%-25s: %s\n", $key, $value);
    }

    $output .= "\nLoaded PHP Extensions:\n";
    $output .= "=====================\n";
    $output .= implode("\n", $extensionsInfo);

    $filename = 'server_configuration.txt';

    if (!file_exists($filename)) touch($filename);

    file_put_contents($filename, $output);
    // Get last 20 lines from error log - check common log locations
    $possibleLogs = [
        '/var/log/php/error.log',
        '/var/log/apache2/error_demo-redian-crm.log',
        '/var/log/apache2/error.log',
        '/var/log/httpd/error.log',
        '/var/log/php-fpm/error.log',
        // '/var/log/apache2/error_demo-redian-crm-ssl.log',
        ini_get('error_log'),
    ];

    $errorLog = null;
    foreach ($possibleLogs as $logPath) {
        if ($logPath && file_exists($logPath) && is_readable($logPath)) {
            $errorLog = $logPath;
            break;
        }
    }

    if ($errorLog) {
        $errorLines = [];
        $handle = fopen($errorLog, 'r');
        if ($handle) {
            // Get file size and seek to end minus 4KB
            fseek($handle, -4096, SEEK_END);

            // Discard first incomplete line
            fgets($handle);

            // Read all lines
            while (!feof($handle)) {
                $errorLines[] = fgets($handle);
            }
            fclose($handle);

            // Get last 20 lines
            $lastLines = array_slice($errorLines, -70);

            // Append to configuration file
            file_put_contents($filename, "\n\nLast 70 lines from error log ($errorLog):\n", FILE_APPEND);
            file_put_contents($filename, "==========================\n", FILE_APPEND);
            file_put_contents($filename, implode('', $lastLines), FILE_APPEND);
        }
    } else {
        file_put_contents($filename, "\n\nNo readable error log found in common locations\n", FILE_APPEND);
    }

    // Set appropriate permissions
    chmod($filename, 0644);
}

function print_out_RL_Lead_Finder_info() {

    $filename = 'server_configuration.txt';

    if (!file_exists($filename)) touch($filename);

    $output = "\n\nINDEX.PHP FILE\n";
    $output .= "======================================================================\n";

    $lead_finder_filename = 'modules/RL_Lead_Finder/controller.php';

    $output = "\n\nAPACHE CONFIGURATION\n";
    $output .= "======================================================================\n";

    if (!file_exists($lead_finder_filename)) {
        $output .= "RL Lead Finder Controller not found\n";
    } else {
        $output .= file_get_contents($lead_finder_filename);
        $folder_name = 'modules/RL_Lead_Finder';
        $folder_permissions = substr(sprintf('%o', fileperms($folder_name)), -4);
        $output .= "\n\nRL Lead Finder Folder Permissions: " . $folder_permissions . "\n";
    }


    $index_file = "index.php";
    $output .= file_get_contents($index_file);

    file_put_contents($filename, $output, FILE_APPEND);
}

function add_error_display_in_index_php() {
    try {
        $index_file = "index.php";

        // Read the current content
        $content = file_get_contents($index_file);

        // PHP code to be added at the beginning of the file
        $error_config = "<?php\nini_set('display_errors', 1);\nerror_reporting(E_ALL);\n\n";

        // Check if the file already contains these settings
        if (strpos($content, 'ini_set(\'display_errors\'') === false) {
            // Remove opening PHP tag if it exists
            $content = preg_replace('/^<\?php\s+/', '', $content);

            // Add our error configuration at the start
            $content = $error_config . $content;

            // Write the modified content back to the file
            if (file_put_contents($index_file, $content) === false) {
                throw new Exception("Failed to write to index.php");
            }
        }

        return true;
    } catch (Exception $e) {
        logMessage('Error adding error display configuration: ' . $e->getMessage());
        return false;
    }
}


function remove_error_display_in_index_php() {
    try {
        $index_file = "index.php";

        // Read the current content
        $content = file_get_contents($index_file);

        // Remove the error configuration if it exists
        $content = preg_replace(
            '/^\s*<\?php\s*ini_set\(\'display_errors\',\s*1\);\s*error_reporting\(E_ALL\);\s*\n*/i',
            '<?php' . PHP_EOL,
            $content
        );

        // Write the modified content back to the file
        if (file_put_contents($index_file, $content) === false) {
            throw new Exception("Failed to write to index.php");
        }

        logMessage("Successfully removed error display configuration from index.php");
        return true;
    } catch (Exception $e) {
        logMessage('Error removing error display configuration: ' . $e->getMessage());
        return false;
    }
}
