<?php

/**
 * 
 * Checking if there would be a duplicate on a uniqid()
 */

// $i = 0;
// while ($i < 100000) {

//     $str[] = uniqid();
//     echo $str[$i]. " index => $i". PHP_EOL ;


//     if (count(array_unique($str)) < count($str)) {
//         echo "We've a duplicate of " . $str[$i] . " with only ". $i+1 ." strings";
//         break;
//     }

//     $i++;
// }


$i = 0;
$last_id = '';
while ($i < 100000) {

    $id = uniqid();
    echo "$id index => $i" . PHP_EOL;

    if ($id === $last_id) {
        echo "We have a duplicate of $id with only " . ($i + 1) . " strings" . PHP_EOL;
        break;
    }

    $last_id = $id;
    $i++;
}

