#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log.*

cd /tmp

# wget http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2
# tar jxf binutils-2.25.tar.bz2
cd binutils-2.25
# ./configure --help
# ./configure
make -j4
