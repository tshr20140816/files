<?php
$suffix = $_POST["suffix"];
if (preg_match('/^\w+$/', $suffix) == 0)
{
    header('HTTP', true, 500);
    exit;
}
$file_name = $_FILES['file']['name'];
$original_file = $file_name . "." . $suffix;
$compressed_file = "compressed.$suffix.css";
$yuicompressor = getenv("OPENSHIFT_DATA_DIR") . "/yuicompressor.jar";
if (preg_match('/\.js$/', $file_name) == 0)
{
    header('HTTP', true, 500);
    exit;
}
move_uploaded_file($_FILES['file']['tmp_name'], getenv("OPENSHIFT_TMP_DIR") . "/" . $original_file);
chdir(getenv("OPENSHIFT_TMP_DIR"));
$cmd = "java -jar $yuicompressor --type css -o $compressed_file $original_file 2>&1";
exec($cmd, $arr, $res);
if (file_exists($compressed_file))
{
    header("Content-Type: text/css");
    echo file_get_contents($compressed_file);
}
else
{
    header('HTTP', true, 500);
}
@unlink($original_file);
@unlink($compressed_file);
?>
