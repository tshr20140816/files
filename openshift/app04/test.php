<?php
// https://packages.debian.org/jessie-updates/

header('Content-type: text/plain; charset=utf-8');
$fp = fopen("https://packages.debian.org/jessie/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(preg_match('/<h1>List of sections in /', $buffer)){
    $start_flag = true;
    continue;
  }
  if($start_flag && trim($buffer) === '<div id="footer">'){
    break;
  }
  if($start_flag && preg_match('/ href="(.+?)"/', $buffer, $matchs)){
    if($match[1] === "allpackages"){
      break;
    }
    echo $matchs[1] . "\n";
  }
}
fclose($fp);

?>
