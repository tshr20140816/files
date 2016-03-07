#!/bin/bash

echo "0840"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

cd /tmp

rm -f *.png
rm -f *.png.bak

ls -lang

cd ${OPENSHIFT_DATA_DIR}

ls -lang

exit
