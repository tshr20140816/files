<?php

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
$original_file = getenv("OPENSHIFT_TMP_DIR") . $file_name . "." . $suffix;
$compressed_file = getenv("OPENSHIFT_TMP_DIR") . "compressed.$suffix.css";
$yuicompressor = getenv("OPENSHIFT_DATA_DIR") . "/yuicompressor.jar";

if (preg_match('/\.js$/', $file_name) == 0)
{
    header('HTTP', true, 500);
    exit;
}

move_uploaded_file($_FILES['file']['tmp_name'], $original_file);
chdir(getenv("OPENSHIFT_TMP_DIR"));

if (file_exists($compressed_path . ".compressed") && file_exists($compressed_path))
{
    if (file_get_contents($original_file) == file_get_contents($compressed_path))
    {
        copy($compressed_path . ".compressed", $compressed_file);
    }
}
else
{
    $cmd = "java -jar $yuicompressor --type css -o $compressed_file $original_file 2>&1";
    exec($cmd, $arr, $res);
}

if (file_exists($compressed_file))
{
    header("Content-Type: text/css");
    echo file_get_contents($compressed_file);
    if (!file_exists($compressed_path . ".compressed"))
    {
        @mkdir(pathinfo($compressed_path, PATHINFO_DIRNAME) , "0777", TRUE);
        copy($original_file, $compressed_path);
        copy($compressed_file, $compressed_path . ".compressed");
    }
}
else
{
    header('HTTP', true, 500);
}

@unlink($original_file);
@unlink($compressed_file);
?>
