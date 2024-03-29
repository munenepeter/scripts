<?php

/**
 * A way to chain static methods with non static methods
 * e.g Class::function()->another_function()
 */
class UrlToJson {

    private $url;

    public static function parse($uri) {

        $instance = new self();
        $instance->url = parse_url($uri);

        return $instance;
    }
    public function json() {
        return json_encode($this->url);
    }
}
$jsoned_url  = UrlToJson::parse("https://www.youtube.com/watch?v=c8Zc0kbaR5I")->json(); //works
print_r($jsoned_url);


/**
 * A way to chain functions 
 *
 * function()->another_function()
 *
 * @param mixed 
 * @return mixed
 **/
function response($data) {
    # code...
    echo $data . PHP_EOL;
    $class = new class {
        public function header($text) {
            echo $text;
        }
    };
    return $class;
}

response('Hello World')->header('Goodbye World');


class DB{

    private $data;
    private $table;
    private $instance;
    public static function table($table) {

        $instance->instance = new self();
        $instance->table = $table};

        return $instance->instance;
    }
    public function where($column, $value){
        
         $this->data = "SELECT * FROM {$this->table} WHERE {$column} = {$value};";
        
         return $this->instance;   
    }
    public function get() {
        
        return json_encode($this->data);
    }
}
$testData  = DB::table("users")->where('name', 'peter')->get(); //works
print_r($testData);



