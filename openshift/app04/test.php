<?php
// https://packages.debian.org/sid/

$xml = simplexml_load_file("https://packages.debian.org/sid/");

echo $xml;
?>
