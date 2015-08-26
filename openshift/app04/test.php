<?php
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof($fp)){
  $buffer = fgets($fp) . "<br>";
  if(preg_match("/\(/", $buffer)){
    list($title, $version, $dummy) = explode(" ", $buffer, 3);
    echo $title . $version . "\n";
  }
}
fclose($fp);
?>
