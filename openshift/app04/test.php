<?php
// https://packages.debian.org/sid/

header('Content-type: text/plain; charset=utf-8');
$fp = fopen("https://packages.debian.org/sid/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(preg_match("/ href=/", $buffer)){
    // $buffer = preg_replace("<.+?>", "", $buffer);
    echo $buffer;
  }
}
fclose($fp);
?>
