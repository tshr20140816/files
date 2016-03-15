#!/bin/bash

echo "0928"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 1000000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# ls -lang

cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 >1.txt
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 >>1.txt

cat 1.txt

exit
