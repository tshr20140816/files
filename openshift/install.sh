#!/bin/bash

set -x

# apache_version='2.2.27'
apache_version='2.2.29'
# php_version='5.5.16'
php_version='5.6.0'
delegate_version='9.9.11'
mrtg_version='2.17.4'
webalizer_version='2.23-08'
# wordpress_version='3.9.2-ja'
wordpress_version='4.0-ja'
ttrss_version='1.13'
memcached_version='1.4.20'
libmemcached_version='1.0.18'
memcached_php_ext_version='2.2.0'
gperf_version='3.0.4'

# port map
# 8080 apache
# 58080 delegate
# 51121 memcached

export TZ=JST-9
echo `date +%Y/%m/%d" "%H:%M:%S` Install Start >> ${OPENSHIFT_LOG_DIR}/install.log
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

bash --version
perl --version
php --version
python --version
ruby --version
httpd --version

# ***** download files *****

cd ${OPENSHIFT_TMP_DIR}
mkdir download_files
cd download_files

files_exists=0
for i in `seq 0 9`
do
    files_exists=1

    # *** apache ***
    if [ ! -f httpd-${apache_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` apache wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ftp.riken.jp/net/apache//httpd/httpd-${apache_version}.tar.gz
    fi
    if [ ! -f httpd-${apache_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** gperf ***
    if [ ! -f gperf-${gperf_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` php wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ftp.gnu.org/gnu/gperf/gperf-${gperf_version}.tar.gz
    fi
    if [ ! -f gperf-${gperf_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** php ***
    if [ ! -f php-${php_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` php wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://jp1.php.net/get/php-${php_version}.tar.gz/from/this/mirror -O php-${php_version}.tar.gz
    fi
    if [ ! -f php-${php_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** memcached ***
    if [ ! -f memcached-${memcached_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.memcached.org/files/memcached-${memcached_version}.tar.gz
    fi
    if [ ! -f memcached-${memcached_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** libmemcached ***
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz
    fi
    if [ ! -f libmemcached-${libmemcached_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** memcached (php extension) ***
    if [ ! -f memcached-${memcached_php_ext_version}.tgz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` memcached php extension wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://pecl.php.net/get/memcached-${memcached_php_ext_version}.tgz
    fi
    if [ ! -f memcached-${memcached_php_ext_version}.tgz ]; then
        files_exists=0
    fi

    # *** delegate ***
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` delegate wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://www.delegate.org/anonftp/DeleGate/delegate${delegate_version}.tar.gz
    fi
    if [ ! -f delegate${delegate_version}.tar.gz ]; then
        files_exists=0
    fi
    if [ ! -f delegated.xz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` delegate binary wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/tshr20140816/files/raw/master/openshift/delegated.xz
    fi
    if [ ! -f delegated.xz ]; then
        files_exists=0
    fi

    # *** mrtg ***
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mrtg wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://oss.oetiker.ch/mrtg/pub/mrtg-${mrtg_version}.tar.gz
    fi
    if [ ! -f mrtg-${mrtg_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** webalizer ***
    if [ ! -f webalizer-${webalizer_version}-src.tgz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` webalizer wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget ftp://ftp.mrunix.net/pub/webalizer/webalizer-${webalizer_version}-src.tgz
    fi
    if [ ! -f webalizer-${webalizer_version}-src.tgz ]; then
        files_exists=0
    fi

    # *** wordpress ***
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` wordpress wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
    fi
    if [ ! -f wordpress-${wordpress_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** Tiny Tiny RSS ***
    if [ ! -f ${ttrss_version}.tar.gz ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://github.com/gothfox/Tiny-Tiny-RSS/archive/${ttrss_version}.tar.gz
    fi
    if [ ! -f ${ttrss_version}.tar.gz ]; then
        files_exists=0
    fi

    # *** PHP iCalendar ***
    if [ ! -f phpicalendar-2.4_20100615.tar.bz2 ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` PHP iCalendar wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget http://downloads.sourceforge.net/project/phpicalendar/phpicalendar/phpicalendar%202.4%20RC7/phpicalendar-2.4_20100615.tar.bz2
    fi
    if [ ! -f phpicalendar-2.4_20100615.tar.bz2 ]; then
        files_exists=0
    fi

    # *** etc ***
    if [ ! -f is_ssl.php ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` is_ssl.php wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://gist.githubusercontent.com/franz-josef-kaiser/1891564/raw/9d3f519c1cfb0fff9ad5ca31f3e783deaf5d561c/is_ssl.php
    fi
    if [ ! -f is_ssl.php ]; then
        files_exists=0
    fi
    if [ ! -f ical_parser.php.patch ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` ical_parser.php.patch wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/icalendar/ical_parser.php.patch
    fi
    if [ ! -f ical_parser.php.patch ]; then
        files_exists=0
    fi
    if [ ! -f mysql_backup.sh ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` mysql_backup.sh wget >> ${OPENSHIFT_LOG_DIR}/install.log
        wget https://raw.githubusercontent.com/tshr20140816/files/master/openshift/redmine/mysql_backup.sh
    fi
    if [ ! -f mysql_backup.sh ]; then
        files_exists=0
    fi
    if [ ! -f salt.txt ]; then
        echo `date +%Y/%m/%d" "%H:%M:%S` salt.txt wget >> ${OPENSHIFT_LOG_DIR}/install.log
        curl -o ./salt.txt https://api.wordpress.org/secret-key/1.1/salt/
    fi
    if [ ! -f salt.txt ]; then
        files_exists=0
    fi

    if [ ${files_exists} -eq 1 ]; then
        break
    else
        sleep 10s
    fi
done

if [ ${files_exists} -eq 0 ]; then
    echo `date +%Y/%m/%d" "%H:%M:%S` file download error >> ${OPENSHIFT_LOG_DIR}/install.log
    exit 1
fi

# ***** git etc *****

if [ -d ${OPENSHIFT_DATA_DIR}/github ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` git skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `date +%Y/%m/%d" "%H:%M:%S` git >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_DATA_DIR}
mkdir github
cd github
git init
git remote add origin https://github.com/tshr20140816/files.git
git pull origin master

cd ${OPENSHIFT_DATA_DIR}
if [ ! -f ${OPENSHIFT_DATA_DIR}/.exrc ]
then
echo "set number" >> .exrc
fi

fi

# ***** apache *****

cd ${OPENSHIFT_TMP_DIR}
if [ -d ${OPENSHIFT_DATA_DIR}/apache ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` apache skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

cp ${OPENSHIFT_TMP_DIR}/download_files/httpd-${apache_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` apache tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz httpd-${apache_version}.tar.gz
cd httpd-${apache_version}
echo `date +%Y/%m/%d" "%H:%M:%S` apache configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure --prefix=${OPENSHIFT_DATA_DIR}/apache \
--enable-mods-shared='all proxy' 2>&1 | tee ${OPENSHIFT_LOG_DIR}/httpd.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` apache make >> ${OPENSHIFT_LOG_DIR}/install.log
time make -j2
echo `date +%Y/%m/%d" "%H:%M:%S` apache make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
echo `date +%Y/%m/%d" "%H:%M:%S` apache conf >> ${OPENSHIFT_LOG_DIR}/install.log
cd ${OPENSHIFT_DATA_DIR}/apache
cp conf/httpd.conf conf/httpd.conf.`date '+%Y%m%d'`
perl -pi -e 's/^Listen .+$/Listen $ENV{OPENSHIFT_DIY_IP}:8080/g' conf/httpd.conf
cat << '__HEREDOC__' >> conf/httpd.conf

Include conf/custom.conf
__HEREDOC__
perl -pi -e 's/(^ +DirectoryIndex .*$)/$1 index.php/g' conf/httpd.conf

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
perl -pi -e 's/(^LoadModule.+mod_authn_dbd.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_dbd.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_log_forensic.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_ajp.so$)/# $1/g' conf/httpd.conf
perl -pi -e 's/(^LoadModule.+mod_proxy_scgi.so$)/# $1/g' conf/httpd.conf

cat << '__HEREDOC__' >> conf/custom.conf
MinSpareServers 1
MaxSpareServers 5
StartServers 1
KeepAlive On
Timeout 30

ServerTokens Prod

HostnameLookups Off
UseCanonicalName Off
AccessFileName .htaccess

# for delegate
ProxyRequests Off
ProxyPass /mail/ http://__OPENSHIFT_DIY_IP__:50080/mail/
ProxyPassReverse /mail/ http://__OPENSHIFT_DIY_IP__:50080/mail/
ProxyMaxForwards 10

AddType application/x-httpd-php .php

<FilesMatch ".php$">
    SetHandler application/x-httpd-php
</FilesMatch>

Header unset x-powered-by
Header set server Apache

<Location />
    SetOutputFilter DEFLATE
    SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary
    Header append Vary User-Agent env=!dont-vary
</Location>

<IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteCond %{HTTP:X-Forwarded-Proto} !https
    RewriteRule .* https://%{HTTP_HOST}%{REQUEST_URI} [R,L]
</IfModule>

<ifModule mod_headers.c>
    Header unset ETag
</ifModule>

FileETag None

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

cat << '__HEREDOC__' > htdocs/robots.txt
User-agent: *
Disallow: /
__HEREDOC__

cd ${OPENSHIFT_TMP_DIR}
rm httpd-${apache_version}.tar.gz
rm -rf httpd-${apache_version}

# *** gperf ***

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/gperf-${gperf_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` gperf tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz gperf-${gperf_version}.tar.gz
cd gperf-${gperf_version}
echo `date +%Y/%m/%d" "%H:%M:%S` gperf configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/local

echo `date +%Y/%m/%d" "%H:%M:%S` gperf make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` gperf make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
export PATH=$PATH:${OPENSHIFT_DATA_DIR}/local/bin

# *** depot_tools ***

# https://developers.google.com/speed/pagespeed/module/build_mod_pagespeed_from_source

cd ${OPENSHIFT_DATA_DIR}

echo `date +%Y/%m/%d" "%H:%M:%S` depot_tools svn >> ${OPENSHIFT_LOG_DIR}/install.log
mkdir -p google/bin
cd google/bin
svn co http://src.chromium.org/svn/trunk/tools/depot_tools
export PATH=$PATH:${OPENSHIFT_DATA_DIR}/google/bin/depot_tools

# *** pagespeed ***

cd ${OPENSHIFT_TMP_DIR}
mkdir mod_pagespeed
cd mod_pagespeed
gclient config http://modpagespeed.googlecode.com/svn/branches/latest-beta/src
gclient sync --force --jobs=1

cd src
make AR.host=`pwd`/build/wrappers/ar.sh AR.target=`pwd`/build/wrappers/ar.sh BUILDTYPE=Release
APXS_BIN=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
APACHE_ROOT=${OPENSHIFT_DATA_DIR}/apache \
./install_apxs.sh

# ToDo

fi

# ***** ruby *****

# http://diary-satoryu.rhcloud.com/?date=201307

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

echo `date +%Y/%m/%d" "%H:%M:%S` rbenv install >> ${OPENSHIFT_LOG_DIR}/install.log

# https://github.com/Seppone/openshift-rbenv-installer
cd ${OPENSHIFT_TMP_DIR}
curl -L https://raw.github.com/Seppone/openshift-rbenv-installer/master/bin/rbenv-installer | bash

export RBENV_ROOT=${OPENSHIFT_DATA_DIR}/.rbenv
export PATH="${OPENSHIFT_DATA_DIR}/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

echo `date +%Y/%m/%d" "%H:%M:%S` ruby rbenv >> ${OPENSHIFT_LOG_DIR}/install.log
ruby -v
rbenv install 1.9.3-p547
rbenv global 1.9.3-p547
ruby -v

# ***** passenger *****

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

echo `date +%Y/%m/%d" "%H:%M:%S` passenger gem >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_DATA_DIR}
mkdir gems
gem install passenger --install-dir ${OPENSHIFT_DATA_DIR}/gems/ --no-ri --no-rdoc

# ToDo

# export APXS2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs
# export PATH=${OPENSHIFT_DATA_DIR}/apache/bin:$PATH

# passenger-install-apache2-module

# ***** php *****

if [ -d ${OPENSHIFT_DATA_DIR}/php ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` php skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/php-${php_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` php tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz php-${php_version}.tar.gz
cd php-${php_version}
echo `date +%Y/%m/%d" "%H:%M:%S` php configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--with-curl \
--with-libdir=lib64 \
--with-bz2 \
--with-iconv \
--with-openssl \
--with-zlib \
--enable-exif \
--enable-ftp \
--enable-xml \
--enable-mbstring \
--enable-mbregex \
--enable-sockets \
--with-gettext=${OPENSHIFT_DATA_DIR}/php 2>&1 | tee ${OPENSHIFT_LOG_DIR}/php.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` php make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` php make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
echo `date +%Y/%m/%d" "%H:%M:%S` php make conf >> ${OPENSHIFT_LOG_DIR}/install.log
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini
cp php.ini-production ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-production
cp php.ini-development ${OPENSHIFT_DATA_DIR}/php/lib/php.ini-development
cd ${OPENSHIFT_DATA_DIR}/php
perl -pi -e 's/^short_open_tag .+$/short_open_tag = On/g' lib/php.ini
perl -pi -e 's/(^;date.timezone =.*$)/$1\r\ndate.timezone = Asia\/Tokyo/g' lib/php.ini

# ToDo
# for memcached
# lib/php.ini
# [Session]
# session.save_handler = memcached
# session.save_path = "__OPENSHIFT_DIY_IP__:51211"
# perl -pi -e "s/__OPENSHIFT_DIY_IP__/${OPENSHIFT_DIY_IP}/g" lib/php.ini

cd ${OPENSHIFT_TMP_DIR}
rm php-${php_version}.tar.gz
rm -rf php-${php_version}

fi

# ***** memcached *****

# *** memcached ***

memcached-${memcached_version}.tar.gz
echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/memcached-${memcached_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` memcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_version}.tar.gz
cd memcached-${memcached_version}
echo `date +%Y/%m/%d" "%H:%M:%S` memcached configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/memcached

echo `date +%Y/%m/%d" "%H:%M:%S` memcached make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` memcached make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

# *** libmemcached ***

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/libmemcached-${libmemcached_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz libmemcached-${libmemcached_version}.tar.gz
cd libmemcached-${libmemcached_version}
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=$OPENSHIFT_DATA_DIR/libmemcached

echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` libmemcached make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

# *** memcached php extention ***

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/memcached-${memcached_php_ext_version}.tgz ./
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz memcached-${memcached_php_ext_version}.tgz
cd memcached-${memcached_php_ext_version}
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext phpize >> ${OPENSHIFT_LOG_DIR}/install.log
${OPENSHIFT_DATA_DIR}/php/bin/phpize
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php_memcached \
--with-libmemcached-dir=$OPENSHIFT_DATA_DIR/libmemcached \
--disable-memcached-sasl \
--enable-memcached \
--with-php-config=${OPENSHIFT_DATA_DIR}/php/bin/php-config

echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` memcached_php_ext make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

# ***** delegate *****

if [ -d ${OPENSHIFT_DATA_DIR}/delegate ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` delegate skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/delegate${delegate_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` delegate tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz delegate${delegate_version}.tar.gz
cd delegate${delegate_version}
# echo `date +%Y/%m/%d" "%H:%M:%S` delegate make >> ${OPENSHIFT_LOG_DIR}/install.log
# perl -pi -e 's/^ADMIN = undef$/ADMIN = admin\@rhcloud.local/g' src/Makefile
# time make -j2 CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe"
mkdir ${OPENSHIFT_DATA_DIR}/delegate/
# cp src/delegated ${OPENSHIFT_DATA_DIR}/delegate/
cp ${OPENSHIFT_TMP_DIR}/download_files/delegated.xz ./
xz -dv delegated.xz
cp ./delegated ${OPENSHIFT_DATA_DIR}/delegate/

# apache htdocs
mkdir -p ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons
cp src/builtin/icons/ysato/*.* ${OPENSHIFT_DATA_DIR}/apache/htdocs/delegate/icons/
# */

cd ${OPENSHIFT_DATA_DIR}/delegate/
cat << '__HEREDOC__' > P50080
-P__OPENSHIFT_DIY_IP__:50080
SERVER=http
ADMIN=admin@rhcloud.local
DGROOT=__OPENSHIFT_DATA_DIR__delegate
MOUNT="/mail/* pop://pop.mail.yahoo.co.jp:110/* noapop"
FTOCL="/bin/sed -f __OPENSHIFT_DATA_DIR__delegate/filter.txt"
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' P50080
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' P50080
cat << '__HEREDOC__' > filter.txt
s/http:..__OPENSHIFT_DIY_IP__:50080.-.builtin.icons.ysato/\/delegate\/icons/g
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DIY_IP__/$ENV{OPENSHIFT_DIY_IP}/g' filter.txt

cd ${OPENSHIFT_TMP_DIR}
rm delegate${delegate_version}.tar.gz
rm -rf delegate${delegate_version}

fi

# ***** mrtg *****

cd ${OPENSHIFT_TMP_DIR}
if [ -d ${OPENSHIFT_DATA_DIR}/mrtg ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` mrtg skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/mrtg-${mrtg_version}.tar.gz ./
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz mrtg-${mrtg_version}.tar.gz
cd mrtg-${mrtg_version}
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure --prefix=${OPENSHIFT_DATA_DIR}/mrtg 2>&1 | tee ${OPENSHIFT_LOG_DIR}/mrtg.configure.log
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg make >> ${OPENSHIFT_LOG_DIR}/install.log
time make
echo `date +%Y/%m/%d" "%H:%M:%S` mrtg make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install
mkdir ${OPENSHIFT_DATA_DIR}/mrtg/workdir
mkdir ${OPENSHIFT_DATA_DIR}/mrtg/scripts
cd ${OPENSHIFT_DATA_DIR}/mrtg

touch scripts/cpu_usage.sh
cat << '__HEREDOC__' > scripts/cpu_usage.sh
#!/bin/bash

echo `cat ${OPENSHIFT_TMP_DIR}/cpu_usage_current`
echo 0
echo dummy
echo cpu usage
__HEREDOC__
chmod +x scripts/cpu_usage.sh

touch scripts/disk_usage.sh
cat << '__HEREDOC__' > scripts/disk_usage.sh
#!/bin/bash

echo `quota | grep -v a | awk '{print $1}'`
echo `quota | grep -v a | awk '{print $3}'`
echo dummy
echo disk usage
__HEREDOC__
chmod +x scripts/disk_usage.sh

touch scripts/file_usage.sh
cat << '__HEREDOC__' > scripts/file_usage.sh
#!/bin/bash

echo `quota | grep -v a | awk '{print $4}'`
echo `quota | grep -v a | awk '{print $6}'`
echo dummy
echo file usage
__HEREDOC__
chmod +x scripts/file_usage.sh

touch scripts/memory_usage.sh
cat << '__HEREDOC__' > scripts/memory_usage.sh
#!/bin/bash

echo `oo-cgroup-read memory.usage_in_bytes | awk '{print $1}'`
echo `oo-cgroup-read memory.limit_in_bytes | awk '{print $1}'`
echo dummy
echo memory usage
__HEREDOC__
chmod +x scripts/memory_usage.sh

cat << '__HEREDOC__' > mrtg.conf
WorkDir: __OPENSHIFT_DATA_DIR__apache/htdocs/mrtg/
HtmlDir: __OPENSHIFT_DATA_DIR__apache/htdocs/mrtg/
ImageDir: __OPENSHIFT_DATA_DIR__apache/htdocs/mrtg/
LogDir: __OPENSHIFT_DATA_DIR__mrtg/log/
Refresh: 60000

Target[disk]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/disk_usage.sh`
Title[disk]: Disk
PageTop[disk]: <h1>Disk</h1>
Options[disk]: gauge, nobanner, growright, unknaszero, noinfo
AbsMax[disk]: 10000000
MaxBytes[disk]: 1048576
kilo[disk]: 1024
YLegend[disk]: Disk Use
LegendI[disk]: Use
LegendO[disk]: Limit
Legend1[disk]: Disk Use
Legend2[disk]: Disk Limit
ShortLegend[disk]: B
Suppress[disk]: y
Factor[disk]: 1024
YTicsFactor[disk]: 1024

Target[file]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/file_usage.sh`
Title[file]: Files
PageTop[file]: <h1>Files</h1>
Options[file]: gauge, nobanner, growright, unknaszero, noinfo, integer
AbsMax[file]: 1000000
MaxBytes[file]: 80000
YLegend[file]: File Count
LegendI[file]: Files
LegendO[file]: Limit
Legend1[file]: File Count
Legend2[file]: File Count Limit
ShortLegend[file]: files
Suppress[file]: y

Target[memory]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/memory_usage.sh`
Title[memory]: Memory
PageTop[memory]: <h1>Memory</h1>
Options[memory]: gauge, nobanner, growright, unknaszero, noinfo
AbsMax[memory]: 5368709120
MaxBytes[memory]: 536870912
YLegend[memory]: Memory Use
LegendI[memory]: Use
LegendO[memory]: Limit
Legend1[memory]: Memory Use
Legend2[memory]: Memory Limit
ShortLegend[memory]: B
Suppress[memory]: y

Target[cpu]: `${OPENSHIFT_DATA_DIR}/mrtg/scripts/cpu_usage.sh`
Title[cpu]: Cpu
PageTop[cpu]: <h1>Cpu</h1>
Options[cpu]: gauge, nobanner, growright, unknaszero, noinfo, noo
AbsMax[cpu]: 200
MaxBytes[cpu]: 100
YLegend[cpu]: Cpu Usage
LegendI[cpu]: Usage
Legend1[cpu]: Cpu Usage
ShortLegend[cpu]: %
Suppress[cpu]: y
WithPeak[cpu]: dwm
Unscaled[cpu]: dwm
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_DATA_DIR__/$ENV{OPENSHIFT_DATA_DIR}/g' mrtg.conf

mkdir ${OPENSHIFT_DATA_DIR}/mrtg/log
mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/mrtg
cd ${OPENSHIFT_DATA_DIR}/mrtg
./bin/indexmaker --output=index.html mrtg.conf
cp index.html ../apache/htdocs/mrtg/

cd ${OPENSHIFT_TMP_DIR}
rm mrtg-${mrtg_version}.tar.gz
rm -rf mrtg-${mrtg_version}

fi

# ***** webalizer *****

cd ${OPENSHIFT_TMP_DIR}
if [ -d ${OPENSHIFT_DATA_DIR}/webalizer ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_TMP_DIR}
cp ${OPENSHIFT_TMP_DIR}/download_files/webalizer-${webalizer_version}-src.tgz ./

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz webalizer-${webalizer_version}-src.tgz
cd webalizer-${webalizer_version}
mv lang/webalizer_lang.japanese lang/webalizer_lang.japanese_euc
iconv -f euc-jp -t utf-8 lang/webalizer_lang.japanese_euc > lang/webalizer_lang.japanese

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer configure >> ${OPENSHIFT_LOG_DIR}/install.log
CFLAGS="-O3 -march=native -pipe" CXXFLAGS="-O3 -march=native -pipe" \
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/webalizer \
--mandir=${OPENSHIFT_DATA_DIR}/webalizer \
--with-language=japanese --enable-dns 2>&1 | tee ${OPENSHIFT_LOG_DIR}/webalizer.configure.log

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make >> ${OPENSHIFT_LOG_DIR}/install.log
time make

echo `date +%Y/%m/%d" "%H:%M:%S` webalizer make install >> ${OPENSHIFT_LOG_DIR}/install.log
make install

# apache htdocs
mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/webalizer
cd ${OPENSHIFT_DATA_DIR}/webalizer/etc
cp webalizer.conf.sample webalizer.conf
echo >> webalizer.conf
echo >> webalizer.conf
echo LogFile ${OPENSHIFT_DATA_DIR}/apache/logs/access_log >> webalizer.conf
echo OutputDir ${OPENSHIFT_DATA_DIR}/apache/htdocs/webalizer >> webalizer.conf
echo HostName ${OPENSHIFT_APP_DNS} >> webalizer.conf
echo UseHTTPS yes >> webalizer.conf

cd ${OPENSHIFT_TMP_DIR}
rm webalizer-${webalizer_version}-src.tgz
rm -rf webalizer-${webalizer_version}

fi

# ***** wordpress *****

cd ${OPENSHIFT_TMP_DIR}
if [ -d ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` wordpress skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
cp ${OPENSHIFT_TMP_DIR}/download_files/wordpress-${wordpress_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` wordpress tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz wordpress-${wordpress_version}.tar.gz --strip-components=1

# # force ssl patch
# mkdir -p wp-content/mu-plugins
# cd wp-content/mu-plugins
# cp ${OPENSHIFT_TMP_DIR}/download_files/is_ssl.php ./
# cd ../../wp-includes
# perl -pi -e 's/(^function is_ssl\(\) \{)$/$1\n\treturn is_maybe_ssl\(\);/g' functions.php

# create database
wpuser_password=`uuidgen | awk -F - '{print $1 $2 $3 $4 $5}' | head -c 20`
cd ${OPENSHIFT_TMP_DIR}
cat << '__HEREDOC__' > create_database_wordpress.txt
CREATE DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON wordpress.* TO wpuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_wordpress.txt
perl -pi -e "s/__PASSWORD__/${wpuser_password}/g" create_database_wordpress.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_wordpress.txt

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
cat << '__HEREDOC__' > wp-config.php
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', '__PASSWORD__');
define('DB_HOST', '__OPENSHIFT_MYSQL_DB_HOST__');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', 'utf8_general_ci');
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' wp-config.php
perl -pi -e "s/__PASSWORD__/${wpuser_password}/g" wp-config.php
cp ${OPENSHIFT_TMP_DIR}/download_files/salt.txt ./
cat ${OPENSHIFT_TMP_DIR}/salt.txt >> wp-config.php
rm ${OPENSHIFT_TMP_DIR}/salt.txt
cat << '__HEREDOC__' >> wp-config.php

$table_prefix  = 'wp_';
define('WPLANG', 'ja');
define('WP_DEBUG', false);

# define('FORCE_SSL_ADMIN', true);
# define('FORCE_SSL_LOGIN', true);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');

__HEREDOC__

echo `date +%Y/%m/%d" "%H:%M:%S` wordpress mysql wpuser/${wpuser_password} >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/wordpress
rm wordpress-${wordpress_version}.tar.gz

fi

# ***** Tiny Tiny RSS *****

cd ${OPENSHIFT_TMP_DIR}
if [ -d ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss
cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss
cp ${OPENSHIFT_TMP_DIR}/download_files/${ttrss_version}.tar.gz ./

echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar xfz ${ttrss_version}.tar.gz --strip-components=1

# create database
ttrssuser_password=`uuidgen | awk -F - '{print $1 $2 $3 $4 $5}' | head -c 20`
cd ${OPENSHIFT_TMP_DIR}
cat << '__HEREDOC__' > create_database_ttrss.txt
CREATE DATABASE ttrss CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON ttrss.* TO ttrssuser@__OPENSHIFT_MYSQL_DB_HOST__ IDENTIFIED BY '__PASSWORD__';
FLUSH PRIVILEGES;
EXIT
__HEREDOC__
perl -pi -e 's/__OPENSHIFT_MYSQL_DB_HOST__/$ENV{OPENSHIFT_MYSQL_DB_HOST}/g' create_database_ttrss.txt
perl -pi -e "s/__PASSWORD__/${ttrssuser_password}/g" create_database_ttrss.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" < create_database_ttrss.txt

mysql -u "${OPENSHIFT_MYSQL_DB_USERNAME}" \
--password="${OPENSHIFT_MYSQL_DB_PASSWORD}" \
-h "${OPENSHIFT_MYSQL_DB_HOST}" \
-P "${OPENSHIFT_MYSQL_DB_PORT}" ttrss < ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/schema/ttrss_schema_mysql.sql

echo `date +%Y/%m/%d" "%H:%M:%S` Tiny Tiny RSS mysql ttrssuser/${ttrssuser_password} >> ${OPENSHIFT_LOG_DIR}/install.log

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss
rm ${ttrss_version}.tar.gz

fi

# ***** PHP iCalendar *****

cd ${OPENSHIFT_TMP_DIR}
if [ -d ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal ]
then

echo `date +%Y/%m/%d" "%H:%M:%S` PHP iCalendar skip all >> ${OPENSHIFT_LOG_DIR}/install.log

else

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

mkdir ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal
cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal
cp ${OPENSHIFT_TMP_DIR}/download_files/phpicalendar-2.4_20100615.tar.bz2 ./

echo `date +%Y/%m/%d" "%H:%M:%S` PHP iCalendar tar >> ${OPENSHIFT_LOG_DIR}/install.log
tar jxf phpicalendar-2.4_20100615.tar.bz2 --strip-components=1

cd functions
cp ${OPENSHIFT_TMP_DIR}/download_files/ical_parser.php.patch ./
patch ical_parser.php ical_parser.php.patch

cd ${OPENSHIFT_DATA_DIR}/apache/htdocs/cal
rm phpicalendar-2.4_20100615.tar.bz2

fi

# ***** cron *****

# *** daily ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron daily >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/daily > /dev/null
rm -f *
touch jobs.deny

# * mysql_backup *

cp ${OPENSHIFT_TMP_DIR}/download_files/mysql_backup.sh ./
chmod +x mysql_backup.sh
echo mysql_backup.sh >> jobs.allow
./mysql_backup.sh
popd > /dev/null

# *** hourly ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron hourly >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly > /dev/null
rm -f *
touch jobs.deny

# * webalizer *

cat << '__HEREDOC__' > webalizer.sh
#!/bin/bash

export TZ=JST-9
cd ${OPENSHIFT_DATA_DIR}/webalizer
./bin/webalizer -c ./etc/webalizer.conf
__HEREDOC__
chmod +x webalizer.sh
echo webalizer.sh >> jobs.allow
popd > /dev/null

# *** minutely ***

echo `date +%Y/%m/%d" "%H:%M:%S` cron minutely >> ${OPENSHIFT_LOG_DIR}/install.log
pushd ${OPENSHIFT_REPO_DIR}/.openshift/cron/minutely > /dev/null
rm -f *
touch jobs.deny

# * keep_process *

cat << '__HEREDOC__' > keep_process.sh
#!/bin/bash

# delegated
is_alive=`ps -ef | grep delegated | grep -v grep | wc -l`
if [ ${is_alive} -gt 1 ]; then
  echo delegated is alive
else
  echo ${is_alive}
  echo RESTART delegated
  cd ${OPENSHIFT_DATA_DIR}/delegate/
  export TZ=JST-9
  ./delegated -r +=P50080
fi

# memcached
is_alive=`ps -ef | grep memcached | grep -v grep | wc -l`
if [ ${is_alive} -gt 1 ]; then
  echo memcached is alive
else
  echo ${is_alive}
  echo RESTART memcached
  cd ${OPENSHIFT_DATA_DIR}/memcached/
  ./bin/memcached -l ${OPENSHIFT_DIY_IP} -p 51211 -d
fi
__HEREDOC__

chmod +x keep_process.sh
echo keep_process.sh >> jobs.allow

# * mrtg *

cat << '__HEREDOC__' > mrtg.sh
#!/bin/bash

mpstat 5 1 | grep ^Average | awk '{print $3+$4+$5+$6+$7+$8+$9+$10}' > ${OPENSHIFT_TMP_DIR}/cpu_usage_current
cd ${OPENSHIFT_DATA_DIR}/mrtg
export TZ=JST-9
env LANG=C ./bin/mrtg mrtg.conf
__HEREDOC__
chmod +x mrtg.sh
echo mrtg.sh >> jobs.allow

# * Tiny Tiny Rss update feeds *

cat << '__HEREDOC__' > update_feeds.sh
#!/bin/bash

minute=`date +%M`

if [ `expr ${minute} % 5` -eq 0 ]; then
    ${OPENSHIFT_DATA_DIR}/php/bin/php ${OPENSHIFT_DATA_DIR}/apache/htdocs/ttrss/update.php --feeds
fi
__HEREDOC__
chmod +x update_feeds.sh
echo update_feeds.sh >> jobs.allow

echo `quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.usage_in_bytes | awk '{print "Memory Usage : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log
echo `oo-cgroup-read memory.failcnt | awk '{print "Memory Fail Count : " $1}'` >> ${OPENSHIFT_LOG_DIR}/install.log

echo `date +%Y/%m/%d" "%H:%M:%S` Install Finish >> ${OPENSHIFT_LOG_DIR}/install.log

# ***** start *****

kill `netstat -anpt 2>/dev/null | grep ${OPENSHIFT_DIY_IP} | grep LISTEN | awk '{print $7}' | awk -F/ '{print $1}'`
cd ${OPENSHIFT_DATA_DIR}
export TZ=JST-9
./apache/bin/apachectl -k graceful
cd delegate
./delegated -r +=P50080

wget --spider https://${OPENSHIFT_APP_DNS}/
sleep 5s

cd ${OPENSHIFT_REPO_DIR}/.openshift/cron/hourly/
./webalizer.sh

set +x

echo https://${OPENSHIFT_APP_DNS}/wordpress/wp-admin/install.php
echo https://${OPENSHIFT_APP_DNS}/ttrss/install/ ttrssuser/${ttrssuser_password} ttrss ${OPENSHIFT_MYSQL_DB_HOST} admin/password
echo https://${OPENSHIFT_APP_DNS}/cal/
echo https://${OPENSHIFT_APP_DNS}/mail/
echo https://${OPENSHIFT_APP_DNS}/webalizer/
echo https://${OPENSHIFT_APP_DNS}/mrtg/
