<?php

header('Content-type: text/plain; charset=utf-8');

for($i = 0; $i < 7; $i++){
  $dt = strtotime("-" . $i . " day");
  $contents = file_get_contents('http://news.yahoo.co.jp/hl?c=l34&p=1&d=' . date("Ymd", $dt));
  
  foreach(explode("\n", $contents) as $value) {
    $cnt = preg_match('/.*<li><p class="ttl"><a href="(.+?)".*?>(.+?)<.+/', $value, $m);
    if($cnt > 0){
      echo date("Y/m/d", $dt) . "\n";
      echo $m[1] . "\n";
      echo $m[2] . "\n";
    }
  }
}

$contents = file_get_contents('http://h50146.www5.hp.com/directplus/personal/');
$contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
foreach(explode("\n", $contents) as $value) {
  $cnt = preg_match('/.*<p class="mrk_.+?href="(.+?)".+?>(.+?)<.+/', $value, $m);
  if($cnt > 0){
    echo $m[1] . "\n";
    echo $m[2] . "\n";
  }
}
?>
