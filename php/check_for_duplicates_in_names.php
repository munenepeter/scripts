<?php

/**
 * 
 * 
 * The script reads a file called "names.txt" that contains a list of names. It then checks each name in the list to see if it has any 
 *  duplicates.

 * To check for duplicates, the script first splits each name into words and then tries to match each possible prefix of the name with 
 * the suffix of other names. If it finds a match, it adds the two names to a list of duplicates.

 * Finally, the script outputs the duplicates in a table format with two columns: "Prefix" and "Names". The Prefix column shows the 
 * common prefix of the duplicate names, and the Names column shows the actual names separated by commas.

 *  Note that the script only considers names that have two or more consecutive duplicate words. For example, if the names "Official 
 *  Gazette of the Argentine Republic" and "Gazette Official of the Republic of Turkey" are in the list, the script will not consider 
 *  them duplicates because they do not have two or more consecutive duplicate words.
 * 
 * 
 */

$names = file("names.txt", FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

$duplicates = [];

$total = count($names);
$count = 0;

foreach ($names as $name) {
    $count++;
    echo "Checking $count/$total: $name";
    $words = explode(" ", $name);
    $length = count($words);
    for ($i = 1; $i < $length; $i++) {
        $prefix = implode(" ", array_slice($words, 0, $i));
        if (!isset($duplicates[$prefix])) {
            $duplicates[$prefix] = [];
        }
        $suffix = implode(" ", array_slice($words, $i));
        if (in_array($suffix, $duplicates[$prefix])) {
            continue;
        }
        foreach ($names as $other) {
            if ($other === $name) {
                continue;
            }
            if (strpos($other, $prefix) === 0) {
                $otherWords = explode(" ", $other);
                $otherSuffix = implode(" ", array_slice($otherWords, $i));
                if ($suffix === $otherSuffix) {
                    $duplicates[$prefix][] = $other;
                    $duplicates[$prefix][] = $name;
                    echo " -----> Duplicate" . PHP_EOL;
                    break;
                }
            }
        }
    }
    echo PHP_EOL;
}

// Output duplicates in a table
echo "Duplicates:\n";
echo "+--------------+----------------------------------------------+\n";
echo "| Prefix       | Names                                        |\n";
echo "+--------------+----------------------------------------------+\n";
foreach ($duplicates as $prefix => $names) {
    $count = count($names);
    if ($count >= 2) {
        echo "| " .
            str_pad($prefix, 12) .
            " | " .
            str_pad(implode(", ", $names), 44) .
            " |\n";
    }
}
echo "+--------------+----------------------------------------------+\n";
