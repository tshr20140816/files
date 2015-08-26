<?php
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof($fp)){
  $buffer = fgets($fp) . "<br>";
  if(preg_match("\(", $buffer)){
    echo $buffer;
  }
}
fclose($fp);
?>
