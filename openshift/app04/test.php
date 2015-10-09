<?php
header('Content-type: text/plain; charset=utf-8');

$item_template = "<item><title>%s</title><link>%s</link><description />%s<pubDate>%s</pubDate></item>";

$items = array();

$url = 'http://www.cellstar.co.jp/mcd/gps/img/gps_date_top.gif';
$headers = get_headers($url);

foreach ($headers as $value) {
  if(substr($value, 0, 13) == 'Last-Modified'){
    print $value ."\n";
    $title = 'test1';
    $items[] = sprintf($item_template, $title, $url, substr($value, 15));
  }
}

print var_dump($items);
?>
