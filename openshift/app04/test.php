<?php
header('Content-type: text/plain; charset=utf-8');

$headers = get_headers('http://www.cellstar.co.jp/mcd/gps/img/gps_date_top.gif');

print var_dump($headers);

foreach ($headers as $value) {
  print $value ."\n";
}

?>
