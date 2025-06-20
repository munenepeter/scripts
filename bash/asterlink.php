<?php 
define('PHONE', 6001);
define('ENDPOINT', 'http://127.0.0.1:5678');
define('ASTERLINK_TOKEN', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEiLCJleHAiOjE3NDA1NTU3OTd9.MMmN9fEfl3Z3tbqtRFpmTqBEs_kkM3NiTMiVVuu2-3Y');

$url = ENDPOINT . '/originate';
$ch = curl_init();

// Enable verbose output for debugging
$verbose = fopen('php://temp', 'w+');

curl_setopt_array($ch, [
    CURLOPT_URL => $url,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query(['phone' => PHONE]),
    CURLOPT_HTTPHEADER => ['X-AsterLink-Token: ' . ASTERLINK_TOKEN],
    CURLOPT_RETURNTRANSFER => true, // Capture response
    CURLOPT_HEADER => true, // Include headers in response
    CURLOPT_VERBOSE => true, // Enable verbose output
    CURLOPT_STDERR => $verbose, // Log verbose output
    CURLOPT_CONNECTTIMEOUT => 10
]);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$last_err = curl_error($ch);
$info = curl_getinfo($ch);
curl_close($ch);

// Retrieve verbose debug output
rewind($verbose);
$verbose_log = stream_get_contents($verbose);
fclose($verbose);

// Display results
echo "=== cURL Request Debug Info ===\n";
echo "Request URL: " . $url . "\n";
echo "HTTP Code: " . ($http_code ?: 'N/A') . "\n";
echo "cURL Error: " . ($last_err ?: 'None') . "\n";
echo "\n=== Response Headers & Body ===\n";
echo $response ?: 'No response received';
echo "\n\n=== cURL Debug Log ===\n";
echo $verbose_log;
echo "\n\n=== cURL Full Info ===\n";
//print_r($info);
