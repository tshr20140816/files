#!/bin/bash

# 1508

export TZ=JST-9

echo "$(date)"
echo ${OPENSHIFT_PHP_IP}

set -x

find / -name apxs -print 2>/dev/null

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cflag_data=$(gcc -march=native -E -v - </dev/null 2>&1 | sed -n 's/.* -v - //p')
export CFLAGS="-O2 ${cflag_data} -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_COMPILERCHECK=none
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
rm -rf ${CCACHE_DIR}
mkdir ${CCACHE_DIR}
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M
export CCACHE_NLEVELS=3

cd /tmp
rm -f libmemcached-${libmemcached_version}.tar.gz
rm -rf libmemcached-${libmemcached_version}
libmemcached_version=1.0.18
wget https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz

tar zxf libmemcached-${libmemcached_version}.tar.gz
cd libmemcached-${libmemcached_version}
./configure --help
./configure \
 --prefix=${OPENSHIFT_DATA_DIR}/libmemcached \
 --mandir=${OPENSHIFT_TMP_DIR}/man \
 --docdir=${OPENSHIFT_TMP_DIR}/doc \
 --disable-sasl \
 --enable-jobserver=3 > /dev/null

time make

grep -r ${OPENSHIFT_APP_UUID} ./
