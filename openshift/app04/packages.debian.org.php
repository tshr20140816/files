<?php
// https://packages.debian.org/sid/
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>packages.debian.org</title>
  <link>https://packages.debian.org/</link>
  <description>packages.debian.org</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;

$item_template = <<< __HEREDOC__
<item><title>{0}</title><link>https://packages.debian.org{0}</link><description /><pubDate /></item>
__HEREDOC__;

header('Content-type: text/plain; charset=utf-8');
$fp = fopen("https://packages.debian.org/sid/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(trim($buffer) === '<div id="content">'){
    $start_flag = true;
    continue;
  }
  if($start_flag && trim($buffer) === '<h1>List of sections in "sid"</h1>'){
    break;
  }
  if($start_flag && preg_match('/ href="(.+?)"/', $buffer, $matchs)){
    $items[] = str_replace("{0}", $matchs[1], $item_template);
  }
}
$items[] = str_replace("{0}", "/sid/, $item_template);
fclose($fp);

$fp = fopen("./packages.xml", "w");
$buffer = str_replace("{0}", implode($items), $xml);
fwrite($fp, $buffer);
fclose($fp);
?>
