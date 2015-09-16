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

foreach($lines as $value) {
  $cnt = preg_match_all('/.+?<a href="(.+?)">(.+?)</', $value, $m);
  for($i = 0; $i < $cnt + 1; $i++) {
    if(substr($m[1][i], 0, 5) == "http:") {
      $url = $m[1][i];
    } else {
      $url = "http://www.carp.co.jp/headline15/" . $m[1][i];
    }
    $dt = '20' . str_replace('.', '/', substr($m[2][i], 0, 8));
    $title = trim(substr($m[2][i], 9));
    echo $url . "\n";
    echo $dt . "\n";
    echo $title . "\n";
  }
}
// <li><a href="../bosyu15/index.html">xxx</a></li>
echo "\n";
?>
