#!/bin/bash

export TZ=JST-9
set -x
quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# ***** apache *****

apache_version=2.4.23

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/httpd/httpd-${apache_version}.tar.bz2
tar xf httpd-${apache_version}.tar.bz2
pushd httpd-${apache_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr
time make -j4
make install
popd > /dev/null
rm -rf httpd-${apache_version}
rm -f httpd-${apache_version}.tar.bz2
popd > /dev/null

# ***** php *****

php_version=7.1.0

pushd ${OPENSHIFT_TMP_DIR} > /dev/null
wget -q http://jp2.php.net/get/php-${php_version}.tar.xz/from/this/mirror -O php-${php_version}.tar.xz
tar xf php-${php_version}.tar.xz
pushd php-${php_version} > /dev/null
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr
time make -j1
make install
popd > /dev/null
rm -rf php-${php_version}
rm -f php-${php_version}.tar.xz
popd > /dev/null

# ***** wordpress *****

wordpress_version=4.7-ja

pushd ${OPENSHIFT_DATA_DIR} > /dev/null
wget -q https://ja.wordpress.org/wordpress-${wordpress_version}.tar.gz
tar xf wordpress-${wordpress_version}.tar.gz
rm -f wordpress-${wordpress_version}.tar.gz
popd > /dev/null

quota -s
