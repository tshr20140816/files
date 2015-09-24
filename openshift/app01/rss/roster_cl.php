<?php
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>NPB 公示 セリーグ</title>
  <link>http://www.npb.or.jp/announcement/2015/roster_cl.html</link>
  <description>NPB 公示 セリーグ</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;

$item_template = "<item><title>%s</title><link>%s</link><description>%s</description><pubDate /></item>";

header('Content-type: text/xml; charset=utf-8');

$url = 'http://www.npb.or.jp/announcement/2015/roster_cl' . date('Ymd') . '.html';
$contents = file_get_contents($url);
$contents = mb_convert_encoding($contents, "UTF-8", "SJIS");

$start_flg = 0;
$lines = array();
foreach(explode("\n", $contents) as $value) {
  if(trim($value) == '<!-- 公示日付 -->') {
    $start_flg = 1;
    continue;
  }
  if($start_flg == 1 && trim($value) == '<!-- 出場選手一覧 -->') {
    break;
  }
  if($start_flg == 1) {
    $lines[] = trim($value);
  }
}

$items = array();
$tmp_old = '';
foreach($lines as $value) {
  $tmp = preg_replace('/<.+?>/', ' ', $value);
  $tmp = trim(preg_replace('/ +/', ' ', $tmp));
  if($tmp_old != $tmp){
    $items[] = $tmp;
    $tmp_old = $tmp;
  }
}
if(count($items) > 0) {
  echo str_replace("{0}", sprintf($item_template, date('Y.m.d'), $url, implode("&lt;br /&gt;\n", $items)), $xml);
} else {
  echo str_replace("{0}", "", $xml);
}
?>
