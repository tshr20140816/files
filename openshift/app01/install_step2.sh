#!/bin/bash

set -x

while read LINE
do
  product=`echo $LINE | awk '{print $1}'`
  version=`echo $LINE | awk '{print $2}'`
  eval "$product"=$version
done < ${OPENSHIFT_DATA_DIR}/version_list

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** apache *****

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/httpd-${apache_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` apache tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz httpd-${apache_version}.tar.gz
popd > /dev/null
pushd ${OPENSHIFT_TMP_DIR}/httpd-${apache_version} > /dev/null

# *** configure make install ***

echo `date +%Y/%m/%d" "%H:%M:%S` apache configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure --prefix=${OPENSHIFT_DATA_DIR}/apache \
--enable-mods-shared='all proxy' 2>&1 | tee ${OPENSHIFT_LOG_DIR}/httpd.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` apache make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` apache make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
echo `date +%Y/%m/%d" "%H:%M:%S` apache conf >> ${OPENSHIFT_LOG_DIR}/install.log
popd > /dev/null
pushd ${OPENSHIFT_DATA_DIR}/apache > /dev/null

# *** *.conf ***

cp conf/httpd.conf conf/httpd.conf.`date '+%Y%m%d'`

# * Listen 書き換え $ENV{OPENSHIFT_DIY_IP}:8080 *

perl -pi -e 's/^Listen .+$/Listen $ENV{OPENSHIFT_DIY_IP}:8080/g' conf/httpd.conf
cat << '__HEREDOC__' >> conf/httpd.conf

Include conf/custom.conf
__HEREDOC__

# * DirectoryIndex に index.php 追加 *

perl -pi -e 's/(^ +DirectoryIndex .*$)/$1 index.php/g' conf/httpd.conf

# * 未使用モジュールコメントアウト *

perl -pi -e 's/(^LoadModule.+mod_authn_anon.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authn_dbm.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_dbm.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_groupfile.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_owner.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authz_user.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_info.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_balancer.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_ftp.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_speling.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_status.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_userdir.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_version.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_vhost_alias.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_authn_dbd.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_dbd.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_log_forensic.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_ajp.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_scgi.so$)/# $1/g' conf/httpd.conf

cat << '__HEREDOC__' >> conf/custom.conf
# tune

MinSpareServers 1
MaxSpareServers 5
StartServers 1
KeepAlive On
Timeout 30

# security

ServerTokens Prod

HostnameLookups Off
UseCanonicalName Off
AccessFileName .htaccess

Header always unset "X-Powered-By"
Header always unset "X-Rack-Cache"
Header always unset "X-Runtime"

# delegate

ProxyRequests Off
ProxyPass /mail/ http://__OPENSHIFT_DIY_IP__:30080/mail/
ProxyPassReverse /mail/ http://__OPENSHIFT_DIY_IP__:30080/mail/
ProxyMaxForwards 10

# php

AddType application/x-httpd-php .php

<FilesMatch ".php$">
    SetHandler application/x-httpd-php
</FilesMatch>

# Header unset x-powered-by
# Header set server Apache

# deflate

<Location />
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary
    Header append Vary User-Agent env=!dont-vary
</Location>

# force ssl

<IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteCond %{HTTP:X-Forwarded-Proto} !https
    RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
</IfModule>

# delete etag

<ifModule mod_headers.c>
    Header unset ETag
</ifModule>

FileETag None

# memory cache

<IfModule mod_cache.c>
    LoadModule mem_cache_module modules/mod_mem_cache.so
    <IfModule mod_mem_cache.c>
        CacheEnable mem /
        MCacheSize 4096
        MCacheMaxObjectCount 100
        MCacheMinObjectSize 1
        MCacheMaxObjectSize 2048
    </IfModule>
</IfModule>
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' conf/custom.conf

# *** robots.txt ***

cat << '__HEREDOC__' > htdocs/robots.txt
User-agent: *
Disallow: /
__HEREDOC__

# *** info ***

mkdir htdocs/info

cat << '__HEREDOC__' > htdocs/info/phpinfo.php
<?php
phpinfo();
?>
__HEREDOC__

# * htpassword *
# more arrange please

echo user:realm:`echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32` > ${OPENSHIFT_DATA_DIR}/apache/.htpasswd

# * htaccess *

echo AuthType Digest > htdocs/info/.htaccess
echo AuthUserFile $OPENSHIFT_DATA_DIR/apache/.htpasswd >> htdocs/info/.htaccess
cat << '__HEREDOC__' >> htdocs/info/.htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>
__HEREDOC__

popd > /dev/null

# * logs dir *

pushd $OPENSHIFT_DATA_DIR/apache/htdocs/ > /dev/null
ln -s ${OPENSHIFT_LOG_DIR} logs
popd > /dev/null

pushd $OPENSHIFT_DATA_DIR/apache/htdocs/ > /dev/null
echo AuthType Digest > logs/.htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/apache/.htpasswd >> logs/.htaccess
cat << '__HEREDOC__' >> logs/.htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>
__HEREDOC__
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm httpd-${apache_version}.tar.gz
rm -rf httpd-${apache_version}
popd > /dev/null

echo `date +%Y/%m/%d" "%H:%M:%S` Install STEP 2 Finish >> ${OPENSHIFT_LOG_DIR}/install.log
