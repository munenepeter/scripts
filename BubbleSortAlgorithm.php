<?php
//Initialize the array to be sorted
$arr = [9, 8, 7, 6, 5, 4, 3];

//create a function to sort the array

function bubble($arr){
  //count the number of elements in the array
$length = count($arr);
  
  for($i=0; $i < $length; $i++){
      
      for($j=0; $j < $length - 1; $j++){
              
              if($arr[$j] > $arr[$j + 1]){
                              
                 $temp = $arr[$j + 1];
                 $arr[$j + 1] = $arr[$j];
                 $arr[$j] = $temp;                          
                                           
            }
        }
    } 
    //return the array after sorting
  return $arr;
}
//Display the array before sorting
echo 'Original array ' . implode(',', $arr);

//place the sorted array in a variable 
$sorted = bubble($arr);

//Display the sorteed array
echo 'final array ' . implode(',', $sorted);
