<?php

$filePath = 'C:\Users\Peter\laragon\www\scripts\php\samples\tender-sample.pdf';
$pdftotextPath = 'C:\Users\Peter\Software\xpdf-tools-win-4.05\xpdf-tools-win-4.05\bin64\pdftotext.exe';
$outputFile = 'output.txt';

// Debug: Check file and binary existence
echo "=== DEBUG INFORMATION ===\n";
echo "PDF File: " . (file_exists($filePath) ? "EXISTS (" . filesize($filePath) . " bytes)" : "MISSING") . "\n";
echo "PDF Tool: " . (file_exists($pdftotextPath) ? "EXISTS" : "MISSING") . "\n";

// Use file-based approach instead of stream handling
$command = escapeshellarg($pdftotextPath) . " -layout " . escapeshellarg($filePath) . " " . escapeshellarg($outputFile);
echo "Executing: $command\n";

// Execute the command
exec($command, $output, $returnCode);

echo "Return code: $returnCode\n";

if ($returnCode !== 0) {
    die("Error: pdftotext failed with return code $returnCode\n");
}

if (!file_exists($outputFile)) {
    die("Error: Output file was not created\n");
}

// Read the extracted content
$stdoutContent = file_get_contents($outputFile);
$fileSize = filesize($outputFile);

echo "Extracted $fileSize bytes\n";
echo "First 200 characters of output:\n" . substr($stdoutContent, 0, 200) . "...\n";

// Process the content
$pages = explode("\f", $stdoutContent);
echo "Number of pages detected: " . count($pages) . "\n";

$tenderData = [
    'submission_dates' => []
];

foreach ($pages as $pageNumber => $pageContent) {
    $actualPageNumber = $pageNumber + 1; // Convert from 0-based to 1-based
    if (!empty(trim($pageContent))) {
        // Check for submission deadline (case-insensitive)
        if (stripos($pageContent, 'submission deadline') !== false) {
            $tenderData['submission_dates'][] = [
                'page' => $actualPageNumber,
                'content' => trim($pageContent)
            ];
        }
        
        // You can add more extraction patterns here:
        // Example: Check for tender opening dates
        if (stripos($pageContent, 'tender opening') !== false) {
            if (!isset($tenderData['tender_opening'])) {
                $tenderData['tender_opening'] = [];
            }
            $tenderData['tender_opening'][] = [
                'page' => $actualPageNumber,
                'content' => trim($pageContent)
            ];
        }
        
        // Example: Check for procurement references
        if (stripos($pageContent, 'tender no') !== false || stripos($pageContent, 'reference') !== false) {
            if (!isset($tenderData['references'])) {
                $tenderData['references'] = [];
            }
            $tenderData['references'][] = [
                'page' => $actualPageNumber,
                'content' => trim($pageContent)
            ];
        }
    }
}

// Clean up the temporary file
unlink($outputFile);

echo "\n=== TENDER DATA EXTRACTION RESULTS ===\n";

// Display submission dates
if (!empty($tenderData['submission_dates'])) {
    echo "Submission Dates Found:\n";
    foreach ($tenderData['submission_dates'] as $index => $submissionDate) {
        echo ($index + 1) . ". Page {$submissionDate['page']}:\n";
        echo "   " . wordwrap($submissionDate['content'], 70, "\n   ") . "\n\n";
    }
} else {
    echo "No submission deadlines found in the PDF\n";
}

// Display other extracted data if found
if (!empty($tenderData['tender_opening'])) {
    echo "\nTender Opening Dates Found:\n";
    foreach ($tenderData['tender_opening'] as $index => $opening) {
        echo ($index + 1) . ". Page {$opening['page']}:\n";
        echo "   " . wordwrap($opening['content'], 70, "\n   ") . "\n\n";
    }
}

if (!empty($tenderData['references'])) {
    echo "\nReferences/Tender Numbers Found:\n";
    foreach ($tenderData['references'] as $index => $reference) {
        echo ($index + 1) . ". Page {$reference['page']}:\n";
        echo "   " . wordwrap($reference['content'], 70, "\n   ") . "\n\n";
    }
}

// Show summary
echo "\n=== EXTRACTION SUMMARY ===\n";
echo "Total pages processed: " . count($pages) . "\n";
echo "Submission deadlines found: " . count($tenderData['submission_dates']) . "\n";
echo "Tender opening dates found: " . (isset($tenderData['tender_opening']) ? count($tenderData['tender_opening']) : 0) . "\n";
echo "References found: " . (isset($tenderData['references']) ? count($tenderData['references']) : 0) . "\n";

// Save results to JSON file for later use
file_put_contents('tender_results.json', json_encode($tenderData, JSON_PRETTY_PRINT));
echo "Results saved to tender_results.json\n";


exec('start tender_results.json'); // Open the JSON file automatically on Windows

?>