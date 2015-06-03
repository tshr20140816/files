#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log.*

cd /tmp

rm -rf glibc-2.14.1
rm -rf gcc
rm -f cc*
rm -f test.tar.xz

wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2
tar jxf binutils-2.25.tar.bz2
cd binutils-2.25
./configure --help
./configure
