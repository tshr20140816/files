<?php
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof($fp)){
  $buffer = fgets($fp) . "<br>";
  if( ! preg_match("^Generated:.+", $buffer)){
    echo $buffer;
  }
}
fclose($fp);
?>
