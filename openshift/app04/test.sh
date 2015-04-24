#!/bin/bash

echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# dummy

cd /tmp
if [ ! -e ${OPENSHIFT_DATA_DIR}/ccache ]; then
    if [ ! -f ccache-3.2.1.tar.xz ]; then
        wget https://files3-20150207.rhcloud.com/files/ccache-3.2.1.tar.xz
    fi
    tar Jxf ccache-3.2.1.tar.xz
    cd ccache-3.2.1
    CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s" CXXFLAGS="-O2 -march=native -pipe" \
     ./configure --prefix=${OPENSHIFT_DATA_DIR}/ccache --mandir=/tmp/man --docdir=/tmp/doc
    make
    make install
fi

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_MAXSIZE=300M
export CCACHE_BASEDIR=${OPENSHIFT_HOME_DIR}

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

ls -lang /tmp

cd /tmp

rm -rf grafana
rm -rf grafana-2.0.1
rm -f grafana-2.0.1.linux-x64.tar.gz
rm -f centos-initscripts.patch
rm -f ccache.tar.xz
rm -f ccache_php.tar.xz
rm -f pbzip2-1.1.12
rm -f php-5.6.8.tar.xz
rm -rf php-5.6.8

ccache -C
ccache -z

ls -lang /tmp

export target_data_dir=/var/lib/openshift/552a8c5fe0b8cd8ae0000031/app-root/data/
export target_tmp_dir=/tmp/

rm -rf httpd-2.2.29
rm -f httpd-2.2.29.tar.bz2

wget http://ftp.riken.jp/net/apache//httpd/httpd-2.2.29.tar.bz2
tar jxf httpd-2.2.29.tar.bz2
cd httpd-2.2.29

./configure \
 --prefix=${target_data_dir}/apache \
 --mandir=${target_tmp_dir}/man \
 --docdir=${target_tmp_dir}/doc \
 --enable-mods-shared='all proxy'

time make -j$(grep -c -e processor /proc/cpuinfo)

cd ..
rm -rf maked_httpd-2.2.29.tar.xz
time tar Jcf maked_httpd-2.2.29.tar.xz httpd-2.2.29
rm -rf httpd-2.2.29

ccache -s

ls -lang /tmp
