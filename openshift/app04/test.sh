#!/bin/bash

echo "1552"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

ps aux | grep -e httpd | grep -e ${OPENSHIFT_APP_UUID} | grep -c -v grep

pgrep -fl httpd

pgrep --help

exit
