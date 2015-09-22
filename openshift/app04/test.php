<?php
header('Content-type: text/plain; charset=utf-8');

$sb = array();
$sb[] = 'BEGIN:VCALENDAR'
$sb[] = 'PRODID:tshr_original_20150922'
$sb[] = 'VERSION:2.0'
$sb[] = 'BEGIN:VTIMEZONE'
$sb[] = 'TZID:Asia/Tokyo'
$sb[] = 'X-LIC-LOCATION:Asia/Tokyo'
$sb[] = 'BEGIN:STANDARD'
$sb[] = 'TZOFFSETFROM:+0900'
$sb[] = 'TZOFFSETTO:+0900'
$sb[] = 'TZNAME:JST'
$sb[] = 'DTSTART:20010101T000000'
$sb[] = 'END:STANDARD'
$sb[] = 'END:VTIMEZONE'

$created =

# $contents = file_get_contents('http://soccer.phew.homeip.net/download/schedule/data/SJIS_all_hirosima.csv');
$contents = file_get_contents('/tmp/SJIS_all_hirosima.csv');
$contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
foreach(explode("\n", $contents) as $value) {
  $cnt = preg_match('/.*エディオンスタジアム広島.+/', $value, $m);
  if($cnt > 0) {
    // echo $value . "\n";
    $temp_array = explode('","', $value);
    if($temp_array[1] >= date('Y/m/d', strtotime("-2 day"))){
      echo ltrim($temp_array[0], '"') . "\n";
      echo $temp_array[1] . "\n";
      echo $temp_array[2] . "\n";
      $sb[] = 'BEGIN:VEVENT'
      $sb[] = 'CREATED:'
      $sb[] = 'LAST-MODIFIED:'
      $sb[] = 'DTSTAMP:'
      $sb[] = 'UID:'
      $sb[] = 'DTSTART:'
      $sb[] = 'DTEND:'
      $sb[] = 'SUMMARY:'
      $sb[] = 'TRANSP:TRANSPARENT'
      $sb[] = 'END:VEVENT'
    }
  }
}
sb[] = 'END:VCALENDAR'
?>
