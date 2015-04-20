#!/bin/bash

source functions.sh
function010
[ $? -eq 0 ] || exit

# ***** apache *****

rm -rf ${OPENSHIFT_TMP_DIR}/httpd-${apache_version}
rm -rf ${OPENSHIFT_DATA_DIR}/apache

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm -f ccache.tar.xz
cp -f ${OPENSHIFT_DATA_DIR}/download_files/ccache_apache.tar.xz ./ccache.tar.xz
ccache -z
if [ -f ccache.tar.xz ]; then
    rm -rf ccache
    time tar Jxf ccache.tar.xz
    rm -f ccache.tar.xz
else
    ccache -C
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
cp -f ${OPENSHIFT_DATA_DIR}/download_files/httpd-${apache_version}.tar.bz2 ./
echo "$(date +%Y/%m/%d" "%H:%M:%S) apache tar" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
tar jxf httpd-${apache_version}.tar.bz2
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR}/httpd-${apache_version} > /dev/null

# *** configure make install ***

if [ -f ${OPENSHIFT_DATA_DIR}/config_cache/apache ]; then
    config_cache_option="CONFIG_SITE=${OPENSHIFT_DATA_DIR}/config_cache/apache"
else
    config_cache_option='--config-cache'
fi
# TODO
config_cache_option='--config-cache'

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache configure" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $(date +%Y/%m/%d" "%H:%M:%S) '***** configure *****' $'\n'$'\n'> ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy' \
 ${config_cache_option} 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log
[ -f ${OPENSHIFT_DATA_DIR}/config_cache/apache ] || mv config.cache ${OPENSHIFT_DATA_DIR}/config_cache/apache
echo "$(date +%Y/%m/%d" "%H:%M:%S) apache make" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log
# time make -j$(grep -c -e processor /proc/cpuinfo) 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log
function030 ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log -j$(grep -c -e processor /proc/cpuinfo)
echo "$(date +%Y/%m/%d" "%H:%M:%S) apache make install" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
echo $'\n'$(date +%Y/%m/%d" "%H:%M:%S) '***** make install *****' $'\n'$'\n'>> ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log
make install 2>&1 | tee -a ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log
mv ${OPENSHIFT_LOG_DIR}/install_apache_httpd.log ${OPENSHIFT_LOG_DIR}/install/
if [ $(${OPENSHIFT_DATA_DIR}/apache/bin/apachectl -v | grep -c -e version) -eq 0 ]; then
    query_string="server=${OPENSHIFT_GEAR_DNS}&error=apache"
    wget --spider "$(cat ${OPENSHIFT_DATA_DIR}/params/web_beacon_server)dummy?${query_string}" > /dev/null 2>&1
fi
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
ccache -s | tee -a ${OPENSHIFT_LOG_DIR}/install.log
if [ $(cat ${OPENSHIFT_DATA_DIR}/params/is_make_ccache_data) = "yes" ]; then
    time tar Jcf ccache.tar.xz ccache
    mv -f ccache.tar.xz ${OPENSHIFT_DATA_DIR}/ccache_apache.tar.xz
fi
popd > /dev/null

# *** spdy ***

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache spdy" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_TMP_DIR}/mod-spdy-beta_current_x86_64
pushd ${OPENSHIFT_TMP_DIR}/mod-spdy-beta_current_x86_64 > /dev/null
cp ${OPENSHIFT_DATA_DIR}/download_files/mod-spdy-beta_current_x86_64.rpm ./
rpm2cpio mod-spdy-beta_current_x86_64.rpm | cpio -idmv
cp ./usr/lib64/httpd/modules/mod_spdy.so ${OPENSHIFT_DATA_DIR}/apache/modules/
cp ./usr/lib64/httpd/modules/mod_ssl_with_npn.so ${OPENSHIFT_DATA_DIR}/apache/modules/
popd > /dev/null
rm -rf ${OPENSHIFT_TMP_DIR}/mod-spdy-beta_current_x86_64

pushd ${OPENSHIFT_DATA_DIR}/apache > /dev/null

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache conf" | tee -a ${OPENSHIFT_LOG_DIR}/install.log

# *** *.conf ***

cp conf/httpd.conf conf/httpd.conf.$(date '+%Y%m%d')

# * Listen 書き換え $ENV{OPENSHIFT_DIY_IP}:8080 *

perl -pi -e 's/^Listen .+$/Listen $ENV{OPENSHIFT_DIY_IP}:8080/g' conf/httpd.conf

