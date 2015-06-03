#!/bin/bash

# echo "$(date)" > ${OPENSHIFT_LOG_DIR}/test.log

set -x

rm -f $OPENSHIFT_LOG_DIR/cron_minutely.log.*

cd /tmp

rm -rf glibc-2.14.1
rm -rf gcc
rm -f cc*
rm -f test.tar.xz


ls -lang

