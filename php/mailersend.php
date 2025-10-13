<?php

$tokenFile = 'access_token.txt';
if (!file_exists($tokenFile)) {
    die("Error: token.txt file not found in current directory.\n");
}

$token = trim(file_get_contents($tokenFile));
if (empty($token)) {
    die("Error: token.txt file is empty or contains only whitespace.\n");
}

$emailData = [
    "subject" => "Job Application - PHP Engineer",
    "from" => [
        "email" => "test@test-zxk54v8wyq1^^^&^&&&&&&&&&&&&jy6v.mlsender.net"
    ],
    "to" => [
        [
            "email" => "apply@mailerlite.recruitee.com"
        ]
    ],
    "personalization" => [
        [
            "email" => "apply@mailerlite.recruitee.com",
            "data" => [
                "url" => ""
            ]
        ]
    ],
    "template_id" => "z86org8odqz4ew13"
];

$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_URL => 'https://api.mailersend.com/v1/email',
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => json_encode($emailData),
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'X-Requested-With: XMLHttpRequest',
        'Authorization: Bearer ' . $token
    ],
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT => 30,
    CURLOPT_SSL_VERIFYPEER => true,
    CURLOPT_SSL_VERIFYHOST => 2
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);

curl_close($ch);

if ($response === false) {
    die("cURL Error: " . $curlError . "\n");
}

echo "HTTP Status Code: " . $httpCode . "\n";
echo "Response: " . $response . "\n";

if ($httpCode >= 200 && $httpCode < 300) {
    echo "Email sent successfully!\n";
} else {
    echo "Error sending email. Check the response above for details.\n";
    exit(1);
}

?>