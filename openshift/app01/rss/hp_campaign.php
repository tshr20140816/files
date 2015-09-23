<?php
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>HP Campaign</title>
  <link>http://h50146.www5.hp.com/</link>
  <description>HP キャンペーン</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;
$item_template = "<item><title>%s</title><link>%s</link><description /><pubDate /></item>";

header('Content-type: text/xml; charset=utf-8');

$items = array();
$urls = array();
$urls[] = 'http://h50146.www5.hp.com/directplus/personal/';
$urls[] = 'http://h50146.www5.hp.com/directplus/smb/';
foreach($urls as $url) {
  $contents = file_get_contents($url);
  $contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
  foreach(explode("\n", $contents) as $value) {
    $cnt = preg_match('/.*<p class="mrk_.+?href="(.+?)".+?>(.+?)<.+/', $value, $m);
    if($cnt > 0) {
      $link = $m[1];
      if(substr($link, 0, 4) != "http") {
        $link = "http://h50146.www5.hp.com/" . $link;
      }
      $title = $m[2];
      $items[] = sprintf($item_template, $title, $link);
    }
  }
}
echo str_replace("{0}", implode("\n", $items), $xml);
?>
