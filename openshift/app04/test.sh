#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

if [ 1 -eq 0 ]; then
cd /tmp
wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2

tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy'

time make -j4
make install
cd $OPENSHIFT_DATA_DIR
rm -rf apache/manual
fi

cd /tmp

export HOME=${OPENSHIFT_DATA_DIR}

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_COMPILERCHECK=none
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${OPENSHIFT_TMP_DIR}/tmp_ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M
export CCACHE_NLEVELS=3
ccache -s
ccache --zero-stats

# wget https://files3-20150207.rhcloud.com/files/ld.gold
export LD=ld.gold
# rm -rf /tmp/local
# mkdir -p /tmp/local/bin
cp -f /tmp/ld.gold /tmp/local/bin/
export PATH="/tmp/local/bin:$PATH"

php_version=5.6.10
rm -rf php-${php_version}
# rm -f php-${php_version}.tar.xz
# wget http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar Jxf php-${php_version}.tar.xz

cd php-${php_version}
./configure \
--prefix=${OPENSHIFT_DATA_DIR}/php \
--mandir=${OPENSHIFT_TMP_DIR}/man \
--docdir=${OPENSHIFT_TMP_DIR}/doc \
--infodir=${OPENSHIFT_TMP_DIR}/info \
--with-apxs2=${OPENSHIFT_DATA_DIR}/apache/bin/apxs \
--with-mysql \
--with-pdo-mysql \
--without-sqlite3 \
--without-pdo-sqlite \
--without-cdb \
--without-pear \
--with-curl \
--with-libdir=lib64 \
--with-bz2 \
--with-iconv \
--with-openssl \
--with-zlib \
--with-gd \
--enable-exif \
--enable-ftp \
--enable-xml \
--enable-mbstring \
--enable-mbregex \
--enable-sockets \
--disable-ipv6 \
--with-gettext=${OPENSHIFT_DATA_DIR}/php \
--with-zend-vm=GOTO

time make -j4

tar Jcf ccache_php.tar.xz ${CCACHE_DIR}
ccache -s

ls /tmp
