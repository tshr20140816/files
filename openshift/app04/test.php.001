<?php

$section_list[] = "wheezy";
$section_list[] = "wheezy-updates";
$section_list[] = "wheezy-backports";
$section_list[] = "wheezy-backports-sloppy";
$section_list[] = "jessie";
$section_list[] = "jessie-updates";
$section_list[] = "jessie-backports";

$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>{0}</title>
  <link>https://packages.debian.org/{0}/</link>
  <description>{0}</description>
  <language>ja</language>
  {1}
</channel>
</rss>
__HEREDOC__;

$item_template = <<< __HEREDOC__
<item><title>{0}</title><link /><description /><pubDate /></item>
__HEREDOC__;

// header('Content-type: text/xml; charset=utf-8');
header('Content-type: text/plain; charset=utf-8');

foreach($section_list as &$section){
  echo "start " . $section . "\n";
  $items = array();
  $fp = gzopen("https://packages.debian.org/" . $section . "/allpackages?format=txt.gz", "r");
  while( ! feof($fp)){
    $buffer = fgets($fp);
    if(preg_match("/\(/", $buffer)){
      list($title, $version) = explode(" ", $buffer, 2);
      list($version, $dummy) = explode(")", $version, 2);
      $version .= ")";
      // echo $title . $version . "\n";
      $items[] = str_replace("{0}", $title . $version, $item_template);
    }
  }
  gzclose($fp);
  // echo str_replace("{0}", implode($items), $xml);
  $fp = fopen("./" . $section . ".xml", "w");
  $buffer = str_replace("{0}", $section, $xml);
  $buffer = str_replace("{1}", implode($items), $buffer);
  fwrite($fp, $buffer);
  fclose($fp);
  echo "finish " . $section . "\n";
}
?>
