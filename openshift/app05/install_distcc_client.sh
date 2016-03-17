#!/bin/bash

# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/install_distcc_client.sh
# chmod +x install_distcc_client.sh

set -x

export TZ=JST-9

if [ $# -ne 2 ]; then
    set +x
    echo "arg1 : web_beacon_server https://xxx/"
    echo "arg2 : web beacon server user (digest auth)"
    exit
fi

web_beacon_server=${1}
web_beacon_server_user=${2}

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** distcc *****

distcc_version=3.1

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget https://distcc.googlecode.com/files/distcc-${distcc_version}.tar.bz2
tar jxf distcc-${distcc_version}.tar.bz2
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/distcc-${distcc_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/distcc \
 --infodir=${OPENSHIFT_TMP_DIR}/info \
 --mandir=${OPENSHIFT_TMP_DIR}/man
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null

cat << '__HEREDOC__' > ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start
#!/bin/bash

export DISTCC_TCP_CORK=0
export HOME=${OPENSHIFT_DATA_DIR}
export PATH="${OPENSHIFT_DATA_DIR}/distcc/bin:$PATH"
export DISTCC_DIR=${OPENSHIFT_DATA_DIR}.distcc
export DISTCC_LOG=${OPENSHIFT_LOG_DIR}/distcc/$(date +%Y%m%d).$$.log

echo "$(date +%Y/%m/%d" "%H:%M:%S) $@" >> ${DISTCC_LOG}
exec ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd $@
__HEREDOC__
chmod 755 ${OPENSHIFT_DATA_DIR}/distcc/bin/distccd_start

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
mkdir distcc
popd > /dev/null

# ***** YUI Compressor *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
yuicompressor_version="2.4.8"
wget https://github.com/yui/yuicompressor/releases/download/v${yuicompressor_version}/yuicompressor-${yuicompressor_version}.jar
cp yuicompressor-${yuicompressor_version}.jar yuicompressor.jar
popd > /dev/null

# ***** PHP (YUI Compressor) *****

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
cat << '__HEREDOC__' > yuicompressor.php
<?php
$log_file = getenv("OPENSHIFT_LOG_DIR") . "yuicompressor_php_" . date("Ymd") . ".log";
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
$original_file = getenv("OPENSHIFT_TMP_DIR") . $file_name . "." . $suffix;
$compressed_file = getenv("OPENSHIFT_TMP_DIR") . "compressed.$suffix.css";
$yuicompressor = getenv("OPENSHIFT_DATA_DIR") . "/yuicompressor.jar";
if (preg_match('/\.css/', $file_name) == 0)
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 060 $file_name\r\n", FILE_APPEND);
    header('HTTP', true, 500);
    exit;
}
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 050 suffix $suffix\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 060 path $path\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 070 compressed_path $compressed_path\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 080 file_name $file_name\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 090 original_file $original_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 100 compressed_file $compressed_file\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " CHECK POINT 110 yuicompressor $yuicompressor\r\n", FILE_APPEND);
file_put_contents($log_file, date("YmdHis") . " TARGET $path\r\n", FILE_APPEND);
move_uploaded_file($_FILES['file']['tmp_name'], $original_file);
chdir(getenv("OPENSHIFT_TMP_DIR"));
if (file_exists($compressed_path . ".compressed") && file_exists($compressed_path)
    && (file_get_contents($original_file) == file_get_contents($compressed_path)))
{
    file_put_contents($log_file, date("YmdHis") . " CACHE HIT $path\r\n", FILE_APPEND);
    copy($compressed_path . ".compressed", $compressed_file);
}
else
{
    file_put_contents($log_file, date("YmdHis") . " CACHE MISS $path\r\n", FILE_APPEND);
    $cmd = "java -jar $yuicompressor --type css -o $compressed_file $original_file 2>&1";
    exec($cmd, $arr, $res);
    $tmp = var_dump($arr);
    file_put_contents($log_file, date("YmdHis") . " RESULT $tmp\r\n", FILE_APPEND);
}
if (file_exists($compressed_file))
{
    header("Content-Type: text/css");
    echo file_get_contents($compressed_file);
    if (!file_exists($compressed_path . ".compressed"))
    {
        @mkdir(pathinfo($compressed_path, PATHINFO_DIRNAME) , 0777, TRUE);
        copy($original_file, $compressed_path);
        copy($compressed_file, $compressed_path . ".compressed");
    }
}
else
{
    file_put_contents($log_file, date("YmdHis") . " CHECK POINT 070 $compressed_file\r\n", FILE_APPEND);
    header('HTTP', true, 500);
}
@unlink($original_file);
@unlink($compressed_file);
?>
__HEREDOC__
popd > /dev/null

# ***** Closure Compiler *****

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget http://dl.google.com/closure-compiler/compiler-latest.zip
unzip compiler-latest.zip
popd > /dev/null

# ***** PHP (Closure Compiler) *****

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
# wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/closure_compiler.php
cat << '__HEREDOC__' > closure_compiler.php
<?php
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
        file_put_contents($log_file, date("YmdHis") . "CHECK POINT 160 MKDIR $tmp\r\n", FILE_APPEND);
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
__HEREDOC__
popd > /dev/null

# ***** cron *****

# *** hourly ***

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f ./*
touch jobs.deny

cat << '__HEREDOC__' > delete_log.sh
#!/bin/bash
export TZ=JST-9

find ${OPENSHIFT_LOG_DIR}/distcc/ -mtime +2 -print0 | xargs -0i -P 1 -n 1 rm -f {}
__HEREDOC__
chmod +x delete_log.sh
echo delete_log.sh >> jobs.allow

popd > /dev/null

# *** minutely ***

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f ./*
touch jobs.deny

cat << '__HEREDOC__' > create_index_page.sh
#!/bin/bash
export TZ=JST-9

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
echo "<HTML><BODY><PRE>" > ${OPENSHIFT_TMP_DIR}/index.html.$$
ls -lang >> ${OPENSHIFT_TMP_DIR}/index.html.$$
echo "</PRE></BODY></HTML>" >> ${OPENSHIFT_TMP_DIR}/index.html.$$
mv -f ${OPENSHIFT_TMP_DIR}/index.html.$$ ./index.html
popd > /dev/null
__HEREDOC__
chmod +x create_index_page.sh
echo create_index_page.sh >> jobs.allow

popd > /dev/null

# ***** logs dir *****

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
ln -s ${OPENSHIFT_LOG_DIR} logs
popd > /dev/null

# ***** robots.txt *****

cat << '__HEREDOC__' > ${OPENSHIFT_REPO_DIR}/robots.txt
User-agent: *
Disallow: /
__HEREDOC__

# ***** htaccess *****

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd

echo AuthType Digest > ${OPENSHIFT_LOG_DIR}/.htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> ${OPENSHIFT_LOG_DIR}/.htaccess
cat << '__HEREDOC__' >> ${OPENSHIFT_LOG_DIR}/.htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

# IndexOptions +FancyIndexing

RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__

# ***** phpinfo *****

cat << '__HEREDOC__' > ${OPENSHIFT_LOG_DIR}/phpinfo.php
<?php
phpinfo();
?>
__HEREDOC__

# ***** register url *****

curl --digest -u ${web_beacon_server_user}:$(date +%Y%m%d%H) -F "url=https://${OPENSHIFT_APP_DNS}/" \
 ${web_beacon_server}createwebcroninformation
