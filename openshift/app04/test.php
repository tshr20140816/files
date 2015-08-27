<?php

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
    $sections[] = $matchs[1];
  }
}
$sections[] = "/sid/";
fclose($fp);

foreach($sections as &$section){
  $fp = fopen("https://packages.debian.org" . $section, "r");
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
      echo "https://packages.debian.org" . $section . $matchs[1] . "\n";
    }
  }
  fclose($fp);
}

?>
