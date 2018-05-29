<?php

while ($line = fgets($stdin)) {

  error_log($line);
  
  echo $line;
}

?>
