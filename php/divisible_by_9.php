<?php


//number - (it's digits)


///89 - 8 and 9


function getDigits(int $number): array {
    $digits = [];

    for ($i = 0; $i < strlen((string)$number); $i++)
        $digits[] = (int)substr((string)$number, $i, 1);

    return $digits;
}

function testDivisiblity(int $number, array $digits): array {
    $op = "$number-" . implode('-', $digits);

    $val = 0;

    eval("\$val = $op;");

    $op = $op . "=$val";

    $isDivisible = 'FALSE';

    if ($val % 9 === 0) {
        $isDivisible = 'TRUE';
    }


    return [$op, $isDivisible];
}

$number = 0;

while ($number < PHP_INT_MAX) {
    $digits = getDigits($number);

    [$op, $isDivisible] = testDivisiblity($number, $digits);

    printf("Number: %d\tdigits: %s\tOperation: %s\tDivisible: %s\n", $number, implode(',', $digits), $op, $isDivisible);

    $number++;
}
