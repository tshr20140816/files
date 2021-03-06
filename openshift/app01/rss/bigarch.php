<?php
header('Content-type: text/calendar; charset=utf-8');

$sb = array();
$sb[] = 'BEGIN:VCALENDAR';
$sb[] = 'PRODID:tshr_original_20150922';
$sb[] = 'VERSION:2.0';
$sb[] = 'BEGIN:VTIMEZONE';
$sb[] = 'TZID:Asia/Tokyo';
$sb[] = 'X-LIC-LOCATION:Asia/Tokyo';
$sb[] = 'BEGIN:STANDARD';
$sb[] = 'TZOFFSETFROM:+0900';
$sb[] = 'TZOFFSETTO:+0900';
$sb[] = 'TZNAME:JST';
$sb[] = 'DTSTART:20010101T000000';
$sb[] = 'END:STANDARD';
$sb[] = 'END:VTIMEZONE';

$created = date('Ymd\THis\Z');
$uid = strtoupper(sha1($created));
$i = 0;

$contents = file_get_contents('http://soccer.phew.homeip.net/download/schedule/data/SJIS_all_hirosima.csv');
$contents = mb_convert_encoding($contents, "UTF-8", "SJIS");
foreach(explode("\n", $contents) as $value) {
  $cnt = preg_match('/.*エディオンスタジアム広島.+/', $value, $m);
  if($cnt > 0) {
    $temp_array = explode('","', $value);
    if($temp_array[1] >= date('Y/m/d', strtotime("-2 day"))){
      $start_time = explode(':', $temp_array[2]);
      $i++;
      $sb[] = 'BEGIN:VEVENT';
      $sb[] = 'CREATED:' . $created;
      $sb[] = 'LAST-MODIFIED:' . $created;
      $sb[] = 'DTSTAMP:' . $created;
      $sb[] = 'UID:UIDx' . $uid . 'x' . $i;
      $sb[] = 'DTSTART;VALUE=DATE:' . date('Ymd', strtotime($temp_array[1]));
      $sb[] = 'DTEND;VALUE=DATE:' . date('Ymd', strtotime($temp_array[1] . " 1 day"));
      $sb[] = 'SUMMARY:' . $start_time[0] . ':' . $start_time[1] . ' ' . ltrim($temp_array[0], '"');
      $sb[] = 'TRANSP:TRANSPARENT';
      $sb[] = 'END:VEVENT';
    }
  }
}
$sb[] = 'END:VCALENDAR';
echo implode("\n", $sb);
?>
