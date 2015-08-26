<?php

$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>jessie-backports</title>
  <link>https://packages.debian.org/jessie-backports/</link>
  <description>jessie-backports</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;

$item_template = <<< __HEREDOC__
<item><title>{0}</title><link>{1}</link><description /><pubDate /></item>
__HEREDOC__;

header('Content-type: text/plain; charset=utf-8');
$fp = gzopen("https://packages.debian.org/jessie-backports/allpackages?format=txt.gz", "r");
while( ! feof($fp)){
  $buffer = fgets($fp) . "<br>";
  if(preg_match("/\(/", $buffer)){
    list($title, $version) = explode(" ", $buffer, 2);
    list($version, $dummy) = explode(")", $version, 2);
    $version .= ")";
    echo $title . $version . "\n";
    items[]
  }
}
fclose($fp);
?>
