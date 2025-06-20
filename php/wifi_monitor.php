#!/usr/bin/env php
<?php

// Wi-Fi Monitoring Script
// This script monitors the Wi-Fi connection status, speed, duration, and internet access.

$ssid = "Redian Software";
function checkWifiStatus($ssid) {
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        
        $output = shell_exec("netsh wlan show interfaces");
        if (strpos($output, $ssid) !== false) {
            return [
                'status' => 'Connected',
                'speed' => extractSpeedFromNetsh($output),
                'duration' => extractDurationFromNetsh($output),
            ];
        } else {
            return ['status' => 'Disconnected'];
        }
    } else {
        
        $output = shell_exec("nmcli -t -f NAME,DEVICE,STATE,ACTIVE,TIMESTAMP connection show --active");
        if (strpos($output, $ssid) !== false) {
            return [
                'status' => 'Connected',
                'speed' => extractSpeedFromNmcli($output),
                'duration' => extractDurationFromNmcli($output),
            ];
        } else {
            return ['status' => 'Disconnected'];
        }
    }
}
function extractSpeedFromNetsh($output) {
    preg_match('/Receive rate \(Mbps\)\s*:\s*(\d+)/', $output, $matches);
    return $matches[1] ?? 'N/A';
}
function extractDurationFromNetsh($output) {
    preg_match('/Duration\s*:\s*(\d+:\d+:\d+)/', $output, $matches);
    return $matches[1] ?? 'N/A';
}
function extractSpeedFromNmcli($output) {
    $output = shell_exec("nmcli -t -f ACTIVE,RATE dev wifi");
    preg_match('/yes:(\d+)/', $output, $matches);
    return $matches[1] ?? 'N/A';
}
function extractDurationFromNmcli($output) {
    preg_match('/:(\d+)$/', $output, $matches);
    if (isset($matches[1])) {
        $seconds = time() - $matches[1];
        return gmdate("H:i:s", $seconds);
    }
    return 'N/A';
}
function checkInternetAccess() {
    $host = '8.8.8.8'; 
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $command = "ping -n 1 $host";
    } else {
        $command = "ping -c 1 $host";
    }
    exec($command, $output, $result);
    return $result === 0;
}
function reconnectToWifi($ssid) {
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        
        shell_exec("netsh wlan disconnect");
        shell_exec("netsh wlan connect name=\"$ssid\"");
    } else {
        
        shell_exec("nmcli connection up \"$ssid\"");
    }
}
function sendNotification($message) {
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        
        shell_exec("powershell -command \"[reflection.assembly]::loadwithpartialname('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$message', 'Wi-Fi Status')\"");
    } else {
        
        shell_exec("notify-send 'Wi-Fi Status' '$message'");
    }
    echo $message . PHP_EOL;
}
function generateHtmlReport($ssid, $status, $speed, $duration, $internetAccess) {
    $class1 = $status === 'Connected' ? 'bg-green-500' : 'bg-red-500';
    $class2 = $internetAccess ? 'bg-green-500' : 'bg-red-500';    $internet = $internetAccess ? 'Yes' : 'No';    $html = <<<HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Wi-Fi Status Report</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 flex items-center justify-center h-screen">
        <div class="bg-white p-8 rounded-lg shadow-lg text-center">
            <h1 class="text-2xl font-bold mb-4">Wi-Fi Status Report</h1>
            <p class="text-lg"><span class="font-semibold">SSID:</span> $ssid</p>
            <p class="text-lg"><span class="font-semibold">Status:</span> <span class="$class1">$status</span></p>
            <p class="text-lg"><span class="font-semibold">Speed:</span> $speed Mbps</p>
            <p class="text-lg"><span class="font-semibold">Duration:</span> $duration</p>
            <p class="text-lg"><span class="font-semibold">Internet Access:</span> <span class="$class2">$internet</span></p>
            <div class="mt-6">
                <a href="/" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">Refresh</a>
            </div>
        </div>
    </body>
    </html>
    HTML;
    file_put_contents("index.html", $html);
}
function startHttpServer() {
    $port = 8080;
    
    echo "Starting HTTP server on http: //localhost:$port" . PHP_EOL;

    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        pclose(popen("start php -S localhost:$port -t " . __DIR__, "r"));
    } else {
        shell_exec("nohup php -S localhost:$port -t " . __DIR__ . " > /dev/null 2>&1 &");
    }
}
startHttpServer();

echo "Starting Wi-Fi monitoring for SSID: $ssid" . PHP_EOL;

while (true) {
    $wifiStatus = checkWifiStatus($ssid);
    $status = $wifiStatus['status'];
    $speed = $wifiStatus['speed'] ?? 'N/A';
    $duration = $wifiStatus['duration'] ?? 'N/A';
    $internetAccess = checkInternetAccess();
    $lastCheck = date("Y-m-d H:i:s");    
    generateHtmlReport($ssid, $status, $speed, $duration, $internetAccess);    if ($status === "Disconnected") {
        $message = "Wi-Fi '$ssid' is disconnected! Attempting to reconnect...";
        sendNotification($message);
        reconnectToWifi($ssid);
    } else {
        echo "Wi-Fi '$ssid' is connected. Speed: $speed Mbps, Duration: $duration, Internet Access: " . ($internetAccess ? 'Yes' : 'No') . PHP_EOL;
    }    
    sleep(10);
}