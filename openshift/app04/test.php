<?php
// header('Content-type: application/force-download');
header('Content-type: text/plain');

// echo date('Ymd');

$url = "http://www.yahoo.co.jp/";
$url = "https://github.com/tshr20140816/files/raw/master/openshift/app04/test.php";
$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, $url); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);
curl_exec($ch);
$info = curl_getinfo($ch);
curl_close($ch);

//print $info["http_code"];
print var_dump($info);
?>
