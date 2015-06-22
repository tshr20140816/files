#!/bin/bash

export TZ=JST-9

tail -n 10000 ${OPENSHIFT_LOG_DIR}/cron_minutely.log > ${OPENSHIFT_LOG_DIR}/cron_minutely.log

echo "$(date)"

rm -f ${OPENSHIFT_LOG_DIR}/cron_minutely.log.*
rm -f ${OPENSHIFT_LOG_DIR}/ccache.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc.log
rm -f ${OPENSHIFT_LOG_DIR}/distcc_ssh.log
rm -f ${OPENSHIFT_TMP_DIR}/distcc_server_stderr_*
ls -d /tmp/cc* | grep -v ccache$ | xargs rm -f

set -x

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

rm -rf libxml2
rm -rf local
rm -rf local2

ls -lang /tmp
ls -lang ${OPENSHIFT_DATA_DIR}

cd /tmp

[ -f autossh-1.4e.tgz ] || wget http://www.harding.motd.ca/autossh/autossh-1.4e.tgz

rm -rf autossh-1.4e
tar zxf autossh-1.4e.tgz

cd autossh-1.4e
./configure --help
./configure --prefix=${OPENSHIFT_DATA_DIR}/autossh > /dev/null
time make -j4
