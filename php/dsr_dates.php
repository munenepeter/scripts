<?php

/**
 * Generates a CSV file with dates for a given month and year.
 *
 * Usage:
 * php script.php <month> <year> [-w]
 *
 * Arguments:
 * - month (int): the month to generate dates for (default is the current month)
 * - year (int): the year to generate dates for (default is the current year)
 * - -w (optional): exclude weekends from the generated dates
 */

date_default_timezone_set('UTC');

if ($argc < 3) {
    echo "Usage: php script.php <month> <year> [-w]\n";
    exit(1);
}
$month = (int)$argv[1] ?? date('m');
$year = (int)$argv[2] ?? date('Y');

// check if the -w is set
$excludeWeekends = false;
if (in_array('-w', $argv)) {
    $excludeWeekends = true;
}
$monthName = date('F', mktime(0, 0, 0, $month, 10));
echo  PHP_EOL;
echo "getting dates for $monthName, $year with" . ($excludeWeekends ? "out Weekends..." : " Weekends...") . PHP_EOL;
echo  PHP_EOL;
$numDays = cal_days_in_month(CAL_GREGORIAN, $month, $year);

// Open the output file for writing
$file = fopen(__DIR__ . '/dates.csv', 'w');

$first_day = date('d/m/Y', mktime(0, 0, 0, $month, 1, $year));
for ($i = 1; $i <= $numDays; $i++) {
    // skip weekends if the flag is set
    if ($excludeWeekends && (date('N', mktime(0, 0, 0, $month, $i, $year)) >= 6)) {
        continue;
    }

    // loop five times to output the same day
    for ($j = 1; $j <= 5; $j++) {

        // Format the date as desired
        $date = date('m/d/Y', mktime(0, 0, 0, $month, $i, $year));

        //repeat date 5 times
        for ($k = 1; $k <= 5; $k++) {
            fwrite($file, "$date\n");
        }

        //finally add 'summary' line
        fwrite($file, "Summary\n");
        break;
    }
}
fclose($file);

echo "Output written to dates.csv\n";
