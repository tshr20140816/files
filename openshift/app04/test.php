<?php
header('Content-type: text/plain; charset=utf-8');

$headers = get_headers('http://www.cellstar.co.jp/mcd/gps/img/gps_date_top.gif');

// print var_dump($headers);

foreach ($headers as $value) {
  if(substr($value, 0, 13) == 'Last-Modified'){
    print $value ."\n";
  }
}

?>
