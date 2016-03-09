<?php
// header('Content-type: application/force-download');
header('Content-type: text/plain');

print uniqid();
print session_id();

$url = "https://woo-20140818.rhcloud.com/ttrss/js/FeedTree.js";
$s = file_get_contents($url);
if($s == FALSE){
    print "ERROR 1";
    return;
}

$fp = fopen("/tmp/FeedTree.js", "w");
fwrite($fp, $s);
fclose($fp);

$cmd = "java -jar " . getenv("OPENSHIFT_DATA_DIR") . "/compiler.jar --summary_detail_level 3 --compilation_level SIMPLE_OPTIMIZATIONS --js /tmp/FeedTree.js --js_output_file /tmp/compiled.js 2>&1";
exec($cmd, $arr, $res);
if($res === 0){
    print var_dump($arr);
} else {
    print "ERROR 2";
    return;
}
// print var_dump($info);
?>
