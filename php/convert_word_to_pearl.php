<?php

/**
 * 
 * The script reads a text file called "pearls.txt" which contains a list of keywords separated by commas. It then removes any 
 *  whitespace characters around the keywords and removes any duplicates.

 * For each unique keyword, the script generates a random RGB color code using the getRandColor() function. It then creates an 
 *  associative array for each keyword containing the keyword itself and its corresponding color code.

 * Finally, the script writes each keyword-color pair to a file called "kw.txt" in JSON format, with each line representing a single 
 *  keyword-color object.

 * Overall, the script's purpose is to assign a random color to each keyword in the input file and store the pairs for future use.
 */


function getRandColor() {
    return sprintf('rgb(%d,%d,%d)', rand(0, 255), rand(0, 255), rand(0, 255));
}

$text = file_get_contents("pearls.txt");
$kw = array_map('trim', explode(",", $text));
$kq = array_unique($kw);

$result = array_map(function($value) {
    return ['word' => $value, 'color' => getRandColor()];
}, $kq);

file_put_contents("kw.txt", json_encode($result, JSON_PRETTY_PRINT));
