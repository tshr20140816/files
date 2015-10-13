<?php
header('Content-type: text/plain; charset=utf-8');

$item_template = "<item><title>%s</title><link>%s</link><description /><pubDate>%s</pubDate></item>";

$items = array();

$url = 'http://www.hiroden.co.jp/what/new/topic.htm';
$contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
foreach(explode("\n", $contents) as $value) {
  echo trim($value);
  if(substr(trim($value), 0, 4) == '<h3>'){
    echo trim($value);
  }
}

//print var_dump($items);
?>
