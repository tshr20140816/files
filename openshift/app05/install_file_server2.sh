#!/bin/bash

# rhc setup --server openshift.redhat.com --create-token -l mail_address -p password
# rhc app create xxx php-5.4 cron-1.4 --server openshift.redhat.com

set -x

export TZ=JST-9

php -v

# ***** args *****

if [ $# -ne 1 ]; then
    echo "arg1 : file upload password"
    exit
fi

file_upload_password=${1}

# ***** ccache file upload *****

mkdir ${OPENSHIFT_DATA_DIR}/files
# TODO change apache path
# ln -s ${OPENSHIFT_DATA_DIR}/files files

# TODO change apache path
pushd /tmp > /dev/null
cat << '__HEREDOC__' > ccache_file_upload_counter.php
<?php
$pw=$_POST['password'];
$host_name=$_POST['hostname'];
if ( $pw !== '__FILE_UPLOAD_PASSWORD__' ){
    exit();
}
if ( preg_match("/^\w+?-\w+$/", $host_name) ){
    $file_name = '__OPENSHIFT_TMP_DIR__/url_ccache_tar_xz.txt';
    file_put_contents($file_name, $host_name);
}
?>
__HEREDOC__
sed -i -e "s|__FILE_UPLOAD_PASSWORD__|${file_upload_password}|g" ccache_file_upload_counter.php
sed -i -e "s|__OPENSHIFT_TMP_DIR__|${OPENSHIFT_TMP_DIR}|g" ccache_file_upload_counter.php
php -l ccache_file_upload_counter.php
popd > /dev/null

# ***** cron hourly *****

pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f ./*
touch jobs.deny

# *** ccache file download ***

cat << '__HEREDOC__' > ccache_file_download.sh
#!/bin/bash

export TZ=JST-9
[ -f ${OPENSHIFT_TMP_DIR}/url_ccache_tar_xz.txt ] || exit

host_name=$(cat ${OPENSHIFT_TMP_DIR}/url_ccache_tar_xz.txt)

[ $(wget -nv --spider -t 1 https://${host_name}.rhcloud.com/ccache.tar.xz 2>&1 | grep -c '200 OK') -eq 1 ] || exit

wget https://${host_name}.rhcloud.com/ccache.tar.xz
rm -f ${OPENSHIFT_TMP_DIR}/url_ccache_tar_xz.txt
mv -f ccache.tar.xz ${OPENSHIFT_DATA_DIR}/files/
__HEREDOC__
chmod +x ccache_file_download.sh
echo ccache_file_download.sh >> jobs.allow

popd  > /dev/null

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

# *** gem ***

cat << '__HEREDOC__' > gem.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_DATA_DIR}/files/ > /dev/null

for gem in bundler rack passenger
do
    rm -f ${gem}.html
    # --no-check-certificate
    wget https://rubygems.org/gems/${gem} -O ${gem}.html
    version=$(grep -e canonical ${gem}.html | sed -r -e 's|^.*versions/(.+)".*$|\1|g')
    if [ ! -f ${gem}-${version}.gem ]; then
        wget https://rubygems.org/downloads/${gem}-${version}.gem -O ${gem}-${version}.gem
        perl -pi -e 's/(\r|\n)//g' ${gem}.html
        perl -pi -e 's/.*gem__sha"> +//g' ${gem}.html
        perl -pi -e 's/ +<.*//g' ${gem}.html
        gem_sha256=$(cat ${gem}.html)
        file_sha256=$(sha256sum ${gem}-${version}.gem | cut -d ' ' -f 1)
        if [ "${gem_sha256}" != "${file_sha256}" ]; then
            rm ${gem}-${version}.gem
        fi
    fi
    rm -f ${gem}.html
done
popd > /dev/null
__HEREDOC__
chmod +x gem.sh
echo gem.sh >> jobs.allow
./gem.sh

# *** download_file_list ***
# https://github.com/tshr20140816/files/raw/master/openshift/app05/download_file_list.txt

cat << '__HEREDOC__' > download_file_list.sh
#!/bin/bash

export TZ=JST-9
pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f download_file_list.txt
wget https://github.com/tshr20140816/files/raw/master/openshift/app05/download_file_list.txt
while read LINE
do
    file_name=$(echo "${LINE}" | awk '{print $1}')
    if [ ! -t ${OPENSHIFT_DATA_DIR}/files/${file_name} ]; then
        url=$(echo "${LINE}" | awk '{print $2}')
        rm -f ${file_name}
        wget ${url} -O ${file_name}
        mv -f ${file_name} ${OPENSHIFT_DATA_DIR}/files/
    fi
done < download_file_list.txt
popd > /dev/null
__HEREDOC__
chmod +x download_file_list.sh
echo download_file_list.sh >> jobs.allow
./download_file_list.sh

popd > /dev/null

# ***** log dir digest auth *****

pushd ${OPENSHIFT_LOG_DIR} > /dev/null

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/.htpasswd
echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/.htpasswd >> .htaccess

cat << '__HEREDOC__' > .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

IndexOptions +FancyIndexing

RewriteEngine on
RewriteCond %{HTTP:X-Forwarded-Proto} !https
RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
__HEREDOC__
popd > /dev/null

# TODO logs dir

# /usr/bin/gear stop
# /usr/bin/gear start
