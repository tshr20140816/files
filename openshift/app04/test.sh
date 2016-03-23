#!/bin/bash

echo "0853"

set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

unzip --help

target_file=${OPENSHIFT_DATA_DIR}ccache/bin/ccache
compressed_file=$(echo ${target_file} | sed -e "s|${OPENSHIFT_DATA_DIR}|${OPENSHIFT_DATA_DIR}/compressed/|g")
echo ${compressed_file}

exit
