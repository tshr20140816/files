<?php
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>CARPニュース</title>
  <link>http://www.carp.co.jp/</link>
  <description>ニュースヘッドライン</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;

$item_template = "<item><title>%s</title><link>%s</link><description /><pubDate>%s</pubDate></item>";

header('Content-type: text/plain; charset=utf-8');

$start_flg = 0;
$lines = array();
foreach(explode("\n", file_get_contents('http://www.carp.co.jp/headline15/index.html')) as $value) {
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

$items = array();
foreach($lines as $value) {
  $cnt = preg_match_all('/.+?<a href="(.+?)">(.+?)</', $value, $m);
  for($i = 0; $i < $cnt; $i++) {
    $url = $m[1][$i];
    if(substr($url, 0, 4) != "http") {
      $url .= "http://www.carp.co.jp/headline15/";
    }
    $dt = '20' . str_replace('.', '/', substr($m[2][$i], 0, 8));
    $title = str_replace("&times;", "x", substr($m[2][$i], 8));
    $items[] = sprintf($item_template, $title, $url, $dt);
  }
}
echo str_replace("{0}", implode("\n", $items), $xml);
?>
