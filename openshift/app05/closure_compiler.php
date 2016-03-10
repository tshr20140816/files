<?php

// wget http://dl.google.com/closure-compiler/compiler-latest.zip
// curl https://xxx/xxx.php -F "file=@./jquery-1.7.1.min.js" -F "suffix=uuid"

$suffix = $_POST["suffix"];

if (preg_match('/^\w+$/') == 0)
{
    header('HTTP', true, 500);
    exit;
}

$file_name = $_FILES['file']['name'];
$original_file = $file_name . "." . $suffix;
$compiled_file = "compiled.$suffix.js";
$result_file = "result.$suffix.txt";
$zip_file = "result.$suffix.zip";
$download_file = "result.$suffix.zip";
$closure_compiler = getenv("OPENSHIFT_DATA_DIR") . "/compiler.jar";

if (preg_match('/\.js$/') == 0)
{
    header('HTTP', true, 500);
    exit;
}

move_uploaded_file($_FILES['file']['tmp_name'], getenv("OPENSHIFT_TMP_DIR") . "/" . $original_file);
chdir(getenv("OPENSHIFT_TMP_DIR"));
$cmd = "java -jar $closure_compiler --summary_detail_level 3 --compilation_level SIMPLE_OPTIMIZATIONS --js $original_file --js_output_file $compiled_file 2>&1";
exec($cmd, $arr, $res);
$fp = fopen($result_file, "w");
fwrite($fp, $arr[0]);
fclose($fp);

if (file_exists($compiled_file))
{
    $cmd = "zip -9 $zip_file $compiled_file $result_file";
}
else
{
    $cmd = "zip -9 $zip_file $result_file";
}

exec($cmd, $arr, $res);
header("Content-Type: application/octet-stream");
header("Content-Disposition: attachment; filename=$download_file");
readfile($zip_file);
unlink($original_file);
unlink($compiled_file);
unlink($result_file);
unlink($zip_file);
?>
