#!/bin/bash

set -x

export target_data_dir='xxx' # ${OPENSHIFT_DATA_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

cd /tmp

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2
tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29

./configure \
 --prefix=${target_data_dir}/apache \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --enable-mods-shared='all proxy'

time make -j$(grep -c -e processor /proc/cpuinfo)

cd ..
tar Jcf httpd.tar.xz httpd-2.2.29
rm -rf httpd-2.2.29

wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar zxf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18

./configure \
 --prefix=${target_data_dir}/libmemcached \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc

time make -j2 -l3

cd ..
tar Jcf libmemcached.tar.xz libmemcached-1.0.18
rm -rf libmemcached-1.0.18
