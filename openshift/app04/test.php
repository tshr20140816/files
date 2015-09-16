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

$item_template = <<< __HEREDOC__
<item><title>{0}</title><link>{1}</link><description /><pubDate>{2}</pubDate></item>
__HEREDOC__;

header('Content-type: text/plain; charset=utf-8');

$contents = file_get_contents('http://www.carp.co.jp/headline15/index.html');

$start_flg = 0;
$lines[] = array();

foreach(explode("\n", $contents) as $value) {
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
    $title = substr($m[2][$i], 8);
    $buffer = str_replace("{0}", $title, $item_template);
    $buffer = str_replace("{1}", $url, $buffer);
    $items[] = str_replace("{2}", $dt, $buffer);
  }
}
$buffer = str_replace("{0}", implode('', $items), $xml);
echo $buffer;
?>
