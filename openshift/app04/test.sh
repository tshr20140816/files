#!/bin/bash

# 1546

set -x

quota -s

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
rm -rf ${CCACHE_TEMPDIR}
mkdir -p ${CCACHE_TEMPDIR}
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
export CCACHE_NLEVELS=3
export CCACHE_MAXSIZE=300M
export CCACHE_COMPILERCHECK=none
export CC="ccache gcc"
export CXX="ccache g++"

ccache --show-stats

cd /tmp

# rm -f squid-3.5.7.tar.xz
rm -rf squid-3.5.7

# wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.7.tar.xz

tar Jxf squid-3.5.7.tar.xz

cd squid-3.5.7

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ./configure --help

cp ../config.site ./

time ./configure --prefix=${OPENSHIFT_DATA_DIR}/squid \
 --mandir=/tmp/gomi \
 --infodir=/tmp/gomi \
 --docdir=/tmp/gomi \
 --disable-dependency-tracking \
 --enable-shared \
 --enable-static=no \
 --enable-fast-install \
 --disable-icap-client \
 --disable-wccp \
 --disable-wccpv2 \
 --disable-snmp \
 --disable-eui \
 --disable-htcp \
 --disable-devpoll \
 --disable-ipv6 \
 --disable-auto-locale \
 --config-cache \
 -C

cp config.cache /tmp/config.site

time make -j4
