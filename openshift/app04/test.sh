#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

rm -rf ${OPENSHIFT_DATA_DIR}/.gnupg
rm -f xz-5.2.1.tar.xz
rm -f xz-5.2.1.tar.xz.sig
rm -rf xz-5.2.1
