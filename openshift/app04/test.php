<?php
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof($fp) ){
  echo fgets($fp) . "<br>";
}
fclose($fp);
?>
