<?php
header('Content-type: text/plain; charset=utf-8');

$contents = file_get_contents('http://www.carp.co.jp/headline15/index.html');

// <div id="contents">

$start_flg = 0;
$lines[] = array();

foreach(explode("\n", $contents) as $value){
  # echo $value;
  # echo "\n";
  if(trim($value) == '<div id="contents">'){
    $start_flg = 1;
    continue;
  }
  if($start_flg == 1 && trim($value) == '</ul>'){
    break;
  }
  if($start_flg == 1){
    $lines[] = $value;
    echo $value;
    echo "\n";
  }
}

echo "\n";
?>
