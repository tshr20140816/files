#!/bin/bash

echo "1421"

# set -x

rm -f ${OPENSHIFT_LOG_DIR}/test.log
rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log-*

ls -lang ${OPENSHIFT_LOG_DIR}/cron_minutely.log

if [ $(wc -c < ${OPENSHIFT_LOG_DIR}/cron_minutely.log) -gt 100000 ]; then
    tail -n 1000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log
fi

cd /tmp

# ls -lang

rm -f test.php*

export GEM_HOME=${OPENSHIFT_DATA_DIR}/.gem
export PATH="${OPENSHIFT_DATA_DIR}/.gem/bin:$PATH"
export HOME=${OPENSHIFT_DATA_DIR}
gem --version
# gem environment

# yes | rhc app delete -a portal5
# yes | rhc app create portal5 diy-0.1 mysql-5.5 cron-1.4 phpmyadmin-4 --server openshift.redhat.com

server_link=$(rhc apps | grep ssh | grep portal5 | awk '{print $3}' | awk -F/ '{print $3}')
echo ${server_link}
ssh ${server_link} cat /proc/cpuinfo

export HOME=${OPENSHIFT_HOME_DIR}

exit
