#!/bin/bash

echo "1138"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang
rm -f xymon-4.3.27.tar.gz*
rm -rf xymon-4.3.27
rm -f fping-3.13.tar.gz
rm -rf fping-3.13
rm -rf ${OPENSHIFT_DATA_DIR}/fping

ping -c 10 8.8.8.8

exit
