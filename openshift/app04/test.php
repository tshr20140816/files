<?php

$suffix = urldecode($_POST["suffix"]);
$js_code = urldecode($_POST["js_code"]);

$original_file = getenv("OPENSHIFT_TMP_DIR") . "/original.$suffix.js";
$compiled_file = getenv("OPENSHIFT_TMP_DIR") . "/compiled.$suffix.js";
$result_file = getenv("OPENSHIFT_TMP_DIR") . "/result.$suffix.txt";
$zip_file = getenv("OPENSHIFT_TMP_DIR") . "/result.$suffix.zip";
$download_file = "result.$suffix.zip";

$fp = fopen($original_file, "w");
fwrite($fp, $js_code);
fclose($fp);

$cmd = "java -jar " . getenv("OPENSHIFT_DATA_DIR") . "/compiler.jar --summary_detail_level 3 --compilation_level SIMPLE_OPTIMIZATIONS --js $original_file --js_output_file $compiled_file 2>&1";
exec($cmd, $arr, $res);

$fp = fopen($result_file, "w");
fwrite($fp, $arr[0]);
fclose($fp);

$cmd = "zip -9 $zip_file $compiled_file $result_file";
exec($cmd, $arr, $res);

header("Content-Type: application/octet-stream");
header("Content-Disposition: attachment; filename=$download_file");
readfile($zip_file);

unlink($original_file);
unlink($compiled_file);
unlink($result_file);
unlink($zip_file);
?>
