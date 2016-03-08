#!/bin/bash

echo "0927"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

find ${OPENSHIFT_DATA_DIR} -name *.css -print

exit
