#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -f gcc-5.1.1-1.fc22.x86_64.rpm

export LD_LIBRARY_PATH="/tmp/gcc/usr/lib"
/tmp/gcc/usr/bin/gcc --version
/tmp/gcc/usr/bin/gcc --help

# printenv
# printenv | grep LIB

cd glibc-2.14.1
mkdir build
cd build
../configure --prefix=${OPENSHIFT_DATA_DIR}/lib
time make -j4

find /tmp -name libc.so* -print

# wget http://ftp.gnu.org/gnu/glibc/glibc-2.14.1.tar.xz
# wget ftp://195.220.108.108/linux/fedora/linux/releases/22/Everything/x86_64/os/Packages/g/gcc-5.1.1-1.fc22.x86_64.rpm

# mkdir gcc
# cd gcc
# mv ../gcc-5.1.1-1.fc22.x86_64.rpm ./

# rpm2cpio gcc-5.1.1-1.fc22.x86_64.rpm | cpio -idmv

# ls -lang
