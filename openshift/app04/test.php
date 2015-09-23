<?php
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>NPB 公示 セリーグ</title>
  <link>http://www.npb.or.jp/announcement/2015/roster_cl.html</link>
  <description>NPB 公示 セリーグ</description>
  <language>ja</language>
  <item><title>%s</title><link>%s</link><description>%s</description><pubDate /></item>
</channel>
</rss>
__HEREDOC__;

header('Content-type: text/plain; charset=utf-8');

$url = 'http://www.npb.or.jp/announcement/2015/roster_cl' . date('Ymd') . '.html'
$contents = file_get_contents($url);
$contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
// echo $contents;

$start_flg = 0;
$lines = array();
foreach(explode("\n", $contents) as $value) {
  if(trim($value) == '<!-- 公示日付 -->') {
    //echo trim($value) . "\n";
    $start_flg = 1;
    continue;
  }
  if($start_flg == 1 && trim($value) == '<!-- 出場選手一覧 -->') {
    //echo trim($value) . "\n";
    break;
  }
  if($start_flg == 1) {
    //echo trim($value) . "\n";
    $lines[] = trim($value);
  }
}

$items = array();
foreach($lines as $value) {
  $tmp = preg_replace('/<.+?>/', ' ', $value);
  $tmp = preg_replace('/ +/', ' ', $tmp);
  // echo trim($tmp) . "\n";
  $items[] = $tmp;
}
echo sprintf($xml, date('Y.m.d'), $url, implode("&lt;br /&gt;", $items));
?>
