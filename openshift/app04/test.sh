#!/bin/bash

# 1015

set -x

quota -s

${OPENSHIFT_DATA_DIR}/squid/sbin/squid --help

exit

# tree ${OPENSHIFT_DATA_DIR}/squid
cp ${OPENSHIFT_DATA_DIR}/squid/etc/* ${OPENSHIFT_LOG_DIR}

exit

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
ccache --zero-stats 

cd /tmp

# rm -f squid-3.5.7.tar.xz
rm -rf squid-3.5.7

if [ ! -f squid-3.5.7.tar.xz ]; then
    wget http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.7.tar.xz
fi

# tar Jxf squid-3.5.7.tar.xz
if [ -f squid_src.tar.xz ]; then
  tar Jxf squid_src.tar.xz
else
  tar Jxf squid-3.5.7.tar.xz
fi

cd squid-3.5.7

export CFLAGS="-O2 -march=native -pipe -fomit-frame-pointer -s"
export CXXFLAGS="${CFLAGS}"

# ./configure --help

if [ ! -f /tmp/squid_src.tar.xz ]; then
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
  --disable-auto-locale
fi

cd ..
if [ ! -f squid_src.tar.xz ]; then
  tar Jcf squid_src.tar.xz squid-3.5.7
fi

cd squid-3.5.7

time make -j4

time make install
