#!/bin/bash

# rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com

# cd /tmp && wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/install_file_server5.sh && chmod +x install_file_server5.sh && ./install_file_server5.sh | tee ${OPENSHIFT_LOG_DIR}/install.log

set -x

export TZ=JST-9

# ***** args *****

if [ $# -ne 3 ]; then
    echo "arg1 : build password"
    exit
fi

build_password=${1}

mkdir ${OPENSHIFT_DATA_DIR}/files
pushd ${OPENSHIFT_REPO_DIR} > /dev/null
ln -s ${OPENSHIFT_DATA_DIR}/files files
popd > /dev/null

# ccache_version 3.2.2

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ***** ccache *****

ccache_version=3.2.2

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f ccache-${ccache_version}.tar.xz
wget http://samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz
tar Jxf ccache-${ccache_version}.tar.xz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version} > /dev/null
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/ccache \
 --infodir=${OPENSHIFT_TMP_DIR}/man \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc
time make -j$(grep -c -e processor /proc/cpuinfo)
make install
popd > /dev/null
rm -rf ${OPENSHIFT_TMP_DIR}/ccache-${ccache_version}
rm -f ccache-${ccache_version}.tar.xz

# ***** build action *****

pushd  ${OPENSHIFT_DATA_DIR}/files/ > /dev/null

: << '__COMMENT__'
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <passsword value="" />
  <uuid value="" />
  <data_dir value="" />
  <tmp_dir value="" />
  <items>
    <item app="" version="" />
  </items>
</root>
__COMMENT__

cat << '__HEREDOC__' > build_action.php
<?php
$file_name = getenv('OPENSHIFT_DATA_DIR') . 'version_list';
$xml_data = file_get_contents('php://input');
$xml = simplexml_load_string($xml_data);
$password = $xml->passsword['value'];
if ( $password != '__BUILD_PASSWORD__' )
{
    die;
}
$uuid = $xml->uuid['value'];
$data_dir = $xml->data_dir['value'];
$tmp_dir = $xml->tmp_dir['value'];
unlink($file_name);
foreach($xml->items->item as $item)
{
    file_put_contents($file_name, $item['app'] . '_version ' . $item['version'] . "\n", FILE_APPEND);
}
file_put_contents(getenv('OPENSHIFT_DATA_DIR') . 'build_action_params', $uuid . ' ' . $data_dir . ' ' . $tmp_dir);
?>
__HEREDOC__
sed -i -e "s|__BUILD_PASSWORD__|${build_password}|g" build_action.php
popd > /dev/null

pushd  ${OPENSHIFT_DATA_DIR} > /dev/null
wget --no-cache https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/build_action3.sh
popd > /dev/null

# ***** cron minutely *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f ./*
touch jobs.deny

# *** index.html ***

cat << '__HEREDOC__' > make_index.sh
#!/bin/bash

export TZ=JST-9

pushd ${OPENSHIFT_DATA_DIR}/files > /dev/null
echo "<HTML><BODY><PRE>" > ${OPENSHIFT_TMP_DIR}/index.html
ls -lang >> ${OPENSHIFT_TMP_DIR}/index.html
echo "</PRE></BODY></HTML>" >> ${OPENSHIFT_TMP_DIR}/index.html
mv -f ${OPENSHIFT_TMP_DIR}/index.html ./
popd > /dev/null

pushd ${OPENSHIFT_LOG_DIR} > /dev/null
echo "<HTML><BODY><PRE>" > ${OPENSHIFT_TMP_DIR}/index.html
ls -lang >> ${OPENSHIFT_TMP_DIR}/index.html
echo "</PRE></BODY></HTML>" >> ${OPENSHIFT_TMP_DIR}/index.html
mv -f ${OPENSHIFT_TMP_DIR}/index.html ./
popd > /dev/null
__HEREDOC__
chmod +x make_index.sh
echo make_index.sh >> jobs.allow

# *** build action ***

cat << '__HEREDOC__' > build_action_start.sh
#!/bin/bash

export TZ=JST-9

[ ! -f ${OPENSHIFT_DATA_DIR}/build_action_params ] && exit

set -x

echo 'build start'
ymdhms=$(date +%Y%m%d%H%M%S)

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
rm -f build_action3.sh
wget --no-cache https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app05/build_action3.sh
popd > /dev/null
params=$(cat ${OPENSHIFT_DATA_DIR}/build_action_params)
echo "${params}"
nohup bash ${OPENSHIFT_DATA_DIR}/build_action3.sh ${params} \
 >> ${OPENSHIFT_LOG_DIR}/nohup.${ymdhms}.log \
 2>> ${OPENSHIFT_LOG_DIR}/nohup_error.${ymdhms}.log &

rm -f ${OPENSHIFT_DATA_DIR}/build_action_params
__HEREDOC__
chmod +x build_action_start.sh
echo build_action_start.sh >> jobs.allow

popd > /dev/null

# ***** cron hourly *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f ./*
touch jobs.deny

# *** rm build files ***

cat << '__HEREDOC__' > rm_build_files.sh
#!/bin/bash

export TZ=JST-9

find ${OPENSHIFT_DATA_DIR}/files/ -name '*_maked_*' -type f -mmin +600 -print0
find ${OPENSHIFT_DATA_DIR}/files/ -name '*_maked_*' -type f -mmin +600 -print0 | xargs -0i rm -f {}
find ${OPENSHIFT_LOG_DIR} -name 'nohup*' -type f -mmin +600 -print0
find ${OPENSHIFT_LOG_DIR} -name 'nohup*' -type f -mmin +600 -print0 | xargs -0i rm -f {}
find ${OPENSHIFT_TMP_DIR} -name 'ruby-build.*' -type f -mmin +600 -print0
find ${OPENSHIFT_TMP_DIR} -name 'ruby-build.*' -type f -mmin +600 -print0 | xargs -0i rm -f {}
__HEREDOC__
chmod +x rm_build_files.sh
echo rm_build_files.sh >> jobs.allow

popd > /dev/null

# ***** cron daily *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f ./*
touch jobs.deny

# *** quota ***

cat << '__HEREDOC__' > quota_info.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_LOG_DIR} > /dev/null
quota -s > quota.txt
popd > /dev/null
__HEREDOC__
chmod +x quota_info.sh
echo quota_info.sh >> jobs.allow
./quota_info.sh

# ***** log dir digest auth *****

pushd ${OPENSHIFT_LOG_DIR} > /dev/null

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> .htaccess

cat << '__HEREDOC__' >> .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

AddType "text/plain; charset=UTF-8" .log

# IndexOptions +FancyIndexing

# Force https
RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_REPO_DIR} > /dev/null
ln -s ${OPENSHIFT_LOG_DIR} logs
popd > /dev/null

# /usr/bin/gear stop
# /usr/bin/gear start
