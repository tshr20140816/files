#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -f gcc-5.1.1-1.fc22.x86_64.rpm

/tmp/gcc/usr/bin/gcc --version
/tmp/gcc/usr/bin/gcc --help

# wget ftp://195.220.108.108/linux/fedora/linux/releases/22/Everything/x86_64/os/Packages/g/gcc-5.1.1-1.fc22.x86_64.rpm

# mkdir gcc
# cd gcc
# mv ../gcc-5.1.1-1.fc22.x86_64.rpm ./

# rpm2cpio gcc-5.1.1-1.fc22.x86_64.rpm | cpio -idmv

# ls -lang
