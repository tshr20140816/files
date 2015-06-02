#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

apache_version=2.2.29

rm -f httpd-${apache_version}.tar.bz2
rm -rf httpd-${apache_version}
rm -f test.tar.xz

gcc -march=native -Q --help=target

ls -lang
ls -lang ${OPENSHIFT_DATA_DIR}
