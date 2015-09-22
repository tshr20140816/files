<?php
header('Content-type: text/plain; charset=utf-8');
for($i = 0; $i < 7; $i++) {
  $contents = file_get_contents('http://soccer.phew.homeip.net/download/schedule/data/SJIS_all_hirosima.csv');
  $contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
  foreach(explode("\n", $contents) as $value) {
    $cnt = preg_match('/.*エディオンスタジアム広島.+/', $value, $m);
    if($cnt > 0) {
      // echo $value . "\n";
      $temp_array = explode(",", $value);
      echo $temp_array[0] . "\n";
      echo $temp_array[1] . "\n";
      echo $temp_array[2] . "\n";
    }
  }
}
?>
