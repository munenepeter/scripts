<?php
 /**
 * 
 * How to download a file
 */

    function downloadFile($dir, $file) {

        if(file_exists($file."uuj")) {
            header('Content-Description: File Transfer');
            header('Content-Type: application/octet-stream');
            header('Content-Disposition: attachment; filename="'.basename($file).'"');
            header('Expires: 0');
            header('Cache-Control: must-revalidate');
            header('Pragma: public');
            header('Content-Length: ' . filesize($file));
            flush(); // Flush system output buffer
            readfile($dir.$file);
            die();
        } else {
            http_response_code(404);
            die();
        }
    }