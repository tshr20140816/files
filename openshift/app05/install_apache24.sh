#!/bin/bash

export TZ=JST-9
set -x
quota -s
oo-cgroup-read memory.usage_in_bytes
oo-cgroup-read memory.failcnt

export CFLAGS="-O2 -march=native -fomit-frame-pointer -s -pipe"
export CXXFLAGS="${CFLAGS}"

# pcre

cd /tmp
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}
wget -q ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
tar xf pcre-8.38.tar.bz2
cd pcre-8.38
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc
time make -j4
make install

# apache

cd /tmp
rm -rf ${tmp_dir}
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}
wget -q http://ftp.yz.yamagata-u.ac.jp/pub/network/apache//httpd/httpd-2.4.20.tar.bz2
tar xf httpd-2.4.20.tar.bz2
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-1.5.2.tar.bz2
tar xf apr-1.5.2.tar.bz2
mv -f ./apr-1.5.2 ./httpd-2.4.20/srclib/apr
wget -q http://ftp.tsukuba.wide.ad.jp/software/apache//apr/apr-util-1.5.4.tar.bz2
tar xf apr-util-1.5.4.tar.bz2
mv -f ./apr-util-1.5.4 ./httpd-2.4.20/srclib/apr-util
rm -f *.bz2

cd httpd-2.4.20
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/usr --mandir=${OPENSHIFT_TMP_DIR}/gomi/man --docdir=${OPENSHIFT_TMP_DIR}/gomi/doc \
 -enable-mods-shared='all proxy' --with-mpm=event --with-pcre=${OPENSHIFT_DATA_DIR}/usr
time make -j4
make install

# php

cd /tmp
rm -rf ${tmp_dir}
tmp_dir=$(mktemp -d tmp.XXXXX)
cd ${tmp_dir}

wget -q http://us1.php.net/get/php-7.0.5.tar.xz/from/this/mirror -O php-7.0.5.tar.xz
tar xf php-7.0.5.tar.xz
cd php-7.0.5
./configure --help

cd /tmp
rm -rf ${tmp_dir}
