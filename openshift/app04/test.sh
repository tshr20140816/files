#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
# export CC="ccache gcc"
# export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
# export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

ccache -z

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
ln -s ccache cc
ln -s ccache gcc

rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

cd /tmp

ls -lang

[ -f ./binutils-2.25.tar.bz2 ] || wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2
rm -rf binutils-2.25
tar jxf binutils-2.25.tar.bz2
cd binutils-2.25
./configure --help
./configure --enable-gold --disable-libquadmath --disable-libstdcxx
time make -j4

ccache -s

# tree

cd ${OPENSHIFT_DATA_DIR}/ccache/bin 
unlink cc
unlink gcc
