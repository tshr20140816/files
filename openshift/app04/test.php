<?php

header('Content-type: text/plain; charset=utf-8');

for($i = 0; $i < 7; $i++){
  $dt = strtotime("-" . $i . " day");
  $contents = file_get_contents('http://news.yahoo.co.jp/hl?c=l34&p=1&d=' . date("Ymd", $dt));
  
  foreach(explode("\n", $contents) as $value) {
    $cnt = preg_match('/.*<li><p class="ttl"><a href="(.+?)".*?>(.+?)<.+/', $value, $m);
    if($cnt > 0){
      $url = $m[1];
      $title = $m[2];
      $date = date("Y/m/d", $dt);
      echo $date . "\n";
      echo $url . "\n";
      echo $title . "\n";
    }
  }
}

$urls = array();
$urls[] = 'http://h50146.www5.hp.com/directplus/personal/';
$urls[] = 'http://h50146.www5.hp.com/directplus/smb/';

foreach($urls as $url){
  $contents = file_get_contents($url);
  $contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
  foreach(explode("\n", $contents) as $value) {
    $cnt = preg_match('/.*<p class="mrk_.+?href="(.+?)".+?>(.+?)<.+/', $value, $m);
    if($cnt > 0){
      $link = $m[1];
      if(substr($link, 0, 4) != "http") {
        $link = "http://h50146.www5.hp.com/" . $link;
      }
      $title = $m[2];
      echo $link . "\n";
      echo $title . "\n";
    }
  }
}
?>
