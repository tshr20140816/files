#!/bin/bash

echo "1521"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 1000000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

rm -f *.js
rm -f *.txt
rm -f ttrss_archive.zip

ls -lang

cd ${OPENSHIFT_DATA_DIR}

rm -f ttrss_archive.zip
rm -rf tt-rss.git

ls -lang

exit
