<?php
header('Content-type: text/plain; charset=utf-8');

$contents = file_get_contents('http://www.carp.co.jp/headline15/index.html');

// <div id="contents">

$start_flg = 0;
$lines[] = array();

foreach(explode("\n", $contents) as $value) {
  // echo $value;
  // echo "\n";
  if(trim($value) == '<div id="contents">') {
    $start_flg = 1;
    continue;
  }
  if($start_flg == 1 && trim($value) == '</ul>') {
    break;
  }
  if($start_flg == 1) {
    $lines[] = trim($value);
  }
}

$items[] = array();

foreach($lines as $value) {
  $cnt = preg_match_all('/.+?<a href="(.+?)">(.+?)</', $value, $m);
  for($i = 0; $i < $cnt; $i++) {
    if(substr($m[1][$i], 0, 5) == "http:") {
      $url = $m[1][$i];
    } else {
      $url = "http://www.carp.co.jp/headline15/" . $m[1][$i];
    }
    $dt = '20' . str_replace('.', '/', substr($m[2][$i], 0, 8));
    $title = trim(substr($m[2][$i], 8));
    echo $url . "\n";
    echo $dt . "\n";
    echo $title . "\n";
    $buffer = str_replace("{0}", $title, $item_template);
    $buffer = str_replace("{1}", $url, $buffer);
    $items[] = str_replace("{2}", $dt, $buffer);
  }
}
$buffer = str_replace("{0}", implode($items), $xml);
echo $buffer;
echo "\n";
?>
