#!/bin/bash

echo "0917"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

rm -f compressed_files.zip
rm -rf nkf-2.1.4

echo "$(quota -s | grep -v a | awk '{print "Disk Usage : " $1,$4 " files"}')" | tee test.txt

echo "CHECK POINT 010"
cat test.txt
rm -f test.txt
exit
