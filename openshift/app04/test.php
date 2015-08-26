<?php
// https://packages.debian.org/sid/

header('Content-type: text/plain; charset=utf-8');
$fp = fopen("https://packages.debian.org/sid/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(trim($buffer) === '<div id="content">'){
    $start_flag = true;
    continue;
  }
  if($start_flag && trim($buffer) === '<h1>List of sections in "sid"</h1>'){
    break;
  }
  if($start_flag && preg_match('/ href="(.+?)"/', $buffer, $matchs)){
    # echo $buffer;
    echo $matchs[1] . "\n";
  }
}
fclose($fp);
?>
