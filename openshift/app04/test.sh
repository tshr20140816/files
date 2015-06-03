#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log.*

cd /tmp

find / -name ld.* -print 2>/dev/null

ls -lang

