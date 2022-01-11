<?php
//This file contains all my tests and exercises done at https://exercism.org/tracks/php/
//this is just for reference for future me 


/*
---------------------------------------------------------------------------
The classical introductory exercise. Just say "Hello, World!".

"Hello, World!" is the traditional first program for beginning programming in a new language or environment.

The objectives are simple:

Write a function that returns the string "Hello, World!".
Run the test suite and make sure that it succeeds.
Submit your solution and check it at the website.
----------------------------------------------------------------------------
*/


function helloWorld():String{
  
    return "Hello, World!";
}
helloWorld();

/*
---------------------------------------------------------------------------
Reverse a string

For example: input: "cool" output: "looc"
----------------------------------------------------------------------------
*/

function reverseString(string $text): String{
  
    return strrev($text);
}
reverseString("cool");

/*
---------------------------------------------------------------------------
Your task is to build a high-score component of the classic Frogger game, 
one of the highest selling and addictive games of all time,and a classic of the arcade era.
Your task is to write methods that return the highest score from the list,
the last added score and the three highest scores.
updated at 11.01.2022
----------------------------------------------------------------------------
*/

class HighScores{
  
public array $scores = [];
public mixed $latest;
public mixed $personalBest;
public array $personalTopThree;
  
public function __construct(array $scores):void{
  
 $this->scores = $scores;
}
public function latest():mixed{
  
$this->latest = end($this->scores);
  
}
public function personalBest():mixed{
  
$this->personalBest =  max($this->scores);
  
}
public function personalTopThree():array{
  
 rsort($this->scores);
 return array_splice($this->scores, 0, 2);
  
}
}

