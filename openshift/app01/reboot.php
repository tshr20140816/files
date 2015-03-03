<?php
$action = $_POST['action']
$url = $_POST['url']
$rc = 'OK';

if(preg_match('^\w+?-\w+?\.rhcloud\.com$', $url) === 0)
{
    $filename = getenve('OPENSHIFT_DATA_DIR') + 'ignore_server_list/' + $url
    switch ($action)
    {
        case "ignore":
            touch($filename);
            break;
        case "reboot_check":
            if(file_exists($filename))
            {
                if(mktime() - filemtime($filename) < 60 * 60 * 3)
                {
                    $rc = 'NG';
                }
                else
                {
                    unlink($filename);
                }
            };
            break;
        case "remove":
            if(file_exists($filename))
            {
                unlink($filename);
            };
            break;
        default:
            break;
    }
}
header('Content-type: text/plain');
echo $rc
?>
