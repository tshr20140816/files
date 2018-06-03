<?php

// /usr/bin/php /var/www/80/ttrss/update_daemon2.php --tasks 2 --interval 80 2>&1 | /usr/bin/php /home/user/loggly_ttrss.php &

$stdin = fopen('php://stdin', 'r');
ob_implicit_flush(TRUE);

$url = 'https://logs-01.loggly.com/inputs/xxxx/tag/ttrss/';

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 20);
curl_setopt($ch, CURLOPT_ENCODING, '');
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($ch, CURLOPT_MAXREDIRS, 3);
curl_setopt($ch, CURLOPT_POST, TRUE);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: text/plain']);

while ($line = fgets($stdin)) {
  curl_setopt($ch, CURLOPT_POSTFIELDS, '[ttrss]' . $line);
  @curl_exec($ch);
}

curl_close($ch);
?>
