#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

gcc --version

gcc -march=native -Q --help=target
gcc -march=core2 -Q --help=target

# wget https://ftp.gnu.org/gnu/gcc/gcc-4.6.4/gcc-4.6.4.tar.bz2

# tar jxf gcc-4.6.4.tar.bz2

rm -rf gcc-4.6.4
