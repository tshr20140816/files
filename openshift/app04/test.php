<?php
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof( $fp ) ){
  echo fgets( $fp, 9182 ) . "<br>";
}
fclose($fp);
?>
