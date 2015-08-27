<?php
// https://packages.debian.org/jessie-updates/utils/

$fp = fopen("https://packages.debian.org/jessie-updates/utils/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(preg_match('/^<dt>.+dt>$/', $buffer)){
    $buffer = preg_replace("/<.+?>/", "", $buffer);
    echo $buffer;
  }
}
fclose($fp);
?>
