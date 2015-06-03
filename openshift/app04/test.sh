#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log.*

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
# export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

cd /tmp

# wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2
# tar jxf binutils-2.25.tar.bz2
cd binutils-2.25
make clean
# ./configure --help
./configure
make -j4
