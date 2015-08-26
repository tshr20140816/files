<?php
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof($fp)){
  $buffer = fgets($fp) . "<br>";
  if(preg_match("/\(/", $buffer)){
    $buffer_array = explode(" ", $buffer, 3);
    echo $buffer_array[0] . $buffer_array[1];
  }
}
fclose($fp);
?>
