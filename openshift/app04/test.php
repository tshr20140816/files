<?php
$d1 = $_POST["d1"];
$d2 = $_POST["d1"];

file_put_contents(getenv("OPENSHIFT_LOG_DIR") . "d1.txt", $d1);
file_put_contents(getenv("OPENSHIFT_LOG_DIR") . "d2.txt", $d2);
?>
