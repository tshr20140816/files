#!/bin/bash

echo "1514"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

ls -lang

cd ${OPENSHIFT_DATA_DIR}

ls -lang

exit
