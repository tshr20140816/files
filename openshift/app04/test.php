<?php
// https://packages.debian.org/sid/

$dom = new DOMDocument('1.0', 'UTF-8');
$dom->preserveWhiteSpace = false;
$dom->formatOutput = true;
$dom->load("https://packages.debian.org/sid/");
 
$xpath = new DOMXPath($dom);
 
$result = $xpath->query("//a");

var_dump($result);
?>