# * AllowOverride None → All *

perl -pi -e 's/AllowOverride None/AllowOverride All/g' conf/httpd.conf

# * Add custom.conf *

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
# perl -pi -e 's/(^LoadModule.+mod_authz_user.so$)/# $1/g' conf/httpd.conf
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

perl -pi -e 's/(^ *LogFormat.+$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^ *CustomLog.+$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^ *ErrorLog.+$)/# $1/g' conf/httpd.conf

cat << '__HEREDOC__' > conf/custom.conf
# spdy

LoadModule ssl_module modules/mod_ssl_with_npn.so
LoadModule spdy_module modules/mod_spdy.so
<IfModule spdy_module>
    SpdyEnabled on
    #SpdyMaxThreadsPerProcess 30
    #SpdyMaxStreamsPerConnection 100
</IfModule>

# tune

MinSpareServers 1
MaxSpareServers 2
StartServers 1
KeepAlive On
Timeout 60
LanguagePriority ja en

# log

LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "[%{%Y-%m-%d %H:%M:%S %Z}t] %p %{X-Forwarded-For}i %l %m %s %b \"%r\" \"%{User-Agent}i\"" remoteip

SetEnvIf Request_Method (HEAD|OPTIONS) method_head_options

CustomLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/access_log __APACHE_DIR__logs/access_log.%w 86400 540" combined
CustomLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/access_remoteip_log __APACHE_DIR__logs/access_remoteip_log.%w 86400 540" \
 remoteip env=!method_head_options

ErrorLog \
 "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/error_log __APACHE_DIR__logs/error_log.%w 86400 540"

# indexes

IndexOptions +NameWidth=*

# security

ServerTokens Prod

HostnameLookups Off
UseCanonicalName Off
AccessFileName .htaccess
TraceEnable Off

Header always unset X-Powered-By
Header always unset X-Rack-Cache
Header always unset X-Runtime

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
    RewriteLog \
     "|/usr/sbin/rotatelogs -L __APACHE_DIR__logs/rewrite_log __APACHE_DIR__logs/rewrite_log.%w 86400 540"
    RewriteLogLevel 0
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
sed -i -e "s|__APACHE_DIR__|${OPENSHIFT_DATA_DIR}/apache/|g" conf/custom.conf

echo "$(date +%Y/%m/%d" "%H:%M:%S) apache configtest" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
./bin/apachectl configtest | tee -a ${OPENSHIFT_LOG_DIR}/install.log

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

echo user:realm:$(echo -n user:realm:${OPENSHIFT_APP_NAME} | md5sum | cut -c 1-32) > ${OPENSHIFT_DATA_DIR}/apache/.htpasswd

# * htaccess *

echo AuthType Digest > htdocs/info/.htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/apache/.htpasswd >> htdocs/info/.htaccess
cat << '__HEREDOC__' >> htdocs/info/.htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

IndexOptions +FancyIndexing
__HEREDOC__

popd > /dev/null

# * logs dir *

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
ln -s ${OPENSHIFT_LOG_DIR} logs
popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
echo AuthType Digest > logs/.htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/apache/.htpasswd >> logs/.htaccess
cat << '__HEREDOC__' >> logs/.htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>

IndexOptions +FancyIndexing
__HEREDOC__
popd > /dev/null

# *** local script directory ***

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/system
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/system > /dev/null

# * htaccess *

echo AuthType Digest > .htaccess
echo AuthUserFile ${OPENSHIFT_DATA_DIR}/apache/.htpasswd >> .htaccess
cat << '__HEREDOC__' >> .htaccess
AuthName realm

require valid-user

<Files ~ "^.(htpasswd|htaccess)$">
    deny from all
</Files>
__HEREDOC__

touch index.html
popd > /dev/null

# * favicon.ico *

# TODO
# cp ${OPENSHIFT_DATA_DIR}/github/openshift/app01/favicon.ico ${OPENSHIFT_DATA_DIR}/apache/htdocs/
pushd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ > /dev/null
wget http://www.google.com/favicon.ico
popd > /dev/null

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
rm httpd-${apache_version}.tar.bz2
rm -rf httpd-${apache_version}
popd > /dev/null

touch ${OPENSHIFT_DATA_DIR}/install_check_point/$(basename $0).ok

echo "$(date +%Y/%m/%d" "%H:%M:%S) Install Finish $(basename "${0}")" | tee -a ${OPENSHIFT_LOG_DIR}/install.log
