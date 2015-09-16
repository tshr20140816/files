<?php
header('Content-type: text/plain; charset=utf-8');

$contents = file_get_contents('http://www.carp.co.jp/headline15/index.html');

// <div id="contents">

foreach(explode("\n", $contents) as $value){
  echo $value;
}

echo "\n";
?>
