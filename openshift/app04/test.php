<?php

// curl https://xxx/test.php -F "file=@./jquery-1.7.1.min.js" -F "param1=value1"
$suffix = $_POST["suffix"];
move_uploaded_file($_FILES['userfile']['tmp_name'], getenv("OPENSHIFT_TMP_DIR") . "/" . $_FILES['userfile']['name'] . "." . $suffix);

$original_file = getenv("OPENSHIFT_TMP_DIR") . "/" . $_FILES['userfile']['name'] . "." . $suffix;
$compiled_file = getenv("OPENSHIFT_TMP_DIR") . "/compiled.$suffix.js";
$result_file = getenv("OPENSHIFT_TMP_DIR") . "/result.$suffix.txt";
$zip_file = getenv("OPENSHIFT_TMP_DIR") . "/result.$suffix.zip";
$download_file = "result.$suffix.zip";

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
