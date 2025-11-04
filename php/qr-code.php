<?php

require __DIR__ . '/vendor/autoload.php';

use Endroid\QrCode\Builder\Builder;
use Endroid\QrCode\Encoding\Encoding;
use Endroid\QrCode\ErrorCorrectionLevel;
use Endroid\QrCode\RoundBlockSizeMode;
use Endroid\QrCode\Writer\PngWriter;


$documents = [
    [
        'title' => 'Legal Notice 178 of 2023',
        'url' => 'https://new.kenyalaw.org/akn/ke/act/ln/2023/178/eng@2023-12-22'
    ],

    [
        'title' => 'Legal Notice 188 of 2011',
        'url' => 'https://new.kenyalaw.org/akn/ke/act/ln/2011/188/eng@2022-12-31'
    ],

    [
        'title' => 'Legal Notice 95 of 2010',
        'url' => 'https://new.kenyalaw.org/akn/ke/act/ln/2010/95/eng@2022-12-31'
    ],

    [
        'title' => 'Legal Notice 82 of 2020',
        'url' => 'https://new.kenyalaw.org/akn/ke/act/ln/2020/82/eng@2022-12-31'
    ]
];
$outputDir = __DIR__ . '/qr/clean';
if (!is_dir($outputDir)) {
    mkdir($outputDir, 0777, true);
}

foreach ($documents as $doc) {
    $title = $doc['title'];
    $url   = $doc['url'];

    $filename = preg_replace('/[^a-z0-9_\-]+/i', '_', strtolower($title)) . '.png';
    $filePath = $outputDir . '/' . $filename;

    $builder = new Builder(
        writer: new PngWriter(),
        writerOptions: [],
        validateResult: false,
        data: $url,
        encoding: new Encoding('UTF-8'),
        errorCorrectionLevel: ErrorCorrectionLevel::High,
        size: 300,
        margin: 10,
        roundBlockSizeMode: RoundBlockSizeMode::Margin,
        // labelText: $title,
        // labelFont: new OpenSans(16),
        // labelAlignment: LabelAlignment::Center
    );

    $result = $builder->build();

    $result->saveToFile($filePath);

    echo "generated qr for '{$title}' -> {$filePath}\n";
}
