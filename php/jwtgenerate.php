<?php

define('APP_KEY', "my_endpoint_token"); // Must match AsterLink's `s.cfg.EndpointToken`


class JWT
{
    private $signing_key;

    public function __construct()
    {
        $this->signing_key = APP_KEY;
    }

    public function encode(array $payload): string
    {
        $header = [
            "alg" => "HS256", // AsterLink uses HMAC (HS256) --see the asterlink repo
            "typ" => "JWT"
        ];

        $encodedHeader = rtrim(strtr(base64_encode(json_encode($header)), '+/', '-_'), '=');
        $encodedPayload = rtrim(strtr(base64_encode(json_encode($payload)), '+/', '-_'), '=');

        $signature = hash_hmac('sha256', "$encodedHeader.$encodedPayload", $this->signing_key, true);
        $encodedSignature = rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');

        return "{$encodedHeader}.{$encodedPayload}.{$encodedSignature}";
    }
}

// Example usage:
$jwtHelper = new JWT();
$token = $jwtHelper->encode([
    'id' => '1', // user who has the extension
    'exp' => time() + 3600 // expiration time (1 hour from now)
]);

echo "JWT Token: " . $token;

