<?php

/*
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
*/

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

$time = time();

$mch = curl_multi_init();

foreach($sections as &$section){
  $url = $prefix . "https://packages.debian.org" . $section;
  $ch = curl_init();
  curl_setopt_array($ch, array(
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
  ));
  curl_multi_add_handle($mch, $ch);
}

do {
  $mrc = curl_multi_exec($mh, $active);
} while ($mrc == CURLM_CALL_MULTI_PERFORM);

if ( ! $running || $stat !== CURLM_OK) {
    throw new RuntimeException('GURD. Please Retry.');
}

$results = array();

do switch (curl_multi_select($mch, $TIMEOUT)) {
  case -1:
    do {
        $stat = curl_multi_exec($mch, $running);
    } while ($stat === CURLM_CALL_MULTI_PERFORM);
    continue 2;
  case 0:
    continue 2;
  default:
    do {
      $stat = curl_multi_exec($mch, $running);
    } while ($stat === CURLM_CALL_MULTI_PERFORM);
    
    do if ($raised = curl_multi_info_read($mch, $remains)) {
      $info = curl_getinfo($raised['handle']);
      echo "{$info['url']}: {$info['http_code']}\n";
      $response = curl_multi_getcontent($raised['handle']);
      
      if ($response === false) {
        echo 'ERROR ' . $info['url'] . PHP_EOL;
      } else {
        // echo $response, PHP_EOL;
        $results[] = array($info['url'], $response);
      }
      curl_multi_remove_handle($mch, $raised['handle']);
      curl_close($raised['handle']);
    } while ($remains);
} while ($running);
curl_multi_close($mch);

$time = time() - $time;

echo var_dump($time);
/*
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
*/
?>
