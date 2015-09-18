<?php

header('Content-type: text/plain; charset=utf-8');

$contents = file_get_contents('http://news.yahoo.co.jp/hl?c=l34&p=1&d=20150918');

foreach(explode("\n", $contents) as $value) {
  // echo $value;
  $cnt = preg_match('/.*<li><p class="ttl"><a href="(.+?)".*>(.+?)<.+/', $value, $m);
  if($cnt > 0){
    echo $m[0] . "\n";
    echo $m[1] . "\n";
  }
}
?>
