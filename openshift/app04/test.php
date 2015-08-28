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

header('Content-type: text/plain; charset=utf-8');

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

echo date("H:i:s");

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
  $stat = curl_multi_exec($mch, $active);
} while ($stat === CURLM_CALL_MULTI_PERFORM);

if ( ! $active || $stat !== CURLM_OK) {
    // throw new RuntimeException('GURD. Please Retry.');
    echo var_dump($active);
    echo var_dump($stat);
    echo "Error...";
    exit;
}

do switch (curl_multi_select($mch, 60)) {
  case -1:
    do {
        $stat = curl_multi_exec($mch, $active);
    } while ($stat === CURLM_CALL_MULTI_PERFORM);
    continue 2;
  case 0:
    continue 2;
  default:
    do {
      $stat = curl_multi_exec($mch, $active);
    } while ($stat === CURLM_CALL_MULTI_PERFORM);
    
    do if ($raised = curl_multi_info_read($mch, $remains)) {
      $info = curl_getinfo($raised['handle']);
      echo date("H:i:s") . "{$info['url']}: {$info['http_code']}\n";
      $response = curl_multi_getcontent($raised['handle']);
      
      if ($response === false) {
        echo 'ERROR ' . $info['url'] . PHP_EOL;
      } else {
        // echo $response, PHP_EOL;
        // var_dump($response);
        $tmp = explode("/", $info['url']);
        $section = $tmp[count($tmp) - 2];
        $start_flag = false;
        $tmp = explode("\n", $response);
        foreach($tmp as &$line){
          if(preg_match('/<h1>List of sections in /', $line)){
            $start_flag = true;
            continue;
          } elseif($start_flag === false) {
            continue;
          }
          if(trim($line) === '<div id="footer">'){
            break;
          }
          if(preg_match('/ href="(.+?)\/"/', $line, $matchs)){
            $pages[] = array(trim($section, "/"), $matchs[1]);
          }
        }
      }
      curl_multi_remove_handle($mch, $raised['handle']);
      curl_close($raised['handle']);
    } while ($remains);
} while ($active);

curl_multi_close($mch);

echo date("H:i:s");

$mch = curl_multi_init();

foreach($pages as &$page){
  list($section, $genre) = $page;
  $url = $prefix . "https://packages.debian.org/" . $section . "/" . $genre . "/";
  $ch = curl_init();
  curl_setopt_array($ch, array(
    CURLOPT_URL => $url,
    CURLOPT_RETURNTRANSFER => true,
  ));
  curl_multi_add_handle($mch, $ch);
}

do {
  $stat = curl_multi_exec($mch, $active);
} while ($stat === CURLM_CALL_MULTI_PERFORM);

if ( ! $active || $stat !== CURLM_OK) {
    echo var_dump($active);
    echo var_dump($stat);
    echo "Error...";
    exit;
}

do switch (curl_multi_select($mch, 60)) {
  case -1:
    do {
        $stat = curl_multi_exec($mch, $active);
    } while ($stat === CURLM_CALL_MULTI_PERFORM);
    continue 2;
  case 0:
    continue 2;
  default:
    do {
      $stat = curl_multi_exec($mch, $active);
    } while ($stat === CURLM_CALL_MULTI_PERFORM);
    
    do if ($raised = curl_multi_info_read($mch, $remains)) {
      $info = curl_getinfo($raised['handle']);
      echo date("H:i:s") . " {$info['url']}: {$info['http_code']}\n";
      $response = curl_multi_getcontent($raised['handle']);
      
      if ($response === false) {
        echo 'ERROR ' . $info['url'] . PHP_EOL;
      } else {
        $tmp = explode("/", $info['url']);
        $section = $tmp[count($tmp) - 3];
        $genre = $tmp[count($tmp) - 2];
        $items = array();
        $tmp = explode("\n", $response);
        foreach($tmp as &$line){
          if(preg_match('/^<dt>.+dt>$/', $line)){
            $buffer = preg_replace("/<.+?>/", "", $line);
            // echo $buffer;
            $items[] = str_replace("{0}", $buffer, $item_template);
          }
        }
        $fp = fopen("./debian.package." . $section . "." . $genre . ".xml", "w");
        $buffer = str_replace("{0}", $section . " " . $genre, $xml);
        $buffer = str_replace("{1}", implode($items), $buffer);
        fwrite($fp, $buffer);
        fclose($fp);
      }
      curl_multi_remove_handle($mch, $raised['handle']);
      curl_close($raised['handle']);
    } while ($remains);
} while ($active);

curl_multi_close($mch);

echo date("H:i:s");
?>
