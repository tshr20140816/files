<?php
date_default_timezone_set('Asia/Tokyo');
$log_file = getenv("OPENSHIFT_LOG_DIR") . "closure_compiler_php_" . date("Ymd") . ".log";
if (!isset($_POST['suffix']))
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 010 suffix\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
if (!isset($_POST['path']))
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 020 path\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
$suffix = $_POST["suffix"];
$path = $_POST["path"];
if (preg_match('/^\w+$/', $suffix) == 0)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 030 $suffix\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
if (preg_match('/.*\.\..*/', $path) == 1)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 040 $path\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
if (preg_match('/^app-root\/data\/.+$/', $path) == 0)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 050 $path\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
$compressed_path = getenv("OPENSHIFT_DATA_DIR") . "compressed/";
$compressed_path = preg_replace("/^app-root\/data\//", $compressed_path, $path);
$file_name = $_FILES['file']['name'];
$original_file = getenv("OPENSHIFT_TMP_DIR") . "/" . $file_name . "." . $suffix;
$compiled_file = getenv("OPENSHIFT_TMP_DIR") . "compiled.$suffix.js";
$result_file = getenv("OPENSHIFT_TMP_DIR") . "result.$suffix.txt";
$zip_file = "result.$suffix.zip";
$download_file = "result.$suffix.zip";
$closure_compiler = getenv("OPENSHIFT_DATA_DIR") . "/compiler.jar";
if (preg_match('/\.js$/', $file_name) == 0)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 060 $file_name\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 070 suffix $suffix\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 080 path $path\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 090 compressed_path $compressed_path\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 100 file_name $file_name\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 110 original_file $original_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 120 compiled_file $compiled_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 130 result_file $result_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 140 zip_file $zip_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 150 download_file $download_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " TARGET $path\r\n", FILE_APPEND);
move_uploaded_file($_FILES['file']['tmp_name'], $original_file);
if (file_exists($compressed_path . ".compressed") && file_exists($compressed_path)
     && (file_get_contents($original_file) == file_get_contents($compressed_path)))
{
    file_put_contents($log_file, date("YmdHis") . " CACHE HIT $path\r\n", FILE_APPEND);
    copy($compressed_path . ".compressed", $compiled_file);
    copy($compressed_path . ".result.txt", $result_file);
}
else
{
    file_put_contents($log_file, date("YmdHis") . " CACHE MISS $path\r\n", FILE_APPEND);
    $cmd = "java -jar $closure_compiler --summary_detail_level 3 --compilation_level SIMPLE_OPTIMIZATIONS --js $original_file --js_output_file $compiled_file 2>&1";
    exec($cmd, $arr, $res);
    file_put_contents($result_file, $arr[0]);
    file_put_contents($log_file, date("YmdHis") . " RESULT $arr[0]\r\n", FILE_APPEND);
}
chdir(getenv("OPENSHIFT_TMP_DIR"));
if (file_exists($compiled_file))
{
    if (!file_exists($compressed_path . ".compressed"))
    {
        $tmp = pathinfo($compressed_path, PATHINFO_DIRNAME);
        file_put_contents($log_file, date("YmdHis") . " CHECK POINT 160 MKDIR $tmp\r\n", FILE_APPEND);
        @mkdir(pathinfo($compressed_path, PATHINFO_DIRNAME) , 0777, TRUE);
        copy($original_file, $compressed_path);
        copy($compiled_file, $compressed_path . ".compressed");
        copy($result_file, $compressed_path . ".result.txt");
    }
    $cmd = "zip -9 $zip_file " . pathinfo($compiled_file, PATHINFO_BASENAME) . " " . pathinfo($result_file, PATHINFO_BASENAME);
}
else
{
    $cmd = "zip -9 $zip_file " . pathinfo($result_file, PATHINFO_BASENAME);
}
file_put_contents($log_file, date("YmdHis") . " $cmd\r\n", FILE_APPEND);
exec($cmd, $arr, $res);
header("Content-Type: application/octet-stream");
header("Content-Disposition: attachment; filename=$download_file");
readfile($zip_file);
unlink($original_file);
unlink($compiled_file);
unlink($result_file);
unlink($zip_file);
?>
