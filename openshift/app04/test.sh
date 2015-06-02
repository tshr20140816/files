#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -rf binutils-2.25
rm -rf bison-3.0
rm -f cadaver_put.sh
rm -rf distcc-3.1
rm -f monitor_resourse.sh
rm -f test.txt
rm -rf xz-5.2.1

gcc -march=native -Q --help=target

ls -lang
ls -lang ${OPENSHIFT_DATA_DIR}
