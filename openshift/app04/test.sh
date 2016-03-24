#!/bin/bash

echo "1025"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

ls -lang

target_file=${OPENSHIFT_DATA_DIR}ccache/bin/ccache
path=$(echo ${target_file} | sed -e "s|${OPENSHIFT_HOMEDIR}||g")
echo ${path}

path=$(echo "${target_file||${OPENSHIFT_HOMEDIR}|}")
echo ${path}

exit
