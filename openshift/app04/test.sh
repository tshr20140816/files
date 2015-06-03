#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

export PATH="${OPENSHIFT_DATA_DIR}/ccache/bin:$PATH"
export CC="ccache gcc"
export CXX="ccache g++"
export CCACHE_DIR=${OPENSHIFT_TMP_DIR}/ccache
export CCACHE_TEMPDIR=${OPENSHIFT_TMP_DIR}/tmp_ccache
export CCACHE_LOGFILE=${OPENSHIFT_LOG_DIR}/ccache.log
# export CCACHE_LOGFILE=/dev/null
export CCACHE_MAXSIZE=300M

mkdir ${OPENSHIFT_TMP_DIR}/ccache
mkdir ${OPENSHIFT_TMP_DIR}/tmp_ccache

ccache -s

tree ${OPENSHIFT_DATA_DIR}/ccache/bin

cd /tmp

# rm -f gcc-5.1.1-1.fc22.x86_64.rpm
rm -f glibc-2.14.1.tar.xz

# export LD_LIBRARY_PATH="/tmp/gcc/usr/lib"
/tmp/gcc/usr/bin/gcc --version
/tmp/gcc/usr/bin/gcc --help

# printenv
# printenv | grep LIB

cd glibc-2.14.1
rm -rf build
mkdir build
cd build
make clean
../configure --prefix=${OPENSHIFT_DATA_DIR}/lib
time make -j4

find /tmp -name libc.so* -print

# wget http://ftp.gnu.org/gnu/glibc/glibc-2.14.1.tar.xz
# wget ftp://195.220.108.108/linux/fedora/linux/releases/22/Everything/x86_64/os/Packages/g/gcc-5.1.1-1.fc22.x86_64.rpm

# rpm2cpio gcc-5.1.1-1.fc22.x86_64.rpm | cpio -idmv

# ls -lang
