#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

# rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log
# touch $OPENSHIFT_LOG_DIR/cron_minutely.log

# cat /usr/libexec/openshift/cartridges/cron/bin/cron_runjobs.sh

cd /tmp

head --help
${OPENSHIFT_DATA_DIR}/xz/bin/xz --help
gcc --version

gcc -march=native -Q --help=target
gcc -march=core2 -Q --help=target
