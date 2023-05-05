<?php

$str1 = "Hello world";
$str2 = "world Hello";



function getrev($s){
    $new = str_split($s);
    asort($new);
   return implode("",$new); 
}

function getOriginal($r){
    $new = str_split($r);
    arsort($new);
    return implode("",$new);
}

echo getrev($str1);
echo PHP_EOL;
echo getOriginal($str1);
echo PHP_EOL;
echo getrev($str2);
echo PHP_EOL;
echo getOriginal($str2);
