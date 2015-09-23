<?php

header('Content-type: text/plain; charset=utf-8');

$contents = file_get_contents('http://www.npb.or.jp/announcement/2015/roster_cl' . date('Ymd') . '.html');
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

var_dump($lines);

$items = array();
foreach($lines as $value) {
  $value = preg_replace('/<.+?>/', ' ', $value);
  $value = preg_replace('/ .+/', ' ', $value);
  echo trim($value) . "\n";
}
?>
