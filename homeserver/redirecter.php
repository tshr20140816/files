<?php

$stdin = fopen('php://stdin', 'r');
ob_implicit_flush(true);

while ($line = fgets($stdin)) {

  error_log($line);
  
  $response = '';
  if (file_exists('/tmp/REDIRECT_ADDRESS')) {
    $response = file_get_contents('/tmp/REDIRECT_ADDRESS');
  } else {
    $response = file_get_contents('https://xxx.herokuapp.com/fqdn.php');
    file_put_contents('/tmp/REDIRECT_ADDRESS', $response);
  }
  
  echo '302:' . $line . "\n";
  //echo $line;
}

?>
