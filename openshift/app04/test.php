<?php

$start_flag = false;
$fp = fopen("https://packages.debian.org/sid/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(trim($buffer) === '<div id="content">'){
    $start_flag = true;
    continue;
  } elseif($start_flag === false) {
    continue;
  }
  if(trim($buffer) === '<h1>List of sections in "sid"</h1>'){
    break;
  }
  if(preg_match('/ href="(.+?)"/', $buffer, $matchs)){
    $sections[] = $matchs[1];
  }
}
$sections[] = "/sid/";
fclose($fp);

foreach($sections as &$section){
  $start_flag = false;
  $fp = fopen("https://packages.debian.org" . $section, "r");
  while( ! feof($fp)){
    $buffer = fgets($fp);
    if(preg_match('/<h1>List of sections in /', $buffer)){
      $start_flag = true;
      continue;
    } elseif($start_flag === false) {
      continue;
    }
    if(trim($buffer) === '<div id="footer">'){
      break;
    }
    if(preg_match('/ href="(.+?)\/"/', $buffer, $matchs)){
      // echo "https://packages.debian.org" . $section . $matchs[1] . "/\n";
      $items[] = str_replace("{0}", $section . $matchs[1], $item_template);
    }
  }
  fclose($fp);
}

$fp = fopen("./debian.package.sections.xml", "w");
$buffer = str_replace("{0}", implode($items), $xml);
fwrite($fp, $buffer);
fclose($fp);
?>
