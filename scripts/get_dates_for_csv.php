<?php
/**
 * This script generates a schedule file for a given month and year,
 * with five entries per day for each of five people.
 *
 * Usage: php script.php <month> <year>
 */

// Set the timezone
date_default_timezone_set('UTC');

// Get the month and year from the command line arguments
if ($argc < 3) {
    echo "Usage: php script.php <month> <year>\n";
    exit(1);
}
$month = (int)$argv[1];
$year = (int)$argv[2];

// Get the number of days in the month
$numDays = cal_days_in_month(CAL_GREGORIAN, $month, $year);

// Open the output file for writing
$file = fopen(__DIR__ . '/dates.csv', 'w');

$first_day = date('d/m/Y', mktime(0, 0, 0, $month, 1, $year));

// Loop through the days of the month
for ($i = 1; $i <= $numDays; $i++) {

    // Loop five times to output the same day
    for ($j = 1; $j <= 5; $j++) {

        // Format the date as desired
        $date = date('d/m/Y', mktime(0, 0, 0, $month, $i, $year));

        // Write the output to the file
        fwrite($file, "$date\t$first_day\tCarter\n");
        fwrite($file, "$date\t$first_day\tMaxwell\n");
        fwrite($file, "$date\t$first_day\tPeter\n");
        fwrite($file, "$date\t$first_day\tSamuel\n");
        fwrite($file, "$date\t$first_day\tDan\n");
        break;
    }
}

// Close the output file
fclose($file);

echo "Output written to dates.csv\n";



