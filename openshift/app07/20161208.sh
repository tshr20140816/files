#!/bin/bash

export TZ=JST-9
set -x
quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** ccache *****

ccache_version=3.3.3

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q https://www.samba.org/ftp/ccache/ccache-${ccache_version}.tar.xz
tar xf ccache-${ccache_version}.tar.xz
pushd ccache-${ccache_version} > /dev/null
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_ccache
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr
time make -j4
make install
popd > /dev/null
rm -f ccache-${ccache_version}.tar.xz
popd > /dev/null

export PATH="${OPENSHIFT_DATA_DIR}/usr/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_DATA_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/
# export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

mkdir -p ${CCACHE_DIR}
mkdir -p ${CCACHE_TEMPDIR}

# ***** apache *****

# *** pcre ***

pcre_version=8.39

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${pcre_version}.tar.bz2
tar xf pcre-${pcre_version}.tar.bz2
pushd pcre-${pcre_version} > /dev/null
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_pcre
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --enable-static=no
time make -j4
make install
popd > /dev/null
rm -rf pcre-${pcre_version}
rm -f pcre-${pcre_version}.tar.bz2
popd > /dev/null

# *** httpd ***

apache_version=2.4.25
apr_version=1.5.2
aprutil_version=1.5.4

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-${apache_version}.tar.bz2
tar xf httpd-${apache_version}.tar.bz2

wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-${apr_version}.tar.bz2
tar xf apr-${apr_version}.tar.bz2
mv -f ./apr-${apr_version} ./httpd-${apache_version}/srclib/apr

wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-${aprutil_version}.tar.bz2
tar xf apr-util-${aprutil_version}.tar.bz2
mv -f ./apr-util-${aprutil_version} ./httpd-${apache_version}/srclib/apr-util

pushd httpd-${apache_version} > /dev/null
./configure --help > ${OPENSHIFT_LOG_DIR}/configure_apache
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --with-pcre=${OPENSHIFT_DATA_DIR}/usr
time make -j4
make install
popd > /dev/null
rm -rf httpd-${apache_version}
rm -f *.tar.bz2
popd > /dev/null

# ***** php *****

php_version=7.1.0

# pushd ${OPENSHIFT_DATA_DIR}/usr/bin > /dev/null
# wget -q https://raw.githubusercontent.com/tshr20140816/files/master/openshift/app07/gcc.sh
# chmod +x gcc.sh
# popd > /dev/null
# export CC="gcc.sh"
# export CXX="gcc.sh"
# export PATH="${OPENSHIFT_DATA_DIR}/usr/bin:$PATH"

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar xf php-${php_version}.tar.xz
pushd php-${php_version} > /dev/null
# ./configure --help > ${OPENSHIFT_LOG_DIR}/configure_php
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/usr \
 --with-apxs2=${OPENSHIFT_DATA_DIR}/usr/bin/apxs \
 --without-sqlite3 \
 --without-pdo-sqlite \
 --without-cdb \
 --without-pear \
 --with-curl \
 --with-gd \
 --disable-fileinfo \
 --disable-ipv6 \
 --enable-fpm \
 --enable-mbstring \
 --with-pdo-mysql \
 --disable-phar \
 --disable-phpdbg

time make -j1 | tee -a ${OPENSHIFT_LOG_DIR}/install_php.log
make install
popd > /dev/null
rm -rf php-${php_version}
rm -f php-${php_version}.tar.xz

# ttrss

popd > /dev/null

pushd ${OPENSHIFT_DATA_DIR} > /dev/null

rm -rf tt-rss
git clone https://tt-rss.org/git/tt-rss.git
mv tt-rss ttrss

popd > /dev/null

exit

# ***** wordpress *****

wordpress_version=4.7-ja

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget -q https://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
tar xf wordpress-${wordpress_version}.tar.gz
rm -f wordpress-${wordpress_version}.tar.gz
popd > /dev/null

quota -s
