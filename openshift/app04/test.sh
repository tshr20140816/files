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
rm -rf ${CCACHE_DIR}
mkdir ${CCACHE_DIR}
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${OPENSHIFT_TMP_DIR}/tmp_ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M
export CCACHE_NLEVELS=3
ccache -s
ccache --zero-stats

export LD=ld.gold
rm -rf /tmp/local
mkdir -p /tmp/local/bin
cp -f /tmp/ld.gold /tmp/local/bin/
export PATH="/tmp/local/bin:$PATH"

ccache -s
