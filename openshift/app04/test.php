<?php
// https://packages.debian.org/sid/

header('Content-type: text/plain; charset=utf-8');
$fp = fopen("https://packages.debian.org/sid/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if($buffer === '<div id="content">'){
    $start_flag = true;
    continue;
  }
  if($start_flag && $buffer === '<h1>List of sections in "sid"</h1>'){
    break;
  }
  if(preg_match("/ href=/", $buffer)){
    echo $buffer;
  }
}
fclose($fp);
?>
