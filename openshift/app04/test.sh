#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -f xz-5.2.1.tar.xz
rm -rf xz-5.2.1
wget http://tukaani.org/xz/xz-5.2.1.tar.xz
tar Jxf xz-5.2.1.tar.xz
cd xz-5.2.1
./configure --help
