<?php
/**
 * Libraries is a sample class to be used to download js libraries
 * 
 * It should search for given library,
 * download and create a local copy of the same
 * 
 * Example usage:
 * 
 * Libraries::get('jquery');
 *  * 
 */
class Libraries {
    public static $libs = [
        'jquery' => 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js',
        'axios' => 'https://cdnjs.cloudflare.com/ajax/libs/axios/0.26.0/axios.min.js'
    ];
    public static function get(String $libname) {
        //check if the file already exists
        if (file_exists("Libs/" . $libname)) {
            echo "The requested library, $libname, already exists!";
            return;
        }
        //check of the name provided has a corresponding source url
        if (!array_key_exists($libname, self::$libs)) {
            echo "Sorry but we cannot get $libname at the moment";
            return;
        }
        //get file contents
        $content = file_get_contents(self::$libs[$libname]);
        //open file
        $file = fopen("Libs/" . $libname, 'w+');
        //write file
        fwrite($file, $content);
        //echo result
        if (file_exists("Libs/" . $libname)) {
            echo "Successfully downloaded $libname, Find it at Libs/$libname";
            return;
        }
    }
}
Libraries::get('jquery');
