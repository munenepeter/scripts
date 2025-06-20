<?php
$startMonth = '2025-01';
$endMonth = '2025-12';

$csvFile = 'working_days.csv';

$output = "Month\tWeek\tStart Date\tEnd Date\n";

$currentDate = new DateTime("$startMonth-01");

$endDate = new DateTime("$endMonth-01");

$endDate->modify('last day of this month');

while ($currentDate <= $endDate) {
    $month = $currentDate->format('M Y');
    $monthStart = clone $currentDate;

    $monthStart->modify('last Monday of previous month');

    $monthEnd = new DateTime($currentDate->format('Y-m-t'));

    $monthEnd->modify('next Friday');

    $weekNumber = 1;
    $weekStartDate = clone $monthStart;

    while ($weekStartDate <= $monthEnd) {
        $weekEndDate = clone $weekStartDate;
        $weekEndDate->modify('+4 days');
        if ($weekEndDate->format('m') !== $currentDate->format('m')) {
            $weekEndDate = clone $monthEnd;
        }
        if ($weekStartDate->format('m') === $currentDate->format('m')) {
            for ($i = 0; $i < 5; ++$i) {
                $output .= "$month\tWeek $weekNumber\t" . $weekStartDate->format('Y-m-d') . "\t" . $weekEndDate->format('Y-m-d') . "\n";
            }
            $weekNumber++;
        }
        $weekStartDate->modify('+7 days');
    }
    $output .= "\n";
    
    print $output;

    $currentDate->modify('first day of next month');
}
file_put_contents($csvFile, $output);

echo "created: $csvFile\n";
