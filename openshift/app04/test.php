<?php

/*
$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>debian package sections</title>
  <link>https://packages.debian.org/</link>
  <description>debian package sections</description>
  <language>ja</language>
  {0}
</channel>
</rss>
__HEREDOC__;

$item_template = <<< __HEREDOC__
<item><title>{0}</title><link>https://packages.debian.org/{0}/</link><description /><pubDate /></item>
__HEREDOC__;
*/
$start_flag = false;
$fp = fopen("https://packages.debian.org/sid/", "r");
while( ! feof($fp)){
  $buffer = fgets($fp);
  if(trim($buffer) === '<div id="content">'){
    $start_flag = true;
    continue;
  } elseif($start_flag === false) {
    continue;
  }
  if(trim($buffer) === '<h1>List of sections in "sid"</h1>'){
    break;
  }
  if(preg_match('/ href="(.+?)"/', $buffer, $matchs)){
    $sections[] = $matchs[1];
  }
}
$sections[] = "/sid/";
fclose($fp);

foreach($sections as &$section){
  $start_flag = false;
  $fp = fopen("https://packages.debian.org" . $section, "r");
  while( ! feof($fp)){
    $buffer = fgets($fp);
    if(preg_match('/<h1>List of sections in /', $buffer)){
      $start_flag = true;
      continue;
    } elseif($start_flag === false) {
      continue;
    }
    if(trim($buffer) === '<div id="footer">'){
      break;
    }
    if(preg_match('/ href="(.+?)\/"/', $buffer, $matchs)){
      // echo "https://packages.debian.org" . $section . $matchs[1] . "/\n";
      $pages[] = array(trim($section, "/"), $matchs[1]);
    }
  }
  fclose($fp);
}

foreach($pages as &$page){
  $section = $page[0];
  $genre = $page[1];
  echo $section . "/" . $genre;
  $fp = fopen("https://packages.debian.org/" . $section . "/" . $genre . "/", "r");
  while( ! feof($fp)){
    $buffer = fgets($fp);
    if(preg_match('/^<dt>.+dt>$/', $buffer)){
      $buffer = preg_replace("/<.+?>/", "", $buffer);
      echo $buffer;
    }
  }
  fclose($fp);
}

/*
$fp = fopen("./debian.package.sections.xml", "w");
$buffer = str_replace("{0}", implode($items), $xml);
fwrite($fp, $buffer);
fclose($fp);
*/
?>
