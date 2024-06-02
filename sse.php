<?php
function file_changed(string $filePath): bool {
    if (!file_exists($filePath)) {
        return false; 
    }
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    $sessionKey = "last_modified_" . $filePath;
    if (!isset($_SESSION[$sessionKey])) {
        $_SESSION[$sessionKey] = filemtime($filePath);
    }
    $last_modified_time = $_SESSION[$sessionKey];

    if ($last_modified_time === false) {
        $last_modified_time = filemtime($filePath);
    }

    return filemtime($filePath) !== $last_modified_time;
}

function logger(string $level, string $message) {
    return new class($level, $message) {

        private static $filename = __DIR__ . '/logs.log';

        public function __construct($level, $message) {
            $this->setLog($message, $level);
        }
        public static function save($log) {

            if (!file_exists(self::$filename)) {
                touch(self::$filename);
            }
            return file_put_contents(self::$filename, $log, FILE_APPEND);
        }
        private static function setLog($message, $level = "Info") {

            // $message .= json_encode($_REQUEST, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT) . "\t\t";
            // $message .= json_encode($_SERVER, JSON_PRETTY_PRINT | JSON_FORCE_OBJECT) . "\t";

            $log = sprintf(
                "[%s]\t%s\t%s\n",
                date('Y-m-d H:i:s'),
                strtolower($level),
                $message
            );
            self::save($log);
        }
    };
}
logger('Info', 'This is an informational message.');
function handleSocketConnection($socket) {
    logger('Info', "Started listening");

     if (file_changed(__DIR__ . '/index.html')) {
        $message = "reload";
        socket_write($socket, $message, strlen($message));
    }
    socket_close($socket);
}

$port = 8080; 

$server = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
if (!$server) {
    logger('Info', "socket_create() failed: " . socket_last_error());
    die("socket_create() failed: " . socket_last_error());
}

logger('Info', "socket_create() success");


if (!socket_bind($server, "0.0.0.0", $port)) {
    logger('Info', "socket_bind() failed: " . socket_last_error());
    die("socket_bind() failed: " . socket_last_error());
}

if (!socket_listen($server, 10)) {
    logger('Info', "socket_listen() failed: " . socket_last_error());
    die("socket_listen() failed: " . socket_last_error());
}

echo "Server started on port $port\n";

while (true) {
    $client = socket_accept($server);
    if ($client) {
        handleSocketConnection($client);
    }
}

socket_close($server);

