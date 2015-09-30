<?php
header('Content-type: text/calendar; charset=utf-8');

$contents = file_get_contents('http://www.formula1.com/content/fom-website/en/championship/races/2015.html');

$start_flag = 0;
foreach(explode("\r\n", $contents) as $value) {
  echo trim($value);
  if(trim($value) == '<p class="teaser-date">') {
    $buffer = trim($value);
    $start_flag = 1;
  } elseif($start_flag === 1){
    if(trim($value) == '</p>'){
      echo $buffer;
      $start_flag = 0;
    } else {
      $buffer .= trim($value);
    }
  }
}

?>
