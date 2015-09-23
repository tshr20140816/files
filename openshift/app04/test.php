<?php

header('Content-type: text/plain; charset=utf-8');

$start_flg = 0;
$lines = array();
foreach(explode("\n", file_get_contents('http://www.npb.or.jp/announcement/2015/roster_cl' . date('Ymd') . '.html')) as $value) {
  echo $value . "\n";
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
foreach($lines as $value) {
  $value = preg_replace('/<.+?>/', ' ', $value);
  $value = preg_replace('/ .+>/', ' ', $value);
  echo trim($value) + "\n";
}
?>
