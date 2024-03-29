<?php
/**
 * 
 * Fun plays with static magic methods
 */

  function test($name){
      
      return trim($name);
 }

class Str {
    private static $methods = [
        'upper' => 'strtoupper',
        'lower' => 'strtolower',
        'len' => 'strlen',
        'trim' => 'test'        
    ];

    public static function __callStatic(string $method, array $parameters){
      
        if (!array_key_exists($method, self::$methods)) {
            throw new Exception('The ' . $method . ' is not supported.');
        }

        return call_user_func_array(self::$methods[$method], $parameters);
    }
}

echo Str::lower('Hello') . PHP_EOL; // hello
echo Str::upper('Hello') . PHP_EOL; // HELLO
echo Str::len('Hello') . PHP_EOL; //13
echo Str::trim("   Helllo   ") . PHP_EOL; // Helllo


