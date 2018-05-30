<?php

$stdin = fopen('php://stdin', 'r');
ob_implicit_flush(true);

$redirect_address_file = '/tmp/REDIRECT_ADDRESS';

while ($line = fgets($stdin)) {

  error_log($line);
  
  $redirect_address = null;
  if (file_exists($redirect_address_file)) {
    if (time() - filemtime($redirect_address_file) < 60 * 60 * 6) {
      $redirect_address = file_get_contents($redirect_address_file);
    }
  }
  if (is_null($response)) {    
    $redirect_address = file_get_contents('https://xxx.herokuapp.com/fqdn.php');
    file_put_contents($redirect_address_file, $redirect_address);
  }
  error_log($redirect_address);
  
  echo '302:' . $redirect_address . '?u=' . urlencode($line) . "\n";
  //echo $line;
}

?>
