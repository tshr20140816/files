<?php
header('Content-type: text/plain; charset=utf-8');
$fp = fopen("https://packages.debian.org/jessie-backports/admin/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(preg_match("/^<dt>/", $buffer)){
    echo $buffer;
  }
}
fclose($fp);
?>
