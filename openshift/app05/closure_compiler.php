<?php
// wget http://dl.google.com/closure-compiler/compiler-latest.zip
// curl https://xxx/xxx.php -F "file=@./jquery-1.7.1.min.js" -F "suffix=uuid" -F "path=app-root/"

if (!isset($_POST['suffix'], $_POST['path']))
{
    header('HTTP', true, 500);
    exit;
}

$suffix = $_POST["suffix"];
$path = $_POST["path"];

if (preg_match('/^\w+$/', $suffix) == 0)
{
    header('HTTP', true, 500);
    exit;
}

if (preg_match('/.*\.\..*/', $path) == 1)
{
    header('HTTP', true, 500);
    exit;
}

if (preg_match('/^app-root\/data\/.+$/', $path) == 0)
{
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
    header('HTTP', true, 500);
    exit;
}
move_uploaded_file($_FILES['file']['tmp_name'], $original_file);

if(file_exists($compressed_path . ".compressed") && file_exists($compressed_path))
{
    if(file_get_contents($original_file) == file_get_contents($compressed_path)){
        copy($compressed_path . ".compressed", $compiled_file);
        copy($compressed_path . ".result.txt", $result_file);
    }
} else {
    $cmd = "java -jar $closure_compiler --summary_detail_level 3 --compilation_level SIMPLE_OPTIMIZATIONS --js $original_file --js_output_file $compiled_file 2>&1";
    exec($cmd, $arr, $res);
    file_put_contents($result_file, $arr[0]);
}
chdir(getenv("OPENSHIFT_TMP_DIR"));
if (file_exists($compiled_file))
{
    $cmd = "zip -9 $zip_file $compiled_file $result_file";
    if (!file_exists($compressed_path . ".compressed"))
    {
        @mkdir(pathinfo($compressed_path, PATHINFO_DIRNAME), "0777", TRUE);
        copy($original_file, $compressed_path);
        copy($compiled_file, $compressed_path . ".compressed");
        copy($result_file, $compressed_path . ".result.txt");
    }
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
