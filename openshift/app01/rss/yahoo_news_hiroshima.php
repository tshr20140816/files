<?php
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>Yahoo広島ニュース</title>
  <link>http://news.yahoo.co.jp/</link>
  <description>Yahoo広島ニュース</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;
$item_template = "<item><title>%s</title><link>%s</link><description /><pubDate>%s</pubDate></item>";

header('Content-type: text/xml; charset=utf-8');
$items = array();
for($i = 0; $i < 7; $i++) {
  $dt = strtotime("-" . $i . " day");
  $contents = file_get_contents('http://news.yahoo.co.jp/hl?c=l34&p=1&d=' . date("Ymd", $dt));
  foreach(explode("\n", $contents) as $value) {
    $cnt = preg_match('/.*<li><p class="ttl"><a href="(.+?)".*?>(.+?)<.+/', $value, $m);
    if($cnt > 0) {
      $url = $m[1];
      $title = $m[2];
      $date = date("Y/m/d", $dt);
      $items[] = sprintf($item_template, $title, $url, $date);
    }
  }
}
echo str_replace("{0}", implode("\n", $items), $xml);
?>
