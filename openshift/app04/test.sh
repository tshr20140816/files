#!/bin/bash

echo "1048"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log &
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-* &

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

# wget --help

curl --help

rm -f ttrss_archive.zip
rm -f 01_ttrss_archive.zip
rm -f 02_ttrss_archive.zip

echo "START $(date +%Y/%m/%d" "%H:%M:%S)"

curl -LI https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.zip?ref=master

echo "FINISH $(date +%Y/%m/%d" "%H:%M:%S)"

ls -lang

exit
