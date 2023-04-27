<?php

/**
 * 
 * In general the script takes in a text file with some keywords and assigns each and every keyword a color based on RGB
 */

function getRandColor() {
    $rgbColor = [];
    foreach (['r', 'g', 'b'] as $color) {
        //Generate a random number between 0 and 255.
        $rgbColor[$color] = mt_rand(0, 255);
    }
    $colorCode = implode(",", $rgbColor);
    return "rgb($colorCode)";
}

//change to file

$text = trim(file_get_contents("pearls.txt"));



$kw = explode(",", $text);



$kw = array_map(function ($v) {
    return trim($v);
}, $kw);

$kq = array_unique($kw);

$n = [];

foreach ($kq as $key => $value) {
    $n[] = [
        'word' => $value,
        'color' => getRandColor()
    ];
}

//$n = array_unique($n);

foreach ($n as $key) {
    file_put_contents("kw.txt", json_encode($key). PHP_EOL, FILE_APPEND | LOCK_EX);
}