<?php
/**
 * Generates a CSV file with dates for a given month and year.
 * with five entries per day for each of five people.
 * Usage:
 * php script.php <month> <year> [-w]
 *
 * Arguments:
 * - month (int): the month to generate dates for (default is the current month)
 * - year (int): the year to generate dates for (default is the current year)
 * - -w (optional): exclude weekends from the generated dates
 */

// Set the timezone
date_default_timezone_set('UTC');

// Get the month and year from the command line arguments
if ($argc < 3) {
    echo "Usage: php script.php <month> <year> [-w]\n";
    exit(1);
}
$month = (int)$argv[1] ?? date('m');
$year = (int)$argv[2] ?? date('Y');

// Check if the -w flag is set
$excludeWeekends = false;
if (in_array('-w', $argv)) {
    $excludeWeekends = true;
}

// Get the number of days in the month
$numDays = cal_days_in_month(CAL_GREGORIAN, $month, $year);

// Open the output file for writing
$file = fopen(__DIR__ . '/dates.csv', 'w');

$first_day = date('d/m/Y', mktime(0, 0, 0, $month, 1, $year));
// Loop through the days of the month
for ($i = 1; $i <= $numDays; $i++) {
    // Skip weekends if the flag is set
    if ($excludeWeekends && (date('N', mktime(0, 0, 0, $month, $i, $year)) >= 6)) {
        continue;
    }
   
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
