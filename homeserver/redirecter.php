<?php

while ($line = fgets($stdin)) {

  error_log($line);
  
  echo '302:' . $line . "\n";
  //echo $line;
}

?>
