<?php

$xml = <<< __HEREDOC__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>debian package {0}</title>
  <link>https://packages.debian.org/</link>
  <description>debian package {0}</description>
  <language>ja</language>
  {1}
</channel>
</rss>
__HEREDOC__;

$item_template = <<< __HEREDOC__
<item><title>{0}</title><link /><description /><pubDate /></item>
__HEREDOC__;

$prefix="https://tshrapp3.appspot.com/pagerelay?param=";
$start_flag = false;
$fp = fopen($prefix . "https://packages.debian.org/sid/", "r");
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

/*
$mch = curl_multi_init();

foreach($sections as &$section){
  $url = "https://packages.debian.org" . $section;
  $ch = curl_init();
  curl_setopt_array($ch, array(
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
  ));
  curl_multi_add_handle($mch, $ch);
}
*/

foreach($sections as &$section){
  $start_flag = false;
  $fp = fopen($prefix . "https://packages.debian.org" . $section, "r");
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
  list($section, $genre) = $page;
  echo $section . "/" . $genre;
  $items = array();
  $fp = fopen($prefix . "https://packages.debian.org/" . $section . "/" . $genre . "/", "r");
  while( ! feof($fp)){
    $buffer = fgets($fp);
    if(preg_match('/^<dt>.+dt>$/', $buffer)){
      $buffer = preg_replace("/<.+?>/", "", $buffer);
      // echo $buffer;
      $items[] = str_replace("{0}", $buffer, $item_template);
    }
  }
  fclose($fp);

  $fp = fopen("./debian.package." . $section . "." . $genre . ".xml", "w");
  $buffer = str_replace("{0}", $section . " " . $genre, $xml);
  $buffer = str_replace("{1}", implode($items), $buffer);
  fwrite($fp, $buffer);
  fclose($fp);
}

?>
