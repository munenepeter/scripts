<?php

class Str {
    private static $methods = [
        'upper' => 'strtoupper',
        'lower' => 'strtolower',
        'len' => 'strlen'
    ];

    public static function __callStatic(string $method, array $parameters){
      
        if (!array_key_exists($method, self::$methods)) {
            throw new Exception('The ' . $method . ' is not supported.');
        }

        return call_user_func_array(self::$methods[$method], $parameters);
    }
}

echo Str::lower('Hello') . '<br>';
echo Str::upper('Hello') . '<br>';
echo Str::len('Hello') . '<br>';
